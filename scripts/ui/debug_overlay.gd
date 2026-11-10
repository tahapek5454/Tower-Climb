class_name DebugOverlay
extends CanvasLayer
## F3 ile açılıp kapanan debug paneli: FPS, hız, durum, kat, kombo, kamera hızı.
## Sadece okur; oyuna dokunmaz.

const MARGIN: int = 16
const FONT_SIZE: int = 18
const PANEL_COLOR := Color(0.0, 0.0, 0.0, 0.6)
const PANEL_PADDING: int = 10
## Overlay her şeyin üstünde çizilsin.
const LAYER: int = 100

var player: Player
var camera: TowerCamera

var _label: Label


func _ready() -> void:
	layer = LAYER
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build()
	visible = false


func _unhandled_input(input_event: InputEvent) -> void:
	if input_event.is_action_pressed(&"toggle_debug"):
		visible = not visible
		get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	if visible:
		_label.text = _compose_text()


func _compose_text() -> String:
	var lines: PackedStringArray = []
	lines.append("FPS: %d" % Engine.get_frames_per_second())
	if player != null:
		lines.append("vx: %7.1f   vy: %7.1f" % [player.velocity.x, player.velocity.y])
		lines.append("Durum: %s" % Player.State.keys()[player.state])
		lines.append("Yerde: %s" % ("evet" if player.is_on_floor() else "hayır"))
	lines.append("Kat: %d" % GameState.floor_number)
	lines.append("Kombo: x%d  %d kat  %.2f s" % [GameState.combo_jumps, GameState.combo_floors,
			GameState.combo_time_ratio * Tuning.COMBO_TIMEOUT])
	if camera != null:
		var scroll: String = "kayıyor" if camera.is_scrolling else "bekliyor"
		lines.append("Kamera: %.1f px/s (%s)" % [camera.speed, scroll])
	return "\n".join(lines)


func _build() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for side in [&"margin_left", &"margin_top", &"margin_right", &"margin_bottom"]:
		margin.add_theme_constant_override(side, MARGIN)
	add_child(margin)

	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_SHRINK_END
	panel.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL_COLOR
	style.set_content_margin_all(PANEL_PADDING)
	panel.add_theme_stylebox_override(&"panel", style)
	margin.add_child(panel)

	_label = Label.new()
	_label.add_theme_font_size_override(&"font_size", FONT_SIZE)
	panel.add_child(_label)
