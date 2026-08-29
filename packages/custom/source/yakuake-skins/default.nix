/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-08-23
 * Description: Yakuake 下拉终端皮肤集（老式 SVG 皮肤，与 yakuake 26.04 内置格式一致）。
 *
 * 皮肤目录名即皮肤 ID（yakuake 按目录名枚举 skins 目录）。
 * 来源：
 *   - dracula/yakuake        （Dracula 官方）  商店同名 3895 下载
 *   - catppuccin/yakuake     （Catppuccin 官方，4 个变体）
 *   - Yakuake-Breath2-Dark-Minimal             商店 9513 下载
 *   - WhiteSur-Yakuake-theme                   商店 4468 下载
 *   - shvchk/breezly-yakuake                   商店 Breezly 5314 下载
 *   - TheBigWazz/Slate                         商店 Slate 3623 下载
 *   - vendor/（商店 top：ROUNDED DARK / Sierra Breeze Mini / Monochrome /
 *     Breeze V2 / Prof Dark / Breeze Black —— 从 KDE 商店下载 vendor 进 git）
 *
 * github.com 直连不通，走 ghfast.top 代理（与本仓库其他 input 一致）。
 */
{ lib, stdenv, fetchurl }:

let
  gh = { name, owner, repo, branch, sha256 }: fetchurl {
    name = "${name}.tar.gz";
    url = "https://ghfast.top/https://github.com/${owner}/${repo}/archive/refs/heads/${branch}.tar.gz";
    inherit sha256;
  };

  skins = {
    Dracula = gh {
      name = "dracula"; owner = "dracula"; repo = "yakuake"; branch = "master";
      sha256 = "sha256-4LuwyD5ZcQRXzlk0nDaUUt6q4AB3FHHkFqfyegdzan4=";
    };
    Catppuccin = gh {
      name = "catppuccin"; owner = "catppuccin"; repo = "yakuake"; branch = "main";
      sha256 = "sha256-dcHtBVbw8X8SMvw5dBLo4syqSXD2xJOdumZrGHZZIpg=";
    };
    Breath2DarkMinimal = gh {
      name = "breath2"; owner = "bernharl"; repo = "Yakuake-Breath2-Dark-Minimal"; branch = "master";
      sha256 = "sha256-RU/nq7LyEetjV+vBE1zNzHineyXYQo8VAiEiz+3PH0A=";
    };
    WhiteSur = gh {
      name = "whitesur"; owner = "InterstellarOne"; repo = "WhiteSur-Yakuake-theme"; branch = "main";
      sha256 = "sha256-KeqKZz93SspDtCDyYkmBUN0LOfawED7gS5HPv4JImFM=";
    };
    Breezly = gh {
      name = "breezly"; owner = "shvchk"; repo = "breezly-yakuake"; branch = "master";
      sha256 = "sha256-WIzMvrlfLIk3uI6pqI20+6ArhquUlIAXv/gSVPB+BS0=";
    };
    Slate = gh {
      name = "slate"; owner = "TheBigWazz"; repo = "Slate"; branch = "main";
      sha256 = "sha256-4wm5AxVW8QdrL4a2h+PxQWzJbAgmqEy849ZItRjJhxs=";
    };
  };

in
stdenv.mkDerivation {
  pname = "yakuake-skins";
  version = "2026-08-23";

  dontBuild = true;
  dontConfigure = true;
  unpackPhase = "true";

  installPhase = ''
    runHook preInstall
    skinDir="$out/share/yakuake/skins"

    # Dracula：仓库根即皮肤
    unpackOne() { # $1=tar $2=目的地
      mkdir -p "$2"
      tar xzf "$1" -C "$2" --strip-components=1
    }

    unpackOne ${skins.Dracula} "$skinDir/Dracula"

    # Catppuccin：4 个变体
    mkdir -p /tmp/catppuccin
    tar xzf ${skins.Catppuccin} -C /tmp/catppuccin --strip-components=1
    for v in frappe latte macchiato mocha; do
      mkdir -p "$skinDir/Catppuccin-$v"
      cp -r "/tmp/catppuccin/$v/." "$skinDir/Catppuccin-$v/"
    done

    unpackOne ${skins.Breath2DarkMinimal} "$skinDir/Breath2-Dark-Minimal"
    unpackOne ${skins.WhiteSur} "$skinDir/WhiteSur"
    unpackOne ${skins.Breezly} "$skinDir/Breezly"

    # Slate：外层仓库只含一个内层 Slate.tar.gz
    mkdir -p /tmp/slate
    tar xzf ${skins.Slate} -C /tmp/slate --strip-components=1
    unpackOne /tmp/slate/Slate.tar.gz "$skinDir/Slate"

    # vendor 皮肤（商店 top）
    if [ -d ${./vendor} ]; then
      for f in ${./vendor}/*.tar.gz; do
        [ -e "$f" ] || continue
        name="$(basename "$f" .tar.gz)"
        unpackOne "$f" "$skinDir/$name"
      done
    fi

    runHook postInstall
  '';

  meta = with lib; {
    description = "High-ranked Yakuake skins (Dracula, Catppuccin, Breath2, WhiteSur, Breezly, Slate + store top)";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = [ ];
  };
}
