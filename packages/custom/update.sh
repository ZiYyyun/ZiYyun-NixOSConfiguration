#!/usr/bin/env bash
# File: update.sh — packages/custom 自定义包的上游更新检查/升级助手
# Author: ziyun
#
# 用法:
#   ./update.sh                     # 检查所有可自动查询上游的包，报告可更新项
#   ./update.sh --bump <包名>        # 升级到自动探测到的最新版（改 version + hash）
#   ./update.sh --bump <包名> <ver>  # 手动指定版本升级（用于 trae-code 等无清单源的包）
#   ./update.sh --bump --all        # 升级所有探测到更新的自动包
#   ./update.sh --bump --all --verify  # 同上，但每个包 bump 后跑 nix build 验证，失败则回退
#
# 各包版本来源:
#   flex-movie   https://flex-download.pages.dev/updates/latest.json (Tauri 清单)
#   qwen         GitHub releases (youssefvdel/qwen-studio)
#   codebuddy    JipZeonGit/codebuddy-ide-cn-linux 的 Makefile (CB_*)
#   dsh          npm dist-tags (@deepseek-ai/dsh)
#   dsh-plugins  固定到 GitHub main 当前提交（doctor + deep-whale）
#   qoder        URL 不带版本号(永远最新)，check 仅提示；bump 需显式给版本号
#   trae-code    无机器可读清单，bump 需显式给版本号
#   webapps/winapps/其余 vendored 静态包  无上游版本，跳过
#
# bump 只改文件里的 version/hash 并用 `nix store prefetch-file` 预取真实 hash；
# dsh 的 npmDepsHash 例外（无法离线预取），bump_dsh 内部用 fakeHash 两轮校准。
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO"

# jq 未安装时经 nix shell 提供后重入本脚本
if ! command -v jq >/dev/null 2>&1; then
    exec nix shell nixpkgs#jq -c bash "$0" "$@"
fi

GH_PROXY="https://ghfast.top"   # 国内直连 GitHub raw 的加速代理
FAKE_SRI="sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="  # npmDepsHash 校准占位

MODE="check"
ALL=0
VERIFY=0
PKG=""
EXPLICIT_VER=""
while [ $# -gt 0 ]; do
    case "$1" in
        --check)  MODE="check" ;;
        --bump)   MODE="bump" ;;
        --all)    ALL=1 ;;
        --verify) VERIFY=1 ;;
        -h|--help) sed -n '2,26p' "$0"; exit 0 ;;
        *) if [ -z "$PKG" ]; then PKG="$1"
           elif [ -z "$EXPLICIT_VER" ]; then EXPLICIT_VER="$1"
           else echo "多余参数: $1" >&2; exit 1; fi ;;
    esac
    shift
done

# 当前 flake 里登记的版本
cur() { nix eval --raw ".#packages.x86_64-linux.$1.version" 2>/dev/null || echo "?"; }

# 预取 URL 的 SRI hash
prefetch() { nix store prefetch-file "$1" --json | jq -r '.hash'; }

# —— 上游最新版本探测 ——
up_flex_movie()  { curl -sL "https://flex-download.pages.dev/updates/latest.json" | jq -r .version; }
up_qwen()        { curl -sL "https://api.github.com/repos/youssefvdel/qwen-studio/releases/latest" | jq -r .tag_name | sed 's/^v//'; }
up_dsh()         { curl -sL "https://registry.npmjs.org/@deepseek-ai/dsh" | jq -r '."dist-tags".latest'; }
up_dshmarket()   { curl -sL "https://registry.npmjs.org/dshmarket" | jq -r '."dist-tags".latest'; }
up_git_head()    { git ls-remote "$GH_PROXY/https://github.com/$1.git" refs/heads/main | awk '{print $1}'; }
# codebuddy: Makefile 的 CB_VERSION/CB_BUILD/CB_HASH → "4.11.3.37298507-2345dde1"
up_codebuddy()   { local mk v b h
                   mk=$(curl -sL "$GH_PROXY/https://raw.githubusercontent.com/JipZeonGit/codebuddy-ide-cn-linux/main/Makefile")
                   v=$(sed -n 's/^.*CB_VERSION[[:space:]]*:=[[:space:]]*\([0-9.]*\).*/\1/p' <<<"$mk")
                   b=$(sed -n 's/^.*CB_BUILD[[:space:]]*:=[[:space:]]*\([0-9]*\).*/\1/p' <<<"$mk")
                   h=$(sed -n 's/^.*CB_HASH[[:space:]]*:=[[:space:]]*\([0-9a-f]*\).*/\1/p' <<<"$mk")
                   [ -n "$v$b$h" ] && echo "$v.$b-$h"; }

# 取文件里第一处 fetchurl url（模板，含 ${version} 占位）
file_url() { sed -n 's/^.*url = "\([^"]*\)".*/\1/p' "$1" | head -1; }

# —— 通用 bump 原语 ——
set_version() { sed -i "s|^  version = \".*\";|  version = \"$2\";|" "$1"; }
set_hash()    { sed -i "s|hash = \"sha256-[A-Za-z0-9+/=]*\"|hash = \"$2\"|" "$1"; }

# 单文件 + URL 模板含 ${version} 的包（flex-movie/qwen/trae-code/qoder）
bump_simple() { # $1=attr $2=dir $3=newver $4=url模板
    local f="packages/custom/dist/$2/default.nix"
    local new_hash
    new_hash=$(prefetch "${4//\$\{version\}/$3}")
    set_version "$f" "$3"
    set_hash "$f" "$new_hash"
    echo "  已更新 $f → version=$3 hash=${new_hash:0:20}..."
}

bump_codebuddy() { # $1=fullVer "4.11.3.37298507-2345dde1"
    local f="packages/custom/dist/codebuddy/default.nix"
    local short="${1%.*-*}"  # 去掉 .build-hash → 4.11.3
    local url="https://download.codebuddy.cn/aiide/linux-x64/CodeBuddy-linux-x64-$1-cn.deb"
    local new_hash; new_hash=$(prefetch "$url")
    set_version "$f" "$short"
    sed -i "s|CodeBuddy-linux-x64-[0-9.]*-[0-9a-f]*-cn\.deb|CodeBuddy-linux-x64-$1-cn.deb|" "$f"
    set_hash "$f" "$new_hash"
    echo "  已更新 $f → version=$short url=...$1... hash=${new_hash:0:20}..."
}

bump_dsh() { # $1=newver。dsh 特殊：vendored lock 需按新 tarball 重新生成
    local dir="packages/custom/source/deepseek-harness" v="$1" tmp got
    # 1) 重新生成 package-lock.json：新 tarball 的 package.json 剪掉 devDependencies
    #    （0.1.5-rc.1 起含未发布的 experimental 包会 E404）后再生成
    tmp=$(mktemp -d)
    curl -sL "https://registry.npmjs.org/@deepseek-ai/dsh/-/dsh-$v.tgz" -o "$tmp/dsh.tgz"
    tar xzf "$tmp/dsh.tgz" -C "$tmp" package/package.json
    ( cd "$tmp/package" &&
        nix shell nixpkgs#nodejs -c node -e "const fs=require('fs');const p=JSON.parse(fs.readFileSync('package.json','utf8'));delete p.devDependencies;fs.writeFileSync('package.json',JSON.stringify(p,null,2)+'\n')" &&
        nix shell nixpkgs#nodejs -c npm install --package-lock-only --ignore-scripts --no-audit --no-fund )
    cp "$tmp/package/package-lock.json" "$dir/package-lock.json"
    rm -rf "$tmp"
    # 2) version + src hash
    set_version "$dir/default.nix" "$v"
    set_hash "$dir/default.nix" "$(prefetch "https://registry.npmjs.org/@deepseek-ai/dsh/-/dsh-$v.tgz")"
    # 3) npmDepsHash 校准：先置 fakeHash 让 FOD 报 got 值，再填回并复验
    sed -i "s|npmDepsHash = \"sha256-[A-Za-z0-9+/=]*\"|npmDepsHash = \"$FAKE_SRI\"|" "$dir/default.nix"
    got=$(nix build .#packages.x86_64-linux.dsh --no-link 2>&1 | sed -n 's/^ *got: *\(sha256-[A-Za-z0-9+/=]*\)/\1/p' | head -1)
    if [ -n "$got" ]; then
        sed -i "s|npmDepsHash = \"$FAKE_SRI\"|npmDepsHash = \"$got\"|" "$dir/default.nix"
        nix build .#packages.x86_64-linux.dsh --no-link >/dev/null 2>&1 \
            && echo "  已更新 dsh → $v（lock 重生成，npmDepsHash=$got 校准完成）" \
            || echo "  ⚠ dsh $v hash 已填但仍构建失败，请手动检查" >&2
    else
        echo "  ⚠ 未能捕获 npmDepsHash got 值（已置 fakeHash），手动跑一次: nix build .#dsh" >&2
    fi
}

bump_dsh_plugins() { # 将 GitHub 插件更新到 main 当前提交，并保持 URL 固定
    local f="packages/custom/source/deepseek-harness/plugins.nix"
    local doctor_rev whale_rev doctor_url whale_url doctor_hash whale_hash
    doctor_rev=$(up_git_head Zhenyu98/dsh-context-doctor)
    whale_rev=$(up_git_head Small-tailqwq/dsh-deep-whale)
    doctor_url="$GH_PROXY/https://github.com/Zhenyu98/dsh-context-doctor/archive/$doctor_rev.tar.gz"
    whale_url="$GH_PROXY/https://github.com/Small-tailqwq/dsh-deep-whale/archive/$whale_rev.tar.gz"
    doctor_hash=$(prefetch "$doctor_url")
    whale_hash=$(prefetch "$whale_url")
    sed -i "/doctor = tgz \"dsh-context-doctor\"/,+2 {
      s|https://[^\"]*|$doctor_url|
      s|sha256-[A-Za-z0-9+/=]*|$doctor_hash|
    }" "$f"
    sed -i "/deepWhale = tgz \"dsh-deep-whale\"/,+2 {
      s|https://[^\"]*|$whale_url|
      s|sha256-[A-Za-z0-9+/=]*|$whale_hash|
    }" "$f"
    echo "  已更新 dsh 插件：doctor=${doctor_rev:0:12} deep-whale=${whale_rev:0:12}"
}

# —— 定义自动化包表: attr|类型|上游探测函数名 ——
AUTO_PKGS="flex-movie|simple|flex_movie
qwen|simple|qwen
codebuddy|codebuddy|codebuddy
dsh|dsh|dsh"

# --verify 模式：bump 后跑 nix build 验证，失败则回退该包改动
verify_pkg() {
    local attr="$1"; shift
    local files="$*"
    echo "  [verify] nix build .#$attr ..."
    if nix build ".#packages.x86_64-linux.$attr" --no-link 2>&1 | tail -3; then
        echo "  [verify] $attr 构建通过"
        return 0
    else
        echo "  [verify] $attr 构建失败，回退改动: $files"
        for f in $files; do git -C "$REPO" checkout -- "$f" 2>/dev/null || true; done
        return 1
    fi
}

# bump 后可选验证：VERIFY=1 时跑 nix build，失败回退；VERIFY=0 直接计数
maybe_verify() { # $1=attr  $2..=files to revert on failure
    local attr="$1"; shift
    if [ "$VERIFY" = 0 ]; then OK=$((OK+1)); return 0; fi
    verify_pkg "$attr" "$@" && OK=$((OK+1)) || FAIL=$((FAIL+1))
}

check_one() { # $1=attr $2=upstreamLatest
    local c u; c=$(cur "$1"); u="$2"
    if [ "$c" = "$u" ]; then printf "  %-12s %-16s (=)   已是最新\n" "$1" "$c"
    else printf "  %-12s %-16s (→)   可更新到 %s\n" "$1" "$c" "$u"; fi
}

echo "== 上游版本检查 $(date '+%F %H:%M') =="

case "$MODE" in
check)
    for line in $AUTO_PKGS; do
        IFS='|' read -r attr _ name <<<"$line"
        latest=$(up_"$name")
        [ "$name" = codebuddy ] && latest="${latest%.*-*}"  # attr 只存短版本，比对前去掉 .build-hash
        check_one "$attr" "$latest"
    done
    # dsh-plugins：比较固定提交与两个仓库的 main HEAD。
    doctor_pinned=$(sed -n '/doctor = tgz "dsh-context-doctor"/,+2s|.*/archive/\([0-9a-f]\{40\}\)\.tar\.gz.*|\1|p' packages/custom/source/deepseek-harness/plugins.nix)
    whale_pinned=$(sed -n '/deepWhale = tgz "dsh-deep-whale"/,+2s|.*/archive/\([0-9a-f]\{40\}\)\.tar\.gz.*|\1|p' packages/custom/source/deepseek-harness/plugins.nix)
    doctor_upstream=$(up_git_head Zhenyu98/dsh-context-doctor)
    whale_upstream=$(up_git_head Small-tailqwq/dsh-deep-whale)
    if [ "$doctor_pinned" = "$doctor_upstream" ] && [ "$whale_pinned" = "$whale_upstream" ]; then
        echo "  dsh-plugins   dshmarket=$(up_dshmarket) / GitHub 插件 (=)   已是最新提交"
    else
        echo "  dsh-plugins   (→)   GitHub 插件有新提交，可 --bump dsh-plugins"
    fi
    echo "  qoder         $(cur qoder-cn)  (i)   URL 无版本号，需 --bump qoder <版本> 手动升级"
    echo "  trae-code     $(cur trae-code)  (i)   无清单源，需 --bump trae-code <版本> 手动升级"
    echo "  webapps/winapps/vendored   (i)   静态包，无上游版本"
    ;;
bump)
    OK=0; FAIL=0
    if [ "$ALL" = 1 ]; then
        for line in $AUTO_PKGS; do
            IFS='|' read -r attr kind name <<<"$line"
            local_ver=$(cur "$attr"); latest=$(up_"$name")
            if [ "$local_ver" != "$latest" ]; then
                echo "→ $attr $local_ver → $latest"
                nf="packages/custom/dist/$attr/default.nix"
                case "$kind" in
                    simple)    bump_simple "$attr" "$attr" "$latest" "$(file_url "$nf")"
                               maybe_verify "$attr" "$nf" ;;
                    codebuddy) bump_codebuddy "$latest"
                               maybe_verify "$attr" "$nf" ;;
                    dsh)       bump_dsh "$latest"   # 内部已自验，直接计数
                               OK=$((OK+1)) ;;
                esac
            fi
        done
        if [ -n "$PKG" ]; then
            echo "→ $PKG (滚动/指定)"
            pf="packages/custom/source/deepseek-harness/plugins.nix"
            case "$PKG" in
                dsh-plugins) bump_dsh_plugins; maybe_verify dsh-plugins "$pf" ;;
                *) echo "  未知的 --all 附加包: $PKG" >&2; exit 1 ;;
            esac
        fi
    elif [ -n "$PKG" ]; then
        nf=""
        case "$PKG" in
            flex-movie|qwen)
                v="${EXPLICIT_VER:-$(up_"$PKG")}"
                nf="packages/custom/dist/$PKG/default.nix"
                bump_simple "$PKG" "$PKG" "$v" "$(file_url "$nf")"
                maybe_verify "$PKG" "$nf" ;;
            trae-code)
                [ -n "$EXPLICIT_VER" ] || { echo "trae-code 无清单源: ./update.sh --bump trae-code <版本>"; exit 1; }
                nf="packages/custom/dist/trae-code/default.nix"
                bump_simple trae-code trae-code "$EXPLICIT_VER" "$(file_url "$nf")"
                maybe_verify trae-code "$nf" ;;
            qoder)
                [ -n "$EXPLICIT_VER" ] || { echo "qoder URL 无版本号: ./update.sh --bump qoder <版本>"; exit 1; }
                nf="packages/custom/dist/qoder/default.nix"
                bump_simple qoder qoder "$EXPLICIT_VER" "$(file_url "$nf")"
                maybe_verify qoder "$nf" ;;
            codebuddy)
                v="${EXPLICIT_VER:-$(up_codebuddy)}"
                nf="packages/custom/dist/codebuddy/default.nix"
                bump_codebuddy "$v"
                maybe_verify codebuddy "$nf" ;;
            dsh)
                v="${EXPLICIT_VER:-$(up_dsh)}"
                bump_dsh "$v"   # 内部已自验
                OK=$((OK+1)) ;;
            dsh-plugins)
                bump_dsh_plugins
                nf="packages/custom/source/deepseek-harness/plugins.nix"
                maybe_verify dsh-plugins "$nf" ;;
            *) echo "未知包: $PKG（支持: $AUTO_PKGS 的首列 + qoder/trae-code/dsh-plugins）" >&2; exit 1 ;;
        esac
    else
        echo "用法: $0 --bump <包名> [版本]  或  $0 --bump --all" >&2
        exit 1
    fi
    if [ "$OK" -gt 0 ]; then
        git -C "$REPO" add packages/custom
        echo "已 git add（成功 $OK 个$( [ "$FAIL" -gt 0 ] && echo "，失败 $FAIL 个已回退")）"
    else
        echo "无成功升级$( [ "$FAIL" -gt 0 ] && echo "（$FAIL 个失败已回退")）"
    fi
    ;;
esac
