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

           # Enregistrez le temps de début
            start_time=$(date +%s.%N)

            echo "Traitement D1..."
            #cat "$input_file" >> temp/temp.csv
            grep ";1;" "$input_file" > temp/firsttemp.csv
            awk -F';' '{count[$6]+= 1} END {for (driver in count) print driver ";" count[driver]}' temp/firsttemp.csv >> temp/secondtemp.csv

            # Trier la liste par ordre décroissant de nombre de trajets
            sort -t';' -k2,2 -n -r temp/secondtemp.csv >> temp/thirdtemp.csv 

            # Récupérer les 10 premiers conducteurs au choix fichier finaltemp.csv ou dansla variable
            # longest_10_drivers=$(head -n 10 temp/thirdtemp.csv)
            head -n 10 temp/thirdtemp.csv >> temp/finaltemp.csv

            # Commande Gnuplot
            gnuplot << EOF
            #Définition du style de sortie avec rotation
            set terminal pngcairo enhanced font 'arial,15' size 1100,1000
            set output 'images/Traitement1.png'
            
            #Séparateur pour le using
            set datafile separator ";"
            
            #Titre du graphique
            set ylabel 'Option -d1 : Nb routes = f(Driver)'
            
            #Style de la barre
            set style data histogram
            set style fill solid border -1
            
            #Enlever la légende
            unset key
            
            #Ajustement de la largeur des colonnes et positionnement à gauche
            set style histogram cluster gap 1
            set boxwidth 1.6
            
            #Axe X
            set xlabel 'DRIVER NAMES' rotate by 180
            set y2label 'NB ROUTES'
            
            #Ajustement des xtics
            set xtics rotate
            set y2range [0:250]
            
            #Ajustement des y2tics
            set y2tics rotate
            unset ytics;set y2tics mirror
            
            #Charger les données depuis le fichier temporaire
            plot 'temp/finaltemp.csv' using 2:xticlabels(1) axes x1y2 notitle linecolor 2 lt 1
EOF
            convert -rotate 90 images/Traitement1.png images/Traitement1.png
            
            
            # Placer l'image dans le dossier images
            mv "$output_file" images/
            # Ouvrir l'image
            xdg-open "images/Traitement1.png"
            
            # Nettoyer les fichiers temporaires
            rm temp/firsttemp.csv temp/secondtemp.csv temp/thirdtemp.csv temp/finaltemp.csv

             # Calculez la durée totale d'exécution
            execution_time=$(echo "$end_time - $start_time" | bc)

            echo "Le temps d'exécution est de $execution_time secondes."
            ;;
            
        -d2)
            echo "Traitement D2..."
            #Recupérer 
            #awk -F';' '{count[$6]+=$5} END {for (driver in count) print driver ";" count[driver]}' "$input_file" >> temp/firsttemp.csv
            LC_NUMERIC="en_US.UTF-8" awk -F';' '{count[$6] += $5} END {for (driver in count) printf "%s;%.6f\n", driver, count[driver]}' "$input_file" >> temp/firsttemp.csv

           
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
            LC_NUMERIC="en_US.UTF-8" awk -F';' '{ sum[$1] += $5 } END { for (traject in sum) { formatted_value=sprintf("%.6f", sum[traject]); print traject ";" formatted_value } }' "$input_file" >> temp/templ.csv
            
            # trier les plus longs trajets
            sort -t ';' -k2,2 -n -r temp/templ.csv >> temp/tempcorrected.csv
            # Récupérer les 10 premiers trajets
            head -n 10 temp/tempcorrected.csv >> temp/tempfinal.csv
            #trier les 10 trajets par numéro d'identification croissant
            sort -t ';' -k1,1 -n -r temp/tempfinal.csv >> temp/tempdone.csv
            longest_10_trajects=$(head -n 10 temp/tempdone.csv)
            
            # Nom du fichier de sortie du graphique
            output_file="TraitemenentL.png"
            
            # Commande Gnuplot
            gnuplot <<EOF
            # Police du graphique
            set terminal pngcairo enhanced font 'Verdana,12'
            # Fichier de sortie du gnuplot
            set output '$output_file'
            # Le plot sera un histogramme
            set style data histograms
            # Remplissage
            set style fill solid border -1
            # Largeur des cases
            set boxwidth 0.8
            # Titre du graphique
            set title 'Option -l : Distance = f(Trajet)'
            # Axe des x horizontal
            set xlabel 'Numéro identifiant de trajet'
            # Axe des y vertical
            set ylabel 'Distance en km'
            # Utiliser ';' comme séparateur
            set datafile separator ';'
            # Définir l'intervalle de l'axe des y et l'incrément des graduations
            set yrange [0:3000]
            set ytics 500
            # Rotation des étiquettes de l'axe des x
            set xtics rotate by -45
            # Plotting the top 10 data without legend
            plot '< head -n 10 temp/tempdone.csv' using 2:xtic(1) notitle with boxes
EOF
            
            # Placer l'image dans le dossier images
            mv "$output_file" images/
            # Ouvrir l'image
            xdg-open "images/$output_file"
            
            # Nettoyer les fichiers temporaires
            rm temp/templ.csv temp/tempcorrected.csv temp/tempfinal.csv temp/tempdone.csv
            ;;
        -t)
            echo "Traitement T..."
            # Vérification de l'executable c
            executable_verification "$option"

            # Recupère le nombre de trajets qui parcourent chaque ville, ainsi que le nombre de fois où ces villes ont été des villes de départ de trajets.
            awk -F';' 'BEGIN { OFS=";"; } { count[$4] += 1; if ($2 == 1) { departure_city[$3] += 1; count[$3] += 1; } } END { for (city in count) print city, count[city] ";" departure_city[city] }' "$input_file" >> temp/firsttemp.csv


            gcc -o progc/progt progc/programme_t.c
            ./progc/progt temp/firsttemp.csv
            
            head -n 10 temp/secondtemp.csv >> temp/thirdtemp.csv

            gcc -o progc/progt2 progc/programme_t2.c
            ./progc/progt2 temp/thirdtemp.csv

            cat temp/finaltemp.csv
            rm temp/firsttemp.csv temp/thirdtemp.csv temp/secondtemp.csv temp/finaltemp.csv

            ;;
        -s)
            echo "Traitement S..."
            # Vérification de l'executable c
            executable_verification "$option"
            #awk -F';' '{count[$1]++} END {for (route in count) print route ";" count[route]}' "$input_file" >> temp/temp.csv
            cut -d';' -f1,2,5 "$input_file" >> temp/firsttemp.csv
            #route=$(tail -n +2 temp/firsttemp.csv | head -n 10)
            #tail -n +2 temp/firsttemp.csv | head -n 100000 > temp/secondtemp.csv
            tail -n +3 temp/firsttemp.csv >> temp/secondtemp.csv 
            # DEMANDER A LA PROF 


            echo "Les statistiques sur les étapes sont : "

            ./progc/progs temp/secondtemp.csv

            # Récupérer les 50 premiers 
            head -n 50 temp/output.csv >> temp/finaltemp.csv
            echo "Les 50 premiers sont : "
            # route_id, min, max, moy, diff
            cat temp/finaltemp.csv
            
            rm temp/firsttemp.csv temp/output.csv temp/secondtemp.csv temp/finaltemp.csv
            ;;

        *)
            echo "L'option $option n'est pas reconnue. Veuillez réessayer."
            exit 1 ;;
    esac
done

echo "ÇA COMPIILLEEEE HEHEEEE"
