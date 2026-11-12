class_name PlatformDecor
extends RefCounted
## Platform süsleri (sadece görüntü; oynanışa etkisi yok). Temaya göre seçilir.
## "Arka" süsler platformun altından sarkar ve platformdan önce çizilir (gövdenin arkasında kalır):
## sarmaşık, kök, fener, buz saçağı. "Ön" süsler üst yüzeydedir ve platformdan sonra çizilir:
## çimen, çiçek, yosun, mantar, kar, kristal filizi. Ön süsler ayakların bastığı yeri kapatmasın diye
## sadece uçlara yakın ve kısadır.
## Işık veren süsler (fener, kristal filizi) konumlarını `lights` dizisine ekler: [konum, boyut, renk]
## (PlatformGlow çizer).

const BEHIND: Array[StringName] = [&"vines", &"roots", &"lanterns", &"icicles"]
## Her temanın süsleri (WorldPalette tema sırasıyla).
const THEME_DECOR: Array[Array] = [
	[&"vines", &"grass", &"flowers"],
	[&"moss", &"mushrooms", &"vines", &"roots"],
	[&"lanterns", &"vines", &"grass"],
	[&"snow", &"icicles"],
	[&"crystals", &"lanterns", &"vines"],
]
## Stilin zaten içerdiği süs (tekrar olmasın): stil -> süs.
const REDUNDANT: Dictionary = {&"snowdrift": &"snow", &"ice": &"icicles", &"crystal": &"crystals"}
## Süslerin üst yüzeyden taşabileceği en büyük yükseklik (px) ve uçlardan içeri alan (px).
const FRONT_MAX_HEIGHT: float = 14.0
const END_ZONE: float = 26.0

const GRASS := Color(0.42, 0.58, 0.36)
const GRASS_DARK := Color(0.30, 0.45, 0.28)
const FLOWER := Color(0.86, 0.78, 0.86)
const MOSS := Color(0.40, 0.56, 0.34)
const ROOT := Color(0.40, 0.31, 0.25)
const MUSHROOM_CAP := Color(0.70, 0.42, 0.48)
const MUSHROOM_STEM := Color(0.86, 0.83, 0.76)
const LANTERN := Color(0.92, 0.76, 0.50)
const LANTERN_FRAME := Color(0.24, 0.20, 0.24)
const SNOW := Color(0.88, 0.92, 0.96)
const ICICLE := Color(0.74, 0.86, 0.94)
## Kristal filizi: mor platformlarda kaybolmasın diye camgöbeği (Gece'nin vurgu rengi).
const CRYSTAL := Color(0.60, 0.86, 0.92)


## Platformun süsleri (saf): tema listesinden, stilin zaten içerdiği süs çıkarılarak, rng ile.
## Olasılıklar Tuning.PLATFORM_DECOR_CHANCE / PLATFORM_DECOR_SECOND_CHANCE.
static func pick(theme: int, style: StringName, rng: RandomNumberGenerator) -> Array[StringName]:
	var result: Array[StringName] = []
	if rng.randf() >= Tuning.PLATFORM_DECOR_CHANCE:
		return result
	var options: Array[StringName] = []
	for kind: StringName in THEME_DECOR[posmod(theme, THEME_DECOR.size())]:
		if REDUNDANT.get(style, &"") != kind:
			options.append(kind)
	if options.is_empty():
		return result
	var first: int = rng.randi_range(0, options.size() - 1)
	result.append(options[first])
	if options.size() > 1 and rng.randf() < Tuning.PLATFORM_DECOR_SECOND_CHANCE:
		result.append(options[(first + rng.randi_range(1, options.size() - 1)) % options.size()])
	return result


## Arka süsler (platform gövdesinden önce çağrılır).
static func draw_behind(canvas: CanvasItem, width: float, kinds: Array[StringName],
		rng: RandomNumberGenerator, lights: Array = []) -> void:
	for kind: StringName in kinds:
		match kind:
			&"vines": _vines(canvas, width, rng, GRASS_DARK, true)
			&"roots": _vines(canvas, width, rng, ROOT, false)
			&"lanterns": _lanterns(canvas, width, rng, lights)
			&"icicles": _icicles(canvas, width, rng)


## Ön süsler (platform gövdesinden sonra çağrılır).
static func draw_front(canvas: CanvasItem, width: float, kinds: Array[StringName],
		rng: RandomNumberGenerator, lights: Array = []) -> void:
	for kind: StringName in kinds:
		match kind:
			&"grass": _at_ends(canvas, width, rng, PlatformDecor._grass)
			&"flowers": _at_ends(canvas, width, rng, PlatformDecor._flower)
			&"moss": _moss(canvas, width, rng)
			&"mushrooms": _at_ends(canvas, width, rng, PlatformDecor._mushroom)
			&"snow": _snow(canvas, width, rng)
			&"crystals":
				for base: Vector2 in _at_ends(canvas, width, rng, PlatformDecor._crystal_sprout):
					lights.append([base + Vector2(0.0, -6.0), Tuning.LIGHT_CRYSTAL_SIZE,
							Color(CRYSTAL, Tuning.LIGHT_CRYSTAL_ALPHA)])


## Bir ya da iki uçta, uca yakın rastgele bir noktada çizer; çizilen noktaları döndürür.
static func _at_ends(canvas: CanvasItem, width: float, rng: RandomNumberGenerator,
		painter: Callable) -> Array[Vector2]:
	var bases: Array[Vector2] = []
	var sides: Array[float] = [-1.0, 1.0]
	if rng.randf() >= 0.4:
		sides = [1.0 if rng.randf() < 0.5 else -1.0]
	for side: float in sides:
		var x: float = (width * 0.5 - rng.randf_range(6.0, minf(END_ZONE, width * 0.3))) * side
		painter.call(canvas, Vector2(x, 0.5), rng)
		bases.append(Vector2(x, 0.5))
	return bases


static func _grass(canvas: CanvasItem, base: Vector2, rng: RandomNumberGenerator) -> void:
	for i: int in rng.randi_range(4, 7):
		var root: Vector2 = base + Vector2(rng.randf_range(-7.0, 7.0), 0.0)
		var tip: Vector2 = root + Vector2(rng.randf_range(-3.0, 3.0), -rng.randf_range(5.0, FRONT_MAX_HEIGHT - 2.0))
		canvas.draw_line(root, tip, PlatformDraw.OUTLINE_COLOR, 4.0, true)
		canvas.draw_line(root, tip, GRASS if i % 2 == 0 else GRASS_DARK, 2.4, true)


static func _flower(canvas: CanvasItem, base: Vector2, rng: RandomNumberGenerator) -> void:
	_grass(canvas, base, rng)
	var head: Vector2 = base + Vector2(rng.randf_range(-2.0, 2.0), -FRONT_MAX_HEIGHT + 2.0)
	canvas.draw_circle(head, 4.4, PlatformDraw.OUTLINE_COLOR, true, -1.0, true)
	canvas.draw_circle(head, 3.3, FLOWER, true, -1.0, true)
	canvas.draw_circle(head, 1.4, LANTERN, true, -1.0, true)


static func _mushroom(canvas: CanvasItem, base: Vector2, rng: RandomNumberGenerator) -> void:
	var height: float = rng.randf_range(7.0, FRONT_MAX_HEIGHT - 3.0)
	var stem := PlatformDraw.rounded_rect(Rect2(base + Vector2(-2.2, -height), Vector2(4.4, height)), 1.8)
	PlatformDraw.shape(canvas, stem, MUSHROOM_STEM, 1.1)
	var cap_center: Vector2 = base + Vector2(0.0, -height)
	var cap := PlatformDraw.arc(cap_center, rng.randf_range(6.0, 8.0), PI, TAU, 8)
	PlatformDraw.shape(canvas, cap, MUSHROOM_CAP, 1.2)
	canvas.draw_circle(cap_center + Vector2(-1.5, -2.5), 1.0, MUSHROOM_STEM, true, -1.0, true)


static func _crystal_sprout(canvas: CanvasItem, base: Vector2, rng: RandomNumberGenerator) -> void:
	for i: int in rng.randi_range(2, 3):
		var root: Vector2 = base + Vector2((i - 1) * 5.0, 0.0)
		var height: float = rng.randf_range(8.0, FRONT_MAX_HEIGHT + 2.0) * (1.0 if i == 1 else 0.7)
		var lean: float = (i - 1) * 2.5
		var shard := PackedVector2Array([root + Vector2(-3.0, 0.0), root + Vector2(lean, -height),
				root + Vector2(3.0, 0.0)])
		PlatformDraw.shape(canvas, shard, CRYSTAL.lightened(0.1 * i), 1.1)


## Yosun: üst kenarın üstüne serilen, kenardan hafifçe sarkan yumuşak tümsekler (bir bölümde).
static func _moss(canvas: CanvasItem, width: float, rng: RandomNumberGenerator) -> void:
	var span: float = rng.randf_range(0.25, 0.5) * width
	var start: float = rng.randf_range(-width * 0.5 + 4.0, width * 0.5 - span - 4.0)
	var x: float = start
	while x < start + span:
		var radius: float = rng.randf_range(3.0, 5.0)
		canvas.draw_circle(Vector2(x, 1.0), radius + 1.2, PlatformDraw.OUTLINE_COLOR, true, -1.0, true)
		x += radius * 1.3
	x = start
	while x < start + span:
		var radius: float = rng.randf_range(3.0, 5.0)
		canvas.draw_circle(Vector2(x, 1.0), radius, MOSS if int(x) % 3 != 0 else GRASS, true, -1.0, true)
		x += radius * 1.3


## Kar: üst yüzeyin bir bölümünü örten, alt kenarı dalgalı ince kar örtüsü.
static func _snow(canvas: CanvasItem, width: float, rng: RandomNumberGenerator) -> void:
	var span: float = rng.randf_range(0.4, 0.85) * width
	var start: float = rng.randf_range(-width * 0.5 + 2.0, width * 0.5 - span - 2.0)
	var steps: int = maxi(3, int(span / 12.0))
	var points := PackedVector2Array()
	for i: int in steps + 1:
		var bump: float = -1.0 if i == 0 or i == steps else -rng.randf_range(1.5, 3.0)
		points.append(Vector2(start + span * float(i) / steps, bump))
	for i: int in range(steps, -1, -1):
		points.append(Vector2(start + span * float(i) / steps, rng.randf_range(2.5, 5.5)))
	PlatformDraw.shape(canvas, points, SNOW, 1.3)


## Sarmaşık / kök: platformun altından sarkan dalgalı ince dallar; sarmaşıkta yapraklar.
static func _vines(canvas: CanvasItem, width: float, rng: RandomNumberGenerator, color: Color,
		leaves: bool) -> void:
	for i: int in rng.randi_range(1, 3):
		var x: float = rng.randf_range(-width * 0.5 + 10.0, width * 0.5 - 10.0)
		var length: float = rng.randf_range(26.0, 60.0)
		var phase: float = rng.randf_range(0.0, TAU)
		var points := PackedVector2Array()
		for step: int in int(length / 4.0) + 1:
			var y: float = 8.0 + step * 4.0
			points.append(Vector2(x + sin(phase + step * 0.7) * 2.5, y))
		canvas.draw_polyline(points, PlatformDraw.OUTLINE_COLOR, 4.4, true)
		canvas.draw_polyline(points, color, 2.6, true)
		if leaves:
			for step: int in range(2, points.size(), 2):
				var side: float = 1.0 if step % 4 == 0 else -1.0
				var leaf := PlatformDraw.ellipse(points[step] + Vector2(4.0 * side, 0.0), Vector2(4.4, 2.8), 8)
				PlatformDraw.shape(canvas, leaf, GRASS, 1.0)


## Fener: platformun altına iple asılı küçük sıcak renkli fener (ışığı madde 7'de).
static func _lanterns(canvas: CanvasItem, width: float, rng: RandomNumberGenerator, lights: Array) -> void:
	var count: int = 1 if width < 200.0 or rng.randf() < 0.6 else 2
	for i: int in count:
		var x: float = rng.randf_range(-width * 0.35, width * 0.35) if count == 1 \
				else (width * 0.28) * (1.0 if i == 0 else -1.0)
		var top := Vector2(x, 10.0)
		var body_top: Vector2 = top + Vector2(0.0, rng.randf_range(10.0, 20.0))
		canvas.draw_line(top, body_top, LANTERN_FRAME, 1.4, true)
		var body := PlatformDraw.rounded_rect(Rect2(body_top + Vector2(-6.5, 0.0), Vector2(13.0, 15.0)), 4.0)
		PlatformDraw.shape(canvas, body, LANTERN, 1.4)
		PlatformDraw.shape(canvas, PlatformDraw.rounded_rect(
				Rect2(body_top + Vector2(-7.5, -2.0), Vector2(15.0, 4.0)), 1.5), LANTERN_FRAME)
		canvas.draw_circle(body_top + Vector2(-2.0, 5.5), 2.0, LANTERN.lightened(0.5), true, -1.0, true)
		lights.append([body_top + Vector2(0.0, 7.5), Tuning.LIGHT_LANTERN_SIZE,
				Color(LANTERN, Tuning.LIGHT_LANTERN_ALPHA)])


## Buz saçakları: platformun altından sarkan ince sivri buzlar.
static func _icicles(canvas: CanvasItem, width: float, rng: RandomNumberGenerator) -> void:
	var x: float = -width * 0.5 + rng.randf_range(10.0, 24.0)
	while x < width * 0.5 - 10.0:
		var length: float = rng.randf_range(6.0, 18.0)
		var half: float = rng.randf_range(2.5, 4.5)
		var y: float = Tuning.PLATFORM_THICKNESS - 6.0
		PlatformDraw.shape(canvas, PackedVector2Array([Vector2(x - half, y), Vector2(x + half, y),
				Vector2(x, y + length + 6.0)]), ICICLE, 1.2)
		x += rng.randf_range(16.0, 40.0)
