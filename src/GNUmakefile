ifeq ($(CPU),x64) # Xeon / Intel Fortran
include x64.mk
MKFS=GNUmakefile x64.mk
else ifeq ($(CPU),x200) # Knights Landing / Intel Fortran
include x200.mk
MKFS=GNUmakefile x200.mk
else # !CPU
CPU=x86_64 # GNU Fortran
include gnu.mk
MKFS=GNUmakefile gnu.mk
endif # ?CPU

.PHONY: all help clean

all: libMPHZ.a hzl1p.exe

help:
	@echo '[g]make [CPU=x64|x200] [NDEBUG=0|1|2|3|4|5] [KIND_SINGLE=4|8|10|16] [KIND_DOUBLE=4|8|10|16] [KIND_FILE=4|8|10|16] [all|clean|help]'
	@echo 'If CPU is defined, Intel Fortran compiler will be used and KIND(s) cannot be set to 10.'
	@echo 'If CPU is not defined, GNU Fortran compiler will be used and KIND(s) can be set to 10.'
	@echo 'KIND_SINGLE specifies a memory data type.'
	@echo 'KIND_DOUBLE specifies an internal arithmetic data type.'
	@echo 'KIND_FILE specifies a type of the input files (KIND_SINGLE by default).'
	@echo 'The output files are written in KIND_SINGLE, i.e., data is transferred from the memory as-is.'
	@echo 'If NDEBUG is defined, a release build will proceed, with the optimisation level set to $$(NDEBUG).'
	@echo 'If NDEBUG is not defined, a debug build will proceed.'

hzl1p.exe: hzl1p.o libMPHZ.a $(MKFS)
	$(FC) $(FFLAGS) hzl1p.o -o$@ -L. -lMPHZ -L../../JACSD -ljstrat $(LDFLAGS)

hzl1p.o: hzl1p.F90 binio.mod xhz.mod $(MKFS)
	$(FC) $(FFLAGS) -c hzl1p.F90

libMPHZ.a: params.o binio.o jacstr.o xhz.o $(MKFS)
	$(AR) $(ARFLAGS) $@ params.o binio.o jacstr.o xhz.o

params.o params.mod: params.F90 $(MKFS)
	$(FC) $(FFLAGS) -c params.F90

binio.o binio.mod: binio.F90 params.mod $(MKFS)
	$(FC) $(FFLAGS) -c binio.F90

jacstr.o jacstr.mod: jacstr.F90 params.mod $(MKFS)
	$(FC) $(FFLAGS) -c jacstr.F90

xhz.o xhz.mod: xhz.F90 xvrotm.F90 xhzl1p.F90 jacstr.mod $(MKFS)
	$(FC) $(FFLAGS) -c xhz.F90

clean:
	-$(RM) *.exe
	-$(RM) *.mod
	-$(RM) *.o
	-$(RM) *.a
	-$(RM) *.optrpt
	-$(RM) *__genmod.f90
	-$(RM) *__genmod.mod
	-$(RM) *.dSYM
