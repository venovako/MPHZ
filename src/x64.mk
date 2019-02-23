SHELL=/bin/bash
ARCH=$(shell uname)
RM=rm -rfv
AR=xiar
ARFLAGS=-qnoipo -lib rsv
FC=ifort
CC=icc
CPUFLAGS=-DUSE_INTEL -DUSE_X64 -fexceptions
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
C11FLAGS=$(CPUFLAGS) -DVN_INTEGER_KIND=8 -std=c11
ifdef NDEBUG
OPTFLAGS=-O$(NDEBUG) -xHost
DBGFLAGS=-DNDEBUG -qopt-report=5 -traceback -diag-disable=10397
DBGFFLAGS=$(DBGFLAGS)
DBGCFLAGS=$(DBGFLAGS) -w3 -diag-disable=1572,2547
FPUFLAGS=-fma -fp-model source -no-ftz -no-complex-limited-range -no-fast-transcendentals -prec-div -prec-sqrt -fimf-precision=high -fimf-use-svml=true
FPUFFLAGS=$(FPUFLAGS)
FPUCFLAGS=$(FPUFLAGS)
else # DEBUG
OPTFLAGS=-O0 -xHost
DBGFLAGS=-g -debug emit_column -debug extended -debug inline-debug-info -debug pubnames -traceback -diag-disable=10397
ifneq ($(ARCH),Darwin) # Linux
DBGFLAGS += -debug parallel
endif # ?Linux
DBGFFLAGS=$(DBGFLAGS) -debug-parameters all -check all -warn all
DBGCFLAGS=$(DBGFLAGS) -check=stack,uninit -w3 -diag-disable=1572,2547
FPUFLAGS=-fp-model strict -fp-stack-check -fma -no-ftz -no-complex-limited-range -no-fast-transcendentals -prec-div -prec-sqrt -fimf-precision=high
FPUFFLAGS=$(FPUFLAGS) -assume ieee_fpe_flags
FPUCFLAGS=$(FPUFLAGS)
endif # ?NDEBUG
OPTFFLAGS=$(OPTFLAGS)
OPTCFLAGS=$(OPTFLAGS)
LIBFLAGS=-qopenmp
LDFLAGS=-lpthread -lm -ldl
FFLAGS=$(OPTFFLAGS) $(DBGFFLAGS) $(LIBFLAGS) $(FORFLAGS) $(FPUFFLAGS)
CFLAGS=$(OPTCFLAGS) $(DBGCFLAGS) $(LIBFLAGS) $(C11FLAGS) $(FPUCFLAGS)
