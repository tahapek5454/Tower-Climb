shader_type spatial;
// Düz renkli çizgi film gölgelemesi (dokusuz aksesuarlar için: sırt roketi).
// toon_character ile aynı ışık kuralı: kamera uzayında sabit yönden iki tonlu ışık + kenar ışığı.
render_mode unshaded;

uniform vec3 base_color : source_color = vec3(0.9, 0.4, 0.25);
uniform vec3 light_direction = vec3(-0.35, 0.75, 0.55);
uniform vec3 shadow_tint : source_color = vec3(0.62, 0.64, 0.80);
uniform float shade_threshold : hint_range(-1.0, 1.0) = -0.1;
uniform float shade_softness : hint_range(0.001, 0.5) = 0.04;
uniform vec3 rim_color : source_color = vec3(0.75, 0.85, 1.0);
uniform float rim_strength : hint_range(0.0, 2.0) = 0.28;
uniform float rim_start : hint_range(0.0, 1.0) = 0.55;
uniform float rim_softness : hint_range(0.001, 0.5) = 0.08;

void fragment() {
	vec3 normal = normalize(NORMAL);
	float lit = smoothstep(shade_threshold - shade_softness, shade_threshold + shade_softness,
			dot(normal, normalize(light_direction)));
	vec3 color = base_color * mix(shadow_tint, vec3(1.0), lit);

	float fresnel = 1.0 - clamp(dot(normal, normalize(VIEW)), 0.0, 1.0);
	float rim = smoothstep(rim_start, rim_start + rim_softness, fresnel);
	color += rim_color * rim * rim_strength * mix(0.35, 1.0, lit);

	ALBEDO = color;
}
