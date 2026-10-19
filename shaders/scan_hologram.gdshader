// Scan / x-ray mode (f07.8): surfaces near-black; only SOME edges catch a thick cyan-white
// rim light (#9fc2e4, HDR so the glow pass blooms it) from two virtual rim lights.
// Enemies use the same shader with `fill` > 0 (solid red).
shader_type spatial;
render_mode unshaded, cull_back, fog_disabled, shadows_disabled;

uniform vec3 tint : source_color = vec3(0.627, 0.784, 0.937);   // #a0c8ef
uniform float edge_energy = 3.4;
uniform float base = 0.012;
uniform float fill = 0.0;
uniform vec3 rim_dir_a = vec3(-0.7, 0.35, -0.6);   // world dirs the rim light comes from
uniform vec3 rim_dir_b = vec3(0.8, 0.2, 0.55);

void fragment() {
	vec3 wn = normalize((INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
	float ndv = clamp(abs(dot(NORMAL, VIEW)), 0.0, 1.0);
	float rim = smoothstep(0.42, 0.85, 1.0 - ndv);   // thick rims
	float side = max(smoothstep(0.25, 0.75, dot(wn, normalize(rim_dir_a))),
			smoothstep(0.35, 0.8, dot(wn, normalize(rim_dir_b))) * 0.7);
	vec3 col = tint * (base + rim * side * edge_energy) + tint * fill;
	ALBEDO = col;
}
