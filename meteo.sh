#!/bin/bash

##########Variables#############
fichier=""
fichier_temp="temp.csv"
localisation_fichier="localisation.csv"
temperature1='-t1'
temperature2='-t2'
temperature3='-t3'
pression1='-p1'
pression2='-p2'
pression3='-p3'
wind='-w'
altitude='-h'
humidite='-m'
all_args=$*

#Sorting the arguments

data_args="-t1 -t2 -t3 -p1 -p2 -p3 -w -h -m "
geo_args="-F -G -S -A -O -Q"
date_args="-d"
tri_args="--tab --avl --abr"
file_args="-f"
###############
data_args_true=()
geo_args_true=()
date_args_true=()
tri_args_true=()
file_args_true=()

###################Latitude & longitude##############
#France & Corse
F_long_min=-4.971415
F_long_max=9.878467
F_lat_max=51.270339
F_lat_min=41.210628
#### Guyane
G_lat_min=1.8478803779844726
G_long_min=-54.69873610259564
G_lat_max=6.113934908040344
G_long_max=-51.09053415541363
###St Pierre & Miquelon
S_lat_min=46.7221817600691
S_long_min=-56.461309006811724
S_lat_max=47.17515419807999
S_long_max=-56.03663540013838
###Antilles
A_lat_min=6.554650796080206
A_long_min=-77.39700107476912
A_lat_max=27.72078809213117
A_long_max=-60.869610705585
###Ocean Indien
O_lat_min=-36.45534607533344
O_long_min=34.2301840195848
O_lat_max=14.017777948216473
O_long_max=113.71778433592755
###Antartique
Q_lat_min=-90
Q_long_min=-180
Q_lat_max=-60
Q_long_max=180

##### Compile all C files ###
if [ ! -e Src/main ]; then
    echo Lancement de la compilation
    (cd Src && make && echo Compilation finie);
fi


###Identification of arguments###
for ((var=1;var<= $#;var++)); #var in $all_args;
    do
    ######## Data argument ####
    if [[ $data_args =~ (^|[[:space:]])${!var}($|[[:space:]]) ]]; then 
    data_args_true+=(${!var})
    fi
    ######## Geographical argument####
    if [[ $geo_args =~ (^|[[:space:]])${!var}($|[[:space:]]) ]]; then 
    geo_args_true+=(${!var})
    fi
    ######## Sorting argument ####
    if [[ $tri_args =~ (^|[[:space:]])${!var}($|[[:space:]]) ]]; then 
    tri_args_true+=(${!var})
    fi
    ######## File argument ####
    if [[ $file_args =~ (^|[[:space:]])${!var}($|[[:space:]]) ]]; then
    file=$((var+1))
    fichier=${!file}
    file_args_true+=(${!var})
    fi
    ######## Date argument ####
    if [[ $date_args =~ (^|[[:space:]])${!var}($|[[:space:]]) ]]; then
    idx_1=$((var+1))
    idx_2=$((var+2))
    date_1_YY=${!idx_1}
    date_2_YY=${!idx_2}
    HH=" 00:00:00"
    date_1="$date_1_YY$HH"
    date_2="$date_2_YY$HH"
    ######Check if the dates are in the right format####
    if [[ ($date_1 =~ ^[0-9]{4}-[0-1][0-9]-[0-3][0-9]\ [0-2][0-9]:[0-5][0-9]:[0-5][0-9]$  &&  $date_2 =~ ^[0-9]{4}-[0-1][0-9]-[0-3][0-9]\ [0-2][0-9]:[0-5][0-9]:[0-5][0-9]$)]] ; then
      echo 
    else 
      echo "Les date ne sont pas au format. Veuillez utiliser -d YYYY-MM-DD HH-mm-SS "
      exit 1
    fi
    ############Check that the dates are in order###################""
    date1_seconds=$(date -d "$date_1" +%s)
    date2_seconds=$(date -d "$date_2" +%s)
    if [[ $date1_seconds -gt $date2_seconds ]]; then
      echo "Attention ! $date_1_YY est après $date_2_YY. Les dates doivent être cohérente"
      exit 1
    fi

    date_args_true+=(${!var})
    fi
done

##############Check###################
if [ ! -e $fichier ] || [ -z $fichier ];then
  echo "Ce fichier n'existe pas ! Reessayer avec le bon fichier"
  exit 1
fi

if [ ${#tri_args_true[@]} -gt 1 ];then
  echo "Trop d'argument pour trier ! N'en choisir que 1 parmi --tab --avl ou --abr"
  exit 1
fi

if [ ${#data_args_true[@]} == 0 ];then
  echo "Seléctionner au moins un argument (-w, -p, ...) "
  exit 1
fi

if [ ${#geo_args_true[@]} -gt 1 ];then
  echo "Trop d'argument géographique ! N'en choisir que 1 parmi -F -G -S -A -O -Q"
  exit 1
fi

if [ ${#file_args_true[@]} -gt 1 ];then
  echo "Trop d'argument de fichier ! N'en choisir que 1"
  exit 1
fi

#### Creating a temporary file to store
cp $fichier $fichier_temp

##############################Sorting argument function######
launch_file() {
  echo "Trie en cours..."
  if [ "$1" == "--tab" ]; then
    ./Src/lineaire $2
  elif [ "$1" == "--avl" ]; then
    ./Src/AVL_der $2
  elif [ ${#tri_args_true[@]} == 0 ]; then
    ./Src/AVL_der $2
  elif [ "$1" == "--abr" ]; then
    ./Src/BST_tri $2
  else
    echo "Invalid argument. Please use --tab, --avl, or --abr."
  fi
}



#######Filter by location ####

for var_geo in $geo_args_true;
do
    lat_min="${var_geo:1}"_lat_min
    lat_mini="${!lat_min}"
    
    lat_max="${var_geo:1}"_lat_max
    lat_maxi="${!lat_max}"

    long_min="${var_geo:1}"_long_min
    long_mini="${!long_min}"

    long_max="${var_geo:1}"_long_max
    long_maxi="${!long_max}"
    echo Filtrage géographique en cours...
    if [ ! -z "$date_args_true" ] ; then
      awk -v lat_maxi=$lat_maxi -v lat_mini=$lat_mini -v long_maxi=$long_maxi -v long_mini=$long_mini -F ";" 'NR==1{print $0; next}NR==FNR && FNR>1{split($10,a,",");if((a[1]<lat_maxi  && a[1]>lat_mini) && (a[2]<long_maxi && a[2]>long_mini)){print $0}}' $fichier > $localisation_fichier
    else
      awk -v lat_maxi=$lat_maxi -v lat_mini=$lat_mini -v long_maxi=$long_maxi -v long_mini=$long_mini -F ";" 'NR==1{print $0; next}NR==FNR && FNR>1{split($10,a,",");if((a[1]<lat_maxi  && a[1]>lat_mini) && (a[2]<long_maxi && a[2]>long_mini)){print $0}}' $fichier > $fichier_temp
    fi
done


##############Filter by date ################
if [ ! -z "$date_args_true" ] ; then
    echo Filtrage temporel en cours...
    if [ ! -z "$geo_args_true" ]; then
      awk -v date_1="$date_1" -v date_2="$date_2" -F ";" 'NR==1{print $0; next} NR==FNR && FNR>1{f="\\1 \\2 \\3 \\4 \\5 \\6 \\7";inf=mktime(gensub(/(....)-(..)-(..) (..):(..):(..)/, "\\1 \\2 \\3 \\4 \\5 \\6", "g", date_1));sup=mktime(gensub(/(....)-(..)-(..) (..):(..):(..)/, "\\1 \\2 \\3 \\4 \\5 \\6", "g", date_2));a=mktime(gensub(/(....)-(..)-(..)T(..):(..):(..)([+-].*)/, f, "g", $2));if(a>inf && a<sup) {print $0}}' $localisation_fichier>$fichier_temp 
      rm $localisation_fichier
    else
      awk -v date_1="$date_1" -v date_2="$date_2" -F ";" 'NR==1{print $0; next} NR==FNR && FNR>1{f="\\1 \\2 \\3 \\4 \\5 \\6 \\7";inf=mktime(gensub(/(....)-(..)-(..) (..):(..):(..)/, "\\1 \\2 \\3 \\4 \\5 \\6", "g", date_1));sup=mktime(gensub(/(....)-(..)-(..) (..):(..):(..)/, "\\1 \\2 \\3 \\4 \\5 \\6", "g", date_2));a=mktime(gensub(/(....)-(..)-(..)T(..):(..):(..)([+-].*)/, f, "g", $2));if(a>inf && a<sup) {print $0}}' $fichier > $fichier_temp   
    fi
fi


####################################################################### MAIN ###########################################################
for var in $data_args_true; do
    if [ $var == $temperature1 ]; then
        awk -F ";" 'NR==1{print $1,",Température moyenne",",Temperature maximal",",Température minimal"; next}
        NR==FNR && FNR>1{arr[$1]+=$11;count[$1]+=1;if(max[$1]<$11){max[$1]=$11;};if(!($1 in min) || (min[$1]>0+$11 && ($11 != ""))){min[$1]=0+$11;};} 
        END {for (i in arr) {print i","arr[i]/count[i]","max[i]","min[i]}}' $fichier_temp > tri_"${var:1}".csv
        ./Src/main "$tri_args_true" -f tri_"${var:1}".csv -o sorted_tri_"${var:1}".csv
        echo Affichage des temperature t1
        #gnuplot -p -e "set datafile separator ',';set nokey; set title 'Température moyenne et la différence entre le Maximal & Minimal par Station';set nokey; set xlabel 'ID Station';set ylabel 'Temperature'; set style fill pattern 4; set autoscale; ; plot 'sorted_tri_t1.csv' using 1:2:(column(3)-column(4)) with yerrorbars, 'sorted_tri_t1.csv' using 1:2 with lines"
        gnuplot -p -e "set datafile separator ',';Shadecolor = '#80E0A080';set nokey; set title 'Température moyenne et la différence entre le Maximal & Minimal par Station';set nokey; set xlabel 'ID Station';set ylabel 'Temperature'; set autoscale; plot 'sorted_tri_t1.csv' using 1:(column(2)-(column(3)-column(4))):(column(2)+(column(3)-column(4))) with filledcurve fc rgb Shadecolor title 'Shaded error region', '' using 1:2 with lines lw 2"

        #rm *tri_t1*
    fi

    #we have a problem with the minimum 
    if [ $var == $pression1 ]; then
        awk -F ";" 'NR==1{print $1,",Pression moyenne",",Pression maximal",",Pression minimal"; next}
        NR==FNR && FNR>1{arr[$1]+=$7;count[$1]+=1;if(max[$1]<$7){max[$1]=$7;};if(!($1 in min) || (min[$1]>0+$7 && ($7 != ""))){min[$1]=0+$7;};} 
        END {for (i in arr) {print i","arr[i]/count[i]","max[i]","min[i]}}' $fichier_temp > tri_"${var:1}".csv
        ./Src/main "$tri_args_true" -f tri_"${var:1}".csv -o sorted_tri_"${var:1}".csv
        echo Affichage des pression p1
        gnuplot -p -e "set datafile separator ',';Shadecolor = '#80E0A080';set nokey; set title 'Pression moyenne et la différence entre le Maximal & Minimal par Station';set nokey; set xlabel 'ID Station';set ylabel 'Pression'; set autoscale; plot 'sorted_tri_p1.csv' using 1:(column(2)-(column(3)-column(4))):(column(2)+(column(3)-column(4))) with filledcurve fc rgb Shadecolor title 'Shaded error region', '' using 1:2 with lines lw 2"
        #rm $fichier_temp
    fi

    if [ $var == $temperature2 ]; then
    awk -F ";" 'NR==1{print $2,",Température moyenne"; next}
        NR==FNR && FNR>1{arr[$2]+=$11;count[$2]+=1;f="\\1 \\2 \\3 \\4 \\5 \\6 \\7"} 
        END {for (i in arr) {j=mktime(gensub(/(....)-(..)-(..)T(..):(..):(..)([+-].*)/, f, "g", i));print j","arr[i]/count[i]}}' $fichier_temp > tri_"${var:1}".csv
        ./Src/main "$tri_args_true" -f tri_"${var:1}".csv -o sorted_tri_"${var:1}".csv
        awk -F, 'NR==1{print "Date",",Température moyenne"; next} NR==FNR && FNR>1{
          timestamp=$1;
          time_string=strftime("%Y-%m-%d %H:%M:%S", timestamp);
          print time_string "," $2}' sorted_tri_t2.csv > dated_sorted_tri_t2.csv
        echo Affichage de la carte temperature moyenne par date
        gnuplot -p -e "set datafile separator ','; set nokey;set xdata time; set timefmt '%Y-%m-%d %H:%M:%S' ;set title 'Température moyenne par date';set nokey; set xlabel 'Date';set ylabel 'Température';  set autoscale; plot 'dated_sorted_tri_t2.csv' using 1:2 with lines"
        rm dated_sorted_tri_t2.csv
    fi
    ##Bizzare l'évolution temporel
    if [ $var == $pression2 ]; then
    awk -F ";" 'NR==1{print $2,",Pression moyenne"; next}
        NR==FNR && FNR>1{arr[$2]+=$7;count[$2]+=1;f="\\1 \\2 \\3 \\4 \\5 \\6 \\7"} 
        END {for (i in arr) {j=mktime(gensub(/(....)-(..)-(..)T(..):(..):(..)([+-].*)/, f, "g", i));print j","arr[i]/count[i]}}' $fichier_temp > tri_"${var:1}".csv
        ./Src/main "$tri_args_true" -f tri_"${var:1}".csv -o sorted_tri_"${var:1}".csv
        awk -F, 'NR==1{print "Date",",Pression moyenne"; next} NR==FNR && FNR>1{
          timestamp=$1;
          time_string=strftime("%Y-%m-%d %H:%M:%S", timestamp);
          print time_string "," $2}' sorted_tri_p2.csv > dated_sorted_tri_p2.csv
        echo Affichage de la carte Pression moyenne par date
        gnuplot -p -e "set datafile separator ','; set nokey;set xdata time; set timefmt '%Y-%m-%d %H:%M:%S' ;set title 'Pression moyenne par date';set nokey; set xlabel 'Date';set ylabel 'Pression';  set autoscale; plot 'dated_sorted_tri_p2.csv' using 1:2 with lines"
        #rm dated_sorted_tri_p2.csv
    fi

    if [ $var == $temperature3 ]; then
    awk -F ";" 'NR==1{print $2,$1,$11; next}
        NR==FNR && FNR>1{f="\\1 \\2 \\3 \\4 \\5 \\6 \\7";time=mktime(gensub(/(....)-(..)-(..)T(..):(..):(..)([+-].*)/, f, "g", $2));print time","$1","$11}' $fichier_temp > tri_"${var:1}".csv
    ./Src/main "$tri_args_true" -f tri_"${var:1}".csv -o sorted_tri_"${var:1}".csv
    #awk -F ";" 'NR==1{print $2,$1,$11; next}
    #    NR==FNR && FNR>1{print $2,$1,$11}' $fichier_temp > tri_"${var:1}".csv
    fi

    if [ $var == $pression3 ]; then
    awk -F ";" 'NR==1{print $2,$1,$7; next}
        NR==FNR && FNR>1{print $2,$1,$7}' $fichier_temp > tri_"${var:1}".csv
    fi


    if [ $var == $altitude ]; then
        awk -F ";" 'NR==1{print $1,",",$14,",Latitude",",Longitude"; next}
        NR==FNR && FNR>1{arr[$1]=$14;split($10,a,",");lat[$1]=a[1];lon[$1]=a[2]} 
        END {for (i in arr) {print i","arr[i]","lat[i]","lon[i]}}' $fichier_temp > tri_"${var:1}".csv
        ./Src/main "$tri_args_true" -f tri_"${var:1}".csv -o sorted_tri_"${var:1}".csv -r
        echo Affichage de la carte altitude
        gnuplot -p -e "set datafile separator ',' ; set nokey;set xlabel 'Longitude';set ylabel 'Latitude'; set title 'HeatMap Altitude';set view map;set autoscale fix;set pm3d at b map;set dgrid3d 200,200,1; splot 'sorted_tri_h.csv' using (column(4)):(column(3)):(column(2))"
        #rm *tri_h*
    fi  

    if [ $var == $humidite ]; then
        awk -F ";" 'NR==1{print $1,",Humidité maximal",",Latitude",",Longitude"; next} 
        NR==FNR && FNR>1{if(max[$1]<$6){max[$1]=$6;};split($10,a,",");lat[$1]=a[1];lon[$1]=a[2]} 
        END {for (i in max) {print i","max[i]","lat[i]","lon[i]}}' $fichier_temp > tri_"${var:1}".csv
        ./Src/main "$tri_args_true" -f tri_"${var:1}".csv -o sorted_tri_"${var:1}".csv -r
        echo Affichage de la carte humidite
        gnuplot -p -e "set datafile separator ',' ; set nokey; set xlabel 'Longitude';set ylabel 'Latitude'; set title 'HeatMap Humidité';set view map;set autoscale fix;set pm3d at b map;set dgrid3d 200,200,1; splot 'sorted_tri_m.csv' using (column(4)):(column(3)):(column(2))"
        #rm *tri_m*

    fi

    if [ $var == $wind ]; then
        awk -F ";" 'NR==1{print $1,",Direction vent moyenne",",Vitesse vent moyenne",",Latitude",",Longitude"; next}
        NR==FNR && FNR>1{direction[$1]+=$4;count[$1]+=1;vitesse[$1]+=$5;split($10,a,",");lat[$1]=a[1];lon[$1]=a[2]} 
        END {for (i in direction) {print i","direction[i]/count[i]","vitesse[i]/count[i]","lat[i]","lon[i]}}' $fichier_temp > tri_"${var:1}".csv;
        ./Src/main "$tri_args_true" -f tri_"${var:1}".csv -o sorted_tri_"${var:1}".csv
        echo Affichage de la carte des vents
        gnuplot -p -e "set datafile separator ',';set nokey;set xlabel 'Longitude';set ylabel 'Latitude';set title 'Carte des vents';xf(phi,len) = len*cos(phi/180.0*pi+pi/2);yf(phi,len) = len*sin(phi/180.0*pi+pi/2); plot 'sorted_tri_w.csv' using (column(5)):(column(4)):((xf(column(2),column(3)))):((yf(column(2),column(3)))):3 with vectors head size 2,20,60;"
        #rm *tri_w*

    fi

done
rm $fichier_temp
exit 0
