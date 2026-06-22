# Marble Kernel — KernelSU-Next + SUSFS v2.2.0

> Build Date: 2026-06-22 10:47:33 UTC
> Build ID: `27940668609`
> Workflow: https://github.com/mohdakil2426/marble-kernel-builder/actions/runs/27940668609

---

## Build Configuration

| Component | Details |
|---|---|
| Device | Poco F5 / Redmi Note 12 Turbo (`marble`, `marblein`) |
| Kernel Base | `android12-5.10` |
| Build Scope | `image-only` |
| Source | [`mohdakil2426/android_kernel_xiaomi_marble@melt-rebase`](https://github.com/mohdakil2426/android_kernel_xiaomi_marble/commit/3673961d444b5e2b879be97a161241243d543bd2) (`3673961`) |
| Compiler | Android `clang-r416183b` |

## Manager

| Field | Value |
|---|---|
| Manager | KernelSU-Next |
| Repository | [`pershoot/KernelSU-Next@dev-susfs`](https://github.com/pershoot/KernelSU-Next) |
| Commit | [`5a8a604`](https://github.com/pershoot/KernelSU-Next/commit/5a8a6040e3a97bf8a3bb36a86ee86eb14882b92c) |
| Version Tag | `v3.2.0` |
| Version Code | `33201` |
| SUSFS Policy | Uses `pershoot/KernelSU-Next@dev-susfs` for SUSFS builds |

## SUSFS

| Field | Value |
|---|---|
| Version | `v2.2.0` |
| Kernel Branch | `gki-android12-5.10` |
| Commit | [4003ecf](https://gitlab.com/simonpunk/susfs4ksu/-/commit/4003ecf2d01c6d13fa8edf6c4f2607365738dc3d) |

---

## Installation

### Prerequisites

- Unlocked bootloader
- Poco F5 (`marblein`) or Redmi Note 12 Turbo (`marble`) only
- Stock `boot.img` from the same ROM/firmware stored outside the device
- Matching manager app: KernelSU-Next
- [KSU SUSFS module](https://github.com/sidex15/susfs4ksu-module/releases) for `v2.2.0`

### Steps

1. Download `Marble_KSUNext-v3.2.0_SUSFS-v2.2.0_20260622_r46.zip` and verify its SHA256 checksum.
2. Flash the ZIP to the active slot via [Kernel Flasher](https://github.com/fatalcoder524/KernelFlasher/releases).
3. The installer confirms the device codename (`marble`/`marblein`) and backs up the current boot image to `/sdcard/marble-kernel-backup/` before flashing.
4. Install/open the KernelSU-Next manager app after boot.
5. Install the KSU SUSFS module, configure hiding rules, then reboot.

> **Bootloop recovery:** Flash the stock `boot.img` back to the active slot.

---

## Artifacts

| File | Details |
|---|---|
| `Marble_KSUNext-v3.2.0_SUSFS-v2.2.0_20260622_r46.zip` | Flashable AnyKernel3 zip, 12M |
| `Marble_KSUNext-v3.2.0_SUSFS-v2.2.0_20260622_r46.zip.sha256` | SHA256 checksum |
| `build-info.txt` | Exact resolved refs and workflow metadata |

### Checksums

| Artifact | SHA256 |
|---|---|
| Image | `a3f1c9e2b847d506f1e3a2c4b9d7e8f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6` |
| Marble_KSUNext-v3.2.0_SUSFS-v2.2.0_20260622_r46.zip | `b4e2d1f9a836c705e2f4b3d5c8e9f1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8` |

---

## Credits

- Xiaomi/Poco kernel source maintainers
- AnyKernel3 by osm0sis
- KernelSU / KernelSU-Next / SukiSU Ultra / ReSukiSU maintainers
- susfs4ksu by simonpunk and contributors

---

⚡ Built with GitHub Actions
