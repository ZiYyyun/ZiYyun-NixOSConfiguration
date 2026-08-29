/**
 * File: jieli.nix
 * Author: ziyun
 * Date: 2026-08-28
 * Description: 杰理（Jieli）芯片开发环境（AC63/AC69/AC79/AC792/AC82N 系列）。
 *
 * 复用公共 helper：mkEmbeddedMcuShell（libs/embedded-mcu-shell.nix）+
 * 包组 embedded-packages.nix 的 `jieli` 组，与 stm/esp/luatos 同构。
 *
 * 进入 shell 时自动初始化（见 shells/jieli-setup.sh）：
 *   - 工具链：杰理闭源 Linux 工具链，缺失时自动下载官方包并解压到
 *     ~/.local/share/jieli（用户目录，rebuild 不影响），无需 sudo
 *   - SDK：缺失时交互选择系列（AC63/AC69、AC79、AC792、AC82N 或自定义），
 *     git clone 到 ~/dev/jieli
 *   - 自动设置 ulimit -n 8096（链接阶段文件描述符上限）
 *
 * 使用：
 *   nix develop .#jieli
 *   # 进入 SDK 根目录后
 *   make            # 编译（SDK 顶层 Makefile）
 *   make -j $(nproc)
 *   # Linux 端官方只支持编译；烧录/下载需 Windows 杰理工具（可试 Wine）。
 */
{ pkgs, ... }:
let
  embeddedPackages = import ../libs/embedded-packages.nix { inherit pkgs; };
  mkEmbeddedMcuShell = import ../libs/embedded-mcu-shell.nix;
in
mkEmbeddedMcuShell {
  inherit pkgs;
  name = "jieli";
  # jieli-setup：随时运行可添加/确保 SDK（先选芯片系列，再检测对应目录）
  packages = embeddedPackages.jieli ++ [
    (pkgs.writeShellScriptBin "jieli-setup" ''
      export JL_HOME="$HOME/.local/share/jieli"
      export SDK_DIR="$HOME/dev/jieli"
      bash ${../../shells/jieli-setup.sh}
    '')
  ];
  env = {
    CHIP_VENDOR = "Zhuhai Jieli Technology (杰理)";
    TARGET_ARCH = "AC63/AC69(私有DSP) / AC79/AC792(Cortex-M33) / AC82N";
    # 自动初始化脚本的默认位置（可在 shell 里覆盖）
    JL_HOME = "/home/ziyun/.local/share/jieli";
    SDK_DIR = "/home/ziyun/dev/jieli";
  };
  tools = [
    "make (SDK 顶层 Makefile 编译)"
    "python3 (SDK 固件生成脚本)"
    "host gcc + clangd"
    "串口: picocom/minicom/screen"
    "自动: 工具链下载解压 + SDK 交互克隆"
  ];
  libraries = [ ];
  versionCommands = [
    { name = "make"; bin = "make"; command = "make --version"; }
    { name = "python3"; bin = "python3"; command = "python3 --version"; }
    { name = "jieli-clang"; bin = "clang"; command = "clang --version"; }
  ];
  message = "杰理 SDK 编译：进入 SDK 根目录执行 make。Linux 只支持编译，烧录用 Windows 工具（可试 Wine）。";
  # 初始化以「子进程」运行 jieli-setup.sh（不能 source 进交互 shell，
  # 否则脚本代码会被折叠进 history，按上箭头会翻到长串代码）。
  extraShellHook = ''
    ulimit -n 8096
    # 仅工具链未就绪时自动初始化；SDK 随时可通过 jieli-setup 命令添加/确保
    # （进入 shell 后直接运行 jieli-setup 即可选择 AC79 等其它系列）。
    if [ ! -x "$HOME/.local/share/jieli/common/bin/clang" ]; then
      echo "=== 杰理工具链未就绪，运行初始化（工具链 + SDK 选择）... ==="
      bash ${../../shells/jieli-setup.sh}
    fi
    # 工具链就绪后应用 PATH / ulimit（env.sh 由 jieli-setup.sh 生成，仅两行）
    if [ -f "$HOME/.local/share/jieli/env.sh" ]; then
      source "$HOME/.local/share/jieli/env.sh"
    fi
  '';
}
