ifndef CPU
CPU=gnu
endif # !CPU
include $(CPU).mk
MKFS=GNUmakefile $(CPU).mk

.PHONY: all help clean

all: libMPHZ.a hzl1sa.exe

help:
	@echo 'gmake [CPU=x64|x200|pgi|gnu] [NDEBUG=0|1|2|3|4|5] [KIND_SINGLE=4|8|10|16] [KIND_DOUBLE=4|8|10|16] [KIND_FILE=4|8|10|16] [all|clean|help]'
	@echo 'If CPU is defined, Intel Fortran compiler will be used and KIND(s) cannot be set to 10.'
	@echo 'If CPU is not defined, GNU Fortran compiler will be used and KIND(s) can be set to 10.'
	@echo 'KIND_SINGLE specifies a memory data type.'
	@echo 'KIND_DOUBLE specifies an internal arithmetic data type.'
	@echo 'KIND_FILE specifies a type of the input files (KIND_SINGLE by default).'
	@echo 'The output files are written in KIND_SINGLE, i.e., data is transferred from the memory as-is.'
	@echo 'If NDEBUG is defined, a release build will proceed, with the optimisation level set to $$(NDEBUG).'
	@echo 'If NDEBUG is not defined, a debug build will proceed.'

hzl1sa.exe: hzl1sa.o libMPHZ.a ../../JACSD/libjstrat.a $(MKFS)
	$(FC) $(FFLAGS) hzl1sa.o -o$@ -L. -lMPHZ -L../../JACSD -ljstrat $(LDFLAGS)

hzl1sa.o: hzl1sa.F90 binio.mod params.mod xhz.mod $(MKFS)
	$(FC) $(FFLAGS) -I../../JACSD/jstrat -c hzl1sa.F90

libMPHZ.a: params.o binio.o xhz.o $(MKFS)
	$(AR) $(ARFLAGS) $@ params.o binio.o xhz.o

params.o params.mod: params.F90 $(MKFS)
	$(FC) $(FFLAGS) -c params.F90

binio.o binio.mod: binio.F90 params.mod $(MKFS)
	$(FC) $(FFLAGS) -c binio.F90

xhz.o xhz.mod: xhz.F90 xvrotm.F90 xhzl1sa.F90 params.mod ../../JACSD/jstrat/jstrat_f.mod $(MKFS)
	$(FC) $(FFLAGS) -I../../JACSD/jstrat -c xhz.F90

clean:
	-$(RM) *.exe
	-$(RM) *.mod
	-$(RM) *.o
	-$(RM) *.a
	-$(RM) *.optrpt
	-$(RM) *__genmod.f90
	-$(RM) *__genmod.mod
	-$(RM) *.dSYM
