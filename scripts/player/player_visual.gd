class_name PlayerVisual
extends Node2D
## Karakterin görüntüsü ve efektleri. Player'ın sinyallerini dinler; fiziğe karışmaz.
## Gövde: 3D model (CharacterModel); model yoksa ya da kapalıysa kutu.
##
## Yapı:
##   Visual (ayaklarda)
##    ├─ Trail, SpeedLines (top_level: dünyada kalır; gövdeden önce eklenir → arkasında çizilir)
##    └─ Spin (gövde ortasında; döner → takla)
##        └─ Squash (gövdenin altında; ölçeklenir → dikken ayaklar yerde kalır,
##            │        takla sırasında gövde kendi boyu yönünde uzar/ezilir)
##            └─ Model (CharacterModel)  — ya da kutu gövde + göz

const BODY_COLOR := Color(1.0, 0.55, 0.15)
const EYE_COLOR := Color(0.12, 0.08, 0.05)
const EYE_SIZE := Vector2(8.0, 10.0)
## Gözün gövde ortasına göre konumu (x yüz dönülen yöne göre çevrilir).
const EYE_OFFSET := Vector2(8.0, -12.0)

var _spin: Node2D
var _squash: Node2D
var _eye: Polygon2D
var _model: CharacterModel
var _animator: ModelAnimator
var _facing: float = 1.0
## + boyuna uzama, - boyuna ezilme.
var _stretch: float = 0.0
var _stretch_velocity: float = 0.0
## Son efektin gücüne göre seçilen yay (zayıf efekt = yumuşak, yavaş yay).
var _spring_stiffness: float = Tuning.SQUASH_SPRING_STIFFNESS
var _spring_damping: float = Tuning.SQUASH_SPRING_DAMPING
var _flip_tween: Tween
var _bursts: ParticleBursts

@onready var _player: Player = get_parent() as Player


func _ready() -> void:
	_build()
	_apply_facing()
	_player.event.connect(_on_player_event)


func _process(delta: float) -> void:
	_update_facing()
	_update_wall_clearance()
	if _animator != null:
		_animator.update(delta, _player.is_on_floor(), _player.velocity, is_flipping())
	_update_squash(delta)


func is_flipping() -> bool:
	return _flip_tween != null and _flip_tween.is_running()


func _build() -> void:
	var use_model: bool = Tuning.USE_CHARACTER_MODEL and CharacterModel.is_available()
	# Takla ekseni: kutuda gövde ortası, modelde topak pozunun ortası.
	var half_height: float = Tuning.MODEL_SPIN_PIVOT_HEIGHT if use_model else Tuning.PLAYER_HEIGHT * 0.5
	_spin = Node2D.new()
	_spin.name = "Spin"
	_spin.position = Vector2(0.0, -half_height)
	add_child(_spin)

	_squash = Node2D.new()
	_squash.name = "Squash"
	_squash.position = Vector2(0.0, half_height)
	_spin.add_child(_squash)

	if use_model:
		_model = CharacterModel.new()
		_model.name = "Model"
		_squash.add_child(_model)
		_animator = ModelAnimator.new(_model)
	else:
		_build_box(half_height)
	_build_effects()


## Yedek gövde: model yokken kullanılan kutu ve göz.
func _build_box(half_height: float) -> void:
	var body_size := Vector2(Tuning.PLAYER_WIDTH, Tuning.PLAYER_HEIGHT)
	var body: Polygon2D = _make_rect(Vector2(0.0, -half_height), body_size, BODY_COLOR)
	_squash.add_child(body)
	_eye = _make_rect(Vector2.ZERO, EYE_SIZE, EYE_COLOR)
	_squash.add_child(_eye)


## Efektler gövdeden (Spin) önceye yerleştirilir: ağaç sırasıyla gövdenin arkasında çizilir.
## Sıra (arkadan öne): hâle, iz, hız çizgileri, parçacıklar, gövde.
func _build_effects() -> void:
	var aura := PlayerAura.new()
	aura.name = "Aura"
	aura.player = _player

	var trail := SmoothTrail.new()
	trail.name = "Trail"
	trail.trail_color = BODY_COLOR
	trail.player = _player

	var speed_lines := SpeedLines.new()
	speed_lines.name = "SpeedLines"
	speed_lines.player = _player

	_bursts = ParticleBursts.new()
	_bursts.name = "Bursts"

	var effects: Array[Node] = [aura, trail, speed_lines, _bursts]
	for i in effects.size():
		add_child(effects[i])
		move_child(effects[i], i)


func _update_facing() -> void:
	var vx: float = _player.velocity.x
	if absf(vx) > Tuning.RUN_STATE_MIN_SPEED and signf(vx) != _facing:
		_facing = signf(vx)
		_apply_facing()


## Model hitbox'tan geniş: duvara yaslanınca görüntü duvarın içine girmesin diye içeri kayar.
func _update_wall_clearance() -> void:
	if _model == null:
		return
	_spin.position.x = WallClearance.offset_x(_player.global_position.x,
			Tuning.MODEL_WALL_HALF_WIDTH, Tuning.TOWER_WIDTH * 0.5)


func _apply_facing() -> void:
	if _model != null:
		_model.set_facing(_facing)
	elif _eye != null:
		# Göz, Squash'ın (gövde altı) koordinatında: gövde ortası -yarım boy.
		_eye.position = Vector2(EYE_OFFSET.x * _facing, EYE_OFFSET.y - Tuning.PLAYER_HEIGHT * 0.5)


# --- Squash & stretch ---

## Yay, havadayken dikey hıza göre hafif bir uzamaya, yerdeyken 0'a doğru çeker.
func _update_squash(delta: float) -> void:
	var target: float = 0.0
	if not _player.is_on_floor() and not is_flipping():
		target = absf(_player.velocity.y) / Tuning.MAX_FALL_SPEED * Tuning.AIR_STRETCH_MAX
	var result: Vector2 = Spring.step(_stretch, _stretch_velocity, target,
			_spring_stiffness, _spring_damping, delta)
	_stretch = result.x
	_stretch_velocity = result.y
	_apply_stretch()


## Gövde alanı korunur: boy (1 + s), en 1 / boy.
func _apply_stretch() -> void:
	var height_scale: float = 1.0 + clampf(_stretch, -Tuning.SQUASH_LIMIT, Tuning.SQUASH_LIMIT)
	_squash.scale = Vector2(1.0 / height_scale, height_scale)


## Uzamayı anında bu değere ayarlar; yay oradan geri döndürür.
## strength (0..1): efektin gücü; zayıf efektler daha yumuşak, yavaş bir yayla döner.
func _kick(amount: float, strength: float) -> void:
	_stretch = clampf(amount, -Tuning.SQUASH_LIMIT, Tuning.SQUASH_LIMIT)
	_stretch_velocity = 0.0
	_spring_stiffness = lerpf(Tuning.SQUASH_SPRING_STIFFNESS_SOFT, Tuning.SQUASH_SPRING_STIFFNESS,
			clampf(strength, 0.0, 1.0))
	# Sönüm/√sertlik oranı sabit kalsın: yay yumuşasa da aynı karakterde sallansın.
	_spring_damping = Tuning.SQUASH_SPRING_DAMPING * sqrt(_spring_stiffness / Tuning.SQUASH_SPRING_STIFFNESS)
	_apply_stretch()


## Zıplama gücü: duran zıplama 0, tam hızda zıplama 1.
func _jump_strength(jump_speed: float) -> float:
	var max_jump: float = Player.jump_speed_for(Tuning.MAX_RUN_SPEED)
	return clampf(inverse_lerp(Tuning.JUMP_BASE, max_jump, jump_speed), 0.0, 1.0)


## İniş gücü: LAND_SQUASH_MIN_SPEED'de 0, LAND_SQUASH_FULL_SPEED ve üstünde 1.
func _land_strength(fall_speed: float) -> float:
	return clampf(inverse_lerp(Tuning.LAND_SQUASH_MIN_SPEED, Tuning.LAND_SQUASH_FULL_SPEED, fall_speed),
			0.0, 1.0)


# --- Takla ---

## Gövdeyi `direction` yönünde, yukarı hıza göre belirlenen süre ve tur sayısıyla döndürür.
func _start_flip(up_speed: float, direction: float, from_wall: bool = false) -> void:
	if _animator != null:
		_animator.on_flip_started(from_wall)
	var duration: float = FlipRules.duration_for(up_speed)
	var turns: int = FlipRules.turns_for(duration)
	_kill_flip()
	var start: float = wrapf(_spin.rotation, -PI, PI)
	_spin.rotation = start
	_flip_tween = create_tween()
	_flip_tween.tween_property(_spin, ^"rotation", start + direction * turns * TAU, duration) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


## İnişte açı sıfırlanır: takla bitmediyse en yakın dik konuma hızla döner.
func _reset_flip_on_landing() -> void:
	_kill_flip()
	var angle: float = wrapf(_spin.rotation, -PI, PI)
	_spin.rotation = angle
	if is_zero_approx(angle):
		return
	_flip_tween = create_tween()
	_flip_tween.tween_property(_spin, ^"rotation", 0.0, Tuning.FLIP_LAND_RESET_TIME)


func _kill_flip() -> void:
	if _flip_tween != null:
		_flip_tween.kill()
		_flip_tween = null


# --- Olaylar ---

func _on_player_event(event_name: StringName, data: Dictionary) -> void:
	match event_name:
		&"jumped":
			_on_jumped(data["speed"])
		&"landed":
			_on_landed(data["speed"])
		&"wall_bounce":
			_on_wall_bounce(data)


func _on_jumped(jump_speed: float) -> void:
	var t: float = _jump_strength(jump_speed)
	_kick(lerpf(Tuning.JUMP_STRETCH_MIN, Tuning.JUMP_STRETCH_MAX, t), t)
	if FlipRules.jump_triggers_flip(jump_speed, GameState.combo_jumps > 0):
		_start_flip(jump_speed, FlipRules.direction_for(_player.velocity.x, _facing))
	if _animator != null:
		_animator.on_jumped(t)


func _on_landed(fall_speed: float) -> void:
	_reset_flip_on_landing()
	if _animator != null:
		_animator.on_landed(fall_speed)
	if fall_speed >= Tuning.LAND_SQUASH_MIN_SPEED:
		var t: float = _land_strength(fall_speed)
		_kick(-t * Tuning.LAND_SQUASH_MAX, t)
	if fall_speed >= Tuning.LAND_DUST_MIN_SPEED:
		var dust: float = clampf(inverse_lerp(Tuning.LAND_DUST_MIN_SPEED, Tuning.LAND_DUST_FULL_SPEED,
				fall_speed), 0.0, 1.0)
		_bursts.land_dust(_player.global_position, dust)
	var land_shake: float = CameraShake.land_trauma(fall_speed)
	if land_shake > 0.0:
		Events.screen_shake.emit(land_shake)


func _on_wall_bounce(data: Dictionary) -> void:
	var t: float = clampf(data["speed"] / Tuning.MAX_RUN_SPEED, 0.0, 1.0)
	_kick(t * Tuning.WALL_SQUASH_MAX, t)
	# Çarpma noktası: gövdenin duvar tarafındaki kenarı (duvar normalin tersinde).
	var normal_x: float = data["normal_x"]
	var contact: Vector2 = _player.global_position + Vector2(
			-normal_x * Tuning.PLAYER_WIDTH * 0.5, -Tuning.PLAYER_HEIGHT * 0.5)
	_bursts.wall_sparks(contact, normal_x, t)
	Events.screen_shake.emit(CameraShake.wall_trauma(data["speed"]))
	if data["airborne"]:
		# Sekme sonrası gidilen yön = duvarın normali.
		_start_flip(-_player.velocity.y, signf(data["normal_x"]), true)


func _make_rect(center: Vector2, size: Vector2, color: Color) -> Polygon2D:
	var half: Vector2 = size * 0.5
	var polygon := Polygon2D.new()
	polygon.color = color
	polygon.position = center
	polygon.polygon = PackedVector2Array([
		Vector2(-half.x, -half.y), Vector2(half.x, -half.y),
		Vector2(half.x, half.y), Vector2(-half.x, half.y),
	])
	return polygon
