# KDE Dotfiles

This directory is the repository-managed source for KDE user configuration.
Home Manager links files from here through:

```nix
modules/home/dotfile-links/kde.nix
```

Suggested files to export from a working KDE session:

- `config/kdeglobals`
- `config/kwinrc`
- `config/kglobalshortcutsrc`
- `config/kcminputrc`
- `config/kscreenlockerrc`
- `config/plasma-org.kde.plasma.desktop-appletsrc`
- `config/plasmarc`
- `config/konsolerc`
- `wallpapers/<your-wallpaper-file>`

Copy only the settings you want to reproduce. Avoid committing secrets,
machine-specific display identifiers, recent-file lists, and cache files.

The module links existing files into the user's home directory with Home
Manager. It does not enable KDE itself; the host profile remains responsible
for selecting KDE Plasma and SDDM.
