all: runmain

run: runmain
	./result
runmain: clean
	g++ main.c random_walk.c dictionary.c sort_array.c calculate_stats.c -o result -g -lm -std=c++11 -I/usr/include/python3.8 -lpython3.8
clean:
	rm -f result
