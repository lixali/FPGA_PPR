#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include <math.h>

//#include <dictionary.h>

#define TABLE_SIZE 100000
// cora_adj.txt has 2708 nodes; For other graphs, it can set it to be same as TABLE_SIZE if number of nodes is not known
#define NODE_NUM 2708 
#define MAX_STEPS 7
#define ALPHA 0.95
#define M_RW 4000 // 4000 random walks
#define SEED_RATIO 0.05

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

// when adding element to vertex->value[], memory needs to be resized
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
// counter is used to keep track of number of times of visting node "u" starting from node "v" at step i 
// Therefore, the counter Y column will have to be COMB = MAX_STEPS * (NODE_NUM+1)
// counter x index will go from 1 to NODE_NUM, y index will to from 0 to COMB-1
#define COMB MAX_STEPS*(NODE_NUM+1)
int counter[NODE_NUM+1][COMB] = {0}; // by default, it should also be 0 without assigning 
double score[TABLE_SIZE];


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

// currently is not used yet. Will need to shorten the code in main() and put code in here and make it more modularized
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

// add node to the end of the list vertex->value[] 
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

int random_walk( vertex * table[], int counter[NODE_NUM+1][COMB], int m_rw){

    int ridx = 0;
    int seed_count=floor(NODE_NUM*SEED_RATIO); // seed_count is number of seeds required
    int seedset[seed_count]; // contains the seeds nodes
    int visited[NODE_NUM+1] =  {0};

    /* the following for loop is to create seed set */
    for(int i=0; i<seed_count;i++){
        
        int seed = rand()%(NODE_NUM)+1; /*seed is randomly pick from 1 to NODE_NUM here */

        /* the while loop and visited[] is to make sure that there are seed_count number of unique nodes in in seedset */
        while(visited[seed] == 1){ 
            seed = rand()%(NODE_NUM)+1;
        }
        seedset[ridx] = seed;
        visited[seed] = 1;
        ridx += 1;
    }

    /* the following 3 nested for loop is to fill up the counter[][] 
       counter[NODE_NUM+1][COMB] is a 2D array, it records the number of times a node is visted when specific i step and start node
       COMB is ranging from 0 MAX_STEPS * (NODE_NUM+1); 
    */

    for(int s=0; s<seed_count; s++){
        int startn = hash(seedset[s]); // the variable use slight different naming as below is because it is easier copy the code somewhere else debugging
        int currn = startn;
        /* m times l-step walk for each seed node*/
        for(int m=1; m<=m_rw; m++){
            for(int i=0; i<=MAX_STEPS; i++){
                // y start from 0, y is a funciton of start node and i, which is intended
                int y = (startn-1)*MAX_STEPS + i; 
                counter[currn][y] += 1;  // currn start from 1

                // the following 3 lines is to random walk and pick one neighbour node
                int ri = table[currn]->right;  
                int nnode_index = rand()%(ri+1); 
                int nnode = table[currn]->value[nnode_index];
                currn = nnode;      
                }
        }        
    }

    // the following 3 nested for loop is to caculate the score for each node
    for(int curr=1; curr<=NODE_NUM; curr++){
        int currnode = hash(curr);
        for(int i=0; i<=MAX_STEPS; i++){
            for(int start=1;start<=NODE_NUM; start++){
                int startnode = hash(start); // slight different naming as above
                
                int startnode_degree = table[startnode]->right+1;
                int index = (startnode-1)*MAX_STEPS + i;

                // equation:  (alpha ^ i) * counter[][] * start node's degree
                score[currnode] += pow(ALPHA, i) * counter[currnode][index] * startnode_degree; 

            }
        }
    }

    // And each node's score needs to be divided by its own degree
    for(int i=1; i <= NODE_NUM; i++){
        int curr = hash(i);
        score[curr] /= (table[curr]->right+1);
    }
    return 0;

}

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
    FILE * fptr = fopen("sorted_nodes.txt", "w");
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
int main() {
//int create_dict() {
    init_hash_table();
    //print_table();
    
    FILE * fp = fopen ("./cora_adj.txt", "r");
    int num1, num2, c;

    while(1) {


    fscanf(fp, "%d %d", &num1, &num2);
    //if (num1 <= 10) {
    //printf("%d %d \n", num1, num2);
    if( feof(fp) ) {
         break;
      }
    
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

   random_walk(*&hash_table, *&counter, M_RW);
    
   /*for(int i =1; i <= NODE_NUM; i++){

       printf("node is %d, score is %f \n", i, score[i]);
   } */

   sort_array(score, NODE_NUM+1);
    //print_table();
    return 0;
}
