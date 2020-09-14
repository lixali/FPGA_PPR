#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include <math.h>

#include "sort_array.h"

double *array;

// compare function which is called by sort_array function
int cmp(const void *a, const void *b){
    int ia = *(int *)a;
    int ib = *(int *)b;
    // this is descending order, to make it ascending, just change the < to >, and > to <
    return array[ia] > array[ib] ? -1 : array[ia] < array[ib]; 
}

int sort_array(double * data, int max_size){
    //int data[] ={ 5,4,1,2,3,4,100,50,50,50,10055};
    //int size = sizeof(data)/sizeof(*data);
    int size = max_size;
    int index[size];//use malloc to large size array
    //int i;
    FILE * fptr = fopen("sorted_nodes_cmty_4.txt", "w");
    for(int i=0;i<size;i++){
        index[i] = i;
    }
    array = data;
    qsort(index, size, sizeof(*index), cmp);
    //printf("\n\ncount_number\tnode\n"); // it is for printing out in terminal when debugging
    fprintf(fptr, "%s\t\t\t\t%s\n", "score", "node");

    for(int i=0;i<size;i++){
        //printf("%d\t\t\t%d\n", data[index[i]], index[i]);
        if(index[i]>=1){ // remove node 0; node 0 doesn't exist, node starts from 1
        fprintf(fptr, "%f\t\t%d\n", data[index[i]], index[i]);
        }
    }
    return 0;
}