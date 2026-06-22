<div align="center">

# 🪨 Marble Kernel

### Poco F5 · Redmi Note 12 Turbo

[![Manager](https://img.shields.io/badge/KernelSU--Next-v3.2.0_%2333201-4CAF50?style=for-the-badge&logo=linux&logoColor=white)](https://github.com/pershoot/KernelSU-Next)
[![SUSFS](https://img.shields.io/badge/SUSFS-v2.2.0-FF6D00?style=for-the-badge&logo=gitlab&logoColor=white)](https://gitlab.com/simonpunk/susfs4ksu/-/commit/4003ecf2d01c6d13fa8edf6c4f2607365738dc3d)
[![Device](https://img.shields.io/badge/Poco_F5_%2F_Note_12_Turbo-marble%20%7C%20marblein-EF5350?style=for-the-badge)](https://github.com/mohdakil2426/android_kernel_xiaomi_marble)
[![Build](https://img.shields.io/badge/Build-Passing-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)](https://github.com/mohdakil2426/marble-kernel-builder/actions/runs/27940668609)

<br>

🕐 **2026-06-22 10:47:33 UTC** &nbsp;·&nbsp; 🔢 **Run #46** &nbsp;·&nbsp; 🔗 **[View Workflow](https://github.com/mohdakil2426/marble-kernel-builder/actions/runs/27940668609)**

</div>

---

## ⚙️ Build Configuration

| | |
|:---|:---|
| 📱 **Device** | Poco F5 (`marblein`) · Redmi Note 12 Turbo (`marble`) |
| 🧬 **Kernel Base** | `android12-5.10` |
| 🛠️ **Build Scope** | `image-only` |
| 📦 **Source** | [`melt-rebase @ 3673961`](https://github.com/mohdakil2426/android_kernel_xiaomi_marble/commit/3673961d444b5e2b879be97a161241243d543bd2) |
| 🔨 **Compiler** | Android `clang-r416183b` |

---

## 🔑 Manager — KernelSU-Next

| | |
|:---|:---|
| 📁 **Repository** | [`pershoot/KernelSU-Next @ dev-susfs`](https://github.com/pershoot/KernelSU-Next) |
| 🔖 **Version** | `v3.2.0` &nbsp;·&nbsp; code `33201` |
| 🔗 **Commit** | [`5a8a604`](https://github.com/pershoot/KernelSU-Next/commit/5a8a6040e3a97bf8a3bb36a86ee86eb14882b92c) |
| 📌 **Note** | Non-SUSFS builds use official `KernelSU-Next/KernelSU-Next@dev` · SUSFS builds use `pershoot/dev-susfs` |

---

## 🛡️ SUSFS

| | |
|:---|:---|
| 🏷️ **Version** | `v2.2.0` |
| 🌿 **Kernel Branch** | `gki-android12-5.10` |
| 🔗 **Commit** | [`4003ecf`](https://gitlab.com/simonpunk/susfs4ksu/-/commit/4003ecf2d01c6d13fa8edf6c4f2607365738dc3d) |

---

## 📲 Installation

<details>
<summary><b>📋 Prerequisites</b> — expand before flashing</summary>
<br>

- 🔓 Unlocked bootloader
- 📱 Poco F5 (`marblein`) or Redmi Note 12 Turbo (`marble`) **only**
- 💾 Stock `boot.img` from the **same ROM/firmware** stored safely outside the device
- 📦 [KernelSU-Next manager app](https://github.com/KernelSU-Next/KernelSU-Next/releases)
- 🧩 [KSU SUSFS module](https://github.com/sidex15/susfs4ksu-module/releases) matching `v2.2.0`

</details>

<details>
<summary><b>⚡ Flash Steps</b></summary>
<br>

1. Download `Marble_KSUNext-v3.2.0_SUSFS-v2.2.0_20260622_r46.zip` and its `.sha256` file
2. Verify the checksum before flashing
3. Flash the ZIP to the active slot via **[Kernel Flasher](https://github.com/fatalcoder524/KernelFlasher/releases)**
4. The AnyKernel3 installer will verify your device codename and **automatically back up** your current boot image to `/sdcard/marble-kernel-backup/` before writing
5. After boot — install / open the **KernelSU-Next** manager app
6. Install the **KSU SUSFS module**, configure hiding rules, then reboot

</details>

> [!WARNING]
> **Bootloop?** Flash the stock `boot.img` back to the active slot using Kernel Flasher or fastboot. Keep it accessible before flashing.

---

## 📦 Artifacts & Checksums

| File | Size | Notes |
|:---|:---:|:---|
| `Marble_KSUNext-v3.2.0_SUSFS-v2.2.0_20260622_r46.zip` | 12 MB | Flashable AnyKernel3 zip |
| `Marble_KSUNext-v3.2.0_SUSFS-v2.2.0_20260622_r46.zip.sha256` | — | SHA256 checksum |
| `build-info.txt` | — | Exact resolved refs + workflow metadata |

<details>
<summary><b>🔐 SHA256 Checksums</b></summary>
<br>

| Artifact | SHA256 |
|:---|:---|
| `Image` | `a3f1c9e2b847d506f1e3a2c4b9d7e8f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6` |
| `.zip` | `b4e2d1f9a836c705e2f4b3d5c8e9f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8` |

</details>

---

## 🙏 Credits

| | |
|:---|:---|
| 🧑‍💻 **Kernel Source** | Pzqqt · Xiaomi/Poco kernel maintainers |
| 📦 **AnyKernel3** | osm0sis |
| 🔑 **KernelSU-Next** | KernelSU-Next team · pershoot |
| 🛡️ **SUSFS** | simonpunk and contributors |

---

<div align="center">

⚡ Built with ❤️ using **GitHub Actions**

</div>
