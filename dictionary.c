#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>

//#include <dictionary.h>

#define TABLE_SIZE 100000
#define NODE_NUM 2708 // if not knowing the total number of node, can set it to be same as TABLE_SIZE 
typedef struct {
    int left;
    int right;
    int key;
    // define an value[] array within the struct, this array will need to be resizable, the left and right index are in ->left and ->right respectively
    int  value[]; 
}vertex;

// vertex struct the contains 
vertex *init_array(int node, int m){
    vertex *st = (vertex *)malloc(sizeof(vertex)+m*sizeof(int));
    st->left = 0; // left and st->value[] array's left most index, right is right most index
    st->right = m-1;
    st->key = node;
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

//each element in hash_table is a pointer that points to vertex data type
vertex * hash_table[TABLE_SIZE];
// counter is used to keep track of the number of count during random walk
int counter[TABLE_SIZE];



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

        hash_table[i] = NULL;
    }
}

// this is for debugging purpose, it will print out the hash_table value, 
// it can be used to print before and after the hash_table is filled up
void print_table(){

    for (int i = 0; i < TABLE_SIZE; i ++){

        if (hash_table[i] == NULL){

            printf("\t%i\t --- \n ", i);
        }else {
            printf("\t%i\t%d",i, hash_table[i]->key);
            printf("\n");
        }
    }
}

bool hash_table_insert(vertex *p){
    if(p == NULL) return false;
    int index = hash(p->key);
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

// currently is not used yet. Will need to shorten the code in main() and put code in here and make it more modularized
bool hash_value_insert(vertex *p, int n){
    //printf("p and right is %d %d \n", p->key, p->right);
    p->value[p->right] = n;
    /*
    for(int i = 0; i<p->right+1; i++){
        printf("value is %d \n", p->value[i]);
    }
    */
    return true;
}

int random_walk( vertex * table[], int start, int counter[]){
    
    int currnode = hash(start);

    int walk = 0;
    int total_walk = 100000; // this can be larger if graph is bigger
    
    while(walk <= total_walk){
        counter[currnode] += 1;
        int right = table[currnode]->right;
        int nextnode_index = rand()%(right+1); // it is going to randomly pick the next adjacent node
        int nextnode = table[currnode]->value[nextnode_index];
        currnode = nextnode;

        walk += 1;
    }
    return 0;

}

int *array;

// compare function which is called by sort_array function
int cmp(const void *a, const void *b){
    int ia = *(int *)a;
    int ib = *(int *)b;
    // this is descending order, to make it ascending, just change the < to >, and > to <
    return array[ia] > array[ib] ? -1 : array[ia] < array[ib]; 
}

int sort_array(int * data, int max_size){
    //int data[] ={ 5,4,1,2,3,4,100,50,50,50,10055};
    //int size = sizeof(data)/sizeof(*data);
    int size = max_size;
    int index[size];//use malloc to large size array
    //int i;

    for(int i=0;i<size;i++){
        index[i] = i;
    }
    array = data;
    qsort(index, size, sizeof(*index), cmp);
    printf("\n\ncount_number\tnode\n");
    for(int i=0;i<size;i++){
        printf("%d\t\t\t%d\n", data[index[i]], index[i]);
    }
    return 0;
}
int main() {
//int create_dict() {
    init_hash_table();
    //print_table();
    
    FILE * fp = fopen ("./cora_adj.txt", "r");
    int num1, num2, c;

    while(1) {
      c = fgetc(fp);
      if( feof(fp) ) {
         break;
      }

    fscanf(fp, "%d %d", &num2, &num1);
    //if (num1 <= 10) {
    //printf("%d %d \n", num1, num2);

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

   random_walk(*&hash_table, 1, *&counter);
    /*
    for(int i =1; i <= NODE_NUM; i++){
        printf("counter[%d] value is %d \n", i, counter[i]);

    }
    */
   sort_array(counter, NODE_NUM+1);
    //print_table();
    return 0;
}
