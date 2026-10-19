// Nebula haze sheet just below the play plane: smooth grey-teal fog whose density the
// EnvManager ramps up as you fly deeper into the cloud (f00.05 -> f02.0), plus soft vertical
// light shafts (world-fixed columns, brighter toward the top/north of the screen).
shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled, fog_disabled, shadows_disabled;

uniform sampler2D noise_a : repeat_enable, filter_linear_mipmap;
uniform vec3 haze_color : source_color = vec3(0.43, 0.52, 0.57);
uniform float density = 0.2;
uniform float var_scale = 0.0004;
uniform vec2 focus = vec2(0.0);          // world XZ under the screen centre (set per frame)
uniform float shaft_origin_x = 0.0;
uniform float shaft_spacing = 280.0;
uniform float shaft_width = 11.0;
uniform float shaft_strength = 0.0;
uniform vec3 shaft_color : source_color = vec3(0.70, 0.80, 0.86);
uniform float fade_radius = 2500.0;

varying vec3 wpos;
varying vec3 lpos;

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	lpos = VERTEX;
}

float hash11(float p) {
	p = fract(p * 0.1031);
	p *= p + 33.33;
	p *= p + p;
	return fract(p);
}

void fragment() {
	float n = texture(noise_a, wpos.xz * var_scale + vec2(0.31, 0.77)).r;
	float a = density * (0.8 + 0.4 * n);
	vec3 col = haze_color * (0.92 + 0.16 * n);
	if (shaft_strength > 0.0) {
		float k = floor((wpos.x - shaft_origin_x) / shaft_spacing + 0.5);
		float cx = shaft_origin_x + k * shaft_spacing;
		float amp = 0.55 + 0.45 * hash11(k + 7.0);
		float dx = (wpos.x - cx) / shaft_width;
		float g = exp(-dx * dx);
		// brighter toward the top of the screen (north of the focus), fading southward
		float vfade = smoothstep(focus.y + 25.0, focus.y - 45.0, wpos.z);
		float flick = 0.85 + 0.15 * texture(noise_a, vec2(wpos.z * 0.002, k * 0.37)).r;
		float s = g * vfade * amp * flick * shaft_strength;
		col = mix(col, shaft_color, clamp(s * 1.6, 0.0, 1.0));
		a = max(a, s);
	}
	// the cloud deepens to the east (right third darker at f02.0), stronger as the fog thickens
	float east = smoothstep(-10.0, 45.0, wpos.x - focus.x);
	float deep = east * clamp(density * 2.4, 0.0, 1.0);
	col *= 1.0 - 0.45 * deep;
	a = max(a, 0.55 * deep);
	a *= 1.0 - smoothstep(fade_radius * 0.7, fade_radius, length(lpos.xz));
	ALBEDO = col;
	ALPHA = clamp(a, 0.0, 1.0);
}
