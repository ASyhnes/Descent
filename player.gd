extends CharacterBody2D

# --- REGLAGES GRILLE ---
var tile_size : int = 16

# Vitesse de déplacement : 80 pixels/sec = 5 carreaux par seconde.
#1 carreau = 16 pixels
# Plus c'est haut, plus il marche vite.
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
@onready var ray : RayCast2D = $RayCast2D 

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

func _process(delta):
	# 1. LOGIQUE DE DEPLACEMENT STRICT
	if is_moving:
		AnimMove(delta)
	else:
		CheckInput()
	
	# 2. PHYSIQUE LUMIERE
	time_passed += delta * 15.0 
	if smoke_mask and smoke_mask.texture and smoke_mask.texture is NoiseTexture2D:
		if smoke_mask.texture.noise:
			smoke_mask.texture.noise.offset.z = time_passed
	
	var simulated_velocity = (target_position - position) * 50 
	var target_offset = simulated_velocity * light_push_factor
	var displacement = light_offset - target_offset
	var spring_force = -light_springiness * displacement - light_damping * light_velocity_proxy
	light_velocity_proxy += spring_force * delta
	light_offset += light_velocity_proxy * delta
	
	var decalage_visuel = Vector2(-8, 0) # rappel: le sprite est décaller de -8 en x. permet de faire pareil pour la lumiére
	
	if light_base: 
		light_base.position = decalage_visuel + light_offset
	if smoke_mask: 
		smoke_mask.position = decalage_visuel + light_offset
	
	# 3. ANIMATION
	UpdateState()
	UpdateAnimation()
	
	if cardinal_direction.x != 0:
		sprite.flip_h = cardinal_direction.x < 0

func CheckInput():
	# On écoute les touches
	var input_vector = Input.get_vector("left", "right", "up", "down")
	
	if input_vector != Vector2.ZERO:
		# Verouillagede l'axe (pas de diagonales)
		if abs(input_vector.x) > abs(input_vector.y):
			input_direction = Vector2(sign(input_vector.x), 0)
		else:
			input_direction = Vector2(0, sign(input_vector.y))
			
		cardinal_direction = input_direction
		
		# mur est devant?
		ray.target_position = input_direction * tile_size
		ray.force_raycast_update()
		
		# Reset des timers d'attente
		idle_timer = 0.0
		is_long_idle = false
		
		if not ray.is_colliding():
			# On définit la destination finale (la prochaine tuile)
			target_position = position + (input_direction * tile_size)
			# Activation mode mouvement qui interdit de changer d'avis
			is_moving = true
			
	else:
		idle_timer += get_process_delta_time()
		if idle_timer >= wait_time:
			is_long_idle = true

func AnimMove(delta):
	# On avance vers la cible d'un pas calculé selon le temps (delta)
	# Pour vitesse une vitesse constante quel que soit l'ordi
	var step = move_speed * delta
	
	position = position.move_toward(target_position, step)
	
	# Une fois arrivé pile sur la case
	if position == target_position:
		is_moving = false
		# Relance CheckInput tout de suite pour permettre
		# le mouvement continu si la touche est restée appuyée
		CheckInput()

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
