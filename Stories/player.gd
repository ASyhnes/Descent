extends CharacterBody2D

# --- REGLAGES GRILLE ---
var tile_size : int = 16

# Vitesse de déplacement : 80 pixels/sec = 5 carreaux par seconde.
# 1 carreau = 16 pixels
var move_speed : float = 80.0 

# --- ETAT DU JEU ---
var is_moving : bool = false
var target_position : Vector2
var input_direction : Vector2 = Vector2.ZERO
var cardinal_direction : Vector2 = Vector2.DOWN 
var state : String = "idle"

# --- IDLE LONG ---
var idle_timer : float = 0.0
var wait_time : float = 6.0
var is_long_idle : bool = false

# --- REFERENCES ---
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var sprite : Sprite2D = $Sprite2D
@onready var move_ray : RayCast2D = $MovementRay        # Pour marcher
@onready var interact_ray : RayCast2D = $InteractionRay  # Pour interagir

# --- LUMIÈRES ---
@onready var light_base : PointLight2D = $LightBase
@onready var smoke_mask : PointLight2D = $LightMask 
var light_offset : Vector2 = Vector2.ZERO        
var light_velocity_proxy : Vector2 = Vector2.ZERO 
var time_passed : float = 0.0                    
var light_push_factor : float = 0.05  
var light_springiness : float = 15.0  
var light_damping : float = 5.0       

func _ready():
	# Verif joueur démarre pile au centre d'une case
	position = position.snapped(Vector2(tile_size, tile_size))
	target_position = position
	if interact_ray:
		interact_ray.hit_from_inside = true

func _process(delta):
	# 1. LOGIQUE DE DEPLACEMENT ET INTERACTION
	if is_moving:
		AnimMove(delta)
	else:
		CheckInput()
		CheckInteraction()
	
	# 2. PHYSIQUE LUMIERE
	UpdateLighting(delta)
	
	# 3. ANIMATION
	UpdateState()
	UpdateAnimation()
	
	# 4. ORIENTATION DU SPRITE
	if cardinal_direction.x != 0:
		sprite.flip_h = cardinal_direction.x < 0

# ---------------------------------------------------------
# FONCTIONS DE LOGIQUE
# ---------------------------------------------------------

func CheckInput():
	# On écoute les touches directionnelles
	var input_vector = Input.get_vector("left", "right", "up", "down")
	
	if input_vector != Vector2.ZERO:
		
		# --- NOUVEAUTÉ 1 : FERMER LE DIALOGUE SI ON S'ÉLOIGNE ---
		if DialogueManager and DialogueManager.visible:
			DialogueManager.fermer()
			
		# Verrouillage de l'axe (pas de diagonales)
		if abs(input_vector.x) > abs(input_vector.y):
			input_direction = Vector2(sign(input_vector.x), 0)
		else:
			input_direction = Vector2(0, sign(input_vector.y))
			
		cardinal_direction = input_direction
		
		# Un mur est devant ? On utilise le rayon de mouvement !
		move_ray.target_position = input_direction * tile_size
		move_ray.force_raycast_update()
		
		# Reset des timers d'attente
		idle_timer = 0.0
		is_long_idle = false
		
		# Si le chemin est libre
		if not move_ray.is_colliding():
			# On définit la destination finale (la prochaine tuile)
			target_position = position + (input_direction * tile_size)
			# Activation mode mouvement qui interdit de changer d'avis
			is_moving = true
			
	else:
		# On ne touche à rien, on compte le temps pour l'animation d'attente
		idle_timer += get_process_delta_time()
		if idle_timer >= wait_time:
			is_long_idle = true

func CheckInteraction():
	# --- NOUVEAUTÉ 2 : BLOQUER LE RAYCAST SI ON LIT UN TEXTE ---
	# On laisse le DialogueManager gérer la touche Action tout seul !
	if DialogueManager and DialogueManager.visible:
		return 

	# On pointe le rayon d'interaction devant le joueur
	interact_ray.target_position = cardinal_direction * tile_size
	interact_ray.force_raycast_update()
	
	if interact_ray.is_colliding():
		var collider = interact_ray.get_collider()
		
		# Si on appuie sur le bouton d'action
		if Input.is_action_just_pressed("ui_accept"):
			# On vérifie ce qu'on a touché
			if collider is InteractableItem:
				collider.on_player_interact()
			elif collider is SequenceDoor:
				collider.on_interact()
			elif collider is SavePoint:
				collider.on_interact(self)

func AnimMove(delta):
	var step = move_speed * delta
	position = position.move_toward(target_position, step)
	
	# Une fois arrivé pile sur la case
	if position == target_position:
		is_moving = false
		CheckInput() # On revérifie direct pour enchaîner les déplacements sans pause

# ---------------------------------------------------------
# FONCTIONS VISUELLES
# ---------------------------------------------------------

func UpdateLighting(delta):
	time_passed += delta * 15.0 
	
	# Animation du nuage de fumée
	if smoke_mask and smoke_mask.texture and smoke_mask.texture is NoiseTexture2D:
		if smoke_mask.texture.noise:
			smoke_mask.texture.noise.offset.z = time_passed
	
	# Effet élastique de la lumière
	var simulated_velocity = (target_position - position) * 50 
	var target_offset = simulated_velocity * light_push_factor
	var displacement = light_offset - target_offset
	var spring_force = -light_springiness * displacement - light_damping * light_velocity_proxy
	light_velocity_proxy += spring_force * delta
	light_offset += light_velocity_proxy * delta
	
	# Rappel : le sprite est décalé de -8 en x. Permet de faire pareil pour la lumière
	var decalage_visuel = Vector2(-8, 0) 
	
	if light_base: 
		light_base.position = decalage_visuel + light_offset
	if smoke_mask: 
		smoke_mask.position = decalage_visuel + light_offset

func UpdateState():
	if is_moving:
		state = "walk"
	elif is_long_idle:
		state = "idle_long"
	else:
		state = "idle"

func UpdateAnimation():
	var suffix = ""
	if cardinal_direction.y == 1: suffix = "_down"
	elif cardinal_direction.y == -1: suffix = "_up"
	else: suffix = "_side"
	
	var anim_name = ""
	
	if is_moving:
		anim_name = "walk" + suffix
	elif is_long_idle:
		anim_name = "idle" + suffix + "_long"
	else:
		anim_name = "idle" + suffix
	
	if animation_player.has_animation(anim_name):
		animation_player.play(anim_name)
	elif animation_player.has_animation("idle" + suffix):
		animation_player.play("idle" + suffix)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://Scenes/UI/ecran_titre.tscn")
