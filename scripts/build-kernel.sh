#!/usr/bin/env bash
set -euo pipefail

source config/marble.env

KERNEL_DIR="${KERNEL_DIR:-kernel-source}"
BUILD_SCOPE="${BUILD_SCOPE:-image-only}"
JOBS="${JOBS:-$(nproc)}"

pushd "${KERNEL_DIR}" >/dev/null
mkdir -p "${OUT_DIR}" "${RELEASE_DIR}"

export ARCH
export SUBARCH="${ARCH}"
export KBUILD_BUILD_USER="${KBUILD_BUILD_USER:-marble}"
export KBUILD_BUILD_HOST="${KBUILD_BUILD_HOST:-github-actions}"
export CCACHE_DIR="${CCACHE_DIR:-${HOME}/.ccache}"
export CCACHE_COMPILERCHECK=none
export CCACHE_NOHASHDIR=true

if [[ -n "${ANDROID_CLANG_BIN:-}" ]]; then
  if [[ ! -x "${ANDROID_CLANG_BIN}/clang" ]]; then
    echo "::error::ANDROID_CLANG_BIN does not contain clang: ${ANDROID_CLANG_BIN}"
    exit 1
  fi
  export PATH="${ANDROID_CLANG_BIN}:${PATH}"
fi

if command -v ccache >/dev/null 2>&1; then
  export CC="ccache clang"
  ccache -M 10G
  ccache -o compression=true
  ccache -z || true
else
  export CC="clang"
fi

clang --version | tee "${RELEASE_DIR}/build.log"
make O="${OUT_DIR}" ARCH="${ARCH}" LLVM=1 LLVM_IAS=1 CC="${CC}" "${DEFCONFIG}" 2>&1 | tee -a "${RELEASE_DIR}/build.log"
make O="${OUT_DIR}" ARCH="${ARCH}" LLVM=1 LLVM_IAS=1 CC="${CC}" olddefconfig 2>&1 | tee -a "${RELEASE_DIR}/build.log"

targets=(Image)
if [[ "${BUILD_SCOPE}" == "full" ]]; then
  targets+=(modules dtbs)
fi

make -j"${JOBS}" O="${OUT_DIR}" ARCH="${ARCH}" LLVM=1 LLVM_IAS=1 CC="${CC}" "${targets[@]}" 2>&1 | tee -a "${RELEASE_DIR}/build.log"

image_path="${OUT_DIR}/arch/arm64/boot/Image"
if [[ ! -s "${image_path}" ]]; then
  echo "::error::Built Image not found at ${image_path}"
  exit 1
fi

cp "${image_path}" "${RELEASE_DIR}/Image"
for file in System.map vmlinux; do
  if [[ -s "${OUT_DIR}/${file}" ]]; then
    cp "${OUT_DIR}/${file}" "${RELEASE_DIR}/${file}"
  fi
done

if [[ "${BUILD_SCOPE}" == "full" ]]; then
  if find "${OUT_DIR}/arch/arm64/boot/dts" -name '*.dtb' -print -quit | grep -q .; then
    find "${OUT_DIR}/arch/arm64/boot/dts" -name '*.dtb' -print0 | tar --null -T - -czf "${RELEASE_DIR}/dtbs.tar.gz"
  fi
  if find "${OUT_DIR}" -name '*.ko' -print -quit | grep -q .; then
    find "${OUT_DIR}" -name '*.ko' -print0 | tar --null -T - -czf "${RELEASE_DIR}/modules.tar.gz"
  fi
fi

if command -v ccache >/dev/null 2>&1; then
  ccache -s || true
fi

popd >/dev/null
