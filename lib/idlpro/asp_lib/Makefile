###############################################################################
#
#		Makefile
#
###############################################################################

SRCS	= gncorrc.c
OBJS	= gncorrc.o

#-------------------
# SunOS 4
#CFLAGS	= -pic -fsingle -c -O3
# SunOS 5
# (so far this isn't working ... may need IDL 3.6 !!!!  -Rob, 7/94)
#CFLAGS	= -Kpic -fsingle -c -xO3
#CFLAGS	= -Kpic -fsingle -c -xO3 -L/opt/SUNWspro/SC2.0.1/ -lm
CFLAGS	= -Kpic -fsingle -c -xO3 -L/opt/SUNWspro/SC2.0.1/ -lm
#-------------------
# SunOS 4
##LFLAGS = -assert pure-text
#LFLAGS	=
# SunOS 5
LFLAGS	= -dy -G
#-------------------

gncorrc.so: $(OBJS)
	ld -o $@ $(LFLAGS) $(OBJS)

gncorrc.o: gncorrc.c
	cc $(CFLAGS) $*.c

lint:
	lint $(SRCS) | more

clean:
	rm -f $(OBJS) core a.out

#---------------------------------------------
#  aspinterp has been replaced by gncorrc
#---------------------------------------------
#
#aspinterp:
#	cc -pic -fsingle -c aspinterp.c
#	ld -o aspinterp.so -assert pure-text aspinterp.o
#
#---------------------------------------------
