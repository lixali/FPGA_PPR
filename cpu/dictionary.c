#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include <math.h>

#include "dictionary.h"
#include "sort_array.h"

vertex * my_hash_table[TABLE_SIZE];

// vertex struct the contains 
vertex *init_array(int node, int m){
    vertex *st = (vertex *)malloc(sizeof(vertex)+m*sizeof(int));
    st->left = 0; // left and st->neighbours[] array's left most index, right is right most index
    st->right = m-1;
    st->key = node;
    return st;
}

// when adding element to vertex->value[], memory needs to be resized
vertex *resize_array(vertex *st, int m){
    if (m<=st->right + 1){
         return st; /* Make sure do not kill old values */
    }
    st = (vertex *)realloc(st, sizeof(vertex)+m*sizeof(int));
    st->right = m-1;

    return st;
}

//input node is a number, the simplest hashing will be returning itself.
unsigned int hash(int node){
    unsigned int hash_value = 0;
    hash_value += node;
    hash_value %= TABLE_SIZE; // need to do mod operation in case hash number is larger than table size
    return hash_value;
}

// initialize the the hash_table[] to be NULL
void init_hash_table(){
    for(int i=0; i < TABLE_SIZE; i++){
        my_hash_table[i] = NULL;
    }
}

// this is for debugging purpose, it will print out the hash_table value, 
// it can be used to print before and after the hash_table is filled up
void print_table(){
    for (int i = 0; i < TABLE_SIZE; i ++){
        if (my_hash_table[i] == NULL){
            printf("\t%i\t --- \n ", i);
        }else {
            printf("\t%i\t%d",i, my_hash_table[i]->key);
            printf("\n");
        }
    }
}

// currently is not used yet. Will need to shorten the code in main() and put code in here and make it more modularized
bool hash_table_insert(vertex *p){
    if(p == NULL) return false;
    int index = hash(p->key);
    if (my_hash_table[index] != NULL){

        return true;
    }
    printf("test p right value %d \n", p->right);
    my_hash_table[index] = p;
    return true;
}

// add node to the end of the list vertex->neighbours[] 
bool hash_value_insert(vertex *p, int n){
    //printf("p and right is %d %d \n", p->key, p->right);
    p->neighbours[p->right] = n;
    /*
    for(int i = 0; i<p->right+1; i++){
        printf("neighbours is %d \n", p->neighbours[i]);
    }
    */
    return true;
}
