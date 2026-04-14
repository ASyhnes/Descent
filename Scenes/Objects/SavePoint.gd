class_name SavePoint
extends Area2D

@onready var sprite = $Sprite2D
var save_menu_scene = preload("res://Scenes/UI/SaveMenu.tscn")
var save_menu_instance = null

var is_dialogue_active = false
var player_ref = null

func _ready():
	save_menu_instance = save_menu_scene.instantiate()
	add_child(save_menu_instance)
	set_process(false)

func on_interact(player):
	player_ref = player
	DialogueManager.afficher_texte("Depuis la triangulation des Abeilles, l'OFI veille sur votre mémoire...")
	is_dialogue_active = true
	set_process(true)
	
func _process(_delta):
	# On attend que l'utilisateur appuie de nouveau sur "Action" (ui_accept) 
	# pendant que le texte de l'OFI est affiché devant lui
	if is_dialogue_active:
		if not DialogueManager.visible:
			is_dialogue_active = false
			set_process(false)
		elif Input.is_action_just_pressed("ui_accept"):
			DialogueManager.fermer()
			is_dialogue_active = false
			set_process(false)
			save_menu_instance.ouvrir(player_ref)

func on_player_look():
	pass
