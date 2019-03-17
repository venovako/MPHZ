# MPHZ
A multi-precision Hari-Zimmermann complex GSVD.

...a work in progress...

## Building

### Prerequisites

A recent 64-bit Linux (e.g., CentOS 7.5) or macOS (e.g., High Sierra) is needed.

Have the Intel MKL (Math Kernel Library) installed.

Then, clone and build [JACSD](https://github.com/venovako/JACSD) in a directory parallel to this one.

### Make options

Run ``make help`` to see the options:
```bash
cd src
make help
```

## Execution

### Command line

To run the executable, say, e.g.
```bash
OMP_NUM_THREADS=T OMP_PLACES=C /path/to/hzl1sa.exe FN M N JSTRAT NSWP
```
where ``T`` is the number of threads, ``C`` is the thread placement (e.g., ``CORES``), ``FN`` is the file name prefix (without an extension) containing the input data, ``M`` and ``N`` are the number of rows and columns, respectively, ``JSTRAT`` is a parallel Jacobi strategy to employ (e.g., ``4`` for ``mmstep``), and ``NSWP`` is the maximal number of sweeps allowed (``30`` should suffice in many cases).

### Data format

Data should be contained in ``FN.Y`` and ``FN.W`` binary, Fortran-array-order files of ``KIND_FILE`` element kind, where the first one stores the matrix ``F`` and the second one the matrix ``G``, and both matrices are expected to have ``M`` rows and ``N`` columns.

The output comprises ``FN.YU``, ``FN.WV``, ``FN.Z``, for the matrices ``U``, ``V``, and ``Z``; and ``FN.SY``, ``FN.SW``, ``FN.SS``, for the vectors ``\Sigma_F``, ``\Sigma_G``, and ``\Sigma``, respectively.

This work has been supported in part by Croatian Science Foundation under the project IP-2014-09-3670 ([MFBDA](https://web.math.pmf.unizg.hr/mfbda/)).
