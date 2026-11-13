class_name PlatformTypeArt
extends Node2D
## Platform türünün işaretleri (her temada tanınsın diye platform görüntüsünün üstüne çizilir).
## Çatlayan: üst yüzeyden inen zarif çatlaklar (basınca büyür). Buz: parlak, kenarlardan taşan buz
## tabakası + ara sıra üstünden kayan parıltı. Kayan: uçlarda küçük oklar (gittiği yönde parlar) ve
## behind katmanında, platformun arkasında hareket aralığı boyunca ince ray.

const OUTLINE := PlatformDraw.OUTLINE_COLOR
const ICE_COLOR := Color(0.84, 0.95, 1.0)
const ICE_SHADE := Color(0.56, 0.76, 0.92)
const HINT_COLOR := Color(0.88, 0.91, 0.97)
## Buz tabakası: üst ve alt kenar (px, yüzeye göre), kenarlardan taşma, platform rengiyle karışım.
const ICE_TOP: float = -2.5
const ICE_BOTTOM: float = 6.5
const ICE_OVERHANG: float = 2.5
const ICE_TINT: float = 0.88
## Buzun üstündeki soğuk, yumuşak ışık (her temada ayırt edilsin diye) ve hafif nabzı.
const ICE_GLOW_COLOR := Color(0.7, 0.9, 1.0)
const ICE_GLOW_ALPHA: float = 0.3
const ICE_GLOW_HEIGHT: float = 34.0
## Çatlak: kaç px'te bir çatlak, kalınlık.
const CRACK_SPACING: float = 78.0
const CRACK_WIDTH: float = 2.8

## Çatlakların görünen oranı (0..1); çatlayan platform basınca 1'e büyür.
var crack_progress: float = 0.0
var _platform: Platform
var _behind: bool = false
var _kind: StringName
var _width: float = 0.0
var _seed: int = 0
## Çatlaklar: her biri yukarıdan aşağı nokta listesi; dallar ayrı.
var _cracks: Array[PackedVector2Array] = []
var _branches: Array[PackedVector2Array] = []
var _drips: Array[Vector3] = []
var _time: float = 0.0
var _ice_glow: Sprite2D


func setup(platform: Platform, behind: bool) -> void:
	_platform = platform
	_behind = behind
	_kind = platform.kind
	_width = platform.width
	_seed = platform.floor_number
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(_seed * 977 + 3)
	_time = rng.randf() * Tuning.PLATFORM_ICE_GLINT_INTERVAL
	match _kind:
		PlatformTypeRules.CRUMBLE: _make_cracks(rng)
		PlatformTypeRules.ICE:
			_make_drips(rng)
			if not behind:
				add_child(_make_ice_glow())


## Çatlakların başladığı x'ler (parçalanma bu çizgilerden olur).
func cracks() -> Array[PackedVector2Array]:
	return _cracks


func _process(delta: float) -> void:
	if _kind == PlatformTypeRules.ICE or _kind == PlatformTypeRules.MOVING:
		_time += delta
		queue_redraw()
	if _ice_glow != null:
		_ice_glow.modulate.a = ICE_GLOW_ALPHA * (0.8 + 0.2 * sin(_time * 2.2))


func _draw() -> void:
	match _kind:
		PlatformTypeRules.CRUMBLE: _draw_cracks()
		PlatformTypeRules.ICE: _draw_ice()
		PlatformTypeRules.MOVING:
			if _behind:
				_draw_rail()
			else:
				_draw_arrows()


# --- Çatlayan ---

func _make_cracks(rng: RandomNumberGenerator) -> void:
	var count: int = clampi(roundi(_width / CRACK_SPACING), 2, 6)
	var span: float = _width - 36.0
	for i: int in count:
		var x: float = -span * 0.5 + span * (i + 0.5) / count + rng.randf_range(-8.0, 8.0)
		var path := PackedVector2Array([Vector2(x, 0.0)])
		var depth: float = Tuning.PLATFORM_THICKNESS + rng.randf_range(-3.0, 2.0)
		# Zikzak: her adımda yön değişir (kırık taş çizgisi).
		var steps: int = 4
		var zig: float = -1.0 if rng.randf() < 0.5 else 1.0
		for s: int in steps:
			x += zig * rng.randf_range(3.0, 6.0)
			zig = -zig
			path.append(Vector2(x, depth * (s + 1) / steps))
		_cracks.append(path)
		var root: Vector2 = path[2]
		var side: float = -1.0 if rng.randf() < 0.5 else 1.0
		_branches.append(PackedVector2Array([root,
				root + Vector2(side * rng.randf_range(6.0, 10.0), rng.randf_range(3.0, 5.0)),
				root + Vector2(side * rng.randf_range(11.0, 16.0), rng.randf_range(6.0, 9.0))]))


func _draw_cracks() -> void:
	var idle: float = Tuning.PLATFORM_CRACK_IDLE_LENGTH
	var length: float = lerpf(idle, 1.0, crack_progress)
	var alpha: float = lerpf(0.78, 0.95, crack_progress)
	var light: Color = Color(_platform.theme_color().lightened(0.35), 0.5 * alpha)
	for path: PackedVector2Array in _cracks:
		var visible_path: PackedVector2Array = _partial(path, length)
		if visible_path.size() < 2:
			continue
		# Yukarıda geniş, aşağı doğru incelen yarık; sağında ışık alan ince açık kenar.
		_polyline(_shifted(visible_path, Vector2(2.2, 0.8)), light, 1.4)
		draw_colored_polygon(_wedge(visible_path, CRACK_WIDTH * 2.2), Color(OUTLINE, alpha))
	var branch_length: float = lerpf(0.45, 1.0, crack_progress)
	if branch_length > 0.0:
		for branch: PackedVector2Array in _branches:
			_polyline(_partial(branch, branch_length), Color(OUTLINE, alpha * 0.9), CRACK_WIDTH * 0.75)


# --- Buz ---

func _make_drips(rng: RandomNumberGenerator) -> void:
	var x: float = -_width * 0.5 + rng.randf_range(12.0, 26.0)
	while x < _width * 0.5 - 12.0:
		_drips.append(Vector3(x, rng.randf_range(2.5, 4.5), rng.randf_range(3.5, 8.0)))
		x += rng.randf_range(26.0, 58.0)


func _draw_ice() -> void:
	var base: Color = _platform.theme_color()
	var fill: Color = base.lerp(ICE_COLOR, ICE_TINT).lightened(0.12)
	var shade: Color = base.lerp(ICE_SHADE, ICE_TINT)
	var left: float = -_width * 0.5 - ICE_OVERHANG
	var sheet_width: float = _width + ICE_OVERHANG * 2.0
	var sheet := PlatformDraw.rounded_rect(Rect2(left, ICE_TOP, sheet_width, ICE_BOTTOM - ICE_TOP), 4.0)
	# Damlalar: önce koyu dış çizgili, sonra tabakanın dolgusu birleşme çizgisini örter.
	for drip: Vector3 in _drips:
		var drop := _drip_points(drip)
		PlatformDraw.shape(self, drop, shade, 1.4)
	PlatformDraw.shape(self, sheet, fill, 1.6)
	for drip: Vector3 in _drips:
		draw_rect(Rect2(drip.x - drip.y + 1.2, ICE_BOTTOM - 2.0, drip.y * 2.0 - 2.4, 2.8), shade)
	# Alt yarı hafif koyu (kalınlık hissi), üstte parlak çizgi.
	draw_rect(Rect2(left + 3.0, ICE_BOTTOM - 3.2, sheet_width - 6.0, 2.0), shade)
	var gloss := Color(1.0, 1.0, 1.0, 0.85)
	var gx: float = left + 6.0
	var segment: int = 0
	while gx < left + sheet_width - 10.0:
		var length: float = 22.0 if segment % 3 != 2 else 7.0
		var end_x: float = minf(gx + length, left + sheet_width - 6.0)
		draw_line(Vector2(gx, ICE_TOP + 1.8), Vector2(end_x, ICE_TOP + 1.8), gloss, 1.8, true)
		gx = end_x + 6.0
		segment += 1
	_draw_glint(left, sheet_width)


## Ara sıra soldan sağa kayan çapraz parıltı + ucunda küçük yıldız.
func _draw_glint(left: float, sheet_width: float) -> void:
	var t: float = fmod(_time, Tuning.PLATFORM_ICE_GLINT_INTERVAL)
	if t > Tuning.PLATFORM_ICE_GLINT_TIME:
		return
	var u: float = t / Tuning.PLATFORM_ICE_GLINT_TIME
	var alpha: float = sin(PI * u)
	var x: float = lerpf(left + 4.0, left + sheet_width - 12.0, u)
	var top: float = ICE_TOP + 1.0
	var bottom: float = ICE_BOTTOM - 1.0
	draw_colored_polygon(PackedVector2Array([Vector2(x + 3.0, top), Vector2(x + 9.0, top),
			Vector2(x + 5.0, bottom), Vector2(x - 1.0, bottom)]), Color(1.0, 1.0, 1.0, 0.7 * alpha))
	PlatformDraw.sparkle(self, Vector2(x + 7.0, top - 1.0), 5.0 * alpha + 1.0, Color(1.0, 1.0, 1.0, 0.9 * alpha))


func _make_ice_glow() -> Sprite2D:
	_ice_glow = Sprite2D.new()
	_ice_glow.texture = SoftTextures.dot()
	_ice_glow.material = SoftTextures.additive()
	_ice_glow.modulate = Color(ICE_GLOW_COLOR, ICE_GLOW_ALPHA)
	_ice_glow.scale = Vector2(_width * 1.15, ICE_GLOW_HEIGHT) / SoftTextures.DOT_SIZE
	_ice_glow.position = Vector2(0.0, ICE_TOP)
	_ice_glow.show_behind_parent = true
	return _ice_glow


func _drip_points(drip: Vector3) -> PackedVector2Array:
	var y: float = ICE_BOTTOM - 1.5
	var half: float = drip.y
	var length: float = drip.z
	return PackedVector2Array([Vector2(drip.x - half, y), Vector2(drip.x + half, y),
			Vector2(drip.x + half * 0.7, y + length * 0.55), Vector2(drip.x + half * 0.3, y + length * 0.9),
			Vector2(drip.x, y + length), Vector2(drip.x - half * 0.3, y + length * 0.9),
			Vector2(drip.x - half * 0.7, y + length * 0.55)])


# --- Kayan ---

## Platformun arkasında, hareket aralığı boyunca ince oluk (dünyada sabit: platformun kaymasını geri alır).
func _draw_rail() -> void:
	var offset: float = _platform.position.x - _platform.base_x()
	var reach: float = _platform.travel + _width * 0.5 - 6.0
	var y: float = Tuning.PLATFORM_THICKNESS * 0.5
	var from := Vector2(-offset - reach, y)
	var to := Vector2(-offset + reach, y)
	draw_line(from, to, Color(OUTLINE, 0.45), 4.0, true)
	draw_line(from, to, Color(HINT_COLOR, 0.12), 1.4, true)
	for end: Vector2 in [from, to]:
		draw_circle(end, 4.0, Color(OUTLINE, 0.55))
		draw_circle(end, 2.0, Color(HINT_COLOR, 0.3))


## Uçlarda çift ok; platformun gittiği yöndeki oklar daha parlak.
func _draw_arrows() -> void:
	var max_speed: float = maxf(_platform.travel * TAU / Tuning.PLATFORM_MOVING_PERIOD_END, 1.0)
	var velocity: float = _platform.motion_velocity()
	var y: float = Tuning.PLATFORM_THICKNESS * 0.5
	for side: float in [-1.0, 1.0]:
		var toward: float = clampf(velocity * side / max_speed, 0.0, 1.0)
		var alpha: float = 0.35 + 0.5 * toward
		for i: int in 2:
			var x: float = side * (_width * 0.5 + 6.0 + i * 5.5)
			var points := PackedVector2Array([Vector2(x, y - 4.5), Vector2(x + side * 4.0, y),
					Vector2(x, y + 4.5)])
			draw_polyline(points, Color(OUTLINE, alpha * 0.8), 4.2, true)
			draw_polyline(points, Color(HINT_COLOR, alpha), 2.0, true)


# --- Yardımcılar ---

## Yol boyunca üstte top_width genişliğinde, uca doğru sivrilen dolu yarık çokgeni.
static func _wedge(path: PackedVector2Array, top_width: float) -> PackedVector2Array:
	var left := PackedVector2Array()
	var right := PackedVector2Array()
	var last: int = path.size() - 1
	for i: int in path.size():
		var half: float = top_width * 0.5 * (1.0 - float(i) / last) + 0.5
		left.append(path[i] + Vector2(-half, 0.0))
		right.append(path[i] + Vector2(half, 0.0))
	right.reverse()
	left.append_array(right)
	return left


## Yolun baştan itibaren `fraction` uzunluktaki kısmı.
static func _partial(path: PackedVector2Array, fraction: float) -> PackedVector2Array:
	var total: float = 0.0
	for i: int in range(1, path.size()):
		total += path[i - 1].distance_to(path[i])
	var remaining: float = total * clampf(fraction, 0.0, 1.0)
	var result := PackedVector2Array([path[0]])
	for i: int in range(1, path.size()):
		var segment: float = path[i - 1].distance_to(path[i])
		if remaining >= segment:
			result.append(path[i])
			remaining -= segment
		else:
			result.append(path[i - 1].lerp(path[i], remaining / maxf(segment, 0.001)))
			break
	return result


static func _shifted(path: PackedVector2Array, by: Vector2) -> PackedVector2Array:
	var result := PackedVector2Array()
	for point: Vector2 in path:
		result.append(point + by)
	return result


func _polyline(points: PackedVector2Array, color: Color, line_width: float) -> void:
	if points.size() >= 2 and points[0] != points[points.size() - 1]:
		draw_polyline(points, color, line_width, true)
