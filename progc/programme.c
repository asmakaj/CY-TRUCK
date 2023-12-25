#include<stdio.h>
#include <stdlib.h>


typedef struct tree{
  int route_ID;
  int step_ID;
  float distance;
  float min;
  float max;
  int n;
  struct tree* pLeft;
  struct tree* pRight;
}Tree;

typedef Tree* pTree;

pTree createNode(int route_ID, int step_ID, float distance) {
    pTree pNew = malloc(sizeof(Tree));
    // NE PAS OUBLIER DE FREE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    if (pNew == NULL) {
        printf("Erreur au niveau du malloc");
        exit(1);
    }


    pNew->route_ID = route_ID;
    pNew->step_ID = step_ID;
    pNew->distance = distance;
    pNew->min = 0;
    pNew->max = 0;
    pNew->n = 1;
    pNew->pLeft = NULL;
    pNew->pRight = NULL;

    return pNew;
}

/*
void insert(Tree** root, int route_ID, int step_ID, float distance) {
    if (*root == NULL) {

        *root = createNode(route_ID, step_ID, distance);
    } else {
        // Parcours l'abre et ajt le chaino au bon endroit
        if (route_ID < (*root)->route_ID) {
            insert(&((*root)->pLeft), route_ID, step_ID, distance);
        } else {
            insert(&((*root)->pRight), route_ID, step_ID, distance);
        }
    }
}
*/

void insert(pTree root, int route_ID, int step_ID, float distance) {
    if (root == NULL) {
        root = createNode(route_ID, step_ID, distance);
    } else {
        // Parcours l'arbre et ajoute le nœud au bon endroit
        if (route_ID < root->route_ID) {
            insert(root->pLeft, route_ID, step_ID, distance);
        } else {
            insert(root->pRight, route_ID, step_ID, distance);
        }
    }
}

// Function to read data from CSV and build the tree
void readCSV(const char* data, pTree root) {
    FILE* file = fopen(data, "r");
    if (file == NULL) {
        perror("Error opening the file");
        exit(EXIT_FAILURE);
    }

    int route_ID, step_ID;
    float distance;

    while (fscanf(file, "%d;%d;%f", &route_ID, &step_ID, &distance) == 3) {
        // Insert the values into the tree
        insert(root, route_ID, step_ID, distance);
    }

    fclose(file);
}

void infixreverse(pTree p){
    printf("1111111\n");
    if(p != NULL){
        infixreverse(p->pRight);
        printf("Route_ID: %d, Step_ID: %d, Distance: %f, Min: %f, Max: %f, n: %d\n", p->route_ID, p->step_ID, p->distance, p->min, p->max, p->n);
        // printf("[%02d]", p->route_ID);
        printf("test parcours \n");
        infixreverse(p->pLeft);
    } 
    else{
        printf("l'arbre est NULL\n");
    }
}


void freeTree(Tree *root) {
    // Si le nœud est NULL, il n'y a rien à libérer, donc return
    if (root == NULL) {
        return;
    }

    // Récursivement libérer le sous-arbre gauche et le sous-arbre droit
    freeTree(root->pLeft);
    freeTree(root->pRight);

    // Libérer le nœud actuel
    free(root);
}

int main(int argc, char *argv[]){
     // Vérifier si le nombre d'arguments est correct
    if (argc != 2) {
        printf("Il y a plus d'un argument pour le programme.c");
        exit (1);
    }
    
    pTree root = NULL;
    readCSV(argv[1], root);

    infixreverse(root);

    printf("Le main fonctionne\n");
    freeTree(root);

    return 0 ;
}
