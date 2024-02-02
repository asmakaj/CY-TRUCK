OBJ := files_o
DBG = -g -Wall


all: Project_T1 Project_T2 Project_S


$(OBJ)/programme_s.o: programme_s.c programme_s.h
gcc -c programme_s.c -o $(OBJ)/programme_s.o

$(OBJ)/programme_t.o: programme_t.c programme_t.h
gcc -c programme_t.c -o $(OBJ)/programme_t.o

$(OBJ)/programme_t2.o: programme_t2.c programme_t2.h
gcc -c programme_t2.c -o $(OBJ)/programme_t2.o



Project_S: $(OBJ)/programme_s.o
gcc $(CFLAGS) $(OBJ)/programme_s.o -o Project_S -lm

Project_T1: $(OBJ)/programme_t.o
gcc $(CFLAGS) $(OBJ)/programme_t.o -o Project_T1 -lm

Project_T2: $(OBJ)/programme_t2.o
gcc $(CFLAGS) $(OBJ)/programme_t2.o -o Project_T2 -lm


