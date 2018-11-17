SHELL=/bin/bash
ARCH=$(shell uname)
RM=rm -rfv
AR=ar
ARFLAGS=rsv
FC=gfortran
ifeq ($(ARCH),Darwin)
CC=clang
else # Linux
CC=gcc
endif # ?Darwin
CPUFLAGS=-DUSE_GNU -DUSE_X64
ifdef KIND_SINGLE
CPUFLAGS += -DKIND_SINGLE=$(KIND_SINGLE)
endif # KIND_SINGLE
ifdef KIND_DOUBLE
CPUFLAGS += -DKIND_DOUBLE=$(KIND_DOUBLE)
endif # KIND_DOUBLE
ifdef KIND_FILE
CPUFLAGS += -DKIND_FILE=$(KIND_FILE)
endif # KIND_FILE
FORFLAGS=-cpp $(CPUFLAGS) -fdefault-integer-8 -ffree-line-length-none -fopenmp -fstack-arrays
C11FLAGS=$(CPUFLAGS) -DFORTRAN_INTEGER_KIND=8
ifeq ($(ARCH),Darwin)
C11FLAGS += -std=gnu17 -pthread
else # Linux
C11FLAGS += -std=gnu11 -fopenmp
endif # ?Darwin
ifdef NDEBUG
OPTFLAGS=-O$(NDEBUG) -march=native
DBGFLAGS=-DNDEBUG
ifeq ($(ARCH),Darwin)
OPTFFLAGS=$(OPTFLAGS) -Wa,-q -fgcse-las -fgcse-sm -fipa-pta -ftree-loop-distribution -ftree-loop-im -ftree-loop-ivcanon -fivopts -fvect-cost-model=unlimited -fvariable-expansion-in-unroller
OPTCFLAGS=$(OPTFLAGS) -integrated-as
DBGFFLAGS=$(DBGFLAGS) -fopt-info-optimized-vec
DBGCFLAGS=$(DBGFLAGS)
else # Linux
OPTFLAGS += -fgcse-las -fgcse-sm -fipa-pta -ftree-loop-distribution -ftree-loop-im -ftree-loop-ivcanon -fivopts -fvect-cost-model=unlimited -fvariable-expansion-in-unroller
OPTFFLAGS=$(OPTFLAGS)
OPTCFLAGS=$(OPTFLAGS)
DBGFLAGS += -fopt-info-optimized-vec
DBGFFLAGS=$(DBGFLAGS) -pedantic -Wall -Wextra -Wno-compare-reals -Warray-temporaries -Wcharacter-truncation -Wimplicit-procedure -Wfunction-elimination -Wrealloc-lhs-all
DBGCFLAGS=$(DBGFLAGS)
endif # ?Darwin
FPUFLAGS=-ffp-contract=fast
FPUFFLAGS=$(FPUFLAGS)
FPUCFLAGS=$(FPUFLAGS) -fno-math-errno
else # DEBUG
OPTFLAGS=-Og -march=native
ifeq ($(ARCH),Darwin)
OPTFFLAGS=$(OPTFLAGS) -Wa,-q
OPTCFLAGS=$(OPTFLAGS) -integrated-as
else # Linux
OPTFFLAGS=$(OPTFLAGS)
OPTCFLAGS=$(OPTFLAGS)
endif # ?Darwin
DBGFLAGS=-g
DBGFFLAGS=$(DBGFLAGS) -fcheck=all -finit-local-zero -finit-real=snan -finit-derived -pedantic -Wall -Wextra -Wno-compare-reals -Warray-temporaries -Wcharacter-truncation -Wimplicit-procedure -Wfunction-elimination -Wrealloc-lhs-all
DBGCFLAGS=$(DBGFLAGS) -ftrapv
FPUFLAGS=-ffp-contract=fast
FPUFFLAGS=$(FPUFLAGS) -ffpe-trap=invalid,zero,overflow
FPUCFLAGS=$(FPUFLAGS)
endif # ?NDEBUG
LDFLAGS=-lpthread -lm -ldl
FFLAGS=$(OPTFFLAGS) $(DBGFFLAGS) $(LIBFLAGS) $(FORFLAGS) $(FPUFFLAGS)
CFLAGS=$(OPTCFLAGS) $(DBGCFLAGS) $(LIBFLAGS) $(C11FLAGS) $(FPUCFLAGS)
