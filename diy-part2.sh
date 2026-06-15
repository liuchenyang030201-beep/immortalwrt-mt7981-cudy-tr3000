#!/bin/bash
set -e

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
# 基础路径检查
# ===============================
test -f target/linux/mediatek/image/filogic.mk
test -d target/linux/mediatek/dts

# ===============================
# TR3000 512MB DTS 注入
# ===============================
rm -rf mod512
git clone --depth 1 https://github.com/zhuannn/cudy-tr3000-512 mod512

test -f mod512/openwrt-mod/cudy-tr3000-512.mk
test -n "$(find mod512 -name '*.dts' -print -quit)"

echo "========== MOD512 MK CHECK =========="
grep -E "cudy_tr3000-512mb-v1|DEVICE_DTS|IMAGE_SIZE|TARGET_DEVICES" mod512/openwrt-mod/cudy-tr3000-512.mk

# 防止重复 patch
grep -q "cudy_tr3000-512mb-v1" target/linux/mediatek/image/filogic.mk || \
cat mod512/openwrt-mod/cudy-tr3000-512.mk >> target/linux/mediatek/image/filogic.mk

# 安全复制 DTS
find mod512 -name "*.dts" -exec cp -f {} target/linux/mediatek/dts/ \;

# ===============================
# 确认 512 设备已经注册
# ===============================
grep -q "cudy_tr3000-512mb-v1" target/linux/mediatek/image/filogic.mk
ls target/linux/mediatek/dts/ | grep -q "tr3000.*512"

# ===============================
# 4G LTE 驱动
# ===============================
cat >> .config <<'EOF'

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

# ===============================
# 最终确认：必须是 512M profile
# ===============================
grep -q '^CONFIG_TARGET_mediatek_filogic_DEVICE_cudy_tr3000-512mb-v1=y' .config
grep -q '^CONFIG_TARGET_PROFILE="DEVICE_cudy_tr3000-512mb-v1"' .config
! grep -q '^CONFIG_TARGET_mediatek_filogic_DEVICE_cudy_tr3000-v1-256mb=y' .config

# ===============================
# 最终确认：4G 驱动必须启用
# ===============================
grep -q '^CONFIG_PACKAGE_kmod-usb-net=y' .config
grep -q '^CONFIG_PACKAGE_kmod-usb-net-qmi-wwan=y' .config
grep -q '^CONFIG_PACKAGE_kmod-usb-wdm=y' .config
grep -q '^CONFIG_PACKAGE_kmod-usb-serial=y' .config
grep -q '^CONFIG_PACKAGE_kmod-usb-serial-option=y' .config
grep -q '^CONFIG_PACKAGE_kmod-usb-serial-wwan=y' .config
grep -q '^CONFIG_PACKAGE_kmod-usb-net-rndis=y' .config
grep -q '^CONFIG_PACKAGE_kmod-usb-net-cdc-ether=y' .config
grep -q '^CONFIG_PACKAGE_kmod-usb-net-cdc-mbim=y' .config
grep -q '^CONFIG_PACKAGE_luci-proto-qmi=y' .config
grep -q '^CONFIG_PACKAGE_luci-proto-mbim=y' .config

# ===============================
# 打印最终确认信息
# ===============================
echo "========== FINAL TARGET CHECK =========="
grep -E 'CONFIG_TARGET_mediatek_filogic_DEVICE_cudy_tr3000|CONFIG_TARGET_PROFILE' .config

echo "========== FINAL 4G DRIVER CHECK =========="
grep -E 'CONFIG_PACKAGE_(kmod-usb-net|kmod-usb-net-qmi-wwan|kmod-usb-wdm|kmod-usb-serial|kmod-usb-serial-option|kmod-usb-serial-wwan|kmod-usb-net-rndis|kmod-usb-net-cdc-ether|kmod-usb-net-cdc-mbim|uqmi|umbim|wwan|usb-modeswitch|luci-proto-qmi|luci-proto-mbim)=y' .config

echo "OK: TR3000 512MB config + DTS + 4G drivers enabled."
