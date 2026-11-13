class_name GameAudio
extends Node
## Oyun olaylarını ses efektlerine bağlar: oyuncu olayları (zıplama, iniş, duvar) ve Events sinyalleri
## (kombo, bölüm, oyun sonu). Perde/ses kuralları SfxRules'ta; çalma AudioManager'da.

var player: Player
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	if player != null:
		player.event.connect(_on_player_event)
	Events.combo_changed.connect(_on_combo_changed)
	Events.combo_ended.connect(_on_combo_ended)
	Events.floor_changed.connect(_on_floor_changed)
	Events.game_over.connect(_on_game_over)
	Events.pickup_collected.connect(_on_pickup_collected)
	Events.powerup_started.connect(_on_powerup_started)
	Events.powerup_ended.connect(_on_powerup_ended)
	Events.hearts_changed.connect(_on_hearts_changed)


func _on_player_event(event_name: StringName, data: Dictionary) -> void:
	# Menüdeki kendiliğinden zıplamalar sessiz.
	if not GameFlow.is_playing():
		return
	match event_name:
		&"jumped":
			var speed: float = data["speed"]
			_play(&"jump", SfxRules.jump_pitch(speed), SfxRules.jump_volume_db(speed))
			if SfxRules.is_big_jump(speed):
				_play(&"whoosh", 1.0, Tuning.SFX_WHOOSH_DB)
		&"landed":
			var fall: float = data["speed"]
			if SfxRules.should_play_land(fall):
				_play(&"land", SfxRules.land_pitch(fall), SfxRules.land_volume_db(fall))
		&"wall_bounce":
			_play(&"wall", 1.0, SfxRules.wall_volume_db(data["speed"]))
		&"rescued":
			AudioManager.play(&"rescue", 1.0, Tuning.SFX_RESCUE_DB)


func _on_combo_changed(jumps: int, _floors: int) -> void:
	if jumps >= 1:
		AudioManager.play(&"combo", SfxRules.combo_pitch(jumps), Tuning.SFX_COMBO_DB)


func _on_combo_ended(_jumps: int, _floors: int, bonus: int) -> void:
	if bonus > 0:
		AudioManager.play(&"combo_end", 1.0, Tuning.SFX_COMBO_END_DB)


func _on_floor_changed(floor_number: int) -> void:
	if PlatformRules.is_section_floor(floor_number):
		AudioManager.play(&"section", 1.0, Tuning.SFX_SECTION_DB)


func _on_game_over(_score: int, _floor: int) -> void:
	# Rekor kırıldıysa üzgün "game over" yerine fanfar.
	if GameState.new_records.is_empty():
		AudioManager.play(&"game_over", 1.0, Tuning.SFX_GAME_OVER_DB)
	else:
		AudioManager.play(&"record", 1.0, Tuning.SFX_RECORD_DB)


func _on_pickup_collected(kind: StringName, _world_position: Vector2) -> void:
	match kind:
		Pickup.DIAMOND:
			_play(&"diamond", 1.0, Tuning.SFX_DIAMOND_DB)
		Pickup.HOURGLASS:
			pass  # yavaşlama sesi powerup_started'da çalar
		Pickup.HEART:
			# Kalp sesi kalp sayısı artınca çalar (_on_hearts_changed); kalpler doluysa sayı artmaz.
			if GameState.hearts >= Tuning.HEART_MAX:
				AudioManager.play(&"pickup", 1.0, Tuning.SFX_PICKUP_DB)
		_:
			AudioManager.play(&"pickup", 1.0, Tuning.SFX_PICKUP_DB)


func _on_hearts_changed(_hearts: int, change: int) -> void:
	if change > 0 and GameFlow.is_playing():
		AudioManager.play(&"heart", 1.0, Tuning.SFX_HEART_DB)


func _on_powerup_started(kind: StringName, _duration: float) -> void:
	match kind:
		Pickup.JETPACK:
			AudioManager.play(&"jetpack", 1.0, Tuning.SFX_JETPACK_DB)
		Pickup.HOURGLASS:
			AudioManager.play(&"hourglass", 1.0, Tuning.SFX_HOURGLASS_DB)


func _on_powerup_ended(kind: StringName) -> void:
	if not GameFlow.is_playing():
		return
	match kind:
		Pickup.JETPACK:
			AudioManager.play(&"jetpack_end", 1.0, Tuning.SFX_JETPACK_END_DB)
		Pickup.HOURGLASS:
			AudioManager.play(&"hourglass_end", 1.0, Tuning.SFX_HOURGLASS_END_DB)


## Sık çalan sesler için küçük rastgele perde sapmasıyla çalar.
func _play(sound: StringName, pitch: float, volume_db: float) -> void:
	AudioManager.play(sound, SfxRules.jitter_pitch(pitch, _rng.randf()), volume_db)
