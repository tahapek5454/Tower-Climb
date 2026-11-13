class_name PlatformCrumble
extends Node2D
## Çatlayan platformun davranışı: üstüne inilince PLATFORM_CRUMBLE_DELAY boyunca titrer, çatlaklar
## büyür, altından taş tozu dökülür; sonra çarpışma kapanır ve platform parçalanıp düşer. Geri gelmez.
## Görüntü işleri CrumbleFx'te; bu düğüm yalnız zamanlamayı ve çarpışmayı yönetir.

var _platform: Platform
var _collider: CollisionShape2D
## -1: tetiklenmedi; 0..DELAY: geri sayım sürüyor.
var _elapsed: float = -1.0
var _broken: bool = false
var _fx: CrumbleFx
var _rng := RandomNumberGenerator.new()


func setup(platform: Platform, collider: CollisionShape2D) -> void:
	_platform = platform
	_collider = collider
	_rng.seed = hash(platform.floor_number * 131 + 5)


func is_triggered() -> bool:
	return _elapsed >= 0.0


func is_broken() -> bool:
	return _broken


## Oyuncu üstüne indi: geri sayım başlar (bir kez).
func trigger() -> void:
	if is_triggered() or _broken:
		return
	_elapsed = 0.0
	_fx = CrumbleFx.new()
	_fx.name = "CrumbleFx"
	_platform.add_child(_fx)
	_fx.start(_platform)
	AudioManager.play(&"crumble_crack", _rng.randf_range(0.94, 1.06), Tuning.SFX_CRUMBLE_CRACK_DB)


func _physics_process(delta: float) -> void:
	if not is_triggered() or _broken:
		return
	_elapsed += delta
	var progress: float = clampf(_elapsed / Tuning.PLATFORM_CRUMBLE_DELAY, 0.0, 1.0)
	_fx.set_progress(progress)
	if progress >= 1.0:
		_break()


func _break() -> void:
	_broken = true
	_collider.set_deferred(&"disabled", true)
	_fx.shatter()
	AudioManager.play(&"crumble", _rng.randf_range(0.95, 1.05), Tuning.SFX_CRUMBLE_DB)
