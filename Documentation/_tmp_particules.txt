DOCUMENT SOURCE : Projet Godot - Système de Particules, UI et Collisions
1. SYSTÈME DE NUAGE DE PARTICULES (CHAMP DE VISION)
Objectif du système :
 Créer un effet visuel ("Color Cloud" ou Champ de vision) géré par un Shader, qui suit le personnage de manière fluide (avec inertie), réagit aux mouvements, et s'écrase de façon réaliste contre les murs du décor.
Concepts clés de la physique du nuage :
Delta Time (
delta
) :
 Utilisé pour calculer la vitesse réelle du joueur (
Vitesse = Distance / delta
). Cela permet au nuage de réagir intelligemment aux collisions réelles du joueur (ex: s'il est poussé ou bloqué).
Combinaison de forces :
 Le nuage est tiré par deux forces : la vélocité réelle (vitesse de déplacement) et l'intention (la touche pressée sur le clavier, via 
smoothed_input
). Cela permet au nuage de "pousser" visuellement dans une direction même si le joueur court contre un mur.
La Laisse (
limit_length
) :
 La distance maximale entre le joueur et le centre du nuage est bornée par 
limit_length(max_stretch)
. Cela empêche le nuage de s'étirer à l'infini.
Le Raycasting (Anti-traversée des murs) :
Pour empêcher le nuage visuel de traverser les murs, un rayon physique (
PhysicsRayQueryParameters2D
) est lancé entre le joueur et la cible du nuage.
Si le rayon percute un obstacle (mur), la position cible finale du nuage (
final_target_pos
) est bloquée sur le point d'impact.
Le paramètre 
cloud_spread
 (rayon d'étalement des particules) est réduit dynamiquement via un 
clamp()
 en fonction de la distance au mur, donnant l'impression que le nuage "s'écrase" contre la paroi.
Script consolidé de la gestion du nuage (
_process
) :
GDScript
# Calcul de la vitesse et de la cible
var actual_velocity = (current_pos - last_target_pos) / delta
last_target_pos = current_pos 
smoothed_velocity = smoothed_velocity.lerp(actual_velocity, 5.0 * delta)
var target_pos = current_pos + base_offset
var total_stretch = (smoothed_velocity * anticipation_factor) + (smoothed_input * intent_push_force)
total_stretch = total_stretch.limit_length(max_stretch)
target_pos += total_stretch
# Détection des murs (Raycast)
var space_state = get_world_2d().direct_space_state
var query = PhysicsRayQueryParameters2D.create(current_pos, target_pos)
if target is CollisionObject2D:
query.exclude = [target.get_rid()]
var hit_result = space_state.intersect_ray(query)
var final_target_pos = target_pos
var current_spread = 60.0 
if hit_result:
final_target_pos = hit_result.position
var distance_au_mur = current_pos.distance_to(hit_result.position)
current_spread = clamp(distance_au_mur * 0.8, 15.0, 60.0) 
# Envoi des données au Shader (GPU)
if particles and particles.process_material is ShaderMaterial:
particles.process_material.set_shader_parameter("target_pos", final_target_pos)
particles.process_material.set_shader_parameter("cloud_spread", current_spread)
var fake_velocity_for_cone = smoothed_velocity + (smoothed_input * 200.0)
particles.process_material.set_shader_parameter("player_velocity", fake_velocity_for_cone)
2. SYNCHRONISATION DU MASQUE VISUEL (CLONAGE)
Pour que les effets de particules (SubViewport) interagissent avec le sprite du joueur, il faut un "clone" parfait de l'animation du joueur en temps réel.
Le script récupère la 
texture
, les 
hframes
/
vframes
, la 
frame
 actuelle, et les propriétés de miroir (
flip_h
) du 
Sprite2D
 du joueur pour les appliquer au 
core_mask
.
Les Viewports sont également synchronisés (
size
 et 
canvas_transform
) pour que les caméras correspondent parfaitement.
3. DÉBOGAGE PHYSIQUE : RÈGLES DE COLLISION ET INTERACTIONS
Lors de la mise en place de zones d'interaction (comme des boîtes de dialogue avec des affiches via 
Area2D
), plusieurs règles strictes s'appliquent dans Godot.
Le Syndrome du "Joueur Fantôme" (Warning Triangle)
Problème :
 Une 
Area2D
 utilisant le signal 
body_entered
 ne détecte pas le joueur, bien que les calques (Layers/Masks) soient corrects.
Cause :
 Le nœud 
CharacterBody2D
 du joueur n'a pas de 
CollisionShape2D
 enfant (indiqué par un triangle jaune d'avertissement dans l'arbre de scène).
Règle absolue :
 Un corps physique sans forme de collision (Shape) n'a pas de volume pour le moteur physique. Il est impossible à détecter pour une Area2D.
Layers et Masks
Layer :
 Détermine sur quel calque de collision l'objet existe.
Mask :
 Détermine quels calques de collision l'objet est capable de détecter (scanner).
Pour qu'une Affiche (Area) détecte un Joueur, le 
Mask
 de l'affiche doit cocher le même numéro que le 
Layer
 du joueur.
4. DÉBOGAGE DE L'INTERFACE UTILISATEUR (UI)
Hiérarchie et Z-Index (Éléments cachés)
Problème :
 L'UI (boîte de dialogue) est cachée par les effets de particules plein écran.
Solution :
 Placer les éléments d'interface à l'intérieur d'un nœud 
CanvasLayer
. En augmentant la propriété 
Layer
 du CanvasLayer (ex: 100), Godot dessinera toujours l'interface par-dessus le reste du jeu, indépendamment de sa position dans l'arbre de scène.
Problème de texte de Bouton tronqué
Problème :
 Le texte d'un bouton est coupé aux extrémités lorsqu'il est sélectionné (Focus) ou survolé (Hover).
Cause :
 Le style 
Focus
 ou 
Hover
 par défaut de Godot (le fond gris) possède des marges internes (padding). L'ajout de ces marges pousse le texte en dehors de la boîte de contrôle si celle-ci est trop petite.
Solution :
Agrandir la taille physique du composant bouton dans la vue 2D.
Ou
 aller dans 
Theme Overrides > Styles
, et remplacer les styles 
Focus
 et 
Hover
 par un 
New StyleBoxEmpty
 pour supprimer le fond gris et ses marges. (Utiliser 
Theme Overrides > Colors > Font Focus Color
 pour indiquer visuellement la sélection au joueur).
