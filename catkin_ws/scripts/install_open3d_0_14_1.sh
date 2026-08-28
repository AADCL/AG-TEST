#!/usr/bin/env bash
set -euo pipefail

workspace_dir="${1:-/home/bitcq/catkin_ws}"
artifact_dir="${2:-/home/bitcq}"
jobs="${OPEN3D_BUILD_JOBS:-4}"
source_dir="/home/bitcq/src/Open3D-0.14.1"
install_dir="/home/bitcq/opt/open3d-0.14.1"
cmake_bin="/home/bitcq/.local/bin/cmake"

source_archive="${artifact_dir}/Open3D-0.14.1.tar.gz"
dependency_archive="${artifact_dir}/open3d-3rdparty.zip"
cmake_wheel="${artifact_dir}/cmake-3.22.6-py2.py3-none-manylinux_2_17_aarch64.manylinux2014_aarch64.whl"
patch_file="${workspace_dir}/scripts/open3d-0.14.1-offline.patch"
eigen_package="${artifact_dir}/libeigen3-dev_3.4.0-2ubuntu2_all.deb"
eigen_root="/home/bitcq/opt/eigen-3.4.0"

for required in "${source_archive}" "${dependency_archive}" "${cmake_wheel}" "${patch_file}" "${eigen_package}"; do
    test -f "${required}" || { echo "Missing offline artifact: ${required}" >&2; exit 2; }
done

if ! test -x "${cmake_bin}"; then
    python3 -m pip install --user --no-index "${cmake_wheel}"
fi

if ! dpkg-query -W -f='${Status}' liblapacke-dev 2>/dev/null | grep -q 'install ok installed'; then
    sudo dpkg -i \
        "${artifact_dir}/libtmglib3_3.9.0-1build1_arm64.deb" \
        "${artifact_dir}/libtmglib-dev_3.9.0-1build1_arm64.deb" \
        "${artifact_dir}/liblapacke_3.9.0-1build1_arm64.deb" \
        "${artifact_dir}/liblapacke-dev_3.9.0-1build1_arm64.deb"
fi

mkdir -p "${source_dir}"
if ! test -f "${source_dir}/CMakeLists.txt"; then
    tar -xzf "${source_archive}" -C "${source_dir}"
fi

if ! grep -q 'option(BUILD_DOCUMENTATION' "${source_dir}/CMakeLists.txt"; then
    patch --batch --forward -d "${source_dir}" -p1 < "${patch_file}"
fi
grep -q 'BUILD_UNIT_TESTS OR BUILD_EXAMPLES OR BUILD_BENCHMARKS' \
    "${source_dir}/cmake/Open3DSetGlobalProperties.cmake"
grep -q 'c4fd999d67cd12872a8604162f2b1cf5b5a02fb807a88215f0f96bd50331b166' \
    "${source_dir}/3rdparty/zeromq/zeromq_build.cmake"
grep -q '754c3ace499a63e45b77ef4bcab4ee602c2c414f58403bce826b76ffc2f77d0b' \
    "${source_dir}/3rdparty/msgpack/msgpack_build.cmake"

unzip -q -o "${dependency_archive}" -d "${source_dir}/3rdparty_downloads"
if test -f "${artifact_dir}/v7.3.0.tar.gz"; then
    mkdir -p "${source_dir}/3rdparty_downloads/qhull"
    cp "${artifact_dir}/v7.3.0.tar.gz" "${source_dir}/3rdparty_downloads/qhull/"
fi

rm -rf "${eigen_root}"
mkdir -p "${eigen_root}"
dpkg-deb -x "${eigen_package}" "${eigen_root}"
test -f "${eigen_root}/usr/share/eigen3/cmake/Eigen3Config.cmake"

mkdir -p "${source_dir}/build"
"${cmake_bin}" -S "${source_dir}" -B "${source_dir}/build" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${install_dir}" \
    -DGLIBCXX_USE_CXX11_ABI=ON \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_EXAMPLES=OFF \
    -DBUILD_UNIT_TESTS=OFF \
    -DBUILD_BENCHMARKS=OFF \
    -DBUILD_DOCUMENTATION=OFF \
    -DBUILD_PYTHON_MODULE=OFF \
    -DBUILD_CUDA_MODULE=OFF \
    -DBUILD_ISPC_MODULE=OFF \
    -DBUILD_GUI=OFF \
    -DBUILD_WEBRTC=OFF \
    -DBUILD_JUPYTER_EXTENSION=OFF \
    -DBUILD_LIBREALSENSE=OFF \
    -DBUILD_AZURE_KINECT=OFF \
    -DBUILD_TENSORFLOW_OPS=OFF \
    -DBUILD_PYTORCH_OPS=OFF \
    -DWITH_FAISS=OFF \
    -DWITH_IPPICV=OFF \
    -DUSE_BLAS=ON \
    -DUSE_SYSTEM_EIGEN3=ON \
    -DEigen3_DIR="${eigen_root}/usr/share/eigen3/cmake" \
    -DUSE_SYSTEM_JPEG=ON \
    -DUSE_SYSTEM_PNG=ON \
    -DUSE_SYSTEM_QHULLCPP=OFF

"${cmake_bin}" --build "${source_dir}/build" --parallel "${jobs}"
"${cmake_bin}" --install "${source_dir}/build"
test -f "${install_dir}/lib/cmake/Open3D/Open3DConfig.cmake"
echo "Open3D 0.14.1 installed at ${install_dir}"
