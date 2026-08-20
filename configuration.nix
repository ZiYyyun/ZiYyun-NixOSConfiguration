# Edit this configuration file to define what should be installed on
# your system. Help is available in configuration.nix(5) and in the
# NixOS manual, accessible by running nixos-help.

{ pkgs, ... }:

{
  # Prefer the official cache, with domestic university mirrors as fallbacks
  # when cache.nixos.org is slow from the current network.
  nix.settings.substituters = [
    "https://mirror.sjtu.edu.cn/nix-channels/store"
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
    "https://mirrors.ustc.edu.cn/nix-channels/store"
    "https://cache.nixos.org/"
  ];
  nix.settings.connect-timeout = 30;
  nix.settings.download-attempts = 10;
  nix.settings.http-connections = 4;
  nix.settings.stalled-download-timeout = 60;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.package = pkgs.lix;

  networking.hostName = "nixos";
  # networking.wireless.enable = true;

  # Configure network proxy if necessary.
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Shanghai";

  i18n.defaultLocale = "zh_CN.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "zh_CN.UTF-8";
  };

  # CJK fonts: required for Chinese text in Wine apps (FeiQ, 红蜘蛛) and
  # generally for correct Chinese rendering.
  fonts.packages = with pkgs; [
    wqy_zenhei
    noto-fonts-cjk-sans
  ];

  services.xserver.xkb = {
    layout = "cn";
    variant = "";
  };

  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # jack.enable = true;
  };

  # services.xserver.libinput.enable = true;

  users.users."ziyun" = {
    isNormalUser = true;
    description = "ziyun";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  programs.firefox.enable = true;

  nixpkgs.config = {
    allowUnfree = true;
    # Required by winboat after the 2026-08 flake update.
    permittedInsecurePackages = [
      "electron-40.10.5"
    ];
  };

  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  services.openssh.enable = true;

  # FeiQ (飞秋) LAN discovery uses UDP 2425 (IPMSG-compatible protocol) with
  # subnet broadcasts; allow inbound so classmates' replies reach us. TCP 2425
  # is used for file transfer.
  networking.firewall.allowedUDPPorts = [ 2425 ];
  networking.firewall.allowedTCPPorts = [ 2425 ];

  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # networking.firewall.enable = false;

  system.stateVersion = "26.05";
}
