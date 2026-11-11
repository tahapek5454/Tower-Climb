class_name AfterimageTrail
extends Node2D
## Hareket izi: hızlı hareket ederken gövdenin solan kopyalarını dünyada bırakır.
## top_level: kopyalar oyuncuyla birlikte kaymaz, bırakıldıkları yerde kalır.
## Kopyalar önceden oluşturulmuş bir havuzdan tekrar kullanılır.

## Kopyalanan gövde (şekli, rengi ve o anki dünya dönüşümü alınır).
var source: Polygon2D
var player: Player

var _ghosts: Array[Polygon2D] = []
var _ages: PackedFloat32Array = []
var _next: int = 0
var _spawn_timer: float = 0.0


func _ready() -> void:
	top_level = true
	global_transform = Transform2D.IDENTITY
	var pool_size: int = ceili(Tuning.TRAIL_LIFETIME / Tuning.TRAIL_INTERVAL) + 2
	for i in pool_size:
		var ghost := source.duplicate() as Polygon2D
		ghost.visible = false
		add_child(ghost)
		_ghosts.append(ghost)
	_ages.resize(pool_size)


func _process(delta: float) -> void:
	_age_ghosts(delta)
	if _should_emit():
		_spawn_timer -= delta
		if _spawn_timer <= 0.0:
			_spawn()
			_spawn_timer = Tuning.TRAIL_INTERVAL
	else:
		_spawn_timer = 0.0


func active_count() -> int:
	var count: int = 0
	for ghost in _ghosts:
		if ghost.visible:
			count += 1
	return count


func _should_emit() -> bool:
	# Oyun bitince oyuncu donar ama hızı kalır; iz bırakmasın.
	return player.is_physics_processing() and player.velocity.length() >= Tuning.TRAIL_MIN_SPEED


func _spawn() -> void:
	var ghost: Polygon2D = _ghosts[_next]
	ghost.global_transform = source.global_transform
	ghost.modulate.a = Tuning.TRAIL_START_ALPHA
	ghost.visible = true
	_ages[_next] = 0.0
	_next = (_next + 1) % _ghosts.size()


func _age_ghosts(delta: float) -> void:
	for i in _ghosts.size():
		var ghost: Polygon2D = _ghosts[i]
		if not ghost.visible:
			continue
		_ages[i] += delta
		var t: float = _ages[i] / Tuning.TRAIL_LIFETIME
		if t >= 1.0:
			ghost.visible = false
		else:
			ghost.modulate.a = Tuning.TRAIL_START_ALPHA * (1.0 - t)
