<img width="1200" height="1200" alt="image" src="https://github.com/user-attachments/assets/15feaff7-49f2-4927-888f-7ac2258ba5ff" />



# Cudy TR3000 v1 512M ImmortalWrt 自动编译

基于 GitHub Actions 的 **Cudy TR3000 v1 512M Flash 改版机** ImmortalWrt 自动编译项目。

本项目适用于已经改装为 **512M Flash** 的 Cudy TR3000 v1，支持在 GitHub Actions 中一键选择 `512M` 编译，并集成常见 4G 模块相关驱动。
修改文件以适配128 
 **128M Flash** 
修改文件以适配256
 **128M Flash**
 
刷错固件可能导致：

* 无法启动
* 配置丢失
* 需要 TTL 救砖
* 需要编程器恢复

刷机有风险，操作需谨慎，风险自负。

---

## 项目特点

* 基于 GitHub Actions 自动编译
* 支持 Cudy TR3000 v1 512M Flash 改版机
* Actions 手动运行时可选择 `512M`
* 基于 `immortalwrt-mt798x-6.6` 源码
* 新增 512M 设备配置
* 集成常见 4G 模块驱动
* 适合旁路由、OpenClash、Mihomo、4G 模块、USB 网卡等场景

---

## 源码来源

ImmortalWrt 源码：

```text
https://github.com/padavanonly/immortalwrt-mt798x-6.6
```

本项目基于以下项目整理和适配：

```text
https://github.com/weekdaycare/immortalwrt-mt7981-cudy-tr3000
https://github.com/zhuannn/cudy-tr3000-512
```

---

## 支持设备

| 项目     | 说明                   |
| ------ | -------------------- |
| 设备型号   | Cudy TR3000 v1       |
| Flash  | 512M Flash 改版机    
| Flash  | 256M Flash 机型
| Flash  | 128M Flash 机型
| Target | mediatek / filogic   |
| SoC    | MT7981               |
| 内核     | 6.6                  |
| 设备配置   | cudy_tr3000-512mb-v1 |



## 4G 模块驱动支持

本项目加入了常见 USB 4G 模块相关驱动，主要包括：

* QMI
* MBIM
* RNDIS
* CDC ECM
* CDC NCM
* USB Serial
* Option
* WWAN
* CDC WDM

适用于常见 Quectel、Fibocom、Simcom 等 USB 4G 模块。

常见设备示例：

* Quectel EC20
* Quectel EC25
* Quectel EP06
* Fibocom L850
* Fibocom L860
* 其他 USB QMI / MBIM / RNDIS 模块

具体兼容性请自行测试。

---

## 编译方法

Fork 本仓库后，进入自己的仓库页面。

打开：

```text
Actions -> Build OpenWrt -> Run workflow
```

在编译选项中选择：

```text
512M
```

然后点击运行编译。

编译完成后，可以在以下位置下载固件：

```text
Actions Artifacts
Releases
```

---

## 固件文件说明

常见固件文件说明如下：

| 文件类型           | 用途                             |
| -------------- | ------------------------------ |
| factory.bin    | 一般用于首次刷机                       |
| sysupgrade.bin | 一般用于 OpenWrt / ImmortalWrt 内升级 |
| ubootmod       | 大分区 / U-Boot Mod 版本使用          |

如果不确定应该刷哪个文件，请先确认自己的机器分区布局，不要盲刷。

---

## 主要修改内容

相对原项目，主要做了以下修改：

* 新增 `512m.config`
* GitHub Actions 新增 `512M` 编译选项
* 适配 `cudy_tr3000-512mb-v1`
* 修改 part2 以支持 512M 设备
* 增加常用 4G 模块驱动
* README 增加说明、使用方法和风险提示

---

## 目录说明

```text
.github/workflows/
  openwrt-builder.yml        GitHub Actions 编译流程

config/
  512m.config                512M Flash 改版机配置

diy-part1.sh                 编译前自定义脚本
diy-part2.sh                 编译后自定义脚本
README.md                    项目说明
```

---

## 使用建议

刷机前建议确认以下信息：

```text
1. 机器型号是否为 Cudy TR3000 v1
2. Flash 是否已经改为 512M
3. 分区布局是否与 512M 固件匹配
4. 是否有 TTL 或编程器救砖能力
5. 是否已经备份原厂固件和 ART / EEPROM / 配置分区
```

如果你不确定自己的机器是否适合，请不要直接刷入。

---

## 免责声明

本项目仅用于学习、研究和个人折腾。

固件由 GitHub Actions 自动编译生成，不保证适用于所有设备和所有使用场景。

刷机存在风险，使用本项目固件导致的设备变砖、数据丢失、无法启动、网络异常等问题，均需自行承担。

---

## 致谢

感谢以下项目和作者：

* OpenWrt
* ImmortalWrt
* padavanonly/immortalwrt-mt798x-6.6
* weekdaycare/immortalwrt-mt7981-cudy-tr3000
* zhuannn/cudy-tr3000-512

感谢各位大佬的源码、补丁、配置和折腾经验。





