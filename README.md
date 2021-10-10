# MPHZ
A multi-precision Hari-Zimmermann complex GSVD.

A part of the supplementary material for the paper
doi:[10.1137/19M1277813](https://doi.org/10.1137/19M1277813 "The LAPW Method with Eigendecomposition Based on the Hari–Zimmermann Generalized Hyperbolic SVD")
(arXiv:[1907.08560](https://arxiv.org/abs/1907.08560 "The LAPW Method with Eigendecomposition Based on the Hari–Zimmermann Generalized Hyperbolic SVD") \[math.NA\]).

## Building

### Prerequisites

A recent 64-bit Linux (e.g., CentOS 7.9 with devtoolset-8) or macOS (e.g., Big Sur) is needed.

Have the Intel MKL (Math Kernel Library) installed.

Then, clone and build [JACSD](https://github.com/venovako/JACSD) in a directory parallel to this one.

### Make options

Run ``make help`` to see the options:
```bash
cd src
make help
```

Intel C/C++ and Fortran compilers (version 19.1+/2020+) are recommended.
GNU Fortran 9 and 10 are *not* supported!
Please take a look [here](https://gcc.gnu.org/gcc-9/changes.html) for the explanation regarding the MAX and MIN intrinsics.
Currently, only GNU Fortran *8* is fully supported.
On RHEL/CentOS it is provided by, e.g., devtoolset-8.

## Execution

### Command line

To run the executable, say, e.g.
```bash
OMP_NUM_THREADS=T OMP_PLACES=C /path/to/hzl1sa.exe FN M N JSTRAT NSWP
```
where ``T`` is the number of threads, ``C`` is the thread placement (e.g., ``CORES``), ``FN`` is the file name prefix (without an extension) containing the input data, ``M`` and ``N`` are the number of rows and columns, respectively, ``JSTRAT`` is a parallel Jacobi strategy to employ (e.g., ``4`` for ``mmstep``), and ``NSWP`` is the maximal number of sweeps allowed (``30`` should suffice in many cases).

### Data format

Data should be contained in ``FN.Y``, ``FN.W``, and ``FN.J`` binary files.
The first two are Fortran-array-order files of ``KIND_FILE`` element kind, where the first one stores the matrix ``F`` and the second one the matrix ``G``, and both matrices are complex and expected to have ``M`` rows and ``N`` columns.
The third file contains the diagonal of the matrix ``J`` as a vector of 8-byte integers.

The output comprises ``FN.YU``, ``FN.WV``, ``FN.Z``, for the complex matrices ``U``, ``V`` (both ``M x N``), and ``Z`` (``N x N``); ``FN.SY``, ``FN.SW``, ``FN.SS``, for the real vectors ``\Sigma_F``, ``\Sigma_G``, and ``\Sigma``; and ``FN.EY``, ``FN.EW``, ``FN.E``, for the real vectors ``\Lambda_F``, ``\Lambda_G``, and ``\Lambda``, respectively, where all vectors are of length ``N``.

This work has been supported in part by Croatian Science Foundation under the project IP-2014-09-3670 ([MFBDA](https://web.math.pmf.unizg.hr/mfbda/)).
