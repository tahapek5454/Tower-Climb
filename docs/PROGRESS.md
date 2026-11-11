# İlerleme

**Aktif aşama:** 2 — Juice / animasyon
**Durum:** Devam ediyor (1/8 madde)

## Aşama 1 — Fizik prototipi
- [x] Godot projesi + klasör yapısı + `.gitignore` + autoload'lar (`Events`, `GameState`)
- [x] `tuning.gd` (GAME_DESIGN.md'deki değerlerle)
- [x] Kule duvarları + kutu karakter: koşma (ivme/sürtünme)
- [x] Zıplama: momentuma bağlı yükseklik, değişken zıplama, coyote time, jump buffer
- [x] Duvar sekmesi
- [x] Tek yönlü platformlar + sonsuz platform üretimi (eskileri temizleme)
- [x] Kamera: bekleme, hızlanan kayma, yakalama bölgesi
- [x] Game over + yeniden başlatma
- [x] Skor + kombo sistemi (+ GUT testleri)
- [x] Basit HUD (kat, skor, kombo)
- [x] Debug overlay (F3)

## Aşama 2 — Juice / animasyon
- [x] Görsel katman yapısı (Squash → Spin) + squash & stretch (yay ile)
- [ ] Takla (büyük zıplama, duvar sekmesi, kombo zıplayışı)
- [ ] Hareket izi (trail) + hız çizgileri
- [ ] İniş tozu + duvar kıvılcımı (parçacıklar)
- [ ] Ekran sarsıntısı (büyük iniş, duvar sekmesi, kombo bitişi)
- [ ] Hit-stop (kombo bitişinde ~60 ms yavaşlama)
- [ ] Kombo yazıları ("COMBO x7!") + skor sayacı tween
- [ ] Glow/bloom (WorldEnvironment) + renk vurguları

## Tamamlanan aşamalar
- Aşama 1 — Fizik prototipi (2026-11-10)

## Notlar

### Ortam
- Kullanıcının kurulu araçları: Godot 4.7.2 Standard, Git, Node.js, godot-mcp, GUT 9.7.1. `gh` yok.
- Editör dili İngilizce. Renderer: `gl_compatibility` (web build uyumu için).
- `godot` komutu PowerShell'de çalışır, Bash'te PATH'te yok.
- `project.godot`'u editör açıkken dışarıdan değiştirince kullanıcıya editörü yeniden açmasını söyle; yoksa editör eski hâlini geri yazabilir.

### Kullanıcı kararları
- Ayarlar `const` kalacak, oyun içi canlı ayar paneli şimdilik yok. Güçlendirmeler ileride çalışma zamanı çarpanlarıyla eklenecek (bkz. GAME_DESIGN.md).
- Kule genişliği 896 px; ayarlanabilir kalmalı (`Tuning.TOWER_WIDTH`). Yanlardaki boşluklara Aşama 4'te dış çevre dekoru gelecek.
- Görünüş (HUD, oyun bitti yazısı) şimdilik önemsenmiyor; genel görsel düzenlemede (Aşama 4–5) ele alınacak.
- Doğrulama yöntemi: headless'ta simüle girişle sayısal kontrol + kullanıcının elle testi. Otomatik ekran görüntüsü şimdilik istenmiyor.

### Mimari
- Dünya koordinatları: x=0 kule ortası, y=0 zeminin üstü, yukarı = -y. Oyuncunun orijini ayaklarında.
- Giriş eylemleri (`project.godot`): `move_left`, `move_right`, `jump`, `pause`, `toggle_debug`, `toggle_fullscreen`, `restart`. `pause` henüz bir şey yapmıyor (Aşama 5).
- `Player.event` olayları: `jumped`, `jump_cut`, `landed {speed, floor}`, `wall_bounce`. `state_changed` yayınlanıyor; `LAND`, `WALL_BOUNCE`, `FLIP` durumları henüz kullanılmıyor (Aşama 2'de görsel tarafta).
- Duvarlar kamerayı dikeyde takip eder (`tower.gd`).
- Platformlar: kurallar `scripts/world/platform_rules.gd` (saf), üretim `platform_spawner.gd`.
- Kamera: `TowerCamera` (`scripts/world/tower_camera.gd`), kuralları `CameraRules`.
- Skor/kombo: kurallar `scripts/game/combo_counter.gd` (saf), durum `GameState`. `main.gd` iniş olayını `GameState.register_landing(floor)`'a iletir.
- Oyun sonu: oyuncu ekranın altından tamamen çıkınca `GameState.end_game()`. Geçici yazı `scripts/ui/game_over_label.gd` (Aşama 5'te gerçek ekranla değişecek). Yeniden başlatma: R veya Space (0,5 s gecikmeyle) → `GameState.reset()` + sahneyi yeniden yükleme.
- UI: `scripts/ui/hud.gd` (sol üst), `scripts/ui/debug_overlay.gd` (sağ üst, F3).
- Görsel katman: `Visual` → `Squash` (ayaklarda, ölçeklenir) → `Spin` (gövde ortasında, döner; takla için) → gövde + göz. Juice ayar değerleri de `tuning.gd`'de ("Juice" bölümleri). Yay: `scripts/fx/spring.gd` (saf, GUT testli).

### Ölçümler ve testler
- Zıplama yükseklikleri: duran ~176 px (1,4 kat), tam hızda ~444 px (3,5 kat), kısa basış ~68 px. Coyote time platform kenarında doğrulandı.
- GUT testleri: platform kuralları (7), kamera kuralları (7), kombo (11), skor (5), yay (4). Toplam 34.
- Squash & stretch (ölçüldü, 2. ayar): zıplama boyu 1,25–1,50 (120–400 ms), normal iniş (500 px/s) 0,68 (~250 ms), sert iniş 0,50, duvar 1,40. İlk ayar (%15 uzama, ~150 ms) kullanıcıya hiç hissettirmedi: juice efektleri belirgin ve en az ~0,25 s görünür olmalı.
- F4: debug yavaş çekim (x0,25), efektleri incelemek için. Hit-stop maddesinde `Engine.time_scale` ile çakışmasına dikkat.
- Headless simülasyonlar gerçek zamanlı çalışır; uzun süreli davranışları (ör. hız tavanı) saf kural testleriyle doğrula.
