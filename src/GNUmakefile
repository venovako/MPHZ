ifndef COMPILER
COMPILER=x64x
endif # !COMPILER
include $(COMPILER).mk
MKFS=GNUmakefile $(COMPILER).mk

.PHONY: all help clean

all: libMPHZ$(DEBUG).a hzl1sa.exe

help:
	@echo 'gmake [COMPILER=x64x|x200|gnu] [NDEBUG=0|1|2|3|4|5] [KIND_SINGLE=4|8|16] [KIND_DOUBLE=4|8|16] [KIND_FILE=4|8|16] [all|clean|help]'
	@echo 'KIND_SINGLE specifies a memory data type.'
	@echo 'KIND_DOUBLE specifies an internal arithmetic data type.'
	@echo 'KIND_FILE specifies a type of the input files (KIND_SINGLE by default).'
	@echo 'The output files are written in KIND_SINGLE, i.e., data is transferred from the memory as-is.'
	@echo 'If NDEBUG is defined, a release build will proceed, with the optimisation level set to $$(NDEBUG).'
	@echo 'If NDEBUG is not defined, a debug build will proceed.'

hzl1sa.exe: hzl1sa.o libMPHZ$(DEBUG).a ../../JACSD/libjstrat$(DEBUG).a ../../JACSD/libvn$(DEBUG).a $(MKFS)
	$(FC) $(FFLAGS) hzl1sa.o -o$@ -L. -lMPHZ$(DEBUG) -L../../JACSD -ljstrat$(DEBUG) $(LDFLAGS)

hzl1sa.o: hzl1sa.F90 binio.mod params.mod xhz.mod ../../JACSD/jstrat/jstrat_f.mod $(MKFS)
	$(FC) -I../../JACSD/jstrat $(FFLAGS) -c hzl1sa.F90

libMPHZ$(DEBUG).a: params.o binio.o xhz.o $(MKFS)
	$(AR) $(ARFLAGS) $@ params.o binio.o xhz.o

params.o params.mod: params.F90 ../../JACSD/vn/vn_types_f.mod ../../JACSD/vn/vn_params.F90 $(MKFS)
	$(FC) $(FFLAGS) -c params.F90

binio.o binio.mod: binio.F90 params.mod $(MKFS)
	$(FC) $(FFLAGS) -c binio.F90

xhz.o xhz.mod: xhz.F90 xvrotm.F90 xhzl1sa.F90 params.mod ../../JACSD/jstrat/jstrat_f.mod $(MKFS)
	$(FC) -I../../JACSD/jstrat $(FFLAGS) -c xhz.F90

clean:
	-$(RM) *.exe
	-$(RM) *.mod
	-$(RM) *.o
	-$(RM) *.a
	-$(RM) *.optrpt
	-$(RM) *.opt.yaml
	-$(RM) *__genmod.f90
	-$(RM) *__genmod.mod
	-$(RM) *.dSYM
