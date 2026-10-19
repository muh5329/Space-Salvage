// Scan mode aura: an inflated back-face shell around the ship, additive dark blue, giving the
// soft ~25 px glow around the silhouette seen in f07.8.
shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_front, fog_disabled, shadows_disabled;

uniform vec3 color : source_color = vec3(0.05, 0.08, 0.18);   // reads ~#1f3373 with bloom
uniform float grow = 1.3;

void vertex() {
	VERTEX += NORMAL * grow;
}

void fragment() {
	float ndv = clamp(abs(dot(NORMAL, VIEW)), 0.0, 1.0);
	ALBEDO = color * (0.35 + 0.65 * ndv);
}
