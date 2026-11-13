class_name AchievementTracker
extends Node
## Başarım izleyicisi (main'e kodla eklenir; autoload gerekmez: tüm durum kayıtlı, sahne yenilenince
## kayıttan yüklenir). Events sinyallerini ve oyuncu olaylarını dinler; yalnız oyun sürerken (PLAYING)
## sayar, menüdeki zıplamalar sayılmaz. Açılınca: kaydeder, ödül elmasını verir, Events.achievement_unlocked yayınlar.
## Kurallar AchievementRules'ta (saf).

## Açılmış başarımlar {id (String) -> true}.
var _unlocked: Dictionary = {}


func _ready() -> void:
	_unlocked = SaveData.load_achievements()
	Events.floor_changed.connect(func(floor_number: int) -> void: report(AchievementRules.FLOOR, floor_number))
	Events.combo_ended.connect(_on_combo_ended)
	Events.diamonds_changed.connect(func(total: int) -> void: report(AchievementRules.DIAMONDS, total))
	Events.pickup_collected.connect(_on_pickup_collected)
	Events.hearts_changed.connect(_on_hearts_changed)


## Oyuncunun olaylarını izler (kalple kurtulma: &"rescued").
func watch_player(player: Player) -> void:
	player.event.connect(_on_player_event)


## Bir değer türünün yeni değerini bildirir; hedefe ulaşan başarımlar açılır. Oyun sürmüyorsa yok sayılır.
func report(stat: StringName, value: int) -> void:
	if not GameFlow.is_playing():
		return
	for id: StringName in AchievementRules.newly_unlocked(stat, value, _unlocked):
		_unlock(id)


func is_unlocked(id: StringName) -> bool:
	return _unlocked.has(String(id))


func _unlock(id: StringName) -> void:
	# Önce kaydet: ödül elması elmas toplamını değiştirip yeniden değer bildirimi tetikleyebilir.
	_unlocked[String(id)] = true
	SaveData.save_achievement(id)
	GameState.grant_reward_diamonds(int(AchievementRules.get_def(id).get("reward", 0)))
	Events.achievement_unlocked.emit(id)


func _on_combo_ended(_jumps: int, floors: int, bonus: int) -> void:
	if bonus > 0:
		report(AchievementRules.COMBO_FLOORS, floors)


func _on_pickup_collected(kind: StringName, _world_position: Vector2) -> void:
	match kind:
		&"jetpack":
			report(AchievementRules.PICKUP_JETPACK, 1)
		&"hourglass":
			report(AchievementRules.PICKUP_HOURGLASS, 1)


func _on_hearts_changed(hearts: int, change: int) -> void:
	if change > 0:
		report(AchievementRules.HEARTS, hearts)


func _on_player_event(event_name: StringName, _data: Dictionary) -> void:
	if event_name == &"rescued":
		report(AchievementRules.RESCUE, 1)
