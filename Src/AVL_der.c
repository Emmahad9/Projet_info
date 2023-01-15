#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../Header/AVL_der.h"

struct Node {
    int key;
    char *value;
    struct Node *left;
    struct Node *right;
    int height;
};


int height(struct Node *node) {
    if (node == NULL)
        return 0;
    return node->height;
}

int max(int a, int b) {
    return (a > b) ? a : b;
}

struct Node *rightRotate(struct Node *y) {
    struct Node *x = y->left;
    struct Node *T2 = x->right;

    x->right = y;
    y->left = T2;

    y->height = max(height(y->left), height(y->right)) + 1;
    x->height = max(height(x->left), height(x->right)) + 1;

    return x;
}

struct Node *leftRotate(struct Node *x) {
    struct Node *y = x->right;
    struct Node *T2 = y->left;

    y->left = x;
    x->right = T2;

    x->height = max(height(x->left), height(x->right)) + 1;
    y->height = max(height(y->left), height(y->right)) + 1;

    return y;
}

int getBalance(struct Node *node) {
    if (node == NULL)
        return 0;
    return height(node->left) - height(node->right);
}

struct Node* newNode(int key, char *value) {
    struct Node* node = (struct Node*) malloc(sizeof(struct Node));
    node->key = key;
    node->value = value;
    node->left = NULL;
    node->right = NULL;
    node->height = 1;  // new node is initially added at leaf
    return node;
}

struct Node* insertAVL(struct Node* node, int key, char *value) {
    if (node == NULL)
        return newNode(key, value);
    if (key < node->key)
        node->left = insertAVL(node->left, key, value);
    else if (key > node->key)
        node->right = insertAVL(node->right, key, value);
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

void inOrder(struct Node *root, FILE *file) {
    if (root != NULL) {
        inOrder(root->left, file);
        fprintf(file, "%d,%s",root->key, root->value);
        inOrder(root->right, file);
    }
}

void reverseInOrder(struct Node *root, FILE *file) {
    if (root != NULL) {
        reverseInOrder(root->right, file);
        fprintf(file, "%d,%s",root->key, root->value);
        reverseInOrder(root->left, file);
    }
}

void saveToCSV(struct Node *root, char *filename, void (*traverse)(struct Node *, FILE *)) {
    FILE *outfile = fopen(filename, "w");
    traverse(root, outfile);
    fclose(outfile);
}

int main(int argc, char *argv[]) {
    FILE *file = fopen(argv[1], "r");
    struct Node *root = NULL;
    char line[1024];
    char name[1024] = "sorted_";
    //fgets(line, 1024, file); // Read and discard the first line
    while (fgets(line, 1024, file)) {
        char *first_column = strtok(line, ",");
        int key = atoi(strtok(line, ","));
        char *value = strdup(line + strlen(first_column) + 1);
        root = insertAVL(root, key, value);
    }
    fclose(file);
    strcat(name,argv[1]);
    // Save the data in ascending order
        saveToCSV(root, name, inOrder);

    // Save the data in descending order
    //saveToCSV(root, "data_descending.csv", reverseInOrder);
    return 0;
}

