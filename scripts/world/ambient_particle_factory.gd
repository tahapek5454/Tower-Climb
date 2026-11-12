class_name AmbientParticleFactory
extends RefCounted
## Ortam parçacığı yayıcılarını kurar (AmbientParticles kullanır). Dokular kodla üretilir (dış dosya yok).
## Hepsi görüntüyü (+ pay) kaplayan dikdörtgenden doğar, ömür başında belirip sonunda söner
## (birden ortaya çıkmasınlar); açılışta ekran dolu olsun diye önceden işlenir (preprocess).

const DUST_COLOR := Color(1.0, 0.95, 0.85)
const SNOW_COLOR := Color(0.92, 0.95, 1.0)
const FIREFLY_COLOR := Color(0.80, 1.0, 0.45)
const LEAF_COLORS: Array[Color] = [Color(0.48, 0.64, 0.36), Color(0.62, 0.66, 0.34), Color(0.40, 0.55, 0.32)]
const LEAF_SIZE := Vector2i(18, 9)

static var _leaf_texture: Texture2D


## Işıkta süzülen toz zerreleri: küçük, soluk, toplamalı; yavaş rastgele süzülme.
static func dust() -> CPUParticles2D:
	var emitter: CPUParticles2D = _base(Tuning.AMBIENT_DUST_AMOUNT, 7.0)
	emitter.texture = SoftTextures.dot()
	emitter.material = SoftTextures.additive()
	emitter.direction = Vector2(0.0, -1.0)
	emitter.spread = 180.0
	emitter.initial_velocity_min = 4.0
	emitter.initial_velocity_max = 14.0
	emitter.gravity = Vector2(0.0, -3.0)
	emitter.scale_amount_min = 6.0 / SoftTextures.DOT_SIZE
	emitter.scale_amount_max = 13.0 / SoftTextures.DOT_SIZE
	emitter.color_ramp = _fade(DUST_COLOR, Tuning.AMBIENT_DUST_ALPHA, [0.0, 0.3, 0.7, 1.0])
	return emitter


## Uçuşan yapraklar: dönerek, rüzgârla yana savrularak yavaşça düşer.
static func leaves() -> CPUParticles2D:
	var emitter: CPUParticles2D = _base(Tuning.AMBIENT_LEAF_AMOUNT, 11.0)
	emitter.texture = _leaf()
	emitter.direction = Vector2(0.4, 1.0)
	emitter.spread = 35.0
	emitter.initial_velocity_min = 18.0
	emitter.initial_velocity_max = 40.0
	emitter.gravity = Vector2(10.0, 14.0)
	emitter.angle_min = 0.0
	emitter.angle_max = 360.0
	emitter.angular_velocity_min = -90.0
	emitter.angular_velocity_max = 90.0
	emitter.scale_amount_min = 1.0
	emitter.scale_amount_max = 1.6
	emitter.color_initial_ramp = _palette(LEAF_COLORS)
	emitter.color_ramp = _fade(Color.WHITE, 1.0, [0.0, 0.1, 0.85, 1.0])
	return emitter


## Kar: yavaş düşen, hafif rüzgârlı, farklı boyda yumuşak taneler.
static func snow() -> CPUParticles2D:
	var emitter: CPUParticles2D = _base(Tuning.AMBIENT_SNOW_AMOUNT, 12.0)
	emitter.texture = SoftTextures.dot()
	emitter.direction = Vector2(0.15, 1.0)
	emitter.spread = 15.0
	emitter.initial_velocity_min = 22.0
	emitter.initial_velocity_max = 50.0
	emitter.gravity = Vector2(6.0, 4.0)
	emitter.scale_amount_min = 8.0 / SoftTextures.DOT_SIZE
	emitter.scale_amount_max = 18.0 / SoftTextures.DOT_SIZE
	emitter.color_ramp = _fade(SNOW_COLOR, Tuning.AMBIENT_SNOW_ALPHA, [0.0, 0.1, 0.85, 1.0])
	return emitter


## Ateş böcekleri: yavaş, gelişigüzel süzülür; ömrü boyunca birkaç kez yanıp söner (toplamalı ışık).
static func fireflies() -> CPUParticles2D:
	var emitter: CPUParticles2D = _base(Tuning.AMBIENT_FIREFLY_AMOUNT, 6.0)
	emitter.texture = SoftTextures.dot()
	emitter.material = SoftTextures.additive()
	emitter.direction = Vector2(1.0, 0.0)
	emitter.spread = 180.0
	emitter.initial_velocity_min = 8.0
	emitter.initial_velocity_max = 22.0
	emitter.gravity = Vector2(0.0, -2.0)
	emitter.damping_min = 0.0
	emitter.damping_max = 2.0
	emitter.scale_amount_min = 18.0 / SoftTextures.DOT_SIZE
	emitter.scale_amount_max = 30.0 / SoftTextures.DOT_SIZE
	var blink := Gradient.new()
	blink.set_color(0, Color(FIREFLY_COLOR, 0.0))
	blink.set_color(1, Color(FIREFLY_COLOR, 0.0))
	var peak: float = Tuning.AMBIENT_FIREFLY_ALPHA
	for point: Vector2 in [Vector2(0.15, peak), Vector2(0.3, 0.1), Vector2(0.5, peak), Vector2(0.62, 0.15),
			Vector2(0.8, peak)]:
		blink.add_point(point.x, Color(FIREFLY_COLOR, point.y))
	emitter.color_ramp = blink
	return emitter


## Ortak ayarlar: görüntüyü (+ pay) kaplayan dikdörtgen, dünyada kalan parçacıklar, ön işleme.
static func _base(amount: int, lifetime: float) -> CPUParticles2D:
	var emitter := CPUParticles2D.new()
	emitter.amount = amount
	emitter.lifetime = lifetime
	emitter.preprocess = lifetime
	emitter.local_coords = false
	emitter.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	emitter.emission_rect_extents = Vector2(Tuning.VIEW_WIDTH, Tuning.VIEW_HEIGHT) * 0.5 \
			+ Vector2.ONE * Tuning.AMBIENT_VIEW_MARGIN
	emitter.randomness = 1.0
	return emitter


## Belirme/sönme rampası: alpha_points = [başlangıç, tam görünür, sönmeye başlama, bitiş] konumları.
static func _fade(color: Color, alpha: float, points: Array) -> Gradient:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(color, 0.0))
	gradient.set_color(1, Color(color, 0.0))
	gradient.add_point(points[1], Color(color, alpha))
	gradient.add_point(points[2], Color(color, alpha))
	return gradient


## Parçacık başına rastgele renk (rampadan rastgele bir nokta).
static func _palette(colors: Array[Color]) -> Gradient:
	var gradient := Gradient.new()
	gradient.set_color(0, colors[0])
	gradient.set_color(1, colors[colors.size() - 1])
	for i: int in range(1, colors.size() - 1):
		gradient.add_point(float(i) / (colors.size() - 1), colors[i])
	return gradient


## Yaprak dokusu: beyaz iç (parçacık rengiyle boyanır), koyu kenar ve orta damar.
static func _leaf() -> Texture2D:
	if _leaf_texture != null:
		return _leaf_texture
	var image := Image.create(LEAF_SIZE.x, LEAF_SIZE.y, false, Image.FORMAT_RGBA8)
	var half := Vector2(LEAF_SIZE) * 0.5
	for y: int in LEAF_SIZE.y:
		for x: int in LEAF_SIZE.x:
			var p: Vector2 = (Vector2(x, y) + Vector2(0.5, 0.5) - half) / (half - Vector2(0.5, 0.5))
			var d: float = p.x * p.x + p.y * p.y * (1.0 + 0.6 * p.x)
			if d > 1.0:
				continue
			var shade: float = 0.3 if d > 0.6 or (absf(p.y) < 0.15 and p.x < 0.7) else 1.0
			image.set_pixel(x, y, Color(shade, shade, shade, 1.0))
	_leaf_texture = ImageTexture.create_from_image(image)
	return _leaf_texture
