#ifndef MAIN_H
#define MAIN_H

/******BST****/
struct Node_BST;
struct Node_BST* insert_BST(struct Node_BST* node, int key, char *value);
void saveToCSV_BST(struct Node_BST *root, char *filename, int ascending);
void inOrder_BST(struct Node_BST *root, FILE *outfile);
void reverseInOrder_BST(struct Node_BST *root, FILE *outfile);

/******AVL****/
struct Node_AVL;

int height(struct Node_AVL *node);
int max(int a, int b);
struct Node_AVL *rightRotate(struct Node_AVL *y);
struct Node_AVL *leftRotate(struct Node_AVL *x);
int getBalance(struct Node_AVL *node);
struct Node_AVL* newNode_AVL(int key, char *value);
struct Node_AVL* insertAVL(struct Node_AVL* node, int key, char *value);
void inOrder_AVL(struct Node_AVL *root, FILE *file);
void reverseInOrder_AVL(struct Node_AVL *root, FILE *file);

/*******tab*****/
struct Data;
int compare(const void *a, const void *b);
#endif
