# İlerleme

**Aktif aşama:** 1 — Fizik prototipi
**Durum:** Devam ediyor (4/11 madde)

## Aşama 1 — Fizik prototipi
- [x] Godot projesi + klasör yapısı + `.gitignore` + autoload'lar (`Events`, `GameState`)
- [x] `tuning.gd` (GAME_DESIGN.md'deki değerlerle)
- [x] Kule duvarları + kutu karakter: koşma (ivme/sürtünme)
- [x] Zıplama: momentuma bağlı yükseklik, değişken zıplama, coyote time, jump buffer
- [ ] Duvar sekmesi
- [ ] Tek yönlü platformlar + sonsuz platform üretimi (eskileri temizleme)
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
- `Player.event` olayları: `jumped`, `jump_cut`, `landed`.
- Dünya koordinatları: x=0 kule ortası, y=0 zeminin üstü, yukarı = -y. Oyuncunun orijini ayaklarında.
- Duvarlar kamerayı dikeyde takip eder (`tower.gd`); kamera şimdilik sabit, kayma kamera maddesinde.
