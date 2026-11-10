# İlerleme

**Aktif aşama:** 1 — Fizik prototipi
**Durum:** Devam ediyor (6/11 madde)

## Aşama 1 — Fizik prototipi
- [x] Godot projesi + klasör yapısı + `.gitignore` + autoload'lar (`Events`, `GameState`)
- [x] `tuning.gd` (GAME_DESIGN.md'deki değerlerle)
- [x] Kule duvarları + kutu karakter: koşma (ivme/sürtünme)
- [x] Zıplama: momentuma bağlı yükseklik, değişken zıplama, coyote time, jump buffer
- [x] Duvar sekmesi
- [x] Tek yönlü platformlar + sonsuz platform üretimi (eskileri temizleme)
- [ ] Kamera: bekleme, hızlanan kayma, yakalama bölgesi
- [ ] Game over + yeniden başlatma
- [ ] Skor + kombo sistemi (+ GUT testleri)
- [ ] Basit HUD (kat, skor, kombo)
- [ ] Debug overlay (F3)

## Tamamlanan aşamalar
(yok)

## Notlar
- Kullanıcının kurulu araçları: Godot 4 Standard, Git, Node.js, godot-mcp. `gh` yok.
- Godot sürümü 4.7.2. Renderer: `gl_compatibility` (web build uyumu için).
- Giriş eylemleri `project.godot`'ta: `move_left`, `move_right`, `jump`, `pause`, `toggle_debug`.
- Pencere: oyun büyütülmüş pencerede başlar, F11 / Alt+Enter tam ekran (`WindowManager` autoload'u). Tasarım çözünürlüğü 1280x720 olarak kalır, görüntü ölçeklenir.
- Zıplama yükseklikleri (ölçüldü): duran ~176 px (1,4 kat), tam hızda ~444 px (3,5 kat), kısa basış ~68 px. Coyote time zeminde kenar olmadığı için henüz sınanamadı; platformlar gelince sınanacak.
- `Player.event` olayları: `jumped`, `jump_cut`, `landed`, `wall_bounce`.
- Kullanıcı kararı: ayarlar `const` kalacak, oyun içi canlı ayar paneli şimdilik yok. Güçlendirmeler ileride çalışma zamanı çarpanlarıyla eklenecek (bkz. GAME_DESIGN.md).
- Doğrulama yöntemi: headless'ta simüle girişle sayısal kontrol + kullanıcının elle testi. Otomatik ekran görüntüsü şimdilik istenmiyor.
- Platform kuralları saf sınıfta (`scripts/world/platform_rules.gd`); GUT testleri `tests/test_platform_rules.gd` (7 test).
- GUT 9.7.1 kurulu (`addons/gut/`, editörde eklenti etkin). AssetLib'deki 9.6.1 Godot 4.7 ile editörde çalışmadı; kullanıcı 9.7.1'i GitHub'dan indirdi.
- `main.gd`'de GEÇİCİ kamera takibi var (oyuncuyu sadece yukarı doğru izler); kamera maddesinde gerçek davranışla değiştirilecek.
- Dünya koordinatları: x=0 kule ortası, y=0 zeminin üstü, yukarı = -y. Oyuncunun orijini ayaklarında.
- Duvarlar kamerayı dikeyde takip eder (`tower.gd`); kamera şimdilik sabit, kayma kamera maddesinde.
