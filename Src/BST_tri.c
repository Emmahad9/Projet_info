#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../Header/BST_tri.h"



struct Node {
    int key;
    char *value;
    struct Node *left, *right;
};

struct Node* newNode(int key, char *value) {
    struct Node* node = (struct Node*)malloc(sizeof(struct Node));
    node->key = key;
    node->value = value;
    node->left = node->right = NULL;
    return node;
}

struct Node* insert(struct Node* node, int key, char *value) {
    if (node == NULL) return newNode(key, value);
    if (key < node->key)
        node->left = insert(node->left, key, value);
    else if (key > node->key)
        node->right = insert(node->right, key, value);
    return node;
}

void inOrder(struct Node *root, FILE *outfile) {
    if (root != NULL) {
        inOrder(root->left, outfile);
        fprintf(outfile, "%d,%s", root->key, root->value);
        inOrder(root->right, outfile);
    }
}


void reverseInOrder(struct Node *root, FILE *outfile) {
    if (root != NULL) {
        reverseInOrder(root->right, outfile);
        fprintf(outfile, "%d,%s", root->key, root->value);
        reverseInOrder(root->left, outfile);
    }
}


void saveToCSV(struct Node *root, char *filename) {
    FILE *outfile = fopen(filename, "w");
    inOrder(root, outfile);
    fclose(outfile);
}


int main(int argc, char *argv[]) {
    struct Node *root = NULL;
    FILE *file = fopen(argv[1], "r");
    char line[1024];
    char name[1024] = "sorted_";
    
    //fgets(line, 1024, file); // Read and discard the first line
    while (fgets(line, 1024, file)) {
        char *first_column = strtok(line, ",");
        int key = atoi(first_column);
        char *value = strdup(line + strlen(first_column) + 1);
        root = insert(root, key, value);
    }
    strcat(name,argv[1]);
    saveToCSV(root, name);
    fclose(file);
    return 0;
}
