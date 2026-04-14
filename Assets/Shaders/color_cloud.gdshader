shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D mask_texture : hint_default_transparent;

void fragment() {
    vec4 original_color = texture(screen_texture, SCREEN_UV);
    float gray = dot(original_color.rgb, vec3(0.299, 0.587, 0.114));
    vec4 bw_color = vec4(gray, gray, gray, 1.0);

    float mask_value = texture(mask_texture, SCREEN_UV).a;

    COLOR = mix(bw_color, original_color, mask_value);
}