// Red giant surface (f08.4): dark crimson base with big dark patches, multi-scale granulation
// and bright fibrous orange filaments, churning slowly; thin (8–12 px) yellow-orange limb.
// Sampled in object space with 3D noise (no seams/poles).
shader_type spatial;
render_mode unshaded, fog_disabled, shadows_disabled;

uniform sampler3D noise3 : repeat_enable, filter_linear;
uniform vec3 col_dark : source_color = vec3(0.2, 0.07, 0.05);
uniform vec3 col_base : source_color = vec3(0.46, 0.16, 0.11);
uniform vec3 col_fil : source_color = vec3(0.92, 0.42, 0.22);
uniform vec3 col_limb : source_color = vec3(1.0, 0.72, 0.28);
uniform float energy = 1.0;
uniform float churn = 0.02;

varying vec3 opos;

void vertex() {
	opos = normalize(VERTEX);
}

void fragment() {
	float t = TIME * churn;
	vec3 p = opos;
	// big dark patches (low frequency)
	float patches = texture(noise3, p * 0.5 + vec3(0.13, t * 0.5, 0.71)).r;
	// domain-warped mid-scale granulation
	float w1 = texture(noise3, p * 1.6 + vec3(t, 0.0, t * 0.7)).r;
	float w2 = texture(noise3, p * 1.6 + vec3(0.31, t * 0.8, 0.77)).r;
	vec3 q = p * 5.0 + vec3(w1, w2, w1 * w2) * 1.3 + vec3(0.0, t * 2.0, 0.0);
	float g1 = texture(noise3, q).r;
	float g2 = texture(noise3, q * 2.3 + vec3(t * 2.0)).r;
	float g3 = texture(noise3, q * 5.1 - vec3(t * 3.0)).r;
	// fibrous filaments: thin ridges of two octaves, stretched by the warp
	float r1 = 1.0 - abs(g1 * 2.0 - 1.0);
	float r2 = 1.0 - abs(g2 * 2.0 - 1.0);
	float fil = smoothstep(0.86, 0.98, r1) * 0.8 + smoothstep(0.9, 0.99, r2) * 0.5;
	float gran = g2 * 0.5 + g3 * 0.5;
	vec3 col = mix(col_dark, col_base, smoothstep(0.2, 0.75, gran));
	col *= mix(0.22, 1.15, smoothstep(0.32, 0.68, patches));   // big dark patches
	col = mix(col, col_fil, clamp(fil, 0.0, 1.0) * smoothstep(0.25, 0.6, patches + 0.15));
	// thin bright limb (ndv < ~0.2 ≈ outer 2% of the radius)
	float ndv = clamp(dot(NORMAL, VIEW), 0.0, 1.0);
	float limb = smoothstep(0.28, 0.06, ndv);
	col = mix(col, col_limb * 1.6, limb);
	ALBEDO = col * energy;
}
