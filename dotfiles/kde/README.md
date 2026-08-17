# KDE Dotfiles

Source: https://gitee.com/zhangchibang/ziyun_-arch_-kde_-config.git

This directory stores the repository-managed KDE configuration used by Home Manager.

Imported from the old Arch KDE config:

- Plasma shell config
- Plasma locale/network/welcome/discover config
- KDE defaults
- KDE user feedback config
- Panel + desktop widget layout
  (`plasma-org.kde.plasma.desktop-appletsrc`): bottom panel with kickoff /
  icon tasks, top panel with window list + CPU/memory monitors, desktop
  disk-activity widget, system tray items
- A repository-local wallpaper image

Intentionally not imported:

- `kdeconnect/`, because it contains private keys, certificates, and
  trusted-device state. Re-pair devices on each machine instead.
- `.git/` and old repository metadata
- The `mkos-BigSur` Plasma theme: only the config reference was backed up,
  the theme package itself was not, so `plasmarc` keeps the default theme.
- absolute wallpaper references under `/home/ziyun/Downloads/` (klm.jpg /
  ygg.jpg were never in the backup, only the paths were)

Old wallpaper references are rewritten to:

```text
/home/ziyun/.local/share/wallpapers/ZiYyun_KDE_DesktopShort.png
```

Note: `plasma-org.kde.plasma.desktop-appletsrc` is written back by Plasma
when you move widgets, so expect it to diverge from this file after you
customize the desktop. Re-export it with `shells/export-kde-dotfiles.sh`
if you want to keep changes.

Home Manager links these files through:

```nix
modules/home/config-files/kde.nix
```
