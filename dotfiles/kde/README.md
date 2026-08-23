# KDE Dotfiles

This directory stores the small amount of KDE configuration that Home Manager
manages. It is deliberately minimal.

Original source (old Arch backup):
https://gitee.com/zhangchibang/ziyun_-arch_-kde_-config.git

## What Is Kept

- `config/plasma-org.kde.plasma.desktop-appletsrc` — the two-panel layout:

  **bottom panel** (Containment 2, floating, 45px):
  - kickoff (start menu, normal popup — not fullscreen) + panel spacer
  - icon-only task manager (`org.kde.plasma.icontasks`, Win11 style:
    open windows collapse to icons, no long strips) + panel spacer
  - margins separator (right edge)
  - no clock, no system tray here

  **top panel** (Containment 30, floating, 36px), left → right:
  - window list (unchanged, top-left)
  - flexible spacer
  - lyrics display (`com.github.illuminate-dev.onlyrics`, middle-right)
  - net speed (system monitor, text-only) → CPU usage (text-only)
  - system tray (status bar) → digital clock (time + date, with seconds)

  **system tray** (private containment 8): clipboard, notifications,
  volume, network, bluetooth, battery, brightness, kimpanel (fcitx5),
  keyboard layout, kscreen, media controller, vault, print manager,
  kdeconnect, device notifier, camera indicator.

- `config/kdeglobals` — the "Sakura Neon" (樱花霓虹) anime scheme:
  dark violet base, neon pink/cyan accents, `candy-icons` gradient icon
  theme. To change: System Settings → Colors, then copy the resulting
  `~/.config/kdeglobals` back over this file (KDE app saves replace the
  Home Manager symlink with a regular file).
- `config/plasmashellrc` — panel thickness/floating settings.
- `config/plasma-localerc` — Chinese locale for Plasma.
- `config/kwinrc` — virtual desktops, flashy effects (wobbly, fallapart,
  slideback, translucency), fcitx5 as Wayland input method.
- `wallpapers/ZiYyun_KDE_DesktopShort.png` — optional wallpaper, available
  in `~/.local/share/wallpapers/`; the layout does not force it. Drop any
  anime wallpaper into `wallpapers/` and pick it in System Settings.

## Related Packages

- `packages/custom/plasma-desktop-qml` — QML applet frontends missing from
  the nixpkgs plasma-desktop build (kickoff, icontasks/taskmanager,
  windowlist, kimpanel, ...).
- `packages/custom/plasmoid-onlyrics` — the panel lyrics widget
  (`com.github.illuminate-dev.onlyrics`), patched to use LRCLIB
  (https://lrclib.net) as default lyrics source. Works with any
  MPRIS2-capable player. If your player reports lyrics in its own app but
  the panel shows "No lyrics available!", check the song exists on LRCLIB
  or set a custom `{time,words}` API URL in the widget's settings.

## What Was Removed And Why

The previous version imported most of the Arch backup (kdeglobals, kwinrc,
plasmarc, plasmashellrc, kdedefaults, user-feedback config, plasma-nm, ...).
That caused repeated load failures in Plasma 6.6:

- `org.kde.plasma.manage-inputmethod` tray item: plasmoid not shipped by
  the nixpkgs fcitx5 package (kimpanel is used instead).
- `org.kde.plasma.icontasks` task bar: its QML lives under
  `org.kde.plasma.taskmanager` (X-Plasma-RootPath), and the nixpkgs
  plasma-desktop build ships no applet QML at all (fixed separately by
  `packages/custom/plasma-desktop-qml`).
- standalone network/volume/battery/bluetooth panel applets: folded into the
  system tray in the top-right corner.

If you want more Plasma customizations, configure them in the running session
and export with `shells/export-dotfiles.sh`, or hand-edit the appletsrc
above. Note that Home Manager links are read-only; Plasma cannot persist
widget moves back into the store path.

Home Manager links these files through:

```nix
modules/home/config-files/kde.nix
```
