all: runmain

run: runmain
	./result
runmain: clean
	g++ main.c random_walk.c dictionary.c sort_array.c -o result -g -lm
clean:
	rm -f result
