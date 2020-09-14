#ifndef DICTIONARY_H
#define DICTIONARY_H

// the table size can be set larger if the number of nodes exceeds 100K
#define TABLE_SIZE 100000

typedef struct {
    int left;
    int right;
    int key;
    // define an value[] array within the struct, this array will need to be resizable, the left and right index are in ->left and ->right respectively
    int  value[]; 
}vertex;

//each element in hash_table is a pointer that points to vertex data type
vertex * hash_table[TABLE_SIZE];

void init_hash_table();
bool hash_value_insert(vertex *p, int n);
vertex *init_array(int node, int m);
vertex *resize_array(vertex *st, int m);
unsigned int hash(int node);


#endif