#!/usr/bin/env bash
set -euo pipefail

source config/marble.env

KERNEL_DIR="${KERNEL_DIR:-kernel-source}"
MANAGER="${MANAGER:-none}"
ENABLE_SUSFS="${ENABLE_SUSFS:-false}"
BUILD_SCOPE="${BUILD_SCOPE:-image-only}"
run_number="${GITHUB_RUN_NUMBER:-local}"

release_dir="${KERNEL_DIR}/${RELEASE_DIR}"
image_path="${release_dir}/Image"
if [[ ! -s "${image_path}" ]]; then
  echo "::error::Cannot package without ${image_path}"
  exit 1
fi

if [[ -f release/resolved-refs.env ]]; then
  source release/resolved-refs.env
fi

manager_label="${MANAGER}"
case "${MANAGER}" in
  none) manager_label="NoRoot" ;;
  kernelsu) manager_label="KernelSU" ;;
  kernelsu-next) manager_label="KSUNext" ;;
  sukisu-ultra) manager_label="SukiSUUltra" ;;
  resukisu) manager_label="ReSukiSU" ;;
esac

manager_ref_label="${manager_ref:-${MANAGER_REF:-none}}"
manager_ref_label="$(echo "${manager_ref_label}" | sed -E 's/[^A-Za-z0-9._-]+/-/g')"
if [[ "${manager_ref_label}" =~ ^[0-9a-fA-F]{40}$ ]]; then
  manager_ref_label="${manager_ref_label:0:7}"
fi
manager_short="${manager_commit:-none}"
manager_short="${manager_short:0:7}"

susfs_label="NoSUSFS"
susfs_short="none"
if [[ "${ENABLE_SUSFS}" == "true" ]]; then
  susfs_label="SuSFS-${susfs_reported_version:-${SUSFS_VERSION:-unknown}}"
  susfs_short="${susfs_commit:-unknown}"
  susfs_short="${susfs_short:0:7}"
fi

build_date="${BUILD_DATE:-$(date -u +%Y%m%d)}"

zip_name="AK3_Marble_android12-5.10_${manager_label}-${manager_ref_label}_${manager_short}_${susfs_label}_${susfs_short}_${build_date}_r${run_number}.zip"
work_dir="$(mktemp -d)"
git clone --depth=1 "${ANYKERNEL3_REPO}" "${work_dir}/ak3"
rsync -a ak3/ "${work_dir}/ak3/"
cp "${image_path}" "${work_dir}/ak3/Image"

pushd "${work_dir}/ak3" >/dev/null
zip -r9 "${OLDPWD}/${release_dir}/${zip_name}" . -x ".git/*" "README.md" "*placeholder*"
popd >/dev/null

pushd "${release_dir}" >/dev/null
sha256sum "${zip_name}" > "${zip_name}.sha256"
printf 'zip_name=%s\n' "${zip_name}" > zip-name.env
printf 'zip_sha256=%s\n' "$(sha256sum "${zip_name}" | awk '{print $1}')" >> zip-name.env
popd >/dev/null

rm -rf "${work_dir}"
echo "Packaged ${release_dir}/${zip_name}"
