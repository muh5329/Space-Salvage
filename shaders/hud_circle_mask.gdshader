// Clips a TextureRect (target hologram) to a soft-edged circle.
shader_type canvas_item;

uniform float radius = 0.5;
uniform float soft = 0.04;

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	float r = length(UV - 0.5);
	c.a *= 1.0 - smoothstep(radius - soft, radius, r);
	COLOR = c;
}
