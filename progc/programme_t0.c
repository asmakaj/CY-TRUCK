#include<stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct chainon{
    char* city;
    int count;
    int departure_city;
    struct chainon* suivant;
}Chainon;

typedef struct file{
    Chainon* tete;
    Chainon* queue;
}File;

typedef struct AVL{
    int route_ID;
    File* crossed;
    int step;
    int departure_city;
    char* cityA;
    char* cityB;
    int eq;
    struct AVL* pLeft;
    struct AVL* pRight;
}AVL_Tree;

typedef AVL_Tree* spTree;

/*
// ville; nb traversée
void prefixe(File* result, FILE* file){
    if(result != NULL){

        if (result->queue != NULL && result->tete != NULL) {
            Chainon* p = result->tete;
            while(p != NULL){
                fprintf(file, "%s;%d", p->city, p->count);
                p = p->suivant;
            }
        }
    }
}
*/

void prefixe(File* result, FILE* file) {
    if (result == NULL || file == NULL) {
        printf("Erreur : pointeur nul\n");
        return;
    }

    // Assurez-vous que le fichier est ouvert en mode écriture
    if (file == NULL) {
        printf("Erreur : le fichier n'est pas ouvert en mode écriture\n");
        return;
    }

    if (result->queue != NULL && result->tete != NULL) {
        Chainon* p = result->tete;
        while (p != NULL) {
            fprintf(file, "%s;%d", p->city, p->count);
            p = p->suivant;
        }
    } else {
        printf("La file est vide\n");
    }
}


void afficheListe(Chainon* pliste){
    if(pliste == NULL){
        exit(2);
    }
    Chainon* p = pliste;

    while(p->suivant != NULL){
        printf("%s;%d",p->city, p->count);
        p = p->suivant;
        if(p->suivant != NULL){
            printf("\n");
        }
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


File* creationFile(){
    File* file = malloc(sizeof(File));
    if(file == NULL){
        printf("echec du malloc \n");
        exit(48);
    }

    file->tete = NULL;
    file->queue = NULL;
    return file;
}

//ok
spTree createNodeAVL(int route_ID, int step, const char* cityA, const char* cityB){
    spTree new = malloc(sizeof(AVL_Tree));
    if (new == NULL) {
        printf("Erreur au niveau du malloc");
        exit(3);
    }

    File* crossed = creationFile();


    new->route_ID = route_ID;
    new->step = step;
    new->cityA = strdup(cityA); // Alloue de la mémoire et copie la ville
    new->cityB = strdup(cityB);
    new->crossed = crossed;
    new->departure_city = 0;
    new->eq = 0;
    new->pLeft = NULL;
    new->pRight = NULL;

    return new;
}

Chainon* createNodeFile(const char* city){
    Chainon* new = malloc(sizeof(Chainon));
    if (new == NULL) {
        printf("Erreur au niveau du malloc");
        exit(4);
    }

    new->city = strdup(city);
    new->count = 0;
    new->departure_city = 0;
    new->suivant = NULL;

    return new;
}

// LA file a un probleme dans les cas : -2, -1, 0 a supprimer
int fileVerification(File* f){
    printf("verif 1 \n");

    if(f == NULL){
        return -2;
    }

    printf("verif 2 \n");
    if((f->tete == NULL && f->queue != NULL) || (f->tete != NULL && f->queue ==NULL)){
        return -1;
    }

    printf("verif 3 \n");
    //if(f->queue->suivant != NULL){
      //  return 0;
    //}
    printf("verif 4 \n");
    if(f->queue == NULL && f->tete == NULL){
        return 1;
    }
    else{
        printf("verif 5 \n");
        return 2;
    }

}

// Fontion pour compter le nombre de fois où les villes on été traversées par trajets
 File* crossedcity(spTree avl, const char* city) {
    if (avl == NULL || city == NULL) {
        exit(2);
    }
    
    if (avl->crossed == NULL) {
        avl->crossed = creationFile();
    }

    Chainon* p = avl->crossed->tete;
    Chainon* new = createNodeFile(city);

    if (avl->crossed->queue == NULL && avl->crossed->tete == NULL) {
        avl->crossed->tete = new;
        avl->crossed->queue = new;
        new->count++;

    } 
    else if(avl->crossed->queue != NULL && avl->crossed->tete != NULL){
        while (p->suivant != NULL) {
            if (strcmp(new->city, p->city) == 0) {
                p->count++;
                free(new->city);
                free(new);
                return avl->crossed;
            }
            p = p->suivant;
        }
        p->suivant = new;
        avl->crossed->queue = new;
    }
      //  printf("crossedcity 1 ok \n");
    return avl->crossed;
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
// issu du coursconst char* city

/*
spTree insertAVL(spTree avl, int* h, int route_ID, int step, const char* cityA, char* cityB){
    printf("insertAVL 1 ok \n");

    spTree new = createNodeAVL(route_ID, step, cityA, cityB);

    if(new == NULL){
        printf("Erreur, le nouveau est NULL");
        exit(10);
    }
    if(avl ==  NULL){
        *h = 1;
        avl = new;
        // REMPLIR LA FILE qui stocke le nombre de fois où les villes sont traversées par trajets
        avl->crossed = crossedcity(avl, cityA);
        avl->crossed = crossedcity(avl, cityB);
        printf("insertAVL 2 ok \n");
        return avl;
    }
    else if(new->route_ID < avl->route_ID){
        avl->pLeft = insertAVL(avl->pLeft, h, route_ID, step, cityA, cityB);
        *h = -(*h);
    }
    else if(new->route_ID > avl->route_ID){
        avl->pRight = insertAVL(avl->pRight, h, route_ID, step, cityA, cityB);
    }
    else{
        *h = 0;
 // REMPLIR LA FILE qui stocke le nombre de fois où les villes sont traversées par trajets
        avl->crossed = crossedcity(avl, cityA);
        avl->crossed = crossedcity(avl, cityB);
        return avl;
    }

printf("insertAVL 3 ok \n");
    if(*h != 0){
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
*/
spTree insertAVL(spTree avl, int* h, int route_ID, int step, const char* cityA, const char* cityB) {
    //printf("insertAVL 1 ok \n");

    spTree new = createNodeAVL(route_ID, step, cityA, cityB);

    if (new == NULL) {
        printf("Erreur, le nouveau est NULL");
        exit(10);
    }
    if (avl ==  NULL) {
        *h = 1;
        avl = new;
        // REMPLIR LA FILE qui stocke le nombre de fois où les villes sont traversées par trajets
        avl->crossed = creationFile();
        avl->crossed = crossedcity(avl, cityA);
        avl->crossed = crossedcity(avl, cityB);
        //printf("insertAVL 2 ok \n");
        return avl;
    } else if (new->route_ID < avl->route_ID) {
        avl->pLeft = insertAVL(avl->pLeft, h, route_ID, step, cityA, cityB);
        *h = -(*h);
    } else if (new->route_ID > avl->route_ID) {
        avl->pRight = insertAVL(avl->pRight, h, route_ID, step, cityA, cityB);
    } else {
        *h = 0;
        // REMPLIR LA FILE qui stocke le nombre de fois où les villes sont traversées par trajets
        avl->crossed = crossedcity(avl, cityA);
        avl->crossed = crossedcity(avl, cityB);
        return avl;
    }

    //printf("insertAVL 3 ok \n");
    if (*h != 0) {
        avl->eq = avl->eq + *h;
        avl = equilibrageAVL(avl);
        if (avl->eq == 0) {
            *h = 0;
        } else {
            *h = 1;
        }
    }
    return avl;
}


/*
// route_id; step; villeA; villeB
File* insertResult(File* result, spTree avl){
 if (avl == NULL || result == NULL) {
        exit(42);
    }
    printf("insert result debut ok \n");

    if(avl->crossed == NULL){
        printf("L'avl pour remplir les resultats est nulle\n");
        exit(54);
    }

    printf("insert result 2 ok \n");

    Chainon* p = avl->crossed->tete;
    
    while(p->suivant != NULL){
        if (result->queue == NULL && result->tete == NULL){
            result = avl->crossed;
            printf("insert result 3 ok \n");
        }
        else if(result->queue != NULL && result->tete != NULL){
            Chainon* r = result->tete;

            while (r->suivant != NULL){
                if (strcmp(r->city, p->city) == 0) {
                    r->count += p->count;
                    break;
                }
                r = r->suivant;
            }
            if(strcmp(r->city, p->city) != 0){
                r->suivant = p;
                result->queue = p;
            }
            
        }
    }


    printf("inssertResult 1 ok \n");
    return result;
}
*/

File* insertResult(File* result, spTree avl) {
    if (avl == NULL || result == NULL) {
        exit(42);
    }
    //printf("insert result debut ok \n");

    if (avl->crossed == NULL) {
        printf("L'avl pour remplir les resultats est nulle\n");
        exit(54);
    }

    //printf("insert result 2 ok \n");

    Chainon* p = avl->crossed->tete;

    while (p != NULL) { // Utilisez une boucle while pour parcourir tous les éléments de la liste

        if (result->queue == NULL && result->tete == NULL) {
            // Si la file de résultat est vide, initialisez-la avec les éléments de avl->crossed
            result->tete = createNodeFile(p->city);
            result->queue = result->tete;
            result->queue->count = p->count;
        } else {
            Chainon* r = result->tete;
            while (r != NULL) {
                if (strcmp(r->city, p->city) == 0) {
                    // Si la ville existe déjà dans la file de résultat, mettez à jour le compteur
                    r->count += p->count;
                    break;
                }

                if (r->suivant == NULL) {
                    // Si on atteint la fin de la file de résultat et que la ville n'existe pas, ajoutez-la
                    r->suivant = createNodeFile(p->city);
                    r->suivant->count = p->count;
                    result->queue = r->suivant;
                    break;
                }

                r = r->suivant;
            }
        }

        p = p->suivant;
    }

   // printf("inssertResult 1 ok \n");
    return result;
}

// Parcours de l'ABR et insertion dans l'AVL
File* fillResult(spTree avl, File* result){
    if(avl != NULL){
        // Insérer la valeur actuelle de l'AVL dans la file result
        result = insertResult(result, avl);
        
        // Continuer le parcours en ordre dans l'AVL
        result = fillResult(avl->pLeft, result);
        result = fillResult(avl->pRight, result);
    } 
    return result;
}


spTree fillAVL(const char* data, spTree avl) {
    printf("fill avl debut ok\n");
    FILE* file1 = fopen(data, "r");
    if (file1 == NULL) {
        perror("Error opening the file");
        exit(EXIT_FAILURE);
    }

    int h = 0;
    char cityA[50];
    char cityB[50];
    int step, route_ID;

    while (fscanf(file1, "%49[^;];%49[^;];%d;%d;", cityA, cityB, &route_ID, &step) == 4) {
       // printf("Route_ID: %d, Step: %d, CityA: %s, CityB: %s\n", route_ID, step, cityA, cityB);
       // printf("test dans while\n");
        avl = insertAVL(avl, &h, route_ID, step, strdup(cityA), strdup(cityB));
    }
    fclose(file1);
    printf("fill avl fin ok\n");
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
    free(avl->cityA);
    free(avl->cityB);
    free(avl);
}

// Function to free a file
void freeFile(File* f) {
    Chainon* current = f->tete;
    while (current != NULL) {
        Chainon* next = current->suivant;
        free(current->city);
        free(current);
        current = next;
    }
}

// Function to free AVL tree
void freeAVLFiles(spTree avl) {
    if (avl == NULL) {
        return;
    }

    // Recursively free files in the left and right subtrees
    freeAVLFiles(avl->pLeft);
    freeAVLFiles(avl->pRight);

    // Free the file in the current node
    freeFile(avl->crossed);
}

int main(int argc, char *argv[]){
    printf("main 1 ok\n");
    // Vérifier si le nombre d'arguments est correct
    if (argc != 2) {
        printf("Il y a plus d'un argument pour le programme.c\n");
        exit(1);
    }

    spTree avl = NULL;
    avl = fillAVL(argv[1], avl);

    //infixtestAVL(avl);
    printf("main 2 ok\n");

    int h= 0;

    File* result = creationFile();
    printf("main 2bis ok\n");

    result = fillResult(avl, result);

    printf("main 3 ok\n");
    
    // Ouvrir un fichier en écriture
    FILE *file = fopen("temp/thirdtemp.csv", "w");
    if (file == NULL) {
        perror("Erreur lors de l'ouverture du fichier");
        exit(EXIT_FAILURE);
    }
    
    prefixe(result, file);

    printf("main 4 ok\n");

    //afficheListe(result->tete);
    fclose(file);

    freeFile(result);
    freeAVLFiles(avl);
    freeAVL(avl);

    return 0 ;
}
