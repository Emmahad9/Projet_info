#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../Header/main.h"

/************************ BST ************************************/

//structure of a node 
struct Node_BST {
    int key;
    char *value;
    struct Node_BST *left, *right;
};

//create a node
struct Node_BST* newNode_BST(int key, char *value) {
    struct Node_BST* node = (struct Node_BST*)malloc(sizeof(struct Node_BST));
    node->key = key;
    node->value = value;
    node->left = node->right = NULL;
    return node;
}

//insert a node
struct Node_BST* insert_BST(struct Node_BST* node, int key, char *value) {
    if (node == NULL) return newNode_BST(key, value);
    if (key < node->key)
        node->left = insert_BST(node->left, key, value);
    else if (key > node->key)
        node->right = insert_BST(node->right, key, value);
    return node;
}

//infixed path of the tree
void inOrder_BST(struct Node_BST *root, FILE *outfile) {
    if (root != NULL) {
        inOrder_BST(root->left, outfile);
        fprintf(outfile, "%d,%s", root->key, root->value);
        inOrder_BST(root->right, outfile);
    }
}

//infixed reverse tree path
void reverseInOrder_BST(struct Node_BST *root, FILE *outfile) {
    if (root != NULL) {
        reverseInOrder_BST(root->right, outfile);
        fprintf(outfile, "%d,%s", root->key, root->value);
        reverseInOrder_BST(root->left, outfile);
    }
}

//save the sorted data to a file
void saveToCSV_BST(struct Node_BST *root, char *filename, int ascending) {
    FILE *outfile = fopen(filename, "w");
    if (ascending == 0){
        reverseInOrder_BST(root, outfile);
    }
    else{
        inOrder_BST(root, outfile);
    }
    fclose(outfile);
}


/************************ AVL ************************************/

//structure of a node
struct Node_AVL {
    int key;
    char *value;
    struct Node_AVL *left;
    struct Node_AVL *right;
    int height;
};

//determining the height of a node
int height(struct Node_AVL *node) {
    if (node == NULL)
        return 0;
    return node->height;
}

//determination of the max between two values
int max(int a, int b) {
    return (a > b) ? a : b;
}

//right rotation
struct Node_AVL *rightRotate(struct Node_AVL *y) {
    struct Node_AVL *x = y->left;
    struct Node_AVL *T2 = x->right;
    x->right = y;
    y->left = T2;
    y->height = max(height(y->left), height(y->right)) + 1;
    x->height = max(height(x->left), height(x->right)) + 1;
    return x;
}

//left rotation
struct Node_AVL *leftRotate(struct Node_AVL *x) {
    struct Node_AVL *y = x->right;
    struct Node_AVL *T2 = y->left;
    y->left = x;
    x->right = T2;
    x->height = max(height(x->left), height(x->right)) + 1;
    y->height = max(height(y->left), height(y->right)) + 1;
    return y;
}

//balancing factor
int getBalance(struct Node_AVL *node) {
    if (node == NULL)
        return 0;
    return height(node->left) - height(node->right);
}

//create a node
struct Node_AVL* newNode_AVL(int key, char *value) {
    struct Node_AVL* node = (struct Node_AVL*) malloc(sizeof(struct Node_AVL));
    node->key = key;
    node->value = value;
    node->left = NULL;
    node->right = NULL;
    node->height = 1;  // new node is initially added at leaf
    return node;
}

//insert a node
struct Node_AVL* insert_AVL(struct Node_AVL* node, int key, char *value) {
    if (node == NULL)
        return newNode_AVL(key, value);
    if (key < node->key)
        node->left = insert_AVL(node->left, key, value);
    else if (key > node->key)
        node->right = insert_AVL(node->right, key, value);
    else
        return node;
    node->height = 1 + max(height(node->left), height(node->right));
    int balance = getBalance(node);
    if (balance > 1 && key < node->left->key)
        return rightRotate(node);
    if (balance < -1 && key > node->right->key)
        return leftRotate(node);
    if (balance > 1 && key > node->left->key) {
        node->left = leftRotate(node->left);
        return rightRotate(node);
    }
    if (balance < -1 && key < node->right->key) {
        node->right = rightRotate(node->right);
        return leftRotate(node);
    }
    return node;
}

//infixed path of the tree
void inOrder_AVL(struct Node_AVL *root, FILE *file) {
    if (root != NULL) {
        inOrder_AVL(root->left, file);
        fprintf(file, "%d,%s",root->key, root->value);
        inOrder_AVL(root->right, file);
    }
}

//infixed reverse tree path
void reverseInOrder_AVL(struct Node_AVL *root, FILE *file) {
    if (root != NULL) {
        reverseInOrder_AVL(root->right, file);
        fprintf(file, "%d,%s",root->key, root->value);
        reverseInOrder_AVL(root->left, file);
    }
}

//save the sorted data to a file
void saveToCSV_AVL(struct Node_AVL *root, char *filename, void (*traverse)(struct Node_AVL *, FILE *)) {
    FILE *outfile = fopen(filename, "w");
    traverse(root, outfile);
    fclose(outfile);
}

/**************************** Tab ****************/

//structure of the table data
struct Data {
    int key;
    char *value;
};

int compare(const void *a, const void *b) {
    struct Data *data1 = (struct Data *)a;
    struct Data *data2 = (struct Data *)b;
    return data1->key - data2->key;
}


/************************    Main ********************/

int main(int argc, char *argv[]) {
    int cpt = 0;
    int ascending = 1;
    char input[1024];
    char output[1024];
    char tri_type[1024] = "--avl";
    for (cpt=0; cpt<argc; cpt++){
        // Input path of the file
        if (strcmp(argv[cpt],"-f") == 0){
            strcpy(input,argv[cpt+1]);
        }
        // Output path of the file
        if(strcmp(argv[cpt],"-o") == 0){
            strcpy(output,argv[cpt+1]);
        }

        // Path if ascending or descending
        if(strcmp(argv[cpt],"-r") == 0){
            ascending = 0;
        }
        // type of sorting algorithm
        if(strcmp(argv[cpt],"--tab") == 0){
            strcpy(tri_type,"--tab");
        }
        if (strcmp(argv[cpt],"--abr") == 0){
            strcpy(tri_type,"--abr");
        }
    }
    /************************AVL Main*********************/
    if (strcmp(tri_type,"--avl") == 0){
        FILE *file = fopen(input, "r");
        struct Node_AVL *root = NULL;
        char line[1024];
        char name[1024] = "sorted_";
        //read the file line by line
        while (fgets(line, 1024, file)) {
            char *first_column = strtok(line, ",");
            int key = atoi(strtok(line, ","));
            char *value = strdup(line + strlen(first_column) + 1);
            root = insert_AVL(root, key, value);
        }
        fclose(file);
        strcat(name,argv[2]); 
        // Save the data in ascending order
        if (ascending == 0){
            saveToCSV_AVL(root, output, inOrder_AVL);
        }
        else{
            saveToCSV_AVL(root, output, reverseInOrder_AVL);
        }
        // Save the data in descending order
        //saveToCSV(root, "data_descending.csv", reverseInOrder);
        free(root);
        return 0;
    }
    /************************BST Main*********************/
    else if (strcmp(tri_type,"--abr") == 0 ){
        struct Node_BST *root = NULL;
        FILE *file = fopen(input, "r");
        char line[1024];
        char name[1024] = "sorted_";
        //read the file line by line
        while (fgets(line, 1024, file)) {
            char *first_column = strtok(line, ",");
            int key = atoi(first_column);
            char *value = strdup(line + strlen(first_column) + 1);
            root = insert_BST(root, key, value);
        }
        strcat(name,argv[2]);
        saveToCSV_BST(root, output,ascending);
        fclose(file);
        free(root);
        return 0;
    }
    /*******************TAB****************************/
    else if (strcmp(tri_type,"--tab") == 0 ){ 
        FILE *file = fopen(input, "r");
        char line[1024];
        int size = 0;
        struct Data *data = NULL;
        char *first_line = NULL;
        char name[1024] = "sorted_";
        int i = 0;
        //read the file line by line
        while (fgets(line, 1024, file)) { 
            if (i == 0) {
                first_line = strdup(line);
                i++;
                continue;
            }
            data = realloc(data, (size + 1) * sizeof(struct Data)); 
            char *first_column = strtok(line, ",");
            int key = atoi(strtok(line, ",")); 
            char *value = strdup(line + strlen(first_column) + 1);
            data[size].key = key;
            data[size].value = value;
            size++;
        }
        fclose(file);
        //sorting of table data
        qsort(data, size, sizeof(struct Data), compare); 

        // Save the data in ascending order
        strcat(name,argv[2]);
        FILE *outfile = fopen(output, "w");
        fprintf(outfile, "%s", first_line);
        if (ascending == 0){
            for (int i = size - 1; i >= 0; i--){
                fprintf(outfile, "%s", data[i].value);
            }
        }
        else{
            for (int i = 0; i < size; i++) {
                fprintf(outfile, "%d,%s",data[i].key,data[i].value);
            }
        }
        fclose(outfile);
        free(data);
        return 0;
    }
    else{
        printf("Error\n");
        return 3;
    }
}
