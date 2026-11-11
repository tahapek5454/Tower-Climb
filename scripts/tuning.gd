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

# --- Karakter ---
const PLAYER_WIDTH: float = 32.0
const PLAYER_HEIGHT: float = 48.0

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

# --- Debug ---
## F4 yavaş çekimde oyun hızı (efektleri incelemek için).
const DEBUG_SLOW_MOTION_SCALE: float = 0.25
