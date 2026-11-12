class_name HitStop
extends Node
## Hit-stop (ekran sarsıntısı ayarı kapalıysa çalışmaz): puan kazandıran kombo bitince oyunu kısa bir an neredeyse durdurur.
## Süre gerçek zamanla ölçülür. Bitince önceki oyun hızına döner (ör. F4 yavaş çekim açıksa ona).

## Hit-stop başlamadan önceki oyun hızı; bitince buna dönülür.
var _restore_scale: float = 1.0
var _active: bool = false
## Üst üste gelen hit-stop'larda sadece en son zamanlayıcı geri döndürür.
var _generation: int = 0


## Kombo büyüklüğüne göre süre: MIN..MAX arası.
static func duration_for(floors: int) -> float:
	var t: float = clampf(float(floors) / Tuning.HITSTOP_FULL_FLOORS, 0.0, 1.0)
	return lerpf(Tuning.HITSTOP_DURATION_MIN, Tuning.HITSTOP_DURATION_MAX, t)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Events.combo_ended.connect(_on_combo_ended)


func _exit_tree() -> void:
	# Yeniden başlatma sırasında oyun yavaş kalmasın.
	if _active:
		Engine.time_scale = _restore_scale
		_active = false


func is_active() -> bool:
	return _active


func trigger(duration: float) -> void:
	if not _active:
		_restore_scale = Engine.time_scale
		_active = true
	Engine.time_scale = _restore_scale * Tuning.HITSTOP_TIME_SCALE
	_generation += 1
	var my_generation: int = _generation
	# Son argüman: zamanlayıcı oyun hızından etkilenmez (gerçek zaman).
	get_tree().create_timer(duration, true, false, true).timeout.connect(
			func() -> void: _release(my_generation))


func _release(generation: int) -> void:
	if generation != _generation or not _active:
		return
	Engine.time_scale = _restore_scale
	_active = false


func _on_combo_ended(_jumps: int, floors: int, bonus: int) -> void:
	if bonus > 0 and GameSettings.get_setting("screen_shake"):
		trigger(duration_for(floors))
