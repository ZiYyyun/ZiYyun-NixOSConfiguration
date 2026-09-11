/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-09-10
 * Description: CC Switch —— 统一管理 Claude Code / Codex / Gemini CLI 配置
 * 与供应商切换的桌面应用（farion1231/cc-switch，Tauri v2）。
 *
 * 官方提供 AppImage（完全自包含：内联 webkit2gtk-4.1 / libsoup-3 /
 * ayatana-appindicator，且 gio/modules/libgiognutls.so 提供 TLS 后端），
 * 因此用 appimageTools.wrapType2 解包封装即可，无需额外 buildInputs
 * 或 LD_LIBRARY_PATH/GIO_EXTRA_MODULES 注入。wrapType2 调 AppRun，后者
 * source linuxdeploy-plugin-gtk.sh 自行设置全部 GTK/GIO 环境变量。
 *
 * 官网：https://www.ccswitch.io/zh/download
 * 更新：版本以 GitHub Releases 为准（通常比官网页更新）：
 *   https://github.com/farion1231/cc-switch/releases/latest
 *   ./packages/custom/update.sh --bump cc-switch
 */
{
  lib,
  stdenv,
  fetchurl,
  appimageTools,
}:
let
  pname = "cc-switch";
  version = "3.20.2";

  src = fetchurl {
    url = "https://github.com/farion1231/cc-switch/releases/download/v${version}/CC-Switch-v${version}-Linux-x86_64.AppImage";
    hash = "sha256-Ubhx8rNGRCn+GZWGE/4b9js772iEmbVnbOeoWeZLXxI=";
  };

  # wrapType2：解包 squashfs → patchelf 解释器 → 生成调 AppRun 的 wrapper
  appimage = appimageTools.wrapType2 {
    name = pname;
    inherit src;
  };

  # extractType2：仅为取出 .desktop 和图标
  contents = appimageTools.extractType2 {
    name = "${pname}-${version}";
    inherit src;
  };
in
stdenv.mkDerivation {
  inherit pname version src;

  # src 是 AppImage，无需源码解包/编译；全部来自上面两个 appimageTools 产物
  dontUnpack = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/share/applications $out/share/icons
    cp ${appimage}/bin/${pname} $out/bin/${pname}

    # hicolor 图标（128/256/512）
    cp -r ${contents}/usr/share/icons/hicolor $out/share/icons/

    cp "${contents}/CC Switch.desktop" $out/share/applications/${pname}.desktop
    sed -i \
      -e "s|^Exec=.*|Exec=$out/bin/${pname}|" \
      -e "s|^Icon=.*|Icon=${pname}|" \
      "$out/share/applications/${pname}.desktop"

    runHook postInstall
  '';

  meta = with lib; {
    description = "All-in-one assistant for Claude Code, Codex & Gemini CLI";
    homepage = "https://www.ccswitch.io";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
  };
}
