shader_type canvas_item;

uniform float fill_amount : hint_range(0.0, 1.0) = 1.0;
uniform vec4 fill_color : source_color = vec4(1.0);

void fragment() {
    vec4 texture_color = texture(TEXTURE, UV);
    if (UV.y < 1.0 - fill_amount) {
        texture_color.a = 0.0;
    }
    COLOR = texture_color * fill_color;
} 