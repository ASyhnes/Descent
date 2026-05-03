# Conception Sonore & Musique

*Musique composée par Johann Scott.*

## Utilisation des Sons et Musiques

### Musiques (Dossier `sound/music/`)
- **`song_1.mp3`** : Jouée sur l'écran titre (`ecran_titre.tscn`) pour installer l'ambiance dès le lancement du jeu.

### Sons d'Ambiance et UI (Dossier `sound/Ambiance/`)
- **`error.mp3`** : 
  - Joué dans le menu `Extra` lorsque le joueur clique sur une tuile verrouillée.
  - Joué sur l'écran titre lors d'une action invalide (ex: tentative de charger une partie sur un emplacement vide).
- **`OK.mp3`** : Joué dans le menu `Extra` lorsque le joueur clique sur une tuile valide/débloquée.
- *Autres sons à définir...*

---

## Planification et Mise en place du projet sonore

### 1. Prévoir un moment avec Johann
Organiser une réunion avec Johann Scott pour réfléchir à la vision globale du projet sonore, l'ambiance musicale des différents niveaux (ex: LevelZero, TemplateLevel) et l'intégration émotionnelle de la musique par rapport au gameplay et à la narration.

### 2. Définir les différents sons
Faire l'inventaire précis et qualifier la liste des bruitages et musiques nécessaires pour le projet complet :
- Bruits de pas (selon la surface)
- Interactions avec les objets (affiches, portes)
- Feedback UI complet (navigation, validation, annulation)
- SFX de l'environnement et des particules (`ColorCloud`)
- Musiques de niveaux et boucles d'ambiance dynamiques
