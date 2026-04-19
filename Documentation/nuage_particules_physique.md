# Physique du Nuage de Particules — `ColorCloud`

> **Fichiers concernés**
> - Scène : `Scenes/Objects/color_cloud.tscn`
> - Script : `Scenes/Objects/color_cloud.gd`
> - Shader comportement : `Assets/Shaders/particle_swarm.gdshader`
> - Shader affichage : `Scenes/Objects/color_cloud.gdshader`

---

## Vue d'ensemble

Le nuage de particules est un système en deux couches :

1. **La dynamique du nuage** — comment l'ensemble du nuage se déplace autour du joueur (géré par `color_cloud.gd`).
2. **La dynamique de chaque particule** — comment chaque point individuel se comporte à l'intérieur du nuage (géré par `particle_swarm.gdshader`).

```
Joueur bouge
    │
    ▼
color_cloud.gd calcule target_pos (position cible du nuage)
    │
    ▼
particle_swarm.gdshader tire chaque particule vers target_pos
    avec un ressort + amortisseur + bruit aléatoire
    │
    ▼
Rendu dans un SubViewport → appliqué comme masque de couleur
```

---

## 1. La Scène (`color_cloud.tscn`)

### Structure des nœuds

```
ColorCloud (Node2D)          ← Racine, porte le script color_cloud.gd
├── BackBufferCopy           ← Copie le framebuffer pour le shader couleur
├── BW_Layer (CanvasLayer)   ← Calque qui affiche le monde en noir & blanc
│   └── ColorRect            ← Rectangle plein écran avec le shader N&B
├── MaskViewport (SubViewport) ← Viewport isolé où les particules sont rendues
│   ├── GPUParticles2D       ← Système de particules (600 particules max)
│   └── CoreMask (Sprite2D)  ← Copie du sprite du joueur (zone toujours en couleur)
└── PerceptionArea (Area2D)  ← Zone physique qui suit le nuage (détection des objets)
    └── CollisionShape2D     ← Cercle de rayon 45 px
```

### Rôle de chaque nœud

| Nœud | Rôle |
|---|---|
| `BW_Layer / ColorRect` | Applique un shader qui passe tout l'écran en noir & blanc, **sauf** là où le masque de particules est blanc |
| `MaskViewport` | Espace de rendu séparé où seul le nuage est dessiné — sa texture est ensuite envoyée au shader N&B comme masque |
| `GPUParticles2D` | Émet les particules, utilise `particle_swarm.gdshader` pour leur mouvement |
| `CoreMask` | Recopie frame par frame le sprite du joueur, garantissant que le personnage lui-même est toujours en couleur (même quand le nuage se déplace) |
| `PerceptionArea` | Zone circulaire physique qui se déplace avec le nuage visuel — c'est elle que les `InteractableItem` détectent pour s'allumer |

---

## 2. Le Script (`color_cloud.gd`)

Le script calcule chaque frame la **position cible** (`target_pos`) du nuage, puis l'envoie au shader.

### Variables exportées (ajustables dans l'inspecteur)

```gdscript
@export var anticipation_factor: float = 0.5
@export var intent_push_force:   float = 40.0
@export var max_stretch:         float = 45.0
```

### Étapes de calcul (`_process`)

#### Étape 1 — Vitesse réelle du joueur

```gdscript
var actual_velocity = (current_pos - last_target_pos) / delta
smoothed_velocity = smoothed_velocity.lerp(actual_velocity, 5.0 * delta)
```

- On calcule la vitesse en pixels/seconde.
- On la **lisse** avec un `lerp` (coefficient `5.0`) pour éviter les sauts brutaux.
- Plus ce coefficient est **bas** → mouvement plus paresseux/inertiel.
- Plus il est **haut** → le nuage réagit quasi instantanément.

#### Étape 2 — Intention directionnelle

```gdscript
var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
smoothed_input = smoothed_input.lerp(input_dir, 15.0 * delta)
```

- On récupère la direction du joystick/clavier **même si le joueur est bloqué par un mur**.
- Cela crée une « intention » : le nuage se penche dans la direction voulue, pas seulement dans la direction réelle.
- Coefficient `15.0` → l'intention est très réactive (3× plus que la vitesse).

#### Étape 3 — Calcul de l'étirement total

```gdscript
var total_stretch = (smoothed_velocity * anticipation_factor)
                  + (smoothed_input   * intent_push_force)
total_stretch = total_stretch.limit_length(max_stretch)
```

- Les deux forces sont additionnées.
- `limit_length(max_stretch)` empêche le nuage de s'éloigner trop du joueur.
- La `target_pos` finale est envoyée au shader via `set_shader_parameter("target_pos", target_pos)`.

#### Étape 4 — Mise à jour des nœuds

```gdscript
perception_area.global_position = target_pos  # La zone physique suit le nuage
particles.global_position = current_pos        # Les particules restent sur le joueur
core_mask.global_position = player_sprite.global_position  # Masque du sprite
```

---

## 3. Le Shader de particules (`particle_swarm.gdshader`)

C'est le cœur de la physique individuelle de chaque particule.

### Fonction `start()` — Naissance d'une particule

Quand une particule (re)naît, elle est placée **aléatoirement dans un cercle** autour de `target_pos` :

```glsl
float angle  = rand(...) * 2.0 * PI;
float radius = sqrt(rand(...)) * cloud_spread;
TRANSFORM[3].xy = target_pos + vec2(cos(angle), sin(angle)) * radius;
```

> `sqrt()` sur le rayon aléatoire garantit une **distribution uniforme** dans le disque (sans `sqrt`, les particules se concentreraient au centre).

### Fonction `process()` — Physique chaque frame

La physique appliquée est celle d'un **ressort amorti + bruit** :

#### Force de ressort (attraction vers la cible)

```glsl
vec2 displacement  = TRANSFORM[3].xy - target_pos;
vec2 spring_force  = (-springiness * displacement) - (damping * VELOCITY.xy);
```

- `displacement` = distance entre la particule et la cible.
- `-springiness * displacement` → force qui ramène la particule vers le centre (loi de Hooke).
- `-damping * VELOCITY` → frein proportionnel à la vitesse (amortisseur).

| Valeur | Effet si on augmente | Effet si on diminue |
|---|---|---|
| `springiness` | Particules très nerveuses, oscillent vite | Particules molles, lentes à revenir |
| `damping` | Particules freinent fort, peu d'oscillations | Particules rebondissent longtemps |

#### Bruit aléatoire (frétillement)

```glsl
float noise_x = (rand(vec2(NUMBER, TIME)) - 0.5) * randomness;
float noise_y = (rand(vec2(TIME, NUMBER)) - 0.5) * randomness;
VELOCITY.xy += (spring_force + chaos) * DELTA;
```

- Chaque particule a un numéro unique (`NUMBER`) → bruit différent pour chacune.
- `TIME` change chaque frame → le bruit change aussi chaque frame.
- `randomness` contrôle l'intensité de ce frétillement.

#### Transparence (fade par distance)

```glsl
float alpha = 1.0 - clamp(current_distance / fade_distance, 0.0, 1.0);
COLOR.a = alpha;
```

- Plus une particule est loin du centre, plus elle devient transparente.
- À `fade_distance` pixels du centre → complètement invisible.

---

## 4. Référence rapide — Tous les paramètres réglables

### Dans l'Inspecteur Godot (nœud `ColorCloud`)

| Paramètre | Valeur par défaut | Effet |
|---|---|---|
| `anticipation_factor` | `0.5` | Poids de la vitesse réelle sur le déplacement du nuage |
| `intent_push_force` | `40.0` | Force de poussée liée aux touches directionnelles |
| `max_stretch` | `45.0` | Distance maximale (px) entre le joueur et le centre du nuage |

### Dans l'Inspecteur Godot (nœud `GPUParticles2D`)

| Paramètre | Valeur par défaut | Effet |
|---|---|---|
| `amount` | `600` | Nombre total de particules |
| `amount_ratio` | `0.65` | Proportion de particules actives |
| `lifetime` | `0.45` s | Durée de vie avant qu'une particule renaisse |
| `speed_scale` | `0.85` | Vitesse globale de simulation (multiplicateur) |
| `explosiveness` | `0.14` | 0 = émission continue, 1 = toutes en même temps |
| `randomness` | `0.55` | Aléatoire dans le timing d'émission |

### Via `shader_parameter` (shader `particle_swarm.gdshader`)

| Paramètre | Valeur par défaut | Effet |
|---|---|---|
| `springiness` | `20.0` | Raideur du ressort (réactivité des particules) |
| `damping` | `1.0` | Amortissement (frein sur les oscillations) |
| `randomness` | `1000.0` | Intensité du frétillement aléatoire |
| `cloud_spread` | `25.0` | Rayon (px) de la zone d'apparition des particules |
| `particle_scale` | `0.1` | Taille visuelle de chaque particule |
| `fade_distance` | `10.0` | Distance (px) au-delà de laquelle les particules disparaissent |

---

## 5. Recettes — Ajustements courants

### Nuage plus calme / moins nerveux
```
color_cloud.gd :
  anticipation_factor : 0.5 → 0.2
  intent_push_force   : 40  → 15
  lerp vitesse (ligne 53) : 5.0 → 2.0

particle_swarm.gdshader :
  springiness : 20 → 8
  damping     : 1  → 3
  randomness  : 1000 → 300
```

### Nuage plus grand / plus étalé
```
particle_swarm.gdshader :
  cloud_spread   : 25 → 60
  fade_distance  : 10 → 30

GPUParticles2D :
  amount : 600 → 800
```

### Nuage qui réagit uniquement au mouvement réel (pas aux intentions)
```
color_cloud.gd :
  intent_push_force : 40 → 0
```
