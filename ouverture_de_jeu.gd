extends CanvasLayer

func _ready():
	# O, fait en sorte que rectangle visible
	$ColorRect.modulate.a = 1.0
	
	# On crée un Twen (un outil Godot pour créer des animations fluides par le code)
	var tween = create_tween()
	
	# le Tween d'animer la transparence
	tween.tween_property($ColorRect, "modulate:a", 0.0, 2.0)
	
	 #Une fois animation terminée, on détruit cette scèn
	tween.tween_callback(queue_free)
