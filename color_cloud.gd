extends Node2D

@export var target_path: NodePath
@onready var target: Node2D = get_node_or_null(target_path)

@export var anticipation_factor: float = 0.5 
@export var intent_push_force: float = 40.0 

# effet elastick (calcul en pixel)
@export var max_stretch: float = 45.0 

@onready var bw_rect = $BW_Layer/ColorRect
@onready var mask_viewport = $MaskViewport
@onready var particles = $MaskViewport/GPUParticles2D
@onready var core_mask = $MaskViewport/CoreMask 

var base_offset: Vector2 = Vector2(-8, 0) 
var last_target_pos: Vector2 = Vector2.ZERO
var smoothed_velocity: Vector2 = Vector2.ZERO
var smoothed_input: Vector2 = Vector2.ZERO 

func _ready():
	if target:
		last_target_pos = target.global_position
		
	mask_viewport.size = get_viewport().get_visible_rect().size
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	bw_rect.material.set_shader_parameter("mask_texture", mask_viewport.get_texture())

func _process(delta: float) -> void:
	if not target:
		return
		
	var current_pos = target.global_position
	
	# 1. calcule de la velocité: delta> temps entre pluisuer image. 
	# comment ça marche: je calcul la vitesse du joueur,
	# puis on mémorise la position actuel pour la frame suivante
	var actual_velocity = (current_pos - last_target_pos) / delta
	last_target_pos = current_pos 
	# "Lissage" de la vitesse (avec la fonction Lerp) : Lerp permet de passer de la vitesse max à la vitesse zero 
	# sans arret net (permet de creer un effet elastique)
	smoothed_velocity = smoothed_velocity.lerp(actual_velocity, 5.0 * delta)
	
	# 2. L'intention de direction: permet de faire en sorte que si le joueur push une direction
	# même si il y a un mur, que le joueur est à l'arret, cela fait une direction. 
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	smoothed_input = smoothed_input.lerp(input_dir, 15.0 * delta)
	
	# 3. addition des deux forces: la force de velocité et la force d'intention
	# pour eviter que le nuage parte trop loin
	var target_pos = current_pos + base_offset
	
	# On calcule l'étirement total (vitesse + clavier)
	var total_stretch = (smoothed_velocity * anticipation_factor) + (smoothed_input * intent_push_force)
	
	# permet de limiter l'etirement pour que le nuage part etrop loin.
	total_stretch = total_stretch.limit_length(max_stretch)
	
	# On l'applique à la position cible
	target_pos += total_stretch
	
	# Sécurité anti-disparition
	if particles:
		particles.global_position = current_pos
	
	# Le masque du personnage: core est un node vide, et prend a chaque miliseconde tout 
	# ce que le masque fait.
	if core_mask and target.has_node("Sprite2D"):
		var player_sprite = target.get_node("Sprite2D")
		core_mask.global_position = player_sprite.global_position
		# On copie l'image source du joueur
		core_mask.texture = player_sprite.texture
		# On copie les données de découpage de la feuille de sprite (lignes/colonnes)
		core_mask.hframes = player_sprite.hframes
		# On copie le numéro exact de l'image d'animation en cours (la frame)
		core_mask.vframes = player_sprite.vframes
		
		core_mask.frame = player_sprite.frame
		# On copie le sens du regard (si le joueur s'est retourné vers la gauche, le masque aussi)
		core_mask.flip_h = player_sprite.flip_h
		# On copie sa taille
		core_mask.scale = player_sprite.scale
	
	# 4. ENVOI AU SHADER
	if particles and particles.process_material is ShaderMaterial:
		particles.process_material.set_shader_parameter("target_pos", target_pos)
		
		var fake_velocity_for_cone = smoothed_velocity + (smoothed_input * 200.0)
		particles.process_material.set_shader_parameter("player_velocity", fake_velocity_for_cone)
		
	mask_viewport.size = get_viewport().get_visible_rect().size
	mask_viewport.canvas_transform = get_viewport().canvas_transform
