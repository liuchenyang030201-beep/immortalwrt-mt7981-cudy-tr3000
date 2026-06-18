#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate

# 临时解决Rust问题
sed -i 's/ci-llvm=true/ci-llvm=false/g' feeds/packages/lang/rust/Makefile

# add date in output file name
sed -i -e '/^IMG_PREFIX:=/i BUILD_DATE := $(shell date +%Y%m%d)' \
       -e '/^IMG_PREFIX:=/ s/\($(SUBTARGET)\)/\1-$(BUILD_DATE)/' include/image.mk

# set ubi to 122M
# sed -i 's/reg = <0x5c0000 0x7000000>;/reg = <0x5c0000 0x7a40000>;/' target/linux/mediatek/dts/mt7981b-cudy-tr3000-v1-ubootmod.dts


# ===== CudyX / Xiaomaozai minimal custom defaults =====
mkdir -p files/etc/uci-defaults files/www/luci-static/custom
cat > files/etc/uci-defaults/90-cudyx-defaults <<'EOF'
#!/bin/sh
uci set system.@system[0].hostname='CudyX'
uci commit system
exit 0
EOF
chmod +x files/etc/uci-defaults/90-cudyx-defaults

cat > files/www/luci-static/custom/xiaomaozai-badge.js <<'EOF'
(function () {
  function addBadge() {
    if (document.getElementById('xiaomaozai-badge')) return;
    var a = document.createElement('a');
    a.id = 'xiaomaozai-badge';
    a.href = 'https://github.com/asrtroh-netizen/immortalwrt-mt7981-cudy-tr3000';
    a.target = '_blank';
    a.textContent = '小猫崽';
    a.style.cssText = 'position:fixed;right:12px;bottom:10px;z-index:9999;padding:5px 9px;border-radius:10px;background:rgba(0,0,0,.45);color:#fff;font-size:12px;text-decoration:none;backdrop-filter:blur(6px);';
    document.body.appendChild(a);
  }
  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', addBadge);
  else addBadge();
})();
EOF

cat > files/etc/uci-defaults/93-xiaomaozai-badge <<'EOF'
#!/bin/sh
for f in /www/index.html /www/luci-static/resources/view/status/include/10_system.js; do
  [ -f "$f" ] || continue
  grep -q 'xiaomaozai-badge.js' "$f" && continue
  echo '<script src="/luci-static/custom/xiaomaozai-badge.js"></script>' >> "$f"
done
exit 0
EOF
chmod +x files/etc/uci-defaults/93-xiaomaozai-badge

# ===== 512M DTS only. Do not touch 128M / 256M. =====
BUILD_DEVICE="${BUILD_DEVICE:-${CURRENT_DEVICE:-${DEVICE:-}}}"
if [ "$BUILD_DEVICE" = "512M" ]; then
  echo "========== 512M DTS injection =========="
  DTS_DIR="target/linux/mediatek/dts"
  IMG_MK="target/linux/mediatek/image/filogic.mk"
  mkdir -p "$DTS_DIR"
  wget -qO "$DTS_DIR/mt7981b-cudy-tr3000-512mb-v1.dts" \
    "https://raw.githubusercontent.com/zhuannn/cudy-tr3000-512/main/mt7981b-cudy-tr3000-512mb-v1.dts" || true
  if [ -s "$DTS_DIR/mt7981b-cudy-tr3000-512mb-v1.dts" ] && ! grep -q "cudy_tr3000-512mb-v1" "$IMG_MK"; then
    cat >> "$IMG_MK" <<'EOF'

define Device/cudy_tr3000-512mb-v1
  DEVICE_VENDOR := Cudy
  DEVICE_MODEL := TR3000
  DEVICE_VARIANT := 512M v1
  DEVICE_DTS := mt7981b-cudy-tr3000-512mb-v1
  DEVICE_DTS_DIR := ../dts
  DEVICE_PACKAGES := kmod-mt7981-firmware mt7981-wo-firmware
  BLOCKSIZE := 128k
  PAGESIZE := 2048
  IMAGE_SIZE := 114688k
  KERNEL_IN_UBI := 1
  IMAGES := sysupgrade.bin
  IMAGE/sysupgrade.bin := sysupgrade-tar | append-metadata
endef
TARGET_DEVICES += cudy_tr3000-512mb-v1
EOF
  fi
else
  echo "Skip 512M DTS injection for ${BUILD_DEVICE:-unknown device}"
fi
