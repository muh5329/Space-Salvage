// Full-screen post pass (CanvasLayer under the HUD): vignette, film grain, lightning/flash
// overlay and an optional tint. Reads the rendered 3D frame via the screen texture.
shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture, filter_linear;
uniform float vignette = 0.24;
uniform float grain = 0.028;
uniform float flash = 0.0;                         // 0..1 lightning / jump flash
uniform vec3 flash_color : source_color = vec3(1.0, 0.9, 0.95);   // pink-white
uniform vec2 flash_center = vec2(0.5, 0.3);
uniform float saturation = 1.0;

float hash(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

void fragment() {
	vec3 c = texture(screen_tex, SCREEN_UV).rgb;
	float l = dot(c, vec3(0.299, 0.587, 0.114));
	c = mix(vec3(l), c, saturation);
	vec2 d = (SCREEN_UV - 0.5) * vec2(1.25, 1.0);
	c *= 1.0 - vignette * smoothstep(0.2, 0.85, length(d));
	float fr = 1.0 - 0.6 * smoothstep(0.0, 0.75, length((SCREEN_UV - flash_center) * vec2(1.6, 1.0)));
	c = mix(c, flash_color, flash * 0.55 * fr) + flash_color * flash * 0.3 * fr;
	float g = hash(floor(FRAGCOORD.xy) + fract(TIME * 13.7) * 91.0) - 0.5;
	c += g * grain;
	COLOR = vec4(c, 1.0);
}
