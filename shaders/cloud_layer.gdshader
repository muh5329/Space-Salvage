// Soft volumetric-looking cloud sheet. Drawn on a huge horizontal plane that follows the
// camera in XZ while the pattern is sampled in WORLD space, so it reads as static clouds with
// natural perspective parallax between stacked layers. Fake lighting: density gradient
// toward the light gives bright rims on the lit edges + darker cores.
shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled, fog_disabled, shadows_disabled;

uniform sampler2D noise_a : repeat_enable, filter_linear_mipmap;
uniform sampler2D noise_b : repeat_enable, filter_linear_mipmap;
uniform float scale = 0.0012;          // world metres -> noise uv
uniform vec2 seed_offset = vec2(0.0);
uniform vec2 drift = vec2(0.004, 0.002); // slow churn
uniform float coverage = 0.45;          // noise threshold where cloud starts
uniform float softness = 0.28;
uniform float opacity = 0.9;
uniform vec3 color_shadow : source_color = vec3(0.10, 0.14, 0.17);
uniform vec3 color_body : source_color = vec3(0.30, 0.38, 0.43);
uniform vec3 color_lit : source_color = vec3(0.55, 0.66, 0.72);
uniform vec2 light_dir = vec2(-0.6, -0.8);  // direction the light comes FROM (xz)
uniform float light_strength = 1.4;
uniform float detail = 0.44;            // weight of the higher-frequency octaves
uniform float fade_radius = 1800.0;     // fade alpha toward plane edges (metres from centre)
// Optional light shafts (diagonal bright bands masked by low-frequency noise).
uniform float shaft_strength = 0.0;
uniform vec3 shaft_color : source_color = vec3(0.6, 0.72, 0.8);
uniform float shaft_spacing = 380.0;

varying vec3 wpos;
varying vec3 lpos;

void vertex() {
	wpos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	lpos = VERTEX;
}

float dens(vec2 uv) {
	float n = texture(noise_a, uv).r * (1.0 - detail);
	n += texture(noise_a, uv * 2.07 + TIME * drift).r * detail * 0.64;
	n += texture(noise_b, uv * 4.3 - TIME * drift * 1.6).r * detail * 0.36;
	return n;
}

void fragment() {
	vec2 uv = wpos.xz * scale + seed_offset;
	float n = dens(uv);
	float d = smoothstep(coverage, coverage + softness, n);
	float n2 = dens(uv + normalize(light_dir) * 0.010);
	float lit = clamp((n2 - n) * 9.0 + 0.15, 0.0, 1.0);
	vec3 col = mix(color_shadow, color_body, d);
	col = mix(col, color_lit, lit * d * light_strength * 0.6);
	float a = d * opacity;
	if (shaft_strength > 0.0) {
		vec2 sd = normalize(vec2(0.35, 1.0));
		float s = dot(wpos.xz, vec2(sd.y, -sd.x)) / shaft_spacing;
		float band = pow(0.5001 + 0.4999 * sin(s * 6.2831 + texture(noise_a, uv * 0.3).r * 3.0), 6.0);
		float mask = smoothstep(0.45, 0.75, texture(noise_a, uv * 0.25 + vec2(0.37, 0.11)).r);
		float sh = band * mask * shaft_strength;
		col += shaft_color * sh;
		a = max(a, sh * 0.6);
	}
	a *= 1.0 - smoothstep(fade_radius * 0.7, fade_radius, length(lpos.xz));
	ALBEDO = col;
	ALPHA = clamp(a, 0.0, 1.0);
}
