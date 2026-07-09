# 360WIFI-MAC

Use legacy 360 Portable Wi-Fi USB adapters on macOS.

This repository collects historical macOS drivers and utilities for several
360 portable Wi-Fi adapter generations. These drivers are old kernel
extensions and are mainly useful for OS X 10.7 through OS X 10.11.

## Supported Devices

| Device | Common chipset | Notes |
| --- | --- | --- |
| 360 Portable Wi-Fi 1st Gen | RT5370 / RT2870 family | Use the 1st generation driver resources. |
| 360 Portable Wi-Fi 2nd Gen | MT7601 / MT7610U family | Use the 2nd generation Mediatek package. |
| XiaoDu Wi-Fi | MT7601 | May work with the same Mediatek package. |
| Xiaomi Portable Wi-Fi | RT2870 or MT7601 variant | Compatibility depends on the exact USB ID. |
| Xunlei Portable Wi-Fi | RTL8188EUS | Not covered by the bundled Ralink/Mediatek drivers. |
| Cheetah Portable Wi-Fi | RTL8192CU | Not covered by the bundled Ralink/Mediatek drivers. |

## Quick Start

Run the environment check first:

```sh
./scripts/doctor.sh
```

Install by device generation:

```sh
# 2nd generation 360 Wi-Fi
./scripts/install.sh --generation 2

# 1st generation 360 Wi-Fi
./scripts/install.sh --generation 1
```

The installer script detects your macOS version, selects the most likely
driver image, mounts it, and opens or runs the bundled installer when possible.

To only see what would be selected:

```sh
./scripts/install.sh --generation 2 --dry-run
```

## macOS Compatibility

| macOS version | 1st Gen recommendation | 2nd Gen recommendation |
| --- | --- | --- |
| OS X 10.7 - 10.9 | `10.7.X-10.9.X(1st Gen)Resources/RTUSB_D2870-4.2.9.10_UI-5.0.0.01.dmg` | Not the primary target. |
| OS X 10.10 | `10.10.X(1st Gen)Resources/360WiFI-148F-7601-760B-RT2870-MT7610U_D5.0.1.22_SDK1.0.2.14_UI5.0.0.21_20141224.dmg` | May work with bundled Mediatek packages. |
| OS X 10.11 | `10.11.X(1st Gen)Resources/BearExtender 5.4 (El Capitan Ready for chipsets RT2870 or RT3070).dmg` | `MT7612_7610U_D5.0.1.25_SDK1.0.2.18_UI5.0.0.27_20151209.dmg` |

Modern macOS releases use stricter driver signing and system extension rules.
These legacy kext installers should be treated as archival software, not as a
guaranteed solution for current macOS versions.

## SIP Notice

Some OS X 10.11 installations require System Integrity Protection to be
disabled before third-party kernel extensions can be installed.

1. Restart into Recovery by holding `Command + R`.
2. Open Terminal from the Utilities menu.
3. Run `csrutil disable`.
4. Restart macOS and install the driver.
5. After installation, consider returning to Recovery and running
   `csrutil enable`.

## Repository Layout

```text
.
├── scripts/
│   ├── doctor.sh      # macOS, SIP, USB, and installed-driver diagnostics
│   └── install.sh     # version-aware installer launcher
├── 10.7.X-10.9.X(1st Gen)Resources/
├── 10.10.X(1st Gen)Resources/
├── 10.10.X_rawDriver_RT2870(1st Gen kext&dmg)/
├── 10.11.X(1st Gen)Resources/
├── Mediatek Wireless Utility(Applaction 2nd Gen) Plugin&Use/
└── MT7612_7610U_D5.0.1.25_SDK1.0.2.18_UI5.0.0.27_20151209.dmg
```

## Useful Resources

- [Mediatek RT2870 legacy product page](https://www.mediatek.com/products/broadbandWifi/rt2870)
- [Mediatek MT7610U product page](https://www.mediatek.com/products/broadbandWifi/mt7610u)
- [Installation guide for RT2870/RT3070 on OS X 10.11](https://www.tonymacx86.com/threads/guide-installation-of-usb-wireless-antenna-chipset-rt2870-rt3070-in-mac-os-x-10-11-x-el-capitan.183175/page-2)
- [Ralink/Mediatek RT2870 driver discussion](http://www.insanelymac.com/forum/topic/299948-usb-wifi-updated-ralinkmediatek-rt2870-rt2770-rt3x7x-rt537x-rt5572/page-8)

## Maintenance

- Keep historical driver images unchanged unless replacing them with a verified
  newer upstream artifact.
- Do not commit `.DS_Store`, local mount folders, or generated logs.
- Prefer adding automation under `scripts/` instead of expanding manual
  installation steps in the README.
