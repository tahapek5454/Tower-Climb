class_name RunBoosts
extends Node
## Takviyeler (main kurar): her yeni turun başında stoktaki her takviyeden bir tane kendiliğinden kullanılır.
## Tur = bu sahnenin oyunu: menüden "Oyna" (MENU → PLAYING) ya da sahne PLAYING ile açıldığında ("Tekrar").
## Sahne her turda yeniden yüklendiği için bir düğüm yalnız bir turu başlatır (duraklatma dönüşü, devam vb.
## yeniden tetiklemez). Yedek kalp: +1 kalp. Roketli çıkış: kısa bir an sonra tam bir roket uçuşu.
## Kapatma: Tuning.BOOSTS_ENABLED (ya da SHOP_ENABLED; o zaman Shop stoğu 0 döner).

## Roketli çıkış: main oyuncunun start_jetpack'ine bağlar (süre "Büyük depo" yükseltmesiyle).
signal rocket_launch(duration: float)

## Kalbin ekleneceği oyun durumu (testlerde ayrı bir örnek verilebilir).
var game_state: Node = GameState
## Takviyelerin devreye girme gecikmeleri (s); 0 ise hemen.
var heart_delay: float = Tuning.BOOST_HEART_DELAY
var rocket_delay: float = Tuning.BOOST_ROCKET_DELAY
var _started: bool = false


func _ready() -> void:
	Events.flow_changed.connect(_on_flow_changed)
	if GameFlow.is_playing():
		begin_run()


## Turun takviyelerini planlar (tur başına bir kez; sonraki çağrılar yok sayılır).
func begin_run() -> void:
	if _started:
		return
	_started = true
	if not Tuning.BOOSTS_ENABLED:
		return
	if Shop.boost_stock(ShopCatalog.BOOST_HEART) > 0:
		_after(heart_delay, _use_heart)
	if Shop.boost_stock(ShopCatalog.BOOST_ROCKET) > 0:
		_after(rocket_delay, _use_rocket)


func has_started() -> bool:
	return _started


func _use_heart() -> void:
	if _can_apply() and Shop.consume_boost(ShopCatalog.BOOST_HEART):
		game_state.add_hearts(1)


func _use_rocket() -> void:
	if _can_apply() and Shop.consume_boost(ShopCatalog.BOOST_ROCKET):
		rocket_launch.emit(Upgrades.jetpack_time())


## Oyun bittiyse ya da bırakıldıysa takviye harcanmaz.
func _can_apply() -> bool:
	return not game_state.is_game_over


## Bekleme ağaçla birlikte durur (duraklatmada saymaz); düğüm silinirse zamanlayıcı da gider.
func _after(delay: float, action: Callable) -> void:
	if delay <= 0.0:
		action.call()
		return
	var timer := Timer.new()
	timer.one_shot = true
	timer.timeout.connect(func() -> void:
		timer.queue_free()
		action.call())
	add_child(timer)
	timer.start(delay)


func _on_flow_changed(new_state: int, old_state: int) -> void:
	if new_state == FlowRules.State.PLAYING and old_state == FlowRules.State.MENU:
		begin_run()
