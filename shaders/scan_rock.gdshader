// Scan mode rock (f07.8 left): a diffuse soft blue haze (mean ~#0c1539) with brighter speckle
// (#1f2f77) and fuzzy, fading edges.
shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_back, fog_disabled, shadows_disabled;

uniform sampler2D noise_a : repeat_enable, filter_linear_mipmap;
uniform vec3 haze : source_color = vec3(0.15, 0.19, 0.34);    // reads ~#0c1539 after tonemap
uniform vec3 speck_col : source_color = vec3(0.2, 0.27, 0.6);   // reads ~#1f2f77
uniform float tex_scale = 0.05;
instance uniform float unit_scale = 1.0;

varying vec3 opos;
varying vec3 onrm;

void vertex() {
	opos = VERTEX * unit_scale;
	onrm = NORMAL;
}

void fragment() {
	vec3 w = pow(abs(normalize(onrm)) + 1e-3, vec3(4.0));
	w /= (w.x + w.y + w.z);
	vec3 p = opos * tex_scale;
	float s = texture(noise_a, p.yz * 2.5).r * w.x + texture(noise_a, p.xz * 2.5).r * w.y + texture(noise_a, p.xy * 2.5).r * w.z;
	float s2 = texture(noise_a, p.xz * 1.5 + 0.3).r;
	float speck = smoothstep(0.45, 0.85, s);
	float ndv = clamp(dot(NORMAL, VIEW), 0.0, 1.0);
	ALBEDO = mix(haze, speck_col, speck * 0.8) * (0.8 + 0.4 * s2);
	ALPHA = smoothstep(0.0, 0.9, ndv) * 0.9;   // fuzzy silhouette
}
