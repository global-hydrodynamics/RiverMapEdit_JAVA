FC	= ifort
FFLAGS = -O3 -warn all -assume byterecl -heap-arrays -nogen-interfaces

TARGETS=\
calc_rivwth \
conv_lndfrc_big \
set_basin \
change_header \
conv_lndfrc_little \
set_flwdir \
check_flwdir \
conv_runoff \

all: $(TARGETS)

clean:
	$(RM) -rf *.o *.s core *~ *trace *.mod *.dSYM  $(TARGETS)

.SUFFIXES : .f90
.f90:
	$(FC) ${FFLAGS} $^ -o $@


