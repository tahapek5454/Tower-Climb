extends GutTest
## Oynanış ayarlarının (GameSettings) varsayılan ve kayıt davranışı. Geçici dosya kullanılır.

const TEMP: String = "user://test_game_settings.cfg"

var _saved_path: String
var _saved_audio_path: String


func before_each() -> void:
	_saved_path = GameSettings.path
	_saved_audio_path = AudioSettings.path
	GameSettings.path = TEMP
	AudioSettings.path = TEMP
	_remove()


func after_each() -> void:
	_remove()
	GameSettings.path = _saved_path
	AudioSettings.path = _saved_audio_path


func test_defaults_when_file_missing() -> void:
	assert_eq(GameSettings.load_all(), GameSettings.DEFAULTS)
	assert_true(GameSettings.load_all()["pause_on_focus_loss"], "odak kaybında duraklatma varsayılan açık")


func test_saved_value_round_trips_and_keeps_other_sections() -> void:
	AudioSettings.save_value("music_volume", 0.3)
	GameSettings.save_value("pause_on_focus_loss", false)
	assert_false(GameSettings.load_all()["pause_on_focus_loss"])
	assert_almost_eq(float(AudioSettings.load_all()["music_volume"]), 0.3, 0.001, "ses bölümüne dokunulmaz")


func test_wrong_type_falls_back_to_default() -> void:
	var config := ConfigFile.new()
	config.set_value(GameSettings.SECTION, "pause_on_focus_loss", "evet")
	config.save(TEMP)
	assert_true(GameSettings.load_all()["pause_on_focus_loss"])


func _remove() -> void:
	if FileAccess.file_exists(TEMP):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEMP))
