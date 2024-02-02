#ifndef programme_t_H
#define programme_t_H

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


spTree createNodeAVL(const char* city, int crossed, int departure_city);

int min3(int a, int b, int c);

int max2(int a, int b);

int min2(int a, int b);

int max3(int a, int b, int c);

spTree leftRotation(spTree avl);

spTree rightRotation(spTree avl);

spTree doubleLeftRotation(spTree avl);

spTree doubleRightRotation(spTree avl);

spTree equilibrageAVL(spTree avl);

spTree insertAVL(spTree avl, int* h, const char* city, int crossed, int departure_city);

spTree fillAVL(const char* data, spTree avl);

void infixreverse(spTree avl, FILE* file);

void freeAVL(spTree avl);

int main(int argc, char *argv[]);


#endif

