class_name InteractableItem
extends Area2D

@export_group("Paramètres")
@export var item_name: String = "Objet"
@export var item_id: int = 0
@export var item_icon: Texture2D 
@export var is_blocking: bool = false
@export_multiline var interaction_text: String = ""

var mask_sprite : Sprite2D
var light_tween : Tween = null
var overlapping_perception_areas : Array[Area2D] = []
var was_fully_covered : bool = false

@onready var sprite = $Sprite2D
@onready var collision_bloquante = $StaticBody2D/CollisionShape2D if has_node("StaticBody2D") else null

func _ready():
	if collision_bloquante:
		collision_bloquante.disabled = !is_blocking
	
	area_entered.connect(_on_area_entered)
	if not area_exited.is_connected(_on_area_exited):
		area_exited.connect(_on_area_exited)
	
	var mask_viewport = get_tree().current_scene.get_node_or_null("ColorCloud/MaskViewport")
	
	if mask_viewport:
		mask_sprite = Sprite2D.new()
		mask_sprite.texture = sprite.texture
		mask_sprite.hframes = sprite.hframes
		mask_sprite.vframes = sprite.vframes
		mask_sprite.frame = sprite.frame
		mask_sprite.scale = sprite.scale
		
		var mask_material = ShaderMaterial.new()
		mask_material.shader = load("res://Assets/Shaders/sprite_mask.gdshader") 
		mask_sprite.material = mask_material
		
		mask_viewport.add_child(mask_sprite)
		mask_sprite.hide()
	
	# Éteint par défaut au lancement
	set_light_visual(false)

func _process(_delta):
	if mask_sprite and mask_sprite.visible:
		mask_sprite.global_position = sprite.global_position
		
	var currently_covered = false
	for area in overlapping_perception_areas:
		if is_fully_covered_by(area):
			currently_covered = true
			break
			
	if currently_covered:
		if not was_fully_covered:
			on_player_look()
			was_fully_covered = true
	else:
		was_fully_covered = false

func is_fully_covered_by(area: Area2D) -> bool:
	var col_shape = area.get_node_or_null("CollisionShape2D")
	if not col_shape or not col_shape.shape is CircleShape2D:
		return false
		
	var radius = col_shape.shape.radius
	var center = area.global_position
	
	var my_shape_node = get_node_or_null("CollisionShape2D")
	if not my_shape_node:
		return false
		
	var my_shape = my_shape_node.shape
	if my_shape is RectangleShape2D:
		var half_size = my_shape.size / 2.0
		var my_center = my_shape_node.global_position
		
		var corners = [
			my_center + Vector2(half_size.x, half_size.y),
			my_center + Vector2(half_size.x, -half_size.y),
			my_center + Vector2(-half_size.x, half_size.y),
			my_center + Vector2(-half_size.x, -half_size.y)
		]
		
		for corner in corners:
			if corner.distance_to(center) > radius:
				return false
		return true
	elif my_shape is CircleShape2D:
		var my_radius = my_shape.radius
		var my_center = my_shape_node.global_position
		return my_center.distance_to(center) + my_radius <= radius
		
	return global_position.distance_to(center) < (radius * 0.5)

# --- GESTION VISUELLE DE LA CARTE ---
func set_light_visual(is_lit: bool):
	if light_tween:
		light_tween.kill()
		
	# On garde la couleur principale toujours à 1 pour qu'il réagisse comme n'importe quel élément de la carte
	sprite.modulate = Color(1, 1, 1)
	
	if is_lit:
		if mask_sprite:
			mask_sprite.show()
			mask_sprite.modulate = Color(1, 1, 1, 1)
		
		# Lance l'extinction progressive via l'opacité du masque, pour redescendre doucement vers le statut B&W
		light_tween = create_tween()
		if mask_sprite:
			light_tween.tween_property(mask_sprite, "modulate:a", 0.0, 3.0).set_trans(Tween.TRANS_LINEAR)
			# Action locale pour cacher le masque à la fin du fade
			var hide_mask = func(): mask_sprite.hide()
			light_tween.tween_callback(hide_mask)
	else:
		if mask_sprite:
			mask_sprite.modulate = Color(1, 1, 1, 0)
			mask_sprite.hide()

# --- INTERACTIONS ---
func _on_area_entered(area):
	if area.name == "PerceptionArea":
		if not overlapping_perception_areas.has(area):
			overlapping_perception_areas.append(area)

func _on_area_exited(area):
	if area.name == "PerceptionArea":
		overlapping_perception_areas.erase(area)

func on_player_look():
	# Demande au manager de gérer l'allumage sur la carte
	MemoryManager.process_light(self)

func on_player_interact():
	# Demande au manager de le stocker dans l'UI
	MemoryManager.process_on(self)
	
	if interaction_text != "":
		DialogueManager.afficher_texte(interaction_text)

func _exit_tree():
	if mask_sprite:
		mask_sprite.queue_free()
