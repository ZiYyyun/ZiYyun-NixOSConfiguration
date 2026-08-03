/**
 * File: noctalia.nix
 * Author: ziyun
 * Date: 2026-07-29
 * Description: Disabled Noctalia shell configuration template.
 */
{ ... }:
{
  # This file is intentionally inactive. Keep the flake input and imports in
  # flake.nix commented until Noctalia is ready to test on the target desktop.

  # Noctalia upstream v5 NixOS usage notes:
  # 1. Add the flake input:
  #
     noctalia.url = "github:noctalia-dev/noctalia";
     noctalia.inputs.nixpkgs.follows = "nixpkgs";
  #
  # 2. Import the upstream NixOS module before this file:
  #
     inputs.noctalia.nixosModules.default
     ./modules/system/packages/desktop/noctalia
  
  # 3. Enable the required system services and Home Manager program:
  #
     services.upower.enable = true;
     services.power-profiles-daemon.enable = true;
     services.blueman.enable = true;
     networking.networkmanager.enable = true;
  #
     home-manager.users.ziyun = { ... }: {
       programs.noctalia = {
         enable = true;
         settings = {
           # Add Noctalia shell settings here after confirming the final UI.
         };
       };
     };
  
  # 4. Optional Cachix cache:
  #
  #    If upstream still recommends Cachix when this module is enabled, copy the
  #    current substituter and trusted-public-key values from the official docs.
}
