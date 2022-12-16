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
CPUFLAGS=-DUSE_INTEL -DUSE_X64 -fPIC -fexceptions -fno-omit-frame-pointer -qopenmp -rdynamic
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
FORFLAGS=$(CPUFLAGS) -i8 -standard-semantics -threads
FPUFLAGS=-fp-model $(FP) -fprotect-parens -no-ftz
ifneq ($(FP),strict)
FPUFLAGS += -fma -fimf-use-svml=true
endif # !strict
ifeq ($(FP),strict)
FPUFLAGS += -assume ieee_fpe_flags
endif # strict
ifdef NDEBUG
OPTFLAGS=-O$(NDEBUG) -xHost -vec-threshold0
DBGFLAGS=-DNDEBUG -qopt-report=3 -traceback
else # DEBUG
OPTFLAGS=-O0 -xHost
DBGFLAGS=-$(DEBUG) -debug emit_column -debug extended -debug inline-debug-info -debug pubnames -traceback
ifneq ($(ARCH),Darwin)
DBGFLAGS += -debug parallel
endif # Linux
DBGFLAGS += -debug-parameters all -check all -warn all
endif # ?NDEBUG
LIBFLAGS=-I. -I../../JACSD/vn
ifneq ($(ARCH),Darwin)
LIBFLAGS += -static-libgcc -D_GNU_SOURCE
endif # Linux
LDFLAGS=-L../../JACSD -lvn$(PROFILE)$(DEBUG) -lpthread -lm -ldl
FFLAGS=$(OPTFLAGS) $(DBGFLAGS) $(LIBFLAGS) $(FORFLAGS) $(FPUFLAGS)
