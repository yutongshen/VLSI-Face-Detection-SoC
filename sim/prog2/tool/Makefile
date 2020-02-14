CC      := g++
EXE     := network
SRC     := main.cpp
OBJ     := main.o
LIBDIR  := ./lib/
LIBNAME := dqn
LIB     := ${LIBDIR}lib${LIBNAME}.so
LIBSRC  := libdqn.cpp libnet.cpp libstruct.cpp libarr.cpp libarr_2.cpp libfunct.cpp libtuple.cpp libpair.cpp
INCLUDE := .
CFLAGS  := -I${INCLUDE}
LIBFLAG := -L${LIBDIR} -Wl,-rpath,${LIBDIR}

PREOPERATION := 
ifneq (${FILE},)
PREOPERATION += cat ${FILE} |
endif

all: main

${EXE}: main

main: clean ${OBJ} ${LIB}
	${CC} ${OBJ} ${LIBFLAG} -o ${EXE} -l${LIBNAME}

${OBJ}: ${SRC}
	${CC} -c ${SRC} -o ${OBJ} ${CFLAGS}

${LIB}: ${LIBDIR}
	${CC} ${LIBSRC} -fPIC -shared -o ${LIB}

${LIBDIR}:
	mkdir ${LIBDIR}

run: ${EXE}
	${PREOPERATION} ./${EXE}

clean:
	rm -rf ${LIB} ${EXE} *.o
