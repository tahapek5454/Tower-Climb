class_name CrumbleFx
extends Node2D
## Çatlayan platformun görüntü efekti (platformun çocuğu). Geri sayımda: platform görüntüsü titrer,
## çatlaklar büyür, altından ufak taş tozu dökülür. Çökünce: görüntü çatlak çizgilerinden parçalara
## ayrılır (her parça platform görüntüsünün kırpılmış kopyası), parçalar dönerek düşüp söner; taş ve toz.

const DUST_COLOR := Color(0.85, 0.87, 0.95)
## Parça kırpma alanının üst/alt sınırı (süsler dahil kalsın diye geniş).
const CLIP_TOP: float = -90.0
const CLIP_BOTTOM: float = 120.0

var _platform: Platform
var _visual: Node2D
var _art: PlatformTypeArt
var _trickle: CPUParticles2D
var _time: float = 0.0
var _shake: float = 0.0
var _stone_color: Color


func start(platform: Platform) -> void:
	_platform = platform
	_visual = platform.get_node_or_null(^"Visual") as Node2D
	_art = platform.get_node_or_null(^"TypeArt") as PlatformTypeArt
	_stone_color = platform.theme_color().darkened(0.2)
	_trickle = _make_emitter(maxi(4, roundi(platform.width / 30.0)), 0.7)
	_trickle.one_shot = false
	_trickle.explosiveness = 0.0
	_trickle.emission_rect_extents = Vector2(platform.width * 0.4, 1.0)
	_trickle.position = Vector2(0.0, Tuning.PLATFORM_THICKNESS)
	_trickle.gravity = Vector2(0.0, 520.0)
	_trickle.initial_velocity_min = 0.0
	_trickle.initial_velocity_max = 20.0
	_trickle.scale_amount_min = 0.05
	_trickle.scale_amount_max = 0.1
	_trickle.color_ramp = _fade_ramp(_stone_color, 0.9)
	_trickle.emitting = true


## progress: 0..1 geri sayım. Titreme giderek artar; çatlaklar büyür.
func set_progress(progress: float) -> void:
	_shake = Tuning.PLATFORM_CRUMBLE_SHAKE * lerpf(0.35, 1.0, progress)
	if _art != null:
		_art.crack_progress = progress
		_art.queue_redraw()


func _process(delta: float) -> void:
	if _shake <= 0.0:
		return
	_time += delta
	var offset := Vector2(sin(_time * 57.0), cos(_time * 43.0) * 0.4) * _shake
	for node: Node2D in [_visual, _art]:
		if node != null:
			node.position = offset


## Çöküş: asıl görüntü gizlenir, parçalar düşer, taş ve toz saçılır.
func shatter() -> void:
	_shake = 0.0
	_trickle.emitting = false
	for node: Node2D in [_visual, _art]:
		if node != null:
			node.visible = false
	var cuts: Array[PackedVector2Array] = _cut_lines()
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(_platform.floor_number * 53 + 11)
	for i: int in cuts.size() - 1:
		_spawn_piece(cuts[i], cuts[i + 1], rng, float(i) / maxf(cuts.size() - 2, 1.0))
	_burst_stones()
	_burst_dust()
	var tween := create_tween()
	tween.tween_interval(maxf(Tuning.PLATFORM_CRUMBLE_FALL_TIME, 1.0) + 0.1)
	tween.tween_callback(queue_free)


## Kesim çizgileri soldan sağa: dış kenarlar dik, aralar çatlakları izler.
func _cut_lines() -> Array[PackedVector2Array]:
	var edge: float = _platform.width * 0.5 + 40.0
	var cuts: Array[PackedVector2Array] = [
		PackedVector2Array([Vector2(-edge, CLIP_TOP), Vector2(-edge, CLIP_BOTTOM)])]
	if _art != null:
		for crack: PackedVector2Array in _art.cracks():
			var cut := PackedVector2Array([Vector2(crack[0].x, CLIP_TOP)])
			cut.append_array(crack)
			cut.append(Vector2(crack[crack.size() - 1].x, CLIP_BOTTOM))
			cuts.append(cut)
	cuts.append(PackedVector2Array([Vector2(edge, CLIP_TOP), Vector2(edge, CLIP_BOTTOM)]))
	return cuts


## Bir parça: iki kesim arası çokgen maske (CLIP_CHILDREN_ONLY) + içinde görüntünün kopyası.
## side: 0 (en sol) .. 1 (en sağ); kenardaki parçalar dışa doğru savrulur.
func _spawn_piece(left: PackedVector2Array, right: PackedVector2Array, rng: RandomNumberGenerator,
		side: float) -> void:
	var center_x: float = (left[0].x + right[0].x) * 0.5
	center_x = clampf(center_x, -_platform.width * 0.5, _platform.width * 0.5)
	var pivot := Node2D.new()
	pivot.position = Vector2(center_x, Tuning.PLATFORM_THICKNESS * 0.5)
	add_child(pivot)
	var mask := Polygon2D.new()
	var points := PackedVector2Array(left)
	var reversed := PackedVector2Array(right)
	reversed.reverse()
	points.append_array(reversed)
	mask.polygon = points
	mask.clip_children = CanvasItem.CLIP_CHILDREN_ONLY
	mask.position = -pivot.position
	pivot.add_child(mask)
	mask.add_child(_platform.make_visual())
	if _art != null:
		var art := PlatformTypeArt.new()
		art.setup(_platform, false)
		art.crack_progress = 1.0
		mask.add_child(art)

	var direction: float = lerpf(-1.0, 1.0, side) + rng.randf_range(-0.3, 0.3)
	var time: float = Tuning.PLATFORM_CRUMBLE_FALL_TIME * rng.randf_range(0.85, 1.1)
	var tween := pivot.create_tween().set_parallel(true)
	tween.tween_property(pivot, ^"position:y", pivot.position.y + Tuning.PLATFORM_CRUMBLE_FALL_DISTANCE,
			time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(pivot, ^"position:x", pivot.position.x + direction * 22.0, time) \
			.set_ease(Tween.EASE_OUT)
	tween.tween_property(pivot, ^"rotation", direction * rng.randf_range(0.25, 0.5), time) \
			.set_ease(Tween.EASE_IN)
	tween.tween_property(pivot, ^"modulate:a", 0.0, time * 0.55).set_delay(time * 0.45)


func _burst_stones() -> void:
	var stones: CPUParticles2D = _make_emitter(clampi(roundi(_platform.width / 9.0), 12, 40), 0.9)
	stones.emission_rect_extents = Vector2(_platform.width * 0.5, 6.0)
	stones.position = Vector2(0.0, Tuning.PLATFORM_THICKNESS * 0.5)
	stones.direction = Vector2(0.0, -1.0)
	stones.spread = 70.0
	stones.initial_velocity_min = 40.0
	stones.initial_velocity_max = 120.0
	stones.gravity = Vector2(0.0, 760.0)
	stones.scale_amount_min = 0.08
	stones.scale_amount_max = 0.17
	stones.color_ramp = _fade_ramp(_stone_color, 1.0, 0.7)
	stones.restart()


func _burst_dust() -> void:
	var dust: CPUParticles2D = _make_emitter(clampi(roundi(_platform.width / 18.0), 8, 20), 1.0)
	dust.emission_rect_extents = Vector2(_platform.width * 0.5, 4.0)
	dust.position = Vector2(0.0, Tuning.PLATFORM_THICKNESS * 0.5)
	dust.direction = Vector2(0.0, -1.0)
	dust.spread = 180.0
	dust.initial_velocity_min = 12.0
	dust.initial_velocity_max = 45.0
	dust.damping_min = 30.0
	dust.damping_max = 50.0
	dust.gravity = Vector2(0.0, -20.0)
	dust.scale_amount_min = 0.3
	dust.scale_amount_max = 0.55
	var grow := Curve.new()
	grow.max_value = 1.8
	grow.add_point(Vector2(0.0, 1.0))
	grow.add_point(Vector2(1.0, 1.8))
	dust.scale_amount_curve = grow
	dust.color_ramp = _fade_ramp(DUST_COLOR.lerp(_stone_color, 0.25), 0.5)
	dust.restart()


func _make_emitter(amount: int, lifetime: float) -> CPUParticles2D:
	var emitter := CPUParticles2D.new()
	emitter.texture = SoftTextures.dot()
	emitter.amount = amount
	emitter.lifetime = lifetime
	emitter.one_shot = true
	emitter.explosiveness = 0.95
	emitter.emitting = false
	emitter.local_coords = false
	emitter.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	add_child(emitter)
	return emitter


## Saydamlık start_alpha'dan 0'a; hold: sönmeye başlamadan önce tam kalan oran.
func _fade_ramp(color: Color, start_alpha: float, hold: float = 0.0) -> Gradient:
	var ramp := Gradient.new()
	ramp.set_color(0, Color(color, start_alpha))
	ramp.set_color(1, Color(color, 0.0))
	if hold > 0.0:
		ramp.add_point(hold, Color(color, start_alpha))
	return ramp
