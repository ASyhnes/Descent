extends CanvasLayer

func _ready():
	# O, fait en sorte que rectangle visible
	$ColorRect.color.a = 1.0
	
	# On crée un Twen (un outil Godot pour créer des animations fluides par le code)
	var tween = create_tween()
	
	# Pause dans le noir total pour laisser les particules (springs) se placer
	tween.tween_interval(1.5)
	
	# le Tween d'animer la transparence
	tween.tween_property($ColorRect, "color:a", 0.0, 2.0)
	
	 #Une fois animation terminée, on détruit cette scèn
	tween.tween_callback(queue_free)
