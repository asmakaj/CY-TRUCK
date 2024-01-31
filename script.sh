#!/bin/bash

# FONCTIONS

# Creation des dossiers temp et images
create_directories(){
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
executable_verification(){
    case $1 in
        -t)
        if [ ! -f progc/progt ]
        then
            gcc -o progc/progt progc/programme_t.c
            # Verifier si la compilation s'est bien deroulee
            if [ $? -ne 0 ]
            then
                echo "Erreur lors de la compilation. Veuillez corriger les erreurs avant de continuer."
                exit 1
            fi
        fi
        if [ ! -f progc/progt2 ]
        then
            gcc -o progc/progt2 progc/programme_t2.c
            # Verifier si la compilation s'est bien deroulee
            if [ $? -ne 0 ]
            then
                echo "Erreur lors de la compilation. Veuillez corriger les erreurs avant de continuer."
                exit 1
            fi
        fi
        ;;
        -s)
        if [ ! -f progc/progs ]
        then
            #gcc -o progc/progs progc/programme_s.c
            gcc -o progc/progs progc/programme_s.c
            # Verifier si la compilation s'est bien deroulee
            if [ $? -ne 0 ]
            then
                echo "Erreur lors de la compilation. Veuillez corriger les erreurs avant de continuer."
                exit 1
            fi
        fi
        ;;
         *)
            echo "L'option $option n'est pas reconnue. Veuillez réessayer."
            exit 1 ;;
    esac
# echo "L'executable C est present."
}

#--------------------------------------------------------------------------------------------------------------------------------------------------

# MAIN

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
cp "$input_file" data/ #

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

# EXECUTION DES DIFFÉRENTS TRAITEMENTS

# Le premier argument est le fichier CSV
input_file=$1
shift


# Boucle pour traiter chaque argument 
for option in "$@"
do
   case $option in
        -d1)
            echo "Traitement D1..."
            #cat "$input_file" >> temp/temp.csv
            grep ";1;" "$input_file" > temp/firsttemp.csv
            awk -F';' '{count[$6]+= 1} END {for (driver in count) print driver ";" count[driver]}' temp/firsttemp.csv >> temp/secondtemp.csv

            # Trier la liste par ordre décroissant de nombre de trajets
            sort -t';' -k2,2 -n -r temp/secondtemp.csv >> temp/thirdtemp.csv 
            head -n 10 temp/thirdtemp.csv >> temp/finaltemp.csv

            echo "Les 10 conducteurs avec le plus de trajets sont : "
            cat temp/finaltemp.csv

            # Nettoyer les fichiers temporaires
            rm temp/firsttemp.csv temp/secondtemp.csv temp/thirdtemp.csv temp/finaltemp.csv

            ;;
        -d2)
            echo "Traitement D2..."
            #Recupérer 
            #awk -F';' '{count[$6]+=$5} END {for (driver in count) print driver ";" count[driver]}' "$input_file" >> temp/firsttemp.csv
            #awk -F';' '{count[$6]+=$5} END {for (driver in count) printf "%s;%.2f\n", driver, count[driver]}' "$input_file" >> temp/firsttemp.csv
            LC_NUMERIC="en_US.UTF-8" awk -F';' '{count[$6] += $5} END {for (driver in count) printf "%s;%.6f\n", driver, count[driver]}' "$input_file" >> temp/firsttemp.csv
            #LC_NUMERIC="en_US.UTF-8" awk -F';' '{count[$6] += $5} END {asorti(count, sorted_indices); for (i in sorted_indices) printf "%s;%.6f\n", sorted_indices[i], count[sorted_indices[i]]}' "$input_file" >> temp/firsttemp.csv



            # Trier la liste par ordre décroissant des distances totales
            sort -t';' -k2,2 -n -r temp/firsttemp.csv >> temp/secondtemp.csv 
            
            #longest_10_distances=$(head -n 10 temp/finaltemp.csv)
            head -n 10 temp/secondtemp.csv >> temp/finaltemp.csv
            
            echo "Les 10 conducteurs avec les plus grandes distances sont : "
            cat temp/finaltemp.csv
            
            rm temp/firsttemp.csv temp/finaltemp.csv temp/secondtemp.csv
            ;;
        -l)
            echo "Traitement L..."
            LC_NUMERIC="en_US.UTF-8" awk -F';' '{ sum[$1] += $5 } END { for (traject in sum) { formatted_value=sprintf("%.6f", sum[traject]); print traject ";" formatted_value } }' "$input_file" >> temp/templ.csv

            # trier les plus longs trajets
            sort -t ';' -k2,2 -n -r temp/templ.csv >> temp/tempcorrected.csv  
           
            # Récupérer les 10 premiers trajets
            head -n 10 temp/tempcorrected.csv >> temp/tempfinal.csv
           
            #trier les 10 trajets par numéro d'identification croissant
            sort -t ';' -k1,1 -n -r temp/tempfinal.csv >> temp/tempdone.csv
            longest_10_trajects=$(head -n 10 temp/tempdone.csv)

            # Créer le graphique de type histogramme
            echo "Les 10 trajets les plus longs sont : "
            echo "$longest_10_trajects"

            # Nettoyer les fichiers temporaires
            rm temp/temp.csv temp/templ.csv temp/tempcorrected.csv temp/tempfinal.csv temp/tempdone.csv
           
            ;;
        -t)
            echo "Traitement T..."
            # Vérification de l'executable c
            executable_verification "$option"
            #tail -n +2 "$input_file" > temp/firsttemp.csv
            #awk -F';' '{print $3";"$4";"$1";"$2}' temp/firsttemp.csv >> temp/secondtemp.csv

            # head -n 2000000 temp/temp.csv > temp/secondtemp.csv

  #awk avec ville de depart
            #awk -F';' '$2 == 1 {departure_city[$3]+=1 et count[$3]++ } END {for (city in departure_city) print city ";" departure_city[city]}' "$input_file" >> temp/firsttemp.csv

             # Recupère le nombre de trajets qui parcourent chaque ville, ainsi que le nombre de fois où ces villes ont été des villes de départ de trajets.
            #awk -F';' 'BEGIN { OFS=";"; } { count[$4] += 1; if ($2 == 1) { departure_city[$3] += 1; count[$3] += 1; } } END { for (city in count) print city, count[city] ";" (city in departure_city ? departure_city[city] : 0) }' "$input_file" >> temp/firsttemp.csv

            awk -F';' 'BEGIN { OFS=";"; }
            { 
                route_id = $1;
                townA = $3;
                townB = $4;

                # Vérifier si townA ou townB ne sont pas dans route_id SUBSEP town dans visited_cities
                if (!(route_id SUBSEP townA in visited_cities) || !(route_id SUBSEP townB in visited_cities)) {
                    if (!(route_id SUBSEP townA in visited_cities)) {
                        visited_cities[route_id SUBSEP townA] = 1;
                        count[townA] += 1;
                    }
                    if (!(route_id SUBSEP townB in visited_cities)) {
                        visited_cities[route_id SUBSEP townB] = 1;
                        count[townB] += 1;
                    }
                }

                if ($2 == 1) { 
                    departure_city[$3] += 1;
                }
            }
            END { 
                for (city in count) {
                    print city, count[city] ";" (city in departure_city ? departure_city[city] : 0);
                }
            }' "$input_file" >> temp/firsttemp.csv

            ./progc/progt temp/firsttemp.csv
             #sort -t ';' -k2,2 -n -r temp/firsttemp.csv >> temp/secondtemp.csv


             head -n 11 temp/secondtemp.csv >> temp/thirdtemp.csv
             #awk 'NF{printf "%s", $0; getline; print}' temp/thirdtemp.csv > temp/ok.csv

             ./progc/progt2 temp/thirdtemp.csv
             #sort -t ';' -k2,1 -n temp/thirdtemp.csv >> temp/finaltemp.csv

             cat temp/finaltemp.csv
             rm temp/firsttemp.csv temp/thirdtemp.csv temp/secondtemp.csv temp/finaltemp.csv
           ;;
        -s)
           echo "Traitement S..."
            # verification of the c executable
            executable_verification "$option"

            # Extract Route_id, Step_id and Distance from the data file
            cut -d';' -f1,2,5 "$input_file" >> temp/firsttemp.csv
            tail -n +2 temp/firsttemp.csv >> temp/secondtemp.csv

            # Start processing via the c program
            echo "Les statistiques sur les étapes sont : "
            ./progc/progs temp/secondtemp.csv

            # Recover the first 50 
            head -n 50 temp/output.csv >> temp/finaltemp.csv
            echo "Les 50 premiers sont : "
            cat temp/finaltemp.csv
            
            rm temp/output.csv temp/firsttemp.csv temp/secondtemp.csv temp/finaltemp.csv
            ;;

        *)
            echo "L'option $option n'est pas reconnue. Veuillez réessayer."
            exit 1 ;;
    esac
done

echo "ÇA COMPIILLEEEE HEHEEEE"
