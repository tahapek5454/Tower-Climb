# İlerleme

**Aktif aşama:** 2 — Juice / animasyon
**Durum:** Devam ediyor (4/8 madde)

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
- [x] Görsel katman yapısı + squash & stretch (yay ile)
- [x] Takla (büyük zıplama, duvar sekmesi, kombo zıplayışı)
- [x] Hareket izi (trail) + hız çizgileri
- [x] İniş tozu + duvar kıvılcımı (parçacıklar)
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
- Görsel katman: `Visual` (ayaklar) → `Spin` (gövde ortası, döner: takla) → `Squash` (gövde altı, ölçeklenir: dikken ayaklar yerde, takla sırasında gövde kendi boyu yönünde uzar) → gövde + göz. Aşama 3'te model `Squash`'ın içine takılacak. Juice ayar değerleri de `tuning.gd`'de. Yay: `scripts/fx/spring.gd`, takla kuralları: `scripts/fx/flip_rules.gd` (ikisi de saf, GUT testli).
- İz: `scripts/fx/smooth_trail.gd` — gövde merkezinin yolundan geçen tek `Line2D` şerit (incelen + solan, yuvarlak uçlar, 2 tur Chaikin yumuşatma, `scripts/fx/smoothing.gd`). Hız çizgileri: `speed_lines.gd` (havuzlu `Line2D`, yuvarlak uç, kuyruğa doğru incelir). İkisi de `Visual`'ın ilk çocukları (gövdenin arkasında çizilir), `top_level` (dünyada kalır). Modelden bağımsız: Aşama 3'te değişiklik gerekmez.
- Parçacıklar: `scripts/fx/particle_bursts.gd` — `CPUParticles2D` (Compatibility renderer'a uygun), tek seferlik, havuzlu (3'er), `top_level`. Doku kodla üretilen yumuşak daire (`GradientTexture2D` radyal), dış dosya yok. `land_dust(ayak, güç)`, `wall_sparks(temas, normal_x, güç)` başka efektlerde de kullanılabilir.
- Kullanıcı geri bildirimi (iz): ilk sürümdeki kutu kopyaları "çok yoğun, köşeli" bulundu. İstenen: silik, hafif, kıvrımlı/yumuşak, köşesiz. Efektlerde bu üslup tercih edilmeli.
- Takla `Visual` tarafında; `player.gd` `FLIP` durumuna geçmiyor (fizik taklayı bilmiyor). Kombo zıplayışı tespiti için `player_visual.gd` `GameState.combo_jumps`'ı okur (sadece okuma).
- Kullanıcı geri bildirimi: hızlı koşup zıplamadaki uzayıp ezilme "zıpladığımı hissettiriyor" — bu his korunmalı. Kısa zıplamalar için yay efekt gücüne göre yumuşuyor (`SQUASH_SPRING_STIFFNESS_SOFT`).

### Ölçümler ve testler
- Zıplama yükseklikleri: duran ~176 px (1,4 kat), tam hızda ~444 px (3,5 kat), kısa basış ~68 px. Coyote time platform kenarında doğrulandı.
- GUT testleri: platform kuralları (7), kamera kuralları (7), kombo (11), skor (5), yay (4), takla (6), yumuşatma (3). Toplam 43.
- İz: |hız| ≥ 650 (tam hızda koşu, büyük zıplama); koşuda ~140 px kuyruk, %22 saydamlık, en keskin kıvrım ~22°. Hız çizgileri: |hız| ≥ 1100 (büyük zıplama kalkışı ~0,3 s, hızlı düşüş), %30 saydamlık, aynı anda en çok ~4; koşuda çıkmaz.
- İniş tozu: 350 px/s üstü inişlerde; normal iniş (500) 5 bulut, sert iniş 12. Duvar kıvılcımı: her sekmede 4–10, duvar yüzeyinden normal yönünde.
- Görüntü fizikten sık güncellenebilir (yüksek Hz monitör): her karede iz/efekt eklerken aynı noktanın tekrar eklenmesine dikkat.
- Takla (ölçüldü): tam hızda zıplama 1 tur, ~0,8 s; havada duvar sekmesi yeni takla başlatır (ters yön); inişte açı 0°.
- Squash & stretch (ölçüldü, 2. ayar): zıplama boyu 1,25–1,50 (120–400 ms), normal iniş (500 px/s) 0,68 (~250 ms), sert iniş 0,50, duvar 1,40. İlk ayar (%15 uzama, ~150 ms) kullanıcıya hiç hissettirmedi: juice efektleri belirgin ve en az ~0,25 s görünür olmalı.
- F4: debug yavaş çekim (x0,25), efektleri incelemek için. Hit-stop maddesinde `Engine.time_scale` ile çakışmasına dikkat.
- Headless simülasyonlar gerçek zamanlı çalışır; uzun süreli davranışları (ör. hız tavanı) saf kural testleriyle doğrula.
