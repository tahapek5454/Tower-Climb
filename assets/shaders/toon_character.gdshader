shader_type spatial;
// Karakter için çizgi film gölgelemesi: iki tonlu ışık + kenar ışığı (rim).
// Işık sahneden değil, kamera uzayındaki sabit bir yönden gelir: model dönse de ışık aynı kalır.
render_mode unshaded;

uniform sampler2D albedo_texture : source_color, filter_linear_mipmap;
// Doku parlaklık çarpanı: bake edilen beyazlar biraz soluk; kafa temiz beyaz görünsün.
uniform float albedo_gain = 1.18;
// Kamera uzayında ışığın geldiği yön (+X sağ, +Y yukarı, +Z kameraya doğru).
uniform vec3 light_direction = vec3(-0.35, 0.75, 0.55);
// Gölgede kalan yüzeyin rengi bununla çarpılır.
uniform vec3 shadow_tint : source_color = vec3(0.62, 0.64, 0.80);
// Aydınlık/gölge sınırı (-1..1) ve sınırın yumuşaklığı.
uniform float shade_threshold : hint_range(-1.0, 1.0) = -0.1;
uniform float shade_softness : hint_range(0.001, 0.5) = 0.04;
// Çok koyu renkleri hafifçe açar: siyah parçalar koyu zeminde kaybolmasın.
uniform vec3 dark_lift : source_color = vec3(0.10, 0.11, 0.16);
// Kenar ışığı: silüetin kenarlarında açık renkli şerit.
uniform vec3 rim_color : source_color = vec3(0.75, 0.85, 1.0);
uniform float rim_strength : hint_range(0.0, 2.0) = 0.55;
uniform float rim_start : hint_range(0.0, 1.0) = 0.55;
uniform float rim_softness : hint_range(0.001, 0.5) = 0.08;

void fragment() {
	vec3 base = texture(albedo_texture, UV).rgb;
	base = max(min(base * albedo_gain, vec3(1.0)), dark_lift);

	vec3 normal = normalize(NORMAL);
	float lit = smoothstep(shade_threshold - shade_softness, shade_threshold + shade_softness,
			dot(normal, normalize(light_direction)));
	vec3 color = base * mix(shadow_tint, vec3(1.0), lit);

	float fresnel = 1.0 - clamp(dot(normal, normalize(VIEW)), 0.0, 1.0);
	float rim = smoothstep(rim_start, rim_start + rim_softness, fresnel);
	// Kenar ışığı aydınlık tarafta güçlü, gölge tarafta zayıf.
	color += rim_color * rim * rim_strength * mix(0.35, 1.0, lit);

	ALBEDO = color;
}
