class_name TowerCamera
extends Camera2D
## Kule kamerası: CAMERA_START_FLOOR'a kadar bekler, sonra hızlanarak yukarı kayar (zamanla ve her bölüm
## geçişinde; bkz. CameraRules.scroll_speed).
## Oyuncu ekranın üst bölgesine çıkarsa onu yakalar. Asla aşağı inmez. Kum saati kaymayı geçici yavaşlatır.
## Ekran sarsıntısı sadece `offset`'i değiştirir; oyun mantığı (kayma, oyun sonu) `position` kullanır.

## Kum saati etkisi bitti (main powerup_ended yayınlar).
signal slow_ended

## Takip edilen oyuncu (yakalama bölgesi için).
var target: Node2D
var is_scrolling: bool = false
## Şu anki kayma hızı (px/s; kum saati çarpanı dahil); debug overlay için.
var speed: float = 0.0
var shake := CameraShake.new()
var _scroll_time: float = 0.0
## Kum saati: etki başlayalı geçen süre (s); etki yokken < 0.
var _slow_elapsed: float = -1.0
## Ulaşılan bölüm (seviye) ve yumuşakça hedefine yaklaşan bölüm ek hızı (px/s).
var _section: int = 0
var _section_bonus: float = 0.0


func _ready() -> void:
	# Oyuncu fizik adımında hareket ettiği için kamera da fizik adımında güncellenir (titreme olmaz).
	process_callback = Camera2D.CAMERA2D_PROCESS_PHYSICS
	Events.floor_changed.connect(_on_floor_changed)
	Events.screen_shake.connect(_add_shake)
	Events.combo_ended.connect(_on_combo_ended)


func _physics_process(delta: float) -> void:
	var multiplier: float = _advance_slow(delta)
	var bonus_target: float = CameraRules.section_bonus(_section)
	_section_bonus = move_toward(_section_bonus, bonus_target,
			Tuning.CAMERA_SECTION_SPEED_BONUS / maxf(Tuning.CAMERA_SECTION_RAMP_TIME, 0.001) * delta)
	if is_scrolling:
		# Kum saati hem kaymayı hem de zamanla hızlanmayı yavaşlatır.
		_scroll_time += delta * multiplier
		speed = CameraRules.scroll_speed(_scroll_time, _section_bonus) * multiplier
		position.y -= speed * delta
	if target != null:
		position.y = minf(position.y, CameraRules.catchup_center_y(target.global_position.y))


func _process(delta: float) -> void:
	offset = shake.update(delta)


## Kum saati: kaymayı HOURGLASS_DURATION boyunca yavaşlatır (sürerken yeniden alınırsa süre baştan başlar;
## zaten yavaşken yeniden yavaşlama geçişi yapmaz).
func slow_down() -> void:
	if is_slowed():
		_slow_elapsed = minf(_slow_elapsed, Tuning.HOURGLASS_RAMP_TIME)
	else:
		_slow_elapsed = 0.0


func is_slowed() -> bool:
	return _slow_elapsed >= 0.0


## Kum saati etkisinin kalan süresi (s); etki yoksa 0.
func slow_time_left() -> float:
	return Tuning.HOURGLASS_DURATION - _slow_elapsed if is_slowed() else 0.0


## Kum saati süresini ilerletir; bu karenin hız çarpanını döndürür.
func _advance_slow(delta: float) -> float:
	if not is_slowed():
		return 1.0
	_slow_elapsed += delta
	if _slow_elapsed >= Tuning.HOURGLASS_DURATION:
		_slow_elapsed = -1.0
		slow_ended.emit()
		return 1.0
	return PickupRules.hourglass_multiplier(_slow_elapsed)


## Kaymayı durdurur (oyun bitince).
func stop() -> void:
	is_scrolling = false
	speed = 0.0


## Oyuncu ekranın altından tamamen çıktı mı? (Sarsıntı kaydırması hesaba katılmaz.)
func is_below_screen(world_y: float) -> bool:
	return CameraRules.is_below_screen(world_y, global_position.y)


## Ekran sarsıntısı ayardan kapatılabilir.
func _add_shake(amount: float) -> void:
	if GameSettings.get_setting("screen_shake"):
		shake.add(amount)


func _on_floor_changed(floor_number: int) -> void:
	if not is_scrolling and CameraRules.should_start(floor_number):
		is_scrolling = true
	var section: int = CameraRules.section_of(floor_number)
	if section > _section:
		_section = section
		Events.speed_increased.emit(section)


func _on_combo_ended(_jumps: int, floors: int, bonus: int) -> void:
	_add_shake(CameraShake.combo_trauma(floors, bonus))
