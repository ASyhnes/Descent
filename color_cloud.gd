extends Node2D

@export var target_path: NodePath
@onready var target: Node2D = get_node_or_null(target_path)

# --- PHYSIQUE DU RESSORT ---
var velocity: Vector2 = Vector2.ZERO
var springiness: float = 15.0
var damping: float = 5.0

func _process(delta: float) -> void:
	if not target:
		return
		
	# Calcul du déplacement élastique vers la position du joueur
	var displacement = global_position - target.global_position
	var spring_force = -springiness * displacement - damping * velocity
	
	velocity += spring_force * delta
	global_position += velocity * delta
	
