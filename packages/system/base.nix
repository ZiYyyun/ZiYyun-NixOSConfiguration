/**
 * File: base.nix
 * Author: ziyun
 * Date: 2026-08-07
 * Description: Core system package list that should stay available on every host.
 */
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    curl
    usbutils   # lsusb
    pciutils   # lspci
    unzip      # waydroid-init.sh 解压镜像等
    peazip
  ];
}
