# KDE Dotfiles

This directory stores the small amount of KDE configuration that Home Manager
manages. It is deliberately minimal.

Original source (old Arch backup):
https://gitee.com/zhangchibang/ziyun_-arch_-kde_-config.git

## What Is Kept

- `config/plasma-org.kde.plasma.desktop-appletsrc` — the two-panel layout:
  - bottom panel: kickoff (start menu) + task manager + clock + system tray
  - top panel: window list + network / volume / battery / bluetooth
  Everything else (desktop, wallpaper, widgets) is left at Plasma defaults.
- `config/plasma-localerc` — Chinese locale for Plasma.
- `wallpapers/ZiYyun_KDE_DesktopShort.png` — optional wallpaper, available in
  `~/.local/share/wallpapers/`; the layout does not force it.

## What Was Removed And Why

The previous version imported most of the Arch backup (kdeglobals, kwinrc,
plasmarc, plasmashellrc, kdedefaults, user-feedback config, plasma-nm, ...).
That caused repeated load failures in Plasma 6.6:

- `org.kde.plasma.manage-inputmethod` tray item: plasmoid not shipped by the
  nixpkgs fcitx5 package.
- `org.kde.plasma.icontasks` task bar: its QML lives under
  `org.kde.plasma.taskmanager` (X-Plasma-RootPath), and the nixpkgs
  plasma-desktop build ships no applet QML at all (fixed separately by
  `packages/custom/plasma-desktop-qml`).
- system-monitor widgets: they work, but were dropped to keep the layout
  minimal.

If you want more Plasma customizations, configure them in the running session
and export with `shells/export-dotfiles.sh`, or hand-edit the appletsrc
above. Note that Home Manager links are read-only; Plasma cannot persist
widget moves back into the store path.

Home Manager links these files through:

```nix
modules/home/config-files/kde.nix
```
