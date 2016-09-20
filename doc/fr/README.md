# MagiCd, rend vos cd magiques !

MagiCd est un ensemble de scripts bash utilisés pour améliorer la commande shell `cd`. L'objectif est d'identifier des répertoires particuliers et d'exécuter des actions spécifiques en y entrant ou en les quittant.

# Langue

Le français étant ma langue maternelle, fournir les documents et messages en français n'est pas une option. Les autres traductions sont bienvenues.

Cependant, l'anglais étant la langue de la programmation, le code, y compris les noms de variable et commentaires, sont en anglais.

# Licence

Copyright © 2016 Stéphane Veyret stephane_POINT_veyret_CHEZ_neptura_POINT_org

MagiCd est un outil libre ; vous pouvez le redistribuer ou le modifier suivant les termes de la GNU General Public License telle que publiée par la Free Software Foundation ; soit la version 3 de la licence, soit (à votre gré) toute version ultérieure.

MagiCd est distribué dans l'espoir qu'il sera utile, mais SANS AUCUNE GARANTIE ; pas même la garantie implicite de COMMERCIALISABILITÉ ni d'ADÉQUATION à UN OBJECTIF PARTICULIER. Consultez la GNU General Public License pour plus de détails.

Vous devez avoir reçu une copie de la GNU General Public License en même temps que MagiCd ; si ce n'est pas le cas, consultez http://www.gnu.org/licenses.

# Installation

La compilation et l'installation sont effectuées simplement par :

    make && make install

Notez que `make install` supporte également la variable `DESTDIR` pour installer ailleurs qu'au niveau de la racine du système.

# Mode d'emploi

L'installation automatique de MagiCd ajoute des alias sur les commandes `cd` et `clean`. Lorsque vous entrez dans un répertoire particulier avec la commande `cd`, les actions correspondantes s'exécutent. La commande `clean` peut être utilisée dans certain cas pour nettoyer un répertoire. Cette commande attend les même paramètres que `cd`.

Pour identifier un répertoire particulier, vous devez y mettre un fichier `.magicd-`_catégorie_, où _catégorie_ identifie le type de répertoire. Les différentes catégories existantes dépendent des scripts ajoutés dans les répertoires de paramétrage. Le fichier ajouté peut éventuellement contenir des paramètres. Les paramètres utilisables dépendent de la catégorie.

Il est toujours possible d'utiliser la commande `\cd` pour entrer dans le répertoire sans exécuter les actions magiques.

# Catégories livrées

## EnVar

Un répertoire de type `envar` est identifié par un fichier `.magicd-envar`. Ce fichier contient des paires de clé/valeur qui seront utilisées pour positionner des variables d'environnement dans le répertoire concerné.

### Entrée

À l'entrée du répertoire, les paramètres positionnées dans le fichier de configuration sont exportées comme variables d'environnement.

### Sortie

À la sortie du répertoire, l'environnement est restauré tel qu'il était lors de l'entrée.

### Nettoyage

La commande de nettoyage est sans effet sur un répertoire EnVar.

### Paramètres

Chaque paramètre du fichier `.magicd-envar` est utilisé pour positionner les variables d'environnement.

## Docker

Un répertoire de type `docker` contient un fichier `.magicd-docker`. Il est automatiquement monté dans le répertoire `/root` d'un conteneur Docker.

### Entrée

S'il n'existe pas de conteneur dont le nom est le nom du répertoire, un nouveau est créé. Si ce conteneur existe, il est démarré. Au lieu d'entrer sur le répertoire, on se retrouve donc directement dans le conteneur Docker.

### Sortie

La sortie du répertoire est automatique lorsque l'on sort du conteneur Docker. La sortie n'occasionne aucune action particulière.

### Nettoyage

Le nettoyage du répertoire supprime le conteneur, ainsi que les images et les volumes qui ne sont plus utilisés.

### Paramètres

Les options suivantes peuvent être ajoutées dans le fichier `.magicd-docker` :

* IMAGE=_image docker_, avec l'image Docker à utiliser, par défaut `gentoo/stage3-amd64` ;
* OPTIONS=_options_, avec les options à utiliser, par défaut `--volumes-from portage` ;
* CMD=_commande de démarrage_, avec la commande à exécuter au démarrage du conteneur, par défaut `/bin/bash`.

# Définition des catégories

Les catégories de répertoire vont être recherchées dans :

* le sous-répertoire `magicd.d` du répertoire où se trouve le script principal de MagiCd, en général réservé aux catégories livrées avec le produit ;
* le sous-répertoire `magicd.d` du répertoire de configuration, identifié par la variable d'environnement `$MAGICD_CONF`, qui pointe par défaut sur `/etc`, utilisé pour les catégories globales à l'ordinateur ;
* le sous-répertoire `.magicd.d` du répertoire de l'utilisateur `$HOME`, pour les catégories privées de l'utilisateur.

Ces 3 répertoires sont donnés par ordre de priorité croissante, le répertoire utilisateur surchargeant donc les deux autres, tandis que les catégories livrées avec le produit sont les moins prioritaires.

# Écrire un fichier de catégorie

Un fichier de catégorie doit être trouvé dans l'un des répertoires de définition des catégories et avoir comme nom le nom de la catégorie. Il peut contenir 3 fonctions :

* `magicd_enter` contient les actions à exécuter à l'entrée du répertoire ;
* `magicd_leave` contient les actions à exécuter à la sortie du répertoire ;
* `magicd_clean` contient les actions à exécuter pour nettoyer le répertoire.

Les commandes `cd` et `clean` étant potentiellement des alias sur MagiCd, il est interdit de les utiliser directement dans les scripts de catégories, pour éviter d'entrer dans une boucle infinie. Si vous avez besoin de changer de répertoire, utilisez la commande `command cd` qui ne tiendra pas compte de l'alias.

Le fichier de catégorie est sourcé par MagiCd. Il n'a donc pas besoin d'avoir les droits d'exécution ; les droits de lecture sont toutefois nécessaires. Par contre, afin de ne pas « polluer » l'environnement, l'exécution des fonctions se fait dans une sous-procédure. Les actions n'auront donc pas d'impact dans l'environnement courant.

Si toutefois il est nécessaire de modifier l'environnement courant (ajout de variables d'environnement, changement de répertoire, etc.), les instructions doivent être écrites dans de descripteur de fichier n°3. Tout ce qui est écrit dans ce descripteur terminera dans un fichier temporaire qui sera sourcé par MagiCd.

Exemple 1 - Modification du répertoire courant :

    magicd_leave() {
        echo 'command cd ..' >&3
    }

Exemple 2 - Ajout de variables d'environnement :

    magicd_enter() {
        cat <<EOF >&3
    export NEW_HOME=\${PWD}
    export MY_VAR_SET="true"
		EOF
    }
