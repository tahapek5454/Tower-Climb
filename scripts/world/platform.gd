class_name Platform
extends AnimatableBody2D
## Tek yönlü platform: alttan geçilir, üstüne basılır. Orijin üst yüzeyin ortasında.
## AnimatableBody2D (StaticBody2D'den türer): kayan platform fizik karesinde taşınır ve hızını
## bildirir; üstündeki CharacterBody2D (oyuncu) bu hızla birlikte taşınır. Sabit platformlar hiç oynamaz.
## Türler (PlatformTypeRules): normal, çatlayan (üstüne inilince çöker), kayan (yatay salınır), buz (kaygan).

var floor_number: int = 0
var width: float = 0.0
var kind: StringName = PlatformTypeRules.NORMAL
## Kayan platform: salınım genliği (px, merkezden bir yana), tam tur süresi (s), başlangıç fazı (rad).
var travel: float = 0.0
var _period: float = 1.0
var _phase: float = 0.0
var _elapsed: float = 0.0
var _base_x: float = 0.0
var _collider: CollisionShape2D
var _crumble: PlatformCrumble


## add_child'dan önce çağrılır; çarpışma şeklini ve görseli kurar.
func setup(p_floor_number: int, p_width: float, p_kind: StringName = PlatformTypeRules.NORMAL) -> void:
	floor_number = p_floor_number
	width = p_width
	kind = p_kind
	var size := Vector2(width, Tuning.PLATFORM_THICKNESS)
	var center := Vector2(0.0, size.y * 0.5)

	var shape := RectangleShape2D.new()
	shape.size = size
	_collider = CollisionShape2D.new()
	_collider.shape = shape
	_collider.position = center
	_collider.one_way_collision = true
	_collider.one_way_collision_margin = Tuning.PLATFORM_ONE_WAY_MARGIN
	add_child(_collider)

	var is_section: bool = PlatformRules.is_section_floor(floor_number)
	if is_section:
		add_child(_make_section_glow())
	if kind == PlatformTypeRules.MOVING:
		add_child(_make_type_art(true))
	add_child(make_visual())
	if kind != PlatformTypeRules.NORMAL:
		add_child(_make_type_art(false))
	if kind == PlatformTypeRules.CRUMBLE:
		_crumble = PlatformCrumble.new()
		_crumble.name = "Crumble"
		_crumble.setup(self, _collider)
		add_child(_crumble)


## Kayan platform: add_child'dan önce (setup'tan sonra) çağrılır.
func set_motion(p_travel: float, period: float, phase: float) -> void:
	travel = p_travel
	_period = period
	_phase = phase


func _ready() -> void:
	_base_x = position.x
	if kind == PlatformTypeRules.MOVING:
		position.x = _base_x + PlatformTypeRules.moving_offset(travel, _period, _phase, 0.0)


func _physics_process(delta: float) -> void:
	if kind != PlatformTypeRules.MOVING:
		return
	_elapsed += delta
	position.x = _base_x + PlatformTypeRules.moving_offset(travel, _period, _phase, _elapsed)


## Salınımın merkezi (kayan platformda; diğerlerinde konum).
func base_x() -> float:
	return _base_x if is_inside_tree() else position.x


## Platformun bu karedeki yatay hızı (px/s; görsel ipuçları için).
func motion_velocity() -> float:
	if kind != PlatformTypeRules.MOVING:
		return 0.0
	return travel * TAU / _period * cos(_phase + TAU * _elapsed / _period)


## Oyuncu üstüne indi (Player çağırır). Çatlayan platformun geri sayımını başlatır.
func notify_landed() -> void:
	if _crumble != null:
		_crumble.trigger()


## Hâlâ üstüne basılabilir mi? (Çöken çatlayan platform: hayır.)
func is_solid() -> bool:
	return _crumble == null or not _crumble.is_broken()


## Roket / kalp uçuşu oyuncuyu buraya bırakabilir mi?
func is_safe_landing() -> bool:
	return is_solid() and PlatformTypeRules.is_safe_landing(kind)


func ground_accel_factor() -> float:
	return PlatformTypeRules.ground_accel_factor(kind)


func ground_friction_factor() -> float:
	return PlatformTypeRules.ground_friction_factor(kind)


## Platformun görüntüsü (çatlayan platformun parçaları da aynı görüntünün kopyalarını kullanır).
func make_visual() -> PlatformVisual:
	var visual := PlatformVisual.new()
	visual.name = "Visual"
	if PlatformRules.is_section_floor(floor_number):
		visual.setup(width, WorldPalette.PLATFORM_SECTION, floor_number, WorldPalette.SECTION_PLATFORM_STYLE)
	else:
		visual.setup(width, theme_color(), floor_number,
				ThemeRules.platform_style(floor_number, Platform.style_roll),
				ThemeRules.platform_theme(floor_number))
	return visual


## Türün işaretleri (çatlak, buz tabakası, ray). behind: platformun arkasında çizilen katman (ray).
func _make_type_art(behind: bool) -> PlatformTypeArt:
	var art := PlatformTypeArt.new()
	art.name = "TypeArtBehind" if behind else "TypeArt"
	art.setup(self, behind)
	return art


## Platformun kendi katındaki tema rengi (geçiş bölgesinde iki tema arası).
func theme_color() -> Color:
	var theme_position: float = ThemeRules.position(float(floor_number))
	return WorldPalette.colors_at(theme_position)[&"platform"]


## Kata bağlı sabit rastgele sayı (0..1): aynı kat hep aynı stili alır.
static func style_roll(for_floor: int) -> float:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(for_floor * 7919 + 13)
	return rng.randf()


## Bölüm platformunun arkasında yumuşak, toplamalı sarı ışık hâlesi.
func _make_section_glow() -> Sprite2D:
	var glow := Sprite2D.new()
	glow.texture = SoftTextures.dot()
	glow.material = SoftTextures.additive()
	glow.modulate = Color(WorldPalette.PLATFORM_SECTION, Tuning.GLOW_SECTION_ALPHA)
	glow.scale = Vector2(width, Tuning.GLOW_SECTION_HEIGHT) / SoftTextures.DOT_SIZE
	glow.position = Vector2(0.0, Tuning.PLATFORM_THICKNESS * 0.5)
	return glow
