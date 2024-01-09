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
        ;;
        -s)
        if [ ! -f progc/progs2 ]
        then
            #gcc -o progc/progs progc/programme_s.c
            gcc -o progc/progs2 progc/programme_s2.c
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

# À SUPPRIMER QUAND ON AURA FINI DE TOUT CODER
#compilation() {
 #   gcc -o progc/prog progc/programme.c
#    if [ $? -ne 0 ]
#    then
#       echo "Erreur lors de la compilation. Veuillez corriger les erreurs avant de continuer."
#        exit 1
#    fi
#}

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
            #cat "$input_file" >> temp/temp.csv
            grep ";1;" "$input_file" > temp/firsttemp.csv
            awk -F';' '{count[$6]+= 1} END {for (driver in count) print driver ";" count[driver]}' temp/firsttemp.csv >> temp/secondtemp.csv

            # Trier la liste par ordre décroissant de nombre de trajets
            sort -t';' -k2,2 -n -r temp/secondtemp.csv >> temp/thirdtemp.csv 

            # Récupérer les 10 premiers conducteurs au choix fichier finaltemp.csv ou dansla variable
            # longest_10_drivers=$(head -n 10 temp/thirdtemp.csv)
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
            # récupérer les distances totales pour chaque trajet (meme route ID)
            #cat "$input_file" >> temp/temp.csv
            #awk -F ';' '{ sum[$1] += $5 } END { for (traject in sum) { formatted_value=sprintf("%.6f", sum[traject]); print traject ";" formatted_value } }' "$input_file" >> temp/templ.csv
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

            # Partie du awk qui ne fonctionne pas (nombre de trajets qui parcourent chaque ville)
            #awk -F';' '{count[$4]+= 1} END {for (city in count) print city ";" count[city]}' "$input_file" >> temp/firsttemp.csv


            #awk -F';' '{ count[$3] += 1; count[$4] += 1 } END { for (item in count) print item ";" count[item] }' "$input_file" >> temp/firsttemp.csv
            #awk -F';' '{count[$3] += 1; if ($4 in count) count[$4] += 1 sinon crée count[$4] =+ 1} END { for (item in count) print item ";" count[item] }' temp/temp.csv >> temp/firsttemp.csv
            #awk -F';' '{count[$3] += 1; if ($4 in count) count[$4] += 1; else count[$4] = 1} END { for (item in count) print item ";" count[item] }' "$input_file" >> temp/firsttemp.csv

            # Partie du awk qui compte departure city -> les valeurs sont bonnes
            #awk -F';' '$2 == 1 {departure_city[$3]+=1 et count[$3]++ } END {for (city in departure_city) print city ";" departure_city[city]}' "$input_file" >> temp/firsttemp.csv


            #awk -F';' 'BEGIN { OFS=";"; } { count[$4] += 1; if ($2 == 1) { departure_city[$3] += 1; count[$3] += 1; } } END { for (city in count) print city, count[city] ";" departure_city[city] }' "$input_file" >> temp/firsttemp.csv
            awk -F';' 'BEGIN { OFS=";"; } { count[$4] += 1; if ($2 == 1) { departure_city[$3] += 1; count[$3] += 1; } } END { for (city in count) print city, count[city] ";" (city in departure_city ? departure_city[city] : 0) }' "$input_file" >> temp/firsttemp.csv

            gcc -o progc/progt progc/programme_t.c
            ./progc/progt temp/firsttemp.csv

            #sort -t ';' -k2,2 -n -r temp/firsttemp.csv >> temp/secondtemp.csv

            
            head -n 20 temp/secondtemp.csv >> temp/thirdtemp.csv
            #awk 'NF{printf "%s", $0; getline; print}' temp/thirdtemp.csv > temp/ok.csv

            gcc -o progc/progt2 progc/programme_t2.c
            ./progc/progt2 temp/thirdtemp.csv

            #sort -t ';' -k2,1 -n temp/thirdtemp.csv >> temp/finaltemp.csv

            cat temp/finaltemp.csv
            rm temp/firsttemp.csv temp/temp.csv temp/secondtemp.csv temp/thirdtemp.csv temp/finaltemp.csv

            ;;
        -s)
            echo "Traitement S..."
            # Vérification de l'executable c
            executable_verification "$option"
            #awk -F';' '{count[$1]++} END {for (route in count) print route ";" count[route]}' "$input_file" >> temp/temp.csv
            cut -d';' -f1,2,5 "$input_file" | tail -n +2 > temp/firsttemp.csv
awk -F ';' '
    BEGIN {
        FS=";"
        OFS=";"
    }

    # Fonction pour traiter chaque ligne
    function process_line(route_ID, etape, distance) {
        if (!(route_ID in trajets)) {
            trajets[route_ID] = ""
        }
        trajets[route_ID] = trajets[route_ID] route_ID OFS etape OFS distance ORS
    }

    # Traitement de chaque ligne
    {
        route_ID = $1
        etape = $2
        distance = $3
        process_line(route_ID, etape, distance)
    }

    # À la fin de la lecture du fichier, afficher les résultats
    END {
        for (route_ID in trajets) {
            print trajets[route_ID]
        }
    }
' temp/firsttemp.csv > temp/secondtemp.csv


            # Script 1: Calcul de min, max et moyenne
awk -F ';' '
    BEGIN {
        # Initialisation des variables
        FS=";"
        OFS=";"
    }

    # Fonction pour mettre à jour les statistiques
    function update_distances(route_ID, distance){

        if (distance < min[route_ID] || !(route_ID in min)) {
            min[route_ID] = distance
        }
        if (!(route_ID in max) || distance > max[route_ID]) {
            max[route_ID] = distance
        }
        total_distance[route_ID] += distance
        count[route_ID]++
    }

    # Traitement de chaque ligne
    {
        route_ID = $1
        distance = $3
        update_distances(route_ID, distance)
    }

    # À la fin de la lecture du fichier, afficher les résultats
    END {
        for (route_ID in min) {
            moyenne = total_distance[route_ID] / count[route_ID]
            print route_ID, min[route_ID], max[route_ID], moyenne
        }
    }
' temp/secondtemp.csv > temp/thirdtemp.csv




            echo "Les statistiques sur les étapes sont : "
            gcc -o progc/prog2 progc/programme_s.c
            ./progc/progs2 temp/thirdtemp.csv

            # Récupérer les 50 premiers 
            head -n 50 temp/output.csv >> temp/finaltemp.csv
            echo "Les 50 premiers sont : "
            # route_id, min, max, moy, diff
            cat temp/finaltemp.csv
            
            rm temp/firsttemp.csv temp/output.csv temp/secondtemp.csv temp/finaltemp.csv temp/thirdtemp.csv
            ;;

        *)
            echo "L'option $option n'est pas reconnue. Veuillez réessayer."
            exit 1 ;;
    esac
done

echo "ÇA COMPIILLEEEE HEHEEEE"
