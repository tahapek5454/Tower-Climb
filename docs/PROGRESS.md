# İlerleme

**Aktif aşama:** 3 — Karakter
**Durum:** Başladı (0/8 madde) — chibi konsept görseli geldi (`docs/concept/hero_chibi_v1.jpg`); Tripo üretimi için kullanıcı onayı bekleniyor.

## ▶ Yeni oturumda buradan devam
1. CLAUDE.md bölüm 0'daki ortam kontrolünü yap ve tabloyla raporla. Aşama 3 araçları 2026-11-11'de hazırdı: Blender 5.3.0 (PATH'te), uv/uvx 0.13.7, blender-mcp bağlı (eklenti 1.8, `tripo: on`). Yine de `get_addon_status` ile Blender bağlantısını doğrula.
2. Aşama 2 ışık hâleleri ekran görüntüsüyle görüldü (2026-11-11): hâle, iz ve duvar efektleri kullanıcıya göre iyi; düzeltme istenmedi.
3. Sıradaki iş: Madde 1. Konsept `docs/concept/hero_chibi_v1.jpg` (ChatGPT ile kullanıcı üretti). Tripo görselden 3D üretimini **kullanıcı onayıyla** başlat (her üretim kredi harcar), modeli Blender'da farklı açılardan göster.
4. Kontrast kaygısı (kullanıcı sordu): karakter siyah/koyu gri, mevcut arka plan çok koyu lacivert → karakter kaybolur. Önerilen çözüm (kullanıcı onayı bekliyor): kule içi orta ton (soğuk mavi-mor taş), toon shader'da açık renkli kenar ışığı (rim) + siyah yerine açık/renkli outline, mevcut hâle karakterin arkasında kalır, gerekirse giysi tonu Blender'da açılır. Madde 5–6'da model geçici bir orta ton test zemininde denenecek.

## Aşama 3 kararları (2026-11-11)
- Karakter: **kartal maskotu**, **chibi oranlar** (büyük kafa, kısa bacak, kalın uzuvlar), yumuşak/yuvarlak tüy tutamları. Beyaz kafa, turuncu gaga ve ayaklar, **düz koyu gri–siyah arası tişört** (çizgisiz, logo/yazı/reklam yok), koyu pantolon. İfade: kararlı ama sevimli.
- İlk konsept (`C:\Users\pekta\Downloads\tower-climb-hero.png`, ChatGPT ile kullanıcı üretti) referans: kartal + forma. Çizgili forma ve gerçekçi oranlar **kullanılmayacak**.
- **3D** (Tripo görselden üretim). 2D çizim yok.
- Görüntü kutudan **biraz büyük** olacak (hareketler belirgin olsun). Hitbox 32x48 **değişmez**; görsel boy oyunda denenerek ayarlanır (başlangıç hedefi ~72 px). Duvara taşmayı kontrol et.
- Rig + animasyon: Blender'da (Claude, blender-mcp ile). Animasyonlar: idle, run, jump, fall, land; ek olarak taklada topak pozu, büyük zıplamada kanat (kol) çırpma.
- 2D'ye yerleştirme: canlı 3D, `SubViewport` (şeffaf arka plan, ortografik yan kamera) → dokusu `Visual/Spin/Squash` içine. Sağa/sola dönüşte model 180° döner. Kutu gövde yedek olarak kalır.
- Toon shader + outline: `assets/shaders/`. Siyah parçalar outline ile birleşmesin diye kontrast Aşama 4'te çevre renkleriyle sağlanacak (çevre siyah/beyazdan uzak, orta tonlar).
- Sıra: önce karakter (Aşama 3), çevre karakter paletine göre (Aşama 4).
- Kaynak `.blend` dosyaları `assets/models/source/` (+ `.gdignore`), oyunda sadece `.glb`.
- `tools/blender/addon.py` (blender-mcp eklentisi) repoda kalacak; kullanıcı kararı.

## Aşama 3 — Karakter
- [ ] Chibi konsept görseli + Tripo ile görselden 3D üretim → Blender'da inceleme
- [ ] Temizlik: sadeleştirme (~3–5k üçgen), ölçek, orijin ayakta, yön, malzeme/doku
- [ ] İskelet + skinning
- [ ] Animasyonlar: idle, run, jump, fall, land, takla topak pozu, kanat çırpma
- [ ] Godot: SubViewport render katmanı, `Squash`'a takma, yön dönüşü, kutu yedek
- [ ] Toon shader + outline
- [ ] Durumlara animasyon bağlama (`state_changed`/`event`; koşu animasyonu hızı koşu hızına göre; `player.gd`'ye dokunulmaz)
- [ ] İnce ayar, Compatibility/web doğrulama, `CREDITS.md`

### Kullanıcı tercihleri (özet)
- Türkçe konuş. Tek seferde tek madde; her madde sonunda test talimatı ver, aşama geçişinde mutlaka "devam" bekle.
- Görsel üslup: **yumuşak, silik, kıvrımlı, köşesiz; yazılar minimal**. Efektler ilk denemede belirgin olmalı (çok küçük/kısa efekt hissedilmiyor) ama kalabalık/keskin olmamalı.
- Hızlı koşup zıplamadaki squash & stretch hissini çok beğendi — korunmalı.
- Kullanıcı ekran görüntüsü paylaşıyor; görsel değişikliklerde iste, göremediğini "güzel oldu" diye raporlama.

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
- [x] Ekran sarsıntısı (büyük iniş, duvar sekmesi, kombo bitişi)
- [x] Hit-stop (kombo bitişinde ~60 ms yavaşlama)
- [x] Kombo yazıları ("COMBO x7!") + skor sayacı tween
- [x] Glow ("sahte glow": toplamalı ışık hâleleri) + renk vurguları

## Tamamlanan aşamalar
- Aşama 1 — Fizik prototipi (2026-11-10)
- Aşama 2 — Juice / animasyon (2026-11-11)

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
- `Player.event` olayları: `jumped {speed, run_speed}`, `jump_cut`, `landed {speed, floor}`, `wall_bounce {speed, normal_x, airborne}`. `state_changed` yayınlanıyor ama sadece `IDLE/RUN/JUMP/FALL` kullanılıyor; `LAND`, `WALL_BOUNCE`, `FLIP` durumlarına geçilmiyor (takla ve iniş efektleri olaylarla `Visual` tarafında). Aşama 3'te animasyon için gerekirse eklenebilir.
- Duvarlar kamerayı dikeyde takip eder (`tower.gd`).
- Platformlar: kurallar `scripts/world/platform_rules.gd` (saf), üretim `platform_spawner.gd`.
- Kamera: `TowerCamera` (`scripts/world/tower_camera.gd`), kuralları `CameraRules`.
- Skor/kombo: kurallar `scripts/game/combo_counter.gd` (saf), durum `GameState`. `main.gd` iniş olayını `GameState.register_landing(floor)`'a iletir.
- Oyun sonu: oyuncu ekranın altından tamamen çıkınca `GameState.end_game()`. Geçici yazı `scripts/ui/game_over_label.gd` (Aşama 5'te gerçek ekranla değişecek). Yeniden başlatma: R veya Space (0,5 s gecikmeyle) → `GameState.reset()` + sahneyi yeniden yükleme.
- UI: `scripts/ui/hud.gd` (sol üst), `scripts/ui/debug_overlay.gd` (sağ üst, F3).
- Görsel katman: `Visual` (ayaklar) → `Spin` (gövde ortası, döner: takla) → `Squash` (gövde altı, ölçeklenir: dikken ayaklar yerde, takla sırasında gövde kendi boyu yönünde uzar) → gövde + göz. Aşama 3'te model `Squash`'ın içine takılacak. Juice ayar değerleri de `tuning.gd`'de. Yay: `scripts/fx/spring.gd`, takla kuralları: `scripts/fx/flip_rules.gd` (ikisi de saf, GUT testli).
- İz: `scripts/fx/smooth_trail.gd` — gövde merkezinin yolundan geçen tek `Line2D` şerit (incelen + solan, yuvarlak uçlar, 2 tur Chaikin yumuşatma, `scripts/fx/smoothing.gd`). Hız çizgileri: `speed_lines.gd` (havuzlu `Line2D`, yuvarlak uç, kuyruğa doğru incelir). İkisi de `Visual`'ın ilk çocukları (gövdenin arkasında çizilir), `top_level` (dünyada kalır). Modelden bağımsız: Aşama 3'te değişiklik gerekmez.
- Parçacıklar: `scripts/fx/particle_bursts.gd` — `CPUParticles2D` (Compatibility renderer'a uygun), tek seferlik, havuzlu (3'er), `top_level`. Doku kodla üretilen yumuşak daire (`GradientTexture2D` radyal), dış dosya yok. `land_dust(ayak, güç)`, `wall_sparks(temas, normal_x, güç)` başka efektlerde de kullanılabilir.
- Ekran sarsıntısı: `scripts/fx/camera_shake.gd` (trauma² + yumuşak gürültü, saf, GUT testli), `TowerCamera.offset`'e uygulanır. Oyun mantığı `offset`'siz konumu kullanır (`is_below_screen` → `global_position`). İstek: `Events.screen_shake.emit(trauma)`; kamera kombo bitişini kendisi dinler.
- Hit-stop: `scripts/fx/hit_stop.gd` (`main.gd`'de düğüm). `Engine.time_scale`'i önceki değerin %5'ine indirir, gerçek zamanlı zamanlayıcıyla geri döndürür (F4 yavaş çekime saygılı); `_exit_tree`'de geri alır. `Engine.time_scale`'e dokunan başka kod eklenirse bununla uyumlu olmalı.
- Kombo yazıları: `scripts/ui/combo_popups.gd` (CanvasLayer, oyuncunun ekran konumunun üstünde), kurallar `scripts/ui/popup_rules.gd` (saf, GUT testli). HUD skoru `PopupRules.count_toward` ile sayar, bonusla büyür.
- Kullanıcı geri bildirimi (yazılar): ilk sürüm (34–72 punto, "COMBO x3!", "+144 / 12 KAT") "çok büyük" bulundu → minimal yapıldı ("COMBO x3" 18–26, "+144" 22–30, az fırlama/sallanma). Asset aşamasında (4–5) daha şık, modern bir görünümle yeniden ele alınacak. Genel ilke: oyun içi yazılar minimal ve göze batmayan olmalı.
- Godot tuzağı: Container'lar çocuklarının `scale`/`rotation`'ını her yerleşimde sıfırlar. Container içinde ölçek/dönme animasyonu için öğeyi düz bir `Control` ara katmanına koy (bkz. `hud.gd` `_score_holder`).
- Glow: WorldEnvironment glow yerine "sahte glow". Sebep: Compatibility renderer'da HDR 2D yok; Canvas arka plan modunda glow'un çalıştığı belgelerde doğrulanmıyor ve nesne seçmiyor. Bunun yerine toplamalı (`BLEND_MODE_ADD`) yumuşak hâleler: `scripts/fx/player_aura.gd` (dururken/hızlı/kombo parlaklığı, kombo rengi), iz/hız çizgisi/kıvılcım toplamalı; bölüm platformu hâlesi ve platform üst vurgu şeridi `platform.gd`'de. Ortak doku/malzeme: `scripts/fx/soft_textures.gd`.
- Kullanıcı geri bildirimi (iz): ilk sürümdeki kutu kopyaları "çok yoğun, köşeli" bulundu. İstenen: silik, hafif, kıvrımlı/yumuşak, köşesiz. Efektlerde bu üslup tercih edilmeli.
- Takla `Visual` tarafında; `player.gd` `FLIP` durumuna geçmiyor (fizik taklayı bilmiyor). Kombo zıplayışı tespiti için `player_visual.gd` `GameState.combo_jumps`'ı okur (sadece okuma).
- Kullanıcı geri bildirimi: hızlı koşup zıplamadaki uzayıp ezilme "zıpladığımı hissettiriyor" — bu his korunmalı. Kısa zıplamalar için yay efekt gücüne göre yumuşuyor (`SQUASH_SPRING_STIFFNESS_SOFT`).

### Ölçümler ve testler
- Zıplama yükseklikleri: duran ~176 px (1,4 kat), tam hızda ~444 px (3,5 kat), kısa basış ~68 px. Coyote time platform kenarında doğrulandı.
- GUT testleri: platform kuralları (7), kamera kuralları (7), kombo (11), skor (5), yay (4), takla (6), yumuşatma (3), sarsıntı (8), hit-stop (3), yazılar (5), hâle (3). Toplam 62.
- İz: |hız| ≥ 650 (tam hızda koşu, büyük zıplama); koşuda ~140 px kuyruk, %22 saydamlık, en keskin kıvrım ~22°. Hız çizgileri: |hız| ≥ 1100 (büyük zıplama kalkışı ~0,3 s, hızlı düşüş), %30 saydamlık, aynı anda en çok ~4; koşuda çıkmaz.
- İniş tozu: 350 px/s üstü inişlerde; normal iniş (500) 5 bulut, sert iniş 12. Duvar kıvılcımı: her sekmede 4–10, duvar yüzeyinden normal yönünde.
- Sarsıntı (ölçüldü): normal zıplama/iniş 0; büyük iniş (≥1000 px/s) ~8 px; 12 katlık kombo bitişi ~8 px; tam hızla duvar ~3 px; ~0,8 s'de yatışır. En fazla 24 px.
- Hit-stop (ölçüldü): 4 katlık kombo ~70 ms, 30 katlık ~145 ms, hız %5.
- Test tuzağı: `-s` ile çalışan geçici script'ler, autoload adı (`Events`, `GameState`) kullanan sınıflara (ör. `HitStop`) doğrudan başvurursa derlenmez ve takılır; bu sınıfların değerlerini script içinde hesapla veya düğüm üzerinden eriş.
- Test tuzağı: simülasyonda oyuncuyu yukarı ışınlayıp sonra aşağı taşımak oyunu bitirir (kamera aşağı inmez) → oyuncu donar. Her ölçümü temiz sahnede ya da ekranda kalan konumlarda yap.
- Görüntü fizikten sık güncellenebilir (yüksek Hz monitör): her karede iz/efekt eklerken aynı noktanın tekrar eklenmesine dikkat.
- Takla (ölçüldü): tam hızda zıplama 1 tur, ~0,8 s; havada duvar sekmesi yeni takla başlatır (ters yön); inişte açı 0°.
- Squash & stretch (ölçüldü, 2. ayar): zıplama boyu 1,25–1,50 (120–400 ms), normal iniş (500 px/s) 0,68 (~250 ms), sert iniş 0,50, duvar 1,40. İlk ayar (%15 uzama, ~150 ms) kullanıcıya hiç hissettirmedi: juice efektleri belirgin ve en az ~0,25 s görünür olmalı.
- F4: debug yavaş çekim (x0,25), efektleri incelemek için. Hit-stop maddesinde `Engine.time_scale` ile çakışmasına dikkat.
- Headless simülasyonlar gerçek zamanlı çalışır; uzun süreli davranışları (ör. hız tavanı) saf kural testleriyle doğrula.
