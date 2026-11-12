# İlerleme

**Aktif aşama:** 4 — Dünya görselleri ve ses
**Durum:** Devam ediyor (3/10 madde). Madde 3 için kullanıcının onayı bekleniyor; sıradaki madde 4.

## Aşama 4 — Dünya görselleri ve ses
Maddeler ve kararlar kullanıcıyla 2026-11-12'de netleştirildi.
- [x] 1. Palet kaynağı (`WorldPalette`) + kule içi taş deseni (`assets/shaders/tower_interior.gdshader`)
- [x] 2. Karakter okunurluğu: yeni zeminde outline/rim yeniden ayarı (`Tuning.MODEL_OUTLINE_*`, `MODEL_RIM_*`)
- [x] 3. Yan duvarlar ve zemin (taş sütun görünümü, iç kenar gölgesi; `TOWER_WIDTH`'ten türetilir)
- [ ] 4. Platformlar (yuvarlak köşe, üst vurgu, alt gölge; renk temadan; bölüm platformu altın sarısı kalır)
- [ ] 5. Dış çevre + parallax (gökyüzü gradyanı, 2–3 bulut katmanı, uzak siluetler; kule içi arka duvar da hafif yavaş kayar)
- [ ] 6. Tema sistemi: her 100 katta yumuşak palet geçişi (`ThemeRules` saf + GUT; temaları hızlı görmek için debug tuşu)
- [ ] 7. Işık: sahte ışık hâleleri (pencere/fener), `Light2D` yok
- [ ] 8. Ses efektleri: `AudioManager` autoload, `Master/SFX/Music` bus'ları; zıplama, iniş, duvar sekmesi, kombo artışı/bitişi, bölüm platformu, oyun sonu
- [ ] 9. Müzik: tek döngü, oyun bitince kısılır
- [ ] 10. Kapanış: HUD/yazı renkleri, `CREDITS.md`, ince ayar

### Aşama 4 kararları (2026-11-12)
- **Dokular:** yok; her şey shader/kodla.
- **Ses efektleri:** Claude kodla sentezler (`.wav` üreten script; indirme yok). Kullanıcı kararı.
- **Müzik:** ertelendi ("sonra bakarız"); kullanıcı seçip `assets/audio/music/`'e koyacak. Madde 9'a gelince sor.
- **Yazı tipi:** kullanıcı Claude'a bıraktı. İndirme yasak olduğu için şimdilik Godot varsayılan fontu; asıl karar Aşama 5'te (kullanıcı font dosyası koyarsa kullanılır).
- **Palet ilkesi:** dünya orta parlaklık (%30–50), düşük doygunluk; saf siyah/beyaz ve doygun turuncu dünyada yok (turuncu/altın: karakter, kombo, bölüm platformu).
- **Temalar (öneri, itiraz gelmedi):** Taş kule 0–99 (mavi-mor taş / koyu lacivert-gri duvar / soluk turkuaz platform) · Yosunlu 100–199 (adaçayı-teal / koyu çam / soluk kum) · Alacakaranlık 200–299 (mürdüm / koyu erik / soluk lila) · Buz 300–399 (soluk çelik mavisi / koyu petrol / buz mavisi) · Gece 400+ (lacivert-mor / koyu indigo / soluk mor); sonra döngü.
- **Dış çevre (öneri, itiraz gelmedi):** gökyüzü + bulut + uzak siluetler.
- Kullanıcı geri bildirimi (madde 1, ilk sürüm): doygun mor-mavi ton ve yumuşak (bulanık) derzler "gözü yordu". → Daha gri arduvaz tonu, ince ve net derzler (yumuşaklık 3 → 1 px), daha az blok/kenar kontrastı. Kullanıcı rengi henüz kesinleştirmedi; tüm tasarım bitince yeniden bakılacak (renkler `WorldPalette`, desen `Tuning.INTERIOR_*` — tek satırlık değişiklik). Genel ilke: arka plan sakin, net ve düşük doygunlukta olmalı; bulanık desenlerden kaçın.
- Madde 2: orta tonlu zeminde açık outline + güçlü rim gövdede beyaz "karalama" çizgileri yapıyordu. → Outline koyu lacivert (`0.09, 0.10, 0.18`), rim gücü 0,55 → 0,28. Yakın plan görüntüyle karşılaştırıldı (idle/zıplama): beyaz kafa ve gaga öne çıkıyor, koyu gövde zeminden ayrışıyor. Tema koyu bir zemine geçerse (ör. Gece) outline yeniden değerlendirilmeli; gerekirse outline rengi temaya bağlanır (madde 6).
- Doğrulama script tuzağı: `-s` script'inde `root.add_child(scene)` sonrası düğümler hemen hazır değil; oyuncuyu bulmadan önce bekle (`create_timer`), yoksa script hata verip pencere açık kalır (takılır).
- Madde 3: yan duvarlar `assets/shaders/tower_wall.gdshader` (koyu sütun, her iki katta bir yatay derz, kule içine bakan kenarda 5 px açık pervaz, dışa doğru hafif kararma; desen dünya koordinatında). Zemin: çarpışma levhası aynı (24 px); görüntü üst açık şerit + levha + ekranın altına inen dolu taban (`Tuning.GROUND_VISUAL_DEPTH`). Ayarlar `Tuning.WALL_*`/`GROUND_*`, renkler `WorldPalette`. `Tower._make_body` artık görselsiz; görseller ayrı eklenir.
- Madde 1 uygulama notu: arka duvar dikdörtgeni kamerayı takip eder ama desen shader'da dünya koordinatından (`MODEL_MATRIX * VERTEX`) hesaplanır → taşlar yerinde durur. Blok 128x64 (kat başına iki sıra), ayarlar `Tuning.INTERIOR_*`, renkler `WorldPalette`. Madde 5'te parallax için shader'a kaydırma çarpanı eklenecek; madde 6'da `WorldPalette` temalı hâle gelecek.

## ▶ Yeni oturumda buradan devam
1. CLAUDE.md bölüm 0'daki ortam kontrolünü yap ve tabloyla raporla.
2. Aşama 4 sürüyor: yukarıdaki listede işaretsiz ilk maddeden devam et (tek seferde tek madde, her madde sonunda test talimatı + ekran görüntüsü iste).
3. Aşama 4 başlangıç notları (eski):
   - **Kontrast (karar verildi, kullanıcı onayladı):** kule içi orta tonda olacak (siyah/beyazdan uzak, soğuk mavi-mor taş gibi); karakter siyah-beyaz-turuncu. Zemin değişince karakterin açık renkli outline/rim ayarını yeniden değerlendir (`Tuning.MODEL_OUTLINE_*`, `MODEL_RIM_*`).
   - Dünya kodla/shader ile üretilecek (GAME_DESIGN "Görsel yön"); parallax, her 100 katta tema, duvar dışı dekor alanı `TOWER_WIDTH`'ten türetilir.
   - Ses: internetten asset indirme yok; kaynakları kullanıcı seçer/indirir.
   - Blender/Tripo gerekirse: Blender 5.3 + blender-mcp hazır (`get_addon_status` ile doğrula). Tripo API'de kredi yok; üretim Tripo web sitesinde, ücretsiz planda **H2.5** sürümüyle kullanıcı tarafından yapılır.
4. Web doğrulaması ertelendi: export şablonları kurulu değil (`%APPDATA%\Godot\export_templates` boş) — Aşama 7'nin ön koşulu. Aşama 7'de özellikle kontrol et: SubViewport + şeffaf arka plan + MSAA + `next_pass` outline WebGL2'de çalışıyor mu. Masaüstünde `gl_compatibility` ile doğrulandı.

### Çalışma yöntemi notları (Aşama 3'te işe yarayanlar)
- Kullanıcı Aşama 3'ü 2026-11-12'de bitirip oturumu kapattı; Aşama 4'e **yeni oturumda** başlanacak. Aşama 4'e henüz "devam" denmedi sayılmaz: kullanıcı yeni oturumu Aşama 4 için açıyor, ama yine de önce maddeleri netleştir ve onay al.
- Akış: her maddede kısa plan → uygula → doğrula → commit → `PROGRESS.md` → kullanıcıya test talimatı + ekran görüntüsü iste. Kullanıcı kısa cevap verir ("devam", "uygun"); görsel kararları çoğu zaman Claude'a bırakır ama sonucu oyunda görüp yorumlar.
- Kullanıcı karar gerekçelerini merak eder (ör. "hitbox neden büyümedi?"): sessizce karar verme, kısa gerekçeyle bildir.
- Görsel doğrulama: geçici bir `-s` script'i (scratchpad'de; repoya koyma) ana sahneyi pencereli açar, `Input.action_press` ile oynatır, `root.get_texture().get_image()` ile karakterin çevresini kırpıp PNG kaydeder; Claude görüntüyü okur. Script içinde `Tuning`/autoload kullanan sınıflara doğrudan başvurma (düğüm üzerinden eriş). Headless'ta render yok.
- Araç tuzakları: Bash'te `python` var (`py` yok, PIL yok); `godot` sadece PowerShell'de. Çok satırlı dosya düzenlemelerini Bash heredoc yerine Write aracıyla yazılan küçük Python script'leriyle yap (tırnak hataları). Dosyalar LF ile yazılır; git CRLF uyarıları zararsız.
- Blender: çalışma dosyası açık değilse kullanıcıdan `assets/models/source/eagle_hero.blend`'i açmasını iste. Model/animasyon değişince: `eagle_anims.py`'yi çalıştır → pozu sıfırla → kaydet → glb'yi aynı ayarlarla dışa aktar → `godot --headless --path . --import`.

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

### Aşama 3 model notları
- Konsept: `docs/concept/hero_chibi_v1.jpg` (kullanıcı ChatGPT ile üretti).
- Tripo API anahtarında kredi yok (`generate_3d` → "not enough credit"). Model **Tripo web sitesinde, ücretsiz planda, H2.5 sürümüyle** kullanıcı tarafından üretildi (ücretsiz planda sadece H2.5 dışa aktarılabiliyor). Yeniden üretim gerekirse aynı yol.
- Ham dosya `assets/models/source/eagle_hero_raw.glb` (14,8 MB, 450k üçgen) **git'te değil** (`.gitignore`, kullanıcı kararı). `assets/models/source/` ve `docs/` altında `.gdignore` var (Godot içe aktarmaz).
- `eagle_hero.blend`: `EagleHero` — 8.000 üçgen, tek parça, boy 1,0 m, ayaklar z=0'da, orijin ayakta, **yüzü -Y'ye bakıyor** (glTF'te +Z). Yeni UV (smart project) + ham modelden 1024 px renk bake'i: `eagle_hero_albedo.png`. Sadece renk dokusu var (normal/pürüz yok; toon shader kullanılacak).
- Gözler: ham modelde düz siyahtı (parıltı yansımadan geliyordu, bake'te kayboldu); kullanıcı "normal göz" istedi → göz yüzleri atlasın sağ şeridinde ayrı 112 px UV adalarına alındı (atlasın geri kalanı 0,875'e küçültüldü) ve kodla boyandı: beyaz göz akı, kehribar iris, siyah göz bebeği, parıltı. Göz merkezi (±0.072, -0.077, 0.823), yarıçap ~0.046.
- İskelet `EagleRig` (17 kemik): `root` (deform değil) → `hips` → `spine` → `chest` → `head`; `chest` → `upper_arm.L/R` → `forearm.L/R` (el dahil); `hips` → `thigh.L/R` → `shin.L/R` → `foot.L/R`; `hips` → `tail` → `tail_tip`. `.L` = +X. Pose kemikleri `XYZ` euler. Ağırlıklar: otomatik (bone heat) + bölgesel temizlik (z>0,665 tamamen `head`; kol/bacak/kuyruk sızıntıları silindi). Koşu adımı ve topak pozunda test edildi, bozulma yok.
- Animasyonlar kodla üretilir: `tools/blender/eagle_anims.py` (Blender'da `exec` ile çalıştır; action'ları silip yeniden kurar, her birini NLA şeridine koyar). 30 fps. `idle` 2,0 s döngü · `run` 0,53 s döngü · `jump` 0,27 s tek sefer (son poz tutulur) · `fall` 0,67 s döngü · `land` 0,33 s tek sefer · `tuck` sabit poz · `flap` 0,53 s (iki kanat çırpışı, zıplama pozunda biter). Açı kuralları script başında. Poz değiştirmek = script'teki sayıları değiştirip yeniden çalıştırmak + yeniden dışa aktarmak.
- Dışa aktarım: `assets/models/eagle_hero.glb` (1,3 MB; mesh + iskelet + 7 animasyon + gömülü doku). Ayarlar: seçili `EagleHero`+`EagleRig`, `export_animation_mode='NLA_TRACKS'`, `export_force_sampling=True`, Y-up. Godot içe aktarımı hatasız. Döngü bayrakları glb'de yok → Godot tarafında kodla ayarlanacak (idle, run, fall).
- Bilinen zayıflık: yandan bakışta `flap` ve `fall` kol hareketi az okunuyor (kollar kameraya doğru açılıyor). Oyun içinde, gerçek kamera ve boyutta ayarlanacak (madde 7–8).
- Godot tarafı: `scripts/player/character_model.gd` (`CharacterModel`, Node2D, orijin ayaklarda). İçinde `SubViewport` (şeffaf, `own_world_3d`, MSAA 4x, 346 px) + `Pivot` (model) + ortografik `Camera3D` (-X tarafında, +X'e bakar; model +Z'ye baktığı için ekranda sağa bakar) + geçici düz ışık; görüntü `Sprite2D` ile `Squash`'a konur. API: `set_facing(±1)`, `play(anim, blend, speed)`, `set_speed`, `has_animation`, `current_animation`, `is_available()`. Dönüş `Pivot.rotation.y` ile, kameranın önünden geçerek; model tam profilden 25° kameraya dönük. Ayarlar `Tuning.MODEL_*`; `USE_CHARACTER_MODEL=false` ya da glb yoksa kutu gövde.
- `eagle_hero.glb.import`: `animation/remove_immutable_tracks=false` (sabit pozlu izler silinmesin; animasyon değişince kemik eski pozda kalmasın). Yeniden dışa aktarımda bu ayar korunur (.import dosyası repoda).
- Doğrulama yöntemi (Claude için): geçici `-s` script'i ana sahneyi açıp `root.get_texture().get_image().save_png()` ile görüntü alır (pencereli çalıştırma gerekir, headless'ta render yok). Kullanıcı ekran görüntüsü yine istenir.
- Kullanıcı geri bildirimi (2026-11-12, ilk oyun içi görüntü): genel boy büyüsün, kafa gövdeye göre daha büyük olsun; duvara girmiyor, juice iyi. → Kafa Blender'da boyun pivotu (z=0,67) etrafında ×1,22 büyütüldü (kafa ağırlığıyla harmanlı; model boyu 1,074 birim), `Tuning.MODEL_HEIGHT` 72 → 88 (ekranda ~94 px).
- Toon görünüm: `assets/shaders/toon_character.gdshader` (unshaded; kamera uzayında sabit ışık yönü, iki ton, kenar ışığı, koyu renkleri hafif açma, beyazları parlatma) + `toon_outline.gdshader` (ters kabuk, `next_pass`). `CharacterModel._apply_toon_materials` her yüzeye uygular, dokuyu modelin kendi malzemesinden alır. Outline **açık renk** (siyah değil): koyu gövde koyu zeminde okunuyor ("çıkartma" görünümü). Ayarlar `Tuning.MODEL_OUTLINE_*`, `MODEL_RIM_*`, `MODEL_SHADOW_TINT`; ince ayarlar shader uniform varsayılanlarında. Sahne ışığı yok (unshaded).
- Duvar taşması (kullanıcı bildirdi, büyütmeden sonra): hitbox 32 px genişlikte kalıyor, model ~54 px. Çözüm fizik değil görüntü: `scripts/fx/wall_clearance.gd` (`WallClearance.offset_x`, saf, 5 GUT testi) → `PlayerVisual._update_wall_clearance` `Spin.position.x`'i duvara yaklaştıkça içeri kaydırır (en çok 11 px). `Tuning.MODEL_WALL_HALF_WIDTH = 27`. Hitbox neden büyütülmedi: geniş hitbox platform kenarında "havada durma" görüntüsü verir ve zıplama/duvar ayarlarını değiştirir. Takla sırasında (model yatayken) kısa süreli taşma olabilir; kabul edildi. GUT toplam 67.
- Animasyon bağlama: kurallar `scripts/player/animation_rules.gd` (`AnimationRules.pick/run_speed_scale/blend_time`, saf, 8 GUT testi), zamanlayıcılar `scripts/player/model_animator.gd` (`ModelAnimator`, RefCounted; `on_jumped(güç)`, `on_landed(hız)`, `update(...)`). `PlayerVisual` her karede `update` çağırır; `player.gd`'ye dokunulmadı (`is_on_floor`, `velocity` okunur; `state_changed` kullanılmadı çünkü `LAND/FLIP` durumlarına geçilmiyor). Kurallar: havada takla varsa `tuck`; aşağı hız > 60 ise `fall`; yükselirken güçlü zıplamada (güç ≥ 0,35, takla yoksa) `flap`, değilse `jump`; yerde iniş süresi dolmadıysa ve yatay hız < 250 ise `land`; hız > 20 ise `run` (oynatma hızı 0,7–2,0), değilse `idle`. `CharacterModel.play` aynı isteği tekrar başlatmaz. Takla ekseni modelde `Tuning.MODEL_SPIN_PIVOT_HEIGHT` (42 px, topak pozunun ortası). Oyun içi görüntüyle doğrulandı: jump, fall, land, run, tuck. GUT toplam 75.
- Kullanıcı geri bildirimi (madde 7 sonrası): "animasyonlara bayıldım, her şey harika". İstek: ikinci bir takla çeşidi → **yıldız takla** eklendi: `star` pozu (kollar/bacaklar yana açık, `eagle_anims.py` `STAR_POSE`), oynarken model tam kameraya döner (`CharacterModel.set_front_view`), `Spin` dönüşüyle ekranda çark gibi görünür. Seçim: `AnimationRules.flip_animation(randf(), from_wall)` — zıplama taklalarında %50 yıldız / %50 topak (`Tuning.MODEL_STAR_FLIP_CHANCE`), duvar sekmesi taklaları hep topak (yıldız geniş, duvara taşar). GUT toplam 78.
- Genişletilebilirlik (kullanıcı sordu; ileride roket vb. güçlendirmeler için): yeni animasyon = `eagle_anims.py`'ye poz/fonksiyon + `build()`'e satır → script'i çalıştır → glb'yi yeniden dışa aktar → `AnimationRules`'a sabit ve kural. Aksesuar (roket, şapka) = `Skeleton3D` altına `BoneAttachment3D` ile kemiğe bağlanan ayrı model. Güçlendirme durumu `pick`'e yeni bir parametre olarak girer.
- Aşama 4 notu: zemin orta tona geçince açık outline/rim yeniden değerlendirilmeli.
- Doku düzeltmesi: tişört düz kurşuni griye çekildi (ham dokuda tişört/pantolon neredeyse aynı koyuluktaydı). Gövde yandan %22 kalınlaştırıldı. Tripo'nun eklediği beyaz kuyruk kaldı (ikincil hareket için; kullanıcı kararı Claude'a bıraktı).

## Aşama 3 — Karakter
- [x] Chibi konsept görseli + Tripo ile görselden 3D üretim → Blender'da inceleme
- [x] Temizlik: sadeleştirme (8k üçgen), ölçek, orijin ayakta, yön, malzeme/doku
- [x] İskelet + skinning
- [x] Animasyonlar: idle, run, jump, fall, land, takla topak pozu, kanat çırpma
- [x] Godot: SubViewport render katmanı, `Squash`'a takma, yön dönüşü, kutu yedek
- [x] Toon shader + outline
- [x] Durumlara animasyon bağlama (`state_changed`/`event`; koşu animasyonu hızı koşu hızına göre; `player.gd`'ye dokunulmaz)
- [x] İnce ayar, Compatibility/web doğrulama, `CREDITS.md` (web kısmı Aşama 7'ye ertelendi: export şablonları yok)

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
- Aşama 3 — Karakter (2026-11-12)

## Aşama 6 için fikirler (kullanıcı, 2026-11-12 — temel bitince; kapsam o aşamada netleşecek)
- **Para toplama.**
- **Kanat:** alınınca karakter kanatlanır ve otomatik olarak (belli bir süre/mesafe) uçar.
- **Kum saati:** alınınca zaman yavaşlar (`Engine.time_scale` → `HitStop` ve F4 yavaş çekimle uyumlu olmalı).
- Benzeri güçlendirmeler (ör. roket). Uygulama notu: oynanış etkisi çalışma zamanı çarpanlarıyla (`Tuning` sabit kalır), görsel taraf yeni animasyon + kemiğe takılan aksesuar (bkz. "Genişletilebilirlik" notu).

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
