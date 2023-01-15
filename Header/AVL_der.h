#ifndef AVL_H
#define AVL_H

struct Node;

int height(struct Node *node);
int max(int a, int b);
struct Node *rightRotate(struct Node *y);
struct Node *leftRotate(struct Node *x);
int getBalance(struct Node *node);
struct Node* newNode(int key, char *value);
struct Node* insertAVL(struct Node* node, int key, char *value);
void inOrder(struct Node *root, FILE *file);
void reverseInOrder(struct Node *root, FILE *file);

#endif
