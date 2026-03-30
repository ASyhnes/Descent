shader_type canvas_item;

// On récupère la capture d'écran en couleur du BackBufferCopy
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	// On lit la forme de notre particule (notre rond flou)
	vec4 particle_shape = texture(TEXTURE, UV);
	
	// On lit la couleur du jeu en arrière-plan
	vec4 game_color = texture(screen_texture, SCREEN_UV);
	
	// On affiche la couleur du jeu, en utilisant la transparence de la particule
	COLOR = vec4(game_color.rgb, particle_shape.a * COLOR.a);
}