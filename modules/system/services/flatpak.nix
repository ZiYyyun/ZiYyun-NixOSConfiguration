/**
 * File: flatpak.nix
 * Author: ziyun
 * Date: 2026-07-29
 * Description: System Flatpak service and remote configuration.
 */
{ ... }:

{
  # nix-flatpak provides the services.flatpak options used here.
  services.flatpak = {
    enable = true;

    # Add application IDs here when system-wide Flatpak apps are needed.
    packages = [

      # "org.blender.Blender"
      # "com.spotify.Client"
      # "org.mozilla.firefox"
      "org.torproject.torbrowser-laucher"
    ];

    # This replaces the default remote, so keep the name flathub explicit.
    remotes = [
      {
        name = "flathub";
        location = "https://mirror.sjtu.edu.cn/flathub/flathub.flatpakrepo";
      }
    ];

    # Do not update existing Flatpak apps during every system activation.
    update.onActivation = false;
  };
}
