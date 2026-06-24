#!/bin/bash

set -euo pipefail

WORKSPACE="${GITHUB_WORKSPACE:-$(pwd)}"
CONFIG_FILE="${CONFIG_FILE:-config/tr3000-512mb-v1-immortal.config}"
ROOT_PASSWORD_HASH='$1$tr3000$/RT6J1mD4MlJPWZiM/LBS.'

install_zhuannn_board() {
  cat "$WORKSPACE/openwrt-mod/cudy-tr3000-512.mk" >> target/linux/mediatek/image/filogic.mk
  install -D -m 0644 \
    "$WORKSPACE/openwrt-mod/mt7981b-cudy-tr3000-512mb-v1.dts" \
    target/linux/mediatek/dts/mt7981b-cudy-tr3000-512mb-v1.dts
}

install_default_files() {
  mkdir -p files/etc/config files/etc/sysctl.d files/etc/uci-defaults

  if [ -f package/base-files/files/etc/shadow ]; then
    sed -i "s|^root:[^:]*:|root:${ROOT_PASSWORD_HASH}:|" package/base-files/files/etc/shadow
  fi

  cat > files/etc/config/network <<'EOF'
config interface 'loopback'
	option device 'lo'
	option proto 'static'
	option ipaddr '127.0.0.1'
	option netmask '255.0.0.0'

config globals 'globals'
	option packet_steering '1'

config interface 'lan'
	option device 'eth1'
	option proto 'static'
	option ipaddr '192.168.2.1'
	option netmask '255.255.255.0'
	option ip6assign '60'

config interface 'wan'
	option device 'eth0'
	option proto 'dhcp'

config interface 'wan6'
	option device 'eth0'
	option proto 'dhcpv6'
EOF

  cat > files/etc/config/dropbear <<'EOF'
config dropbear main
	option enable '1'
	option PasswordAuth 'on'
	option RootPasswordAuth 'on'
	option Port '22'
EOF

  cat > files/etc/sysctl.d/99-tr3000-tcp-tune.conf <<'EOF'
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.ipv4.tcp_rmem=4096 87380 16777216
net.ipv4.tcp_wmem=4096 65536 16777216
net.ipv4.tcp_slow_start_after_idle=0
net.ipv4.tcp_mtu_probing=1
net.core.netdev_max_backlog=16384
net.core.netdev_budget=600
EOF

  cat > files/etc/uci-defaults/99-tr3000-defaults <<'EOF'
#!/bin/sh
uci -q batch <<'UCI'
set system.@system[0].hostname='CudyX'
set system.@system[0].zonename='Asia/Shanghai'
set system.@system[0].timezone='CST-8'
set network.lan.device='eth1'
set network.lan.proto='static'
set network.lan.ipaddr='192.168.2.1'
set network.lan.netmask='255.255.255.0'
set network.wan.device='eth0'
set network.wan.proto='dhcp'
set network.wan6.device='eth0'
set network.wan6.proto='dhcpv6'
set dhcp.lan='dhcp'
set dhcp.lan.interface='lan'
set dhcp.lan.start='100'
set dhcp.lan.limit='150'
set dhcp.lan.leasetime='12h'
set dhcp.lan.ignore='0'
delete dhcp.wan
set dropbear.main='dropbear'
set dropbear.main.enable='1'
set dropbear.main.PasswordAuth='on'
set dropbear.main.RootPasswordAuth='on'
set dropbear.main.Port='22'
UCI
uci -q commit system
uci -q commit network
uci -q commit dhcp
uci -q commit dropbear

for svc in openclash passwall daed; do
	if [ -x "/etc/init.d/$svc" ]; then
		"/etc/init.d/$svc" disable >/dev/null 2>&1 || true
	fi
done

wifi config >/dev/null 2>&1 || true
if [ -f /etc/config/wireless ]; then
	for radio in $(uci -q show wireless | sed -n "s/^wireless\\.\\([^.=]*\\)=wifi-device$/\\1/p"); do
		uci -q set wireless.$radio.disabled='0'
	done

	idx=0
	for radio in $(uci -q show wireless | sed -n "s/^wireless\\.\\([^.=]*\\)=wifi-device$/\\1/p"); do
		iface=""
		for section in $(uci -q show wireless | sed -n "s/^wireless\\.\\([^.=]*\\)=wifi-iface$/\\1/p"); do
			if [ "$(uci -q get wireless.$section.device)" = "$radio" ]; then
				iface="$section"
				break
			fi
		done

		if [ -z "$iface" ]; then
			iface="$(uci -q add wireless wifi-iface)"
			uci -q set wireless.$iface.device="$radio"
		fi

		uci -q set wireless.$iface.mode='ap'
		uci -q set wireless.$iface.network='lan'
		uci -q set wireless.$iface.ssid='CudyX-Setup'
		uci -q set wireless.$iface.encryption='psk2'
		uci -q set wireless.$iface.key='password'
		uci -q set wireless.$iface.disabled='0'
		idx=$((idx + 1))
	done
	uci -q commit wireless
fi
exit 0
EOF

  chmod +x files/etc/uci-defaults/99-tr3000-defaults
}

merge_config() {
  if [ ! -f "$WORKSPACE/$CONFIG_FILE" ]; then
    echo "ERROR: config file not found: $WORKSPACE/$CONFIG_FILE" >&2
    exit 1
  fi

  cp -f "$WORKSPACE/$CONFIG_FILE" .config
}

install_zhuannn_board
install_default_files
merge_config
