#!/usr/bin/env bash
set -euo pipefail

MANAGER="${MANAGER:-none}"
KERNEL_DIR="${KERNEL_DIR:-kernel-source}"

if [[ "${MANAGER}" == "none" ]]; then
  echo "No manager selected"
  exit 0
fi

source release/resolved-refs.env

if [[ -z "${manager_repo}" || -z "${manager_commit}" || -z "${manager_setup_path}" ]]; then
  echo "::error::Manager resolution missing repo, commit, or setup path"
  exit 1
fi

pushd "${KERNEL_DIR}" >/dev/null
setup_url="https://raw.githubusercontent.com/${manager_repo}/${manager_commit}/${manager_setup_path}"
echo "Applying ${MANAGER} from ${manager_repo}@${manager_commit}"
curl -fsSL "${setup_url}" -o /tmp/manager-setup.sh

manager_owner="${manager_repo%%/*}"
manager_name="${manager_repo#*/}"
if grep -q '^OWNER="KernelSU-Next"$' /tmp/manager-setup.sh &&
   grep -q '^REPO="$OWNER"$' /tmp/manager-setup.sh &&
   [[ "${manager_repo}" != "KernelSU-Next/KernelSU-Next" ]]; then
  sed -i \
    -e "s/^OWNER=\"KernelSU-Next\"$/OWNER=\"${manager_owner}\"/" \
    -e "s/^REPO=\"\$OWNER\"$/REPO=\"${manager_name}\"/" \
    /tmp/manager-setup.sh
fi

bash /tmp/manager-setup.sh "${manager_ref}"
popd >/dev/null
