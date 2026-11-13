class_name ReviveCard
extends UiScreen
## "Elmasla devam" kartı: kalbi olmayan oyuncu düşünce (hak ve elmas yetiyorsa) oyun sonundan önce çıkar.
## Dünya donar (GameFlow REVIVE). Ortada atan büyük kalp ve eriyen süre halkası, altında fiyat ve
## "DEVAM ET"; sağ üstte bakiye. Açılınca REVIVE_INPUT_DELAY boyunca girişler yutulur (düşerken basılan
## Space satın almasın); sonra REVIVE_OFFER_TIME sayılır. Kabul (Enter/Space, düğme ya da kalbe tıklama):
## elmas harcanır, kalp parlayıp patlar, `accepted` → main oyuncuyu roketle kurtarır. Ret (Esc, "Geç")
## ya da süre dolması: kalp söner, `declined` → main oyunu bitirir. Pencere odağı yokken süre işlemez
## ("odak kaybında duraklat" ayarı açıksa).

signal accepted
signal declined

enum Phase { IDLE, LOCKED, COUNTING, ACCEPTING, CLOSING }

const CARD_WIDTH: float = 250.0
const DIM_ALPHA: float = 0.35
const PRICE_FONT_SIZE: int = 26
const WALLET_FONT_SIZE: int = 14
const PRICE_ICON_SCALE: float = 1.0
## Redde kalbin sönme süresi (s); ardından kart kapanır ve oyun sonu gelir.
const DECLINE_TIME: float = 0.3

var _phase: Phase = Phase.IDLE
var _heart: ReviveHeart
var _price_label: Label
var _accept_button: UiButton
var _skip_button: UiButton
var _lock_left: float = 0.0
var _elapsed: float = 0.0
var _last_ticks: int = 0
var _window_focused: bool = true


func _init() -> void:
	super()
	dim_alpha = DIM_ALPHA
	content.custom_minimum_size.x = CARD_WIDTH
	content.add_theme_constant_override(&"separation", 8)
	var wallet := DiamondCounter.new(WALLET_FONT_SIZE)
	wallet.size_flags_horizontal = Control.SIZE_SHRINK_END
	content.add_child(wallet)
	_heart = ReviveHeart.new()
	_heart.clicked.connect(_accept)
	content.add_child(_heart)
	content.add_child(_price_row())
	content.add_child(UiStyle.spacer(2.0))
	_accept_button = UiButton.new("DEVAM ET", true)
	_accept_button.pressed.connect(_accept)
	content.add_child(_accept_button)
	first_focus = _accept_button
	_skip_button = UiButton.new("Geç", false, true, true)
	_skip_button.pressed.connect(_decline)
	content.add_child(_skip_button)


## Koşullar uygunsa kartı açar (dünya donar) ve true döner; değilse hiçbir şey yapmaz.
func offer() -> bool:
	if _phase != Phase.IDLE or not ReviveRules.is_enabled():
		return false
	if not ReviveRules.can_offer(GameState.revives_used, GameState.diamonds):
		return false
	if not GameFlow.request(FlowRules.State.REVIVE):
		return false
	_price_label.text = str(ReviveRules.price(GameState.revives_used))
	_phase = Phase.LOCKED
	_lock_left = Tuning.REVIVE_INPUT_DELAY
	_elapsed = 0.0
	_last_ticks = Time.get_ticks_usec()
	_heart.reset()
	open()
	AudioManager.play(&"revive_offer", 1.0, Tuning.SFX_REVIVE_OFFER_DB)
	return true


func is_offering() -> bool:
	return _phase != Phase.IDLE


func _process(_delta: float) -> void:
	# Gerçek zaman: yavaş çekim / hit-stop (Engine.time_scale) sayımı uzatmasın.
	var now: int = Time.get_ticks_usec()
	var real_delta: float = (now - _last_ticks) / 1000000.0
	_last_ticks = now
	if not _window_focused:
		return
	match _phase:
		Phase.LOCKED:
			_lock_left -= real_delta
			if _lock_left <= 0.0:
				_unlock()
		Phase.COUNTING:
			_elapsed += real_delta
			_heart.ratio = ReviveRules.time_left_ratio(_elapsed)
			if _heart.ratio <= 0.0:
				_decline()


## Giriş kilidi: kilitliyken ve kapanırken tüm tuş/tık olayları yutulur; basılı tutulan tuşun
## tekrarları (echo) hiç sayılmaz — yalnız kilit bittikten sonraki taze basış kabul edilir. Düğmeler
## basışı görmediği için kilitten sonra gelen bırakış da onları tetiklemez (devre dışı bırakmaya gerek yok).
func _input(input_event: InputEvent) -> void:
	if _phase == Phase.IDLE:
		return
	var is_button: bool = input_event is InputEventKey or input_event is InputEventMouseButton \
			or input_event is InputEventJoypadButton
	if is_button and (_phase != Phase.COUNTING or input_event.is_echo()):
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	# Odak kaybında duraklatma ayarı açıksa (PauseController gibi) pencere odakta değilken süre durur.
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and GameSettings.get_setting("pause_on_focus_loss"):
		_window_focused = false
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		_window_focused = true
		_last_ticks = Time.get_ticks_usec()


## Esc: reddet (kilit sürerken olay zaten yutulur).
func _on_cancel() -> void:
	if _phase == Phase.COUNTING:
		_decline()


func _unlock() -> void:
	_phase = Phase.COUNTING
	_accept_button.focus_silently()


func _accept() -> void:
	if _phase != Phase.COUNTING:
		return
	if not GameState.use_revive():
		_decline()
		return
	_phase = Phase.ACCEPTING
	AudioManager.play(&"revive", 1.0, Tuning.SFX_REVIVE_DB)
	_heart.burst(Tuning.REVIVE_ACCEPT_TIME)
	await get_tree().create_timer(Tuning.REVIVE_ACCEPT_TIME).timeout
	_finish()
	GameFlow.request(FlowRules.State.PLAYING)
	accepted.emit()


func _decline() -> void:
	if _phase != Phase.COUNTING:
		return
	_phase = Phase.CLOSING
	_heart.fade(DECLINE_TIME)
	await get_tree().create_timer(DECLINE_TIME).timeout
	_finish()
	declined.emit()


func _finish() -> void:
	_phase = Phase.IDLE
	close()


## Fiyat: elmas simgesi + sayı (ortada).
func _price_row() -> Control:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override(&"separation", 6)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var icon := Control.new()
	icon.custom_minimum_size = Vector2(DiamondArt.HALF_WIDTH * 2.0 + 4.0, PRICE_FONT_SIZE * 1.2) * PRICE_ICON_SCALE
	icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.draw.connect(func() -> void:
		var middle: float = (DiamondArt.TOP + DiamondArt.TIP) * 0.5 * PRICE_ICON_SCALE
		DiamondArt.draw(icon, icon.size * 0.5 - Vector2(0.0, middle), PRICE_ICON_SCALE))
	row.add_child(icon)
	_price_label = UiStyle.label(PRICE_FONT_SIZE, DiamondArt.LIGHT)
	_price_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(_price_label)
	return row
