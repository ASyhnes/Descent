class_name InteractableItem
extends Area2D

@export_group("Paramètres")
@export var item_name: String = "Objet"
@export var item_id: int = 0
@export var item_icon: Texture2D 
@export var is_blocking: bool = false
@export_multiline var interaction_text: String = ""

var mask_sprite : Sprite2D

@onready var sprite = $Sprite2D
@onready var collision_bloquante = $StaticBody2D/CollisionShape2D if has_node("StaticBody2D") else null

func _ready():
	if collision_bloquante:
		collision_bloquante.disabled = !is_blocking
	
	area_entered.connect(_on_area_entered)
	
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

var light_tween : Tween = null

# --- GESTION VISUELLE DE LA CARTE ---
func set_light_visual(is_lit: bool):
	if light_tween:
		light_tween.kill()
		
	if is_lit:
		sprite.modulate = Color(1, 1, 1)
		if mask_sprite: mask_sprite.show()
		
		# Lance l'extinction progressive
		light_tween = create_tween()
		light_tween.tween_property(sprite, "modulate", Color(0.3, 0.3, 0.3), 3.0).set_trans(Tween.TRANS_LINEAR)
		# Action locale pour cacher le masque à la fin du fade
		var hide_mask = func(): if mask_sprite: mask_sprite.hide()
		light_tween.tween_callback(hide_mask)
	else:
		sprite.modulate = Color(0.3, 0.3, 0.3)
		if mask_sprite: mask_sprite.hide()

# --- INTERACTIONS ---
func _on_area_entered(area):
	if area.name == "PerceptionArea":
		on_player_look()

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
