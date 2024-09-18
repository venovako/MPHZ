SHELL=/bin/bash
ARCH=$(shell uname)
ifdef NDEBUG
DEBUG=
else # DEBUG
DEBUG=g
endif # ?NDEBUG
ifndef FP
ifdef NDEBUG
FP=precise
else # DEBUG
FP=strict
endif # ?NDEBUG
endif # !FP
RM=rm -rfv
AR=xiar
ARFLAGS=-qnoipo -lib rsv
FC=ifort
ifndef MARCH
MARCH=Host
# COMMON-AVX512 for KNLs
endif # !MARCH
CPUFLAGS=-DUSE_INTEL -DUSE_X64 -fPIC -fexceptions -fasynchronous-unwind-tables -fno-omit-frame-pointer -qopt-multi-version-aggressive -qopt-zmm-usage=high -vec-threshold0 -qopenmp -x$(MARCH)
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
FPUFLAGS=-fp-model $(FP) -fprotect-parens -fma -no-ftz -no-complex-limited-range -no-fast-transcendentals -prec-div -prec-sqrt
ifeq ($(FP),strict)
FPUFLAGS += -fp-stack-check
else # !strict
FPUFLAGS += -fimf-use-svml=true
endif # ?strict
ifeq ($(FP),strict)
FPUFLAGS += -assume ieee_fpe_flags
endif # strict
DBGFLAGS=-traceback -diag-disable=10397,10441
ifdef NDEBUG
OPTFLAGS=-O$(NDEBUG) -fno-math-errno -inline-level=2
DBGFLAGS += -DNDEBUG -qopt-report=5
else # DEBUG
OPTFLAGS=-O0
DBGFLAGS += -$(DEBUG) -debug emit_column -debug extended -debug inline-debug-info -debug pubnames
ifneq ($(ARCH),Darwin)
DBGFLAGS += -debug parallel
endif # Linux
DBGFLAGS += -debug-parameters all -check all -warn all
endif # ?NDEBUG
LIBFLAGS=-I. -I../../JACSD/vn
LDFLAGS=-rdynamic
ifneq ($(ARCH),Darwin)
LIBFLAGS += -D_GNU_SOURCE
LDFLAGS += -static-libgcc
endif # Linux
LDFLAGS += -L../../JACSD -lvn$(DEBUG) -lpthread -lm -ldl
FFLAGS=$(OPTFLAGS) $(DBGFLAGS) $(LIBFLAGS) $(FORFLAGS) $(FPUFLAGS)
