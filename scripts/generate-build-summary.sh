#!/usr/bin/env bash
set -euo pipefail

source config/marble.env

KERNEL_DIR="${KERNEL_DIR:-kernel-source}"
MANAGER="${MANAGER:-none}"
ENABLE_SUSFS="${ENABLE_SUSFS:-false}"
BUILD_SCOPE="${BUILD_SCOPE:-image-only}"

release_dir="${KERNEL_DIR}/${RELEASE_DIR}"
build_info="${release_dir}/build-info.txt"
zip_env="${release_dir}/zip-name.env"
summary="${release_dir}/summary.md"

if [[ ! -f "${build_info}" || ! -f "${zip_env}" ]]; then
  echo "::error::Missing build metadata for summary generation"
  exit 1
fi

source "${zip_env}"

get_info() {
  local key="$1"
  grep -m1 "^${key}=" "${build_info}" | cut -d= -f2- || true
}

source_repo="$(get_info source_repo)"
source_ref="$(get_info source_ref)"
source_commit="$(get_info source_commit)"
workflow_run="$(get_info workflow_run)"
manager_name="$(get_info manager)"
manager_repo="$(get_info manager_repo)"
manager_ref="$(get_info manager_ref)"
manager_commit="$(get_info manager_commit)"
susfs_version="$(get_info susfs_version)"
susfs_branch="$(get_info susfs_kernel_branch)"
susfs_ref="$(get_info susfs_ref)"
susfs_commit="$(get_info susfs_commit)"
susfs_reported="$(get_info susfs_reported_version)"
zip_sha="$(sha256sum "${release_dir}/${zip_name}" | awk '{print $1}')"
image_sha="$(sha256sum "${release_dir}/Image" | awk '{print $1}')"
zip_size="$(du -h "${release_dir}/${zip_name}" | awk '{print $1}')"
build_date="$(date -u '+%Y-%m-%d %H:%M:%S UTC')"
build_id="${GITHUB_RUN_ID:-}"
if [[ -z "${build_id}" && -n "${workflow_run}" ]]; then
  build_id="${workflow_run##*/}"
fi

manager_display="${manager_name}"
case "${manager_name}" in
  none) manager_display="No manager" ;;
  kernelsu) manager_display="KernelSU" ;;
  kernelsu-next) manager_display="KernelSU-Next" ;;
  sukisu-ultra) manager_display="SukiSU Ultra" ;;
  resukisu) manager_display="ReSukiSU" ;;
esac

title_manager="${manager_display}"
if [[ "${manager_name}" == "none" ]]; then
  title_manager="No Root Manager"
fi
title_suffix=""
if [[ "${ENABLE_SUSFS}" == "true" ]]; then
  title_suffix=" & SUSFS ${susfs_reported:-${susfs_version}}"
fi

{
  echo "# Marble Kernel with ${title_manager}${title_suffix}"
  echo
  echo "> Build Date: ${build_date}"
  echo "> Build ID: \`${build_id:-unknown}\`"
  echo "> Workflow: ${workflow_run}"
  echo
  echo "---"
  echo
  echo "### Build Configuration"
  echo
  echo "| Field | Value |"
  echo "|---|---|"
  echo "| Device | Poco F5 / Redmi Note 12 Turbo (\`marble\`, \`marblein\`) |"
  echo "| Build scope | \`${BUILD_SCOPE}\` |"
  echo "| Manager | \`${manager_display}\` |"
  echo "| SUSFS enabled | \`${ENABLE_SUSFS}\` |"
  echo "| Workflow run | ${workflow_run} |"
  echo
  echo "## Supported Device"
  echo
  echo "| Device | Codename | Kernel base | Package |"
  echo "|---|---|---|---|"
  echo "| Poco F5 / Redmi Note 12 Turbo | \`marble\`, \`marblein\` | \`android12-5.10\` | AnyKernel3 flashable zip |"
  echo
  echo "### Source"
  echo
  echo "| Field | Value |"
  echo "|---|---|"
  echo "| Repository | \`${source_repo}\` |"
  echo "| Ref | \`${source_ref}\` |"
  echo "| Commit | \`${source_commit}\` |"
  echo
  echo "### Kernel Manager"
  echo
  if [[ "${manager_name}" == "none" ]]; then
    echo "No kernel manager was integrated in this build."
  else
    echo "| Field | Value |"
    echo "|---|---|"
    echo "| Repository | \`${manager_repo}\` |"
    echo "| Ref | \`${manager_ref}\` |"
    echo "| Commit | \`${manager_commit}\` |"
  fi
  echo
  echo "## Root Management"
  echo
  if [[ "${manager_name}" == "none" ]]; then
    echo "- No root manager integrated. This mode exists for baseline vanilla kernel builds and troubleshooting."
    echo "- SUSFS is not available with \`manager=none\` because SUSFS requires manager-side KernelSU-compatible hooks."
  else
    echo "- Manager: \`${manager_display}\`"
    echo "- Repository: \`${manager_repo}\`"
    echo "- Ref: \`${manager_ref}\`"
    echo "- Commit: \`${manager_commit}\`"
    if [[ "${manager_name}" == "kernelsu" ]]; then
      echo "- SUSFS policy: disabled for official KernelSU in this builder."
    elif [[ "${manager_name}" == "kernelsu-next" && "${ENABLE_SUSFS}" == "true" ]]; then
      echo "- SUSFS policy: normal KernelSU-Next builds use official \`dev\`; SUSFS builds use \`pershoot/KernelSU-Next@dev-susfs\`."
    fi
  fi
  echo
  echo "## SUSFS"
  echo
  if [[ "${ENABLE_SUSFS}" == "true" ]]; then
    echo "| Field | Value |"
    echo "|---|---|"
    echo "| Requested version | \`${susfs_version}\` |"
    echo "| Reported version | \`${susfs_reported:-unknown}\` |"
    echo "| Kernel branch | \`${susfs_branch}\` |"
    echo "| Ref | \`${susfs_ref}\` |"
    echo "| Commit | \`${susfs_commit}\` |"
  else
    echo "SUSFS was disabled for this build."
  fi
  echo
  if [[ "${ENABLE_SUSFS}" == "true" ]]; then
    echo "## SUSFS Features"
    echo
    echo "- Kernel-side SUSFS patch for \`${susfs_branch}\`."
    echo "- Manager-side SUSFS support verified through \`CONFIG_KSU_SUSFS=y\`."
    echo "- Path, mount, kstat, uname, cmdline/bootconfig, open redirect, and map hiding options are enabled by the selected manager Kconfig defaults."
    echo "- SUSFS userspace module is still required on-device to configure hiding rules."
    echo
  fi
  echo "## Manager Applications"
  echo
  echo "- KernelSU: https://github.com/tiann/KernelSU/releases"
  echo "- KernelSU-Next: https://github.com/KernelSU-Next/KernelSU-Next/releases"
  echo "- SukiSU Ultra: https://github.com/SukiSU-Ultra/SukiSU-Ultra/releases"
  echo "- ReSukiSU: https://github.com/ReSukiSU/ReSukiSU"
  echo
  echo
  echo "Use the manager app that matches the manager family recorded above. For KernelSU-Next SUSFS builds, use a KernelSU-Next compatible manager."
  echo
  echo "## Installation Instructions"
  echo
  echo "1. Download the AnyKernel3 ZIP and matching SHA256 file."
  echo "2. Flash only on Poco F5 / Redmi Note 12 Turbo variants reporting \`marble\` or \`marblein\`."
  echo "3. Keep your current ROM or firmware stock \`boot.img\` before flashing."
  echo "4. Flash the ZIP to the active slot with a trusted recovery or Kernel Flasher."
  echo "5. The installer backs up the current active boot image to \`/sdcard/marble-kernel-backup\` before writing."
  echo "6. Install/open the matching manager application if this is a root-manager build."
  echo "7. Reboot and verify root/SUSFS status before using daily."
  echo
  echo "## Recovery / Bootloop Instructions"
  echo
  echo "If the device bootloops, flash the stock \`boot.img\` from the same ROM/firmware back to the active slot. On A/B slot issues, flash the correct stock boot image to the affected slot or both slots."
  echo
  echo "### Artifacts"
  echo
  echo "| File | Details |"
  echo "|---|---|"
  echo "| \`${zip_name}\` | Flashable AnyKernel3 zip, ${zip_size} |"
  echo "| \`${zip_name}.sha256\` | SHA256 checksum file |"
  echo "| \`build-info.txt\` | Exact resolved refs and workflow metadata |"
  echo
  echo "### Checksums"
  echo
  echo "| Artifact | SHA256 |"
  echo "|---|---|"
  echo "| Image | \`${image_sha}\` |"
  echo "| ${zip_name} | \`${zip_sha}\` |"
  echo
  echo "## Changelog"
  echo
  echo "### This Release"
  echo
  echo "- Built Marble AnyKernel3 package for \`${manager_display}\`."
  if [[ "${ENABLE_SUSFS}" == "true" ]]; then
    echo "- Applied SUSFS \`${susfs_reported:-${susfs_version}}\` for \`${susfs_branch}\`."
    echo "- Verified manager-side SUSFS support and final \`CONFIG_KSU_SUSFS=y\`."
  else
    echo "- Built without SUSFS."
  fi
  echo "- Audited flashable zip structure and generated SHA256 checksums."
  echo
  echo "### Previous Releases"
  echo
  echo "See the GitHub Actions run history and repository releases."
  echo
  echo "## Credits"
  echo
  echo "- Xiaomi/Poco kernel source maintainers"
  echo "- AnyKernel3 by osm0sis"
  echo "- KernelSU / KernelSU-Next / SukiSU Ultra / ReSukiSU maintainers"
  echo "- susfs4ksu by simonpunk and related contributors"
  echo "- Reference projects documented in \`docs/research/reference-projects-analysis.md\`"
} > "${summary}"

cat "${summary}"
