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

# --- Skor ve kombo ---
const SCORE_PER_FLOOR: int = 10
## Tek zıplayışta en az bu kadar kat atlanırsa kombo sayılır.
const COMBO_MIN_FLOORS: int = 2
## Kombonun puan vermesi için gereken en az zıplayış sayısı.
const COMBO_MIN_JUMPS: int = 2
const COMBO_TIMEOUT: float = 3.0

# --- Takla (görsel) ---
## Bu dikey hızın üstündeki zıplamalar takla tetikler.
const FLIP_VELOCITY_THRESHOLD: float = 1200.0
