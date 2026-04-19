Documentation de Conception : Système de Mémoire et d'Interaction (Top-Down RPG)
1. Vue d'Ensemble
Ce système repose sur une mécanique de "mémoire tampon" (buffer) dynamique. Le joueur interagit avec des objets qui s'empilent dans une file d'attente. L'ordre et la nature de ces objets permettent de résoudre des énigmes environnementales (portes à combinaisons).
2. Architecture des Objets (Items)
Tous les objets interactifs du jeu héritent d'une scène parente commune (
BaseItem
).
A. États de l'Objet
Chaque item possède trois états définissant son comportement et son visuel :
ON
 : L'objet est actif. Il apparaît en 
couleur
 dans le monde et 
occupe un slot
 dans la mémoire.
OFF
 : L'objet est inactif. Il apparaît en 
noir et blanc
 et 
n'apparaît pas
 dans la mémoire.
LIGHT
 : L'objet est actif. Il apparaît en 
couleur
 mais 
ne prend pas de place
 dans la mémoire.
B. Propriétés Techniques (Inspecteur Godot)
item_name
 (String) : Nom unique de l'objet.
item_id
 (int) : Identifiant numérique pour la logique des portes.
current_state
 (Enum) : Choix de l'état initial (ON/OFF/LIGHT).
memory_status
 (int) : Valeur de 0 à 5 indiquant sa position actuelle dans la file.
3. Mécanique de Mémoire (Système FIFO)
La mémoire est une file d'attente gérée par un 
MemoryManager
 (Autoload/Singleton).
Capacité
 : Évolutive de 3 à 6 slots durant la progression.
Gestion de la file (First In, First Out)
 :
Un objet ramassé (status ON) occupe le premier slot vide.
Si la mémoire est pleine, le nouvel objet prend la dernière place.
Tous les objets existants sont décalés d'un rang (incrémentation du statut mémoire).
L'objet qui était au rang 0 est éjecté et disparaît de la mémoire.
Interface (UI)
 : Chaque slot mémoire affiche l'icône de l'item correspondant.
4. Système de Portes (Verrouillage Séquentiel)
Les portes agissent comme des validateurs de la mémoire actuelle. Elles héritent d'une scène parente (
BaseDoor
).
A. Configuration dans Godot (Interface Dynamique)
Le Level Designer configure la porte via l'inspecteur :
Nombre d'objets
 : Définit combien d'items sont requis (ex: 3).
Sélection des items
 : Des menus déroulants apparaissent pour chaque slot requis.
Bibliothèque
 : Les menus puisent dans la liste des objets disponibles dans le niveau.
Validation
 : Le système empêche de sélectionner deux fois le même objet pour une même porte.
B. Condition d'Ouverture
La porte compare sa liste d'IDs configurés avec le contenu actuel de la mémoire.
Exemple
 : Si la porte requiert 
[Pomme (ID 1), Poire (ID 2)]
.
Succès
 : La mémoire contient 
ID 1
 au Slot 0 et 
ID 2
 au Slot 1.
Échec
 : L'ordre est inversé ou un des IDs est manquant.
5. Structure de Développement (Godot Engine)
Scène BaseItem
 : 
Area2D
 + 
Sprite2D
. Gère les états visuels.
MemoryManager
 : Script global gérant le tableau (
Array
) des items ON.
HUD
 : Interface affichant les icônes des items en mémoire.
Scène BaseDoor
 : 
StaticBody2D
 + 
Area2D
. Utilise 
_get_property_list()
 pour l'interface de configuration dynamique.
