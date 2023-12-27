#include<stdio.h>
#include <stdlib.h>


typedef struct ABR{
  int route_ID;
  int step_ID;
  float distance;
  float min;
  float max;
  int n;
  struct ABR* pLeft;
  struct ABR* pRight;
}ABR_Tree;

typedef ABR_Tree* pTree;

typedef struct AVL{
    int route_ID;
    float min;
    float max;
    float moy;
    float diff;
    int eq;
    struct AVL* pLeft;
    struct AVL* pRight;
}AVL_Tree;

typedef AVL_Tree* spTree;

pTree createNodeABR(int route_ID, int step_ID, float distance, float min, float max){
    pTree pNew = malloc(sizeof(ABR_Tree));
    // NE PAS OUBLIER DE FREE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    if (pNew == NULL) {
        printf("Erreur au niveau du malloc");
        exit(2);
    }

    pNew->route_ID = route_ID;
    pNew->step_ID = step_ID;
    pNew->distance = distance;
    pNew->min = min;
    pNew->max = max;
    pNew->n = 1 ;
    pNew->pLeft = NULL;
    pNew->pRight = NULL;

    //printf("Route_ID: %d, Step_ID: %d, Distance: %.3f, Min: %.3f, Max: %.3f, n: %d\n", pNew->route_ID, pNew->step_ID, pNew->distance, pNew->min, pNew->max, pNew->n);

    return pNew;
}


pTree insertABR(pTree abr, int route_ID, int step_ID, float distance){

    if(abr == NULL){
        abr = createNodeABR(route_ID, step_ID, distance, distance, distance);
    }
    else if(route_ID < abr->route_ID){
        abr->pLeft = insertABR(abr->pLeft, route_ID, step_ID, distance);
    } 
    else if(route_ID > abr->route_ID){
        abr->pRight = insertABR(abr->pRight, route_ID, step_ID, distance);
    }
    else if(route_ID == abr->route_ID){
        abr->n++;
        abr->distance += distance;
        if(distance > abr->max){
            abr->max = distance;
        }

        if(distance < abr->min){
            abr->min = distance;
        }
    }

    return abr;
}

// Function to read data from CSV
pTree readCSV(const char* data, pTree abr) {
    FILE* file = fopen(data, "r");
    if (file == NULL) {
        perror("Error opening the file");
        exit(EXIT_FAILURE);
    }

    int route_ID, step_ID;
    float distance;
    
    while(fscanf(file, "%d;%d;%f", &route_ID, &step_ID, &distance) == 3) {
        // Remplissage de l'arbre
        abr = insertABR(abr, route_ID, step_ID, distance);
    }
    return abr;

    fclose(file);
}

void infixreverse(spTree avl, FILE* file) {
    if (avl != NULL) {
        infixreverse(avl->pRight, file);
        //printf("[%02d]", avl->route_ID);
        fprintf(file, "%d;%.3f;%.3f;%.3f;%.3f;%d\n", avl->route_ID, avl->min, avl->max, avl->moy, avl->diff, avl->eq);
        infixreverse(avl->pLeft, file);
    }
}

void infixtestABR(pTree p){
    printf("ABR\n");
    if(p != NULL){
        
    infixtestABR(p->pRight);
    printf("[%02d], %d;%.3f;%.3f;%.3f;%d", p->route_ID, p->step_ID, p->min, p->max, p->distance, p->n);
    //fprintf(file, "%d;%.3f;%.3f;%.3f;%.3f;%d\n", p->route_ID, p->min, p->max, p->moy, p->diff, p->eq);
    //insertAVL(avl, 0, p);
    infixtestABR(p->pLeft);
    }
}

void infixtestAVL(spTree p){
    printf("AVL\n");
    if(p != NULL){
        
    infixtestAVL(p->pRight);
    printf("[%02d]", p->route_ID);
    //fprintf(file, "%d;%.3f;%.3f;%.3f;%.3f;%d\n", p->route_ID, p->min, p->max, p->moy, p->diff, p->eq);
    //insertAVL(avl, 0, p);
    infixtestAVL(p->pLeft);
    }
}


spTree createNodeAVL(pTree abr){
    spTree new = malloc(sizeof(AVL_Tree));
    if (new == NULL) {
        printf("Erreur au niveau du malloc");
        exit(3);
    }

    new->route_ID = abr->route_ID;
    new->min = abr->min;
    new->max = abr->max;
    new->moy = (abr->distance / (double)abr->n);
    new->diff = abr->max - abr->min;
    new->eq = 0;
    new->pLeft = NULL;
    new->pRight = NULL;

    return new;
}


// Fonction pour trouver le minimum entre trois entiers
int min3(int a, int b, int c){
return (a < b) ? ((a < c) ? a : c) : ((b < c) ? b : c);
}

// Fonction pour trouver le max entre deux entiers
int max2(int a, int b){
    return (a > b) ? a : b;
}

spTree leftRotation(spTree avl){
    spTree pivot;
    int eq_a, eq_p;

    pivot = avl->pRight;
    avl->pRight = pivot->pLeft;
    pivot->pLeft = avl;
    
    eq_a = avl->eq;
    eq_p = pivot->eq;
    avl->eq = eq_a - max2(eq_p, 0) - 1;
    pivot->eq = min3(eq_a - 2, eq_a + eq_p - 2, eq_p-1);

    avl = pivot;

    return avl;
}

// Fonction pour trouver le minimum entre deux entiers
int min2(int a, int b) {
    return (a < b) ? a : b;
}

// Fonction pour trouver le maximum entre trois entiers
int max3(int a, int b, int c) {
    return (a > b) ? ((a > c) ? a : c) : ((b > c) ? b : c);
}

spTree rightRotation(spTree avl){
    spTree pivot;
    int eq_a, eq_p;

    pivot = avl->pLeft;
    avl->pLeft = pivot->pRight;
    pivot->pRight = avl;
    
    eq_a = avl->eq;
    eq_p = pivot->eq;
    avl->eq = eq_a - min2(eq_p, 0) + 1;
    pivot->eq = max3(eq_a + 2, eq_a + eq_p + 2, eq_p + 1);

    avl = pivot;

    return avl;
}

spTree doubleLeftRotation(spTree avl){
    avl->pRight = rightRotation(avl->pRight);
    return leftRotation(avl);
}

spTree doubleRightRotation(spTree avl){
    avl->pLeft = leftRotation(avl->pLeft);
    return rightRotation(avl);
}

spTree equilibrageAVL(spTree avl){
    if(avl->eq > 1){
        if(avl->pRight->eq >= 0){
            return leftRotation(avl);
        }
        else{
            return doubleLeftRotation(avl);
        }
    }
    else if(avl->eq < -1){
        if(avl->pLeft->eq <= 0){
            return rightRotation(avl);
        }
        else{
            return doubleRightRotation(avl);
        }
    }
    return avl;
}

spTree insertAVL(spTree avl, int* h, pTree abr){
    spTree new = createNodeAVL(abr);

    if(avl ==  NULL){
        *h = 1;
        return new;
    }
    else if(new->diff < avl->diff){
        avl->pLeft = insertAVL(avl->pLeft, h, abr);
        *h = -(*h);
    }
    else if(new->diff > avl->diff){
        avl->pRight = insertAVL(avl->pRight, h, abr);
    }
    else{
        *h = 0;
        return avl;
    }

    if(h != 0){
        avl->eq = avl->eq + *h;
        avl = equilibrageAVL(avl);
        if(avl->eq == 0){
            *h = 0;
        }
        else{
            *h = 1;
        }

    }
    return avl;
}


// Parcours de l'ABR et insertion dans l'AVL
spTree fillAVL(pTree abr, spTree avl, int h){
    if(abr != NULL){
        // Insérer la valeur actuelle de l'ABR dans l'AVL
        avl = insertAVL(avl, &h, abr);
        
        // Continuer le parcours en ordre dans l'ABR
        avl = fillAVL(abr->pLeft, avl, h);
        avl = fillAVL(abr->pRight, avl, h);
    } 
    return avl;
}



void freeABR(pTree abr) {
    // Si le nœud est NULL, il n'y a rien à libérer, donc return
    if (abr == NULL) {
        return;
    }

    // Récursivement libérer le sous-arbre gauche et le sous-arbre droit
    freeABR(abr->pLeft);
    freeABR(abr->pRight);

    // Libérer le nœud actuel
    free(abr);
}

void freeAVL(spTree avl){
    // Si le nœud est NULL, il n'y a rien à libérer, donc return
    if (avl == NULL) {
        return;
    }

    // Récursivement libérer le sous-arbre gauche et le sous-arbre droit
    freeAVL(avl->pLeft);
    freeAVL(avl->pRight);

    // Libérer le nœud actuel
    free(avl);
}


int main(int argc, char *argv[]){
     // Vérifier si le nombre d'arguments est correct
    if (argc != 2) {
        printf("Il y a plus d'un argument pour le programme.c");
        exit (1);
    }

    pTree abr = NULL;
    abr = readCSV(argv[1], abr);
    //infixtestABR(abr);
    //printf("\n\n");

    spTree avl = NULL;
    //hauteur
    int h = 0;
    avl = fillAVL(abr, avl, h);
    //infixtestAVL(avl);
    printf("\n\n");

    // Ouvrir un fichier en écriture
    FILE *file = fopen("temp/output.csv", "w");
    if (file == NULL) {
        perror("Erreur lors de l'ouverture du fichier");
        exit(EXIT_FAILURE);
    }

    infixreverse(avl, file);
    printf("\n");

    fclose(file);

    freeABR(abr);
    freeAVL(avl);

    return 0 ;
}
