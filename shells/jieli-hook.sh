#!/usr/bin/env bash
# jieli-hook.sh: 杰理 SDK 导航/便捷跳转（由 jieli.nix 的 extraShellHook source 进交互 shell）。
#   - 进入 shell 自动落到已安装的 SDK（唯一一个则直接进入，多个则列出可选）
#   - 提供 `jcd` 命令（别名 jl / jieli-cd）随时切换/列出 SDK 子目录
#
# 与 jieli-setup.sh 的区别：setup 用子进程跑（cd 不回传、避免 history 折叠），
# 负责工具链/SDK 的下载克隆；本 hook 必须在交互 shell 里 source（函数 + cd 才生效）。
# 用法：
#   nix develop .#jieli
#   jcd              # 唯一 SDK 直接进入；多个则列菜单选择
#   jcd fw-AC79_AIoT_SDK   # 按名字直接进入
#   jcd -l           # 只列出现有 SDK，不切换

SRC_DIR="${SDK_DIR:-$HOME/dev/jieli}"

# jcd：列出/切换已安装的杰理 SDK 子目录。
jcd () {
    local choice="${1:-}"
    if ! [ -d "$SRC_DIR" ]; then
        echo "[jieli] 没有 SDK 目录: $SRC_DIR （先运行 jieli-setup 选择系列克隆）"
        return 1
    fi

    # 收集带 .git 的子目录
    local dir sdk
    local -a sdks=()
    for dir in "$SRC_DIR"/*/; do
        [ -d "$dir/.git" ] && sdks+=("$(basename "$dir")")
    done

    if [ "${#sdks[@]}" -eq 0 ]; then
        echo "[jieli] $SRC_DIR 下没有已克隆的 SDK，先运行 jieli-setup。"
        cd "$SRC_DIR" || return 1
        return 0
    fi

    # 只列出
    if [ "$choice" = "-l" ]; then
        for sdk in "${sdks[@]}"; do printf "  %s\n" "$sdk"; done
        echo "当前位置: $PWD"
        return 0
    fi

    # 按名字精确进入
    if [ -n "$choice" ]; then
        for sdk in "${sdks[@]}"; do
            if [ "$sdk" = "$choice" ]; then
                cd "$SRC_DIR/$sdk" || return 1
                echo "[jieli] -> $PWD"
                return 0
            fi
        done
        echo "[jieli] 没有这个 SDK: $choice （可用: ${sdks[*]}）"
        return 1
    fi

    # 无参：唯一则直接进，多则列菜单
    if [ "${#sdks[@]}" -eq 1 ]; then
        cd "$SRC_DIR/${sdks[0]}" || return 1
        echo "[jieli] -> $PWD"
        return 0
    fi

    local i=1 n idx
    echo "[jieli] 已安装 SDK（$SRC_DIR）："
    for sdk in "${sdks[@]}"; do printf "  %d) %s\n" "$i" "$sdk"; i=$((i + 1)); done
    read -r -p "[jieli] 选择序号进入（Enter 留在当前）: " n
    if [ -n "$n" ]; then
        idx=$((n - 1))
        if [ "$idx" -ge 0 ] && [ "$idx" -lt "${#sdks[@]}" ]; then
            cd "$SRC_DIR/${sdks[$idx]}" || return 1
            echo "[jieli] -> $PWD"
        fi
    fi
}
alias jl=jcd
alias jieli-cd=jcd

# 进入 shell 自动落到 SDK（唯一则直接进，多个时列菜单供选择）
jcd