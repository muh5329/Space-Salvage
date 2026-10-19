// Opaque deepest backdrop: large-scale colour variation + procedural sparse stars.
// Sits far below the play plane, follows the camera in XZ, pattern in world space.
shader_type spatial;
render_mode unshaded, cull_disabled, fog_disabled, shadows_disabled;

uniform sampler2D noise_a : repeat_enable, filter_linear_mipmap;
uniform vec3 color_deep : source_color = vec3(0.05, 0.08, 0.10);
uniform vec3 color_mid : source_color = vec3(0.17, 0.23, 0.27);
uniform float var_scale = 0.00035;
uniform float star_cell = 60.0;      // metres per star cell
uniform float star_density = 0.12;   // fraction of cells with a star
uniform float star_brightness = 1.6;
uniform vec3 star_tint : source_color = vec3(0.85, 0.92, 1.0);

varying vec3 wpos;

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

float hash12(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

void fragment() {
	float v = texture(noise_a, wpos.xz * var_scale).r;
	vec3 col = mix(color_deep, color_mid, smoothstep(0.25, 0.8, v));
	// stars: one candidate per cell, measured in screen pixels via derivatives.
	vec2 c = wpos.xz / star_cell;
	vec2 id = floor(c);
	float h = hash12(id);
	if (h < star_density) {
		vec2 sp = vec2(hash12(id + 17.1), hash12(id + 41.7)) * 0.8 + 0.1;
		vec2 dpx = (fract(c) - sp) / max(fwidth(c), vec2(1e-5));
		float pd = length(dpx);
		float sz = 0.6 + 0.9 * hash12(id + 5.3);
		float b = smoothstep(sz + 0.9, 0.0, pd);
		col += star_tint * b * star_brightness * (0.35 + 0.65 * hash12(id + 9.9));
	}
	ALBEDO = col;
}
