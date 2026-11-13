class_name MagnetField
extends Node
## Mıknatıs etkisi (main kurar ve başlatır): verilen süre (taban MAGNET_DURATION) boyunca menzildeki elmasları
## oyuncuya çeker, spawner'ı "elmas avı"na geçirir (yeni katlarda elmas bol) ve alındığı anda üstteki boş
## platformlara elmas serper. Kurallar MagnetRules'ta; uçuşu ve toplamayı Pickup yapar.

## Etki bitti (main powerup_ended yayınlar).
signal ended

var player: Node2D
var spawner: PlatformSpawner
var _time_left: float = 0.0


## Etkiyi başlatır; sürerken yeniden alınırsa süre baştan başlar (serpme yine yapılır).
## duration: etkin süre (s; "Güçlü mıknatıs" yükseltmesiyle UpgradeRules.magnet_duration).
func activate(duration: float = Tuning.MAGNET_DURATION) -> void:
	_time_left = duration
	if spawner != null:
		spawner.set_diamond_rush(true)
		if player != null:
			# Toplama çoğu zaman çarpışma geri çağrısında olur: yeni Area2D'ler fizik sorgusu bitince eklenir.
			spawner.scatter_diamonds.call_deferred(player.global_position.y)


func is_active() -> bool:
	return _time_left > 0.0


func time_left() -> float:
	return maxf(_time_left, 0.0)


## Çekilen elmasların hedefi: oyuncunun gövde ortası (ayaklara göre).
static func pull_offset() -> Vector2:
	return Vector2(0.0, -Tuning.PLAYER_HEIGHT * 0.5)


func _physics_process(delta: float) -> void:
	if not is_active():
		return
	_attract_diamonds()
	_time_left -= delta
	if _time_left <= 0.0:
		_time_left = 0.0
		if spawner != null:
			spawner.set_diamond_rush(false)
		ended.emit()


func _attract_diamonds() -> void:
	if player == null or not GameFlow.is_playing():
		return
	var center: Vector2 = player.global_position + pull_offset()
	for node: Node in get_tree().get_nodes_in_group(Pickup.GROUP):
		var pickup := node as Pickup
		if pickup == null or pickup.kind != Pickup.DIAMOND or pickup.is_attracted() or pickup.is_collected():
			continue
		if MagnetRules.in_range(pickup.global_position, center):
			pickup.attract(player, pull_offset())
