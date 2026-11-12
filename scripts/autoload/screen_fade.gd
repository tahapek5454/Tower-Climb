extends CanvasLayer
## Ekran geçişi (autoload): ekranı koyu lacivertle kaplar (cover) ve açar (reveal). Sahne yeniden
## yüklenirken kullanılır: kaplan → yeniden yükle → yeni sahne reveal ister. Kaplı değilken reveal
## bir şey yapmaz (oyunun ilk açılışında solma yok).

const FADE_LAYER: int = 95
const DEFAULT_COVER_TIME: float = 0.22
const DEFAULT_REVEAL_TIME: float = 0.32

var _rect: ColorRect
var _tween: Tween
var _covered: bool = false


func _ready() -> void:
	layer = FADE_LAYER
	process_mode = Node.PROCESS_MODE_ALWAYS
	_rect = ColorRect.new()
	_rect.color = Color(UiStyle.OUTLINE, 0.0)
	_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_rect)


## Ekranı kaplar; kaplanınca döner. Bu sırada fare tıklamaları engellenir.
func cover(time: float = DEFAULT_COVER_TIME) -> void:
	_covered = true
	_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	_fade_to(1.0, time)
	await get_tree().create_timer(time).timeout


## Kaplıysa ekranı açar (beklemez).
func reveal(time: float = DEFAULT_REVEAL_TIME) -> void:
	if not _covered:
		return
	_covered = false
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade_to(0.0, time)


func is_covered() -> bool:
	return _covered


func _fade_to(alpha: float, time: float) -> void:
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_rect, ^"color:a", alpha, time)
