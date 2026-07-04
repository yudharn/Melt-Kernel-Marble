<div align="center">

# 🪨 Melt Rebase Marble Kernel Builder

**CI-driven AnyKernel3 kernel builder for Poco F5 / Redmi Note 12 Turbo**

[![Build](https://img.shields.io/badge/GitHub_Actions-CI_Builder-2088FF?logo=githubactions&logoColor=white)](https://github.com/mohdakil2426/marble-kernel-builder/actions)
[![KernelSU](https://img.shields.io/badge/KernelSU-Supported-4CAF50?logo=linux&logoColor=white)](https://github.com/tiann/KernelSU)
[![KernelSU-Next](https://img.shields.io/badge/KernelSU--Next-Supported-4CAF50?logo=linux&logoColor=white)](https://github.com/KernelSU-Next/KernelSU-Next)
[![SukiSU Ultra](https://img.shields.io/badge/SukiSU_Ultra-Supported-4CAF50?logo=linux&logoColor=white)](https://github.com/SukiSU-Ultra/SukiSU-Ultra)
[![ReSukiSU](https://img.shields.io/badge/ReSukiSU-Supported-4CAF50?logo=linux&logoColor=white)](https://github.com/ReSukiSU/ReSukiSU)
[![SUSFS](https://img.shields.io/badge/SUSFS-v2.2.0-FF6D00?logo=gitlab&logoColor=white)](https://gitlab.com/simonpunk/susfs4ksu)
[![Device](https://img.shields.io/badge/Device-Poco_F5_%2F_Redmi_Note_12_Turbo-EF5350)](https://github.com/mohdakil2426/android_kernel_xiaomi_marble)
[![ROM](https://img.shields.io/badge/ROM-Stock_HyperOS_Only-FF6900)](https://www.mi.com/global/hyperos/)

</div>

---

## ⚠️ Disclaimer

> Flashing a custom kernel always carries a risk of bootloop or data loss. This builder is experimental — artifacts are provided as-is.
>
> - 💾 **Always back up your `boot.img`** from the same ROM/firmware before flashing
> - 🧠 **Understand what you are flashing** — read this README fully
> - 🔓 Unlocked bootloader is required
> - 📱 **Poco F5 (`marblein`) and Redmi Note 12 Turbo (`marble`) only**
> - 🟠 **Official Xiaomi stock HyperOS only** — MIUI, AOSP, and custom ROMs are unsupported
>
> By flashing these artifacts **you accept all risk**. The maintainer is not responsible for bricked devices or data loss.

<div align="center">

### 🚨 Proceed at your own risk!

</div>

---

## 📖 Repository Model

This project uses a **two-repo separation** to keep the kernel source fork clean:

| Repo | Purpose |
|---|---|
| [`mohdakil2426/android_kernel_xiaomi_marble`](https://github.com/mohdakil2426/android_kernel_xiaomi_marble) | Clean upstream kernel source fork — never patched locally |
| [`mohdakil2426/marble-kernel-builder`](https://github.com/mohdakil2426/marble-kernel-builder) | This repo — CI workflows, scripts, config, and docs |

GitHub Actions checks out both repos separately, applies manager and SUSFS patches **only inside the temporary CI workspace**, builds, packages, and uploads artifacts. The source fork remains permanently clean.

---

## 🤖 Manager Matrix

| Manager | Without SUSFS | With SUSFS | Notes |
|---|:---:|:---:|---|
| `none` | ✅ | ❌ | Baseline no-root build only |
| `kernelsu` | ✅ | ❌ | Official only; no compatible SUSFS integration yet |
| `kernelsu-next` | ✅ | ✅ | Non-SUSFS → official `dev`; SUSFS → `pershoot/dev-susfs` |
| `sukisu-ultra` | ✅ | ✅ | Non-SUSFS → `main`; SUSFS → official `builtin` |
| `resukisu` | ✅ | ✅ | `main` includes built-in manager-side SUSFS support |

> **Policy:** Only official upstream manager repositories are used. Custom or forked manager repositories are rejected by the allowlist enforced at CI time. The one exception is `pershoot/KernelSU-Next@dev-susfs` for KernelSU-Next + SUSFS builds, which is a CI-proven fork branch carrying SUSFS integration based on the official `dev` branch.

---

## ⚙️ Workflows

Two workflows are available. `build-matrix.yml` is the only public build and draft-release entrypoint: select one manager for one build or several managers for a parallel matrix build.

| Workflow | Use when |
|---|---|
| **Build Marble Kernel** (`build-matrix.yml`) | Select one or many managers; each gets a separate artifact, one combined summary, and optionally one draft release |
| **Marble Builder Preflight** (`preflight.yml`) | Cheap static checks for workflows, shell scripts, policy tests, actionlint, and shellcheck |

### `build-matrix.yml` Inputs

| Input | Default | Description |
|---|---|---|
| `build_none` | `false` | Build baseline no-root kernel |
| `build_kernelsu` | `false` | Build KernelSU (no SUSFS) |
| `build_kernelsu_next` | `false` | Build KernelSU-Next |
| `build_sukisu_ultra` | `false` | Build SukiSU Ultra |
| `build_resukisu` | `false` | Build ReSukiSU |
| `enable_susfs` | `false` | Enable SUSFS for all managers that support it |
| `susfs_version` | `v2.2.0` | SUSFS preset version |
| `susfs_ref` | *(empty)* | SUSFS branch/tag/commit, used only with the custom preset |
| `source_repo` | `mohdakil2426/android_kernel_xiaomi_marble` | Kernel source repository |
| `source_ref` | `melt-rebase` | Kernel source branch, tag, or commit |
| `build_scope` | `image-only` | `image-only` or `full` |
| `enable_ccache` | `true` | Use ccache to accelerate compatible rebuilds |
| `create_draft_release` | `false` | If enabled, create one ZIP-only draft release after all selected builds and the combined summary pass |

### Create a draft release

1. Open **Actions → Build Marble Kernel → Run workflow**.
2. Select the manager checkboxes and normal build inputs.
3. Enable `create_draft_release` only when you want a draft release from that same successful run.
4. The release job waits for all selected builds and the combined summary to pass, downloads the same run's manager artifacts, verifies every checksum, and creates one draft release.
5. Review the draft on the Releases page and publish it manually when ready.

This flow does not use a GitHub Environment approval, so GitHub does not create Deployment records for release approval. The manual checkbox is the release gate, and the release remains a draft until it is manually published. Draft release assets contain only clean flashable ZIPs; checksums and build metadata remain in Actions artifacts and are used internally for verification.

---

## 📦 Artifact Layout

### ✅ Successful build artifact

```
marble-flash-<label>-<scope>-r<run>/
├─ AK3_Marble-HyperOS_<Manager>-<version>-code<code>_<SUSFS>_r<run>.zip
├─ AK3_Marble-HyperOS_<Manager>-<version>-code<code>_<SUSFS>_r<run>.zip.sha256
├─ build-info.txt      ← exact resolved refs and workflow metadata
├─ build-info.json     ← structured metadata for tooling and future summaries
├─ summary.md          ← build summary (also used for release notes)
├─ zip-audit.txt       ← structure audit results
└─ ccache-stats.txt
```

Examples:
```
AK3_Marble-HyperOS_KSUNext-v3.2.0-code33203_SUSFS-v2.2.0_r9.zip
AK3_Marble-HyperOS_SukiSUUltra-v4.1.3-code40813_SUSFS-v2.2.0_r9.zip
AK3_Marble-HyperOS_ReSukiSU-v4.1.0-code34990_SUSFS-v2.2.0_r9.zip
AK3_Marble-HyperOS_KernelSU-v1.0.3-code12345_NoSUSFS_r9.zip
AK3_Marble-HyperOS_NoRoot_NoSUSFS_r9.zip
```

> The manager build version and numeric code are preferred. Missing metadata falls back to the resolved tag and then a 7-character manager commit.

## 🔒 Verified Defaults

Last verified: **2026-06-23**

| Component | Default Ref | Pinned Commit / Version |
|---|---|---|
| SUSFS (v2.2.0) | `gki-android12-5.10` | `4003ecf2d01c6d13fa8edf6c4f2607365738dc3d` |
| SUSFS (v2.1.0) | `gki-android12-5.10` | `86114db0c49f20fa7857b8b559f3ab87cbc2d00d` |
| KernelSU | `tiann/KernelSU@main` | SUSFS disabled (no compatible official integration) |
| KernelSU-Next (no SUSFS) | `KernelSU-Next/KernelSU-Next@dev` | Official |
| KernelSU-Next (+ SUSFS) | `pershoot/KernelSU-Next@dev-susfs` | CI-proven |
| SukiSU Ultra | `SukiSU-Ultra/SukiSU-Ultra@main` / `builtin` | Official |
| ReSukiSU | `ReSukiSU/ReSukiSU@main` | Built-in SUSFS support |
| Android kernel Clang | `clang-r416183b` | Declared by `build.config.common` |
| Android Clang source | `master-kernel-build-2021` | `6e3223f76384455acde43affde3df0ea9df66c0d` |
| AnyKernel3 | pinned commit | `dca9dc370838d919d56c1f59ec78b27a14a72c68` |

---

## CI Reliability and Performance

- Official GitHub actions are pinned to immutable commits and checked weekly by Dependabot.
- Android Clang is fetched from the official Git repository using a partial clone plus sparse checkout, then verified against its pinned commit before use.
- Ccache is capped at 2 GiB per build identity and keyed by compiler, source, manager, SUSFS, scope, and build configuration; compiler validation uses content checks.
- Matrix policy tests run once before fan-out. Disk cleanup runs only when available space is below 20 GiB.
- Flash artifacts use zero recompression with 30-day retention.
- Build jobs have read-only repository permission for contents. Artifact provenance attestations use GitHub's OIDC-backed attestation permission on the final ZIP.
- Release write permission exists only in the conditional `build-matrix.yml` release job, which runs when `create_draft_release` is enabled and all selected builds pass. Build jobs stay read-only.
- Duplicate manual dispatches are guarded with workflow concurrency groups to avoid piling up accidental repeated runs.

Previous verification on **2026-06-24**: [three-manager matrix run 28081895022](https://github.com/mohdakil2426/marble-kernel-builder/actions/runs/28081895022) and [protected promotion run 28082454769](https://github.com/mohdakil2426/marble-kernel-builder/actions/runs/28082454769) passed on commit `28f3830`. All downloaded ZIP checksums matched, and draft `marble-hyperos-r10` contains only the three clean flashable ZIPs. The current release flow now creates the ZIP-only draft directly from the successful matrix run when `create_draft_release` is enabled.

---

## 🧪 Safe Build Order

Run these in order — verify each before proceeding to the next:

1. Select only `build_none` with SUSFS disabled and `image-only` scope.
2. Repeat `build_none` with `full` scope if full outputs are required.
3. Select one root manager at a time with SUSFS disabled.
4. Select `build_kernelsu_next`, `build_sukisu_ultra`, and/or `build_resukisu` with SUSFS enabled.
5. Once verified, combine the desired managers in one matrix run. Enable `create_draft_release` if that successful run should also create a draft release.

---

## 🚀 Flashing Instructions

### Prerequisites

- Unlocked bootloader
- Poco F5 (`marblein`) or Redmi Note 12 Turbo (`marble`) only
- Official Xiaomi stock HyperOS only; MIUI, AOSP, and custom ROMs are unsupported
- Stock `boot.img` from the **same ROM/firmware** stored somewhere safe (outside the device)
- Matching manager app for root builds

### Via Kernel Flasher *(recommended)*

1. Download the flashable `.zip`
2. Verify it against the SHA256 shown in the build or release summary
3. Flash the ZIP to the active slot using [Kernel Flasher](https://github.com/fatalcoder524/KernelFlasher/releases)
4. The AnyKernel3 installer will verify the device codename (`marble` / `marblein`) and **automatically back up the current boot image** to `/sdcard/marble-kernel-backup/` before writing
5. Install the matching manager app after boot
6. If SUSFS is enabled, install the [KSU SUSFS module](https://github.com/sidex15/susfs4ksu-module/releases) and configure hiding rules

### Recovery from bootloop

Flash the stock `boot.img` from the same ROM/firmware back to the active slot. On A/B slot devices, target the correct slot or flash both.

---

## 🔗 Related Resources

| Resource | Link |
|---|---|
| 📱 Kernel Source Fork | [mohdakil2426/android_kernel_xiaomi_marble](https://github.com/mohdakil2426/android_kernel_xiaomi_marble) |
| 🏗️ Upstream Source | [Pzqqt/android_kernel_xiaomi_marble](https://github.com/Pzqqt/android_kernel_xiaomi_marble) |
| 🫙 AnyKernel3 | [osm0sis/AnyKernel3](https://github.com/osm0sis/AnyKernel3) |
| 🔑 KernelSU | [tiann/KernelSU](https://github.com/tiann/KernelSU) |
| 🔑 KernelSU-Next | [KernelSU-Next/KernelSU-Next](https://github.com/KernelSU-Next/KernelSU-Next) |
| 🔑 SukiSU Ultra | [SukiSU-Ultra/SukiSU-Ultra](https://github.com/SukiSU-Ultra/SukiSU-Ultra) |
| 🔑 ReSukiSU | [ReSukiSU/ReSukiSU](https://github.com/ReSukiSU/ReSukiSU) |
| 🛡️ SUSFS | [simonpunk/susfs4ksu](https://gitlab.com/simonpunk/susfs4ksu) |
| ⚡ Kernel Flasher | [fatalcoder524/KernelFlasher](https://github.com/fatalcoder524/KernelFlasher) |
| 📦 SUSFS Module | [sidex15/susfs4ksu-module](https://github.com/sidex15/susfs4ksu-module) |

---

## 🙏 Credits

- **Pzqqt** — upstream Marble kernel source and maintenance
- **osm0sis** — AnyKernel3 flashing framework
- **tiann** — KernelSU
- **KernelSU-Next team** — KernelSU-Next
- **SukiSU Ultra team** — SukiSU Ultra
- **ReSukiSU team** — ReSukiSU
- **simonpunk** — susfs4ksu patches
- **WildKernels** — reference CI and release patterns
- Xiaomi/MIUI kernel source maintainers

---

<div align="center">

⚡ Built with ❤️ using GitHub Actions

</div>
