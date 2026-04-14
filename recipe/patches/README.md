# Patch provenance for libmagma-feedstock

- `0001-backport-pr65-hipblas-v2-compat.patch`
  - Source: https://github.com/icl-utk-edu/magma/pull/65
  - Purpose: HIPBLAS v2 API/type compatibility backport for MAGMA 2.9.0.

- `0002-add-gfx115x-valid-targets.patch`
  - Source: local backport against MAGMA 2.9.0 `CMakeLists.txt` valid gfx list.
  - Purpose: allow `gfx1150` and `gfx1151` as valid HIP GPU targets.

- `0003-backport-utk-magma-rocm70-hip-api-compat.patch`
  - Source branch: https://github.com/ROCm/utk-magma/tree/release/2.9.0_rocm70
  - Source branch HEAD at backport time: `6e012779d632ac598ec5f0a5416116e3f8d16fac`
  - Files imported from that branch:
    - `interface_hip/blas_h_v2.cpp`
    - `interface_hip/blas_z_v2.cpp`
    - `interface_hip/blas_c_v2.cpp`
    - `interface_hip/interface.cpp`
  - Purpose: ROCm 7.x HIP API compatibility fixes (hipblasGemmEx compute type updates,
    trmm call signature guards, and HIP pointer attribute API updates).
