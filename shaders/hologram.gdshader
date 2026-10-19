// Target-panel hologram (detail_target_panel.png): semi-transparent bluish-white, strong
// fresnel edges, top-light shading and dark panel lines taken from the hull albedo texture.
shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_always, cull_back, fog_disabled, shadows_disabled;

uniform sampler2D albedo_tex : source_color, filter_linear_mipmap;
uniform float use_tex = 0.0;
uniform vec3 tint : source_color = vec3(0.66, 0.72, 0.88);   // #a8b8e0
uniform vec3 shade : source_color = vec3(0.2, 0.25, 0.4);
uniform float alpha = 0.7;

void fragment() {
	float ndv = clamp(abs(dot(NORMAL, VIEW)), 0.0, 1.0);
	float fres = (1.0 - ndv) * (1.0 - ndv);
	float l = clamp(dot(NORMAL, normalize(vec3(-0.4, 0.8, 0.5))), 0.0, 1.0);
	vec3 col = mix(shade, tint * 0.9, 0.25 + 0.75 * l);
	if (use_tex > 0.5) {
		float lum = dot(texture(albedo_tex, UV).rgb, vec3(0.3, 0.59, 0.11));
		col *= mix(0.35, 1.15, smoothstep(0.08, 0.45, lum));   // dark seams / panels
	}
	col += tint * fres * 0.9;
	ALBEDO = col;
	ALPHA = clamp(alpha * (0.75 + 0.5 * fres), 0.0, 1.0);
}
