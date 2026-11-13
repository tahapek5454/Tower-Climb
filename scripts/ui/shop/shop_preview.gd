class_name ShopPreview
extends VBoxContainer
## Mağazadaki canlı karakter önizlemesi: büyütülmüş CharacterModel (idle) yumuşak bir ışığın ve
## gölgenin üstünde yavaşça sağa sola döner; fareyle sürüklenince elle çevrilir. Çevresinde kuşanılı
## (ya da listede odaktaki) efektin renginde bir kuyruklu ışık döner (arkadan geçerken modelin arkasında).
## Listede odaktaki kozmetik satın almadan denenir (`preview_item`). Satın almada parıltı patlaması +
## halka + kanat çırpıp zıplama (`celebrate`). Model yalnız ekran açıkken vardır (activate/deactivate).

const STAGE_SIZE := Vector2(290.0, 340.0)
const MODEL_SCALE: float = 2.7
const FEET_MARGIN: float = 44.0
## Dönme salınımı: genlik (rad) ve hız (rad/s); -PI/2 = tam kameraya dönük.
const SWAY_AMPLITUDE: float = 0.6
const SWAY_SPEED: float = 0.55
const DRAG_YAW_PER_PX: float = 0.012
const DRAG_RETURN_RATE: float = 2.5
## Dönen ışık: yarıçaplar, gövdeye göre yükseklik (model boyuna oran), hız ve kuyruk.
const ORBIT_RADII := Vector2(112.0, 26.0)
const ORBIT_HEIGHT: float = 0.38
const ORBIT_SPEED: float = 1.5
const TAIL_DOTS: int = 26
const TAIL_STEP: float = 0.075
const HOP_HEIGHT: float = 26.0
const RING_TIME: float = 0.6
const BURST_AMOUNT: int = 34
const SMALL_BURST_AMOUNT: int = 14
const BURST_COLORS: Array[Color] = [UiStyle.COMBO, DiamondArt.LIGHT, DiamondArt.MID, UiStyle.TEXT]

var _stage: Control
var _front: Control
var _holder: Node2D
var _model: CharacterModel
var _burst: CPUParticles2D
var _caption: Label
var _hint: Label
var _applied: Dictionary = {}
var _trail_item: Dictionary = {}
var _time: float = 0.0
var _drag_yaw: float = 0.0
var _dragging: bool = false
var _ring_t: float = 1.0
var _ring_color: Color = UiStyle.COMBO
var _hop: Tween
var _anim_back: Tween


func _init() -> void:
	add_theme_constant_override(&"separation", 2)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage = Control.new()
	_stage.custom_minimum_size = STAGE_SIZE
	_stage.mouse_filter = Control.MOUSE_FILTER_STOP
	_stage.mouse_default_cursor_shape = Control.CURSOR_DRAG
	_stage.draw.connect(_draw_back)
	_stage.gui_input.connect(_on_stage_input)
	_stage.resized.connect(_place_holder)
	add_child(_stage)
	_holder = Node2D.new()
	_stage.add_child(_holder)
	_front = Control.new()
	_front.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_front.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_front.draw.connect(_draw_front)
	_stage.add_child(_front)
	_burst = _make_burst()
	_stage.add_child(_burst)
	_caption = UiStyle.label(17, UiStyle.TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	add_child(_caption)
	_hint = UiStyle.label(12, UiStyle.ACCENT, HORIZONTAL_ALIGNMENT_CENTER)
	add_child(_hint)
	set_process(false)


## Ekran açılınca: modeli kurar ve kuşanılıları uygular.
func activate() -> void:
	if _model == null and CharacterModel.is_available():
		_model = CharacterModel.new()
		_model.name = "PreviewModel"
		_holder.add_child(_model)
		_model.set_preview_yaw(-PI * 0.5, true)
	_applied.clear()
	_time = 0.0
	_drag_yaw = 0.0
	preview_item(&"")
	set_process(true)


## Ekran kapanınca: model (ve SubViewport'u) silinir, oyun sırasında boşuna çizilmesin.
func deactivate() -> void:
	set_process(false)
	if _model != null:
		_model.queue_free()
		_model = null
	_applied.clear()


## Odaktaki ürünü dener (boş ad: yalnız kuşanılılar).
func preview_item(id: StringName) -> void:
	var equipped: Dictionary = {}
	for slot: StringName in ShopCatalog.SLOTS:
		equipped[slot] = Shop.equipped(slot)
	var wanted: Dictionary = ShopLabels.try_on(equipped, id)
	for slot: StringName in wanted:
		if _applied.get(slot, &"") != wanted[slot]:
			_applied[slot] = wanted[slot]
			if _model != null:
				_model.set_cosmetic(slot, wanted[slot])
	_trail_item = ShopCatalog.get_item(ShopLabels.trail_preview(equipped[ShopCatalog.TRAIL], id))
	var item: Dictionary = ShopCatalog.get_item(id)
	_caption.text = item.get("title", "")
	var trying: bool = not item.is_empty() and ShopCatalog.is_slot(item["category"]) \
			and Shop.status(id) in [ShopRules.Status.BUYABLE, ShopRules.Status.TOO_EXPENSIVE]
	_hint.text = "deneniyor" if trying else " "


## Önizlemede şu an uygulanmış kozmetikler {yuva: kimlik} (doğrulama için).
func applied_cosmetics() -> Dictionary:
	return _applied.duplicate()


## Satın alma (strong) ya da kuşanma kutlaması. colors: parıltı renkleri (boşsa altın + elmas).
func celebrate(strong: bool, colors: Array[Color] = []) -> void:
	var palette: Array[Color] = colors if not colors.is_empty() else BURST_COLORS
	_burst.color_initial_ramp = _palette_ramp(palette)
	_burst.amount = BURST_AMOUNT if strong else SMALL_BURST_AMOUNT
	_burst.initial_velocity_max = 330.0 if strong else 200.0
	_burst.position = _chest()
	_burst.restart()
	_ring_color = palette[0]
	_ring_t = 0.0
	_hop_model(strong)
	if _model != null and strong and _model.has_animation(&"flap"):
		_model.play(&"flap", Tuning.MODEL_ANIM_BLEND_TIME_FAST)
		if _anim_back != null:
			_anim_back.kill()
		_anim_back = create_tween()
		_anim_back.tween_callback(func() -> void:
			if _model != null:
				_model.play(&"idle")).set_delay(_model.animation_length(&"flap"))


func _process(delta: float) -> void:
	_time += delta
	if not _dragging:
		_drag_yaw = lerpf(_drag_yaw, 0.0, 1.0 - exp(-DRAG_RETURN_RATE * delta))
	if _model != null:
		_model.set_preview_yaw(-PI * 0.5 + SWAY_AMPLITUDE * sin(_time * SWAY_SPEED) + _drag_yaw, true)
	if _ring_t < 1.0:
		_ring_t = minf(_ring_t + delta / RING_TIME, 1.0)
	_stage.queue_redraw()
	_front.queue_redraw()


func _place_holder() -> void:
	_holder.position = Vector2(_stage.size.x * 0.5, _stage.size.y - FEET_MARGIN)
	_holder.scale = Vector2.ONE * MODEL_SCALE


func _feet() -> Vector2:
	return Vector2(_stage.size.x * 0.5, _stage.size.y - FEET_MARGIN)


func _chest() -> Vector2:
	return _feet() - Vector2(0.0, Tuning.MODEL_HEIGHT * MODEL_SCALE * 0.5)


func _hop_model(strong: bool) -> void:
	if _hop != null:
		_hop.kill()
	var base: Vector2 = _feet()
	var height: float = HOP_HEIGHT if strong else HOP_HEIGHT * 0.45
	_holder.position = base
	_holder.scale = Vector2(1.12, 0.88) * MODEL_SCALE
	_hop = create_tween()
	_hop.tween_property(_holder, ^"scale", Vector2(0.94, 1.08) * MODEL_SCALE, 0.08)
	_hop.parallel().tween_property(_holder, ^"position:y", base.y - height, 0.2) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_hop.tween_property(_holder, ^"scale", Vector2.ONE * MODEL_SCALE, 0.16)
	_hop.tween_property(_holder, ^"position:y", base.y, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_hop.tween_property(_holder, ^"scale", Vector2(1.08, 0.93) * MODEL_SCALE, 0.06)
	_hop.tween_property(_holder, ^"scale", Vector2.ONE * MODEL_SCALE, 0.18) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Arka plan: yumuşak ışık, zemin gölgesi, dönen ışığın arka yarısı.
func _draw_back() -> void:
	var feet: Vector2 = _feet()
	var dot: Texture2D = SoftTextures.dot()
	var glow_size := Vector2(300.0, 300.0)
	_stage.draw_texture_rect(dot, Rect2(_chest() - glow_size * 0.5, glow_size), false, Color(UiStyle.ACCENT, 0.16))
	var shadow_size := Vector2(150.0, 34.0)
	_stage.draw_texture_rect(dot, Rect2(feet - shadow_size * 0.5, shadow_size), false, Color(UiStyle.OUTLINE, 0.55))
	_stage.draw_polyline(PlatformDraw.ellipse(feet, Vector2(86.0, 13.0), 40), Color(UiStyle.ACCENT, 0.22), 1.5, true)
	if _model == null:
		var box := Rect2(feet - Vector2(Tuning.PLAYER_WIDTH, Tuning.PLAYER_HEIGHT * 2.0), Vector2(Tuning.PLAYER_WIDTH * 2.0,
				Tuning.PLAYER_HEIGHT * 2.0))
		_stage.draw_rect(box, UiStyle.ACCENT)
	_draw_orbit(_stage, false)


func _draw_front() -> void:
	_draw_orbit(_front, true)
	if _ring_t < 1.0:
		var ease_t: float = 1.0 - pow(1.0 - _ring_t, 3.0)
		_front.draw_arc(_chest(), lerpf(30.0, 150.0, ease_t), 0.0, TAU, 64, Color(_ring_color, 0.5 * (1.0 - _ring_t)),
				lerpf(6.0, 1.5, ease_t), true)


## Kuyruklu ışık: ön yarı (front) modelin önünde, arka yarı arkasında çizilir.
func _draw_orbit(canvas: CanvasItem, front: bool) -> void:
	if _trail_item.is_empty():
		return
	var center: Vector2 = _feet() - Vector2(0.0, Tuning.MODEL_HEIGHT * MODEL_SCALE * ORBIT_HEIGHT)
	var head: float = _time * ORBIT_SPEED
	var sparkle: bool = _trail_item.get("style", &"") == ShopCatalog.STYLE_SPARKLE
	for i: int in range(TAIL_DOTS - 1, -1, -1):
		var angle: float = head - i * TAIL_STEP
		if (sin(angle) > 0.0) != front:
			continue
		var t: float = 1.0 - float(i) / TAIL_DOTS
		var depth: float = lerpf(0.75, 1.0, (sin(angle) + 1.0) * 0.5)
		var point: Vector2 = center + Vector2(cos(angle) * ORBIT_RADII.x, sin(angle) * ORBIT_RADII.y)
		var color: Color = ShopIcons.trail_color(_trail_item, 1.0 - t)
		canvas.draw_circle(point, lerpf(1.5, 8.0, t * t) * depth, Color(color, lerpf(0.05, 0.95, t) * depth), true, -1.0, true)
		var twinkle: float = 0.5 + 0.5 * sin(_time * 9.0 + i)
		if sparkle and i % 6 == 3 and 4.5 * t * twinkle > 1.0:
			PlatformDraw.sparkle(canvas, point + Vector2(0.0, -10.0 * t), 4.5 * t * twinkle,
					Color(_trail_item.get("color2", Color.WHITE), t))


func _on_stage_input(input_event: InputEvent) -> void:
	var button := input_event as InputEventMouseButton
	if button != null and button.button_index == MOUSE_BUTTON_LEFT:
		_dragging = button.pressed
	var motion := input_event as InputEventMouseMotion
	if motion != null and _dragging:
		_drag_yaw += motion.relative.x * DRAG_YAW_PER_PX


func _make_burst() -> CPUParticles2D:
	var emitter := CPUParticles2D.new()
	emitter.texture = SoftTextures.dot()
	emitter.material = SoftTextures.additive()
	emitter.one_shot = true
	emitter.emitting = false
	emitter.explosiveness = 0.92
	emitter.lifetime = 0.9
	emitter.amount = BURST_AMOUNT
	emitter.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	emitter.emission_sphere_radius = 30.0
	emitter.direction = Vector2.UP
	emitter.spread = 180.0
	emitter.initial_velocity_min = 90.0
	emitter.initial_velocity_max = 330.0
	emitter.damping_min = 260.0
	emitter.damping_max = 380.0
	emitter.gravity = Vector2(0.0, 160.0)
	emitter.scale_amount_min = 0.09
	emitter.scale_amount_max = 0.22
	var fade := Gradient.new()
	fade.set_color(0, Color(1.0, 1.0, 1.0, 1.0))
	fade.set_color(1, Color(1.0, 1.0, 1.0, 0.0))
	emitter.color_ramp = fade
	return emitter


static func _palette_ramp(colors: Array[Color]) -> Gradient:
	var gradient := Gradient.new()
	gradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT
	var offsets := PackedFloat32Array()
	var packed := PackedColorArray()
	for i: int in colors.size():
		offsets.append(float(i) / colors.size())
		packed.append(colors[i])
	gradient.offsets = offsets
	gradient.colors = packed
	return gradient
