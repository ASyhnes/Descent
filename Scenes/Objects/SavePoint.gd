class_name SavePoint
extends Area2D

@onready var sprite = $Sprite2D
var save_menu_scene = preload("res://Scenes/UI/SaveMenu.tscn")
var save_menu_instance = null
var player_ref = null

func _ready():
	save_menu_instance = save_menu_scene.instantiate()
	add_child(save_menu_instance)

# Appelé par CheckInteraction() quand le joueur interagit avec le SavePoint
func on_interact(player):
	player_ref = player
	DialogueManager.afficher_texte(
		"Depuis la triangulation des Abeilles, l'OFI veille sur votre mémoire...",
		self  # On se déclare propriétaire pour intercepter le prochain ui_accept
	)

# Appelé par CheckInteraction() quand le joueur appuie sur ui_accept pendant l'affichage
func on_dialogue_advance():
	DialogueManager.fermer()
	if player_ref:
		save_menu_instance.ouvrir(player_ref)

func on_player_look():
	pass
