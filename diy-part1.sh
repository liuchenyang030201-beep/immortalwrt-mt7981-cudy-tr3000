#!/bin/bash
#
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#

set -e

echo "============================================================"
echo " DIY PART1: Add extra packages before feeds update"
echo "============================================================"

mkdir -p package

# ============================================================
# GitHub clone helper
# Proxy first, original URL fallback
# ============================================================

GH_PROXY="https://gh-proxy.com/"

clone_repo() {
  local repo="$1"
  local dir="$2"

  echo "============================================================"
  echo "Clone $repo"
  echo "To    $dir"
  echo "============================================================"

  rm -rf "$dir"

  git clone --depth=1 "${GH_PROXY}${repo}" "$dir" || \
  git clone --depth=1 "$repo" "$dir"
}

# ============================================================
# Keep local luci-compat package if exists
# ============================================================

if [ -d "$GITHUB_WORKSPACE/package/luci-compat-keep" ]; then
  echo "Copy local luci-compat-keep"
  rm -rf package/luci-compat-keep
  cp -r "$GITHUB_WORKSPACE/package/luci-compat-keep" package/
fi

# ============================================================
# Clean old extra packages
# ============================================================

rm -rf package/passwall
rm -rf package/passwall-packages
rm -rf package/nikki
rm -rf package/luci-theme-aurora
rm -rf package/luci-app-aurora-config
rm -rf package/luci-theme-argon
rm -rf package/luci-app-argon-config
rm -rf package/luci-app-bandix
rm -rf package/openwrt-bandix

# ============================================================
# PassWall
# ============================================================

clone_repo "https://github.com/xiaorouji/openwrt-passwall.git" "package/passwall"
clone_repo "https://github.com/xiaorouji/openwrt-passwall-packages.git" "package/passwall-packages"

# ============================================================
# Nikki
# ============================================================

clone_repo "https://github.com/nikkinikki-org/OpenWrt-nikki.git" "package/nikki"

# ============================================================
# LuCI Themes: Aurora / Argon
# ============================================================

clone_repo "https://github.com/eamonxg/luci-theme-aurora.git" "package/luci-theme-aurora"
clone_repo "https://github.com/eamonxg/luci-app-aurora-config.git" "package/luci-app-aurora-config"

clone_repo "https://github.com/jerrykuku/luci-theme-argon.git" "package/luci-theme-argon"
clone_repo "https://github.com/jerrykuku/luci-app-argon-config.git" "package/luci-app-argon-config"

# ============================================================
# Bandix
# ============================================================

clone_repo "https://github.com/timsaya/luci-app-bandix.git" "package/luci-app-bandix"
clone_repo "https://github.com/timsaya/openwrt-bandix.git" "package/openwrt-bandix"

# ============================================================
# Remove git metadata from local packages
# ============================================================

find package -name ".git" -type d -prune -exec rm -rf {} + || true

echo "============================================================"
echo " DIY PART1 done"
echo "============================================================"
