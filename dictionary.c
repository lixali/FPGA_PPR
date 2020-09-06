#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// list_node has value and next pointer
typedef struct list_node {
    int value;
    struct list_node* next;
} list_node;

// list has a list_node type pointer call head
typedef struct list {
    list_node* head;
} list;

// dict_entry has int type value called type, char type pointer called key, void type pointer called value, a dict_entry type pointer called next
typedef struct dict_entry {
    int key;
    int * value;
    struct dict_entry* next;
} dict_entry;

// dict_t has dict_entry type pointer called head
typedef struct dict_t {
    dict_entry* head;
} dict_t;

// return a dict_t type pointer d, d's dict_entry type head is pointing to NULL. 
dict_t* dictAlloc(void) {
    dict_t* d = malloc(sizeof(dict_t)); // just declared a pointer size and that is what is does?  
    d->head = NULL; // why point to NULL? 
    return d; 
}

dict_entry* addItem(dict_t* dict, dict_entry* prev, int key, int value, int length) {
    int new[length];
    dict_entry* de = malloc(sizeof(*de));

    if(prev == 0){
    dict_entry* de = malloc(sizeof(*de));

    de->key = key;
    }else{
        //printf("%d \n", prev);
        //dict_entry * de;
        de = prev;
        //dict_entry * de = prev;
    }
    int a;
    if (length == 1){

        new[0] = value;
        de->value = new;
        printf("first ");
        //printf("%d ", de);

        //printf("%d \n", *(de->value));

    }else{
        printf("second ");
        //printf("%d ", de);

        //printf("%d \n",*(de->value));
    for(a = 0; a < length-1; a++){
        //new[a] = *(de->value+a);
        //printf("enter\n");
        //printf("%d %d \n",a, *(de->value+a));

    }
        new[length-1] = value;
        de->value = new;

    for(a = 0; a < length-1; a++){
        printf("check\n");
        printf("%d %d \n",a, *(de->value+a));

    }
    }
    //new[length-1] = value;
    
    
    de->next = dict->head;
    dict->head = de;
    return de;
}



int main(int argc, char** argv){
    printf("Hello, World\n");
    dict_t* d = dictAlloc();
    dict_entry* de;

    list* l = malloc(sizeof(*l));
    list_node* n = malloc(sizeof(*n));
    int data[100]; 
    int key;
    static  dict_entry *pointers[100000] = {0};
    //n->value = "value";
    n->value = 22222;
    l->head = n;
    pointers[11] = addItem(d, pointers[11], 11, 22, 1);
    printf("%d \n", pointers[11]);
    pointers[11] = addItem(d, pointers[11], 11, 33, 2);
        
        
    pointers[3] = addItem(d, pointers[3], 3, 6, 2);

    FILE * fp;
    fp = fopen ("./cora_adj.txt", "r");
    int c;
    int num1;
    int num2;
    printf("pointers ");
    printf("%d", pointers[100]);
    int b;
    while(1) {
      c = fgetc(fp);
      if( feof(fp) ) {
         break;
      }


    if (b < 5){
        fscanf(fp, "%d %d", &num2, &num1);
        printf("%d %d \n", num1, num2);
        printf("%d \n", num1+num2);
        int a;
        int b;
        a = num1;
        b = num2;
        pointers[a] = addItem(d, pointers[a], a, b, 5);
        //pointers[3] = addItem(d, pointers[3], 3, 5, 2);

    }   
    b++;   

   }
    fclose(fp);

    return 0;

}
