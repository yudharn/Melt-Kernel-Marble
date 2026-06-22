# Verified Defaults

Checked on 2026-06-22.

| Component | Repo | Default Ref | Version / Commit |
|---|---|---|---|
| Kernel source | `Pzqqt/android_kernel_xiaomi_marble` | `melt-rebase` | Poco F5 / marble source |
| Android kernel Clang | `https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86` | `master-kernel-build-2021` | `clang-r416183b`, matching `build.config.common` |
| SUSFS | `https://gitlab.com/simonpunk/susfs4ksu.git` | `gki-android12-5.10` | `SUSFS_VERSION v2.2.0`, commit `aee962343bc49469a5427a0e6987e6a70fe88ba3` |
| SUSFS older preset | `https://gitlab.com/simonpunk/susfs4ksu.git` | commit `86114db0c49f20fa7857b8b559f3ab87cbc2d00d` | `SUSFS_VERSION v2.1.0`; WildKernels GKI r4 gki-android12-5.10 pin |
| KernelSU | `tiann/KernelSU` | `main` | Official source; non-SUSFS builds only |
| KernelSU-Next | `KernelSU-Next/KernelSU-Next` | `dev` | Official non-SUSFS ref |
| KernelSU-Next + SUSFS | `KernelSU-Next/KernelSU-Next` | `legacy-susfs` | Official branch with manager-side SUSFS support for the legacy GKI path |
| SukiSU Ultra | `SukiSU-Ultra/SukiSU-Ultra` | `main` | Official non-SUSFS ref |
| SukiSU Ultra + SUSFS | `SukiSU-Ultra/SukiSU-Ultra` | `builtin` | Official branch with manager-side SUSFS support |
| ReSukiSU | `ReSukiSU/ReSukiSU` | `main` | Official branch with manager-side SUSFS support |

The workflow resolves branch, tag, and commit inputs to exact commits at run time and records them in `release/build-info.txt`. For SUSFS, the user chooses `susfs_version=v2.2.0`, `susfs_version=v2.1.0`, or `susfs_version=custom`. Custom mode uses `susfs_ref` and verifies `susfs_expected_version` when provided.

Manager repositories are allowlisted to official upstreams. When SUSFS is enabled, the workflow automatically selects the manager's official SUSFS-integrated ref, applies only the kernel-side SUSFS patch/files, and verifies the final Kconfig values. Official KernelSU + SUSFS is rejected because current official KernelSU refs do not accept the upstream generic manager patch; a failed or partially applied patch is not treated as support.
