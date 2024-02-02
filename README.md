# CY-TRUCK

Ce projet a pour but de gérer un fichier `.csv` et de le modifier selon différents traitements qui sont automatisés par un script `.sh`.

## Sommaire

* [Informations générales](#informations-générales)
* [Présentation du projet et ses composants](#présentation-du-projet-et-ses-composants)
* [Guides des commandes](#guides-des-commandes)
* [Technologies](#technologies)
* [Auteurs](#auteurs)


## Informations générales

Une fois le programme lancé, l'utilisateur a le choix entre plusieurs traitements prédéfinis.

L'utilisateur peut ensuite choisir un ou plusieurs traitement par compilation parmi la liste suivante :
 
| Traitement | Objectif | 
|----------|:-------------:|
| TRAITEMENT [D1] | conducteurs avec le plus de trajets : option -d1 | 
| TRAITEMENT [D2] | conducteurs et la plus grande distance: option -d2 | 
| TRAITEMENT [L] | les 10 trajets les plus longs : option -l | 
| TRAITEMENT [T] | les 10 villes les plus traversées : option -t  | 
| TRAITEMENT [S] | statistiques sur les étapes : option -s | 
| BONUS [I] | permet de récupérer les deux dernières commandes passées au terminal |

## Présentation du projet et ses composants

Le projet se compose de cinq dossiers :
| Dossier | Usage | 
|----------|:-------------:|
| data | stocke le fichier `.csv` | 
| demo | stocke les résultats d'opérations précédentes | 
| images | stocke les graphiques propres à chaque traitement  | 
| progc | stocke tous les fichiers relatifs au makefile donc les fichiers de type `.c` `.h` `.o` ainsi que les éxecutables  | 
| temp | stocke les fichiers intermédiaires utiles au bon fonctionnement du traitement |

NB : - le dossier `progc` supporte un sous dossier nécessaire au `makefile` qui est `files.o`
     - les dossiers `temp`et `images` n'existent pas lors du téléchargement puisque les traitements n'ont pas été encore effectués, mais dès la compilation ils se créeront.

## Guides des commandes

A partir du terminal:

* Pour compiler :
     1) Se placer dans le dossier CY-TRUCK grâce à la commande `cd CY-TRUCK`après avoir téléchargé le projet.
     2) Compiler pour la première fois le projet grâce à `./script.sh FICHIER.CSV -h` ->  Cela vous permet de passer en revue tout les traitements possibles du projet.
        (NB : lorsque l'argument vaut `-h` les autres arguments sont automatiquement ignorés) 
     3) Une fois avoir choisi un ou plusieurs traitements veuillez réecrire la ligne précédente : `./script.sh FICHIER.CSV -TRAITEMENTS_CHOISIS`.

 * Pour l'utilisation :
    1) Après avoir compilé et essayer au moins un traitement toujours en tapant dans le terminal `./script.sh FICHIER.CSV -TRAITEMENTS_CHOISIS`, tous les dossiers   
       nécessaires au bon fonctionnement du projet seront crées.
    2) Vous pouvez dès lors appliquer le ou les traitements de votre choix sur le fichier. A noter que les fichiers intermédiaires seront placés dans le dossier temp prévu à        cet effet mais seront supprimés à la fin du traitement.
    3) A la fin de chacun des traitements (hormis le -h et -i) une fenêtre avec les résultats de traitement présentés sous forme de graphique sera automatiquement ouverte.
    4) A chaque nouveau traitement, tous les fichiers relevant du traitement précédent seront supprimés à l'exception des graphiques.
    5)  Le dossier `demo` présente quant à lui les résultats de traitement qui seront utilisés pour les graphique.
       

## Technologies

Ce projet a été réalisé sur le logiciel Visual Studio Code sur MacOS et gedit sur Linux. Le langage utilisé est principalement le shell ainsi que le C.
Les différents fichiers utilisés sont enregistrés sur la plateforme Github et l'addresse de dépôt est : https://github.com/asmakaj/CY-TRUCK

## Auteures

- [@DeulyneDestin](https://github.com/Deulyne)
- [@EmmaDosSantos](https://github.com/emmadsnt)
- [@AsmaKajeiou](https://www.github.com/asmakaj)
