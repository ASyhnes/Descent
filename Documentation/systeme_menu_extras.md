# Documentation Technique : Système de Menu Extras (Galerie)

Ce document explique le fonctionnement du système de "Menu Extras" (la galerie d'images et de textes historiques / annexes) ajouté au projet.

## 1. Architecture Générale
Le système repose sur des **Ressources** Godot (fichiers `.tres`), ce qui permet d'ajouter très facilement un nouvel "Extra" depuis l'inspecteur sans écrire une ligne de code, et de bénéficier d'une UI qui s'adapte automatiquement.

L'ensemble des fichiers est localisé dans `res://Extra/`.

### Fichiers de Scènes (UI)
- **`ExtraMenu.tscn`** : La scène racine de la galerie. Elle génère dynamiquement des tuiles en lisant une liste de ressources (définie dans l'inspecteur du noeud `ExtraMenu`).
- **`ExtraTile.tscn`** : La tuile cliquable (miniature, titre, et icône de cadenas 🔒 si non débloquée).
- **`ExtraDetailsPage.tscn`** : L'interface plein écran de lecture d'une tuile spécifique. Elle lit le texte contextuel et instancie dynamiquement les blocs de contenu (textes/images) sans limite de quantité. Cette page est navigable au clavier/manette (les flèches haut/bas contrôlent le défilement du scroll).

### Fichiers de Scripts (Données)
Les fichiers de scripts sont déclarés globalement grâce au mot clé `class_name` pour facilement les créer depuis l'inspecteur.
- **`ExtraData.gd`** (Hérite de `Resource`) : La carte d'identité globale d'un Extra.
- **`ExtraContentBlock.gd`** (Hérite de `Resource`) : Un sous-élément de l'Extra, qui peut être déclaré comme type `TEXT` ou type `IMAGE`.

---

## 2. Comment créer et ajouter un nouvel Extra ?

### Étape A : Créer le fichier .tres
1. Dans l'explorateur de fichiers de Godot, faites `Clic-Droit` > `Créer Nouveau` > `Ressource`.
2. Cherchez `ExtraData` et validez. 
3. Donnez-lui un nom clair (ex: `concept_personnage.tres`) et placez-le dans `res://Extra/`.

### Étape B : Configurer la Ressource globale
Sélectionnez le fichier `.tres` nouvellement créé. Dans l'inspecteur à droite :
- **Title** : Le titre abrégé qui s'affichera sur la tuile et en titre au dessus de la page de détails.
- **Thumbnail** : L'image de la tuile (à glisser-déposer).
- **Context Text** : Une rapide description affichée en tête de l'article de détail.
- **Is Unlocked** : Cochez la case pour rendre l'Extra lisible (sinon, il apparaîtra bloqué par un cadenas et sera incliquable en jeu, utile pour l'avancée de l'histoire).

### Étape C : Ajouter des Blocs de texte / images
1. Allez sur **Content Blocks** dans l'inspecteur de la ressource. C'est un `Array` (tableau).
2. Augmentez la taille (Size) selon le nombre de paragraphes ou d'images que vous souhaitez pour cette page.
3. Pour chaque case du tableau, créez un nouveau sous-élément en choisissant le type **`ExtraContentBlock`**.
4. Cliquez dessus pour le dérouler :
   - Choisissez le **Type** : `TEXT` ou `IMAGE`.
   - Si `TEXT`, écrivez votre contenu dans le champ **Text Content**.
   - Si `IMAGE`, glissez votre texture dans le champ **Image Content**.

### Étape D : Ajouter la ressource à l'UI
Pour que votre nouvel Extra apparaisse dans le jeu :
1. Ouvrez `ExtraMenu.tscn`.
2. Cliquez sur le noeud racine `ExtraMenu`.
3. Dans l'inspecteur de droite, sous "Extra Menu", vous verrez la variable `Extra Resources` qui est un Array.
4. Augmentez sa taille de 1 et glissez l'élément `.tres` que vous venez de créer dans la nouvelle ligne (ou ajoutez le directement par glisser-déposer depuis l'explorateur). 

C'est tout ! Au prochain lancement du jeu, la tuile va s'afficher d'elle-même !

---

## 3. Comment débloquer un Extra depuis le jeu ?

Par défaut, si l'Extra est marqué avec `Is Unlocked = false`, il sera grisé dans le menu. Pour le débloquer lors d'un événement du jeu (par exemple, en lisant une affiche), le système utilise un **Autoload** appelé `ExtraManager`.

### Étape A : Configurer l'ID de l'Extra
1. Dans la ressource `.tres` de votre Extra, donnez-lui un identifiant unique en minuscules et sans espaces dans le champ **`Extra Id`** (ex: `mycelium`).
2. Assurez-vous que **`Is Unlocked`** est décoché (sinon il est toujours débloqué).

### Étape B : Lier l'Extra à un objet interactif
Actuellement, les **Affiches Interactibles** (`AfficheInteractible` - `interaction_affiche.gd`) supportent ce mécanisme :
1. Sélectionnez le nœud de l'affiche dans votre scène (ex: `Affiches/Micelium`).
2. Dans l'inspecteur, cherchez le champ **`Extra Id A Debloquer`**.
3. Tapez exactement l'ID configuré plus tôt (ex: `mycelium`).

Lorsque le joueur aura lu toutes les pages de l'affiche, l'extra sera débloqué en mémoire, et une petite notification visuelle ("Extra Mycélium débloqué") apparaîtra en bas de l'écran.

### Étape C : Persistance de la sauvegarde
L'état des extras débloqués est **automatiquement inclus dans la sauvegarde globale du jeu**. 
Lorsque le joueur va ensuite utiliser un Point de Sauvegarde, le déblocage de l'extra sera écrit dans le fichier `slot_X.save`. Au prochain lancement du jeu, l'`ExtraManager` récupérera cette information pour que l'Extra soit toujours accessible dans le menu.
