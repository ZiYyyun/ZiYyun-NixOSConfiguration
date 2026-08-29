#!/usr/bin/env bash
# jieli-setup.sh: 杰理（Jieli）开发环境自动初始化（独立脚本，由 shellHook 以子进程调用）
#   - 工具链：缺失时自动下载官方 Linux 工具链并解压到 ~/.local/share/jieli
#   - SDK：缺失时交互选择系列并 git clone 到 ~/dev/jieli
#   - 工具链安装成功后写入 $JL_HOME/env.sh（含 PATH），供 shellHook source
# 说明：工具链闭源、来自官方 pkgman；SDK 来自杰理官方 gitee 仓库。
# 注意：以子进程运行（不要 source 进交互 shell），否则脚本内容会被折叠进 history。

# ================= 1. 工具链 =================
JL_HOME="${JL_HOME:-$HOME/.local/share/jieli}"
SDK_DIR="${SDK_DIR:-$HOME/dev/jieli}"
JL_TOOLCHAIN_URL="${JL_TOOLCHAIN_URL:-http://pkgman.jieliapp.com/s/linux-toolchain}"

mkdir -p "$SDK_DIR"

if [ -x "$JL_HOME/common/bin/clang" ]; then
    export PATH="$JL_HOME/common/bin:$PATH"
    echo "杰理工具链: $JL_HOME/common/bin （已加入 PATH）"
else
    echo "============================================="
    echo " 杰理工具链未安装：$JL_HOME/common/bin/clang 不存在"
    echo " 自动下载源: $JL_TOOLCHAIN_URL"
    echo " 安装目录: $JL_HOME （用户目录，rebuild 不影响）"
    echo "============================================="
    read -r -p " 立即下载并安装？(y/N): " ans
    if [ "$ans" = "y" ] || [ "$ans" = "Y" ]; then
        mkdir -p "$JL_HOME" "$HOME/.cache/jieli-dl"
        dl="$HOME/.cache/jieli-dl/toolchain.bin"
        echo "下载中（文件可能较大，请耐心等待）..."
        if curl -fL --retry 3 -o "$dl" "$JL_TOOLCHAIN_URL"; then
            case "$(file -b "$dl")" in
                *gzip* | *xz* | *XZ*)
                    tar xf "$dl" -C "$JL_HOME"
                    ;;
                *Zip*)
                    unzip -q "$dl" -d "$JL_HOME"
                    ;;
                *)
                    echo "无法识别压缩格式，请手动解压到 $JL_HOME"
                    ;;
            esac
            if [ -x "$JL_HOME/common/bin/clang" ]; then
                export PATH="$JL_HOME/common/bin:$PATH"
                echo "工具链安装成功: $JL_HOME/common/bin"
            else
                echo "解压完成，但未找到 $JL_HOME/common/bin/clang。"
                echo "请检查解压后的目录层次，确保 common/bin/clang 存在。"
            fi
        else
            echo "下载失败。请手动安装："
            echo "  下载 $JL_TOOLCHAIN_URL 后解压到 $JL_HOME（确保 common/bin/clang 存在）"
        fi
    else
        echo "跳过工具链安装。手动安装：下载 $JL_TOOLCHAIN_URL 解压到 $JL_HOME"
    fi
fi

# 工具链就绪时写出 env.sh（供 shellHook source 设置 PATH / ulimit）
if [ -x "$JL_HOME/common/bin/clang" ]; then
    printf 'export PATH="%s/common/bin:$PATH"\nulimit -n 8096\n' "$JL_HOME" > "$JL_HOME/env.sh"
fi

# ================= 2. SDK =================
# 先列出已安装的 SDK，再显示选择菜单；选完芯片后才检测对应目录是否已存在
# （这样已有 AC63 时也能再添加 AC79 等其它系列）。
installed_sdks=()
for d in "$SDK_DIR"/*/; do
    [ -d "$d/.git" ] && installed_sdks+=("$(basename "$d")")
done

echo "============================================="
echo " 选择要安装/确保的杰理 SDK（目录: $SDK_DIR）"
if [ "${#installed_sdks[@]}" -gt 0 ]; then
    echo " 已安装: ${installed_sdks[*]}"
fi
echo "  1) AC63/AC69  蓝牙音频     https://gitee.com/Jieli-Tech/fw-AC63_BT_SDK"
echo "  2) AC79  AIoT (WiFi+BT)    https://gitee.com/Jieli-Tech/fw-AC79_AIoT_SDK"
echo "  3) AC792 双模 (WiFi+BT)    https://gitee.com/Jieli-Tech/fw-AC792_SDK"
echo "  4) AC82N 通用 MCU          https://gitee.com/Jieli-Tech/AC82N"
echo "  5) 自定义 URL"
echo "  0) 跳过"
echo "============================================="
read -r -p " 请输入数字: " choice
repo=""
name=""
case "$choice" in
    1) repo="https://gitee.com/Jieli-Tech/fw-AC63_BT_SDK";  name="fw-AC63_BT_SDK" ;;
    2) repo="https://gitee.com/Jieli-Tech/fw-AC79_AIoT_SDK"; name="fw-AC79_AIoT_SDK" ;;
    3) repo="https://gitee.com/Jieli-Tech/fw-AC792_SDK";   name="fw-AC792_SDK" ;;
    4) repo="https://gitee.com/Jieli-Tech/AC82N";          name="AC82N" ;;
    5) read -r -p "  输入 git URL: " repo; name="$(basename "$repo" .git)" ;;
    *) repo="" ;;
esac

if [ -z "$repo" ]; then
    echo "跳过 SDK 克隆。"
else
    target="$SDK_DIR/$name"
    if [ -d "$target/.git" ]; then
        echo "该系列已存在（跳过）: $target"
    else
        # 清理之前 clone 失败残留的空/不完整目录，避免“目标已存在”
        if [ -e "$target" ]; then
            echo "清理不完整的残留目录: $target"
            rm -rf "$target"
        fi
        echo "克隆 $repo -> $target ..."
        if (cd "$SDK_DIR" && git clone "$repo" "$name"); then
            echo "克隆成功: $target"
        else
            echo "克隆失败。请手动执行（注意带目标目录）:"
            echo "  git clone $repo $target"
        fi
    fi
fi

# ================= 3. 公共 =================
ulimit -n 8096  # 杰理链接阶段要求文件描述符上限 > 8096
