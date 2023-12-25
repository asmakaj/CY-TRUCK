#include<stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]){
     // Vérifier si le nombre d'arguments est correct
    if (argc != 2) {
        printf("Il y a plus d'un argument pour le programme.c");
        exit (1);
    }

    // Le chemin vers le fichier CSV est stocké dans argv[1]
    char *firsttemp = argv[1];

    // À partir d'ici, tu peux utiliser cheminFichierCSV pour lire le fichier CSV

    printf("Le fichier CSV est : %s\n", firsttemp);

    
    return 0 ;
}
