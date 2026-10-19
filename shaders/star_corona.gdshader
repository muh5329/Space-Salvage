// Star corona (f08.4): camera-facing quad around the star sphere. Dim red glow hugging the limb
// plus sparse dark-red spicule streaks 40–80 px long. Additive, intentionally restrained.
shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_disabled, fog_disabled, shadows_disabled;

uniform sampler2D noise_a : repeat_enable, filter_linear_mipmap;
uniform float quad_radii = 1.35;   // quad half-size expressed in star radii
uniform vec3 col_spike : source_color = vec3(0.45, 0.1, 0.07);
uniform vec3 col_glow : source_color = vec3(0.63, 0.16, 0.11);   // #a1281c
uniform float spike_len = 0.26;
uniform float energy = 1.0;

void vertex() {
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	MODELVIEW_MATRIX = MODELVIEW_MATRIX * mat4(vec4(length(MODEL_MATRIX[0].xyz), 0, 0, 0), vec4(0, length(MODEL_MATRIX[1].xyz), 0, 0), vec4(0, 0, length(MODEL_MATRIX[2].xyz), 0), vec4(0, 0, 0, 1));
}

void fragment() {
	vec2 c = (UV - 0.5) * 2.0 * quad_radii;
	float r = length(c);
	float a = atan(c.y, c.x) / 6.28318 + 0.5;
	float out_r = r - 1.0;
	if (out_r < 0.0) {
		ALBEDO = vec3(0.0);
	} else {
		float s1 = texture(noise_a, vec2(a * 31.0, TIME * 0.01)).r;
		float s2 = texture(noise_a, vec2(a * 67.0, 0.5 + TIME * 0.013)).r;
		float spikes = smoothstep(0.6, 0.92, s1 * 0.6 + s2 * 0.55);
		float len = spike_len * (0.5 + 0.9 * s2);
		float spike_i = spikes * (1.0 - smoothstep(0.0, len, out_r));
		// chromosphere band 5–40 px (≈0.01–0.09 R) at ~#a1281c, then a faint falloff
		float glow = (1.0 - smoothstep(0.03, 0.095, out_r)) * 0.7 + exp(-out_r * 5.0) * 0.45;
		ALBEDO = (col_spike * spike_i * 0.9 + col_glow * glow) * energy;
	}
}
