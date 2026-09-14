#!/usr/bin/env bash
# WayDroid 镜像下载 + 初始化脚本。
#
# NixOS 只声明了 waydroid 运行时，Android 系统镜像（约 1.4 GB）需要手动
# 下载到 /var/lib/waydroid/images/。本脚本支持换源和代理，面向国内网络。
#
# 用法（root）：
#   # 直连 sourceforge（较慢）
#   sudo bash shells/waydroid-init.sh
#
#   # 走本地 clash 代理（推荐，快）
#   sudo bash shells/waydroid-init.sh --proxy http://127.0.0.1:7897
#
#   # 指定自定义镜像前缀（你自己的镜像站）
#   sudo bash shells/waydroid-init.sh --mirror https://example.com/waydroid
#
set -euo pipefail

# ===== 镜像版本（升级时改这里，日期见 sourceforge 文件名） =====
ANDROID_VERSION="20.0"          # LineageOS 20.0 == Android 13
IMAGE_DATE="20260403"
VARIANT="GAPPS"                 # GAPPS | VANILLA
ARCH="x86_64"

VENDOR_ZIP="lineage-${ANDROID_VERSION}-${IMAGE_DATE}-MAINLINE-waydroid_${ARCH}-vendor.zip"
SYSTEM_ZIP="lineage-${ANDROID_VERSION}-${IMAGE_DATE}-${VARIANT}-waydroid_${ARCH}-system.zip"

# 官方源（sourceforge 会 302 到 zenlayer 等 CDN）
SF_BASE="https://downloads.sourceforge.net/project/waydroid/images"
VENDOR_PATH="vendor/waydroid_${ARCH}/${VENDOR_ZIP}"
SYSTEM_PATH="system/lineage/waydroid_${ARCH}/${SYSTEM_ZIP}"

IMAGES_DIR="/var/lib/waydroid/images"
MIRROR_BASE=""                  # 自定义镜像前缀（若设置，忽略 SF_BASE）
PROXY=""                        # 代理，如 http://127.0.0.1:7897
SKIP_DOWNLOAD="false"
FORCE_INIT="true"

usage() {
  cat <<'EOF'
Usage:
  sudo bash shells/waydroid-init.sh [options]

Options:
  --proxy URL         HTTP(S) 代理（clash 混合端口通常是 http://127.0.0.1:7897）
  --mirror BASE       自定义镜像前缀；BASE 下需有 vendor/ 与 system/lineage/ 目录
  --variant NAME      GAPPS（默认）或 VANILLA
  --images-dir DIR    镜像目录（默认 /var/lib/waydroid/images）
  --skip-download     已手动放好 system.img/vendor.img，只跑 init
  --no-init           只下载解压，不执行 waydroid init
  -h, --help          帮助
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --proxy) PROXY="${2:?missing value for --proxy}"; shift 2 ;;
    --mirror) MIRROR_BASE="${2:?missing value for --mirror}"; shift 2 ;;
    --variant) VARIANT="${2:?missing value for --variant}"; shift 2 ;;
    --images-dir) IMAGES_DIR="${2:?missing value for --images-dir}"; shift 2 ;;
    --skip-download) SKIP_DOWNLOAD="true"; shift ;;
    --no-init) FORCE_INIT="false"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

# 换源后需同步 system 文件名里的 variant
SYSTEM_ZIP="lineage-${ANDROID_VERSION}-${IMAGE_DATE}-${VARIANT}-waydroid_${ARCH}-system.zip"
SYSTEM_PATH="system/lineage/waydroid_${ARCH}/${SYSTEM_ZIP}"

if [[ "${EUID}" -ne 0 ]]; then
  echo "Please run as root." >&2
  exit 1
fi

require_command() { command -v "$1" >/dev/null 2>&1 || { echo "missing command: $1" >&2; exit 1; }; }

# 下载工具：优先 aria2c（多线程），否则 curl
downloader() {
  local url="$1" out="$2"
  if command -v aria2c >/dev/null 2>&1; then
    aria2c ${PROXY:+--all-proxy="$PROXY"} -x 8 -s 8 -k 1M -d "$(dirname "$out")" -o "$(basename "$out")" "$url"
  else
    curl -L ${PROXY:+-x "$PROXY"} --retry 5 --retry-delay 3 -C - -o "$out" "$url"
  fi
}

full_url() { # path -> url
  local path="$1"
  if [[ -n "${MIRROR_BASE}" ]]; then
    echo "${MIRROR_BASE%/}/${path}"
  else
    echo "${SF_BASE}/${path}"
  fi
}

mkdir -p "${IMAGES_DIR}"
cd "${IMAGES_DIR}"

if [[ "${SKIP_DOWNLOAD}" != "true" ]]; then
  # 已下载过的 zip 直接跳过，避免重复下载 1.4 GB
  if [[ -s "${VENDOR_ZIP}" ]]; then
    echo "==> ${VENDOR_ZIP} 已存在，跳过下载"
  else
    echo "==> 下载 vendor 镜像: ${VENDOR_ZIP}"
    downloader "$(full_url "${VENDOR_PATH}")" "${VENDOR_ZIP}"
  fi

  if [[ -s "${SYSTEM_ZIP}" ]]; then
    echo "==> ${SYSTEM_ZIP} 已存在，跳过下载"
  else
    echo "==> 下载 ${VARIANT} system 镜像: ${SYSTEM_ZIP}"
    downloader "$(full_url "${SYSTEM_PATH}")" "${SYSTEM_ZIP}"
  fi

  echo "==> 校验 zip 完整性并解压"
  require_command unzip
  unzip -t "${VENDOR_ZIP}" >/dev/null
  unzip -t "${SYSTEM_ZIP}" >/dev/null
  unzip -o "${VENDOR_ZIP}" -d "${IMAGES_DIR}"
  unzip -o "${SYSTEM_ZIP}" -d "${IMAGES_DIR}"

  # 解压后通常得到 vendor.img / system.img（有的包带一层目录，兜底找一下）
  if [[ ! -f "${IMAGES_DIR}/vendor.img" ]]; then
    mv "$(find "${IMAGES_DIR}" -name vendor.img -type f | head -1)" "${IMAGES_DIR}/vendor.img" 2>/dev/null || true
  fi
  if [[ ! -f "${IMAGES_DIR}/system.img" ]]; then
    mv "$(find "${IMAGES_DIR}" -name system.img -type f | head -1)" "${IMAGES_DIR}/system.img" 2>/dev/null || true
  fi
fi

if [[ ! -f "${IMAGES_DIR}/vendor.img" || ! -f "${IMAGES_DIR}/system.img" ]]; then
  echo "error: ${IMAGES_DIR} 缺少 vendor.img 或 system.img" >&2
  exit 1
fi

ls -lh "${IMAGES_DIR}"/vendor.img "${IMAGES_DIR}"/system.img

if [[ "${FORCE_INIT}" == "true" ]]; then
  require_command waydroid
  echo "==> waydroid init -f -s ${VARIANT} -i ${IMAGES_DIR}"
  waydroid init -f -s "${VARIANT}" -i "${IMAGES_DIR}"
fi

cat <<'EOF'

==> 完成。后续步骤：
  1. 启动容器:   sudo waydroid container start
  2. 显示界面:   waydroid show-full-ui   （需在 Wayland 会话内运行）
  3. 常用命令:   waydroid app list / waydroid app launch <pkg>
  4. GAPPS 登录：Android 13 GApps 需要先做设备认证，否则 Play 商店报错。
     参见: https://docs.waydro.id/faq/google-play-certification

  若从 Niri 会话运行，waydroid 输出到 niri 的 Wayland 合成器，无需 X11。
EOF
