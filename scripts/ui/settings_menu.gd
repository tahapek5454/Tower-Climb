class_name SettingsMenu
extends UiScreen
## Ayarlar ekranı (ana menüden ve duraklatma menüsünden açılır): ses seviyeleri (genel / efekt / müzik),
## tümünü sustur, tam ekran, ekran sarsıntısı, odak kaybında duraklatma; müzik klasörünü aç,
## kontroller sayfası, rekorları sıfırla (onaylı). Her değişiklik anında uygulanır ve kaydedilir.
## Radyo paneli ve M / F11 tuşlarıyla senkron kalır (AudioManager / WindowManager sinyalleri).

const CARD_WIDTH: float = 470.0
const SLIDER_WIDTH: float = 220.0
const TITLE_FONT_SIZE: int = 28
const STATUS_FONT_SIZE: int = 12
const STATUS_HEIGHT: float = 16.0
const STATUS_TIME: float = 2.6

var _master: UiSlider
var _sfx: UiSlider
var _music_slider: UiSlider
var _mute: UiToggle
var _fullscreen: UiToggle
var _shake: UiToggle
var _focus_pause: UiToggle
var _tools_row: HBoxContainer
var _confirm_row: HBoxContainer
var _reset_button: UiButton
var _cancel_reset_button: UiButton
var _status: Label
var _status_tween: Tween
var _controls: ControlsMenu


func _init() -> void:
	super()
	# Kontroller sayfası alt ekran; "Kontroller" düğmesi oluşmadan önce hazır olmalı.
	_controls = ControlsMenu.new()
	_controls.name = "Controls"
	add_child(_controls)
	content.custom_minimum_size.x = CARD_WIDTH
	content.add_theme_constant_override(&"separation", 7)
	var title: Label = UiStyle.label(TITLE_FONT_SIZE, UiStyle.TEXT, HORIZONTAL_ALIGNMENT_CENTER)
	title.text = "AYARLAR"
	content.add_child(title)

	content.add_child(UiStyle.section_label("Ses"))
	_master = _add_slider("Genel ses", _on_master_changed, _on_master_committed)
	_sfx = _add_slider("Efekt sesi", _on_sfx_changed, _on_sfx_committed)
	_music_slider = _add_slider("Müzik sesi", _on_music_changed, _on_music_committed)
	_mute = _add_toggle("Tümünü sustur", AudioManager.set_muted)

	content.add_child(UiStyle.section_label("Oyun"))
	_fullscreen = _add_toggle("Tam ekran", WindowManager.set_fullscreen)
	_shake = _add_toggle("Ekran sarsıntısı", func(on: bool) -> void: GameSettings.save_value("screen_shake", on))
	_focus_pause = _add_toggle("Pencere arka plana geçince duraklat",
			func(on: bool) -> void: GameSettings.save_value("pause_on_focus_loss", on))

	content.add_child(UiStyle.spacer(2.0))
	_build_tools()
	_build_confirm()
	_status = UiStyle.label(STATUS_FONT_SIZE, UiStyle.ACCENT, HORIZONTAL_ALIGNMENT_CENTER)
	_status.custom_minimum_size.y = STATUS_HEIGHT
	content.add_child(_status)
	var back := UiButton.new("Geri", true, true)
	back.pressed.connect(_on_cancel)
	content.add_child(back)
	first_focus = _master

	AudioManager.muted_changed.connect(func(muted: bool) -> void: _mute.set_on(muted))
	AudioManager.volume_changed.connect(_on_bus_volume_changed)
	if AudioManager.music != null:
		AudioManager.music.volume_changed.connect(func(value: float) -> void: _music_slider.value = value)
	WindowManager.fullscreen_changed.connect(func(enabled: bool) -> void: _fullscreen.set_on(enabled))


func open() -> void:
	if is_open:
		return
	_sync_widgets()
	_show_tools()
	_status.text = ""
	super()


func _on_cancel() -> void:
	# Onay açıkken Esc / Geri önce onayı kapatır.
	if _confirm_row.visible:
		_show_tools()
		_reset_button.focus_silently()
		return
	back_requested.emit()


## Denetimleri o anki gerçek değerlere getirir (sinyal yaymadan).
func _sync_widgets() -> void:
	_master.value = AudioManager.master_volume
	_sfx.value = AudioManager.sfx_volume
	_music_slider.value = AudioManager.music.volume if AudioManager.music != null else 0.0
	_mute.set_on(AudioManager.is_muted(), false)
	_fullscreen.set_on(WindowManager.is_fullscreen(), false)
	_shake.set_on(GameSettings.get_setting("screen_shake"), false)
	_focus_pause.set_on(GameSettings.get_setting("pause_on_focus_loss"), false)


func _add_slider(caption: String, on_changed: Callable, on_committed: Callable) -> UiSlider:
	var slider := UiSlider.new()
	slider.value_changed.connect(on_changed)
	slider.value_committed.connect(on_committed)
	content.add_child(UiStyle.row(caption, slider, SLIDER_WIDTH))
	return slider


func _add_toggle(caption: String, on_toggled: Callable) -> UiToggle:
	var toggle := UiToggle.new()
	toggle.toggled.connect(on_toggled)
	content.add_child(UiStyle.row(caption, toggle))
	return toggle


func _build_tools() -> void:
	_tools_row = HBoxContainer.new()
	_tools_row.add_theme_constant_override(&"separation", 8)
	if MusicLibrary.is_available():
		_add_tool("Müzik klasörü", MusicLibrary.open_dir, "Müzik klasörünü dosya gezgininde aç")
	var controls_button: UiButton = _add_tool("Kontroller", Callable())
	link_child(_controls, controls_button.pressed)
	_reset_button = _add_tool("Rekorları sıfırla", _ask_reset, "Kayıtlı tüm rekorları sil")
	content.add_child(_tools_row)


func _add_tool(text: String, action: Callable, tip: String = "") -> UiButton:
	var button := UiButton.new(text, false, false, true)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.tooltip_text = tip
	if action.is_valid():
		button.pressed.connect(action)
	_tools_row.add_child(button)
	return button


func _build_confirm() -> void:
	_confirm_row = HBoxContainer.new()
	_confirm_row.add_theme_constant_override(&"separation", 8)
	_confirm_row.visible = false
	var question: Label = UiStyle.label(14, UiStyle.COMBO)
	question.text = "Tüm rekorlar silinsin mi?"
	question.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	question.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_confirm_row.add_child(question)
	var yes := UiButton.new("Evet, sil", false, false, true)
	yes.pressed.connect(_do_reset)
	_confirm_row.add_child(yes)
	_cancel_reset_button = UiButton.new("Vazgeç", true, true, true)
	_cancel_reset_button.pressed.connect(func() -> void:
		_show_tools()
		_reset_button.focus_silently())
	_confirm_row.add_child(_cancel_reset_button)
	content.add_child(_confirm_row)


func _ask_reset() -> void:
	_tools_row.visible = false
	_confirm_row.visible = true
	_cancel_reset_button.focus_silently()


func _show_tools() -> void:
	_tools_row.visible = true
	_confirm_row.visible = false


func _do_reset() -> void:
	GameState.reset_records()
	_show_tools()
	_reset_button.focus_silently()
	_flash("Rekorlar sıfırlandı")


## Kısa bir bilgi satırı gösterir, biraz sonra siler.
func _flash(text: String) -> void:
	_status.text = text
	_status.modulate.a = 1.0
	if _status_tween != null:
		_status_tween.kill()
	_status_tween = create_tween()
	_status_tween.tween_interval(STATUS_TIME)
	_status_tween.tween_property(_status, ^"modulate:a", 0.0, 0.4)


func _preview_click() -> void:
	AudioManager.play(&"ui_click", 1.0, Tuning.UI_CLICK_DB)


func _on_master_changed(value: float) -> void:
	AudioManager.set_master_volume(value, false)


func _on_master_committed(value: float) -> void:
	AudioManager.set_master_volume(value)
	_preview_click()


func _on_sfx_changed(value: float) -> void:
	AudioManager.set_sfx_volume(value, false)


func _on_sfx_committed(value: float) -> void:
	AudioManager.set_sfx_volume(value)
	_preview_click()


func _on_music_changed(value: float) -> void:
	if AudioManager.music != null:
		AudioManager.music.set_volume(value, false)


func _on_music_committed(value: float) -> void:
	if AudioManager.music != null:
		AudioManager.music.set_volume(value)


## Başka yerden (ör. kısayol) değişen genel/efekt seviyesi kaydırıcıya yansır.
func _on_bus_volume_changed(bus_name: StringName, value: float) -> void:
	if bus_name == &"Master":
		_master.value = value
	elif bus_name == AudioManager.SFX_BUS:
		_sfx.value = value
