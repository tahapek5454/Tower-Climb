class_name ComboPopups
extends CanvasLayer
## Kombo yazıları: oyuncunun üstünde hafifçe büyüyerek beliren, yükselip solan
## "x3" (sadece çarpan) ve kombo bitişinde "+144". Ekran koordinatında çizilir. Minimal tutulur.
## Yeni kombo yazısı öncekinin yerini alır (ekran dolmasın); bonus yazısı ayrıdır.

## Kombo altın (HUD kombo satırıyla aynı), bonus sıcak turuncu; dış çizgi karakter/platformlarla aynı lacivert.
const COMBO_COLOR := UiStyle.COMBO
const BONUS_COLOR := Color(1.0, 0.66, 0.36)
const OUTLINE_COLOR := UiStyle.OUTLINE
const OUTLINE_SIZE: int = 4
## Yazının ekran kenarlarına en fazla bu kadar yaklaşmasına izin verilir.
const SCREEN_MARGIN: float = 24.0

## Yazıların çıkacağı yer bu düğümün ekrandaki konumuna göre hesaplanır.
var player: Node2D

var _combo_label: Label


func _ready() -> void:
	Events.combo_changed.connect(_on_combo_changed)
	Events.combo_ended.connect(_on_combo_ended)
	Events.combo_diamonds_earned.connect(_on_diamonds_earned)


func _on_combo_changed(jumps: int, _floors: int) -> void:
	if not PopupRules.shows_combo(jumps):
		return
	if is_instance_valid(_combo_label):
		_combo_label.queue_free()
	_combo_label = _spawn(PopupRules.combo_text(jumps), PopupRules.combo_font_size(jumps),
			COMBO_COLOR, Tuning.COMBO_POPUP_LIFETIME)


func _on_combo_ended(_jumps: int, floors: int, bonus: int) -> void:
	if is_instance_valid(_combo_label):
		_combo_label.queue_free()
	if bonus > 0:
		_spawn(PopupRules.bonus_text(bonus), PopupRules.bonus_font_size(floors),
				BONUS_COLOR, Tuning.BONUS_POPUP_LIFETIME)


## Kombo bonus yazısının üstünde: küçük elmas simgesi + "+N"; hafifçe süzülüp söner.
func _on_diamonds_earned(count: int) -> void:
	var label := Label.new()
	label.text = "+%d" % count
	label.add_theme_font_size_override(&"font_size", Tuning.COMBO_DIAMOND_FONT_SIZE)
	label.add_theme_color_override(&"font_color", DiamondArt.LIGHT)
	label.add_theme_color_override(&"font_outline_color", OUTLINE_COLOR)
	label.add_theme_constant_override(&"outline_size", OUTLINE_SIZE)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var icon_size: float = DiamondArt.HALF_WIDTH * 2.0 * Tuning.COMBO_DIAMOND_ICON_SCALE
	var text_size: Vector2 = label.get_minimum_size()
	var root := Control.new()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.size = Vector2(icon_size + 6.0 + text_size.x, maxf(text_size.y, icon_size))
	label.position = Vector2(icon_size + 6.0, (root.size.y - text_size.y) * 0.5)
	root.add_child(label)
	root.draw.connect(func() -> void:
		DiamondArt.draw(root, Vector2(icon_size * 0.5, root.size.y * 0.5), Tuning.COMBO_DIAMOND_ICON_SCALE))
	add_child(root)
	root.pivot_offset = root.size * 0.5
	var start: Vector2 = _anchor_point(root.size) - Vector2(0.0, Tuning.COMBO_DIAMOND_POPUP_RAISE) - root.size * 0.5
	root.position = start
	root.scale = Vector2.ZERO
	var life: float = Tuning.COMBO_DIAMOND_LIFETIME
	var tween := root.create_tween().set_parallel()
	tween.tween_property(root, ^"scale", Vector2.ONE, Tuning.POPUP_POP_TIME * 2.0) 			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(root, ^"position:y", start.y - Tuning.COMBO_DIAMOND_RISE, life) 			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(root, ^"modulate:a", 0.0, life * 0.4).set_delay(life * 0.6)
	tween.chain().tween_callback(root.queue_free)


func _spawn(text: String, font_size: int, color: Color, lifetime: float) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override(&"font_size", font_size)
	label.add_theme_color_override(&"font_color", color)
	label.add_theme_color_override(&"font_outline_color", OUTLINE_COLOR)
	label.add_theme_constant_override(&"outline_size", OUTLINE_SIZE)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(label)
	label.size = label.get_minimum_size()
	label.pivot_offset = label.size * 0.5
	label.position = _anchor_point(label.size) - label.size * 0.5
	label.scale = Vector2.ZERO
	_animate(label, lifetime)
	return label


## Oyuncunun ekrandaki konumunun üstü; yazı ekran dışına taşmaz.
func _anchor_point(label_size: Vector2) -> Vector2:
	var point := Vector2(Tuning.VIEW_WIDTH * 0.5, Tuning.VIEW_HEIGHT * 0.4)
	if is_instance_valid(player):
		point = player.get_global_transform_with_canvas().origin + Vector2(0.0, -Tuning.POPUP_OFFSET_Y)
	var half: Vector2 = label_size * 0.5 + Vector2(SCREEN_MARGIN, SCREEN_MARGIN)
	point.x = clampf(point.x, half.x, Tuning.VIEW_WIDTH - half.x)
	point.y = clampf(point.y, half.y, Tuning.VIEW_HEIGHT - half.y)
	return point


## Büyüyerek belir (taşıp otur), sallanarak yüksel, son kısımda sol, sonra silin.
func _animate(label: Label, lifetime: float) -> void:
	var pop := label.create_tween()
	pop.tween_property(label, ^"scale", Vector2.ONE * Tuning.POPUP_POP_SCALE, Tuning.POPUP_POP_TIME) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	pop.tween_property(label, ^"scale", Vector2.ONE, Tuning.POPUP_POP_TIME) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	var drift := label.create_tween().set_parallel()
	drift.tween_property(label, ^"position:y", label.position.y - Tuning.POPUP_RISE, lifetime) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	drift.tween_method(_wobble.bind(label, lifetime), 0.0, lifetime, lifetime)
	drift.tween_property(label, ^"modulate:a", 0.0, lifetime * 0.4).set_delay(lifetime * 0.6)
	drift.chain().tween_callback(label.queue_free)


## Zamanla sönen sinüs sallanması.
func _wobble(age: float, label: Label, lifetime: float) -> void:
	var fade: float = 1.0 - clampf(age / lifetime, 0.0, 1.0)
	label.rotation = deg_to_rad(Tuning.POPUP_WOBBLE_DEGREES) * sin(age * Tuning.POPUP_WOBBLE_SPEED) * fade
