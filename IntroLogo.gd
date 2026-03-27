extends VideoStreamPlayer


var chemin_scene_suivante : String = "res://ecran_titre.tscn"

func _ready():
	# suite apres fin scene
	finished.connect(passer_a_la_suite)

func passer_a_la_suite():
	# On charge la scène qu'on a définie plus haut (l'Écran Titre)
	get_tree().change_scene_to_file(chemin_scene_suivante)

func _input(event):
	# Si le joueur est impatient et appuie sur Entrée, Espace, Échap ou clique : on coupe la vidéo !
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel") or (event is InputEventMouseButton and event.pressed):
		passer_a_la_suite()
