class_name SpeedLines
extends Node2D
## Hız çizgileri: çok hızlıyken gövdenin arkasında, hareket yönünde ince, silik çizgiler.
## Uçlar yuvarlak; kuyruk tarafı incelip kaybolur. top_level: çizgiler dünyada sabit kalır.
## Çizgiler önceden oluşturulmuş bir havuzdan tekrar kullanılır.

const LINE_COLOR := Color(1.0, 1.0, 1.0)

var player: Player

var _lines: Array[Line2D] = []
var _ages: PackedFloat32Array = []
var _next: int = 0
var _spawn_timer: float = 0.0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	top_level = true
	global_transform = Transform2D.IDENTITY
	_rng.randomize()
	# Tüm çizgiler aynı solma/incelme kaynaklarını paylaşır. Nokta 0 = kuyruk, 1 = baş.
	var fade := Gradient.new()
	fade.set_color(0, Color(LINE_COLOR, 0.0))
	fade.set_color(1, Color(LINE_COLOR, Tuning.SPEED_LINE_START_ALPHA))
	var taper := Curve.new()
	taper.add_point(Vector2(0.0, 0.0))
	taper.add_point(Vector2(1.0, 1.0))

	var pool_size: int = ceili(Tuning.SPEED_LINE_LIFETIME / Tuning.SPEED_LINE_INTERVAL) + 2
	for i in pool_size:
		var line := Line2D.new()
		line.width = Tuning.SPEED_LINE_WIDTH
		line.gradient = fade
		line.width_curve = taper
		line.begin_cap_mode = Line2D.LINE_CAP_ROUND
		line.end_cap_mode = Line2D.LINE_CAP_ROUND
		line.antialiased = true
		line.visible = false
		add_child(line)
		_lines.append(line)
	_ages.resize(pool_size)


func _process(delta: float) -> void:
	_age_lines(delta)
	if _should_emit():
		_spawn_timer -= delta
		if _spawn_timer <= 0.0:
			_spawn()
			_spawn_timer = Tuning.SPEED_LINE_INTERVAL
	else:
		_spawn_timer = 0.0


func active_count() -> int:
	var count: int = 0
	for line in _lines:
		if line.visible:
			count += 1
	return count


func _should_emit() -> bool:
	return player.is_physics_processing() and player.velocity.length() >= Tuning.SPEED_LINES_MIN_SPEED


## Gövde merkezinin arkasında, hareket yönüne paralel bir çizgi bırakır.
func _spawn() -> void:
	var direction: Vector2 = player.velocity.normalized()
	var side: Vector2 = direction.orthogonal()
	var body_center: Vector2 = player.global_position + Vector2(0.0, -Tuning.PLAYER_HEIGHT * 0.5)
	var length: float = _rng.randf_range(Tuning.SPEED_LINE_LENGTH_MIN, Tuning.SPEED_LINE_LENGTH_MAX)
	var back: float = _rng.randf_range(Tuning.SPEED_LINE_BACK_MIN, Tuning.SPEED_LINE_BACK_MAX)
	var offset: float = _rng.randf_range(-Tuning.SPEED_LINE_SPREAD, Tuning.SPEED_LINE_SPREAD)
	var head: Vector2 = body_center - direction * back + side * offset

	var line: Line2D = _lines[_next]
	line.points = PackedVector2Array([head - direction * length, head])
	line.modulate.a = 1.0
	line.visible = true
	_ages[_next] = 0.0
	_next = (_next + 1) % _lines.size()


func _age_lines(delta: float) -> void:
	for i in _lines.size():
		var line: Line2D = _lines[i]
		if not line.visible:
			continue
		_ages[i] += delta
		var t: float = _ages[i] / Tuning.SPEED_LINE_LIFETIME
		if t >= 1.0:
			line.visible = false
		else:
			line.modulate.a = 1.0 - t
