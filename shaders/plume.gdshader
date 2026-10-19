// Engine exhaust plume on a cone/cylinder mesh (mesh local +Y = nozzle end, -Y = tail).
// Additive, soft view-dependent edges, hot core near the nozzle, flicker. Length is driven by
// scaling the node; `throttle` drives brightness.
shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, cull_back, fog_disabled, shadows_disabled;

uniform vec3 col_core : source_color = vec3(1.0, 0.95, 0.80);
uniform vec3 col_outer : source_color = vec3(1.0, 0.70, 0.30);
uniform float energy = 3.0;
uniform float throttle = 1.0;
uniform float half_height = 0.5;
uniform float core_power = 1.6;
uniform float edge_power = 1.8;
uniform float flicker_seed = 0.0;

varying float along;
varying vec3 radial_v;   // view-space radial direction of the cone surface

void vertex() {
	along = clamp(0.5 - VERTEX.y / (2.0 * half_height), 0.0, 1.0); // 0 nozzle .. 1 tail
	// NORMAL is unreliable here (node is scaled ~10x along its length -> NaNs on lavapipe),
	// so use the unscaled radial direction for the soft edge term.
	vec2 r = VERTEX.xz;
	r = r / max(length(r), 1e-5);
	radial_v = (MODELVIEW_MATRIX * vec4(r.x, 0.0, r.y, 0.0)).xyz;
}

void fragment() {
	float rl = max(length(radial_v), 1e-5);
	float ndv = clamp(abs(dot(radial_v / rl, VIEW)), 0.0, 1.0);
	// polynomial falloffs (pow() produced NaN pixels on lavapipe that glow smeared into blobs)
	float edge = ndv * ndv;
	float tail = 1.0 - along;
	float fade = tail * mix(1.0, tail, clamp(core_power - 1.0, 0.0, 1.0));
	float flick = 0.88 + 0.12 * sin(TIME * 57.0 + flicker_seed) * sin(TIME * 31.0 + flicker_seed * 2.0);
	vec3 col = mix(col_outer, col_core, (edge * edge) * (1.0 - along * 0.6));
	ALBEDO = col * edge * fade * energy * throttle * flick;
}
