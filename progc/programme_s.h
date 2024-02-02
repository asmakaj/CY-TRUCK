#ifndef programme_s_H
#define programme_s_H
#include<stdio.h>
#include <stdlib.h>

/*
 _____Structure ABR (binary search tree)_____
 Description : stores the Route id, the number of steps, the total distance travelled per journey, the min distance and the max distance
 */
typedef struct ABR{
  int route_ID;
  int step_ID;
  float total_distance;
  float min_distance;
  float max_distance;
  int count;
  struct ABR* pLeft;
  struct ABR* pRight;
}ABR_Tree;

typedef ABR_Tree* pTree;

/*
 _____Structure AVL_____
 Description : stores the Route id, the min distance, the max distance, the average distance and the difference between the max and the min
 */
typedef struct AVL{
    int route_ID;
    float min_distance;
    float max_distance;
    float moy;
    float diff;
    int eq;
    struct AVL* pLeft;
    struct AVL* pRight;
}AVL_Tree;

typedef AVL_Tree* spTree;




pTree createNodeABR(int route_ID, int step_ID, float distance, float min_distance, float max_distance);

pTree insertABR(pTree abr, int route_ID, int step_ID, float distance);

pTree readCSV(const char* data, pTree abr);

int min3(int a, int b, int c);

int max2(int a, int b);

int min2(int a, int b);

int max3(int a, int b, int c);

spTree leftRotation(spTree avl);

spTree rightRotation(spTree avl);

spTree doubleLeftRotation(spTree avl);

spTree doubleRightRotation(spTree avl);

spTree equilibrageAVL(spTree avl);

spTree createNodeAVL(pTree abr);

spTree insertAVL(spTree avl, int* h, pTree abr);

spTree fillAVL(pTree abr, spTree avl, int h);

void infixreverse(spTree avl, FILE* file, int *i);

void freeABR(pTree abr);

void freeAVL(spTree avl);

int main(int argc, char *argv[]);


#endif
