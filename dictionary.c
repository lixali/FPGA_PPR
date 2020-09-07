#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>


#define TABLE_SIZE 100000

typedef struct {
    int left;
    int right;
    //char name[MAX_NAME]; // array of char, one name can have multiple character, therefore need an array to store
    int name;
    int  value[];
    //int *valuepointer = value;
}vertex;

vertex *init_array(int node, int m){
    vertex *st = (vertex *)malloc(sizeof(vertex)+m*sizeof(int));
    st->left = 0;
    st->right = m-1;
    st->name = node;
    return st;
}

vertex *resize_array(vertex *st, int m){
    if (m<=st->right + 1){
         return st; /* Take sure do not kill old values */
    }
    st = (vertex *)realloc(st, sizeof(vertex)+m*sizeof(int));
    st->right = m-1;

    return st;
}

vertex * hash_table[TABLE_SIZE];


int array_size(int *array){
    size_t t = sizeof(&array);
    return t;
}

//input node is a number, the simplest hashing will be returning itself.
unsigned int hash(int node){
    unsigned int hash_value = 0;
    hash_value += node;
    hash_value %= TABLE_SIZE; // need to do mod operation in case hash number is larger than table size
    return hash_value;
}

void init_hash_table(){

    for(int i=0; i < TABLE_SIZE; i++){

        hash_table[i] = NULL;
    }
}

void print_table(){

    for (int i = 0; i < TABLE_SIZE; i ++){

        if (hash_table[i] == NULL){

            printf("\t%i\t --- \n ", i);
        }else {
            printf("\t%i\t%d",i, hash_table[i]->name);
            printf("\n");
        }
    }
}

bool hash_table_insert(vertex *p){
    if(p == NULL) return false;
    int index = hash(p->name);
    if (hash_table[index] != NULL){

        return true;
    }
    //init_array(p, 3);
    printf("test p right value %d \n", p->right);
    hash_table[index] = p;
    //int * poi = hash_table[index]->value;
    //poi = (int *) malloc(sizeof(int));
    return true;

}

bool hash_value_insert(vertex *p, int n){
    printf("p right is %d \n", p->right);
    p->value[p->right] = n;

    for(int i = 0; i<p->right+1; i++){

        printf("value is %d \n", p->value[i]);
    }
    return true;

}


int main() {

    init_hash_table();
    print_table();
    
    FILE * fp = fopen ("./cora_adj.txt", "r");
    int num1, num2, c;

    while(1) {
      c = fgetc(fp);
      if( feof(fp) ) {
         break;
      }

    fscanf(fp, "%d %d", &num2, &num1);
    //if (num1 <= 10) {
        printf("%d %d \n", num1, num2);

    int index = hash(num1);
    if (hash_table[index] == NULL) {
        hash_table[index] = init_array(index, 1);
    }else{

        int right = hash_table[index]->right;
        hash_table[index] = resize_array(hash_table[index],right+2);
    }

    hash_value_insert(hash_table[index], num2); 
    
    //}
   }

    print_table();


    return 0;


}
