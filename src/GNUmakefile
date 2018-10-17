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

all: libMPHZ.a

help:
	@echo '(g)make [CPU=x64|x200] [NDEBUG=0|1|2|3|4|5] [KIND_SINGLE=4|8|10|16] [KIND_DOUBLE=4|8|10|16] [all|clean|help]'
	@echo 'If CPU is defined, Intel Fortran compiler will be used and KIND(s) cannot be set to 10.'
	@echo 'If CPU is not defined, GNU Fortran compiler will be used and KIND(s) can be set to 10.'
	@echo 'If NDEBUG is defined, a release build will proceed, with the optimisation level set to $$(NDEBUG).'
	@echo 'If NDEBUG is not defined, a debug build will proceed.'

libMPHZ.a: params.o $(MKFS)
	$(AR) $(ARFLAGS) $@ params.o

params.o params.mod: params.F90 $(MKFS)
	$(FC) $(FFLAGS) -c params.F90

clean:
	-$(RM) *.exe
	-$(RM) *.mod
	-$(RM) *.o
	-$(RM) *.a
	-$(RM) *.optrpt
	-$(RM) *__genmod.f90
	-$(RM) *__genmod.mod
	-$(RM) *.dSYM
