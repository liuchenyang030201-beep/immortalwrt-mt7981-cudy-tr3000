#!/bin/bash

# ===============================
# Rust workaround（CI兼容）
# ===============================
sed -i 's/ci-llvm=true/ci-llvm=false/g' feeds/packages/lang/rust/Makefile

# ===============================
# 编译日期（文件名区分）
# ===============================
sed -i -e '/^IMG_PREFIX:=/i BUILD_DATE := $(shell date +%Y%m%d)' \
       -e '/^IMG_PREFIX:=/ s/\($(SUBTARGET)\)/\1-$(BUILD_DATE)/' \
       include/image.mk

# ===============================
# TR3000 512MB DTS（核心）
# ===============================
git clone --depth 1 https://github.com/zhuannn/cudy-tr3000-512 mod512

# 防止重复 patch
grep -q "cudy_tr3000-512mb-v1" target/linux/mediatek/image/filogic.mk || \
cat mod512/openwrt-mod/cudy-tr3000-512.mk >> target/linux/mediatek/image/filogic.mk

# 安全复制 DTS（不依赖文件名）
find mod512 -name "*.dts" -exec cp -f {} target/linux/mediatek/dts/ \;

# ===============================
# 强制从 256M profile 切换到 512M profile
# ===============================
sed -i \
  -e 's/^CONFIG_TARGET_mediatek_filogic_DEVICE_cudy_tr3000-v1-256mb=y/# CONFIG_TARGET_mediatek_filogic_DEVICE_cudy_tr3000-v1-256mb is not set/' \
  -e 's/^CONFIG_TARGET_PROFILE="DEVICE_cudy_tr3000-v1-256mb"/CONFIG_TARGET_PROFILE="DEVICE_cudy_tr3000-512mb-v1"/' \
  .config

# ===============================
# 512M profile + 4G LTE 驱动
# ===============================
cat >> .config <<'EOF'

CONFIG_TARGET_mediatek_filogic_DEVICE_cudy_tr3000-512mb-v1=y

CONFIG_PACKAGE_kmod-usb-net=y
CONFIG_PACKAGE_kmod-usb-net-qmi-wwan=y
CONFIG_PACKAGE_kmod-usb-wdm=y

CONFIG_PACKAGE_kmod-usb-serial=y
CONFIG_PACKAGE_kmod-usb-serial-option=y
CONFIG_PACKAGE_kmod-usb-serial-wwan=y

CONFIG_PACKAGE_kmod-usb-net-rndis=y
CONFIG_PACKAGE_kmod-usb-net-cdc-ether=y
CONFIG_PACKAGE_kmod-usb-net-cdc-mbim=y

CONFIG_PACKAGE_uqmi=y
CONFIG_PACKAGE_umbim=y
CONFIG_PACKAGE_wwan=y
CONFIG_PACKAGE_usb-modeswitch=y

CONFIG_PACKAGE_luci-proto-qmi=y
CONFIG_PACKAGE_luci-proto-mbim=y

EOF

# ===============================
# 强制生效配置
# ===============================
make defconfig
make oldconfig
