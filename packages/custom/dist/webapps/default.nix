/**
 * File: default.nix (packages/custom/dist/webapps)
 * Author: ziyun
 * Date: 2026-09-05
 * Description: 复用浏览器原生 PWA 能力（Chromium --app=URL 独立窗口）把 AI
 *   网页应用打包成桌面应用（豆包 / 千问 / DeepSeek）。
 *
 *   理念：不搞 Electron 二次封装（体积大、体验重），直接用宿主 Chromium
 *   （microsooft-edge）的 --app 模式开独立无地址栏窗口。每个 WebApp 用独立
 *   --user-data-dir 隔离缓存与登录态，保证可复现性。
 *
 * 更新：加新站点只需在 sites 里加一组记录即可。
 */
{
  lib,
  stdenv,
  writeText,
  microsoft-edge,
}:

let
  # 生成单个 WebApp 的 derivation：个性化 SVG 图标 + desktop entry + 启动 wrapper。
  buildWebApp =
    { name
    , displayName
    , url
    , color # 图标背景色（#RRGGBB）
    , glyph # 图标上显示的一个字符（如 豆 / Q / D）
    }:
    stdenv.mkDerivation {
      pname = name;
      version = "1.0.0";

      # 纯生成包：没有源码，跳过解包/编译，只跑 installPhase。
      dontUnpack = true;
      dontBuild = true;

      # 独立 user-data-dir：登录态/缓存与主浏览器隔离开，多站点互不干扰。
      # (在 installPhase 里通过 ${name} 内联，Nix 求值为字面量。)

      # 内联 SVG 图标：圆角渐变方块 + 白色首字。离线生成、可复现，无需网络抓 favicon。
      svgIcon = writeText "${name}-icon.svg" ''
        <svg xmlns="http://www.w3.org/2000/svg" width="256" height="256" viewBox="0 0 256 256">
          <defs>
            <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">
              <stop offset="0" stop-color="${color}"/>
              <stop offset="1" stop-color="black" stop-opacity="0.35"/>
            </linearGradient>
          </defs>
          <rect x="20" y="20" width="216" height="216" rx="56" fill="url(#bg)"/>
          <text x="128" y="152" font-family="sans-serif" font-size="120"
                font-weight="bold" text-anchor="middle" dominant-baseline="middle"
                fill="#ffffff">${glyph}</text>
        </svg>
      '';

      installPhase = ''
        runHook preInstall
        mkdir -p $out/bin $out/share/applications $out/share/icons/hicolor/scalable/apps

        install -m644 "$svgIcon" $out/share/icons/hicolor/scalable/apps/${name}.svg

        cat > $out/bin/${name} <<EOF
        #!/usr/bin/env bash
        exec "${microsoft-edge}/bin/microsoft-edge" --no-sandbox \
          --user-data-dir="\$HOME/.config/webapps/${name}" \
          --app="${url}" "\$@"
        EOF
        chmod +x $out/bin/${name}

        cat > $out/share/applications/${name}.desktop <<EOF
        [Desktop Entry]
        Name=${displayName}
        Comment=${displayName} Web App
        Exec=$out/bin/${name}
        Terminal=false
        Type=Application
        Categories=Network;Chat;Web;
        Icon=$out/share/icons/hicolor/scalable/apps/${name}.svg
        StartupNotify=true
        EOF
        runHook postInstall
      '';

      meta = with lib; {
        description = "${displayName} — 浏览器原生 PWA 桌面应用";
        homepage = url;
        license = licenses.unfree;
        platforms = platforms.linux;
        mainProgram = name;
      };
    };

  # 站点清单：name 是包名/命令名，displayName 是菜单位，glyph/color 是图标。
  sites = [
    {
      name = "doubao";
      displayName = "豆包";
      url = "https://www.doubao.com";
      color = "#4F7CFF";
      glyph = "豆";
    }
    {
      name = "qwen-chat";
      displayName = "千问";
      url = "https://chat.qwen.ai";
      color = "#615CED";
      glyph = "Q";
    }
    {
      name = "deepseek";
      displayName = "DeepSeek";
      url = "https://chat.deepseek.com";
      color = "#4D6BFE";
      glyph = "D";
    }
  ];
in
builtins.listToAttrs (map (s: { name = s.name; value = buildWebApp s; }) sites)