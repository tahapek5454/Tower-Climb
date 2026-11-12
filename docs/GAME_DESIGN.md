# Tower Climb — Oyun Tasarım Belgesi

## Konsept
Bir kulenin içindeyiz. Oyuncu karakteri sağa-sola koşturup zıplatarak platformlardan yukarı tırmanır.
Kamera giderek hızlanarak yukarı kayar; ekranın altında kalan oyuncu kaybeder. Amaç: olabildiğince yükseğe çıkmak ve büyük kombolarla puan toplamak.
Ruh hali: hızlı, akışkan, abartılı ve eğlenceli animasyonlar (takla, sekme, patlayan efektler).

## Kontroller
| Eylem | Klavye |
|---|---|
| Sola / sağa | ← → veya A D |
| Zıpla | Space, ↑ veya W |
| Duraklat | Esc |
| Debug overlay | F3 |
| Debug yavaş çekim (x0,25) | F4 |
| Debug: sonraki bölüme ışınlan | F6 |
| Tam ekran aç/kapat | F11 veya Alt+Enter |
| Yeniden başla (oyun bitince) | R veya Space |

Zıplamayı oyuncu yapar (otomatik zıplama yok). Gamepad desteği sonra eklenebilir.

## Ekran
- Temel (tasarım) çözünürlüğü: **1280 x 720**, stretch mode `canvas_items`, aspect `keep`. Bu, oyun dünyasının koordinat sistemidir; pencere boyutu değildir. Görüntü pencereye/ekrana ölçeklenir, 16:9 olmayan ekranlarda kenarlarda siyah bant kalır.
- Oyun **büyütülmüş (maximized) pencerede** başlar. **F11** veya **Alt+Enter** tam ekranı açıp kapatır (`WindowManager` autoload'u). Kalıcı tam ekran ayarı Aşama 5'teki ayarlar menüsünde.
- Oynanabilir kule genişliği: **896 px** (`TOWER_WIDTH`; ekranın %70'i), ekranın ortasında. Sol ve sağda duvarlar (duvar kalınlığı 48 px); duvarların dışı dekor alanı.

## Temel mekanikler

### Yatay hareket
- Yerde ivmelenme ve sürtünme var; havada kontrol daha zayıf ama var.
- Yüksek yatay hız = yüksek zıplama. **Oyunun kalbi bu.**

### Zıplama
- `jump_velocity = JUMP_BASE + abs(vx) * JUMP_SPEED_BONUS`
- Değişken zıplama: tuş erken bırakılırsa yukarı hız kesilir.
- Coyote time ve jump buffer var.

### Duvar sekmesi
- Karakter duvara `WALL_BOUNCE_MIN_SPEED` üzerinde bir hızla çarparsa: `vx = -vx * WALL_BOUNCE_DAMPING`.
- Havadaysa küçük bir yukarı itme alır ve takla tetiklenir.

### Platformlar
- Tek yönlü (alttan geçilir).
- Her "kat" sabit aralıkla dizilir; her katta bir platform.
- Platform genişliği yükseldikçe daralır; her bölüm (100 kat) biraz daha geniş başlar ve bölüm içinde daralır. Her platform bu tipik genişlikten rastgele sapar; ara sıra (yükseldikçe daha sık) sürpriz dar platform çıkar. Her 100 katta bir tam genişlikte "bölüm platformu" (tema değişimi için).
- Platform yatay konumu rastgele ama oynanabilir: bir önceki platformdan ulaşılamayacak bir yere konmaz.

### Kamera
- Oyuncu belli bir kata ulaşana kadar kamera bekler, sonra kaymaya başlar.
- Kayma hızı zamanla artar (üst sınırı var).
- Oyuncu ekranın üst bölgesine çıkarsa kamera onu yakalamak için hızlanır.
- Oyuncu ekranın altından çıkarsa: **oyun biter**.

### Skor ve kombo
- Taban skor: ulaşılan en yüksek kat x 10.
- **Kombo:** Tek zıplayışta **2 veya daha fazla kat** atlamak kombo başlatır/devam ettirir.
  - Kombo süresi `COMBO_TIMEOUT` saniye; her kombo zıplayışı süreyi yeniler.
  - Kombo; 2 kattan az atlanan bir inişte veya süre dolunca biter.
  - Kombo bittiğinde: `kombo_puanı = (komboda atlanan toplam kat)^2`, eğer kombo en az 2 zıplayıştan oluştuysa.
  - "Atlanan kat" = inilen kat − zıplanan kat (aşağı inişte negatif → kombo biter).
  - Oyun biterken aktif bir kombo varsa puanı yine sayılır.
- Ekranda: kat, skor, aktif kombo sayacı + kalan süre çubuğu.

### Taklalar
- Görsel bir ödül; fizikle ilgili değil (`Visual` katmanında).
- Tetikleyiciler: büyük zıplama (dikey hız eşiği aşılınca), duvar sekmesi, kombo zıplayışları.
- Dönüş yönü yatay hareket yönüne göre; havada kalma süresine göre 1 veya daha fazla tur; inişte açı sıfırlanır.

## Başlangıç ayar değerleri (`scripts/tuning.gd`)
Bunlar başlangıç noktasıdır; oynayarak ayarlanacak.
Değerler `const` olarak kalır (oyun içi canlı ayar paneli şimdilik yok). İleride güçlendirmeler (Aşama 6) karakteri hızlandırıp yavaşlatabilir: bu, `Tuning` sabitlerini değiştirerek değil, oyuncu üzerinde çalışma zamanı çarpanlarıyla (ör. hız çarpanı) yapılacak; `Tuning` taban değer olarak kalır.

| Sabit | Değer | Not |
|---|---|---|
| `GRAVITY` | 2400 px/s² | |
| `MAX_FALL_SPEED` | 1800 px/s | |
| `MAX_RUN_SPEED` | 900 px/s | |
| `GROUND_ACCEL` | 2600 px/s² | |
| `GROUND_FRICTION` | 1800 px/s² | |
| `AIR_ACCEL` | 1400 px/s² | |
| `JUMP_BASE` | 900 px/s | |
| `JUMP_SPEED_BONUS` | 0.6 | max hızda ~1440 px/s |
| `JUMP_CUT_MULTIPLIER` | 0.5 | tuş erken bırakılınca |
| `COYOTE_TIME` | 0.10 s | |
| `JUMP_BUFFER_TIME` | 0.12 s | |
| `WALL_BOUNCE_MIN_SPEED` | 300 px/s | |
| `WALL_BOUNCE_DAMPING` | 0.85 | |
| `WALL_BOUNCE_UP_BOOST` | 150 px/s | sadece havadayken |
| `FLOOR_SPACING` | 128 px | katlar arası dikey mesafe |
| `PLATFORM_WIDTH_MAX` | 360 px | başlangıçta |
| `PLATFORM_WIDTH_MIN` | 140 px | yükseklerde (tipik genişlik; 300. kat) |
| `PLATFORM_SECTION_START_BONUS` | +80 px | her bölüm başında, bölüm boyunca erir |
| `PLATFORM_WIDTH_JITTER_MIN/MAX` | x0.75 – x1.15 | rastgele sapma |
| `PLATFORM_SURPRISE_CHANCE_START/END` | %4 → %15 | sürpriz dar platform olasılığı |
| `PLATFORM_SURPRISE_FACTOR` | x0.55 | sürpriz dar platform |
| `PLATFORM_WIDTH_ABS_MIN` | 90 px | mutlak alt sınır |
| `CAMERA_START_FLOOR` | 5 | kamera bu katta kaymaya başlar |
| `CAMERA_START_SPEED` | 40 px/s | |
| `CAMERA_SPEED_STEP` | +12 px/s her 30 s | |
| `CAMERA_MAX_SPEED` | 260 px/s | |
| `CAMERA_CATCHUP_ZONE` | ekranın üst %30'u | |
| `COMBO_MIN_FLOORS` | 2 | |
| `COMBO_TIMEOUT` | 3.0 s | |
| `FLIP_VELOCITY_THRESHOLD` | 1200 px/s | dikey hız |

## Juice listesi (Aşama 2)
- Squash & stretch: zıplarken dikey uzama, inişte yatay ezilme (hıza orantılı).
- Takla dönüşleri (tween), hareket izi (trail) ve hız çizgileri.
- İniş ve duvar sekmesinde toz/kıvılcım parçacıkları.
- Ekran sarsıntısı (büyük iniş, duvar sekmesi, kombo bitişi).
- Hit-stop: kombo bitişinde ~60 ms zaman yavaşlaması.
- Kombo yazısı: büyüyerek beliren, sallanan "COMBO x7!" etiketleri; skor sayacı tween ile.
- Glow ve renk vurguları. (Uygulama: WorldEnvironment yerine toplamalı ışık hâleleri — Compatibility renderer/web uyumu için; bkz. PROGRESS.md.)

## Görsel yön (Aşama 4'te netleşecek)
- Karakter (Aşama 3'te yapıldı): chibi **kartal maskotu** — beyaz kafa, turuncu gaga ve ayaklar, düz gri tişört, koyu pantolon, siyah tüylü kollar, beyaz kuyruk. Tripo ile üretilmiş 3D model; yan kamerayla şeffaf bir katmanda çizilir, toon shader + açık renkli dış çizgi. Ekranda ~94 px; hitbox 32x48 sabit.
- Karakter animasyonları: bekleme, koşu (hız koşu hızına bağlı), zıplama, kanat çırpma, düşme, iniş; taklada rastgele **topak** ya da **yıldız** (yan takla).
- Karakter siyah-beyaz-turuncu olduğu için **kule içi orta tonda** olmalı (siyah ve beyazdan uzak).
- Dünya: kodla/shader ile üretilen şık bir kule; parallax katmanlar; her 100 katta tema değişimi.
- Duvarların dışındaki boşluklar (dekor alanı): dış çevre — doğa, bulutlar vb. (Aşama 4). Kule genişliği değişirse dekor kalan alana kendiliğinden uymalı.
- Şimdilik dünya düz renkli şekiller.
