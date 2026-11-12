# Yeni oturum promptu — Aşama 6

Aşama 5 bittiğinde hazırlandı (2026-11-12). Temiz bir Claude Code penceresi açıp aşağıdaki bloğu olduğu gibi yapıştır.
Önceki sohbetten hiçbir şey taşınmaz; her şey `CLAUDE.md` ve `docs/` altındaki dosyalarda.

````text
Tower Climb projesine devam ediyoruz. Yeni bir oturumdayız; önceki sohbetlerden hiçbir şey hatırlamıyorsun, bu yüzden her şey dosyalarda.

1. CLAUDE.md'yi oku (proje kuralları, altın kurallar, aşama geçiş kuralı). Ardından docs/PROGRESS.md'nin en üstündeki "Yeni oturumda buradan devam" bölümünü ve altındaki "Kullanıcı ve çalışma tarzı" ile "Araç tuzakları" notlarını izle; "Aşama 6 hazırlığı" ve "Aşama 5 sonrası mimari özeti" bölümlerini de oku. docs/GAME_DESIGN.md'yi de oku.

2. Önce ortam kontrolünü yap ve tabloyla raporla (CLAUDE.md bölüm 0). Ayrıca GUT testlerini çalıştır: 134 test geçmeli.

3. Aşama 1–5 bitti ve onaylandı: fizik prototipi, juice, kartal karakter, dünya görselleri ve ses, oyun döngüsü ve arayüz (ana menü, duraklatma, ayarlar, oyun sonu, kalıcı rekorlar). "devam" diyorum: şimdi Aşama 6'ya (Ek özellikler) başlıyoruz. Fikirlerim: para toplama, kanat (alınca karakter belli bir süre kendiliğinden uçar), kum saati (alınca zaman yavaşlar), roket gibi benzer güçlendirmeler.

Kod yazmadan önce:
- Aşama 6'nın maddelerini ve yaklaşımını benimle netleştir: kapsam ve sıra, hangi güçlendirme önce gelsin, paranın kalıcı olup olmayacağı, görünümlerin kodla mı Blender'da mı yapılacağı, denge (ne sıklıkta çıkacaklar, ne kadar sürecekler). Karar gereken yerlerde kısa seçenekler ve kendi önerinle sor.
- Mevcut mimariye uy: sabit sayılar scripts/tuning.gd'de, güçlendirme etkileri çalışma zamanı çarpanlarıyla; player.gd (fizik) ile player_visual.gd (görüntü) ayrı; akış GameFlow ile; arayüz UiStyle/UiScreen dilinde.
- Ben onaylamadan kod yazmaya başlama.

Çalışma tarzım: tek seferde tek madde. Bitir, doğrula (testler + ekran görüntüsü), commit at, docs/PROGRESS.md'yi güncelle, nasıl test edeceğimi söyle. Görsel bir şeyi göremediysen "güzel oldu" deme; ekran görüntüsüyle doğrula. Canlılık katan küçük detayları (animasyon, parçacık, ses, geçiş efekti) severim, uygun yerlerde öner. Beğenmediğim bir şeyin kolayca kaldırılabilmesini isterim. Türkçe konuş. Aşama bitince CLAUDE.md'deki aşama bildirimi formatını kullan ve "devam" yazmamı bekle; kendiliğinden Aşama 7'ye geçme.
````
