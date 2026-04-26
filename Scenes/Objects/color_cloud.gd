extends Node2D

@export var target_path: NodePath
@onready var target: Node2D = get_node_or_null(target_path)
@onready var perception_area = $PerceptionArea

# --- NOUVEAUX PARAMÈTRES "LAMPE TORCHE" MÉCANIQUE ---
# La distance à laquelle le nuage est projeté quand le joueur est à l'arrêt
@export var min_beam_distance: float = 15.0
# La distance à laquelle le nuage est projeté quand le joueur marche
@export var max_beam_distance: float = 20.0

@onready var bw_rect = $BW_Layer/ColorRect
@onready var mask_viewport = $MaskViewport
@onready var particles = $MaskViewport/GPUParticles2D
@onready var core_mask = $MaskViewport/CoreMask 

var base_offset: Vector2 = Vector2(-8, 0) 
var current_look_dir: Vector2 = Vector2(0, 1) # Direction du regard par défaut (vers le bas)
var current_beam_distance: float = 15.0
var last_look_dir: Vector2 = Vector2(0, 1) # <-- NOUVELLE VARIABLE


func _ready():
	if target:
		# On s'assure que le raycast du joueur ignore la zone de particules !
		var raycast = target.get_node_or_null("InteractionRay")
		if raycast and perception_area:
			raycast.add_exception(perception_area)
			
	mask_viewport.size = get_viewport().get_visible_rect().size
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	bw_rect.material.set_shader_parameter("mask_texture", mask_viewport.get_texture())
	
	# Force le nuage à s'émettre dès le début, sans attendre la pression d'une touche
	if particles:
		particles.restart()

func _process(delta: float) -> void:
	if not target:
		return
		
	var current_pos = target.global_position
	
# 1. L'INTENTION DU REGARD ET LA DISTANCE
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var target_distance = min_beam_distance
	
	if input_dir != Vector2.ZERO:
		current_look_dir = input_dir.normalized()
		target_distance = max_beam_distance 
		
		# --- NOUVEAU : LE COUPE-CIRCUIT ---
		# Si la direction actuelle est différente de l'ancienne direction
		if current_look_dir != last_look_dir:
			if particles:
				particles.restart() # On efface instantanément les anciennes particules !
			last_look_dir = current_look_dir # On mémorise la nouvelle direction
		# ----------------------------------
	# 2. APPLICATION DIRECTE (Aucune élasticité)
	# On applique la distance instantanément
	current_beam_distance = target_distance
	
	# 3. POSITION CIBLE FINALE
	# On utilise "current_look_dir" directement (rotation instantanée)
	var target_pos = current_pos + base_offset + (current_look_dir * current_beam_distance)
	
	# On déplace la zone de détection physique
	if perception_area:
		perception_area.global_position = target_pos
	
	# Sécurité anti-disparition ET Avancée du canon
	if particles:
		# On fait naître les particules 15 pixels DEVANT le joueur (changement de direction instantané)
		particles.global_position = current_pos + (current_look_dir * 15.0)
	
	# Le masque du personnage
	if core_mask and target.has_node("Sprite2D"):
		var player_sprite = target.get_node("Sprite2D")
		core_mask.global_position = player_sprite.global_position
		core_mask.texture = player_sprite.texture
		core_mask.hframes = player_sprite.hframes
		core_mask.vframes = player_sprite.vframes
		core_mask.frame = player_sprite.frame
		core_mask.flip_h = player_sprite.flip_h
		core_mask.scale = player_sprite.scale
	
	# 4. ENVOI AU SHADER
	if particles and particles.process_material is ShaderMaterial:
		particles.process_material.set_shader_parameter("target_pos", target_pos)
		
		# Impulsion massive et instantanée dans la nouvelle direction
		var fake_velocity_for_cone = current_look_dir * 50.0
		particles.process_material.set_shader_parameter("player_velocity", fake_velocity_for_cone)
		
	mask_viewport.size = get_viewport().get_visible_rect().size
	mask_viewport.canvas_transform = get_viewport().canvas_transform
