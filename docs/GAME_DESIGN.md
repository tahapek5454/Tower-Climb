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
| Debug: üstteki platforma roket koy | F7 |
| Debug: üstteki platforma kalp koy | F8 |
| Debug: üstteki platforma kum saati koy | F9 |
| Tam ekran aç/kapat | F11 veya Alt+Enter |
| Tüm sesi kapat/aç | M |
| Yeniden başla (oyun bitince) | R veya Space |
| Menülerde gezin / seç / geri | ↑ ↓ ← → / Enter veya Space / Esc (fare de çalışır) |

Zıplamayı oyuncu yapar (otomatik zıplama yok). Gamepad desteği sonra eklenebilir.

## Ekran
- Temel (tasarım) çözünürlüğü: **1280 x 720**, stretch mode `canvas_items`, aspect `keep`. Bu, oyun dünyasının koordinat sistemidir; pencere boyutu değildir. Görüntü pencereye/ekrana ölçeklenir, 16:9 olmayan ekranlarda kenarlarda siyah bant kalır.
- Oyun **büyütülmüş (maximized) pencerede** başlar. **F11** veya **Alt+Enter** tam ekranı açıp kapatır (`WindowManager` autoload'u). Tam ekran seçimi ayarlar menüsünden de yapılır ve kaydedilir.
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
| `CAMERA_SECTION_SPEED_BONUS` | +30 px/s her bölüm geçişinde (2 s'de yumuşak) | Aşama 6: seviye atladıkça hızlanma (yazı yok: oyuncu hızı hisseder) |
| `CAMERA_MAX_SPEED` | 320 px/s | Aşama 6'da 260'tan yükseltildi |
| `CAMERA_CATCHUP_ZONE` | ekranın üst %30'u | |
| `COMBO_MIN_FLOORS` | 2 | |
| `COMBO_TIMEOUT` | 3.0 s | |
| `FLIP_VELOCITY_THRESHOLD` | 1200 px/s | dikey hız |

## Güçlendirmeler (Aşama 6)

Toplanabilir nesneler platformların üstünde hafifçe süzülür (`Pickup`); oyuncu dokununca alınır.

### Roket (jetpack)
- **Çıkış:** nadir. Uygun her platformda `JETPACK_SPAWN_CHANCE` (%2,2; "Şans" yükseltmesiyle artar) olasılık; `JETPACK_MIN_FLOOR` (15) kattan önce ve bölüm platformunda çıkmaz; bir roketten sonra `JETPACK_MIN_FLOOR_GAP` (40) kat boyunca yenisi çıkmaz. Ortalama ~70 katta bir. `JETPACK_ENABLED = false` özelliği kapatır.
- **Uçuş:** `JETPACK_FLIGHT_TIME` (2,2 s; yükseltmeyle 3,4 s'ye kadar) boyunca `JETPACK_SPEED` (1100 px/s) ile yukarı. Oyuncu sağa/sola kayabilir; yerçekimi, zıplama ve duvar sekmesi kapalı. Karakter süpermen pozunda (kollar yukarıda), sırtında roket, memeden alev + duman izi.
- **Puan:** uçarken geçilen her kat normal kat puanını kazandırır (kombo bonusu vermez). Aktif kombo uçuş boyunca donar; roketin bıraktığı platforma iniş komboyu ne bozar ne uzatır.
- **Güvenli bırakma:** süre dolunca roket oyuncuyu üstteki platformlardan birinin (yatayda en yakını) üstüne taşır, yüzeyin biraz üstünde küçük bir sıçrayışla bırakır; boş roket arkaya düşüp kaybolur. Uçarken ekranın altında kalmak mümkün değil (kamera oyuncuyu izler).
- **HUD:** uçuş sürerken "ROKET" satırı ve yakıt çubuğu.

### Elmas (para)
- **Çıkış:** nadir. Her katta `DIAMOND_SPAWN_CHANCE` (%6, ≈ 17 katta bir), `DIAMOND_MIN_FLOOR` (3) kattan itibaren. %45 (`PICKUP_AIR_CHANCE`) havada — iki kat arasında, kulenin herhangi bir yerinde — kalanı platformun üstünde. Bir katta tek toplanabilir (roket öncelikli). `DIAMOND_ENABLED = false` kapatır.
- **Birikim:** toplam kalıcıdır (`user://save.cfg` [wallet]); her alışta kaydedilir; rekor sıfırlama silmez. HUD'da "ELMAS" satırı, ana menüde toplam, oyun sonunda bu oyunda toplanan (+N).
- **Harcama:** elmas mağazası ve "elmasla devam et" (aşağıda).

### Kalp (can)
- **Oyun turu bazlı:** her oyun `HEART_START` (0) kalple başlar, oyunlar arası birikmez; en fazla `HEART_MAX` (3; yükseltmeyle 6'ya kadar).
- **Kazanma:** nadir toplanabilir (`HEART_SPAWN_CHANCE` %1,5, `HEART_MIN_FLOOR` 10'dan sonra, iki kalp arası en az `HEART_MIN_FLOOR_GAP` 35 kat; havada ya da platformda) ve her bölüm geçişinde (her 100 kat) `HEART_SECTION_BONUS` (+1).
- **Ölüm:** kalp varken ekranın altına düşülürse 1 kalp harcanır; oyuncu ekranın altında belirir, sırtına roket takılır ve `HEART_RESCUE_FLIGHT_TIME` (1,6 s) uçup roketteki gibi bir platforma bırakılır. Kalp yoksa oyun biter.
- **HUD (kalp):** "CAN" satırında kalpler; kazanınca başın üstünde kalp yükselir, kurtarılınca kalp ikiye kırılır.

### Kum saati (yavaş zaman)
- **Çıkış:** nadir (`HOURGLASS_SPAWN_CHANCE` %1,8), `HOURGLASS_MIN_FLOOR` (30) kattan sonra, iki kum saati arası en az 40 kat; havada ya da platformda.
- **Etki:** `HOURGLASS_DURATION` (3,5 s; yükseltmeyle 5,75 s'ye kadar) boyunca kameranın kayması `HOURGLASS_SCROLL_FACTOR` (×0,3) hızına yumuşakça iner, sonra yumuşakça döner; bu sürede kameranın zamanla hızlanması da yavaşlar. Karakter normal hızında kalır. Sürerken yeniden alınırsa süre yenilenir.
- **Görsel/ses:** ekran kenarlarında yumuşak mor-mavi gölge, HUD'da "YAVAŞ ZAMAN" çubuğu, yavaşlama ve normale dönme sesleri.

## Elmas mağazası (Aşama 6)
Yalnız ana menüden açılır. Ürünler ve fiyatlar `scripts/game/shop/shop_catalog.gd` tablosunda.
- **Kozmetikler** (alınır, kuşanılır; her yuvada tek ürün, mağazada satın almadan denenir):
  - Şapka (10): kep, bere, parti külahı, hasır, fes, kovboy, pervaneli, silindir, Noel Baba, altın taç (80–400).
  - Tişört (9): düz renkler, denizci ve arı çizgili, puantiyeli, yıldızlı (30–90). Pantolon (5): kot, haki, zeytin, bordo, krem (30–40).
  - Efekt (6): koşu izi + iniş tozu + hâle renk takımı; düz renkler, altın toz ve yıldız tozu (ışıltılı), gökkuşağı (40–160).
- **Takviyeler** (tek kullanımlık, en çok 3 stok; sonraki turun başında kendiliğinden kullanılır): yedek kalp (15), roketli çıkış (25).
- **Yükseltmeler** (kalıcı, 3 seviye): roket süresi +0,4 s, kum saati +0,75 s, mıknatıs +1 s (60 / 120 / 200); kalp sınırı +1, şans ×(1 + 0,15·seviye) (80 / 160 / 260). Yükseltmesiz güçlendirmeler bilerek kısa ve seyrek; tam seviye eski değerlerin biraz üstü.
- **Elmasla devam et:** kalpsiz düşünce oyun sonundan önce 3 sn'lik kart; tur başına 2 kez (10, sonra 20 elmas). Kabul edilirse kalp kurtarmasındaki gibi roketle kurtarılır; reddedilir ya da süre dolarsa oyun biter. Kart beklerken dünya donar.
- Mıknatıs: taban süre 5 s (`MAGNET_DURATION`), çıkma olasılığı %2,2.
- Her parça tek sabitle kapanır: `SHOP_ENABLED`, `COSMETICS_ENABLED`, `UPGRADES_ENABLED`, `BOOSTS_ENABLED`, `REVIVE_ENABLED`.

## Juice listesi (Aşama 2)
- Squash & stretch: zıplarken dikey uzama, inişte yatay ezilme (hıza orantılı).
- Takla dönüşleri (tween), hareket izi (trail) ve hız çizgileri.
- İniş ve duvar sekmesinde toz/kıvılcım parçacıkları.
- Ekran sarsıntısı (büyük iniş, duvar sekmesi, kombo bitişi).
- Hit-stop: kombo bitişinde ~60 ms zaman yavaşlaması.
- Kombo yazısı: büyüyerek beliren, sallanan "x7" etiketleri (sadece çarpan; 2026-11-13 kullanıcı isteğiyle "COMBO" kelimesi kaldırıldı); skor sayacı tween ile.
- Glow ve renk vurguları. (Uygulama: WorldEnvironment yerine toplamalı ışık hâleleri — Compatibility renderer/web uyumu için; bkz. PROGRESS.md.)

## Görsel yön (Aşama 4'te yapıldı)
- Karakter (Aşama 3'te yapıldı): chibi **kartal maskotu** — beyaz kafa, turuncu gaga ve ayaklar, düz gri tişört, koyu pantolon, siyah tüylü kollar, beyaz kuyruk. Tripo ile üretilmiş 3D model; yan kamerayla şeffaf bir katmanda çizilir, toon shader + açık renkli dış çizgi. Ekranda ~94 px; hitbox 32x48 sabit.
- Karakter animasyonları: bekleme, koşu (hız koşu hızına bağlı), zıplama, kanat çırpma, düşme, iniş; taklada rastgele **topak** ya da **yıldız** (yan takla).
- Karakter siyah-beyaz-turuncu olduğu için **kule içi orta tonda** olmalı (siyah ve beyazdan uzak).
- Dünya: kodla/shader ile üretilen şık bir kule; parallax katmanlar; her 100 katta tema değişimi.
- Duvarların dışındaki boşluklar (dekor alanı): dış çevre — doğa, bulutlar vb. (Aşama 4). Kule genişliği değişirse dekor kalan alana kendiliğinden uymalı.
- Dünya tamamen kodla/shader ile çizilir (dış görsel dosyası yok): taş kule iç duvarı (parallax), taş sütun yan duvarlar, kule dışında gökyüzü + bulutlar + kahve dağlar + kule dibinde çimenli ova.
- 5 bölüm teması (her 100 katta, altın bölüm platformundan sonra yumuşak geçiş): Taş kule, Yosunlu, Alacakaranlık, Buz, Gece; sonra döngü.
- Platformlar: tema başına 4 stil (ağırlıklı, art arda aynı stil gelmez) + süsler (yosun, çimen, mantar, kar, kristal, sarmaşık, fener, saçak).
- Duvar süsleri: meşale, pencere, sancak, flama (Gece'de ampul dizisi); başlangıç alanı (sandık, fıçı, tabela, mangal).
- Işık: toplamalı "sahte ışık" hâleleri (fener/meşale titrer). Ortam parçacıkları: toz, yaprak, kar, ateş böceği.
- Arayüz: koyu arduvaz yarı saydam kartlar, soluk turkuaz vurgu, altın kombo (UiStyle).

## Oyun akışı ve arayüz (Aşama 5'te yapıldı)
- Akış: **ana menü → oyun ⇄ duraklatma → oyun sonu** (`FlowRules` / `GameFlow`). Menü oyun dünyasının üstünde açılır (kule, kartal ve parçacıklar arkada canlı).
- **Ana menü:** zıplayarak gelen "TOWER CLIMB" başlığı, rekorlar (en iyi skor / en yüksek kat / en uzun kombo), Oyna / Ayarlar / Çıkış (web'de Çıkış yok); kartal arada küçük zıplamalar yapar; sağ altta yapımcı kartı (`CreatorInfo`; tek satırla kapatılır).
- **Duraklatma (Esc):** dünya donar ve kararır, müzik boğuklaşır; Devam (3-2-1 sayımı) / Ayarlar / Ana menü. Pencere arka plana geçince de duraklar (ayarlanabilir).
- **Ayarlar:** genel / efekt / müzik ses seviyeleri, tümünü sustur (açılınca kaydırıcılar sıfıra kayıp kilitlenir), tam ekran, ekran sarsıntısı (hit-stop dahil), odak kaybında duraklat, müzik klasörünü aç, kontroller sayfası, rekorları sıfırla (onaylı). Değişiklikler anında kaydedilir.
- **Oyun sonu:** zıplayan başlık, sayarak gelen Kat / Skor / En uzun kombo / Süre; kırılan rekor altın "REKOR" rozeti, altın çerçeve, konfeti ve fanfarla kutlanır; Tekrar (R) / Ana menü; 0,5 s giriş gecikmesi.
- **Kayıt:** rekorlar `user://save.cfg`, ayarlar `user://settings.cfg` (Windows: `%APPDATA%\Godot\app_userdata\Tower Climb\`).
- Stil: koyu arduvaz yarı saydam kart, soluk turkuaz vurgu, altın = ödül/rekor; ekranlar `UiScreen` tabanlıdır (belirme animasyonu, klavye + fare gezinmesi, arayüz sesleri).

## Ses
- Efektler kodla sentezlenir (`tools/sfx/generate_sfx.py`): zıplama (hıza göre perde), iniş, duvar, kombo (majör gamda yükselir), kombo bitişi, bölüm, oyun sonu, takla vuuşu, arayüz (üzerine gelme / tık / geri), yeni rekor fanfarı.
- Müzik oyunla gelmez: masaüstünde sol alttaki **radyo paneli** oyuncunun kendi müziklerini (mp3/ogg/wav, `user://music`) çalar; ekleme: klasörü aç (kopyala) ya da dosyaları pencereye sürükle-bırak (dosya seçici yok). Web'de müzik yok. Efekt aç/kapa ve tüm sesi kapat (M) panelde.
