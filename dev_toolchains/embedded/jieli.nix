/**
 * File: jieli.nix
 * Author: ziyun
 * Date: 2026-08-28
 * Description: 杰理（Jieli）芯片开发环境（AC69 / AC79 系列蓝牙音频 SoC）。
 *
 * 复用公共 helper：mkEmbeddedMcuShell（libs/embedded-mcu-shell.nix）+
 * 包组 embedded-packages.nix 的 `jieli` 组，与 stm/esp/luatos 同构。
 *
 * 关键说明 —— 杰理编译工具链是闭源的、不在 nixpkgs：
 *   1. 下载官方 Linux 工具链：
 *      http://pkgman.jieliapp.com/s/linux-toolchain
 *      （官方文档：https://doc.zh-jieli.com/Tools/zh-cn/dev_tools/dev_env/jl_toolchain.html）
 *   2. 解压到 /opt/jieli，确保 /opt/jieli/common/bin/clang 存在：
 *        sudo mkdir -p /opt/jieli
 *        sudo tar xJf linux-toolchain-*.tar.xz -C /opt/jieli
 *   3. 本 shell 会自动检测 /opt/jieli 并把 common/bin 加入 PATH；
 *      未安装时给出提示。
 *
 * 使用：
 *   nix develop .#jieli
 *   # 克隆 SDK（如 gitee.com/fw-AC79_AIoT_SDK）后进入 SDK 根目录
 *   make            # 编译（SDK 顶层 Makefile）
 *   make -j $(nproc)
 *   # Linux 端官方只支持编译；烧录/下载需 Windows 杰理工具
 *   # （可用 Wine 跑杰理下载工具，参考 packages/custom/winapps）。
 */
{ pkgs, ... }:
let
  embeddedPackages = import ../libs/embedded-packages.nix { inherit pkgs; };
  mkEmbeddedMcuShell = import ../libs/embedded-mcu-shell.nix;
in
mkEmbeddedMcuShell {
  inherit pkgs;
  name = "jieli";
  packages = embeddedPackages.jieli;
  env = {
    CHIP_VENDOR = "Zhuhai Jieli Technology (杰理)";
    TARGET_ARCH = "AC69(私有DSP) / AC79(Cortex-M33)";
    JL_TOOLCHAIN = "/opt/jieli";
  };
  tools = [
    "make (SDK 顶层 Makefile 编译)"
    "python3 (SDK 固件生成脚本)"
    "host gcc + clangd"
    "串口: picocom/minicom/screen"
  ];
  libraries = [ ];
  versionCommands = [
    { name = "make"; bin = "make"; command = "make --version"; }
    { name = "python3"; bin = "python3"; command = "python3 --version"; }
    { name = "jieli-clang"; bin = "clang"; command = "/opt/jieli/common/bin/clang --version"; }
  ];
  message = "杰理 SDK 编译：进入 SDK 根目录执行 make。Linux 只支持编译，烧录用 Windows 工具（可试 Wine）。";
  extraShellHook = ''
    # 链接阶段会打开大量文件，官方要求 fd 上限 > 8096
    ulimit -n 8096

    if [ -d /opt/jieli/common/bin ]; then
      export PATH=/opt/jieli/common/bin:$PATH
      echo "杰理工具链: /opt/jieli/common/bin 已加入 PATH"
    else
      echo "警告: 未找到 /opt/jieli/common/bin（杰理 Linux 工具链未安装）"
      echo "  下载: http://pkgman.jieliapp.com/s/linux-toolchain"
      echo "  安装: sudo mkdir -p /opt/jieli && sudo tar xJf <下载的包> -C /opt/jieli"
      echo "  确保解压后存在 /opt/jieli/common/bin/clang"
    fi
  '';
}
