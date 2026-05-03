extends Control

@onready var label = $CenterContainer/Panel/HBoxContainer/Label
@onready var animation_player = $AnimationPlayer

func _ready():
	modulate = Color(1, 1, 1, 0) # Invisible par défaut
	animation_player.animation_finished.connect(_on_animation_finished)

func afficher(texte: String):
	if label:
		label.text = texte
	if animation_player:
		animation_player.play("show")

func _on_animation_finished(anim_name):
	if anim_name == "show":
		queue_free()
