/**
 * File: esp.nix
 * Author: ziyun
 * Date: 2026-08-23
 * Description: ESP32 unified devShell（ESP-IDF + 烧录/调试/串口工具 + clangd）。
 *
 * ⚠️ 与其他 MCU shell 不同：esp 依赖 nixpkgs 25.11（nixos-esp 分支）和
 * mirrexagon/nixpkgs-esp-dev overlay（esp-idf-full 需要 python310，26.05 已
 * 移除），所以 `nix develop esp.nix` 直接加载会失败——pkgs 必须由 flake
 * 传入 espPkgs（见 flake.nix）。Nix Env Selector 里请用 flake 方式：
 *   nix develop /path/to/flake#esp
 */
{ pkgs, mkEmbeddedMcuShell }:

let
  embeddedPackages = import ../libs/embedded-packages.nix { inherit pkgs; };
in
mkEmbeddedMcuShell {
  inherit pkgs;
  name = "esp";
  packages = [ pkgs.esp-idf-full ] ++ embeddedPackages.esp;
  tools = [
    "idf.py (ESP-IDF framework)"
    "esptool / espflash / platformio (flashing)"
    "openocd / probe-rs / dfu-util (debug)"
    "cmake / ninja / pkg-config (build)"
    "clangd (LSP, VSCode C/C++ 补全)"
    "minicom / picocom / screen (serial)"
  ];
  versionCommands = [
    { name = "idf.py"; bin = "idf.py"; command = "idf.py --version"; }
    { name = "esptool.py"; bin = "esptool.py"; command = "esptool.py version"; }
    { name = "espflash"; bin = "espflash"; command = "espflash --version"; }
    { name = "pio"; bin = "pio"; command = "pio --version"; }
    { name = "cmake"; bin = "cmake"; command = "cmake --version"; }
    { name = "clangd"; bin = "clangd"; command = "clangd --version"; }
    { name = "openocd"; bin = "openocd"; command = "openocd --version"; }
  ];
  message = "ESP32 unified shell: ESP-IDF + flashing/serial/debug tools. Usage: idf.py create-project <name>; idf.py set-target esp32c3; idf.py build; idf.py flash monitor; or esptool.py --port /dev/ttyUSB0 write_flash 0x0 build/xxx.bin";
  # ESP-IDF VSCode 扩展自动配置：在 ESP-IDF 项目目录（有 CMakeLists.txt 或
  # .vscode）进 shell 时，把 esp-idf.espIdfPath / pythonBin / openocdPath 等
  # 合并进项目 .vscode/settings.json（保留其他设置）。路径取自当前 store，
  # nixpkgs-esp 升级后进一次 shell 即自动更新。修复扩展报错：
  # "没有可提供视图数据的已注册数据提供程序"（根因：~/.espressif/tools/
  # eim_idf.json 不存在导致扩展激活中断）。
  extraShellHook = ''
    # 仅 ESP-IDF 项目（CMakeLists.txt 引用 tools/cmake/project.cmake）才自动配置，
    # 避免污染非 esp 目录（如本仓库）的 .vscode/settings.json。
    if [ -f CMakeLists.txt ] && grep -q "tools/cmake/project.cmake" CMakeLists.txt 2>/dev/null; then
      python3 - "$IDF_PATH" <<'PY'
import json, pathlib, shutil, sys

if not (pathlib.Path("CMakeLists.txt").exists() or pathlib.Path(".vscode").exists()):
    sys.exit(0)

idf = sys.argv[1]
d = pathlib.Path(".vscode")
d.mkdir(exist_ok=True)
f = d / "settings.json"
data = json.loads(f.read_text()) if f.exists() else {}
data["esp-idf.espIdfPath"] = idf
data["esp-idf.toolsPath"] = idf + "/tools"
data["esp-idf.pythonBin"] = sys.executable
ocd = shutil.which("openocd")
if ocd:
    data["esp-idf.openocdPath"] = ocd
f.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n")
print("ESP-IDF VSCode 扩展路径已更新 → " + idf)
PY
    fi
  '';
}
