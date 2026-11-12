class_name RadioPanel
extends CanvasLayer
## Radyo paneli: oyuncunun müziklerini çalar (AudioManager.music). Kulenin sol dışında, sol altın biraz
## üstünde; genişlik kule dışındaki alandan türetilir (TOWER_WIDTH değişirse uyar). Fare üstünde değilken
## saydam, gelince yumuşakça tam görünür. Web'de oluşturulmaz (main.gd).
## Satırlar: nota + kayan parça adı + sıra · ilerleme çizgisi · önceki/çal/sonraki + ses + seviye.

const LAYER: int = 50

var _music: MusicPlayer
var _box: Control
var _title: MarqueeLabel
var _play: RadioIconButton
var _prev: RadioIconButton
var _next: RadioIconButton
var _volume_icon: RadioIconButton
var _slider: MiniSlider
var _position_text: String = ""


func _ready() -> void:
	layer = LAYER
	_music = AudioManager.music
	_build()
	_music.track_changed.connect(_on_track_changed)
	_music.playing_changed.connect(_on_playing_changed)
	_music.library_changed.connect(func(_count: int) -> void: _refresh())
	_refresh()


func _process(delta: float) -> void:
	var hovered: bool = _box.get_global_rect().has_point(_box.get_global_mouse_position())
	var target: float = 1.0 if hovered else Tuning.RADIO_IDLE_ALPHA
	_box.modulate.a = lerpf(_box.modulate.a, target, 1.0 - exp(-Tuning.RADIO_FADE_SPEED * delta))
	if _music.is_playing():
		_box.queue_redraw()


func _build() -> void:
	var side: float = (Tuning.VIEW_WIDTH - Tuning.TOWER_WIDTH) * 0.5 - Tuning.WALL_THICKNESS
	var width: float = side - Tuning.RADIO_SIDE_PADDING * 2.0
	var height: float = Tuning.RADIO_HEIGHT
	_box = Control.new()
	_box.name = "Radio"
	_box.anchor_top = 1.0
	_box.anchor_bottom = 1.0
	_box.offset_left = Tuning.RADIO_SIDE_PADDING
	_box.offset_right = Tuning.RADIO_SIDE_PADDING + width
	_box.offset_bottom = -Tuning.RADIO_BOTTOM_OFFSET
	_box.offset_top = -Tuning.RADIO_BOTTOM_OFFSET - height
	_box.mouse_filter = Control.MOUSE_FILTER_STOP
	_box.modulate.a = Tuning.RADIO_IDLE_ALPHA
	_box.draw.connect(_draw_box)
	add_child(_box)

	_title = MarqueeLabel.new()
	_title.position = Vector2(22.0, 5.0)
	_title.size = Vector2(width - 22.0 - 26.0, 15.0)
	_title.font_size = 11
	_title.color = RadioStyle.TEXT
	_box.add_child(_title)

	var row_y: float = height - 26.0
	_prev = _add_button(&"prev", 16.0, Vector2(8.0, row_y + 3.0), _music.previous_track)
	_play = _add_button(&"play", 22.0, Vector2(28.0, row_y), _music.toggle_play, true)
	_next = _add_button(&"next", 16.0, Vector2(54.0, row_y + 3.0), _music.next_track)
	_volume_icon = _add_button(&"volume", 14.0, Vector2(76.0, row_y + 4.0), _toggle_music_mute)

	_slider = MiniSlider.new()
	_slider.position = Vector2(92.0, row_y + 5.0)
	_slider.size = Vector2(width - 92.0 - 6.0, 12.0)
	_slider.value = _music.volume
	_slider.value_changed.connect(func(value: float) -> void: _music.set_volume(value, false); _update_volume_icon())
	_slider.value_committed.connect(func(value: float) -> void: _music.set_volume(value))
	_box.add_child(_slider)


func _add_button(kind: StringName, button_size: float, at: Vector2, action: Callable,
		filled: bool = false) -> RadioIconButton:
	var button := RadioIconButton.new(kind, button_size, filled)
	button.position = at
	button.pressed.connect(action)
	_box.add_child(button)
	return button


## Ses simgesi: müziği kısar (seviye 0) ya da önceki seviyeye döner.
func _toggle_music_mute() -> void:
	if _music.volume > 0.001:
		_box.set_meta(&"volume_before_mute", _music.volume)
		_music.set_volume(0.0)
	else:
		_music.set_volume(_box.get_meta(&"volume_before_mute", AudioSettings.DEFAULTS["music_volume"]))
	_slider.value = _music.volume
	_update_volume_icon()


func _update_volume_icon() -> void:
	_volume_icon.set_kind(&"volume_off" if _music.volume <= 0.001 else &"volume")


func _refresh() -> void:
	var has_music: bool = not _music.playlist.is_empty()
	for button: RadioIconButton in [_prev, _play, _next]:
		button.enabled = has_music
	_on_track_changed(_music.current_title(), _music.playlist.position_text())
	_on_playing_changed(_music.is_playing())
	_update_volume_icon()


func _on_track_changed(title: String, position_text: String) -> void:
	_position_text = position_text
	if title == "":
		_title.text = "Müzik yok · klasöre ekle"
		_title.color = RadioStyle.TEXT_DIM
	else:
		_title.text = title
		_title.color = RadioStyle.TEXT
	_box.queue_redraw()


func _on_playing_changed(playing: bool) -> void:
	_play.set_kind(&"pause" if playing else &"play")


## Zemin, nota, sıra yazısı ve ilerleme çizgisi.
func _draw_box() -> void:
	var rect := Rect2(Vector2.ZERO, _box.size)
	var style := StyleBoxFlat.new()
	style.bg_color = RadioStyle.PANEL
	style.border_color = RadioStyle.BORDER
	style.set_border_width_all(1)
	style.set_corner_radius_all(10)
	_box.draw_style_box(style, rect)
	RadioStyle.icon(_box, &"note", Vector2(13.0, 12.5), 11.0, RadioStyle.ACCENT)
	var font: Font = _box.get_theme_default_font()
	if _position_text != "":
		_box.draw_string(font, Vector2(rect.size.x - 24.0, 16.5), _position_text, HORIZONTAL_ALIGNMENT_RIGHT,
				18.0, 9, RadioStyle.TEXT_DIM)
	var y: float = 25.0
	var left: float = 8.0
	var right: float = rect.size.x - 8.0
	_box.draw_line(Vector2(left, y), Vector2(right, y), RadioStyle.TRACK, 2.0, true)
	if not _music.playlist.is_empty():
		_box.draw_line(Vector2(left, y), Vector2(lerpf(left, right, _music.progress()), y), RadioStyle.ACCENT, 2.0, true)
