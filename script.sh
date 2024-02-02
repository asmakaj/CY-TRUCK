#!/bin/bash

#								.|'''', '\\  //`     |''||''| '||'''|, '||   ||` .|'''', '||  //' 
#								||        \\//          ||     ||   ||  ||   ||  ||       || //   
#								||         ||    ---    ||     ||...|'  ||   ||  ||       ||<<    
#								||         ||           ||     || \\    ||   ||  ||       || \\   
#								`|....'   .||.         .||.   .||  \\.  `|...|'  `|....' .||  \\.

###################################################################################################################################

# File Name: script.sh
# Author: Deulyne DESTIN, Asma KAJEIOU, Emma DOS SANTOS
# Created on: December 15, 2023
# Description: This program will allow to perform different options in order to manage a csv file using programs c

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
            make -C progc Project_T1
            # Check if the compilation went well
            if [ $? -ne 0 ]
            then
                echo "Error while compiling... Please correct the errors before proceeding."
                exit 1
            fi
        fi
        if [ ! -f progc/progt2 ]
        then
            make -C progc Project_T2
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
            make -C progc Project_S
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
            exit 4 
		;;
    esac
}

# Check if progc/files_o/ Directory is Empty
files_o_verification(){
    if [ -z "$(ls -A progc/files_o/)" ]; then
        rm -r progc/files_o/*
        # Handle errors if the removal command fails
        if [ $? -ne 0 ]; then
            echo "An error has occurred in the rm : exiting the program"
            exit 5
        fi
    fi
}


###### MAIN #######


# Recovery of the CSV file passed as argument
input_file=$1


# Checking the existence of the file
if [ ! -f "$input_file" ]
then
    echo -e "The file $input_file does not exist... \nPlease add the CSV file as follows :\n ./script.sh file.csv -options "
    exit 6
fi
# Checking the file extension
if [[ ! "$input_file" =~ \.csv$ ]]
then
    echo "The file $input_file is not a CSV. Please try again..."
    exit 7
fi


# Creation of the "data" folder if it does not exist
mkdir -p data
# Copy the CSV file to the data folder
cp "$input_file" data/ 


# Option h
# Loop that scans all arguments by checking the presence of the -t
for arg in "$@"
do
    # If an argument is equal to "-h", then the help is displayed
    if [ "$arg" == "-h" ]
    then
echo "------------------------------------------------------------ "
echo "                     _   _      _       "
echo "                    | | | | ___| |_ __  "
echo "                    | |_| |/ _ \ | '_ \ "
echo "                    |  _  |  __/ | |_) |"
echo "                    |_| |_|\___|_| .__/ "
echo "                                 |_|    "
echo "-------------------------------------------------------------"
echo -e "-> The various options <-"
echo "   -d1 : Drivers with the most trips"
echo "   -d2 : Drivers and the longest distance"
echo "   -l : Top 10 longest trips"
echo "   -t : Top 10 cities most traversed"
echo "   -s : Statistics on the steps"
echo "   -i : (bonus) Get the last two commands from the history"
echo "-------------------------------------------------------------"

    exit 8
    fi
done


# Check temp and image directories
create_directories

###### PROCESSING EXECUTION

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
		
		echo -e "Option -d1 in progress...\n"
		
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
		
		# Clears temporary files needed for this option
		rm temp/firsttemp.csv temp/secondtemp.csv temp/thirdtemp.csv temp/finaltemp.csv
		
		# Records the end time
		end_time=$(date +%s)
		
		# Computes the difference
		execution_time=$((end_time - start_time))
		
		# Displays the execution time
        echo "==========================TIMER=========================="
		echo "          The option -D1 took ${execution_time} seconds to run."
        echo "========================================================="

        ;;
           
	-d2)
           
	    # Saves the start time
		start_time=$(date +%s)
		
		echo -e "Option -D2 in progress...\n"
		
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
		
		# Clears temporary files needed for this treatment
		rm temp/firsttemp.csv temp/secondtemp.csv temp/finaltemp.csv
		
		# Records the end time
		end_time=$(date +%s)
		
		# Computes the difference
		execution_time=$((end_time - start_time))
		
		# Displays the execution time
        echo "==========================TIMER=========================="
		echo "          The Option -D2 took ${execution_time} seconds to run."
        echo "========================================================="
		
        ;;

	-l)
		# Saves the start time
		start_time=$(date +%s)
		
		echo -e "Option -L in progress...\n"
		
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
        echo "==========================TIMER=========================="
		echo "          The Option -L took ${execution_time} seconds to run."
        echo "========================================================="
		
        ;;
           
    -t)
	              
		# Saves the start time
		start_time=$(date +%s)
		
		echo -e "Option -T in progress...\n"
		
		# Check the executable c
		executable_verification "$option"
        files_o_verification "$option"

        # Check if File Exists
        if [ -e "progc/Project_T1" ]; then
            rm -f progc/Project_T1
            # Handle errors if the removal command fails
            if [ $? -ne 0 ]; then
                echo "An error has occurred in the rm : exiting the program"
                exit 9
            fi
        fi

        # Compilation
        make -C progc Project_T1
        # Handle errors if the compilation command fails
        if [ $? -ne 0 ]; then
            echo "An error has occurred in the compilation : exiting the program"
					# Displays the execution time
					echo "==========================TIMER=========================="
					echo "          The Option -T took ${execution_time} seconds to run."
					echo "========================================================="
            exit 10
        fi
        echo # Line break

        # Check if File Exists
        if [ -e "progc/Project_T2" ]; then
            rm -f progc/Project_T2
            # Handle errors if the removal command fails
            if [ $? -ne 0 ]; then
                echo "An error has occurred in the rm : exiting the program"
                exit 11
            fi
        fi

        # Compilation
        make -C progc Project_T2
        # Handle errors if the compilation command fails
        if [ $? -ne 0 ]; then
            echo "An error has occurred in the compilation : exiting the program"
            		# Displays the execution time
					echo "==========================TIMER=========================="
					echo "          The Option -T took ${execution_time} seconds to run."
					echo "========================================================="
            exit 12
        fi
        echo # Line break

        # Will count the number of times each city is crossed and the number of times they are departure city
        make -C progc Project_T1
        make -C progc Project_T2
		
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

		
		#compilation of the programme_t.c thanks to the makefile and then recover the first 10 lines
		./progc/Project_T1  temp/firsttemp.csv
		head -n 11 temp/firsttemp.csv > temp/thirdtemp.csv
		
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
        echo "==========================TIMER=========================="
		echo "          The Option -T took ${execution_time} seconds to run."
        echo "========================================================="
    
    ;;

     
    -s)
       
		# Saves the start time
		start_time=$(date +%s)
		
        executable_verification "$option"
        files_o_verification "$option"

		echo -e "Option -S in progress...\n"

        # Check if File Exists
        if [ -e "progc/Project_S" ]; then
            rm -f progc/Project_S    
        # Handle errors if the removal command fails
            if [ $? -ne 0 ]; then
                echo "An error has occurred in the rm : exiting the program"
                exit 13
            fi
        fi

        # Compilation
        make -C progc Project_S
        # Handle errors if the compilation command fails
        if [ $? -ne 0 ]; then
        echo "An error has occurred in the compilation : exiting the program"
        		# Displays the execution time
				echo "==========================TIMER=========================="
				echo "          The Option -S took ${execution_time} seconds to run."
				echo "========================================================="
        exit 14
        fi
        echo # Line break
		
		make -C progc Project_S
		
		# Extract Route_id, Step_id and Distance from the data file
		cut -d';' -f1,2,5 "$input_file" > temp/firsttemp.csv
		tail -n +2 temp/firsttemp.csv > temp/secondtemp.csv
		
		# Start processing via the c program
		./progc/Project_S temp/secondtemp.csv
		
		# Recover the first 50
		head -n 50 temp/secondtemp.csv > temp/finaltemp.csv
		
		# Set the output
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
		rm temp/firsttemp.csv temp/secondtemp.csv 
        # temp/output.csv temp/finaltemp.csv
		
		# Records the end time
		end_time=$(date +%s)
		
		# Computes the difference
		execution_time=$((end_time - start_time))
		
		# Displays the execution time
		# Displays the execution time
        echo "==========================TIMER=========================="
		echo "          The Option -T took ${execution_time} seconds to run."
        echo "========================================================="
		
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
			echo "The command history is not available... Try again later."
		fi
		}
		
		my_inventory
		;;

	 *)
            echo "The option $option is not recognized... Please try again."
            exit 15 ;;
    esac
done