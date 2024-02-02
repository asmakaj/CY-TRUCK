
/*
 * File Name: programme_s.c
 * Author:
 * Created on: December 25, 2023
 * Description:
    This program collects all the stages of the journeys made by different drivers.
    It will then sum the distances of the different steps while storing the min and max distances of the trips.
    These data will be sorted in descending order of "max distance - min distance",
    and then written to a csv output file as:
    Route_ID;min_distance;max_distance;average_distance;(max_distance-min_distance)
 */


#include "programme_s.h"


/*
    Function : createNodeABR
    Description : Creates a new tree node
    Parameters : necessary information to initialize the new node
    Returns : the new node
 */
pTree createNodeABR(int route_ID, int step_ID, float distance, float min_distance, float max_distance){
    pTree pNew = malloc(sizeof(ABR_Tree));
    if (pNew == NULL) {
        printf("The malloc of the new ABR node failed... Please try again\n");
        exit(16);
    }

    pNew->route_ID = route_ID;
    pNew->step_ID = step_ID;
    pNew->total_distance = distance;
    pNew->min_distance = min_distance;
    pNew->max_distance = max_distance;
    pNew->count= 1 ;
    pNew->pLeft = NULL;
    pNew->pRight = NULL;

    return pNew;
}

/*
    Function : insertABR
    Description : Insert the new nodes in the tree
    Returns : the updated ABR
 */
pTree insertABR(pTree abr, int route_ID, int step_ID, float distance){
    if(abr == NULL){
        abr = createNodeABR(route_ID, step_ID, distance, distance, distance);
    }
    else if(route_ID < abr->route_ID){
        abr->pLeft = insertABR(abr->pLeft, route_ID, step_ID, distance);
    }
    else if(route_ID > abr->route_ID){
        abr->pRight = insertABR(abr->pRight, route_ID, step_ID, distance);
    } //when the route_id are equal, count is increased by 1, the new distance is added to the total distances of the route, and the min and max values are updated
    else if(route_ID == abr->route_ID){
        abr->count++;
        abr->total_distance += distance;
        if(distance > abr->max_distance){
            abr->max_distance = distance;
        }

        if(distance < abr->min_distance){
            abr->min_distance = distance;
        }
    }
    return abr;
}

/*
    Function : readCSV
    Description : Read data from CSV and add these data to the tree
    Returns : the updated ABR
 */
pTree readCSV(const char* data, pTree abr) {
    FILE* file = fopen(data, "r");
    if (file == NULL) {
        perror("Error opening the file");
        exit(17);
    }

    int route_ID, step_ID;
    float distance;
   
    // The loop retrieves the csv data line by line, then adds them to the tree
    while(fscanf(file, "%d;%d;%f", &route_ID, &step_ID, &distance) == 3) {
        abr = insertABR(abr, route_ID, step_ID, distance);
    }
    fclose(file);
    return abr;
}

/*
    Function : min3
    Description : Find the minimum between 3 values
    Returns : the minimum value
 */
int min3(int a, int b, int c){
return (a < b) ? ((a < c) ? a : c) : ((b < c) ? b : c);
}

/*
    Function : max2
    Description : Find the maximum between 2 values
    Returns : the maximum value
 */
int max2(int a, int b){
    return (a > b) ? a : b;
}

/*
    Function : min2
    Description : Find the minimum between 2 values
    Returns : the minimum value
 */
int min2(int a, int b) {
    return (a < b) ? a : b;
}

/*
    Function : max3
    Description : Find the maximum between 3 values
    Returns : the maximum value
 */
int max3(int a, int b, int c) {
    return (a > b) ? ((a > c) ? a : c) : ((b > c) ? b : c);
}

// from the lecture course
spTree leftRotation(spTree avl){
    if(avl == NULL){
        printf("The AVL is NULL... Please try again\n");
        exit(18);
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

// from the lecture course
spTree rightRotation(spTree avl){
    if(avl == NULL){
        printf("The AVL is NULL... Please try again\n");
        exit(19);
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

// from the lecture course
spTree doubleLeftRotation(spTree avl){
    if(avl == NULL){
        printf("The AVL is NULL... Please try again\n");
        exit(20);
    }
    avl->pRight = rightRotation(avl->pRight);
    return leftRotation(avl);
}

// from the lecture course
spTree doubleRightRotation(spTree avl){
        if(avl == NULL){
        printf("The AVL is NULL... Please try again\n");
        exit(21);
    }
    avl->pLeft = leftRotation(avl->pLeft);
    return rightRotation(avl);
}

// from the lecture course
spTree equilibrageAVL(spTree avl){
        if(avl == NULL){
        printf("The AVL is NULL... Please try again\n");
        exit(22);
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

/*
    Function : createNodeAVL
    Description : Creates a new AVL node
    Parameters : necessary information to initialize the new node
    Returns : the new node
 */
spTree createNodeAVL(pTree abr){
    spTree new = malloc(sizeof(AVL_Tree));
    if (new == NULL) {
        printf("The malloc of the new AVL node failed... Please try again\n");
        exit(23);
    }

    new->route_ID = abr->route_ID;
    new->min_distance = abr->min_distance;
    new->max_distance = abr->max_distance;
    new->moy = (abr->total_distance / (double)abr->count);
    new->diff = abr->max_distance - abr->min_distance;
    new->eq = 0;
    new->pLeft = NULL;
    new->pRight = NULL;

    return new;
}

/*
    Function : insertAVL
    Description : Insert the new nodes in the AVL
    Returns : the updated AVL
 */
spTree insertAVL(spTree avl, int* h, pTree abr){
    spTree new = createNodeAVL(abr);

    if(new == NULL){
        printf("The malloc of the new AVL node failed... Please try again\n");
        exit(24);
    }

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

/*
    Function : fillAVL
    Description : Prefix path of the ABR and insert its values in the AVL
    Returns : the updated AVL
 */
spTree fillAVL(pTree abr, spTree avl, int h){
    if(abr != NULL){
        avl = insertAVL(avl, &h, abr);
        avl = fillAVL(abr->pLeft, avl, h);
        avl = fillAVL(abr->pRight, avl, h);
    }
    return avl;
}

/*
    Function : infixreverse
    Description : Infix path of the AVL and print its values in the output_file
 */
void infixreverse(spTree avl, FILE* file, int* i) {
    if (avl != NULL) {
        infixreverse(avl->pRight, file, i);
        (*i)++;
        fprintf(file, "%d;%d;%.3f;%.3f;%.3f;%.3f\n", *i,  avl->route_ID, avl->min_distance, avl->moy, avl->max_distance, avl->diff);
        infixreverse(avl->pLeft, file, i);
    }
}

/*
    Function : freeABR
    Description : Releases the memory allocated for the ABR
 */
void freeABR(pTree abr) {
    if (abr == NULL) {
        return;
    }
    freeABR(abr->pLeft);
    freeABR(abr->pRight);
    free(abr);
}

/*
    Function : freeAVL
    Description : Releases the memory allocated for the AVL
 */
void freeAVL(spTree avl){
    if (avl == NULL) {
        return;
    }
    freeAVL(avl->pLeft);
    freeAVL(avl->pRight);
    free(avl);
}


int main(int argc, char *argv[]){
    // Check if the number of arguments is correct
    if (argc != 2) {
        printf("There is more than two argument for the program. c\n");
        exit (25);
    }

    // Retrieves the csv data for analysis and storage in an ABR
    pTree abr = NULL;
    abr = readCSV(argv[1], abr);

    // Sort in decreasing order the diffenrence of the max and min distance of the ABR nodes
    spTree avl = NULL;
    int h = 0;
    avl = fillAVL(abr, avl, h);

    // Write the information contained in the avl in an output csv file
    FILE *file = fopen("temp/secondtemp.csv", "w");
    if (file == NULL) {
        perror("Error when opening the file...\n");
        exit(26);
    }
    // initializing the count
    int i=0;
    infixreverse(avl, file, &i);
    fclose(file);

    //Memory release
    freeABR(abr);
    freeAVL(avl);

    return 0 ;
}




