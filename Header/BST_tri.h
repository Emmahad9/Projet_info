#ifndef BST_H
#define BST_H


struct Node;
struct Node* insert(struct Node* node, int key, char *value);
void saveToCSV(struct Node *root, char *filename);
void inOrder(struct Node *root, FILE *outfile);
void reverseInOrder(struct Node *root, FILE *outfile);
#endif
