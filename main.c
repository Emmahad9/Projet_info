#include <stdio.h>
#include <stdlib.h>
#include <string.h>



struct Node_BST {
    int key;
    char *value;
    struct Node_BST *left, *right;
};

struct Node_BST* newNode_BST(int key, char *value) {
    struct Node_BST* node = (struct Node_BST*)malloc(sizeof(struct Node_BST));
    node->key = key;
    node->value = value;
    node->left = node->right = NULL;
    return node;
}

struct Node_BST* insert_BST(struct Node_BST* node, int key, char *value) {
    if (node == NULL) return newNode_BST(key, value);
    if (key < node->key)
        node->left = insert(node->left, key, value);
    else if (key > node->key)
        node->right = insert(node->right, key, value);
    return node;
}

void inOrder_BST(struct Node_BST *root, FILE *outfile) {
    if (root != NULL) {
        inOrder_BST(root->left, outfile);
        fprintf(outfile, "%d,%s", root->key, root->value);
        inOrder_BST(root->right, outfile);
    }
}


void reverseInOrder_BST(struct Node_BST *root, FILE *outfile) {
    if (root != NULL) {
        reverseInOrder_BST(root->right, outfile);
        fprintf(outfile, "%d,%s", root->key, root->value);
        reverseInOrder_BST(root->left, outfile);
    }
}


void saveToCSV_BST(struct Node_BST *root, char *filename) {
    FILE *outfile = fopen(filename, "w");
    inOrder(root, outfile);
    fclose(outfile);
}


/************************ AVL ************************************/

struct Node_AVL {
    int key;
    char *value;
    struct Node_AVL *left;
    struct Node_AVL *right;
    int height;
};


int height(struct Node_AVL *node) {
    if (node == NULL)
        return 0;
    return node->height;
}

int max(int a, int b) {
    return (a > b) ? a : b;
}

struct Node_AVL *rightRotate(struct Node_AVL *y) {
    struct Node_AVL *x = y->left;
    struct Node_AVL *T2 = x->right;

    x->right = y;
    y->left = T2;

    y->height = max(height(y->left), height(y->right)) + 1;
    x->height = max(height(x->left), height(x->right)) + 1;

    return x;
}

struct Node_AVL *leftRotate(struct Node *x) {
    struct Node_AVL *y = x->right;
    struct Node_AVL *T2 = y->left;

    y->left = x;
    x->right = T2;

    x->height = max(height(x->left), height(x->right)) + 1;
    y->height = max(height(y->left), height(y->right)) + 1;

    return y;
}

int getBalance(struct Node_AVL *node) {
    if (node == NULL)
        return 0;
    return height(node->left) - height(node->right);
}

struct Node_AVL* newNode_AVL(int key, char *value) {
    struct Node_AVL* node = (struct Node*) malloc(sizeof(struct Node));
    node->key = key;
    node->value = value;
    node->left = NULL;
    node->right = NULL;
    node->height = 1;  // new node is initially added at leaf
    return node;
}

struct Node_AVL* insert_AVL(struct Node* node, int key, char *value) {
    if (node == NULL)
        return newNode(key, value);
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

void inOrder_AVL(struct Node_AVL *root, FILE *file) {
    if (root != NULL) {
        inOrder_AVL(root->left, file);
        fprintf(file, "%d,%s",root->key, root->value);
        inOrder_AVL(root->right, file);
    }
}

void reverseInOrder_AVL(struct Node_AVL *root, FILE *file) {
    if (root != NULL) {
        reverseInOrder_AVL(root->right, file);
        fprintf(file, "%d,%s",root->key, root->value);
        reverseInOrder_AVL(root->left, file);
    }
}

void saveToCSV_AVL(struct Node_AVL *root, char *filename, void (*traverse)(struct Node_AVL *, FILE *)) {
    FILE *outfile = fopen(filename, "w");
    traverse(root, outfile);
    fclose(outfile);
}

int main_AVL(int argc, char *argv[]) {
    FILE *file = fopen(argv[1], "r");
    struct Node_AVL *root = NULL;
    char line[1024];
    char name[1024] = "sorted_";
    //fgets(line, 1024, file); // Read and discard the first line
    while (fgets(line, 1024, file)) {
        char *first_column = strtok(line, ",");
        int key = atoi(strtok(line, ","));
        char *value = strdup(line + strlen(first_column) + 1);
        root = insert_AVL(root, key, value);
    }
    fclose(file);
    strcat(name,argv[1]);
    // Save the data in ascending order
        saveToCSV_AVL(root, name, inOrder);

    // Save the data in descending order
    //saveToCSV(root, "data_descending.csv", reverseInOrder);
    return 0;
}

int main_BST(int argc, char *argv[]) {
    struct Node_BST *root = NULL;
    FILE *file = fopen(argv[1], "r");
    char line[1024];
    char name[1024] = "sorted_";
    
    //fgets(line, 1024, file); // Read and discard the first line
    while (fgets(line, 1024, file)) {
        char *first_column = strtok(line, ",");
        int key = atoi(first_column);
        char *value = strdup(line + strlen(first_column) + 1);
        root = insert_BST(root, key, value);
    }
    strcat(name,argv[1]);
    saveToCSV_BST(root, name);
    fclose(file);
    return 0;
}

int main(int argc, char *argv[]) {
    /************************AVL Main*********************/
    if (argv[1] == "--avl" || argc == 0){
        FILE *file = fopen(argv[1], "r");
        struct Node_AVL *root = NULL;
        char line[1024];
        char name[1024] = "sorted_";
        //fgets(line, 1024, file); // Read and discard the first line
        while (fgets(line, 1024, file)) {
            char *first_column = strtok(line, ",");
            int key = atoi(strtok(line, ","));
            char *value = strdup(line + strlen(first_column) + 1);
            root = insert_AVL(root, key, value);
        }
        fclose(file);
        strcat(name,argv[1]);
        // Save the data in ascending order
            saveToCSV_AVL(root, name, inOrder);

        // Save the data in descending order
        //saveToCSV(root, "data_descending.csv", reverseInOrder);
        return 0;
    }
    /************************BST Main*********************/
    elif (argv[1] == "--abr"){
        struct Node_BST *root = NULL;
        FILE *file = fopen(argv[1], "r");
        char line[1024];
        char name[1024] = "sorted_";
        
        //fgets(line, 1024, file); // Read and discard the first line
        while (fgets(line, 1024, file)) {
            char *first_column = strtok(line, ",");
            int key = atoi(first_column);
            char *value = strdup(line + strlen(first_column) + 1);
            root = insert_BST(root, key, value);
        }
        strcat(name,argv[1]);
        saveToCSV_BST(root, name);
        fclose(file);
        return 0;
    }
    else{}
    return 0;
}
    