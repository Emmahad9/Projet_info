#!/bin/bash

##########Variables#############
fichier="Data/meteo.csv"
fichier_temp="temp.csv"
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

#Trier les arguments

data_args="-t1 -t2 -t3 -p1 -p2 -p3 -w -h -m "
geo_args="-F -G -S -A -O -Q"
date_args="-d"
tri_args="--tab --avr --abl"
file_args="-f"
###############
data_args_true=""
geo_args_true=""
date_args_true=""
tri_args_true=""
file_args_true=""

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

#### Création d'un fichier temporaire pour stocker
cp $fichier $fichier_temp

##### Compiler tous les fichier C###
(cd Src && make && echo Compilation fini);

###Fill the arguments
for var in $all_args;
    do
    if [[ $data_args =~ (^|[[:space:]])$var($|[[:space:]]) ]]; then 
    data_args_true+="${var} "
    fi
    if [[ $geo_args =~ (^|[[:space:]])$var($|[[:space:]]) ]]; then 
    geo_args_true+="${var} "
    fi
    if [[ $tri_args =~ (^|[[:space:]])$var($|[[:space:]]) ]]; then 
    tri_args_true+="${var}"
    fi
done

###################CHECK Exclusivity##############

#num_items_geo=`echo ${geo_args_true[@]} | wc -w`
#num_items_tri=`echo ${tri_args_true[@]} | wc -w`

##############################Fonction argument de tri
launch_file() {
  if [ "$1" == "--tab" ]; then
    ./Src/lineaire $2
  elif [ "$1" == ("--avl" || "") ]; then
    ./Src/AVL_der $2
  elif [ "$1" == "--abr" ]; then
    ./Src/BST_tri $2
  else
    echo "Invalid argument. Please use -tab, -avl, or -abr."
  fi
}

#######FILTER PAR LE LIEU####

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
    
    awk -v lat_maxi=$lat_maxi -v lat_mini=$lat_mini -v long_maxi=$long_maxi -v long_mini=$long_mini -F ";" 'NR==1{print $0; next}NR==FNR && FNR>1{split($10,a,",");if((a[1]<lat_maxi  && a[1]>lat_mini) && (a[2]<long_maxi && a[2]>long_mini)){print $0}}' $fichier > $fichier_temp
done

####################### MAIN ##########################
for var in $data_args_true; do
    if [ $var == $temperature1 ]; then
        awk -F ";" 'NR==1{print $1,",Température moyenne",",Temperature maximal",",Température minimal"; next}
        NR==FNR && FNR>1{arr[$1]+=$11;count[$1]+=1;if(max[$1]<$11){max[$1]=$11;};if(!($1 in min) || (min[$1]>0+$11 && ($11 != ""))){min[$1]=0+$11;};} 
        END {for (i in arr) {print i","arr[i]/count[i]","max[i]","min[i]}}' $fichier_temp > tri_"${var:1}".csv
    fi

    #souci sur le minimum toujours
    if [ $var == $pression1 ]; then
        awk -F ";" 'NR==1{print $1,",Pression moyenne",",Pression maximal",",Pression minimal"; next}
        NR==FNR && FNR>1{arr[$1]+=$7;count[$1]+=1;if(max[$1]<$7){max[$1]=$7;};if(!($1 in min) || (min[$1]>0+$7 && ($7 != ""))){min[$1]=0+$7;};} 
        END {for (i in arr) {print i","arr[i]/count[i]","max[i]","min[i]}}' $fichier_temp > tri_"${var:1}".csv
    fi

    if [ $var == $temperature2 ]; then
    awk -F ";" 'NR==1{print $2,",Température moyenne"; next}
        NR==FNR && FNR>1{arr[$2]+=$11;count[$2]+=1;} 
        END {for (i in arr) {print i","arr[i]/count[i]}}' $fichier_temp > tri_"${var:1}".csv
    fi

    if [ $var == $pression2 ]; then
    awk -F ";" 'NR==1{print $2,",Pression moyenne"; next}
        NR==FNR && FNR>1{arr[$2]+=$7;count[$2]+=1;} 
        END {for (i in arr) {print i","arr[i]/count[i]}}' $fichier_temp > tri_"${var:1}".csv
    fi

    if [ $var == $temperature3 ]; then
    awk -F ";" 'NR==1{print $2,$1,$11; next}
        NR==FNR && FNR>1{print $2,$1,$11}' $fichier_temp > tri_"${var:1}".csv
    fi

    if [ $var == $pression3 ]; then
    awk -F ";" 'NR==1{print $2,$1,$7; next}
        NR==FNR && FNR>1{print $2,$1,$7}' $fichier_temp > tri_"${var:1}".csv
    fi


    if [ $var == $altitude ]; then
        awk -F ";" 'NR==1{print $1,",",$14,",Latitude",",Longitude"; next}
        NR==FNR && FNR>1{arr[$1]=$14;split($10,a,",");lat[$1]=a[1];lon[$1]=a[2]} 
        END {for (i in arr) {print i","arr[i]","lat[i]","lon[i]}}' $fichier_temp > tri_"${var:1}".csv
    fi  

    if [ $var == $humidite ]; then
        awk -F ";" 'NR==1{print $1,",Humidité maximal",",Latitude",",Longitude"; next} 
        NR==FNR && FNR>1{if(max[$1]<$6){max[$1]=$6;};split($10,a,",");lat[$1]=a[1];lon[$1]=a[2]} 
        END {for (i in max) {print i","max[i]","lat[i]","lon[i]}}' $fichier_temp > tri_"${var:1}".csv
    fi

    if [ $var == $wind ]; then
        awk -F ";" 'NR==1{print $1,",Direction vent moyenne",",Vitesse vent moyenne",",Latitude",",Longitude"; next}
        NR==FNR && FNR>1{direction[$1]+=$4;count[$1]+=1;vitesse[$1]+=$5;split($10,a,",");lat[$1]=a[1];lon[$1]=a[2]} 
        END {for (i in direction) {print i","direction[i]/count[i]","vitesse[i]/count[i]","lat[i]","lon[i]}}' $fichier_temp > tri_"${var:1}".csv
        
        launch_file() $tri_args_true tri_"${var:1}".csv;


    fi

done

#####Supression du fichier temporaire
#rm -f $fichier_temp