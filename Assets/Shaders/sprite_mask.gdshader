shader_type canvas_item;
void fragment() {
    vec4 col = texture(TEXTURE, UV);
    COLOR = vec4(1.0, 1.0, 1.0, col.a * COLOR.a); // Garde la forme, mais peint en blanc tout en respectant l'alpha
}