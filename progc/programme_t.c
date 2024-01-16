#include<stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct AVL{
    char* city;
    int crossed;
    int departure_city;
    int eq;
    struct AVL* pLeft;
    struct AVL* pRight;
}AVL_Tree;

typedef AVL_Tree* spTree;

void infixtestAVL(spTree p, int n){
    if(n==11)
        return;
        n++;
    if(p != NULL){
        infixtestAVL(p->pRight,n);
        printf("[%02d]", p->crossed);
        //fprintf(file, "%d;%.3f;%.3f;%.3f;%.3f;%d\n", p->route_ID, p->min, p->max, p->moy, p->diff, p->eq);
        //insertAVL1(avl, 0, p);
    infixtestAVL(p->pLeft,n);
    }
}

void infixreverse(spTree avl, FILE* file) {
    if (avl != NULL) {
        infixreverse(avl->pRight, file);
        fprintf(file, "%s;%d;%d", avl->city, avl->crossed, avl->departure_city);
        infixreverse(avl->pLeft, file);
    }
}


//ok
spTree createNodeAVL(const char* city, int crossed, int departure_city){
    spTree new = malloc(sizeof(AVL_Tree));
    if (new == NULL) {
        printf("Erreur au niveau du malloc");
        exit(3);
    }

    new->city = strdup(city); // Alloue de la mémoire et copie la ville
    new->crossed = crossed;
    new->departure_city = departure_city;
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

// issu du cours
spTree leftRotation(spTree avl){
    if(avl == NULL){
        printf("L'arbre est null\n");
        exit(4);
    }
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

// issu du cours
spTree rightRotation(spTree avl){
    if(avl == NULL){
        printf("L'arbre est null\n");
        exit(5);
    }
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

// issu du cours
spTree doubleLeftRotation(spTree avl){
    if(avl == NULL){
        printf("L'arbre est null\n");
        exit(6);
    }
    avl->pRight = rightRotation(avl->pRight);
    return leftRotation(avl);
}
// issu du cours
spTree doubleRightRotation(spTree avl){
        if(avl == NULL){
        printf("L'arbre est null\n");
        exit(7);
    }
    avl->pLeft = leftRotation(avl->pLeft);
    return rightRotation(avl);
}
// issu du cours
spTree equilibrageAVL(spTree avl){
        if(avl == NULL){
        printf("L'arbre est null\n");
        exit(8);
    }
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
// issu du cours
spTree insertAVL1(spTree avl, int* h, const char* city, int crossed, int departure_city){
    spTree new = createNodeAVL(city, crossed, departure_city);

    if(new == NULL){
        printf("Erreur, le nouveau est NULL");
        exit(10);
    }

    if(avl ==  NULL){
        *h = 1;
        return new;
    }
    else if(new->crossed <= avl->crossed){
        avl->pLeft = insertAVL1(avl->pLeft, h,city, crossed, departure_city);
        *h = -(*h);
    }
    else if(new->crossed > avl->crossed){
        avl->pRight = insertAVL1(avl->pRight, h, city, crossed, departure_city);
    }
    else{
        h = 0;
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

// Function to read data from CSV
// nom de la ville;crossed;departure_city
spTree fillAVL(const char* data, spTree avl) {
    FILE* file1 = fopen(data, "r");
    if (file1 == NULL) {
        perror("Error opening the file");
        exit(EXIT_FAILURE);
    }

    char city[50];
    int h = 0;
    int crossed = 0, departure_city = 0;

    while (fscanf(file1, "%49[^;];%d;%d", city, &crossed, &departure_city) == 3) {
        avl = insertAVL1(avl, &h, city, crossed, departure_city);
    }
    fclose(file1);
    return avl;
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

    spTree avl = NULL;
    avl = fillAVL(argv[1], avl);


    // Ouvrir un fichier en écriture
    FILE *file = fopen("temp/secondtemp.csv", "w");
    if (file == NULL) {
        perror("Erreur lors de l'ouverture du fichier");
        exit(EXIT_FAILURE);
    }

    infixreverse(avl, file);

    fclose(file);
    freeAVL(avl);


    return 0 ;
}
