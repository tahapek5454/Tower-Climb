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

// --- Kıyafet boyama (mağaza kozmetikleri; CosmeticPaint ayarlar) ---
// Bölge maskesi: R = tişört, G = pantolon. Konum haritası: dinlenme pozundaki model uzayı konumu
// (Blender ekseni: +X sol, -Y ön, +Z yukarı) → desenler dikişte kırılmaz, animasyonda kaymaz.
uniform sampler2D cosmetic_mask : hint_default_black, filter_linear;
uniform sampler2D rest_position : hint_default_black, filter_linear;
uniform vec3 position_min = vec3(-0.40, -0.32, -0.02);
uniform vec3 position_size = vec3(0.80, 0.64, 1.12);
uniform bool shirt_enabled = false;
uniform vec3 shirt_color : source_color = vec3(0.36, 0.38, 0.42);
uniform vec3 shirt_color2 : source_color = vec3(0.36, 0.38, 0.42);
// 0 düz, 1 yatay çizgi, 2 puantiye, 3 göğüste yıldız.
uniform int shirt_pattern = 0;
uniform bool pants_enabled = false;
uniform vec3 pants_color : source_color = vec3(0.16, 0.17, 0.20);
// Dokudaki özgün kumaş tonu (doğrusal parlaklık): kıvrım/gölge tonlaması buna oranla korunur.
uniform float shirt_reference = 0.30;
uniform float pants_reference = 0.133;
// Kıvrım tonlamasının belirginliği: özgün parlaklık oranının üssü (0 = düz boya; ~0,45 = dokudaki kadar;
// doku çok düz olduğu için biraz abartılır).
uniform float fold_contrast = 0.75;
uniform float stripe_period = 0.075;
uniform float stripe_fill = 0.45;
uniform float dot_spacing = 0.072;
uniform float dot_radius = 0.021;
uniform vec2 star_center = vec2(0.0, 0.535);
uniform float star_radius = 0.105;

float luminance(vec3 c) {
	return dot(c, vec3(0.2126, 0.7152, 0.0722));
}

// Kumaşın kıvrım tonlaması: özgün parlaklığın referansa oranı.
float fold_shade(vec3 original, float reference) {
	return clamp(pow(max(luminance(original), 0.0001) / reference, fold_contrast), 0.6, 1.25);
}

// Beş köşeli yıldızın işaretli uzaklığı (iq).
float star_sdf(vec2 p, float r) {
	const float rf = 0.45;
	const vec2 k1 = vec2(0.809016994375, -0.587785252292);
	const vec2 k2 = vec2(-k1.x, k1.y);
	p.x = abs(p.x);
	p -= 2.0 * max(dot(k1, p), 0.0) * k1;
	p -= 2.0 * max(dot(k2, p), 0.0) * k2;
	p.x = abs(p.x);
	p.y -= r;
	vec2 ba = rf * vec2(-k1.y, k1.x) - vec2(0.0, 1.0);
	float h = clamp(dot(p, ba) / dot(ba, ba), 0.0, r);
	return length(p - ba * h) * sign(p.y * ba.x - p.x * ba.y);
}

// İkinci rengin ağırlığı (0..1); kenarlar ekran pikseline göre yumuşatılır.
float pattern_weight(vec3 pos) {
	if (shirt_pattern == 1) {
		float s = abs(fract(pos.z / stripe_period) - 0.5) * stripe_period;
		float w = max(fwidth(pos.z), 0.002);
		return 1.0 - smoothstep(stripe_fill * stripe_period * 0.5 - w, stripe_fill * stripe_period * 0.5 + w, s);
	}
	if (shirt_pattern == 2) {
		// Gövde ekseni etrafında açıyı yay uzunluğuna çevir (dikiş sırtta), satırlar kaydırmalı.
		vec2 uv = vec2(atan(pos.x, -pos.y) * 0.17, pos.z);
		float row = floor(uv.y / dot_spacing);
		uv.x += mod(row, 2.0) * dot_spacing * 0.5;
		vec2 cell = (fract(uv / dot_spacing) - 0.5) * dot_spacing;
		float d = length(cell) - dot_radius;
		float w = max(fwidth(uv.y), 0.002);
		return 1.0 - smoothstep(-w, w, d);
	}
	if (shirt_pattern == 3) {
		vec2 p = vec2(pos.x, pos.z) - star_center;
		float d = star_sdf(p, star_radius);
		float w = max(fwidth(pos.z), 0.002);
		// Yalnız göğüste (önde): sırtta görünmesin.
		float front = 1.0 - smoothstep(-0.02, 0.04, pos.y);
		return (1.0 - smoothstep(-w, w, d)) * front;
	}
	return 0.0;
}

vec3 apply_cosmetics(vec3 shaded, vec3 original, vec2 uv) {
	if (!shirt_enabled && !pants_enabled) {
		return shaded;
	}
	vec2 mask = texture(cosmetic_mask, uv).rg;
	vec3 result = shaded;
	if (shirt_enabled && mask.r > 0.001) {
		vec3 pos = position_min + texture(rest_position, uv).rgb * position_size;
		vec3 cloth = mix(shirt_color, shirt_color2, pattern_weight(pos));
		result = mix(result, cloth * fold_shade(original, shirt_reference), mask.r);
	}
	if (pants_enabled && mask.g > 0.001) {
		result = mix(result, pants_color * fold_shade(original, pants_reference), mask.g);
	}
	return result;
}

void fragment() {
	vec3 original = texture(albedo_texture, UV).rgb;
	vec3 base = max(min(original * albedo_gain, vec3(1.0)), dark_lift);
	base = apply_cosmetics(base, original, UV);

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
