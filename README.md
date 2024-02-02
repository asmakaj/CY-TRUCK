# CY-TRUCK

Ce projet a pour but de gérer un fichier `.csv` et de le modifier selon différents traitements qui sont automatisés par un script `.sh`.

## Sommaire

* [Informations générales](#informations-générales)
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

## Guides des commandes

A partir du terminal:

* Pour compiler :
     1) Se placer dans le dossier CY-TRUCK grâce à la commande `cd CY-TRUCK`après avoir téléchargé le projet.
     2) Compiler le projet grâce à `./script.sh FICHIER.CSV -h` ->  Cela vous permet de passer en revue tout les traitements possibles du projet.
        (NB : lorsque l'argument vaut `-h` les autres arguments sont automatiquement ignorés) 
     3) Une fois avoir choisi un ou plusieurs traitements veuillez réecrire la ligne précédente : `./script.sh FICHIER.CSV -TRAITEMENTS_CHOISIS`.
     

## Technologies

Ce projet a été réalisé sur le logiciel Visual Studio Code sur MacOS et gedit sur Linux. Le langage utilisé est principalement le shell ainsi que le C.
Les différents fichiers utilisés sont enregistrés sur la plateforme Github et l'addresse de dépôt est : https://github.com/asmakaj/CY-TRUCK

## Auteures

- [@DeulyneDestin](https://github.com/Deulyne)
- [@EmmaDosSantos](https://github.com/emmadsnt)
- [@AsmaKajeiou](https://www.github.com/asmakaj)
