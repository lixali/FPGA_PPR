#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include <math.h>

#include "dictionary.h"
#include "random_walk.h"
#include "sort_array.h"
#include "calculate_stats.h"

void try_insert(int num, int other){
    int index = hash(num);
    if (my_hash_table[index] == NULL) {
      my_hash_table[index] = init_array(index, 1);
    }
    else{
      int right = my_hash_table[index]->right;
      my_hash_table[index] = resize_array(my_hash_table[index],right+2);
    }

    hash_value_insert(my_hash_table[index], other); 
}

int main(int argc, char** argv) {
  printf("HI");

  //initialize counter
  /*counter = malloc(NODE_NUM * sizeof(int *));
  for(int i = 0; i < NODE_NUM; i++){
    //counter[i] = malloc(MAX_STEPS * sizeof(int));
    counter[i] = malloc(COMB * sizeof(int));
  }*/
  //counter.resize(NODE_NUM, std::vector<int>(COMB));

  init_hash_table();
    //print_table();
  printf("adjacency list file name: %s\n", argv[1]);

  FILE * fp = fopen (argv[1], "r"); // this file input should also be as a variable
  int num1, num2, c;

  //read in graph
  while(1) {
    fscanf(fp, "%d %d", &num1, &num2);
    //if (num1 <= 10) {
    //printf("%d %d \n", num1, num2);
    if( feof(fp) ) {
         break;
      }
    
    try_insert(num1, num2);
    try_insert(num2, num1);
  }

  //read in top community
  printf("chosen community file name: %s\n", argv[2]); // select this in python

  FILE * fp2 = fopen(argv[2], "r");
  int* seedset = (int*) malloc(SEED_COUNT * sizeof(int));

  int community_size = 16;
  int node_count = 0;
  int* community_nodes = (int*) malloc(16 * sizeof(int));
  int node;

  while(!feof(fp2)){
    fscanf(fp2, "%d", &node);
    community_nodes[node_count] = node;
    printf("read new community node %d \n", node);
    node_count++;
    if(node_count >= community_size){
      community_size *= 2;
      community_nodes = (int*) realloc(community_nodes, community_size * sizeof(int));
    }
  }

  for(int i = 0; i < SEED_COUNT; i++){
    int index = rand() % node_count;
    seedset[i] = community_nodes[index];
  }

  //random_walk(*&hash_table, *&counter, M_RW, score[TABLE_SIZE-1]);
  random_walk(*&my_hash_table, *&counter, seedset, M_RW, SEED_COUNT, MAX_STEPS, NODE_NUM);

   /*for(int i =1; i <= NODE_NUM; i++){
       printf("node is %d, score is %f \n", i, score[i]);
   } */

  sort_array(score, NODE_NUM+1);


  /*int * array = (int*) malloc((NODE_NUM + 1) * sizeof(int));
  for(int i=0;i<NODE_NUM + 1;i++){
      array[i] = i;
  }*/
  calc_stats(index_array, NODE_NUM+1, community_nodes, node_count, 1.0);
  //print_table();
  return 0;
}
