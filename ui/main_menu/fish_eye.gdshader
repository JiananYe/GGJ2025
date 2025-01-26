/////////////////////////////////
// 2D Radial Distortion Shader //
/////////////////////////////////

// Screen space shader for Godot, based on: https://gist.github.com/aggregate1166877/a889083801d67917c26c12a98e7f57a7

shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform float aspect = 1.0;
uniform float distortion = 1.0;
uniform float radius = 1.0;
uniform float alpha = 1.0;
uniform float crop = 1.0;
uniform vec4 crop_color = vec4(0,0,0,1);
uniform vec2 effect_center = vec2(0.5, 0.5); // Center of the effect in normalized coordinates
uniform vec2 effect_size = vec2(1.0, 1.0); // Size of the effect in normalized coordinates

vec2 distort(vec2 p)
{
	float d = length(p);
	if (d == 0.0) return vec2(0.5, 0.5); // handle the center case
	float z = sqrt(distortion + d * d * -distortion);
	float r = atan(d, z) / 3.1415926535;
	float phi = atan(p.y, p.x);
	return vec2(r * cos(phi) * (1.0 / aspect), r * sin(phi));
}

void fragment()
{
	vec2 scale = vec2(aspect, 1.0);
	vec2 xy = (SCREEN_UV - effect_center) / effect_size * 2.0; // move origin of UV coordinates to center of effect and scale

	xy = xy * scale; // adjust aspect ratio

	float d = length(xy); // distance from center

	vec4 tex;

	if (d < radius)
	{
		xy = distort(xy);
		tex = texture(SCREEN_TEXTURE, (xy / scale) * effect_size / 2.0 + effect_center); // scale and move back to original UV space
		COLOR = tex;
		COLOR.a = alpha;
	}
	else
	{
		COLOR = crop_color;
	}
}