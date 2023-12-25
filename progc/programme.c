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

    //printf("Route_ID: %d, Step_ID: %d, Distance: %f, Min: %f, Max: %f, n: %d\n", pNew->route_ID, pNew->step_ID, pNew->distance, pNew->min, pNew->max, pNew->n);

    return pNew;
}


pTree insertABR(pTree root, int route_ID, int step_ID, float distance) {
    if(root == NULL){
        root = createNode(route_ID, step_ID, distance);
    }
    else if(route_ID < root->route_ID){
        root->pLeft = insertABR(root->pLeft, route_ID, step_ID, distance);
    } 
    else if(route_ID > root->route_ID){
        root->pRight = insertABR(root->pRight, route_ID, step_ID, distance);
    }
    return root;
}

// Function to read data from CSV and build the tree
pTree readCSV(const char* data, pTree root) {
    FILE* file = fopen(data, "r");
    if (file == NULL) {
        perror("Error opening the file");
        exit(EXIT_FAILURE);
    }

    int route_ID, step_ID;
    float distance;
    
    while(fscanf(file, "%d;%d;%f", &route_ID, &step_ID, &distance) == 3) {
        // Insert the values into the tree
        root = insertABR(root, route_ID, step_ID, distance);
    }
    return root;

    fclose(file);
}


void infixreverse(pTree p){
    if(p != NULL){
        infixreverse(p->pRight);
        //printf("Route_ID: %d, Step_ID: %d, Distance: %f, Min: %f, Max: %f, n: %d\n", p->route_ID, p->step_ID, p->distance, p->min, p->max, p->n);
        printf("[%02d]", p->route_ID);

        infixreverse(p->pLeft);
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
    root = readCSV(argv[1], root);

    infixreverse(root);
    printf("\n");

    freeTree(root);

    return 0 ;
}
