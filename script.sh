#!/bin/bash

###################################################################################################################################

# File Name: script.sh
# Author: Deulyne DESTIN, Asma KAJEIOU, Emma DOS SANTOS
# Created on: December ..., 2023
# Description: (à mettre à jour)
#   This program collects all the stages of the journeys made by different drivers.
#   It will then sum the distances of the different steps while storing the min and max distances of the trips.
#   These data will be sorted in descending order of "max distance - min distance",
#   and then written to a csv output file as: 
#   Route_ID;min_distance;max_distance;average_distance;(max_distance-min_distance)

###################################################################################################################################


###### FUNCTIONS #######


# Creation of temp and image folders
create_directories(){
    file="temp"
    # Check if the folder exists
    if [ -d "$file" ]
    then
        # Ensures that all files and subdirectories in temp are deleted, even if the directory is already empty
        find temp -mindepth 1 -delete 
    fi

    mkdir -p temp images
}

# Verification of the presence of the C executable according to the treatments
executable_verification(){
    case $1 in
        -t)
        if [ ! -f progc/progt ]
        then
            gcc -o progc/progt progc/programme_t.c
            # Check if the compilation went well
            if [ $? -ne 0 ]
            then
                echo "Erreur lors de la compilation. Veuillez corriger les erreurs avant de continuer."
                exit 1
            fi
        fi
        if [ ! -f progc/progt2 ]
        then
            gcc -o progc/progt2 progc/programme_t2.c
            # Check if the compilation went well
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
            # Check if the compilation went well
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
}


###### MAIN #######


# Recovery of the CSV file passed as argument
input_file=$1


# Checking the existence of the file
if [ ! -f "$input_file" ]
then
    echo "Le fichier $input_file n'existe pas."
    exit 1
fi
# Checking the file extension
if [[ ! "$input_file" =~ \.csv$ ]]
then
    echo "Le fichier $input_file n'est pas un fichier .csv. Veuillez réessayer svp..."
    exit 1
fi


# Creation of the "data" folder if it does not exist
mkdir -p data
# Copy the CSV file to the data folder
cp "$input_file" data/ 


# Treatment h
# Loop that scans all arguments by checking the presence of the -t
for arg in "$@"
do
    # If an argument is equal to "-h", then the help is displayed
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


# Check temp and image directories
create_directories

# PROCESSING EXECUTION

# The first argument is the CSV file
input_file=$1
# The first argument is now the first argument given when running the script
shift

# Loop to process each argument
for option in "$@"
do
   case $option in
        -d1)
            # Saves the start time
            start_time=$(date +%s)

            echo "Traitement D1 in progress"

            # Collects the first stages of each journey and count the number of tajects per driver
            grep ";1;" "$input_file" > temp/firsttemp.csv
            awk -F';' '{count[$6]+= 1} END {for (driver in count) print driver ";" count[driver]}' temp/firsttemp.csv > temp/secondtemp.csv

            # Sorts the list in descending order of number of trips and get the first 10
            sort -t';' -k2,2 -n -r temp/secondtemp.csv > temp/thirdtemp.csv 
            head -n 10 temp/thirdtemp.csv > temp/finaltemp.csv


################################## START OF THE GNUPLOT ##################################

            # Gnuplot starting command 
            gnuplot << EOF

            # define the output style and the title
            set terminal pngcairo enhanced font 'arial,15' size 1100,1000
            set output 'images/Treatment1.png'
            set datafile separator ";"
            set ylabel 'Option -d1 : Nb routes = f(Driver)'

            #set the bar graph style 
            set style data histogram
            set style fill solid border -1

            #remove the legend
            unset key

            #adjust the width of the bars
            set style histogram cluster gap 1
            set boxwidth 1.6
      
            #set the axis names
            set xlabel 'DRIVER NAMES' rotate by 180
            set y2label 'NB ROUTES'
       
            #ajust the presentation of data on the two axis
            set xtics rotate
            set y2range [0:250]
            set y2tics rotate
            unset ytics;set y2tics mirror
            
            #enters the data from the end-of-processing file to draw the histogram
            plot 'temp/finaltemp.csv' using 2:xticlabels(1) axes x1y2 notitle linecolor rgb 'purple' lt 1
EOF
####################################### END OF GNUPLOT ####################################
           
            #This puts the graph bars horizontally and parallel to the x-axis
            convert -rotate 90 images/Treatment1.png images/Treatment1.png
            
            # put the histogramm into the correct file
            mv "$output_file" images/
            
            # Open the visualizer of graphics
            xdg-open "images/Treatment1.png"

            # Clears temporary files needed for this treatment
            rm temp/firsttemp.csv temp/secondtemp.csv temp/thirdtemp.csv temp/finaltemp.csv

            # Records the end time
            end_time=$(date +%s)

            # Computes the difference
            execution_time=$((end_time - start_time))

            # Displays the execution time
            echo "The program took ${execution_time} seconds to run."

            ;;
            
        -d2)
            
            # Saves the start time
            start_time=$(date +%s)
            
            echo "Traitement D2..."

            # Gets the total distance travelled by each driver
            LC_NUMERIC="en_US.UTF-8" awk -F';' '{count[$6] += $5} END {for (driver in count) printf "%s;%.6f\n", driver, count[driver]}' "$input_file" > temp/firsttemp.csv

            # Sorts the list in descending order according to total distances and gets the first 10
            sort -t';' -k2,2 -n -r temp/firsttemp.csv > temp/secondtemp.csv 
            head -n 10 temp/secondtemp.csv >> temp/finaltemp.csv
            echo "Les 10 conducteurs avec les plus grandes distances sont : "
            cat temp/finaltemp.csv

################################## START OF THE GNUPLOT ##################################
            # Commande Gnuplot
            gnuplot << EOF
            #Définition du style de sortie avec rotation
            set terminal pngcairo enhanced font 'arial,15' size 1100,1000
            set output 'images/Traitement2.png'
            
            #Séparateur pour le using
            set datafile separator ";"
            
            #Titre du graphique
            set ylabel 'Option -d2 : Distance = f(Driver)'
            
            #Style de la barre
            set style data histogram
            set style fill solid border -1
            
            #Enlever la légende
            unset key
            
            #Ajustement de la largeur des colonnes et positionnement à gauche
            set style histogram cluster gap 1
            set boxwidth 1.6
            
            #Axe X
            set xlabel 'DISTANCE (Km)' rotate by 180
            set y2label 'DRIVER NAMES'
            
            #Ajustement des xtics
            set xtics rotate
            set y2range [0:160000]
            
            #Ajustement des y2tics
            set y2tics rotate
            unset ytics;set y2tics mirror
            
            #Charger les données depuis le fichier temporaire
            plot 'temp/finaltemp.csv' using 2:xticlabels(1) axes x1y2 notitle linecolor 2 lt 1
EOF
            convert -rotate 90 images/Traitement2.png images/Traitement2.png
            
            
            # Placer l'image dans le dossier images
            mv "$output_file" images/
            # Ouvrir l'image
            xdg-open "images/Traitement2.png"

####################################### END OF GNUPLOT ####################################
            # Clears temporary files
            rm temp/firsttemp.csv temp/finaltemp.csv temp/secondtemp.csv
            
            # Records the end time
            end_time=$(date +%s)

            # Computes the difference
            execution_time=$((end_time - start_time))

            # Displays the execution time
            echo "The program took ${execution_time} seconds to run."

            
        ;;

           -l)
            # Saves the start time
            start_time=$(date +%s)

            echo "Traitement L..."

            # Recovers the total distance of each journey
            LC_NUMERIC="en_US.UTF-8" awk -F';' '{ sum[$1] += $5 } END { for (traject in sum) { formatted_value=sprintf("%.6f", sum[traject]); print traject ";" formatted_value } }' "$input_file" > temp/firsttemp.csv

            # Sorts the list in descending order according to total distances and get the first 10
            sort -t ';' -k2,2 -n -r temp/firsttemp.csv > temp/secondtemp.csv
            head -n 10 temp/secondtemp.csv > temp/thirdtemp.csv 
           
            # Sorts trips by increasing identification number
            sort -t ';' -k1,1 -n -r temp/thirdtemp.csv  > temp/finaltemp.csv

            longest_10_trajects=$(head -n 10 temp/finaltemp.csv)
            echo "Les 10 trajets les plus longs sont : "
            echo "$longest_10_trajects"


################################## START OF THE GNUPLOT ##################################
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

####################################### END OF GNUPLOT ####################################

            # Clears temporary files
            rm temp/firsttemp.csv temp/secondtemp.csv temp/thirdtemp.csv temp/finaltemp.csv


            # Records the end time
            end_time=$(date +%s)

            # Computes the difference
            execution_time=$((end_time - start_time))

            # Displays the execution time
            echo "The program took ${execution_time} seconds to run."

            ;;
            
            -t)
                    
            # Saves the start time
            start_time=$(date +%s)
            
             echo "Traitement T..."

            # Check the executable c
            executable_verification "$option"
            
            # Will count the number of times each city is crossed and the number of times they are departure city 
            awk -F';' 'BEGIN { OFS=";"; }
            { 
                route_id = $1;
                townA = $3;
                townB = $4;

                # Check if Route_ID/townA or Route_ID/townB are not already present in the visited_cities table, 
                # otherwise a new box of the table with these values is created and initialized to 1

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

                # If the journey step is 1, then the value assigned to townA is incremented in the departure_city table

                if ($2 == 1) { 
                    departure_city[$3] += 1;
                }
            }
            
            # Displays the results in a temporary file
            END { 
                for (city in count) {
                    print city, count[city] ";" (city in departure_city ? departure_city[city] : 0);
                }
            }' "$input_file" > temp/firsttemp.csv

            # Sort by descending order the cities according to the number of times they are crossed and get the first 10
            ./progc/progt temp/firsttemp.csv
            head -n 11 temp/secondtemp.csv > temp/thirdtemp.csv

            # Alphabetize the top 10 cities 
            ./progc/progt2 temp/thirdtemp.csv
            cat temp/finaltemp.csv

################################## START OF THE GNUPLOT ##################################
###################################### END OF GNUPLOT ####################################

            # Clears temporary files
            rm temp/firsttemp.csv temp/thirdtemp.csv temp/secondtemp.csv temp/finaltemp.csv

             # Records the end time
            end_time=$(date +%s)

            # Computes the difference
            execution_time=$((end_time - start_time))

            # Displays the execution time
            echo "The program took ${execution_time} seconds to run."

           
           ;;
           
       -s)
        
            # Saves the start time
            start_time=$(date +%s)

            echo "S treatment..."
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


################################## START OF THE GNUPLOT ##################################
###################################### END OF GNUPLOT ####################################

            # Clears temporary files
            rm temp/output.csv temp/firsttemp.csv temp/secondtemp.csv temp/finaltemp.csv

            # Records the end time
            end_time=$(date +%s)

            # Computes the difference
            execution_time=$((end_time - start_time))

            # Displays the execution time
            echo "The program took ${execution_time} seconds to run."

            ;;

        *)
            echo "The option $option is not recognized... Please try again.\n"
            exit 1 ;;
    esac
done

echo "ÇA COMPIILLEEEE HEHEEEE"
