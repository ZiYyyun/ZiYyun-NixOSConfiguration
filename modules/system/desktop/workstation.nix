/**
 * File: workstation.nix
 * Description: Shared desktop stack for every graphical host.
 *
 * Keep KDE Plasma, Niri, and Noctalia together so every machine exposes the
 * same sessions and consumes the same repository-managed user configuration.
 */
{ ... }:
{
  imports = [
    ./kde.nix
    ./niri.nix
    ./noctalia.nix
  ];
}
