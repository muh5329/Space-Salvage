// Grey cratered rock with molten crack glow on the star-lit side (star zone) and when heated by
// the C-Beam (instance uniform `heat`, set by gameplay via Asteroid.heat).
// Triplanar in object space so procedural and imported meshes both work without UVs.
shader_type spatial;
render_mode cull_back, diffuse_burley;

uniform sampler2D noise_a : repeat_enable, filter_linear_mipmap;
uniform sampler2D noise_r : repeat_enable, filter_linear_mipmap;  // ridged -> cracks
uniform vec3 rock_dark : source_color = vec3(0.10, 0.10, 0.10);
uniform vec3 rock_light : source_color = vec3(0.42, 0.41, 0.40);
uniform float tex_scale = 0.06;
uniform vec3 hot_dir = vec3(1.0, 0.25, 0.0);     // world dir toward the heat/light source
uniform float molten = 0.0;                      // zone-level molten rim strength
uniform vec3 molten_col : source_color = vec3(1.0, 0.69, 0.125);   // #ffb020
instance uniform float heat = 0.0;
uniform float bump = 1.6;

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
	vec3 p = opos * tex_scale;
	vec3 n = normalize(onrm);
	float big = tri(noise_a, p * 0.5, n);
	float fine = tri(noise_a, p * 3.3, n);
	float speck = tri(noise_a, p * 11.0, n);
	float pits = tri(noise_r, p * 2.2, n);           // ridged -> crater-ish rims / pits
	float v = big * 0.45 + fine * 0.35 + speck * 0.35;
	vec3 alb = mix(rock_dark, rock_light, smoothstep(0.25, 0.85, v));
	alb *= 0.7 + 0.55 * smoothstep(0.3, 0.7, speck);
	// bump: height from layered noise, perturb the view-space normal (no UVs/tangents needed)
	float h = big * 0.8 + fine * 0.45 + speck * 0.18 - pits * 0.35;
	vec3 dpdx = dFdx(VERTEX);
	vec3 dpdy = dFdy(VERTEX);
	float dhdx = dFdx(h);
	float dhdy = dFdy(h);
	vec3 r1 = cross(dpdy, NORMAL);
	vec3 r2 = cross(NORMAL, dpdx);
	float det = dot(dpdx, r1);
	vec3 grad = sign(det) * (dhdx * r1 + dhdy * r2);
	NORMAL = normalize(abs(det) * NORMAL - grad * bump);
	ALBEDO = alb;
	ROUGHNESS = 0.92;
	SPECULAR = 0.3;
	// molten glow ONLY on the star-facing rim (f08.4); cracks appear only when C-Beam heated
	float lit = smoothstep(0.35, 0.8, dot(wnrm, normalize(hot_dir)));
	float rim = smoothstep(0.55, 0.92, 1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0));
	float c = tri(noise_r, p * 0.55, n);
	float crack = smoothstep(0.86, 0.975, c);
	float grain = smoothstep(0.35, 0.75, speck) * 0.8 + 0.35;   // granular, speckled band
	vec3 e = molten_col * rim * lit * molten * 2.6 * grain;
	e += molten_col * heat * (crack * 6.0 + 0.35 * smoothstep(0.4, 0.8, fine));
	EMISSION = e;
}
