extends Control # Bien vérifier que c'est Control ici !

var prochaine_scene = "res://ecran_titre.tscn"

# Comme le VoileNoir est maintenant un enfant direct de NouvelleRacine :
@onready var voile = $TextureRect/Label/VoileNoir

func _ready():
	# Sécurité : on s'assure que le voile couvre tout l'écran et est visible
	voile.show()
	voile.color.a = 1.0 # On commence dans le noir total
	
	var tween = create_tween()
	
	# 1. Apparition (Fade in) : Le noir devient transparent (0.0)
	# On découvre l'image ET le texte en même temps
	tween.tween_property(voile, "color:a", 0.0, 1.5)
	
	# 2. Pause (On laisse le temps de lire)
	tween.tween_interval(2.0)
	
	# 3. Disparition (Fade out) : Le noir revient (1.0)
	# On cache l'image ET le texte en même temps
	tween.tween_property(voile, "color:a", 1.0, 1.5)
	
	# 4. Quand le fondu est fini, on change de scène
	tween.finished.connect(_on_timer_timeout)

func _on_timer_timeout():
	get_tree().change_scene_to_file(prochaine_scene)

func _input(event):
	# Permettre de passer l'animation
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed):
		_on_timer_timeout()
