class_name HeartMeter
extends Control
## HUD kalp göstergesi: bu oyundaki her kalp için bir dolu kalp (sağa yaslı). Hiç kalp yoksa tek bir soluk
## boş kalp. Kalp kazanılınca yenisi büyüyerek belirir; harcanınca giden kalp kızarıp küçülerek kaybolur.

const ICON_SCALE: float = 0.5
const GAP: float = 3.0
const POP_TIME: float = 0.35
const LOSE_TIME: float = 0.45

var _hearts: int = 0
## Belirme (0 → 1) ve kaybolma (1 → 0) animasyonlarının ilerlemesi.
var _pop: float = 1.0
var _lose: float = 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_update_width()
	_hearts = GameState.hearts
	Events.hearts_changed.connect(_on_hearts_changed)


func shown_hearts() -> int:
	return _hearts


## Genişlik o anki kalp sınırına göre ("Geniş yürek" yükseltmesiyle büyür; menüde alınabilir).
func _update_width() -> void:
	custom_minimum_size = Vector2(_slot_width() * maxi(Upgrades.heart_max(), _hearts), 32.0 * ICON_SCALE + 2.0)


func _on_hearts_changed(hearts: int, change: int) -> void:
	_hearts = hearts
	_update_width()
	if change > 0:
		_animate(&"_pop", 0.0, 1.0, POP_TIME, Tween.TRANS_BACK)
	elif change < 0:
		_animate(&"_lose", 1.0, 0.0, LOSE_TIME, Tween.TRANS_CUBIC)
	queue_redraw()


func _animate(property: StringName, from: float, to: float, time: float, transition: Tween.TransitionType) -> void:
	set(property, from)
	var tween := create_tween()
	tween.tween_method(func(value: float) -> void:
		set(property, value)
		queue_redraw(), from, to, time).set_trans(transition).set_ease(Tween.EASE_OUT)


func _draw() -> void:
	var y: float = size.y * 0.5
	if _hearts == 0 and _lose <= 0.0:
		HeartArt.draw(self, Vector2(size.x - _slot_width() * 0.5, y), ICON_SCALE, HeartArt.EMPTY)
		return
	for i: int in _hearts:
		var grow: float = _pop if i == _hearts - 1 else 1.0
		HeartArt.draw(self, _slot_center(i, y), ICON_SCALE * grow)
	if _lose > 0.0:
		# Harcanan kalp, son kalbin yanında kızarıp küçülür.
		HeartArt.draw(self, _slot_center(_hearts, y), ICON_SCALE * (0.4 + 0.8 * _lose),
				Color(HeartArt.GLOW, _lose))


## Kalpler sağdan sola dizilir: ilk kalp en sağda.
func _slot_center(index: int, y: float) -> Vector2:
	return Vector2(size.x - _slot_width() * (index + 0.5), y)


func _slot_width() -> float:
	return 32.0 * ICON_SCALE + GAP
