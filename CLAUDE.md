# Tower Climb — Claude Code Talimatları

Icy Tower tarzı, 2D, sonsuz kule tırmanma oyunu. Masaüstü (Windows öncelikli) + web build hedefi.
Öğrenme amaçlı, açık kaynak, ücretsiz paylaşılacak.

- **Motor:** Godot 4 (Standard sürüm, .NET DEĞİL) — **Dil:** GDScript
- **Tasarım:** `docs/GAME_DESIGN.md` (mekanikler ve başlangıç ayar değerleri)
- **Durum:** `docs/PROGRESS.md` (hangi aşamadayız, ne bitti, sırada ne var)

Kullanıcıyla Türkçe konuş.

---

## 0. Ortam kontrolü — her oturumun başında, kod yazmadan önce

Sırayla kontrol et ve sonucu tablo olarak raporla (araç | sürüm | durum):

1. `godot --version` → 4.x olmalı, çıktıda `mono` geçmemeli.
2. `git --version` çalışmalı; proje klasörü bir git reposu olmalı (değilse `git init` öner).
3. `node --version` çalışmalı (godot-mcp için).
4. `claude mcp list` içinde `godot` görünmeli. Yoksa uyar ama durma — `godot` CLI ile devam edilebilir.
5. Proje varsa: `godot --headless --path . --quit` hatasız bitmeli.

1, 2 veya 5 başarısızsa **kod yazma**: eksik olanı ve nasıl kurulacağını söyle, dur.
Aşamaya özel ön koşullar (Tripo, Blender vb.) bölüm 2'deki tabloda; onları sadece o aşamaya gelince kontrol et.

Ardından `docs/PROGRESS.md`'yi oku ve kullanıcıya tek cümleyle hangi aşamada olduğumuzu ve sıradaki işi söyle.

---

## 1. Altın kurallar

1. **Asla kendiliğinden bir sonraki aşamaya geçme.** Aşama bitince bölüm 2'deki bildirimi yap ve kullanıcının "devam" demesini bekle.
2. **Tek seferde tek özellik.** Bitir → çalıştır/doğrula → commit → `PROGRESS.md` güncelle → kullanıcıya nasıl test edeceğini söyle.
3. **Ön koşulu kurulmamış bir araca ihtiyaç duyarsan dur ve bildir**, etrafından dolanma.
4. **Ücretli servis kullanma, hesap açma, internetten asset indirme** — bunları kullanıcıya bırak, ne gerektiğini söyle.
5. Görsel bir şey değiştirdiğinde kullanıcıdan **ekran görüntüsü** iste; göremediğin şeyi "güzel oldu" diye raporlama.

---

## 2. Aşamalar ve geçiş kuralı

| # | Aşama | Bitti sayılır, eğer… | Bu aşama için kullanıcının kurması gerekenler |
|---|---|---|---|
| 1 | **Fizik prototipi** (kutularla) | Kutu karakter koşuyor, momentuma bağlı zıplıyor, duvardan sekiyor; platformlar sonsuz üretiliyor; kamera hızlanarak kayıyor; düşünce oyun bitiyor ve yeniden başlıyor; skor + kombo çalışıyor; debug overlay var. Kutularla bile eğlenceli. | Yok |
| 2 | **Juice / animasyon** | Takla, squash & stretch, iz, iniş tozu, kombo efektleri, ekran sarsıntısı, hit-stop, glow — hepsi `Visual` katmanında, kutu karakterle çalışıyor. | Yok |
| 3 | **Karakter** | 3D karakter (Tripo → `.glb`) `Visual` katmanına takıldı, toon shader + outline ile 2D dünyaya uyuyor, durum animasyonları bağlı. | **Tripo hesabı**, **Blender**, **uv** (`winget install astral-sh.uv`), **blender-mcp** (`claude mcp add blender uvx blender-mcp` + Blender eklentisi) |
| 4 | **Dünya görselleri ve ses** | Kule duvarları, parallax arka plan, platform temaları (her N katta değişen), ışık; ses efektleri ve müzik. | Kullanıcının seçeceği ses/doku kaynakları (lisansları `CREDITS.md`'ye) |
| 5 | **Oyun döngüsü ve arayüz** | Ana menü, duraklatma, game over ekranı, yerel en yüksek skor kaydı, ayarlar (ses, tam ekran). | Yok |
| 6 | **Ek özellikler** | Para toplama, güçlendirmeler vb. — kapsamı bu aşamaya gelince kullanıcıyla belirle. | Kapsama göre |
| 7 | **Paylaşım** | Windows `.exe` ve web build alınıyor; README, CREDITS ve ekran görüntüleri hazır. | **Godot Export Templates** (Editor → Manage Export Templates), itch.io veya GitHub Pages hesabı |

### Aşama bittiğinde kullanıcıya TAM OLARAK bu formatta bildir, sonra dur:

```
🚩 AŞAMA TAMAMLANDI: <no> — <ad>

✅ Yapılanlar:
- ...

🎮 Test etmek için:
- ... (hangi tuşlar, neye bakmalı)

➡️ Sıradaki aşama: <no> — <ad>
🔧 Senin kurman gerekenler: <bölüm 2 tablosundaki liste, yoksa "Yok">

Hazır olduğunda "devam" yaz.
```

Sıradaki aşamanın kurulum gereksinimi varsa, kullanıcı "devam" dedikten sonra önce o araçları kontrol et (sürüm komutu / `claude mcp list`), eksik varsa yine dur.

---

## 3. Mimari kurallar

### Karakter: fizik ve görüntü ayrı
```
Player (CharacterBody2D)      ← scripts/player/player.gd — hareket, çarpışma, durum
 ├─ CollisionShape2D          ← sabit hitbox: 32 x 48 px (değiştirme)
 └─ Visual (Node2D)           ← scripts/player/player_visual.gd — sadece görüntü ve efekt
     └─ (şimdi: ColorRect/Polygon2D kutu — Aşama 3'te: 3D model)
```
- `player.gd` **hiçbir zaman** `Visual`'ın çocuklarına doğrudan dokunmaz.
- `player.gd` durumları yayınlar: `signal state_changed(new_state, old_state)` ve `signal event(name: StringName, data: Dictionary)` (ör. `&"wall_bounce"`, `&"landed"`, `&"combo_up"`).
- Durumlar: `IDLE, RUN, JUMP, FALL, LAND, WALL_BOUNCE, FLIP`.
- `player_visual.gd` bu sinyalleri dinler; takla, squash & stretch gibi her şey burada.
- Karakter için `RigidBody2D` veya hazır fizik davranışı **kullanılmaz**; hareket elle yazılır.

### Ayar değerleri
- Tüm oynanış sayıları tek yerde: `scripts/tuning.gd` (`class_name Tuning`, `const` değerler). Kodda sihirli sayı yok.
- Başlangıç değerleri `docs/GAME_DESIGN.md`'de.

### Autoload'lar
- `Events` — global sinyal otobüsü (oyun bitti, skor değişti vb.)
- `GameState` — skor, kat, kombo, en yüksek skor
- `WindowManager` — pencere modu; tam ekran aç/kapat (`toggle_fullscreen`: F11, Alt+Enter); seçim kaydedilir
- `AudioManager` — ses kanalları (Master/SFX/Music), efekt çalma (`play`), müzik çalar (`music`), seviyeler/sustur, duraklatınca müzik süzgeci
- `GameFlow` — oyun akışı durumu: `MENU, PLAYING, PAUSED, GAME_OVER` (`request(durum)`; kurallar `FlowRules`). **`get_tree().paused`'a doğrudan dokunma**; duraklatmayı sadece `GameFlow` yönetir.
- `ScreenFade` — ekran kararma/açılma geçişi (sahne yenilerken: `await cover()` → yenile → yeni sahne `reveal()`)

### Arayüz (Aşama 5)
- Tüm ekranlar (menü, duraklatma, ayarlar, oyun sonu) `UiScreen`'den türer; denetimler `UiButton` / `UiToggle` / `UiSlider`; renk ve stil sadece `UiStyle`'dan. Ekranlar arası geçiş `UiScreen.link_child`. Yeni ekranlarda aynı dili kullan (koyu arduvaz kart, turkuaz vurgu, altın = ödül).
- Kullanıcıya görünen ayarlar `AudioSettings` / `GameSettings`'e, rekorlar `SaveData`'ya yazılır (`user://`). Testlerde bu sınıfların `path`'ini geçici dosyaya çevir.
- Katmanlar: HUD 1, UiScreen 40, geri sayım 41, başarım bildirimi 42, konfeti 45, radyo 50, ScreenFade 95, debug 100.
- Debug tuşları: F3 overlay, F4 yavaş çekim, F6 sonraki bölüme ışınlan, F7 üstteki platforma roket koy, F8 kalp koy, F9 kum saati koy, F10 mıknatıs koy.

### Güçlendirmeler (Aşama 6)
- Toplanabilir nesne = `Pickup` (Area2D, platformun çocuğu); alınınca `Events.pickup_collected(kind, konum)`. Etkiyi `main` oyuncuya uygular; süreli etkiler `Events.powerup_started/ended` ile duyurulur (HUD, ses).
- Kurallar saf sınıflarda (`JetpackRules`, `JetpackFlight`) + GUT; sayılar `Tuning.JETPACK_*` / `PICKUP_*`. Oyuncunun özel hareket modu `player.gd`'de (`_flight`); görüntüsü `Visual` katmanında (`JetpackFx`, `CharacterModel.set_jetpack_equipped`, `fly` animasyonu).
- Elmas (para): çıkış/yerleşim `PickupRules` + `Tuning.DIAMOND_*`/`PICKUP_AIR_*`; toplam `GameState.diamonds` → `SaveData.save_diamonds` ([wallet]); gösterim `DiamondCounter`.
- Kalp (can, oyun turu bazlı): `GameState.hearts/add_hearts/use_heart` + `Events.hearts_changed`; düşünce `main._on_player_fell` → `Player.rescue` (kısa roket uçuşu). Kurallar `PickupRules`, sayılar `Tuning.HEART_*`; görüntü `HeartArt`, `HeartMeter`, `PickupFx`.
- Kum saati: `TowerCamera.slow_down` (kamera kaymasını yavaşlatır; `Engine.time_scale`'e dokunmaz), çarpan `PickupRules.hourglass_multiplier`, sayılar `Tuning.HOURGLASS_*`; görüntü `HourglassArt`, `SlowTimeFx`; HUD satırı `PowerupRow` (yeni süreli güçlendirme = Hud._powerup_rows'a bir satır).
- Mıknatıs: `MagnetField` (main kurar; elmasları `Pickup.GROUP`'tan bulur, `Pickup.attract` ile çeker; etki sürerken `PlatformSpawner.set_diamond_rush`), kurallar `MagnetRules`, sayılar `Tuning.MAGNET_*`; görüntü `MagnetArt`, `MagnetFx`.
- Elmas yolları: toplama/kombo `GameState.add_diamond/add_diamonds(n)` (tur sayacına eklenir); ödül (başarım) `GameState.grant_reward_diamonds(n)` (eklenmez). Kombo elması `ComboDiamondRules`.
- Rekor çizgisi: `RecordLine` + `RecordLineRules` (tur başındaki rekor kat; `Tuning.RECORD_LINE_*`).
- Başarımlar: tanım/hedef/ödül tek tablo `AchievementRules`; izleyici `AchievementTracker` (main'e kodla eklenir, yalnız PLAYING'de sayar); kayıt `SaveData` [achievements] (rekor sıfırlama silmez); `Events.achievement_unlocked`; bildirim `AchievementToast`; liste `AchievementsMenu`.
- Platform türleri: `Platform` = `AnimatableBody2D` (`kind`: normal / çatlayan / kayan / buz); seçim `PlatformTypeRules`; buz çarpanları `player.gd`'de üstünde durulan platformdan (`_ground`); roket/kalp iniş adayı yalnız `is_safe_landing` platformlar. Yeni tür = `PlatformTypeRules` + `Tuning.PLATFORM_*`; ulaşılabilirlik `PlatformRules.next_center(..., travel)` ile korunmalı.

### Ekran ve pencere
- Tasarım çözünürlüğü **1280 x 720** sabittir (`Tuning.VIEW_WIDTH/HEIGHT`, stretch `canvas_items`, aspect `keep`). Tüm yerleşim ve oynanış sayıları bu koordinatlara göredir; pencere büyüsün diye bu değerleri **değiştirme**.
- Oyun büyütülmüş pencerede başlar (`project.godot` → `display/window/size/mode=2`). Pencereyi büyütmek/tam ekran yapmak ölçekleme ile olur, viewport boyutuyla değil.
- Kule genişliği ayarlanabilir kalmalı: tek kaynak `Tuning.TOWER_WIDTH` (kullanıcı ileride genişletebilir). Duvar konumu, platform üretimi, kamera, dekor alanı gibi her şey bu sabitten **türetilir**; `448`, `320` gibi türetilmiş sayıları koda yazma.
- Pencere moduna sadece `WindowManager` üzerinden dokun (`set_fullscreen`, `toggle_fullscreen`, `is_fullscreen`); başka yerde `DisplayServer.window_set_mode` çağırma. Aşama 5'teki tam ekran ayarı da bunu kullanır.
- Arayüz (HUD, menüler) her pencere boyutunda çalışmalı: sabit piksel konumu yerine anchor/container kullan.

### Klasör yapısı
```
scenes/        main.tscn, player/, world/, ui/, fx/
scripts/       tuning.gd, autoload/, game/ (skor/kombo gibi saf oyun kuralları), player/, world/, ui/, fx/
assets/        sprites/, models/, shaders/, audio/, fonts/
tests/         GUT testleri
tools/         yardımcı scriptler (ör. check_env.ps1)
docs/          GAME_DESIGN.md, PROGRESS.md
```

### Debug overlay
`F3` ile açılıp kapanan bir panel: FPS, hız (vx, vy), durum, kat, kombo, kamera hızı. Aşama 1'in parçası.

### Platformlar
Tek yönlü çarpışma (alttan geçilir, üstüne basılır).

---

## 4. Kod standartları

- GDScript'te **statik tipleme** kullan (`var speed: float = 0.0`, `func jump() -> void:`).
- Tanımlayıcılar İngilizce, yorumlar kısa ve Türkçe olabilir.
- Bir fonksiyon tek iş yapsın; dosyalar ~300 satırı geçmesin.
- `.tscn` dosyalarını elle düzenlerken dikkatli ol (uid/ext_resource tutarlılığı). Mümkünse sahneler sade olsun, düğümleri kodla oluştur.
- Her değişiklikten sonra `godot --headless --path . --quit` ile hata kontrolü yap. Testler varsa çalıştır.
- Saf mantık içeren parçalar (skor/kombo hesabı, platform üretimi kuralları) için GUT testleri yaz.

### Testler (GUT 9.7.1, `addons/gut/`)
- GUT sürümü Godot sürümüyle eşleşmeli (`addons/gut/versions.json`): Godot 4.7+ → GUT 9.7.x. Uyumsuz sürümde komut satırı çalışsa bile editördeki GUT paneli takılır. Godot güncellenirse GUT'u da kontrol et.
- Test dosyaları `tests/test_*.gd`, `extends GutTest`. Ayarlar `.gutconfig.json`'da.
- Çalıştırma (PowerShell; Bash'te `godot` PATH'te yok): `godot --headless --path . -s res://addons/gut/gut_cmdln.gd` → sonda "All tests passed" ve çıkış kodu 0 olmalı.
- Editördeki GUT paneli `.gutconfig.json`'u okumaz; kendi ayarını `user://gut_temp_directory/gut_editor_config.json`'da tutar (kullanıcıya özel, repoda değil). Kullanıcının panelinde Test Directories = `res://tests`, Include Subdirs açık olarak ayarlı.
- Beklenen değerleri `Tuning`'den türet; ayar değişince testler kırılmasın.
- GUT dosyalarını düzenleme. Zip'ten kurulumda dosyalar `res://addons/gut/` altında olmalı (zip'in kök klasörü atlanmalı).

---

## 5. Git

- Her çalışan adımdan sonra commit at. Mesaj: kısa ve açıklayıcı (ör. `feat: duvar sekmesi eklendi`).
- Push'u sadece kullanıcı isterse yap. GitHub CLI (`gh`) **yok**; sadece `git` kullan.
- Remote kullanıcı tarafından verilecek (`git remote add origin <url>`).
- `.gitignore`: `.godot/`, `*.import` dışındaki geçici dosyalar, export çıktıları (`build/`).

---

## 6. Lisans ve asset'ler

- Dışarıdan gelen her asset için `CREDITS.md`'ye kaynak + lisans satırı ekle.
- Kod lisansı: MIT (kullanıcı başka bir şey istemedikçe).
