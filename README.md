# Introduction
Developpement d'un projet de traitement de données météorologiques en Bash avec tri fait par un programme C (Tri via ABR, AVL, ou lineaire).

# Objectif du Projet
L'utilisateur va lancer le programme en donnant le fichier de données en entrée et en spécifiant plusieurs arguments concernant le type de données météorologiques qu'il souhaite visualiser, la localisation, les dates, le type de structure pour trier les données (voir ci-dessous les arguments disponibles)

# Les arguments :
## Type de données météorologiques
Ces options ne sont pas exclusives entre elles. Si on choisit plusieurs types de données, on aura plusieurs graphiques.
- Les options -t et -p doivent être accompagnées d’un mode : 
 -t<mode> : (t)emperatures. 
 -p<mode> : (p)ressions atmosphériques.
- Pour ces 2 options, il faut indiquer la valeur du <mode> :
  - 1 : produit en sortie les températures (ou pressions) minimales, maximales et moyennes par station dans l’ordre croissant du numéro de station.
  - 2 : produit en sortie les températures (ou pressions) moyennes par date/heure, triées dans l’ordre chronologique. La moyenne se fait sur toutes les stations
  
- L’option -w : vent ((w)ind ) produit en sortie l’orientation moyenne et la vitesse moyenne des vents pour chaque station.
- L’option -h : altitude ( (h)eight). Produit en sortie l’altitude pour chaque station. Les altitudes seront triées par ordre décroissant.
- L’option -m : humidité ( (m)oisture ). Produit en sortie l’humidité maximale pour chaque station. Les valeurs d’humidités seront triées par ordre décroissant.

## Option de limitation géographique 
Ces options sont exclusives entre elles. Cela signifie qu’une seule option à la fois peut être activée au maximum. Ces options ne sont pas obligatoires : si aucune n’est activée, il n’y aura alors pas de limitation géographique sur les mesures traitées.

- option -F : (F)rance : France métropolitaine + Corse.
- option -G : (G)uyane française.
- option -S : (S)aint-Pierre et Miquelon : ile située à l’Est du Canada
- option -A : (A)ntilles.
- option -O : (O)céan indien.
- option -Q : antarcti(Q)ue.

## Specifications temporelles
Il est possible d’indiquer un intervalle temporel pour filtrer les données de mesures. Seules les mesures dans l’intervalle de temps seront traitées. Cette option n’est pas obligatoire : il n’y aura alors pas de limitation temporelle sur les mesures traitées. 
- -d <min> <max> : (d)ates
les données de sortie sont dans l’intervalle de dates [<min>..<max>] incluses. Le format des dates est une chaine de type YYYY-MM-DD (année-mois-jour).

## Specifications de tris :
Il est possible d’imposer le mode de tri des données : soit à l’aide d’un tableau (ou liste chaînée), soit à l’aide d’une structure d’arbre binaire, ABR ou AVL.
Si aucune option de tri n’est activée, par défaut le tri se fera à l’aide d’un AVL qui sera la plus efficace.
- --tab : tri effectué à l’aide d’une structure linéaire (au choix un tableau
ou une liste chaînée)
- --abr : tri effectué l’aide d’une structure de type ABR
- --avl : tri effectué à l’aide d’une structure de type AVL

Les arguments et options du script [FICHIER] :
Le nom du fichier d’entrée doit être renseigné pour que le script puisse acquérir toutes les données. Cette option est obligatoire.
- -f <nom_fichier> : (f)ichier d’entrée.


# Exemple de lancement du fichier
Dès que vous avez téléchargé le projet, n'oubliez pas de telecharger le document data.csv et de la rajouter au dossier pour compiler, veuillez penser à compiler ou le dossier data.csv est enregistré (se rendre dans le chemin grâce à la commande "cd") 
 
Avant tout il faut télécharger "gnuplot" sur votre terminal à l'aide des commandes suivantes
```
sudo apt-get update
sudo apt-get install gnuplot
```
Il est aussi nécessaire d'avoir la fonction gawk à jour. Si ce n'est pas le cas, téléchargez-la à l'aide de la commande suivante
```
sudo apt-get install gawk
```
Production des altitudes (-h) & des cartes de vents (-w) en France (-F) sur toute la période
```
./meteo.sh -w -F -f data.csv
```
Production des temperatures moyennes par date (-t2)  aux antilles (-F) entre le 1er Janvier 2015 & le 1er Janvier 2017 en utilisant un tri ABR
```
./meteo.sh -F -f data.csv -t1 --abr -d 2015-01-01 2017-01-01
```
