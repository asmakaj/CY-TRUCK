            awk -F';' 'BEGIN { OFS=";"; }
{
    route_id = $1;
    townA = $3;
    townB = $4;

    if (!(route_id SUBSEP townA in visited_cities)) {
        visited_cities[route_id SUBSEP townA] = 1;
        count[townA] += 1;
    }


    if ($2 == 1) {
        departure_city[townA] += 1;
    }
}
END {
    for (city in count) {
        print city, count[city] ";" (city in departure_city ? departure_city[city] : 0);
    }
}' "$input_file" >> temp/firsttemp.csv


awk -F';' 'BEGIN { OFS=";"; }
{ 
    route_id = $1;
    townA = $3;
    townB = $4;

        if (townA ou townB ne sont pas dans route_id SUBSEP town in visited_cities) {
            if (!(route_id SUBSEP townA in visited_cities)) {
                visited_cities[route_id SUBSEP townA] = 1;
                count[townA] += 1;
            }
            if (!(route_id SUBSEP townB in visited_cities)) {
                visited_cities[route_id SUBSEP townB] = 1;
                count[townB] += 1;
            }

    }

    if ($2 == 1) { departure_city[$3] += 1;}

}
END { for (city in count) print city, count[city] ";" (city in departure_city ? departure_city[city] : 0) }' "$input_file" >> temp/firsttemp.csv

# C'est equivalent à :

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
