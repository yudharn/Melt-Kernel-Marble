#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${repo_root}"

assert_name() {
  local expected="$1"
  shift
  local actual
  actual="$(env PACKAGE_NAME_ONLY=true GITHUB_RUN_NUMBER=9 "$@" bash scripts/package-anykernel.sh)"
  if [[ "${actual}" != "${expected}" ]]; then
    echo "FAIL: expected ${expected}, got ${actual}" >&2
    exit 1
  fi
}

assert_name \
  'AK3_Marble-HyperOS_KSUNext-v3.2.0-code33203_SUSFS-v2.2.0_r9.zip' \
  MANAGER=kernelsu-next ENABLE_SUSFS=true manager_build_version_name='v3.2.0@KernelSU-Next' \
  manager_build_version_code=33203 manager_commit=66656dd123456789 susfs_reported_version=v2.2.0

assert_name \
  'AK3_Marble-HyperOS_SukiSUUltra-v4.1.3-b88403d2-code40813_SUSFS-v2.2.0_r9.zip' \
  MANAGER=sukisu-ultra ENABLE_SUSFS=true manager_build_version_name='v4.1.3-b88403d2@HEAD' \
  manager_build_version_code=40813 manager_commit=b88403d2561b6e00 susfs_reported_version=v2.2.0

assert_name \
  'AK3_Marble-HyperOS_ReSukiSU-88e7f51-code34990_NoSUSFS_r9.zip' \
  MANAGER=resukisu ENABLE_SUSFS=false manager_version_code=34990 manager_commit=88e7f51c3840436b

assert_name \
  'AK3_Marble-HyperOS_NoRoot_NoSUSFS_r9.zip' \
  MANAGER=none ENABLE_SUSFS=false

echo "Package naming tests passed"
