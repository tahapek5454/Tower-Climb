# Gelecek işler (v1.0.0 sonrası)

İlk sürüm (v1.0.0, 2026-11-14) için kapsam kapandı. Aşağıdakiler ileride yapılabilecekler; hiçbiri sözleşilmiş değil.
Bir madde seçilince kullanıcıyla kapsamı netleştir (CLAUDE.md'deki çalışma tarzı geçerli).

## Denge ve küçük düzeltmeler (oynadıkça)
- **Elmas ekonomisi:** mıknatıs kısalıp seyrekleşince gelir ~%30 düştü; her şeyi açmak ≈ 4.900 elmas ("zor" seçildi). Gerekirse `ShopCatalog` fiyatları ya da `MAGNET_DIAMOND_CHANCE` / `DIAMOND_SPAWN_CHANCE`.
- **Kum saati** tabanı 3,5 s (1,2 s'si yumuşak geçiş) kısa gelebilir → `HOURGLASS_DURATION` 4 s.
- **Şapkalar:** hasır ve kovboy şapkasının geniş kenarı duvara dayanınca birkaç piksel taşabilir (`MODEL_WALL_HALF_WIDTH`); roketle uçarken kollar kovboy şapkasının önünden geçiyor; sallanma hafif (`HAT_SWAY_RESPONSE`). Diğer şapkalar Noel Baba'daki gibi arkadan da kontrol edilmeli (kafaya oturma, iki renkli parçalarda iç içe geçen yüzey).
- **Gökkuşağı izi** açık zeminde silik kalabilir (bu stil için `TRAIL_ALPHA` / genişlik artırılabilir).
- **Mağaza:** dönüşte odak "Oyna"ya gidiyor ("Mağaza"da kalabilir); takviye/yükseltme sekmesinde önizlemeye büyük simge konabilir.
- **Devam et kartı:** 0,45 s giriş kilidi ve kart beklerken müziğin boğuklaşması kullanıcıya soruldu, yanıt bekliyor.
- **"Geniş yürek 3"** ile HUD kartı ~38 px genişliyor (kalp simgeleri küçültülebilir).
- **Platformlar:** kayan platformdan zıplarken platform hızı oyuncuya ekleniyor (Godot varsayılanı); buz temasında buz platformunun farkı ince; dar buz platformu zor olabilir (`PLATFORM_ICE_FRICTION_FACTOR`).
- `Events.speed_increased` (bölüm geçince hızlanma) için ses/efekt bağlanabilir; şu an dinleyen yok.
- Yeni seslerin (mağaza, devam et) kulakla son kontrolü.

## İçerik
- **Yeni kozmetikler:** kemiğe takılan aksesuarlar (gözlük, atkı, pelerin — `head` / `chest` kemiği, `HatModel` deseni), mevsimlik ürünler (yılbaşı dışında), tam kostüm ya da yeni karakter (Tripo web sitesi, H2.5 + Blender hattı).
- **Bağımsız dünya objeleri:** Aşama 4'ten kalan onaylı fikir (6c-2, "basitten karmaşığa"); toplanabilir altyapısıyla birleşebilir.
- **Yeni güçlendirmeler / platform türleri:** `PlatformTypeRules` + `Tuning.PLATFORM_*`, toplanabilirler `Pickup` + `PickupRules` deseniyle.
- **Günlük ödül / görevler:** elmas kazanma ve harcamaya düzenli bir hedef (ör. "bugün 3 kombo yap").
- **El/yumruk:** iskelette parmak kemiği yok; roket pozunda eller açık kalıyor (Blender'da el modeli/kemik gerekir).

## Platform ve erişim
- **Gamepad desteği** (Aşama 5'te ertelendi).
- **Dokunmatik / mobil kontroller** (web sürümü için anlamlı).
- **Yerelleştirme:** İngilizce dil seçeneği (yazılar şu an kodda Türkçe).
- **Web'de müzik:** web sürümünde radyo yok (`MusicLibrary.is_available()` false).
- **Online skor tablosu:** sunucu/hesap gerektirir; ücretsiz ve hesap açmadan bir yol bulunmadıkça yapılmaz (CLAUDE.md altın kural 4).

## Teknik
- Dosya boyutları: `main.gd` ~300 satırda; yeni sistem eklenecekse kurulum kodu ayrı düğümlere bölünmeli.
- Sürüm yükseltme: yalnız `project.godot` → `application/config/version` (`BuildInfo`); sürüm notları README/CHANGELOG'a.
