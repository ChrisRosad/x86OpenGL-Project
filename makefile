# CS 218 Assignment #10
# Simple make file for asst #10

OBJS	= lissajou.o a10procs.o
ASM	= yasm -g dwarf2 -f elf64
CC	= g++ -g -std=c++11 

all: lissajou

lissajou.o: lissajou.cpp
	$(CC) -c lissajou.cpp

a10procs.o: a10procs.asm 
	$(ASM) a10procs.asm -l a10procs.lst

lissajou: $(OBJS)
	$(CC) -no-pie -o lissajou $(OBJS) -lglut -lGLU -lGL -lm

# -----
# clean by removing object files.

clean:
	rm  $(OBJS)
	rm  a10procs.lst
