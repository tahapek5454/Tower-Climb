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
	AudioManager.play(&"game_over", 1.0, Tuning.SFX_GAME_OVER_DB)


## Sık çalan sesler için küçük rastgele perde sapmasıyla çalar.
func _play(sound: StringName, pitch: float, volume_db: float) -> void:
	AudioManager.play(sound, SfxRules.jitter_pitch(pitch, _rng.randf()), volume_db)
