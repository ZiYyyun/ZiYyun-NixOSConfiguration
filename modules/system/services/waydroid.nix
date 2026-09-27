/**
 * File: waydroid.nix
 * Author: ziyun
 * Date: 2026-08-17
 * Description: WayDroid (Android in a Wayland container) enablement — 全声明式。
 *
 * 镜像进 Nix store：从清华 archlinuxcn 镜像下载 waydroid-image-gapps 包
 * （system.img + vendor.img 合一，国内可满速），fetchurl 固定 sha256，
 * derivation 解压出两个 img，systemd tmpfiles 符号链接到预装路径
 * /usr/share/waydroid-extra/images/（waydroid 只认 /etc、/usr/share 下
 * 这两个预装路径；放 /var/lib/waydroid/images 会被当未初始化），再由
 * waydroid-init oneshot 服务跑一次 `waydroid init`（跳过 OTA，秒完成）。
 *
 * 另内置 libndk ARM→x86 翻译层（fetchzip 固定 sha256），由 init 脚本铺进
 * /var/lib/waydroid/overlay/system 并把 abilist/native-bridge 属性合入
 * waydroid.cfg，否则 arm64-only 的 APK 报 INSTALL_FAILED_NO_MATCHING_ABIS。
 * 流程参照 waydroid_script（casualsnek/waydroid_script）的 stuff/ndk.py。
 *
 * 包版本 20.0_20260403 对应官方 lineage-20.0-20260403-GAPPS
 * （https://sourceforge.net/projects/waydroid/files/images/）。
 * 升级：去 https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/x86_64/ 找
 * 最新 waydroid-image-gapps-*.pkg.tar.zst，替换 url + sha256。
 *
 * Kernel prerequisites (ANDROID_BINDER_IPC, ANDROID_BINDERFS, MEMFD_CREATE,
 * PSI) are already enabled in the default nixpkgs kernel, so no custom kernel
 * is required.
 */
{ config, lib, pkgs, ... }:
let
  cfg = config.services.waydroid;

  # 清华 archlinuxcn 的 waydroid-image-gapps 包（内含 system.img + vendor.img）。
  imagePkg = pkgs.fetchurl {
    url = "https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/x86_64/waydroid-image-gapps-20.0_20260403-1-x86_64.pkg.tar.zst";
    sha256 = "sha256-0DE8Vcsp7spDIMobP1nhKThp8gI9cYocMqll9xi0wck=";
  };

  # 解压出 system.img / vendor.img 的 derivation。
  images = pkgs.stdenv.mkDerivation {
    pname = "waydroid-images-gapps";
    version = "20.0-20260403";
    src = imagePkg;
    nativeBuildInputs = [ pkgs.zstd pkgs.gnutar ];
    installPhase = ''
      mkdir -p $out
      tar --zstd -xOf $src usr/share/waydroid-extra/images/system.img > $out/system.img
      tar --zstd -xOf $src usr/share/waydroid-extra/images/vendor.img > $out/vendor.img
      chmod 0644 $out/system.img $out/vendor.img
    '';
  };

  # libndk ARM→x86 翻译层（Android 13 对应版本）。来源与安装流程参照
  # waydroid_script（github.com/casualsnek/waydroid_script）的 stuff/ndk.py：
  # 文件进 /var/lib/waydroid/overlay/system/，属性进 waydroid.cfg [properties]，
  # 然后重跑 init 让 make_base_props 把属性合入 waydroid_base.prop。
  # 没有它，arm64-only 的 APK 会报 INSTALL_FAILED_NO_MATCHING_ABIS。
  libndk = pkgs.fetchzip {
    url = "https://github.com/supremegamers/vendor_google_proprietary_ndk_translation-prebuilt/archive/68734c52556d3d7a6db34c603dd9276915c29f2f.zip";
    sha256 = "sha256-hYpCOuyL/XkjONU7KfE6CU+14jbSzp9JBc8NmET6jXw=";
    stripRoot = true; # 解压后根目录即含 prebuilts/{bin,etc,lib,lib64}
  };

  # 写入 waydroid.cfg [properties] 段的属性（configparser 格式）。
  libndkProps = pkgs.writeText "waydroid-libndk-props.ini" ''
    ro.product.cpu.abilist = x86_64,x86,arm64-v8a,armeabi-v7a,armeabi
    ro.product.cpu.abilist32 = x86,armeabi-v7a,armeabi
    ro.product.cpu.abilist64 = x86_64,arm64-v8a
    ro.dalvik.vm.native.bridge = libndk_translation.so
    ro.enable.native.bridge.exec = 1
    ro.vendor.enable.native.bridge.exec = 1
    ro.vendor.enable.native.bridge.exec64 = 1
    ro.ndk_translation.version = 0.2.3
    ro.dalvik.vm.isa.arm = x86
    ro.dalvik.vm.isa.arm64 = x86_64
  '';

  # waydroid-init 的完整初始化脚本（幂等）：
  # 1) init（建目录/cfg）→ 2) 铺 libndk 到 overlay → 3) 合并 properties →
  # 4) 再 init 一次重新生成 waydroid_base.prop（属性只在 init 时合并，
  #    见 waydroid tools/helpers/lxc.py make_base_props）。
  initScript = pkgs.writeShellScript "waydroid-init-declarative" ''
    set -e
    waydroid_bin="${config.virtualisation.waydroid.package}/bin/waydroid"
    overlay=/var/lib/waydroid/overlay/system
    cfg_file=/var/lib/waydroid/waydroid.cfg

    "$waydroid_bin" init -s GAPPS

    # 铺翻译层文件（--no-preserve=mode 去掉 store 的只读位，之后统一 chmod）。
    mkdir -p "$overlay"
    cp -r --no-preserve=mode ${libndk}/prebuilts/* "$overlay"/
    find "$overlay" -type d -exec chmod 755 {} +
    find "$overlay" -type f -exec chmod 644 {} +
    chmod 755 "$overlay"/bin/arm "$overlay"/bin/arm64 \
      "$overlay"/bin/ndk_translation_program_runner_binfmt_misc*

    # 幂等合并属性：先删同名旧行，再插到 [properties] 段之后。
    ${pkgs.gnused}/bin/sed -i -E '/^ro\.(product\.cpu\.abilist|dalvik\.vm\.native\.bridge|enable\.native\.bridge\.exec|vendor\.enable\.native\.bridge\.exec|ndk_translation\.version|dalvik\.vm\.isa\.arm)[^=]*=/d' "$cfg_file"
    ${pkgs.gnused}/bin/sed -i '/^\[properties\]$/r ${libndkProps}' "$cfg_file"

    # 重新生成 waydroid_base.prop（init 幂等，已初始化时直接走配置合并）。
    "$waydroid_bin" init -s GAPPS
  '';
in
{
  options.services.waydroid = {
    enable = lib.mkEnableOption "Waydroid with declaratively provisioned GAPPS images";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.waydroid.enable = true;

    # 必须用 nftables 变体：本机内核未编译 legacy iptables 的 ip_tables 模块
    # （waydroid-net.sh 会优先调 iptables-legacy → modprobe ip_tables 失败，
    # 容器网络起不来）。nixpkgs 官方模块在 networking.nftables.enable 时会
    # 自动切到 waydroid-nftables；这里不改动全局防火墙，只单独覆盖该包。
    # 依据：nixpkgs nixos/modules/virtualisation/waydroid.nix 与
    # pkgs/top-level/all-packages.nix 中 waydroid-nftables 的定义。
    virtualisation.waydroid.package = pkgs.waydroid-nftables;

    # WayDroid 图形管理器（应用管理/属性修改/镜像挂载）+ adb 调试工具。
    environment.systemPackages = with pkgs; [
      waydroid-helper
      android-tools
    ];

    # 把 store 里的镜像链接到 waydroid 的"预装镜像"路径。必须用
    # /usr/share/waydroid-extra/images（或 /etc/waydroid-extra/images）：
    # waydroid init 只认这两个预装路径，放到 /var/lib/waydroid/images 会被
    # 当成未初始化并尝试从 OTA 重新下载。L+ 强制覆盖（幂等）。
    systemd.tmpfiles.rules = [
      "L+ /usr/share/waydroid-extra/images/system.img - - - - ${images}/system.img"
      "L+ /usr/share/waydroid-extra/images/vendor.img - - - - ${images}/vendor.img"
    ];

    # 一次性初始化（创建 rootfs/overlay/data/lxc 与 host-permissions）。
    # 因为镜像在预装路径，init 跳过 OTA 下载，本地秒完成。
    # ExecStart 走 initScript：同时把 libndk ARM 翻译层铺进 overlay 并
    # 把属性合入 waydroid.cfg，重跑 init 重新生成 waydroid_base.prop。
    systemd.services.waydroid-init = {
      description = "Waydroid initializer (declarative images + libndk)";
      wantedBy = [ "multi-user.target" ];
      after = [ "systemd-tmpfiles-setup.service" ];
      requires = [ "systemd-tmpfiles-setup.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${initScript}";
        # 已初始化时退出码为 0，重复运行无害（幂等）。
      };
    };
  };
}
