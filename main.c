#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include <math.h>

#include "dictionary.h"
#include "random_walk.h"
#include "sort_array.h"


int main() {
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
   }

   //random_walk(*&hash_table, *&counter, M_RW, score[TABLE_SIZE-1]);
   random_walk(*&hash_table, *&counter, M_RW);

   /*for(int i =1; i <= NODE_NUM; i++){
       printf("node is %d, score is %f \n", i, score[i]);
   } */

   sort_array(score, NODE_NUM+1);
    //print_table();
    return 0;
}