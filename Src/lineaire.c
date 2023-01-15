#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../Header/lineaire.h"

struct Data {
    int key;
    char *value;
};

int compare(const void *a, const void *b) {
    struct Data *data1 = (struct Data *)a;
    struct Data *data2 = (struct Data *)b;
    return data1->key - data2->key;
}

int main(int argc, char *argv[]) {
    FILE *file = fopen(argv[1], "r");
    char line[1024];
    int size = 0;
    struct Data *data = NULL;
    char *first_line = NULL;
    char name[1024] = "sorted_";
    int i = 0;
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
    qsort(data, size, sizeof(struct Data), compare);

    // Save the data in ascending order
    strcat(name,argv[1]);
    FILE *outfile = fopen(name, "w");
    fprintf(outfile, "%s", first_line);
    for (int i = 0; i < size; i++) {
        fprintf(outfile, "%d,%s",data[i].key,data[i].value);
    }
    fclose(outfile);

    // Save the data in descending order
    /*outfile = fopen("data_descending_lineaire.csv", "w");
    fprintf(outfile, "%s", first_line);
    for (int i = size - 1; i >= 0; i--) {
        fprintf(outfile, "%s", data[i].value);
    }
    fclose(outfile);
    free(data);
    free(first_line);*/
    return 0;
}
