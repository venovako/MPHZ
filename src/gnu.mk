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
CPUFLAGS=-DUSE_GNU -DUSE_X64 -fPIC -fexceptions -fasynchronous-unwind-tables -fno-omit-frame-pointer -fvect-cost-model=unlimited -march=native -fopenmp
ifdef KIND_SINGLE
CPUFLAGS += -DKIND_SINGLE=$(KIND_SINGLE)
endif # KIND_SINGLE
ifdef KIND_DOUBLE
CPUFLAGS += -DKIND_DOUBLE=$(KIND_DOUBLE)
endif # KIND_DOUBLE
ifdef KIND_FILE
CPUFLAGS += -DKIND_FILE=$(KIND_FILE)
endif # KIND_FILE
FORFLAGS=-cpp $(CPUFLAGS) -fdefault-integer-8 -ffree-line-length-none -fstack-arrays #-DHAVE_IMAGINARY
ifeq ($(ARCH),Darwin)
ifndef GNU
GNU=-8
endif # !GNU
endif # Darwin
FC=gfortran$(GNU)
DBGFLAGS=-Wall -Wextra
FPUFLAGS=-ffp-contract=fast
ifdef NDEBUG
OPTFLAGS=-O$(NDEBUG)
DBGFLAGS += -DNDEBUG
ifeq ($(ARCH),Darwin)
OPTFLAGS += -Wa,-q
endif # Darwin
DBGFLAGS += -Wno-compare-reals -Warray-temporaries -Wcharacter-truncation -Wimplicit-procedure -Wfunction-elimination -Wrealloc-lhs-all
FPUFLAGS += -fno-math-errno
else # DEBUG
OPTFLAGS=-O$(DEBUG)
DBGFLAGS += -$(DEBUG) -pedantic -Wall -Wextra
ifeq ($(ARCH),Darwin)
OPTFLAGS += -Wa,-q
endif # ?Darwin
DBGFLAGS += -fcheck=array-temps -finit-local-zero -finit-real=snan -finit-derived -Wno-compare-reals -Warray-temporaries -Wcharacter-truncation -Wimplicit-procedure -Wfunction-elimination -Wrealloc-lhs-all #-fcheck=all
#FPUFLAGS += -ffpe-trap=invalid,zero,overflow
endif # ?NDEBUG
LIBFLAGS=-I. -I../../JACSD/vn
LDFLAGS=-rdynamic -static-libgcc -L../../JACSD -lvn$(DEBUG)
LDFLAGS += -lpthread -lm -ldl $(shell if [ -L /usr/lib64/libmemkind.so ]; then echo '-lmemkind'; fi)
FFLAGS=$(OPTFLAGS) $(DBGFLAGS) $(LIBFLAGS) $(FORFLAGS) $(FPUFLAGS)
