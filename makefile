run: runmain
	./main
runmain: clean
	gcc main.c random_walk.c dictionary.c sort_array.c -o main
clean:
	rm -f main