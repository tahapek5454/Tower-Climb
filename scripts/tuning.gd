class_name Tuning
extends RefCounted
## Tüm oynanış sayıları burada. Başlangıç değerleri docs/GAME_DESIGN.md'den.
## Birimler: mesafe px, hız px/s, ivme px/s², süre s.

# --- Ekran ve kule ---
const VIEW_WIDTH: float = 1280.0
const VIEW_HEIGHT: float = 720.0
## Duvarlar arası oynanabilir genişlik.
const TOWER_WIDTH: float = 896.0
const WALL_THICKNESS: float = 48.0
## Duvar gövdesinin yüksekliği; duvarlar kamerayı takip ettiği için ekrandan uzun olması yeter.
const WALL_HEIGHT: float = 2160.0
## Zemin ve platformların kalınlığı.
const PLATFORM_THICKNESS: float = 24.0
## Başlangıçta zeminin ekranın alt kenarından yüksekliği.
const GROUND_SCREEN_MARGIN: float = 72.0

# --- Kule içi görünümü (görsel; assets/shaders/tower_interior.gdshader) ---
## Arka duvardaki bir taş bloğun boyutu (px). Yükseklik FLOOR_SPACING'in yarısı: kat başına iki sıra.
const INTERIOR_BLOCK_SIZE: Vector2 = Vector2(128.0, 64.0)
## Taş köşelerinin yuvarlaklığı, derz kalınlığı ve derz kenarının yumuşaklığı (px).
const INTERIOR_BLOCK_CORNER_RADIUS: float = 10.0
const INTERIOR_JOINT_WIDTH: float = 3.0
const INTERIOR_JOINT_SOFTNESS: float = 1.0
## Bloklar arası parlaklık farkı (±oran) ve blok içi üstten alta kararma.
const INTERIOR_BLOCK_VARIATION: float = 0.03
const INTERIOR_BEVEL_STRENGTH: float = 0.04
## Duvar dibindeki yumuşak gölge: genişlik (px) ve en koyu noktadaki kararma oranı.
const INTERIOR_EDGE_SHADE_WIDTH: float = 150.0
const INTERIOR_EDGE_SHADE_STRENGTH: float = 0.18
## Arka duvar deseninin kameraya göre kayma oranı (1 = platformlarla aynı; küçük = daha derinde).
const INTERIOR_PARALLAX: float = 0.85

# --- Kule dışı arka plan (görsel; assets/shaders/backdrop.gdshader) ---
## Katmanların kameraya göre kayma oranı: 0 = ekrana sabit, 1 = platformlarla aynı.
## Tepeler çok yavaş batar (uzakta), bulutlar daha hızlı geçer.
const BACKDROP_HILL_FAR_PARALLAX: float = 0.04
const BACKDROP_HILL_NEAR_PARALLAX: float = 0.09
const BACKDROP_CLOUD_FAR_PARALLAX: float = 0.22
const BACKDROP_CLOUD_NEAR_PARALLAX: float = 0.45
## Bulutların yatay sürüklenme hızı (px/s; uzak bulutlar daha yavaş).
const BACKDROP_CLOUD_DRIFT_SPEED: float = 6.0

# --- Yan duvar ve zemin görünümü (görsel; assets/shaders/tower_wall.gdshader) ---
## Duvar sütununun parça yüksekliği (iki kat) ve parçalar arasındaki derzin kalınlığı (px).
const WALL_SEGMENT_HEIGHT: float = FLOOR_SPACING * 2.0
const WALL_JOINT_WIDTH: float = 3.0
## Kule içine bakan kenardaki açık pervazın genişliği (px) ve dış kenardaki kararma oranı.
const WALL_LIP_WIDTH: float = 5.0
const WALL_OUTER_SHADE: float = 0.15
## Zeminin üstündeki açık şeridin kalınlığı ve zemin görüntüsünün aşağı doğru derinliği (px).
## Kamera aşağı inmediği için yarım ekran yeter (sarsıntı payı dahil).
const GROUND_TOP_HEIGHT: float = 4.0
const GROUND_VISUAL_DEPTH: float = VIEW_HEIGHT * 0.5

# --- Platform görünümü (görsel; scripts/world/platform_visual.gd) ---
## Köşe yuvarlaklığı (px).
const PLATFORM_CORNER_RADIUS: float = 7.0
## Üstteki açık şeridin ve alttaki koyu kenarın kalınlığı (px); ne kadar açık/koyu oldukları.
const PLATFORM_TOP_HEIGHT: float = 5.0
const PLATFORM_UNDERSIDE_HEIGHT: float = 5.0
const PLATFORM_TOP_LIGHTEN: float = 0.35
const PLATFORM_UNDERSIDE_DARKEN: float = 0.30
## Platformun arka duvara düşen gölgesi: yayılma (px), aşağı kayma (px) ve koyuluk.
const PLATFORM_SHADOW_SIZE: float = 5.0
const PLATFORM_SHADOW_OFFSET: float = 5.0
const PLATFORM_SHADOW_ALPHA: float = 0.28
## Uçlardaki başlık taşları: genişlik, levhadan aşağı taşma (px) ve gövdeye göre ne kadar açık.
const PLATFORM_CAP_WIDTH: float = 24.0
const PLATFORM_CAP_DROP: float = 5.0
const PLATFORM_CAP_LIGHTEN: float = 0.10
## Aradaki taşların yaklaşık boyu (px; genişliğe tam bölünecek şekilde ayarlanır) ve ton farkı (±oran).
const PLATFORM_STONE_LENGTH: float = 52.0
const PLATFORM_STONE_VARIATION: float = 0.11
## Taşlar arası derz: kalınlık (px) ve koyuluk.
const PLATFORM_JOINT_WIDTH: float = 2.0
const PLATFORM_JOINT_DARKEN: float = 0.32
## Alttaki destek taşları: üst genişlik, yükseklik, başlıktan içeri mesafe (px), alt/üst genişlik oranı, koyuluk.
const PLATFORM_CORBEL_WIDTH: float = 32.0
const PLATFORM_CORBEL_HEIGHT: float = 12.0
const PLATFORM_CORBEL_INSET: float = 14.0
const PLATFORM_CORBEL_TAPER: float = 0.5
const PLATFORM_CORBEL_DARKEN: float = 0.30

# --- Karakter ---
const PLAYER_WIDTH: float = 32.0
const PLAYER_HEIGHT: float = 48.0

# --- Karakter modeli (görsel; hitbox'tan bağımsız) ---
## false: 3D model yerine kutu gövde kullanılır (model dosyası yoksa da kutuya dönülür).
const USE_CHARACTER_MODEL: bool = true
## Modelin 1 biriminin ekrandaki karşılığı (px). Model ~1,07 birim boyunda (kafa büyütüldü).
## Hitbox'tan (PLAYER_HEIGHT) büyük olabilir.
const MODEL_HEIGHT: float = 88.0
## Görüntünün yarı genişliği (px): duvara yaslanınca görüntü bu kadar içeride tutulur.
## Hitbox (PLAYER_WIDTH) dar kalır; sadece çizim kayar (bkz. WallClearance).
const MODEL_WALL_HALF_WIDTH: float = 27.0
## Çizim çerçevesinin model boyuna oranı: kol, kuyruk ve animasyonlar sığsın diye 1'den büyük.
const MODEL_FRAME_RATIO: float = 1.6
## Model bu kat çözünürlükte çizilir (büyük pencerede/tam ekranda net kalsın).
const MODEL_RENDER_SCALE: float = 3.0
## Model tam profilden bu kadar kameraya dönük durur (yüz ve gövde okunsun).
const MODEL_VIEW_ANGLE_DEGREES: float = 25.0
## Sağa/sola dönüşün hızı (büyük = daha ani).
const MODEL_TURN_RATE: float = 14.0
## Animasyonlar arası geçiş süresi; ani olaylar (zıplama, iniş, takla) için kısa olanı.
const MODEL_ANIM_BLEND_TIME: float = 0.12
const MODEL_ANIM_BLEND_TIME_FAST: float = 0.05
## Koşu animasyonunun oynatma hızı: çok yavaşken ve tam hızda (MAX_RUN_SPEED).
const MODEL_RUN_ANIM_SPEED_MIN: float = 0.7
const MODEL_RUN_ANIM_SPEED_MAX: float = 2.0
## Aşağı hız bunu geçince düşme animasyonuna geçilir (tepe noktasında titremesin).
const MODEL_FALL_ANIM_MIN_SPEED: float = 60.0
## İniş (çömelme) animasyonu sadece bu yatay hızın altında oynar; hızlıyken koşuya devam edilir.
const MODEL_LAND_ANIM_MAX_RUN_SPEED: float = 250.0
## Zıplama gücü (0..1) bu değeri geçerse kanat çırpılır (takla yoksa).
const MODEL_FLAP_MIN_STRENGTH: float = 0.35
## Zıplama taklasının "yıldız" (kollar bacaklar açık, yan takla) olma olasılığı; kalanı topak takla.
## Duvar sekmesi taklaları hep topaktır (yıldız geniş olduğu için duvara taşar).
const MODEL_STAR_FLIP_CHANCE: float = 0.5
## Takla ekseninin ayaklardan yüksekliği (px): topak pozundaki modelin ortası.
const MODEL_SPIN_PIVOT_HEIGHT: float = 42.0
## Toon görünüm (assets/shaders/toon_character.gdshader, toon_outline.gdshader).
## Dış çizgi: koyu lacivert. Kule içi orta tonda olduğu için koyu çizgi hem beyaz kafayı hem
## koyu gövdeyi zeminden ayırır (zemin koyuyken açık renkti; zemin yine koyulaşırsa açığa dön).
const MODEL_OUTLINE_COLOR: Color = Color(0.09, 0.10, 0.18)
## Dış çizgi kalınlığı (model birimi; 0.013 ≈ 1,1 px).
const MODEL_OUTLINE_WIDTH: float = 0.013
## Kenar ışığının rengi ve gücü (zayıf: koyu kol ve bacakları birbirinden ayırmaya yeter).
const MODEL_RIM_COLOR: Color = Color(0.75, 0.85, 1.0)
const MODEL_RIM_STRENGTH: float = 0.28
## Gölgede kalan yüzeyin renk çarpanı.
const MODEL_SHADOW_TINT: Color = Color(0.62, 0.64, 0.80)

# --- Yatay hareket ---
const MAX_RUN_SPEED: float = 900.0
const GROUND_ACCEL: float = 2600.0
const GROUND_FRICTION: float = 1800.0
const AIR_ACCEL: float = 1400.0
## Yerde bu hızın altı IDLE, üstü RUN sayılır.
const RUN_STATE_MIN_SPEED: float = 20.0

# --- Yerçekimi ve zıplama ---
const GRAVITY: float = 2400.0
const MAX_FALL_SPEED: float = 1800.0
const JUMP_BASE: float = 900.0
## Zıplama hızı = JUMP_BASE + abs(vx) * JUMP_SPEED_BONUS (max hızda 1440).
const JUMP_SPEED_BONUS: float = 0.6
## Tuş erken bırakılınca yukarı hız bununla çarpılır.
const JUMP_CUT_MULTIPLIER: float = 0.5
const COYOTE_TIME: float = 0.10
const JUMP_BUFFER_TIME: float = 0.12

# --- Duvar sekmesi ---
const WALL_BOUNCE_MIN_SPEED: float = 300.0
const WALL_BOUNCE_DAMPING: float = 0.85
## Sadece havadayken uygulanır.
const WALL_BOUNCE_UP_BOOST: float = 150.0

# --- Platformlar ---
## Katlar arası dikey mesafe.
const FLOOR_SPACING: float = 128.0
## Tipik genişliğin genel eğilimi: başta MAX, NARROW_FLOORS katta MIN (rastgelelik öncesi).
const PLATFORM_WIDTH_MAX: float = 360.0
const PLATFORM_WIDTH_MIN: float = 140.0
## Her bu kadar katta bir tam genişlikte bölüm platformu.
const SECTION_FLOOR_INTERVAL: int = 100
## Yeni bölümün teması (renkler) bölüm platformundan sonra bu kadar kat boyunca yumuşakça gelir.
const THEME_TRANSITION_FLOORS: float = 8.0
## Platform süsleri (PlatformDecor): bir platformun süslü olma olasılığı ve ikinci bir süs alma olasılığı.
const PLATFORM_DECOR_CHANCE: float = 0.7
const PLATFORM_DECOR_SECOND_CHANCE: float = 0.35
## Platform genişliği bu kata kadar MAX'tan MIN'e doğrusal daralır.
const PLATFORM_NARROW_FLOORS: int = 300
## Her bölüm bu kadar geniş başlar (nefes payı); bölüm boyunca pay erir.
const PLATFORM_SECTION_START_BONUS: float = 80.0
## Her platform tipik genişliğin bu aralıkta rastgele bir katı olur.
const PLATFORM_WIDTH_JITTER_MIN: float = 0.75
const PLATFORM_WIDTH_JITTER_MAX: float = 1.15
## Sürpriz dar platform: olasılık başta START, NARROW_FLOORS katta END; genişlik tipik x FACTOR.
const PLATFORM_SURPRISE_CHANCE_START: float = 0.04
const PLATFORM_SURPRISE_CHANCE_END: float = 0.15
const PLATFORM_SURPRISE_FACTOR: float = 0.55
## Hiçbir platform bundan dar olamaz (karakter hitbox'ı 32 px).
const PLATFORM_WIDTH_ABS_MIN: float = 90.0
## Ardışık iki platformun kenarları arasındaki en fazla yatay boşluk (ulaşılabilirlik).
const PLATFORM_MAX_EDGE_GAP: float = 200.0
## Ekranın üst kenarının bu kadar üstüne kadar platform hazır tutulur.
const PLATFORM_SPAWN_AHEAD: float = VIEW_HEIGHT
## Ekranın alt kenarından bu kadar aşağıda kalan platformlar silinir.
const PLATFORM_DESPAWN_MARGIN: float = 256.0
## Tek yönlü çarpışma payı; hızlı düşüşte platformun içinden geçmeyi önler.
const PLATFORM_ONE_WAY_MARGIN: float = 8.0

# --- Kamera ---
## Kamera bu kata ulaşılınca kaymaya başlar.
const CAMERA_START_FLOOR: int = 5
const CAMERA_START_SPEED: float = 40.0
## Her CAMERA_SPEED_STEP_INTERVAL saniyede hız bu kadar artar.
const CAMERA_SPEED_STEP: float = 12.0
const CAMERA_SPEED_STEP_INTERVAL: float = 30.0
## Seviye atladıkça hızlanma: her bölüm geçişinde (SECTION_FLOOR_INTERVAL kat) kalıcı ek hız (px/s);
## ek hız CAMERA_SECTION_RAMP_TIME saniyede yumuşakça gelir.
const CAMERA_SECTION_SPEED_BONUS: float = 30.0
const CAMERA_SECTION_RAMP_TIME: float = 2.0
## Zaman + bölüm hızının toplam üst sınırı.
const CAMERA_MAX_SPEED: float = 320.0
## Ekranın üstten bu oranı yakalama bölgesi.
const CAMERA_CATCHUP_ZONE: float = 0.30

# --- Oyun sonu ---
## Oyun bittikten sonra yeniden başlatma tuşunun kabul edilmesi için beklenen süre
## (düşerken basılı tutulan zıplama tuşu oyunu hemen yeniden başlatmasın).
const GAME_OVER_RESTART_DELAY: float = 0.5

# --- Skor ve kombo ---
const SCORE_PER_FLOOR: int = 10
## Tek zıplayışta en az bu kadar kat atlanırsa kombo sayılır.
const COMBO_MIN_FLOORS: int = 2
## Kombonun puan vermesi için gereken en az zıplayış sayısı.
const COMBO_MIN_JUMPS: int = 2
const COMBO_TIMEOUT: float = 3.0

# --- Takla (görsel) ---
## Bu dikey hızın üstündeki zıplamalar takla tetikler (kombo zıplayışları ve havada duvar sekmesi de).
const FLIP_VELOCITY_THRESHOLD: float = 1200.0
## Takla süresi = yükselme süresi (vy / GRAVITY) x bu çarpan; tepe noktasından biraz sonra biter.
const FLIP_AIRTIME_FACTOR: float = 1.3
## Takla en az bu kadar sürer (ör. düşerken duvar sekmesi).
const FLIP_MIN_DURATION: float = 0.35
## Bir tur için gereken süre; takla süresi bunun katlarıysa o kadar tur atılır.
const FLIP_TURN_TIME: float = 0.4
const FLIP_MAX_TURNS: int = 3
## Takla bitmeden inilirse gövdenin dik konuma dönme süresi.
const FLIP_LAND_RESET_TIME: float = 0.08

# --- Juice: squash & stretch (görsel) ---
# Uzama değeri: + dikey uzama, - dikey ezilme. Gövde alanı korunur (en = 1 / boy).
## Yay sertliği ve sönümü: düşük sönüm = daha fazla "jöle" sallanması.
## Güçlü efektlerde (tam hızda zıplama) kullanılan yay; zayıf efektlerde SOFT'a doğru yumuşar.
const SQUASH_SPRING_STIFFNESS: float = 220.0
## Zayıf efektlerin (kısa zıplama, yumuşak iniş) yayı: daha yavaş, daha uzun sallanma.
const SQUASH_SPRING_STIFFNESS_SOFT: float = 110.0
## STIFFNESS'taki sönüm; yay yumuşadıkça aynı "sallanma karakteri" korunacak şekilde ölçeklenir.
const SQUASH_SPRING_DAMPING: float = 9.0
## Zıplama anındaki uzama: en düşük zıplamada MIN, en yüksekte MAX.
const JUMP_STRETCH_MIN: float = 0.35
const JUMP_STRETCH_MAX: float = 0.50
## İniş ezilmesi düşüş hızıyla orantılı: MIN_SPEED altında yok, FULL_SPEED ve üstünde MAX.
## (Tipik iniş hızları 450–950 px/s; bir kat yukarıdaki platforma iniş ~500.)
const LAND_SQUASH_MIN_SPEED: float = 150.0
const LAND_SQUASH_FULL_SPEED: float = 700.0
const LAND_SQUASH_MAX: float = 0.50
## Duvara çarpınca yatay ezilme (dikey uzama); çarpma hızıyla orantılı.
const WALL_SQUASH_MAX: float = 0.40
## Havadayken dikey hızla orantılı uzama (MAX_FALL_SPEED'de bu kadar).
const AIR_STRETCH_MAX: float = 0.20
## Uzama/ezilmenin mutlak sınırı (gövde aşırı bozulmasın).
const SQUASH_LIMIT: float = 0.6

# --- Juice: hareket izi (görsel) ---
## Bu hızın (vektör uzunluğu) üstünde gövdenin arkasında yumuşak bir şerit bırakılır.
const TRAIL_MIN_SPEED: float = 650.0
## Şeridin bir noktasının ömrü (s) = kuyruğun uzunluğu.
const TRAIL_LIFETIME: float = 0.22
## Gövdeye yakın uçtaki kalınlık (px) ve saydamlık (0..1); kuyruğa doğru 0'a iner.
const TRAIL_WIDTH: float = 20.0
const TRAIL_ALPHA: float = 0.22
## Noktalar arası en az mesafe (px); daha sık nokta eklenmez.
const TRAIL_POINT_SPACING: float = 6.0

# --- Juice: hız çizgileri (görsel) ---
## Bu hızın üstünde gövdenin arkasında hareket yönünde çizgiler çıkar.
const SPEED_LINES_MIN_SPEED: float = 1100.0
const SPEED_LINE_INTERVAL: float = 0.05
const SPEED_LINE_LIFETIME: float = 0.18
const SPEED_LINE_LENGTH_MIN: float = 40.0
const SPEED_LINE_LENGTH_MAX: float = 90.0
## Baş taraftaki kalınlık; kuyruğa doğru incelir.
const SPEED_LINE_WIDTH: float = 2.5
## Çizgilerin hareket yönüne dik dağılımı (± px) ve gövde merkezinin ne kadar arkasında çıktıkları.
const SPEED_LINE_SPREAD: float = 28.0
const SPEED_LINE_BACK_MIN: float = 20.0
const SPEED_LINE_BACK_MAX: float = 60.0
const SPEED_LINE_START_ALPHA: float = 0.3

# --- Juice: iniş tozu ve duvar kıvılcımı (görsel) ---
## İniş tozu: MIN_SPEED altındaki inişlerde yok; FULL_SPEED ve üstünde en güçlü hâli.
const LAND_DUST_MIN_SPEED: float = 350.0
const LAND_DUST_FULL_SPEED: float = 1200.0
## Bir inişteki toz bulutu sayısı (zayıf → güçlü).
const LAND_DUST_COUNT_MIN: int = 4
const LAND_DUST_COUNT_MAX: int = 12
const LAND_DUST_LIFETIME: float = 0.5
## Bulutların yana yayılma hızı (en güçlü inişte; zayıfta bunun %50'si).
const LAND_DUST_SPEED: float = 220.0
## Toz saydamlığı (başlangıç; ömrü boyunca 0'a iner).
const LAND_DUST_ALPHA: float = 0.35
## Kıvılcım sayısı (yavaş → tam hızla çarpma) ve özellikleri.
const WALL_SPARK_COUNT_MIN: int = 4
const WALL_SPARK_COUNT_MAX: int = 10
const WALL_SPARK_LIFETIME: float = 0.3
const WALL_SPARK_SPEED: float = 380.0
const WALL_SPARK_ALPHA: float = 0.8

# --- Juice: ekran sarsıntısı (görsel) ---
# "Sarsıntı" (trauma) 0..1 birikir ve azalır; kaydırma = trauma² x MAX_OFFSET (küçükler çok hafif).
## En güçlü sarsıntıdaki kamera kaydırması (px).
const SHAKE_MAX_OFFSET: float = 24.0
## Saniyede azalma (1 → 0: 1/DECAY saniye).
const SHAKE_DECAY: float = 1.2
## Gürültü hızı: yüksek = daha hızlı titreşim, düşük = daha yumuşak dalgalanma.
const SHAKE_NOISE_SPEED: float = 30.0
## Büyük iniş: bu düşüş hızının üstünde; MAX_FALL_SPEED'de LAND_TRAUMA_MAX.
const SHAKE_LAND_MIN_SPEED: float = 1000.0
const SHAKE_LAND_TRAUMA_MAX: float = 0.6
## Duvar sekmesi: tam hızda çarpmada bu kadar (yavaşta hızın karesiyle azalır).
const SHAKE_WALL_TRAUMA_MAX: float = 0.45
## Kombo bitişi (puan kazandıran): atlanan kat başına, en çok COMBO_TRAUMA_MAX.
const SHAKE_COMBO_TRAUMA_PER_FLOOR: float = 0.05
const SHAKE_COMBO_TRAUMA_MAX: float = 0.8

# --- Juice: hit-stop (görsel) ---
## Puan kazandıran kombo bitince oyun bu hıza iner (1 = normal).
const HITSTOP_TIME_SCALE: float = 0.05
## Süre (gerçek zaman, s): küçük komboda MIN, HITSTOP_FULL_FLOORS ve üstü katta MAX.
const HITSTOP_DURATION_MIN: float = 0.06
const HITSTOP_DURATION_MAX: float = 0.14
const HITSTOP_FULL_FLOORS: int = 20

# --- Juice: kombo yazıları ve skor sayacı (görsel) ---
## Kombo yazısı bu zıplayış sayısından itibaren gösterilir ("x2"; sadece çarpan, kısa olduğu için biraz büyük).
const COMBO_POPUP_MIN_JUMPS: int = 2
## Yazı boyutu: MIN_JUMPS'ta FONT_MIN, FONT_FULL_JUMPS ve üstünde FONT_MAX.
## (Kullanıcı tercihi: minimal. Asset aşamasında görünüm yeniden ele alınacak.)
const COMBO_POPUP_FONT_MIN: int = 22
const COMBO_POPUP_FONT_MAX: int = 30
const COMBO_POPUP_FONT_FULL_JUMPS: int = 10
## Bonus yazısı ("+144"): 0 kat → FONT_MIN, BONUS_FONT_FULL_FLOORS kat → FONT_MAX.
const BONUS_POPUP_FONT_MIN: int = 22
const BONUS_POPUP_FONT_MAX: int = 30
const BONUS_POPUP_FONT_FULL_FLOORS: int = 20
## Yazının ömrü (s), bu sürede ne kadar yükseldiği (px) ve oyuncunun ne kadar üstünde çıktığı.
const COMBO_POPUP_LIFETIME: float = 0.8
const BONUS_POPUP_LIFETIME: float = 1.1
const POPUP_RISE: float = 40.0
const POPUP_OFFSET_Y: float = 70.0
## Beliriş: 0'dan bu ölçeğe büyür (taşma), sonra 1'e oturur.
const POPUP_POP_SCALE: float = 1.12
const POPUP_POP_TIME: float = 0.12
## Sallanma: en büyük açı (derece) ve hızı (rad/s); ömür boyunca söner.
const POPUP_WOBBLE_DEGREES: float = 3.0
const POPUP_WOBBLE_SPEED: float = 14.0
## Skor sayacı: hedefe yaklaşma hızı (büyük = daha hızlı sayar).
const SCORE_COUNT_RATE: float = 6.0
## Kombo bonusu gelince skor yazısının kısa büyümesi.
const SCORE_PULSE_SCALE: float = 1.3
const SCORE_PULSE_TIME: float = 0.3

# --- Juice: ışık hâlesi ("sahte glow", görsel) ---
# WorldEnvironment glow Compatibility renderer'da 2D için güvenilir değil; yerine toplamalı ışık hâleleri.
## Karakter hâlesinin çapı (px).
const GLOW_AURA_SIZE: float = 150.0
## Hâle parlaklığı: dururken, hızlıyken (|hız| ≥ TRAIL_MIN_SPEED) ve kombo sürerken.
const GLOW_AURA_ALPHA_IDLE: float = 0.08
const GLOW_AURA_ALPHA_FAST: float = 0.18
const GLOW_AURA_ALPHA_COMBO: float = 0.28
## Hâlenin hedef parlaklığa yaklaşma hızı (büyük = daha ani).
const GLOW_AURA_SMOOTHING: float = 6.0
## Bölüm platformunun (her 100 kat) arkasındaki hâle: yükseklik (px) ve parlaklık.
const GLOW_SECTION_HEIGHT: float = 90.0
const GLOW_SECTION_ALPHA: float = 0.22

# --- Işık (görsel; "sahte ışık" hâleleri, scripts/world/platform_glow.gd) ---
## Fener: hâle çapı (px), parlaklık ve titreşim (oran, hız rad/s).
const LIGHT_LANTERN_SIZE: float = 120.0
const LIGHT_LANTERN_ALPHA: float = 0.32
const LIGHT_FLICKER_AMOUNT: float = 0.14
const LIGHT_FLICKER_SPEED: float = 3.2
## Kristal filizi: hâle çapı ve parlaklık.
const LIGHT_CRYSTAL_SIZE: float = 64.0
const LIGHT_CRYSTAL_ALPHA: float = 0.30
## Kendi ışığı olan platform stilleri: platform boyunca parıltının yüksekliği ve parlaklığı.
const LIGHT_PLATFORM_HEIGHT: float = 70.0
const LIGHT_GLOW_TILES_ALPHA: float = 0.20
const LIGHT_CRYSTAL_PLATFORM_ALPHA: float = 0.12
## Duvar meşalesi ve mangal: hâle çapı ve parlaklık.
const LIGHT_TORCH_SIZE: float = 170.0
const LIGHT_TORCH_ALPHA: float = 0.30
## Pencereden sızan gökyüzü ışığı (pencere boyutuna göre ölçeklenir).
const LIGHT_WINDOW_ALPHA: float = 0.16
## Gece temasındaki ampul dizisi: ampul başına hâle çapı ve parlaklık.
const LIGHT_BULB_SIZE: float = 46.0
const LIGHT_BULB_ALPHA: float = 0.40

# --- Duvar süsleri (görsel; scripts/world/wall_decor*.gd) ---
## Süs yuvalarının arası (px, duvar uzayında), ilk yuvanın zeminden yüksekliği ve bir yuvanın dolu olma olasılığı.
const WALL_DECOR_SPACING: float = 190.0
const WALL_DECOR_START_HEIGHT: float = 330.0
const WALL_DECOR_CHANCE: float = 0.8
## Süslerin yan duvarlara en az uzaklığı (px).
const WALL_DECOR_MARGIN: float = 60.0
## Ekranın üstünde/altında hazır tutulan pay (px; süsler bu kadar uzanabilir).
const WALL_DECOR_VIEW_MARGIN: float = 220.0
## Süslerin renk çarpanı: arka plan öğesi olarak platformlardan hafifçe geri çekilsinler.
const WALL_DECOR_TINT: Color = Color(0.9, 0.9, 0.94)

# --- Ortam parçacıkları (görsel; scripts/world/ambient_particles.gd) ---
## Görüntü başına parçacık sayısı ve en yüksek saydamlık (tür başına).
const AMBIENT_DUST_AMOUNT: int = 40
const AMBIENT_DUST_ALPHA: float = 0.5
const AMBIENT_LEAF_AMOUNT: int = 26
const AMBIENT_SNOW_AMOUNT: int = 120
const AMBIENT_SNOW_ALPHA: float = 0.95
const AMBIENT_FIREFLY_AMOUNT: int = 34
const AMBIENT_FIREFLY_ALPHA: float = 1.0
## Yayıcı dikdörtgeninin görüntüden taşma payı (px).
const AMBIENT_VIEW_MARGIN: float = 120.0

# --- Ses efektleri (scripts/game/sfx_rules.gd, game_audio.gd; dosyalar tools/sfx/generate_sfx.py) ---
## Temel ses yükseklikleri (dB; 0 = dosyanın kendi seviyesi). Güce bağlı olanlar bundan biraz kısılır.
const SFX_JUMP_DB: float = -7.0
const SFX_LAND_DB: float = -5.0
const SFX_WALL_DB: float = -5.0
const SFX_COMBO_DB: float = -8.0
const SFX_COMBO_END_DB: float = -4.0
const SFX_SECTION_DB: float = -3.0
const SFX_GAME_OVER_DB: float = -4.0
## Kullanıcı ilk sürümü (-9 dB, daha tiz) yüksek buldu; kısıldı ve yumuşatıldı.
const SFX_WHOOSH_DB: float = -17.0
## Arayüz sesleri (menü üzerine gelme, tıklama, geri). Efekt kanalından çalar; kısık, rahatsız etmesin.
const UI_HOVER_DB: float = -16.0
const UI_CLICK_DB: float = -9.0
const UI_BACK_DB: float = -9.0
## Yeni rekor fanfarı (oyun sonunda game_over sesinin yerine çalar).
const SFX_RECORD_DB: float = -3.0
## Zıplama perdesi: en yavaş ve en hızlı zıplamada.
const SFX_JUMP_PITCH_MIN: float = 0.9
const SFX_JUMP_PITCH_MAX: float = 1.3
## Bu düşüş hızının altındaki inişler sessiz.
const SFX_LAND_MIN_SPEED: float = 250.0
## Sık çalan seslerin rastgele perde sapması (±oran).
const SFX_PITCH_JITTER: float = 0.04

# --- Radyo paneli (arayüz; scripts/ui/radio/) ---
## Panel yüksekliği, kule dışındaki alanın kenarlarından boşluk ve ekranın altından yüksekliği (px).
const RADIO_HEIGHT: float = 76.0
const RADIO_SIDE_PADDING: float = 8.0
const RADIO_BOTTOM_OFFSET: float = 120.0
## Fare üstünde değilken saydamlık ve fareye tepki hızı (büyük = daha ani).
const RADIO_IDLE_ALPHA: float = 0.35
const RADIO_FADE_SPEED: float = 8.0
## Ekleme sonucu mesajının başlıkta kalma süresi (s).
const RADIO_MESSAGE_TIME: float = 2.5

# --- Ana menü (Aşama 5) ---
## Menü açıkken dünyanın karartılması (0..1); düşük: arkadaki canlı dünya görünsün.
const MENU_DIM_ALPHA: float = 0.28
## Menü kartının dikey kayması (px, eksi = yukarı); kartal kartın altında görünsün.
const MENU_CARD_SHIFT: float = -50.0
## Menüde kartalın kendiliğinden yaptığı küçük zıplamanın hızı ve aralığı (s).
const MENU_HOP_SPEED: float = JUMP_BASE * 0.42
const MENU_HOP_INTERVAL_MIN: float = 2.8
const MENU_HOP_INTERVAL_MAX: float = 6.0

# --- Duraklatma (Aşama 5) ---
## "Devam"dan sonra oyun başlamadan önce sayılan adım sayısı ve her adımın süresi (s).
const PAUSE_COUNTDOWN_STEPS: int = 3
const PAUSE_COUNTDOWN_STEP_TIME: float = 0.65
## Duraklatınca müziğin boğuklaşması: süzgeç kesim frekansları (Hz) ve geçiş süresi (s).
const MUFFLE_CUTOFF_OPEN_HZ: float = 20500.0
const MUFFLE_CUTOFF_HZ: float = 800.0
const MUFFLE_TIME: float = 0.25

# --- Toplanabilirler (Aşama 6; scripts/world/pickup.gd) ---
## Toplanabilirin platform yüzeyinden yüksekliği ve toplama yarıçapı (px).
const PICKUP_HOVER_HEIGHT: float = 46.0
const PICKUP_RADIUS: float = 24.0
## Havada süzülme: yukarı-aşağı genlik (px) ve bir turun süresi (s).
const PICKUP_BOB_HEIGHT: float = 5.0
const PICKUP_BOB_TIME: float = 1.7
## Platform kenarına en az bu kadar uzakta durur (px).
const PICKUP_EDGE_MARGIN: float = 32.0
## Arkasındaki ışık hâlesinin çapı (px) ve saydamlığı.
const PICKUP_GLOW_SIZE: float = 120.0
const PICKUP_GLOW_ALPHA: float = 0.30
## Toplanınca büyüyüp kaybolma süresi (s).
const PICKUP_COLLECT_TIME: float = 0.18

# --- Roket / jetpack (Aşama 6; scripts/game/jetpack_rules.gd, scripts/player/jetpack_flight.gd) ---
## false: roket hiç çıkmaz (özelliği tek satırla kapatır).
const JETPACK_ENABLED: bool = true
## NADİRLİK: uygun her platformda roket çıkma olasılığı (0..1). Büyüt = daha sık.
const JETPACK_SPAWN_CHANCE: float = 0.03
## Bu kattan önce roket çıkmaz; bir roketten sonra en az bu kadar kat boyunca yenisi çıkmaz
## (uçuşta geçilen kat sayısından büyük olmalı: uçarken ikinci rokete denk gelinmesin).
const JETPACK_MIN_FLOOR: int = 15
const JETPACK_MIN_FLOOR_GAP: int = 40
## Uçuş süresi (s), tırmanma hızı (px/s) ve o hıza çıkış ivmesi (px/s²).
const JETPACK_FLIGHT_TIME: float = 3.0
const JETPACK_SPEED: float = 1100.0
const JETPACK_ACCEL: float = 4500.0
## Uçarken oyuncunun sağa/sola kayma hızı ve ivmesi.
const JETPACK_STEER_SPEED: float = 380.0
const JETPACK_STEER_ACCEL: float = 2600.0
## Güvenli bırakma: süre dolunca roket oyuncuyu bir platformun üstüne taşır ve orada bırakır.
## Hedef platform oyuncudan en az MIN_RISE px yukarıda olmalı; en yakın CANDIDATES platform arasından
## yatayda en yakını seçilir; oyuncu platform kenarından EDGE_MARGIN içeride, yüzeyden RELEASE_HEIGHT
## yukarıda bırakılır.
const JETPACK_LANDING_MIN_RISE: float = 110.0
const JETPACK_LANDING_CANDIDATES: int = 3
const JETPACK_LANDING_EDGE_MARGIN: float = 34.0
const JETPACK_RELEASE_HEIGHT: float = 44.0
## Yaklaşma: en yüksek dikey/yatay hız (px/s) ve hedefe yaklaşırken yavaşlama katsayısı (1/s).
const JETPACK_APPROACH_SPEED: float = 620.0
const JETPACK_ALIGN_SPEED: float = 760.0
const JETPACK_APPROACH_GAIN: float = 9.0
## Hedefe bu kadar yaklaşınca (px) bırakır; yaklaşma en çok bu kadar sürer (s, güvenlik).
const JETPACK_RELEASE_TOLERANCE: float = 6.0
const JETPACK_APPROACH_TIMEOUT: float = 2.5
## Bırakılırken verilen küçük yukarı hız (px/s): yumuşak bir kavisle platforma konar.
const JETPACK_RELEASE_HOP_SPEED: float = 260.0
## Kalkışta ekran sarsıntısı (0..1).
const JETPACK_LAUNCH_TRAUMA: float = 0.45
## Uçuş sırasında model profilden bu kadar kameraya döner (derece): kollar yüzü kapatmasın, roket görünsün.
const JETPACK_VIEW_ANGLE_DEGREES: float = 52.0
## Uçarken gövdenin boyuna uzaması (hız yüksek olduğu için normal hava uzaması fazla kaçar).
const JETPACK_STRETCH: float = 0.10
## Roket sesleri (dB).
const SFX_PICKUP_DB: float = -6.0
const SFX_JETPACK_DB: float = -8.0
const SFX_JETPACK_END_DB: float = -10.0

# --- Elmas (para; Aşama 6; scripts/game/pickup_rules.gd) ---
## false: elmas hiç çıkmaz.
const DIAMOND_ENABLED: bool = true
## NADİRLİK: her katta elmas çıkma olasılığı (0..1). Büyüt = daha sık. 0,06 ≈ 17 katta bir.
const DIAMOND_SPAWN_CHANCE: float = 0.06
## Bu kattan önce elmas çıkmaz.
const DIAMOND_MIN_FLOOR: int = 3
## Çıkan toplanabilirin havada (iki kat arasında, zıplama yolunda) olma olasılığı; kalanı platformun üstünde.
const PICKUP_AIR_CHANCE: float = 0.45
## Havadaki toplanabilirin altındaki platformun yüzeyinden yüksekliği (px) ve duvarlara en yakın mesafesi.
const PICKUP_AIR_HEIGHT: float = FLOOR_SPACING * 0.55
const PICKUP_AIR_WALL_MARGIN: float = 60.0
const SFX_DIAMOND_DB: float = -7.0

# --- Kalp (can; oyun turu bazlı, birikmez; scripts/game/pickup_rules.gd) ---
## false: kalp toplanabiliri hiç çıkmaz (bölüm geçişi kalbi HEART_SECTION_BONUS ile ayrı yönetilir).
const HEART_ENABLED: bool = true
## NADİRLİK: uygun her katta kalp çıkma olasılığı (0..1). Elmastan nadir.
const HEART_SPAWN_CHANCE: float = 0.02
## Bu kattan önce çıkmaz; bir kalpten sonra en az bu kadar kat boyunca yenisi çıkmaz.
const HEART_MIN_FLOOR: int = 10
const HEART_MIN_FLOOR_GAP: int = 35
## Oyun başındaki kalp, en fazla taşınabilecek kalp ve her bölüm geçişinde (SECTION_FLOOR_INTERVAL) kazanılan.
const HEART_START: int = 0
const HEART_MAX: int = 5
const HEART_SECTION_BONUS: int = 1
## Kalple kurtarılınca: oyuncu ekranın altından bu kadar yukarıda (px, ayaklar) belirir ve roket bu kadar
## süre (s) uçurur; sonra roketteki gibi bir platforma bırakır.
const HEART_RESCUE_RISE: float = 20.0
const HEART_RESCUE_FLIGHT_TIME: float = 1.6
const SFX_HEART_DB: float = -6.0
const SFX_RESCUE_DB: float = -5.0

# --- Kum saati (zaman yavaşlatma; scripts/game/pickup_rules.gd, tower_camera.gd) ---
## Kum saati oyunun asıl baskısını, kameranın kaymasını yavaşlatır (karakter normal hızında kalır);
## bu sürede kameranın zamanla hızlanması da yavaşlar.
const HOURGLASS_ENABLED: bool = true
## NADİRLİK: uygun her katta kum saati çıkma olasılığı (0..1).
const HOURGLASS_SPAWN_CHANCE: float = 0.025
## Bu kattan önce çıkmaz (kamera henüz yavaş); iki kum saati arası en az bu kadar kat.
const HOURGLASS_MIN_FLOOR: int = 30
const HOURGLASS_MIN_FLOOR_GAP: int = 40
## Etkinin süresi (s), kamera hızının çarpanı ve yavaşlama/geri hızlanma geçiş süresi (s).
## Kullanıcı: 8 s çok uzun bulundu → 5 s; kısa ama belirgin olsun diye çarpan 0,35 → 0,3.
const HOURGLASS_DURATION: float = 5.0
const HOURGLASS_SCROLL_FACTOR: float = 0.3
const HOURGLASS_RAMP_TIME: float = 0.6
## Etki sürerken ekran kenarlarındaki mavi-mor gölgenin saydamlığı.
const HOURGLASS_VIGNETTE_ALPHA: float = 0.6
const SFX_HOURGLASS_DB: float = -6.0
const SFX_HOURGLASS_END_DB: float = -9.0

# --- Başarımlar (scripts/game/achievement_rules.gd: tanımlar, hedefler ve ödüller orada) ---
## false ise izleyici, bildirim ve ana menü düğmesi hiç kurulmaz.
const ACHIEVEMENTS_ENABLED: bool = true
## Bildirim kartının ekranda kalma süresi (s), kayarak girme/çıkma süresi (s), üst kenardan boşluk (px).
const ACHIEVEMENT_TOAST_HOLD: float = 2.8
const ACHIEVEMENT_TOAST_SLIDE: float = 0.45
const ACHIEVEMENT_TOAST_TOP: float = 16.0
const SFX_ACHIEVEMENT_DB: float = -8.0

# --- Debug ---
## F4 yavaş çekimde oyun hızı (efektleri incelemek için).
const DEBUG_SLOW_MOTION_SCALE: float = 0.25

# --- Rekor çizgisi (scripts/game/record_line_rules.gd, scripts/world/record_line.gd) ---
## false: çizgi hiç oluşturulmaz.
const RECORD_LINE_ENABLED: bool = true
## Kayıtlı en yüksek kat bundan küçükse çizgi gösterilmez (ilk katlarda anlamsız).
const RECORD_LINE_MIN_FLOOR: int = 5
## Çizgi: kalınlık (px), kesik uzunluğu ve boşluğu (px), alfa; nefes alırken alfanın oynama payı ve hızı.
const RECORD_LINE_WIDTH: float = 3.0
const RECORD_LINE_DASH: float = 18.0
const RECORD_LINE_GAP: float = 12.0
const RECORD_LINE_ALPHA: float = 0.5
const RECORD_LINE_BREATH_AMOUNT: float = 0.18
const RECORD_LINE_BREATH_SPEED: float = 2.0
## Arkadaki toplamalı hâle: yüksekliği (px) ve alfası.
const RECORD_LINE_HALO_HEIGHT: float = 48.0
const RECORD_LINE_HALO_ALPHA: float = 0.26
## Etiket (yıldız + kat sayısı): yazı boyutu ve çizginin üstündeki boşluk (px).
const RECORD_LINE_LABEL_SIZE: int = 15
const RECORD_LINE_LABEL_GAP: float = 14.0
## Geçilince: parlayıp sönme süresi (s), parlarkenki alfa, kalınlaşma çarpanı ve parıltı parçacığı sayısı.
const RECORD_LINE_CELEBRATE_TIME: float = 0.8
const RECORD_LINE_FLASH_ALPHA: float = 1.0
const RECORD_LINE_FLASH_WIDTH_SCALE: float = 2.2
const RECORD_LINE_SPARKS: int = 48
const SFX_RECORD_LINE_DB: float = -6.0

# --- Kombo elması (scripts/game/combo_diamond_rules.gd; ödül GameState, görüntü ComboPopups/PickupFx) ---
## false: büyük kombolar elmas vermez.
const COMBO_DIAMOND_ENABLED: bool = true
## Bu kadar kat kazandıran kombo 1 elmas verir; sonra her COMBO_DIAMOND_STEP_FLOORS katta +1, en çok COMBO_DIAMOND_MAX.
const COMBO_DIAMOND_MIN_FLOORS: int = 20
const COMBO_DIAMOND_STEP_FLOORS: int = 20
const COMBO_DIAMOND_MAX: int = 3
## Elmas yazısı: kombo bonus yazısının üstündeki uzaklık (px), simge ölçeği, yazı boyutu, süzülme (px) ve süre (s).
const COMBO_DIAMOND_POPUP_RAISE: float = 46.0
const COMBO_DIAMOND_ICON_SCALE: float = 0.8
const COMBO_DIAMOND_FONT_SIZE: int = 22
const COMBO_DIAMOND_RISE: float = 30.0
const COMBO_DIAMOND_LIFETIME: float = 1.3
## Elmas sesi biraz yüksek perdeyle ve kombo bitiş sesinden bu kadar (s) sonra çalar.
const COMBO_DIAMOND_PITCH: float = 1.2
const COMBO_DIAMOND_SOUND_DELAY: float = 0.2

# --- Platform türleri (çatlayan / kayan / buz; scripts/world/platform_type_rules.gd) ---
## false: tüm platformlar normal (özelliği tek sabitle kapatır).
const PLATFORM_TYPES_ENABLED: bool = true
## Toplam özel platform olasılığının üst sınırı (türlerin olasılıkları toplamı bunu aşarsa orantılı küçülür).
const PLATFORM_TYPE_TOTAL_MAX: float = 0.3
## Her tür: bu kattan önce çıkmaz; ilk olasılık, bölüm (SECTION_FLOOR_INTERVAL kat) başına artış, üst sınır.
const PLATFORM_CRUMBLE_MIN_FLOOR: int = 20
const PLATFORM_CRUMBLE_CHANCE: float = 0.08
const PLATFORM_CRUMBLE_CHANCE_PER_SECTION: float = 0.03
const PLATFORM_CRUMBLE_CHANCE_MAX: float = 0.14
const PLATFORM_MOVING_MIN_FLOOR: int = 40
const PLATFORM_MOVING_CHANCE: float = 0.08
const PLATFORM_MOVING_CHANCE_PER_SECTION: float = 0.03
const PLATFORM_MOVING_CHANCE_MAX: float = 0.14
const PLATFORM_ICE_MIN_FLOOR: int = 60
const PLATFORM_ICE_CHANCE: float = 0.07
const PLATFORM_ICE_CHANCE_PER_SECTION: float = 0.025
const PLATFORM_ICE_CHANCE_MAX: float = 0.12
## Çatlayan: üstüne inildikten sonra çökmeye kadar geçen süre (s), titreme genliği (px) ve
## parçaların düşüş süresi (s) / mesafesi (px).
const PLATFORM_CRUMBLE_DELAY: float = 0.6
const PLATFORM_CRUMBLE_SHAKE: float = 2.5
const PLATFORM_CRUMBLE_FALL_TIME: float = 0.75
const PLATFORM_CRUMBLE_FALL_DISTANCE: float = 220.0
## Çatlakların üstüne basılmadan önce görünen oranı (0..1); basınca 1'e büyür.
const PLATFORM_CRACK_IDLE_LENGTH: float = 0.7
## Kayan: yatay salınım genliği (px, merkezden bir yana) ve tam tur süresi (s); MIN_FLOOR'da ilk değer,
## bu kadar kat sonra son değer (genlik ve hız katla biraz artar).
const PLATFORM_MOVING_TRAVEL_START: float = 60.0
const PLATFORM_MOVING_TRAVEL_END: float = 110.0
const PLATFORM_MOVING_PERIOD_START: float = 4.4
const PLATFORM_MOVING_PERIOD_END: float = 3.6
const PLATFORM_MOVING_RAMP_FLOORS: int = 400
## Buz: üstünde yer ivmesi ve sürtünmesinin çarpanı (1 = normal). Sürtünme azaldıkça daha uzun kayar.
const PLATFORM_ICE_ACCEL_FACTOR: float = 0.45
const PLATFORM_ICE_FRICTION_FACTOR: float = 0.3
## Buz parıltısı: kaç saniyede bir platformun üstünden geçer ve geçişin süresi (s).
const PLATFORM_ICE_GLINT_INTERVAL: float = 2.8
const PLATFORM_ICE_GLINT_TIME: float = 0.6
const SFX_CRUMBLE_CRACK_DB: float = -9.0
const SFX_CRUMBLE_DB: float = -6.0

# --- Mıknatıs (elmas avı; Aşama 6; scripts/game/magnet_rules.gd, scripts/game/magnet_field.gd) ---
## Mıknatıs sürerken elmaslar bol çıkar ve menzildekiler oyuncuya uçar: kısa bir "elmas avı" anı.
## false: mıknatıs hiç çıkmaz (özelliği tek satırla kapatır).
const MAGNET_ENABLED: bool = true
## NADİRLİK: uygun her katta mıknatıs çıkma olasılığı (0..1).
const MAGNET_SPAWN_CHANCE: float = 0.03
## Bu kattan önce çıkmaz; iki mıknatıs arası en az bu kadar kat (etki sırasında yenisi çıkmasın).
const MAGNET_MIN_FLOOR: int = 15
const MAGNET_MIN_FLOOR_GAP: int = 35
## Etkinin süresi (s).
const MAGNET_DURATION: float = 7.0
## Çekim menzili (px, oyuncunun gövde ortasından); ~2,5 kat yukarısı ve kulenin büyük kısmı.
const MAGNET_RADIUS: float = 320.0
## Çekilen elmasın hızı: başlangıç (px/s), ivme (px/s²) ve üst sınır. Üst sınır roketin hızından
## (JETPACK_SPEED) büyük olmalı: uçarken de elmaslar oyuncuya yetişsin.
const MAGNET_PULL_START_SPEED: float = 200.0
const MAGNET_PULL_ACCEL: float = 2600.0
const MAGNET_PULL_MAX_SPEED: float = 1700.0
## Elmas oyuncunun gövde ortasına bu kadar yaklaşınca toplanır (px; çarpışma beklenmez).
const MAGNET_COLLECT_DISTANCE: float = 22.0
## Etki sürerken yeni katlarda elmas çıkma olasılığı (normalde DIAMOND_SPAWN_CHANCE). Alındığı anda
## oyuncunun üstünde zaten üretilmiş boş platformlara da aynı olasılıkla elmas serpilir.
const MAGNET_DIAMOND_CHANCE: float = 0.4
## Çekim halkası (oyuncunun çevresinde): yarıçap (px), nabız süresi (s) ve saydamlık.
const MAGNET_AURA_RADIUS: float = 64.0
const MAGNET_AURA_PULSE_TIME: float = 0.9
const MAGNET_AURA_ALPHA: float = 0.32
## Arka arkaya toplanan elmasların sesi: bu süre (s) içinde gelen her elmas perdeyi bir adım yükseltir;
## adım (yarım ton) ve en fazla adım sayısı. Bu süreden kısa aralıkla gelen elmas sesi çalınmaz.
const MAGNET_SFX_CHAIN_WINDOW: float = 0.7
const MAGNET_SFX_CHAIN_SEMITONES: float = 1.0
const MAGNET_SFX_CHAIN_MAX: int = 7
const MAGNET_SFX_MIN_INTERVAL: float = 0.06
const SFX_MAGNET_DB: float = -7.0
const SFX_MAGNET_END_DB: float = -10.0

# --- Elmas mağazası (ürünler ve fiyatlar scripts/game/shop/shop_catalog.gd; kurallar shop_rules.gd) ---
## false ise mağaza düğmesi kurulmaz; kozmetikler, yükseltmeler ve takviyeler hiç uygulanmaz.
const SHOP_ENABLED: bool = true
## Bir takviyeden en çok bu kadar stoklanır (her tur başında bir tanesi kendiliğinden kullanılır).
const SHOP_BOOST_MAX_STOCK: int = 3

# --- Efekt kozmetikleri (iz / toz / hâle; ürünler shop_catalog.gd, yardımcı scripts/fx/trail_cosmetic.gd) ---
## Gökkuşağı izi: tam ton turu süresi (s), pastel doygunluk/parlaklık, iz boyunca ton kayması (0..1 tur).
const TRAIL_RAINBOW_PERIOD: float = 6.0
const TRAIL_RAINBOW_SATURATION: float = 0.8
const TRAIL_RAINBOW_VALUE: float = 0.95
const TRAIL_RAINBOW_SPREAD: float = 0.12
## Varsayılan dışı efekt seçilince iniş tozu, duvar kıvılcımı ve hâlenin seçilen renge boyanma oranı (0..1).
const TRAIL_FX_DUST_TINT: float = 0.45
const TRAIL_FX_SPARK_TINT: float = 0.7
const TRAIL_FX_AURA_TINT: float = 0.8
## Işıltı: aynı anda en çok bu kadar nokta, ömrü (s), boyu (64 px dokuya oranla), saçılma yarıçapı (px), saydamlık.
const TRAIL_SPARKLE_COUNT: int = 5
const TRAIL_SPARKLE_LIFETIME: float = 0.7
const TRAIL_SPARKLE_SCALE_MIN: float = 0.07
const TRAIL_SPARKLE_SCALE_MAX: float = 0.16
const TRAIL_SPARKLE_RADIUS: float = 16.0
const TRAIL_SPARKLE_ALPHA: float = 0.7

# --- Mağaza ekranı (scripts/ui/shop/) ---
## Satın alma (parlak arpej + parıltı), kuşanma (küçük tık + çan), yetmiyor (yumuşak, alçak "tık-tık").
const SFX_SHOP_BUY_DB: float = -6.0
const SFX_SHOP_EQUIP_DB: float = -9.0
const SFX_SHOP_DENY_DB: float = -11.0

# --- Giyilebilir kozmetikler (şapka, tişört, pantolon; CharacterModel + scripts/player/cosmetics) ---
## false ise şapka takılmaz, tişört/pantolon boyanmaz (karakter hep özgün görünümde).
const COSMETICS_ENABLED: bool = true
## Şapka takılırken küçükten büyüyerek belirme süresi (s).
const HAT_POP_TIME: float = 0.28
## Pervaneli şapkanın pervanesi (tur/s).
const HAT_PROPELLER_SPEED: float = 2.2
## Sallanan parçalar (Noel Baba ucu, fes püskülü): yay sertliği, sönüm, hareketten tepki, üst sınır (radyan),
## boşta hafif salınım genliği (radyan) ve süresi (s).
const HAT_SWAY_STIFFNESS: float = 90.0
const HAT_SWAY_DAMPING: float = 7.0
const HAT_SWAY_RESPONSE: float = 3.5
const HAT_SWAY_MAX_ANGLE: float = 0.6
const HAT_SWAY_IDLE_ANGLE: float = 0.06
const HAT_SWAY_IDLE_PERIOD: float = 1.9
