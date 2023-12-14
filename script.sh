#!/bin/bash

# Fonctions

# Creation des dossiers temp et images
create_directories() {
# Nom du dossier a verifier
file="temp"
# Verifier si le dossier existe
if [ -d "$file" ]
then
    # Verifier si le dossier n'est pas vide
    if [ "$(ls -A "$dossier")" ]
    then
        echo "Le dossier n'est pas vide."
        # Vider le dossier
        rm -rf temp/*
    fi
fi
# Creer les dossiers
mkdir -p temp images
}

# Verification de la presence de l'executable C
executable_verification() {
if [ ! -f progc/prog ]
then
    echo "Compilation en cours..."
    # On compile
    gcc -o prog progc/programme.c
    # Verifier si la compilation s'est bien deroulee
    if [ $? -ne 0 ]
    then
        echo "Erreur lors de la compilation. Veuillez corriger les erreurs avant de continuer."
        exit 1
    fi
fi
echo "L'executable C est present. Execution du programme..."
# On ajoute ici le traitement demande en argument (-d1, -l, ...)
}

h_traitememnt() {
# Boucle pour parcourir les arguments
for arg in `$@`
do
    # Si l'argument est égal à "-h", alors on affiche l'aide
    if [ "$arg" == "-h" ]
    then
    echo "---------------------------------------------------"
    echo "Aide : Options possibles"
    echo "-d1 : Conducteurs avec le plus de trajets"
    echo "-d2 : Conducteurs et la plus grande distance"
    echo "-l : Les 10 trajets les plus longs"
    echo "-t : Les 10 villes les plus traversees "
    echo "-s : Statistiques sur les etapes"
    echo "---------------------------------------------------"

    exit 0
    fi

done
}



# Creation du graphique avec gnuplot
generate_graph() {
    # Création de variables locales, visible que dans la fonction
    local input_file=$1
    local output_file=$2

    gnuplot -e "input_file='$input_file'" -e "output_file='$output_file'" progc/graph_script.gp
}
# Appel de la fonction : generate_graph "temp/result_$1" "images/graph_$1.png"

# Affichage du temps d'execution
execution_time() {
echo "Temps d'execution : $SECONDS secondes"
}

#--------------------------------------------------------------------------------------------------------------------------------------------------

# MAIN

# Est ce qu'il y aura obligatoirement 1 argument ???? Sinon verifier qu'il y a au moins 1 argument

# Récupération du fichier CSV passé en argument
input_file=$1

# Vérification de l'existence du fichier
if [ ! -f "$input_file" ]
then
    echo "Le fichier $input_file n'existe pas."
    exit 1
fi
# Vérification de l'extension du fichier
if [[ ! "$input_file" =~ \.csv$ ]]
then
    echo "Le fichier $input_file n'est pas un fichier .csv. Veuillez réessayer svp..."
    exit 1
fi

# Création du dossier "data" s'il n'existe pas
mkdir -p data
# Copie du fichier CSV dans le dossier data
cp "$input_file" data/
echo "Le fichier $input_file a été copié dans le dossier data avec succès."

# Cas du -h
h_traitememnt

# Vérification des dossiers temp et images
create_directories

# Vérification de l'executable c
executable_verification

# Execution des différents traitements

# Le premier argument est le fichier CSV
input_file=$1
shift # Décaler les arguments vers la gauche pour exclure le fichier CSV

# Boucle pour traiter chaque option
for option in `$@`
do
   case $option in
        `-d1`)
            echo "Traitement D1..."
             # Code pour le traitement
            ;;
        `-d2`)
            echo "Traitement D2..."
            # Code pour le traitement
            ;;
        `-l`)
            echo "Traitement L..."
            # Code pour le traitement
            ;;
        `-t`)
            echo "Traitement T..."
            # Code pour le traitement
            ;;
        `-s`)
            echo "Traitement S..."
            # Code pour le traitement
            ;;
        *)
            echo "Option non reconnue."
            exit 1 ;;
    esac
done

echo "ÇA COMPIILLEEEE HEHEEEE"