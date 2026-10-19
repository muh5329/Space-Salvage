// Main exhaust cone (f00.05): pale cream-yellow, near-opaque with a fairly hard edge, fading
// toward the tail; HDR core so the glow pass gives it a halo. Same mesh conventions as
// plume.gdshader (mesh +Y = nozzle). No NORMAL / no pow(): see plume.gdshader notes.
shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_back, fog_disabled, shadows_disabled;

uniform vec3 col_core : source_color = vec3(0.925, 0.914, 0.84);   // #ece9d6
uniform vec3 col_edge : source_color = vec3(0.95, 0.82, 0.52);
uniform float energy = 1.7;
uniform float throttle = 1.0;
uniform float half_height = 0.5;
uniform float opacity = 0.95;

varying float along;
varying vec3 radial_v;

void vertex() {
	along = clamp(0.5 - VERTEX.y / (2.0 * half_height), 0.0, 1.0);
	vec2 r = VERTEX.xz;
	r = r / max(length(r), 1e-5);
	radial_v = (MODELVIEW_MATRIX * vec4(r.x, 0.0, r.y, 0.0)).xyz;
}

void fragment() {
	float ndv = clamp(abs(dot(radial_v / max(length(radial_v), 1e-5), VIEW)), 0.0, 1.0);
	float edge = smoothstep(0.05, 0.35, ndv);              // hard-ish silhouette
	float tail = 1.0 - along;
	float fade = smoothstep(0.0, 0.55, tail);                // solid most of the way, soft tip
	float flick = 0.93 + 0.07 * sin(TIME * 53.0) * sin(TIME * 29.0);
	vec3 col = mix(col_edge, col_core, smoothstep(0.3, 0.9, ndv)) * energy * flick;
	ALBEDO = col;
	ALPHA = clamp(edge * fade * opacity * throttle, 0.0, 1.0);
}
