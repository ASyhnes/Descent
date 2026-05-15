# Conception Sonore & Musique

*Musique composée par Johann Scott.*

## Inspirations
La direction musicale s'inspire de textures sombres et enveloppantes, avec une ambiance à la fois introspective, cinématographique et légèrement mystérieuse. L'objectif est de soutenir l'exploration, la tension et la narration sans prendre le dessus sur l'expérience de jeu.

### - **Référence d'inspiration** : 
_ - **`Gui borato chromophobia`** : [Open Spotify Track](https://open.spotify.com/intl-fr/track/435zKMtKQsLt5rJ3lHwWBQ?si=306e82d2e49648ea)

## Utilisation des Sons et Musiques

### Musiques (Dossier `sound/music/`)
- **`song_1.mp3`** : Jouée sur l'écran titre (`ecran_titre.tscn`) pour installer l'ambiance dès le lancement du jeu.
  <audio controls src="../sound/music/song_1.mp3"></audio>

### Sons d'Ambiance et UI (Dossier `sound/Ambiance/`)
- **`error.mp3`** : 
  - Joué dans le menu `Extra` lorsque le joueur clique sur une tuile verrouillée.
  - Joué sur l'écran titre lors d'une action invalide (ex: tentative de charger une partie sur un emplacement vide).
  <audio controls src="../sound/Ambiance/error.mp3"></audio>
- **`OK.mp3`** : Joué dans le menu `Extra` lorsque le joueur clique sur une tuile valide/débloquée.
  <audio controls src="../sound/Ambiance/OK.mp3"></audio>

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
