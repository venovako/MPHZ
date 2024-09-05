SHELL=/bin/bash
ARCH=$(shell uname)
ifdef NDEBUG
DEBUG=
else # DEBUG
DEBUG=g
endif # ?NDEBUG
ifndef FP
FP=precise
endif # !FP
RM=rm -rfv
AR=xiar
ARFLAGS=-qnoipo -lib rsv
FC=ifx
CPUFLAGS=-DUSE_INTEL -DUSE_X64 -fPIC -fexceptions -fasynchronous-unwind-tables -fno-omit-frame-pointer -mprefer-vector-width=512 -vec-threshold0 -qopenmp -rdynamic -static-libgcc
ifdef KIND_SINGLE
CPUFLAGS += -DKIND_SINGLE=$(KIND_SINGLE)
endif # KIND_SINGLE
ifdef KIND_DOUBLE
CPUFLAGS += -DKIND_DOUBLE=$(KIND_DOUBLE)
endif # KIND_DOUBLE
ifdef KIND_FILE
CPUFLAGS += -DKIND_FILE=$(KIND_FILE)
endif # KIND_FILE
FORFLAGS=$(CPUFLAGS) -i8 -standard-semantics -threads
FPUFLAGS=-fp-model=$(FP) -fp-speculation=safe -fma -fprotect-parens -no-ftz
ifneq ($(FP),strict)
FPUFLAGS += -fimf-use-svml=true -fimf-precision=high
endif # !strict
ifeq ($(FP),strict)
FPUFLAGS += -assume ieee_fpe_flags
endif # strict
DBGFLAGS=-traceback
ifdef NDEBUG
OPTFLAGS=-O$(NDEBUG) -xcommon-avx512
DBGFLAGS += -DNDEBUG -qopt-report=3
else # DEBUG
OPTFLAGS=-O0 -xcommon-avx512
DBGFLAGS += -$(DEBUG) -debug emit_column -debug extended -debug inline-debug-info -debug pubnames
ifneq ($(ARCH),Darwin)
DBGFLAGS += -debug parallel
endif # Linux
DBGFLAGS += -debug-parameters all -check all -warn all
endif # ?NDEBUG
LIBFLAGS=-I. -I../../JACSD/vn
ifneq ($(ARCH),Darwin)
LIBFLAGS += -static-libgcc -D_GNU_SOURCE
endif # Linux
LDFLAGS=-L../../JACSD -lvn$(DEBUG) -lpthread -lm -ldl
FFLAGS=$(OPTFLAGS) $(DBGFLAGS) $(LIBFLAGS) $(FORFLAGS) $(FPUFLAGS)
