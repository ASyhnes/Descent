shader_type canvas_item;

// 1. On déclare la capture de l'écran (C'est elle qui te manquait !)
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

// 2. On déclare notre masque avec la sécurité "anti-flash"
uniform sampler2D mask_texture : hint_default_black; 

void fragment() {
    // 3. On lit la couleur d'origine du jeu
    vec4 original_color = texture(screen_texture, SCREEN_UV);
    
    // 4. On calcule la version Noir et Blanc
    float gray = dot(original_color.rgb, vec3(0.299, 0.587, 0.114));
    vec4 bw_color = vec4(gray, gray, gray, 1.0);
    
    // 5. On regarde où sont les particules (le masque)
    float mask_value = texture(mask_texture, SCREEN_UV).r;
    
    // 6. On affiche le mélange final !
    COLOR = mix(bw_color, original_color, mask_value);
}