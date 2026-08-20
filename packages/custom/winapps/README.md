# WinApps (Wine-packaged Windows software)

Windows applications packaged with Wine, Nix-reproducible. Both installers
are fetched automatically from official sources with pinned hashes — no
manual download needed.

| Package | App | Mode | Source |
| --- | --- | --- | --- |
| `feiq` | 飞秋 (LAN IM / file transfer) | extract (green exe) | official `feiq18.com/down/feiq.zip`, pinned hash |
| `redspider-student` | 红蜘蛛多媒体网络教室 学生端 | firstrun-install (InstallShield silent) | official `3000soft.net/cmain/download/red_spider_v721785.zip`, pinned hash |

## Usage

```bash
nix run .#feiq                 # or: nix run .#feiq -- <args>
nix run .#redspider-student
```

Both install a KDE menu entry too.

Each app uses its own Wine prefix at `~/.local/share/winapps/<pname>`; user
data survives rebuilds. On first launch the wrapper:

1. initializes the prefix (`wineboot -u`),
2. injects CJK fonts — copies `wqy-zenhei` into `drive_c/windows/Fonts` and
   registers `SimSun`/`宋体` font substitutes, so Chinese renders correctly
   (also repairs prefixes created before this feature),
3. for redspider: silently installs it with the bundled InstallShield
   response file (`setup.exe /s /f1"usetup.iss"`).

## Updating

- FeiQ: bump the fetchzip hash after downloading the new zip.
- Red Spider: the official site also hosts newer `red_spider_v*` zips;
  update `url` + `sha256` in `redspider.nix`.

## Notes

- LAN apps (UDP broadcast) work directly through Wine on the host — no
  container network isolation like WinBoat. FeiQ needs UDP/TCP 2425 opened
  in the firewall (already in `configuration.nix`).
- Wine version: `wineWowPackages.wayland` (Wine 11, native Wayland). Swap to
  `wineWowPackages.stable` in `wine-app.nix` if a Wayland driver issue appears.
- Reproducibility: software bits come from the Nix store; the Wine prefix is
  created deterministically by the wrapper.
