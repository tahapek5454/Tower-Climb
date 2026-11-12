shader_type canvas_item;
// Kule içi arka duvar: yumuşak köşeli taş bloklar (şaşırtmalı örgü), silik derzler,
// duvarlara doğru hafif kararma. Desen dünya koordinatına bağlıdır; dikdörtgen kamerayı
// takip etse de taşlar yerinde durur.

uniform vec4 stone_color : source_color = vec4(0.34, 0.37, 0.58, 1.0);
uniform vec4 joint_color : source_color = vec4(0.26, 0.28, 0.46, 1.0);
// Bir taş bloğun boyutu (px).
uniform vec2 block_size = vec2(128.0, 64.0);
uniform float corner_radius = 12.0;
uniform float joint_width = 4.0;
// Derz kenarının yumuşaklığı (px): büyük = daha silik.
uniform float joint_softness = 3.0;
// Bloklar arası parlaklık farkı (±oran).
uniform float block_variation = 0.05;
// Blok içinde üstten alta hafif kararma (kabartma hissi).
uniform float bevel_strength = 0.08;
// Kule iç genişliğinin yarısı (px) ve duvar dibindeki gölge.
uniform float half_width = 448.0;
uniform float edge_shade_width = 150.0;
uniform float edge_shade_strength = 0.28;

varying vec2 world_pos;


float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}


void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}


void fragment() {
	vec2 p = world_pos / block_size;
	// Her ikinci sıra yarım blok kayar.
	p.x += 0.5 * mod(floor(p.y), 2.0);
	vec2 cell = floor(p);
	vec2 local = (fract(p) - 0.5) * block_size;

	// Yuvarlak köşeli dikdörtgen uzaklığı: içeride negatif.
	vec2 half_size = block_size * 0.5 - vec2(joint_width * 0.5);
	vec2 q = abs(local) - half_size + corner_radius;
	float dist = length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - corner_radius;
	float inside = 1.0 - smoothstep(-joint_softness, joint_softness, dist);

	vec3 stone = stone_color.rgb * (1.0 + (hash(cell) - 0.5) * 2.0 * block_variation);
	stone *= 1.0 - (local.y / block_size.y) * bevel_strength;
	vec3 color = mix(joint_color.rgb, stone, inside);

	float edge = 1.0 - smoothstep(0.0, edge_shade_width, half_width - abs(world_pos.x));
	color *= 1.0 - edge * edge_shade_strength;

	COLOR = vec4(color, 1.0);
}
