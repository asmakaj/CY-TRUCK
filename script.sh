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
    if [ "$(ls -A "$dossier")" ]; then
        echo "Le dossier n'est pas vide."
        # Vider le dossier
        rm -rf temp/*
    fi
fi
# Creer les dossiers
mkdir -p temp images
}


# Copier le fichier de donnees specifie en argument
cp "$1" data/


# Verification de la presence de l'executable C
executable_verification() {
if [ ! -f progc/prog ]
then
    echo "Compilation en cours..."
    # On compile
    gcc -o prog programme.c
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

# Recuperation des arguments
input_file=$1
shift

# Affichage de l'aide
if [ "$input_file" == "-h" ]
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

# Execution des differents traitements 
run_data_processing(){
    local input_file=$1
    local option=$2

    case $option in
        -d1)
            echo "Traitement D1..."
            time progc/executable -d1 "$input_file" temp/result_d1
            ;;
        -d2)
            echo "Traitement D2..."
            time progc/executable -d2 "$input_file" temp/result_d2
            ;;
        -l)
            echo "Traitement L..."
            time progc/executable -l "$input_file" temp/result_l
            ;;
        -t)
            echo "Traitement T..."
            time progc/executable -t "$input_file" temp/result_t
            ;;
        -s)
            echo "Traitement S..."
            time progc/executable -s "$input_file" temp/result_s
            ;;
        *)
            echo "Option non reconnue."
            exit 1
            ;;
    esac
}

# Execution des traitements : run_data_processing "$input_file" "$1"

# Creation du graphique avec gnuplot
generate_graph() {
    local input_file=$1
    local output_file=$2

    gnuplot -e "input_file='$input_file'" -e "output_file='$output_file'" progc/graph_script.gp
}

generate_graph "temp/result_$1" "images/graph_$1.png"

# Affichage du temps d'execution
echo "Temps d'execution : $SECONDS secondes"
