# TR3000 512M ImmortalWrt Builder

This builder follows zhuannn/cudy-tr3000-512 for the Cudy TR3000 v1 512M flash layout.

Included in config:
- LuCI and package manager
- iStore app
- OpenClash
- PassWall
- daed with kernel BTF/eBPF support
- BBR TCP congestion control, fq scheduler, tc-full and iperf3
- 4G/5G modem drivers: QMI, MBIM, NCM, ModemManager, MHI, QRTR, USB serial/network modules

Build output target:
- `immortalwrt-mediatek-filogic-cudy_tr3000-512mb-v1-squashfs-sysupgrade.bin`

Use the sysupgrade `.bin` for normal U-Boot web flashing for this 512M layout.

Notes:
- OpenClash, PassWall and daed are all included, but only run one proxy service at a time to avoid DNS/firewall conflicts.
- daed needs BPF/BTF kernel support, so this build enables integrated kernel BTF instead of relying on a separate `vmlinux-btf` package.
- The workflow replaces the default 24.10 Go feed with Go 1.26 for daed's current build flags.
- OpenClash may still need its Meta core downloaded from the OpenClash page after first boot.
