// Additive molten-crack overlay for IMPORTED asteroid models (keeps their own rock material).
shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_back, fog_disabled, shadows_disabled;

uniform sampler2D noise_r : repeat_enable, filter_linear_mipmap;
uniform float tex_scale = 0.06;
uniform vec3 hot_dir = vec3(1.0, 0.25, 0.0);
uniform float molten = 0.0;
uniform vec3 molten_col : source_color = vec3(1.0, 0.69, 0.125);   // #ffb020
instance uniform float heat = 0.0;

varying vec3 opos;
varying vec3 onrm;
varying vec3 wnrm;

instance uniform float unit_scale = 1.0;   // metres per object-space unit

void vertex() {
	opos = VERTEX * unit_scale;
	onrm = NORMAL;
	wnrm = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

float tri(sampler2D t, vec3 p, vec3 n) {
	vec3 w = pow(abs(n) + 1e-3, vec3(4.0));
	w /= (w.x + w.y + w.z);
	return texture(t, p.yz).r * w.x + texture(t, p.xz).r * w.y + texture(t, p.xy).r * w.z;
}

void fragment() {
	vec3 n = normalize(onrm);
	float c = tri(noise_r, opos * tex_scale * 0.55, n);
	float crack = smoothstep(0.86, 0.975, c);
	float lit = smoothstep(0.35, 0.8, dot(wnrm, normalize(hot_dir)));
	float rim = smoothstep(0.55, 0.92, 1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0));
	float grain = smoothstep(0.35, 0.75, tri(noise_r, opos * tex_scale * 9.0, n)) * 0.8 + 0.35;
	ALBEDO = molten_col * (rim * lit * molten * 2.6 * grain + crack * heat * 6.0);
}
