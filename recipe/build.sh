#!/usr/bin/env bash
set -exv

# This step is required when building from raw source archive
# make generate --jobs ${CPU_COUNT}

# CUDAARCHS set by nvcc compiler package

backend_args=()
if [[ "${hip_compiler_version}" != "None" ]]; then
  backend_args+=("-DMAGMA_ENABLE_HIP:BOOL=ON")

  # MAGMA consumes HIP arch targets from its GPU_TARGET cache variable.
  # rock-the-conda provides semicolon-delimited gfx targets in
  # ROCK_THE_CONDA_ROCM_GPU_TARGETS is semicolon-delimited (e.g. gfx90a;gfx942).
  # MAGMA's GPU_TARGET expects space-separated names (it builds the list by space-appending
  # in CMake), so convert semicolons to spaces.
  if [[ -n "${ROCK_THE_CONDA_ROCM_GPU_TARGETS:-}" ]]; then
    magma_gpu_target="${ROCK_THE_CONDA_ROCM_GPU_TARGETS//;/ }"
    backend_args+=("-DGPU_TARGET=${magma_gpu_target}")
    echo "Using MAGMA HIP GPU_TARGET=${magma_gpu_target}"
  fi
else
  # Conda-forge nvcc compiler flags environment variable doesn't match CMake environment variable
  # Redirect it so that the flags are added to nvcc calls
  # shellcheck disable=SC2153
  export CUDAFLAGS="${CUDAFLAGS} ${CUDA_CFLAGS}"

  # Compress SASS and PTX in the binary to reduce disk usage
  export CUDAFLAGS="${CUDAFLAGS} -Xfatbin -compress-all"
  # shellcheck disable=SC2154
  if [[ "${cuda_compiler_version}" == 13.* ]]; then
    export CUDAFLAGS="${CUDAFLAGS} -Xfatbin -compress-mode=size"
  fi

  backend_args+=("-DMAGMA_ENABLE_CUDA:BOOL=ON")
fi


mkdir build
cd build

# Must set CMAKE_CXX_STANDARD=17 because CCCL from CUDA 13 has dropped C++14
cmake "${SRC_DIR}" \
  -G "Ninja" \
  -DBUILD_SHARED_LIBS:BOOL=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  "${backend_args[@]}" \
  -DUSE_FORTRAN:BOOL=OFF \
  -DCMAKE_CUDA_SEPARABLE_COMPILATION:BOOL=OFF \
  -DCMAKE_CXX_STANDARD=17 \
  "${CMAKE_ARGS}"

# Explicitly name build targets to avoid building tests
cmake --build . \
    --config Release \
    --parallel "${CPU_COUNT}" \
    --target magma magma_sparse \
    --verbose

cmake --install .  --strip
