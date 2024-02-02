#!/bin/bash

#				.|'''', '\\  //`     |''||''| '||'''|, '||   ||` .|'''', '||  //' 
#				||        \\//          ||     ||   ||  ||   ||  ||       || //   
#				||         ||    ---    ||     ||...|'  ||   ||  ||       ||<<    
#				||         ||           ||     || \\    ||   ||  ||       || \\   
#				`|....'   .||.         .||.   .||  \\.  `|...|'  `|....' .||  \\.

###################################################################################################################################

# File Name: script.sh
# Author: Deulyne DESTIN, Asma KAJEIOU, Emma DOS SANTOS
# Created on: December 15, 2023
# Description:
#  This program will allow to perform different treatments in order to manage a csv file using programs c

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
                echo "Error while compiling... Please correct the errors before proceeding."
                exit 1
            fi
        fi
        if [ ! -f progc/progt2 ]
        then
            gcc -o progc/progt2 progc/programme_t2.c
            # Check if the compilation went well
            if [ $? -ne 0 ]
            then
                echo "Error while compiling... Please correct the errors before proceeding."
                exit 2
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
                echo "Error while compiling... Please correct the errors before proceeding."
                exit 3
            fi
        fi
        ;;
         *)
            echo "The option $option is not recognized... Please try again."
            exit 4 ;;
    esac
}


###### MAIN #######


# Recovery of the CSV file passed as argument
input_file=$1


# Checking the existence of the file
if [ ! -f "$input_file" ]
then
    echo "Le fichier $input_file n'existe pas."
    exit 5
fi
# Checking the file extension
if [[ ! "$input_file" =~ \.csv$ ]]
then
    echo "The file $input_file is not a CSV. Please try again..."
    exit 6
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

    exit 7
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
		
		echo -e "Treatment -d1 in progress...\n"
		
		# Collects the first stages of each journey and count the number of tajects per driver
		grep ";1;" "$input_file" > temp/firsttemp.csv
		awk -F';' '{count[$6]+= 1} END {for (driver in count) print driver ";" count[driver]}' temp/firsttemp.csv > temp/secondtemp.csv
		
		# Sorts the list in descending order of number of trips and get the first 10
		sort -t';' -k2,2 -n -r temp/secondtemp.csv > temp/thirdtemp.csv
		head -n 10 temp/thirdtemp.csv > temp/finaltemp.csv
		
		#set the output
		output_file="images/Treatment1.png"


################################## START OF GNUPLOT ##################################

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
		convert -rotate 90 "$output_file" "temp_rotated.png"
		
		# put the histogramm into the correct file
		mv "temp_rotated.png" "images/Treatment_1.png"
		
		# Open the visualizer of graphics for the right .png
		xdg-open "images/Treatment_1.png"
		
		# Clears temporary files needed for this treatment
		rm temp/firsttemp.csv temp/secondtemp.csv temp/thirdtemp.csv temp/finaltemp.csv
		
		# Records the end time
		end_time=$(date +%s)
		
		# Computes the difference
		execution_time=$((end_time - start_time))
		
		# Displays the execution time
		echo -e "-----------------TIMER-----------------\nThe Treatment -D1 took ${execution_time} seconds to run.\n"

            ;;
           
	-d2)
           
		# Saves the start time
		start_time=$(date +%s)
		
		echo -e "Treatment -D2 in progress...\n"
		
		# Gets the total distance travelled by each driver
		LC_NUMERIC="en_US.UTF-8" awk -F';' '{count[$6] += $5} END {for (driver in count) printf "%s;%.6f\n", driver, count[driver]}' "$input_file" > temp/firsttemp.csv
		
		# Sorts the list in descending order according to total distances and gets the first 10
		sort -t';' -k2,2 -n -r temp/firsttemp.csv > temp/secondtemp.csv
		head -n 10 temp/secondtemp.csv > temp/finaltemp.csv
		
		#set the output
		output_file="images/Treatment2.png"

################################## START OF GNUPLOT ##################################
		# Gnuplot starting command
		gnuplot << EOF
		
		# define the output style and the title
		set terminal pngcairo enhanced font 'arial,15' size 1100,1000
		set output '$output_file'
		set datafile separator ";"
		set ylabel 'Option -d2 : Distance = f(Driver)'
		
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
		set y2label 'DISTANCE (Km)'
		
		#adjust the presentation of data on the two axis
		set xtics rotate
		set y2range [0:160000]
		
		#Ajustement des y2tics
		set y2tics rotate
		unset ytics;set y2tics mirror
		
		#enters the data from the end-of-processing file to draw the histogram
		plot 'temp/finaltemp.csv' using 2:xticlabels(1) axes x1y2 notitle linecolor rgb 'purple' lt 1
EOF

####################################### END OF GNUPLOT ####################################

		#This puts the graph bars horizontally and parallel to the x-axis
		convert -rotate 90 "$output_file" "temp_rotated.png"
		
		# put the histogramm into the correct file
		mv  "temp_rotated.png" "images/Treatment_2.png"
		
		# Open the visualizer of graphics for the right .png
		xdg-open "images/Treatment_2.png"
		
		# Nettoyer les fichiers temporaires
		rm temp/firsttemp.csv temp/secondtemp.csv  temp/finaltemp.csv
		
		# Records the end time
		end_time=$(date +%s)
		
		# Computes the difference
		execution_time=$((end_time - start_time))
		
		# Displays the execution time
		echo -e "-----------------TIMER-----------------\nThe Treatment -D2 took ${execution_time} seconds to run.\n"
		        ;;

	-l)
		# Saves the start time
		start_time=$(date +%s)
		
		echo -e "Treatment -L in progress...\n"
		
		# Recovers the total distance of each journey
		LC_NUMERIC="en_US.UTF-8" awk -F';' '{ sum[$1] += $5 } END { for (traject in sum) { formatted_value=sprintf("%.6f", sum[traject]); print traject ";" formatted_value } }' "$input_file" > temp/firsttemp.csv
		
		# Sorts the list in descending order according to total distances and get the first 10
		sort -t ';' -k2,2 -n -r temp/firsttemp.csv > temp/secondtemp.csv
		head -n 10 temp/secondtemp.csv > temp/thirdtemp.csv
		
		# Sorts trips by increasing identification number
		sort -t ';' -k1,1 -n -r temp/thirdtemp.csv  > temp/finaltemp.csv
		
		#set the output
		output_file="TreatmentL.png"
  
################################## START OF GNUPLOT ##################################
		# Gnuplot starting command
		gnuplot <<EOF
		
		# define the output style and the title
		set terminal pngcairo enhanced font 'Verdana,12'
		set output '$output_file'
		set datafile separator ';'
		set title 'Option -l : Distance = f(Route)'
		
		#set the bar graph style
		set style data histograms
		set style fill solid border -1
		
		#adjust the width of the bars
		set boxwidth 0.8
		
		#set the axis names
		set xlabel 'ROUTE ID'
		set ylabel 'DISTANCE (Km)'
		
		#adjust the presentation of data on the two axis
		set xtics rotate by -45
		set yrange [0:3000]
		set ytics 500
		
		#enters the data from the end-of-processing file to draw the histogram
		plot '< head -n 10 temp/finaltemp.csv' using 2:xtic(1) notitle with boxes
EOF
####################################### END OF GNUPLOT ####################################

		# put the histogramm into the correct file
		mv "$output_file" images/
		 
		# Open the visualizer of graphics for the right .png
		xdg-open "images/$output_file"
		
		# Clears temporary files
		rm temp/firsttemp.csv temp/secondtemp.csv temp/thirdtemp.csv temp/finaltemp.csv
		
		# Records the end time
		end_time=$(date +%s)
		
		# Computes the difference
		execution_time=$((end_time - start_time))
		
		# Displays the execution time
		echo -e "-----------------TIMER-----------------\nThe Treatment -L took ${execution_time} seconds to run.\n"
		;;
           
            -t)
	              
		# Saves the start time
		start_time=$(date +%s)
		
		echo -e "Treatment -L in progress...\n"
		
		# Check the executable c
		executable_verification "$option"
		
		# Will count the number of times each city is crossed and the number of times they are departure city
		make -C progc Project_T1
		make -C progc Project_T2
		
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
		
		#compilation of the programme_t.c thanks to the makefile and then recover the firsst 10 lines
		./progc/Project_T1  temp/firsttemp.csv
		head -n 11 temp/firsttemp.csv >> temp/thirdtemp.csv
		
		#compilation of the programme_t2.c thanks to the makefile who sort by alphabetical order
		./progc/Project_T2 temp/thirdtemp.csv
		
		#set the output
		output_file="TreatmentT.png"

           
################################## START OF GNUPLOT ##################################

		# Gnuplot starting command
		gnuplot << EOF
		
		# define the output style and the title
		set terminal pngcairo enhanced font "arial,10" size 800,600
		set output "TreatmentT.png"
		set title "Option -t : Number routes = f(Towns)"
		
		#set the bar graph style
		set style data histograms
		set style fill solid 1.00 border 0
		set style histogram clustered gap 7
		
		#set the bar graph style
		set boxwidth 3
		
		#set the axis names
		set xlabel "Towns"
		set ylabel "Number routes"
		
		#adjust the presentation of data on the two axis
		set xtics rotate by -45
		set datafile separator ";"
		
		#enters the data from the end-of-processing file to draw the histogram
		plot 'temp/thirdtemp.csv' using 2:xtic(1) lc rgb "#4b0082" title "Total routes", '' using 3 lc rgb "#800080" title "First Town"

EOF

###################################### END OF GNUPLOT ####################################
		
		# put the histogramm into the correct file
		mv "$output_file" images/
		
		# Open the visualizer of graphics for the right .png
		xdg-open "images/$output_file"
		
		# Clears temporary files
		rm temp/firsttemp.csv temp/thirdtemp.csv
		
		# Records the end time
		end_time=$(date +%s)
		
		# Computes the difference
		execution_time=$((end_time - start_time))
		
		# Displays the execution time
		echo -e "-----------------TIMER-----------------\nThe Treatment -T took ${execution_time} seconds to run.\n"
		;;

     
       -s)
       
		# Saves the start time
		start_time=$(date +%s)
		
		echo -e "Treatment -S in progress...\n"
		
		make -C progc Project_S
		
		# Extract Route_id, Step_id and Distance from the data file
		cut -d';' -f1,2,5 "$input_file" >> temp/firsttemp.csv
		tail -n +2 temp/firsttemp.csv >> temp/secondtemp.csv
		
		# Start processing via the c program
		./progc/Project_S temp/secondtemp.csv
		
		# Recover the first 50
		head -n 50 temp/secondtemp.csv >> temp/finaltemp.csv
		
		# Configuration du graphique
		output_file="TreatmentS.png"
		

################################## START OF GNUPLOT ##################################
		# Gnuplot starting command
		gnuplot << EOF
		
		# define the output style and the title
		set terminal pngcairo enhanced font 'arial,10' size 1100,700
		set output 'images/TreatmentS.png'
		set datafile separator ";"
		set title 'Option -s: Distance = f(Route)'
		
		#set the axis names
		set xlabel 'ROUTE ID'
		set ylabel 'DISTANCE(Km)'
		
		#adjust the presentation of data on the two axis
		set ytics 100
		set xtics rotate by 45 right
		set yrange [0:1000]
		
		#enters the data from the end-of-processing file to draw the histogram
		plot 'temp/finaltemp.csv' using 0:3:5:xticlabels(2) with filledcurves linecolor rgb "#d8bfd8" title 'Distances Min-Max (Km)', \
		'' using 0:4 with lines linecolor rgb "#800080" title 'Distance average (Km)'
		
EOF
###################################### END OF GNUPLOT ####################################
           
		# put the histogramm into the correct file
		mv "images/TreatmentS.png" images/
		
		# Open the visualizer of graphics for the right .png
		xdg-open "images/TreatmentS.png"
		
		# Clears temporary files
		rm temp/output.csv temp/firsttemp.csv temp/secondtemp.csv temp/finaltemp.csv
		
		# Records the end time
		end_time=$(date +%s)
		
		# Computes the difference
		execution_time=$((end_time - start_time))
		
		# Displays the execution time
		echo -e "-----------------TIMER-----------------\nThe Treatment -S took ${execution_time} seconds to run.\n"
		
		            ;;

	-i)
		my_inventory() {
		 
		# Path to history file
		inventory_file="$HOME/.bash_history"
		# Check if history file exists
		if [ -f "$inventory_file" ]; then
			# Shows the last 2 orders
			echo -e "*****COMMAND HISTORY*****\nThe two previous command writed in the terminal were :"
			tail -n 2 "$inventory_file"
		else
			echo "The command history is not available."
		fi
		}
		
		my_inventory
		;;

	 *)
            echo "The option $option is not recognized... Please try again.\n"
            exit 8 ;;
    esac
done
