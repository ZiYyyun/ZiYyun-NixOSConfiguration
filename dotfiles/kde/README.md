# KDE Dotfiles

Source: https://gitee.com/zhangchibang/ziyun_-arch_-kde_-config.git

This directory stores the repository-managed KDE configuration used by Home Manager.

Imported from the old Arch KDE config:

- Plasma shell config
- Plasma locale/network/welcome/discover config
- KDE defaults
- KDE user feedback config
- A repository-local wallpaper image

Intentionally not imported:

- `plasma-org.kde.plasma.desktop-appletsrc`, because the old layout contains Plasma 5-era applet IDs that Plasma 6.6 reports as missing packages. It remains in `config/` only as a reference.
- `kdeconnect/`, because it contains private keys, certificates, and trusted-device state
- `.git/` and old repository metadata
- absolute wallpaper references under `/home/ziyun/Downloads/`

The old wallpaper references are rewritten to:

```text
/home/ziyun/.local/share/wallpapers/ZiYyun_KDE_DesktopShort.png
```

Home Manager links these files through:

```nix
modules/home/config-files/kde.nix
```
