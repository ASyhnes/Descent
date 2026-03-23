extends PointLight2D

# On va chercher les bulles que TU as créées manuellement
@onready var bulles = get_children()

func _process(delta):
	var time = Time.get_ticks_msec() / 1000.0
	
	for i in range(bulles.size()):
		var b = bulles[i]
		if b is PointLight2D:
			# 1. Mouvement : elles tournent autour du centre
			var angle = time * (1.0 + i * 0.5)
			var rayon = 15.0 + (i * 5.0)
			b.offset = Vector2(cos(angle), sin(angle)) * rayon
			
			# 2. Taille : elles gonflent et dégonflent
			var pulse = sin(time * 2.0 + i)
			b.texture_scale = 0.8 + (pulse * 0.3)
