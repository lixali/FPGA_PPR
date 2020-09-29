all: runmain

run: runmain
	./result
runmain: clean
	gcc main.c random_walk.c dictionary.c sort_array.c -o result -std=c99 -g -lm
clean:
	rm -f result
