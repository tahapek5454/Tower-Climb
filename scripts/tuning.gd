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
const PLATFORM_CORNER_RADIUS: float = 9.0
## Üstteki açık şeridin ve alttaki koyu kenarın kalınlığı (px); ne kadar açık/koyu oldukları.
const PLATFORM_TOP_HEIGHT: float = 5.0
const PLATFORM_UNDERSIDE_HEIGHT: float = 5.0
const PLATFORM_TOP_LIGHTEN: float = 0.35
const PLATFORM_UNDERSIDE_DARKEN: float = 0.30
## Platformun arka duvara düşen gölgesi: yayılma (px), aşağı kayma (px) ve koyuluk.
const PLATFORM_SHADOW_SIZE: float = 5.0
const PLATFORM_SHADOW_OFFSET: float = 5.0
const PLATFORM_SHADOW_ALPHA: float = 0.28

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
const PLATFORM_WIDTH_MAX: float = 360.0
const PLATFORM_WIDTH_MIN: float = 140.0
## Her bu kadar katta bir tam genişlikte bölüm platformu.
const SECTION_FLOOR_INTERVAL: int = 100
## Platform genişliği bu kata kadar MAX'tan MIN'e doğrusal daralır.
const PLATFORM_NARROW_FLOORS: int = 300
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
const CAMERA_MAX_SPEED: float = 260.0
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
## Kombo yazısı bu zıplayış sayısından itibaren gösterilir ("COMBO x2!").
const COMBO_POPUP_MIN_JUMPS: int = 2
## Yazı boyutu: MIN_JUMPS'ta FONT_MIN, FONT_FULL_JUMPS ve üstünde FONT_MAX.
## (Kullanıcı tercihi: minimal. Asset aşamasında görünüm yeniden ele alınacak.)
const COMBO_POPUP_FONT_MIN: int = 18
const COMBO_POPUP_FONT_MAX: int = 26
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

# --- Debug ---
## F4 yavaş çekimde oyun hızı (efektleri incelemek için).
const DEBUG_SLOW_MOTION_SCALE: float = 0.25
