/**
 * File: default.nix
 * Author: ziyun
 * Date: 2026-08-24
 * Description: QoderWake CN（qoderwake-cn）—— Qoder 的本地语音唤醒/智能体守护进程。
 *
 * 官方 CN 分发（install.sh / manifest.json 抓取）：
 *   qoderwake: https://ide.qoder.com.cn/qoderwake-cn/releases/<v>/qoderwake-cn_<v>_linux_amd64.tar.gz
 *   （tarball 内置 qodercli/qodercli-cn-wake 与 resources/）
 *
 * 二进制（Bun 编译的单文件 ELF）只动态链接 glibc，用 autoPatchelfHook 改
 * 解释器即可在 NixOS 运行；resources/ 必须与 qoderwake-cn 同级（程序按相对
 * 路径加载），因此本体放 $out/lib/qoderwake/。运行时数据写入
 * ~/.qoderwake-cn（官方 QODERWAKE_HOME），wrapper 负责把 qodercli 放到该
 * 目录下官方布局的位置。守护进程由 `qoderwake-cn start` 自注册 systemd 用户
 * 服务，无需 NixOS 模块。
 *
 * 更新：改 version + src.hash（nix build 报错会给出真实值）。
 */
{ lib, stdenv, fetchurl, autoPatchelfHook, python3 }:

stdenv.mkDerivation rec {
  pname = "qoder-wake";
  version = "0.3.5-cn"; # tarball 内置 qodercli 1.1.8（qodercli-cn-wake）

  src = fetchurl {
    url = "https://ide.qoder.com.cn/qoderwake-cn/releases/${version}/qoderwake-cn_${version}_linux_amd64.tar.gz";
    hash = "sha256-jXP7QcDdy3CTh8VpNsvwJGCEX6D/Gpu7uqKP/6Eqf1w=";
  };

  dontBuild = true;
  dontConfigure = true;
  # Bun 编译的单文件二进制：stdenv 的 stripPhase 会破坏内嵌应用数据
  # （表现为退化成纯 bun CLI，"Script not found"），必须跳过。
  dontStrip = true;
  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ stdenv.cc.cc.lib ];

  # 本体目录（二进制 + resources/ 同级，程序按相对路径加载 resources）。
  libDir = "${lib.placeholder "out"}/lib/qoderwake";

  unpackPhase = "true";

  installPhase = ''
    runHook preInstall
    mkdir -p "${libDir}" "$out/bin"

    # 解包 qoderwake-cn + resources/ + qodercli/qodercli-cn-wake
    tar xzf ${src} -C "${libDir}"
    chmod -R u+w "${libDir}"
    chmod 0755 "${libDir}/qoderwake-cn" "${libDir}/qodercli/qodercli-cn-wake"

    autoPatchelf "$out"

    cat > "$out/bin/qoderwake-cn" <<'EOF'
#!/usr/bin/env bash
set -e
# QoderWake 运行时会话目录（官方默认 ~/.qoderwake-cn，可用 QODERWAKE_HOME 覆盖）
QODER_HOME="''${QODERWAKE_HOME:-$HOME/.qoderwake-cn}"
# 守护进程按官方布局在 QODERWAKE_HOME/qodercli 下找 qodercli，首次运行补齐。
mkdir -p "$QODER_HOME/qodercli"
if [ ! -x "$QODER_HOME/qodercli/qodercli-cn-wake" ]; then
  cp "${libDir}/qodercli/qodercli-cn-wake" "$QODER_HOME/qodercli/qodercli-cn-wake"
  chmod 0755 "$QODER_HOME/qodercli/qodercli-cn-wake"
fi
# 触发器脚本等需要 python3；PATH 补上（nix store 只读，不影响）
export PATH="${python3}/bin:$PATH"
exec "${libDir}/qoderwake-cn" "$@"
EOF
    chmod +x "$out/bin/qoderwake-cn"

    cat > "$out/bin/qodercli-cn-wake" <<'EOF'
#!/usr/bin/env bash
set -e
export PATH="${python3}/bin:$PATH"
exec "${libDir}/qodercli/qodercli-cn-wake" "$@"
EOF
    chmod +x "$out/bin/qodercli-cn-wake"

    # Portal 启动器：确保守护进程在跑，然后在默认浏览器打开本地控制台。
    cat > "$out/bin/qoderwake-portal" <<'EOF'
#!/usr/bin/env bash
set -e
export PATH="${python3}/bin:$PATH"
"${libDir}/qoderwake-cn" start >/dev/null 2>&1 || true
exec "${libDir}/qoderwake-cn" portal
EOF
    chmod +x "$out/bin/qoderwake-portal"

    # 兼容旧命令名（此前包提供 qoderwake / qodercli-wake，避免 switch 后
    # 用户习惯的命令失效）。
    ln -s qoderwake-cn "$out/bin/qoderwake"
    ln -s qodercli-cn-wake "$out/bin/qodercli-wake"

    # 桌面入口（KDE 应用菜单，与其他 customPackages 应用一致）。
    mkdir -p "$out/share/applications"
    cat > "$out/share/applications/qoderwake.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=QoderWake
Comment=QoderWake 本地控制台（浏览器打开）
Exec=$out/bin/qoderwake-portal
Icon=qoderwake
Categories=Development;IDE;
Terminal=false
EOF

    runHook postInstall
  '';

  meta = with lib; {
    description = "QoderWake CN - local voice wake-up / agent daemon for Qoder";
    homepage = "https://qoder.com.cn";
    license = licenses.unfree;
    platforms = platforms.linux;
    mainProgram = "qoderwake-cn";
  };
}
