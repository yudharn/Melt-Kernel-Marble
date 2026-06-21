#!/usr/bin/env bash
set -euo pipefail

source config/marble.env

MANAGER="${MANAGER:-none}"
MANAGER_REF="${MANAGER_REF:-}"
CUSTOM_MANAGER_REPO="${CUSTOM_MANAGER_REPO:-}"
CUSTOM_MANAGER_REF="${CUSTOM_MANAGER_REF:-}"
CUSTOM_SETUP_PATH="${CUSTOM_SETUP_PATH:-kernel/setup.sh}"
ENABLE_SUSFS="${ENABLE_SUSFS:-false}"
SUSFS_VERSION="${SUSFS_VERSION:-${SUSFS_VERSION_DEFAULT}}"
SUSFS_KERNEL_BRANCH="${SUSFS_KERNEL_BRANCH:-${SUSFS_KERNEL_BRANCH_DEFAULT}}"
SUSFS_REF="${SUSFS_REF:-}"
SUSFS_EXPECTED_VERSION="${SUSFS_EXPECTED_VERSION:-}"
KERNEL_DIR="${KERNEL_DIR:-kernel-source}"

mkdir -p release

source_commit="$(git -C "${KERNEL_DIR}" rev-parse HEAD)"
manager_repo=""
manager_effective_ref=""
manager_commit=""
manager_setup_path=""
susfs_effective_ref=""
susfs_commit=""
susfs_reported_version=""

if [[ "${MANAGER}" != "none" ]]; then
  if [[ "${MANAGER}" == "custom" ]]; then
    manager_repo="${CUSTOM_MANAGER_REPO}"
    manager_effective_ref="${CUSTOM_MANAGER_REF}"
    manager_setup_path="${CUSTOM_SETUP_PATH}"
  else
    manager_repo="$(jq -r --arg manager "${MANAGER}" '.[$manager].repo' config/managers.json)"
    manager_effective_ref="${MANAGER_REF:-$(jq -r --arg manager "${MANAGER}" '.[$manager].default_ref' config/managers.json)}"
    manager_setup_path="$(jq -r --arg manager "${MANAGER}" '.[$manager].setup_path' config/managers.json)"
  fi
  manager_commit="$(gh api "repos/${manager_repo}/commits/${manager_effective_ref}" --jq .sha)"
fi

if [[ "${ENABLE_SUSFS}" == "true" ]]; then
  if [[ "${SUSFS_VERSION}" == "custom" ]]; then
    susfs_effective_ref="${SUSFS_REF}"
  else
    susfs_effective_ref="$(jq -r --arg branch "${SUSFS_KERNEL_BRANCH}" --arg version "${SUSFS_VERSION}" '.[$branch][$version].ref // empty' config/susfs-refs.json)"
    if [[ -z "${susfs_effective_ref}" ]]; then
      echo "::error::No SUSFS preset for ${SUSFS_KERNEL_BRANCH} ${SUSFS_VERSION}"
      exit 1
    fi
  fi

  tmp_susfs="$(mktemp -d)"
  git clone --filter=blob:none --no-checkout "${SUSFS_REPO}" "${tmp_susfs}"
  git -C "${tmp_susfs}" checkout "${susfs_effective_ref}"
  susfs_commit="$(git -C "${tmp_susfs}" rev-parse HEAD)"
  susfs_reported_version="$(grep -RhoE 'SUSFS_VERSION[[:space:]]+"v[0-9]+\.[0-9]+\.[0-9]+"' "${tmp_susfs}"/kernel_patches/include/linux/susfs.h "${tmp_susfs}"/kernel_patches/*/include/linux/susfs.h 2>/dev/null | head -n1 | sed -E 's/.*"(v[^"]+)".*/\1/')"
  rm -rf "${tmp_susfs}"

  expected="${SUSFS_EXPECTED_VERSION}"
  if [[ -z "${expected}" && "${SUSFS_VERSION}" != "custom" ]]; then
    expected="${SUSFS_VERSION}"
  fi
  if [[ -n "${expected}" && "${susfs_reported_version}" != "${expected}" ]]; then
    echo "::error::SUSFS version mismatch. Expected ${expected}, got ${susfs_reported_version:-unknown}"
    exit 1
  fi
fi

{
  echo "source_commit=${source_commit}"
  echo "manager=${MANAGER}"
  echo "manager_repo=${manager_repo}"
  echo "manager_ref=${manager_effective_ref}"
  echo "manager_commit=${manager_commit}"
  echo "manager_setup_path=${manager_setup_path}"
  echo "enable_susfs=${ENABLE_SUSFS}"
  echo "susfs_version=${SUSFS_VERSION}"
  echo "susfs_kernel_branch=${SUSFS_KERNEL_BRANCH}"
  echo "susfs_ref=${susfs_effective_ref}"
  echo "susfs_commit=${susfs_commit}"
  echo "susfs_reported_version=${susfs_reported_version}"
} | tee release/resolved-refs.env
