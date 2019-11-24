SHELL=/bin/bash
ARCH=$(shell uname)
ifdef NDEBUG
DEBUG=
else # DEBUG
DEBUG=g
endif # ?NDEBUG
RM=rm -rfv
AR=ar
ARFLAGS=rsv
CPUFLAGS=-DUSE_GNU -DUSE_X64 -fPIC -fexceptions -fno-omit-frame-pointer -rdynamic
ifdef KIND_SINGLE
CPUFLAGS += -DKIND_SINGLE=$(KIND_SINGLE)
endif # KIND_SINGLE
ifdef KIND_DOUBLE
CPUFLAGS += -DKIND_DOUBLE=$(KIND_DOUBLE)
endif # KIND_DOUBLE
ifdef KIND_FILE
CPUFLAGS += -DKIND_FILE=$(KIND_FILE)
endif # KIND_FILE
ifdef PROFILE
CPUFLAGS += -DVN_PROFILE=$(PROFILE) -fno-inline -finstrument-functions
endif # PROFILE
FORFLAGS=-cpp $(CPUFLAGS) -fdefault-integer-8 -ffree-line-length-none -fopenmp -fstack-arrays #-DHAVE_IMAGINARY
C11FLAGS=$(CPUFLAGS) -std=gnu17
ifeq ($(ARCH),Darwin)
CC=clang
FC=gfortran-8
C11FLAGS += -pthread
else # Linux
CC=gcc
FC=gfortran
C11FLAGS += -fopenmp
endif # ?Darwin
ifdef NDEBUG
OPTFLAGS=-O$(NDEBUG) -march=native
DBGFLAGS=-DNDEBUG
ifeq ($(ARCH),Darwin)
OPTFFLAGS=$(OPTFLAGS) -Wa,-q -fgcse-las -fgcse-sm -fipa-pta -ftree-loop-distribution -ftree-loop-im -ftree-loop-ivcanon -fivopts -fvect-cost-model=unlimited -fvariable-expansion-in-unroller
OPTCFLAGS=$(OPTFLAGS) -integrated-as
DBGFFLAGS=$(DBGFLAGS) -fopt-info-optimized-vec -pedantic -Wall -Wextra -Wno-compare-reals -Warray-temporaries -Wcharacter-truncation -Wimplicit-procedure -Wfunction-elimination -Wrealloc-lhs-all
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
OPTFLAGS=-O$(DEBUG) -march=native
DBGFLAGS=-$(DEBUG) -fsanitize=address
ifeq ($(ARCH),Darwin)
OPTFFLAGS=$(OPTFLAGS) -Wa,-q
OPTCFLAGS=$(OPTFLAGS) -integrated-as
else # Linux
OPTFFLAGS=$(OPTFLAGS)
OPTCFLAGS=$(OPTFLAGS)
DBGFLAGS += -fsanitize=leak
endif # ?Darwin
DBGFFLAGS=$(DBGFLAGS) -fcheck=all -finit-local-zero -finit-real=snan -finit-derived -pedantic -Wall -Wextra -Wno-compare-reals -Warray-temporaries -Wcharacter-truncation -Wimplicit-procedure -Wfunction-elimination -Wrealloc-lhs-all
DBGCFLAGS=$(DBGFLAGS) -fsanitize=undefined #-ftrapv
FPUFLAGS=-ffp-contract=fast
FPUFFLAGS=$(FPUFLAGS) #-ffpe-trap=invalid,zero,overflow
FPUCFLAGS=$(FPUFLAGS)
endif # ?NDEBUG
LIBFLAGS=-I. -I../../JACSD/vn
LDFLAGS=-L../../JACSD -lvn$(PROFILE)$(DEBUG) -lpthread -lm -ldl $(shell if [ -L /usr/lib64/libmemkind.so ]; then echo '-lmemkind'; fi)
FFLAGS=$(OPTFFLAGS) $(DBGFFLAGS) $(LIBFLAGS) $(FORFLAGS) $(FPUFFLAGS)
CFLAGS=$(OPTCFLAGS) $(DBGCFLAGS) $(LIBFLAGS) $(C11FLAGS) $(FPUCFLAGS)
