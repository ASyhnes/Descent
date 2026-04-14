extends VideoStreamPlayer

# Le chemin vers ton écran titre
var chemin_scene_suivante : String = "res://Scenes/UI/SplashLogo.tscn"

func _ready():
	# Se déclenche quand la vidéo finit
	finished.connect(passer_a_la_suite)

func passer_a_la_suite():
	get_tree().change_scene_to_file(chemin_scene_suivante)

func _input(event):
	# Passer l'intro avec n'importe quelle touche ou clic
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel") or (event is InputEventMouseButton and event.pressed):
		passer_a_la_suite()
