#!/bin/bash

# FONCTIONS
# Creation des dossiers temp et images
create_directories() {
# Nom du dossier a verifier
file="temp"
# Verifier si le dossier existe
if [ -d "$file" ]
then
    # find : Cela garantit que tous les fichiers et sous-répertoires dans temp sont supprimés, même si le répertoire est déjà vide
    find temp -mindepth 1 -delete 
fi
# Creer les dossiers
mkdir -p temp images
}

# Verification de la presence de l'executable C
executable_verification() {
if [ ! -f progc/prog ]
then
    # On compile
    gcc -o progc/prog progc/programme.c
    # Verifier si la compilation s'est bien deroulee
    if [ $? -ne 0 ]
    then
        echo "Erreur lors de la compilation. Veuillez corriger les erreurs avant de continuer."
        exit 1
    fi
fi
# echo "L'executable C est present."
}

# À SUPPRIMER QUAND ON AURA FINI DE TOUT CODER
compilation() {
    gcc -o progc/prog progc/programme.c
    if [ $? -ne 0 ]
    then
        echo "Erreur lors de la compilation. Veuillez corriger les erreurs avant de continuer."
        exit 1
    fi
}

# Creation du graphique avec gnuplot
#generate_graph() {
    # À FAIRE
#}
# Appel de la fonction : generate_graph "temp/result_$1" "images/graph_$1.png"

# Affichage du temps d'execution
#execution_time() {
    # À FAIRE
#}

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
cp "$input_file" data/ # L'ECRASEMENT POSE PROBLEME ?
# echo "Le fichier $input_file a été copié dans le dossier data avec succès."

# Cas du -h
# Boucle pour parcourir les arguments
for arg in "$@"
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

# Vérification des dossiers temp et images
create_directories

# Vérification de l'executable c
executable_verification
#compilation
compilation

# EXECUTION DES DIFFÉRENTS TRAITEMENTS

# Le premier argument est le fichier CSV
input_file=$1
shift
# On a décalé les arguments vers la gauche pour exclure le fichier CSV, le premier argument est maintenant le premier traintement
# Pour avoir accès a data.csv, il faut faire appel à la varible $input_file

# Boucle pour traiter chaque argument 
for option in "$@"
do
   case $option in
        -d1)
            echo "Traitement D1..."
            # Utiliser awk pour compter le nombre de trajets par conducteur
            grep ";1;" "$input_file" >> temp/temp.csv
            awk -F';' '{count[$6]+= 1} END {for (driver in count) print driver ";" count[driver]}' temp/temp.csv >> temp/temp2.csv


            # Trier la liste par ordre décroissant de nombre de trajets
            sort -t';' -k2,2 -n -r temp/temp2.csv >> temp/finaltemp.csv 

            # Récupérer les 10 premiers conducteurs
            longest_10_drivers=$(head -n 10 temp/finaltemp.csv)

            # Créer le graphique de type histogramme horizontal
            echo "Les 10 conducteurs avec le plus de trajets sont : "
            echo "$longest_10_drivers" 

            # Nettoyer les fichiers temporaires
            rm temp/temp.csv temp/finaltemp.csv temp/temp2.csv

            ;;
        -d2)
            echo "Traitement D2..."
            if [ -f "$input_file" ]
            then
                 #tab assosiatif avec conducteur suivi de la distance 
                declare -A conducteur_distances
                   while read -r ligne
                   do
                        conducteur=$(echo "$ligne" | cut -d ' ' -f 6)
                        distance=$(echo "$ligne" | cut -d ' ' -f 5)
                        #accumuler la distance totale parcourue dans le tab cree si le conducteur a déjà une distance enregistrée, cette ligne ajoute la distance actuelle à la distance existante
                        #ajoute la distance extraite de la ligne actuelle au conducteur spécifié.
                        conducteur_distances["$conducteur"]=$(( ${conducteur_distances["$conducteur"]} + distance ))
                    done < "$input_file"
            fi
            # Trier les distances par ordre décroissant
            Trier_distances=($(for conducteur in "${!conducteur_distances[@]}"; do
            echo "$conducteur ${conducteur_distances["$conducteur"]}"
                done | sort -k2,2nr))
            # Afficher les 10 plus grandes distances
            echo "Les 10 plus grandes distances :"
            for item in "${Trier_distances[@]}"; do
                conducteur=${item%% *}
                distance=${item#* }
                 echo "$conducteur : $distance"
            done
            ;;
        -l)
            echo "Traitement L..."
            # Code pour le traitement
            ;;
        -t)
            echo "Traitement T..."
            # Code pour le traitement
            ;;
        -s)
            echo "Traitement S..."
            #awk -F';' '{count[$1]++} END {for (route in count) print route ";" count[route]}' "$input_file" >> temp/temp.csv
            cut -d';' -f1,2,5 "$input_file" > temp/firsttemp.csv
            route=$(tail -n +2 temp/firsttemp.csv | head -n 10)
            tail -n +2 temp/firsttemp.csv | head -n 10 > secondtemp.csv


            echo "Les statistiques sur les étapes sont : "
            #echo "$route"

            ./progc/prog secondtemp.csv

            rm temp/firsttemp.csv secondtemp.csv
            ;;
        *)
            echo "L'option $option n'est pas reconnue. Veuillez réessayer."
            exit 1 ;;
    esac
done

echo "ÇA COMPIILLEEEE HEHEEEE"
