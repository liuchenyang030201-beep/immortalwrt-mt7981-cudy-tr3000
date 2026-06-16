#!/bin/bash
#
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
# Stable build: PassWall removed
#

set -e

printf '%s\n' '============================================================'
printf '%s\n' ' DIY PART1: Add extra packages before feeds update'
printf '%s\n' ' PassWall removed for stable build'
printf '%s\n' '============================================================'

mkdir -p package

download_repo() {
  local owner="$1"
  local repo="$2"
  local dir="$3"
  local branch
  local url
  local tmp
  local ok="0"

  printf '%s\n' '============================================================'
  printf 'Download %s/%s\n' "$owner" "$repo"
  printf 'Target %s\n' "$dir"
  printf '%s\n' '============================================================'

  rm -rf "$dir"

  for branch in main master; do
    url="https://codeload.github.com/${owner}/${repo}/tar.gz/refs/heads/${branch}"
    tmp="/tmp/${owner}-${repo}-${branch}.tar.gz"

    if curl -fsSL --retry 3 --connect-timeout 20 "$url" -o "$tmp"; then
      mkdir -p "$dir"
      tar -xzf "$tmp" -C "$dir" --strip-components=1
      rm -f "$tmp"
      ok="1"
      printf 'Download OK: %s/%s branch %s\n' "$owner" "$repo" "$branch"
      break
    fi

    rm -f "$tmp"
  done

  if [ "$ok" != "1" ]; then
    printf '%s\n' 'Tarball failed, try git clone'
    git clone --depth=1 "https://github.com/${owner}/${repo}.git" "$dir"
  fi
}

if [ -d "$GITHUB_WORKSPACE/package/luci-compat-keep" ]; then
  printf '%s\n' 'Copy local luci-compat-keep'
  rm -rf package/luci-compat-keep
  cp -r "$GITHUB_WORKSPACE/package/luci-compat-keep" package/
fi

rm -rf package/passwall
rm -rf package/passwall-packages
rm -rf package/nikki
rm -rf package/luci-theme-aurora
rm -rf package/luci-app-aurora-config
rm -rf package/luci-theme-argon
rm -rf package/luci-app-argon-config
rm -rf package/luci-app-bandix
rm -rf package/openwrt-bandix

# Nikki
download_repo "nikkinikki-org" "OpenWrt-nikki" "package/nikki"

# LuCI themes
download_repo "eamonxg" "luci-theme-aurora" "package/luci-theme-aurora"
download_repo "eamonxg" "luci-app-aurora-config" "package/luci-app-aurora-config"
download_repo "jerrykuku" "luci-theme-argon" "package/luci-theme-argon"
download_repo "jerrykuku" "luci-app-argon-config" "package/luci-app-argon-config"

# Bandix
download_repo "timsaya" "luci-app-bandix" "package/luci-app-bandix"
download_repo "timsaya" "openwrt-bandix" "package/openwrt-bandix"

rm -rf package/passwall
rm -rf package/passwall-packages

find package -name '.git' -type d -prune -exec rm -rf {} + || true

printf '%s\n' '============================================================'
printf '%s\n' ' DIY PART1 done'
printf '%s\n' '============================================================'
