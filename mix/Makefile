all: example

main.o: main.c
	gcc -c main.c

add.o: add.s
	gcc -c add.s

example: main.o add.o
	gcc -o example main.o add.o

clean:
	rm -f main.o add.o example

