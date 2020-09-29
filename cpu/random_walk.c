#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include <math.h>

//#include "dictionary.h"
#include "random_walk.h"
#include "sort_array.h"

//int random_walk( vertex * table[], int counter[NODE_NUM+1][COMB], int m_rw, double score[TABLE_SIZE]){
int random_walk( vertex * table[], int** counter, int* seedset, int m_rw, int seed_count, int max_steps, int node_num){
    /* the following 3 nested for loop is to fill up the counter[][] 
       counter[NODE_NUM+1][COMB] is a 2D array, it records the number of times a node is visted when specific i step and start node
       COMB is ranging from 0 MAX_STEPS * (NODE_NUM+1); 
    */

    for(int s=0; s<seed_count; s++){
        int startn = hash(seedset[s]); // the variable use slight different naming as below is because it is easier copy the code somewhere else debugging
        /* m times l-step walk for each seed node*/
        for(int m=1; m<=m_rw; m++){
            int currn = startn;
            for(int i=0; i < max_steps; i++){
                // y start from 0, y is a funciton of start node and i, which is intended
                int y = (startn-1)* max_steps + i; 
                //int y = i;
                counter[currn][y] += 1;  // currn start from 1

                // the following 3 lines is to random walk and pick one neighbour node
                int ri = table[currn]->right;  
                int nnode_index = rand()%(ri+1); 
                int nnode = table[currn]->neighbours[nnode_index];
                currn = nnode;      
                }
        }        
    }

    int currnode, startnode, startnode_degree, index;


    // the following 3 nested for loop is to caculate the score for each node
    for(int curr=1; curr<=node_num; curr++){
    //for(int curr = 1; curr <= 1000; curr)
    //int curr = -1;
    //int ** counter_max = counter + node_num;
    //for(int ** ctr = counter; ctr < counter_max; ctr++){
        //curr++;
        if(curr % 1000 == 0) printf("%d\n", curr);
        int currnode = hash(curr);

        for(int i=0; i< max_steps; i++){
            for(int start=0;start<=seed_count; start++){
                startnode = hash(seedset[start]); // slight different naming as above
                //int startnode = seedset[start];

                startnode_degree = table[startnode]->right+1;
                //int index = i;
                index = (startnode-1)*max_steps + i;

                // equation:  (alpha ^ i) * counter[][] * start node's degree
                score[currnode] += pow(ALPHA, i) * counter[currnode][index] * startnode_degree; 
                //score[curr] += pow(ALPHA, i) * (*ctr)[index] * startnode_degree; 
            }
        }
    }

/*
    for(int curr=1; curr<=80000; curr++){
    //for(int curr = 1; curr <= 1000; curr)
    //int curr = -1;
    //int ** counter_max = counter + node_num;
    //for(int ** ctr = counter; ctr < counter_max; ctr++){
        //curr++;
        if(curr % 1000 == 0) printf("%d\n", curr);
        int currnode = hash(curr);

        for(int i=0; i< max_steps; i++){
            for(int start=0;start<=seed_count; start++){
                startnode = hash(seedset[start]); // slight different naming as above
                //int startnode = seedset[start];

                startnode_degree = table[startnode]->right+1;
                //int index = i;
                index = (startnode-1)*max_steps + i;

                // equation:  (alpha ^ i) * counter[][] * start node's degree
                score[currnode] += pow(ALPHA, i) * counter[currnode][index] * startnode_degree; 
                //score[curr] += pow(ALPHA, i) * (*ctr)[index] * startnode_degree; 
            }
        }
    }

    for(int curr=80000; curr<=node_num; curr++){
    //for(int curr = 1; curr <= 1000; curr)
    //int curr = -1;
    //int ** counter_max = counter + node_num;
    //for(int ** ctr = counter; ctr < counter_max; ctr++){
        //curr++;
        if(curr % 1000 == 0) printf("%d\n", curr);
        int currnode = hash(curr);

        for(int i=0; i< max_steps; i++){
            for(int start=0;start<=seed_count; start++){
                startnode = hash(seedset[start]); // slight different naming as above
                //int startnode = seedset[start];

                startnode_degree = table[startnode]->right+1;
                //int index = i;
                index = (startnode-1)*max_steps + i;

                // equation:  (alpha ^ i) * counter[][] * start node's degree
                score[currnode] += pow(ALPHA, i) * counter[currnode][index] * startnode_degree; 
                //score[curr] += pow(ALPHA, i) * (*ctr)[index] * startnode_degree; 
            }
        }
    }*/


    /*
    for(int curr=1; curr<=node_num; curr++){
        if(curr % 1000 == 0) printf("%d\n", curr);
        int currnode = hash(curr);
        for(int i=0; i< max_steps; i++){
            for(int start=0;start<=seed_count; start++){
                int startnode = hash(seedset[start]); // slight different naming as above

                int startnode_degree = table[startnode]->right+1;
                int index = (startnode-1)*max_steps + i;

                // equation:  (alpha ^ i) * counter[][] * start node's degree
                score[currnode] += pow(ALPHA, i) * counter[currnode][index] * startnode_degree; 
            }
        }
    }
    */

    // And each node's score needs to be divided by its own degree
    for(int i=1; i <= node_num; i++){
        int curr = hash(i);
        score[curr] /= (table[curr]->right+1);
    }
    return 0;

}


