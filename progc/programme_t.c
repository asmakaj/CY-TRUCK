/*
 * File Name: programme_t.c
 * Author: 
 * Created on: January 6, 2024
 * Description: 
    This program collects the different cities, the number of times they were crossed,
    and the number of times they are cities of departure of each trip.
    These data will be sort by descending order these cities according to the number of times they were crossed,
    and then written to a csv output file as: 
    City;crossed;departure_city

 */

#include<stdio.h>
#include <stdlib.h>
#include <string.h>

/*
 _____Structure AVL_____
 Description : stores the name of the city, the number of times the city was crossed, the number of times the city is a departure city
 */
typedef struct AVL{
    char* city;
    int crossed;
    int departure_city;
    int eq;
    struct AVL* pLeft;
    struct AVL* pRight;
}AVL_Tree;

typedef AVL_Tree* spTree;

/*
    Function : createNodeAVL
    Description : Creates a new AVL node
    Parameters : necessary information to initialize the new node
    Returns : the new node 
 */
spTree createNodeAVL(const char* city, int crossed, int departure_city){
    spTree new = malloc(sizeof(AVL_Tree));
    if (new == NULL) {
        printf("The malloc of the new AVL node failed... Please try again\n");
        exit(1);
    }

    new->city = strdup(city); // Allocates memory and copies the city
    new->crossed = crossed;
    new->departure_city = departure_city;
    new->eq = 0;
    new->pLeft = NULL;
    new->pRight = NULL;

    return new;
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
        exit(2);
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
        exit(3);
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
        exit(4);
    }
    avl->pRight = rightRotation(avl->pRight);
    return leftRotation(avl);
}

// from the lecture course
spTree doubleRightRotation(spTree avl){
        if(avl == NULL){
        printf("The AVL is NULL... Please try again\n");
        exit(5);
    }
    avl->pLeft = leftRotation(avl->pLeft);
    return rightRotation(avl);
}

// from the lecture course
spTree equilibrageAVL(spTree avl){
        if(avl == NULL){
        printf("The AVL is NULL... Please try again\n");
        exit(6);
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
    Function : insertAVL
    Description : Insert the new nodes in the AVL
    Returns : the updated AVL
 */
spTree insertAVL(spTree avl, int* h, const char* city, int crossed, int departure_city){
    spTree new = createNodeAVL(city, crossed, departure_city);
    if(new == NULL){
        printf("The malloc of the new AVL node failed... Please try again\n");
        exit(7);
    }

    if(avl ==  NULL){
        *h = 1;
        return new;
    }
    else if(new->crossed <= avl->crossed){
        avl->pLeft = insertAVL(avl->pLeft, h,city, crossed, departure_city);
        *h = -(*h);
    }
    else if(new->crossed > avl->crossed){
        avl->pRight = insertAVL(avl->pRight, h, city, crossed, departure_city);
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

/*
    Function : fillAVL
    Description : Read data from CSV and add these data to the AVL
    Returns : the updated AVL
 */
spTree fillAVL(const char* data, spTree avl) {
    FILE* file = fopen(data, "r");
    if (file == NULL) {
        perror("Error opening the file... \n");
        exit(EXIT_FAILURE);
    }

    char city[50];
    int h = 0;
    int crossed = 0, departure_city = 0;

    // The loop retrieves the csv data line by line, then adds them to the tree 
    while (fscanf(file, "%49[^;];%d;%d", city, &crossed, &departure_city) == 3) {
        avl = insertAVL(avl, &h, city, crossed, departure_city);
    }

    fclose(file);
    return avl;
}

/*
    Function : infixreverse
    Description : print in the output file the cities in descending order of the number of times they have been crossed 
 */
void infixreverse(spTree avl, FILE* file) {
    if (avl != NULL) {
        infixreverse(avl->pRight, file);
        fprintf(file, "%s;%d;%d", avl->city, avl->crossed, avl->departure_city);
        infixreverse(avl->pLeft, file);
    }
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
        printf("There is more than one argument for the program. c\n");
        exit (8);
    }

    // Sort in decreasing order the cities by the number of times they have been crossed 
    spTree avl = NULL;
    avl = fillAVL(argv[1], avl);

    // Write the information contained in the avl in an output csv file
    FILE *file = fopen("temp/secondtemp.csv", "w");
    if (file == NULL) {
        perror("Error when opening the file...\n");
        exit(EXIT_FAILURE);
    }
    infixreverse(avl, file);
    fclose(file);

    // Memory release
    freeAVL(avl);
    return 0 ;
}
