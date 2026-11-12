shader_type canvas_item;
// Kule dışı (duvarların arkası): gökyüzü gradyanı, iki kat uzak tepe silueti, iki kat bulut.
// Parallax: her katman kameranın hareketinin bir oranıyla (factor) kayar; 1 = platformlarla aynı,
// 0 = ekrana sabit. Kamera konumu çizim matrisinden okunur (pencere ölçeğinden bağımsız, gecikmesiz).
// Tepeler başlangıçta ekranın altında görünür, tırmandıkça yavaşça aşağı batar.

uniform vec4 sky_top : source_color = vec4(0.36, 0.45, 0.62, 1.0);
uniform vec4 sky_bottom : source_color = vec4(0.60, 0.66, 0.77, 1.0);
uniform vec4 hill_far_color : source_color = vec4(0.48, 0.55, 0.70, 1.0);
uniform vec4 hill_near_color : source_color = vec4(0.36, 0.43, 0.58, 1.0);
uniform vec4 cloud_color : source_color = vec4(0.80, 0.84, 0.90, 1.0);
uniform vec4 cloud_shade_color : source_color = vec4(0.67, 0.72, 0.82, 1.0);

uniform float view_height = 720.0;
// Başlangıçta ekranın üst kenarının dünya y'si ve zeminin ekrandaki y'si.
uniform float rest_top = -648.0;
uniform float ground_view_y = 648.0;

uniform float hill_far_factor = 0.04;
uniform float hill_near_factor = 0.09;
uniform float cloud_far_factor = 0.22;
uniform float cloud_near_factor = 0.45;

// Tepeler: zeminin ne kadar üstünde başladıkları ve ortalama yükseklikleri (px).
uniform float hill_far_height = 190.0;
uniform float hill_near_height = 110.0;
// Bulut ızgarası: hücre boyutu, bir hücrede bulut olma olasılığı, yatay sürüklenme hızı (px/s).
uniform vec2 cloud_cell = vec2(250.0, 210.0);
uniform float cloud_density = 0.55;
uniform float cloud_drift_speed = 6.0;
// Uzak bulutların gökyüzüne karışma oranı (atmosfer).
uniform float cloud_far_fade = 0.45;
// Siluet kenarlarının yumuşatma yarı genişliği (dünya px).
uniform float edge_softness = 0.7;

varying vec2 world_pos;
varying float view_top;


float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}


// Keskin ama kırık olmayan kenar (yaklaşık 1 px yumuşatma). fwidth kullanılmaz: bulut ızgarasının
// hücre sınırında uzaklık sıçradığı için orada ince bir çizgi bırakıyordu.
float fill(float dist) {
	return 1.0 - smoothstep(-edge_softness, edge_softness, dist);
}


float circle(vec2 p, vec2 c, float r) {
	return length(p - c) - r;
}


float round_box(vec2 p, vec2 c, vec2 half_size, float r) {
	vec2 q = abs(p - c) - half_size + r;
	return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}


// Katman koordinatı: başlangıçta ekran koordinatı, kamera kaydıkça factor oranında kayar.
vec2 layer(float factor) {
	float view_y = world_pos.y - view_top;
	return vec2(world_pos.x, view_y + (view_top - rest_top) * factor);
}


// Tepe silueti: yumuşak, kıvrımlı sinüs toplamı. Dönüş: siluetin içindeyse negatif uzaklık.
float hills(vec2 p, float height, float seed) {
	float h = height
			+ sin(p.x * 0.0047 + seed) * height * 0.35
			+ sin(p.x * 0.0113 + seed * 2.3) * height * 0.18
			+ sin(p.x * 0.0261 + seed * 0.7) * height * 0.06;
	return (ground_view_y - h) - p.y;
}


// Bir bulut katmanı: rgb = renk, a = örtme. size: bulut boyu çarpanı.
vec4 clouds(vec2 p, float size, float seed) {
	p.x += TIME * cloud_drift_speed * size;
	vec2 cell = floor(p / cloud_cell);
	vec2 local = p - (cell + 0.5) * cloud_cell;
	float h0 = hash(cell + seed);
	if (h0 > cloud_density) {
		return vec4(0.0);
	}
	float h1 = hash(cell + seed + 17.0);
	float h2 = hash(cell + seed + 31.0);
	float w = mix(90.0, 150.0, h1) * size;
	float r = w * 0.27;
	// Bulut hücreden taşmasın (taşan kısım hücre sınırında kesik görünür): yatayda en geniş yer
	// kutunun yarısı (w/2), dikeyde tabandan en üst daireye kadar ~2,05 r.
	vec2 half_cell = cloud_cell * 0.5 - 2.0;
	float max_x = max(half_cell.x - w * 0.5, 0.0);
	float min_y = -half_cell.y + r * 2.05;
	vec2 base = vec2(mix(-max_x, max_x, h2),
			mix(min(min_y, half_cell.y), half_cell.y, hash(cell + seed + 7.0)));
	float d = round_box(local, base + vec2(0.0, -r * 0.35), vec2(w * 0.5, r * 0.35), r * 0.35);
	d = min(d, circle(local, base + vec2(-w * 0.2, -r * 0.75), r * 0.8));
	d = min(d, circle(local, base + vec2(w * 0.08, -r * 1.05), r));
	d = min(d, circle(local, base + vec2(w * 0.3, -r * 0.6), r * 0.65));
	float shade = step(base.y - r * 0.3, local.y);
	vec3 color = mix(cloud_color.rgb, cloud_shade_color.rgb, shade);
	return vec4(color, fill(d));
}


void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
	// Görüntünün sol üst köşesinin dünya konumu (kamera + sarsıntı dahil).
	view_top = (inverse(CANVAS_MATRIX) * vec4(0.0, 0.0, 0.0, 1.0)).y;
}


void fragment() {
	float view_t = clamp((world_pos.y - view_top) / view_height, 0.0, 1.0);
	vec3 color = mix(sky_top.rgb, sky_bottom.rgb, view_t);

	vec4 far_clouds = clouds(layer(cloud_far_factor), 0.7, 3.0);
	color = mix(color, mix(far_clouds.rgb, color, cloud_far_fade), far_clouds.a);

	color = mix(color, hill_far_color.rgb, fill(hills(layer(hill_far_factor), hill_far_height, 1.3)));
	color = mix(color, hill_near_color.rgb, fill(hills(layer(hill_near_factor), hill_near_height, 4.1)));

	vec4 near_clouds = clouds(layer(cloud_near_factor), 1.0, 11.0);
	color = mix(color, near_clouds.rgb, near_clouds.a);

	COLOR = vec4(color, 1.0);
}
