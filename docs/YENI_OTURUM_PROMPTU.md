# Yeni oturum promptu — Aşama 6, son madde: elmas mağazası

Aşama 6 madde 1–10 bittiğinde hazırlandı (2026-11-13). Temiz bir Claude Code penceresi açıp aşağıdaki bloğu olduğu gibi yapıştır.
Önceki sohbetten hiçbir şey taşınmaz; her şey `CLAUDE.md` ve `docs/` altındaki dosyalarda (ve ikinci beyin kasasındaki Tower-Climb notlarında).

````text
Tower Climb projesine devam ediyoruz. Yeni bir oturumdayız; önceki sohbetlerden hiçbir şey hatırlamıyorsun, bu yüzden her şey dosyalarda.

1. CLAUDE.md'yi oku. Ardından docs/PROGRESS.md'nin en üstündeki "Yeni oturumda buradan devam" bölümünü, "Elmas mağazası hazırlığı"nı, "Kullanıcı ve çalışma tarzı" ve "Araç tuzakları" notlarını, "Aşama 6 kararları"nı ve "Aşama 5 sonrası mimari özeti"ni oku. docs/GAME_DESIGN.md'yi de oku.

2. Önce ortam kontrolünü yap ve tabloyla raporla (CLAUDE.md bölüm 0). GUT testlerini çalıştır: 212 test geçmeli.

3. Aşama 6'nın madde 1–10'u bitti ve onaylandı (roket, elmas, kalp, kum saati, hızlanma, rekor çizgisi, kombo elması, mıknatıs, platform türleri, başarımlar). Şimdi son madde olan elmas mağazasına başlıyoruz; büyük bir geliştirme.

Kod yazmadan önce:
- Mağazanın kapsamını benimle netleştir ("Elmas mağazası hazırlığı"ndaki sorular): ne satılacak (kodla yapılan renk/iz/efektler, kemiğe takılan aksesuarlar, tam kostüm), fiyatlar ve elmas ekonomisi, kayıt, ekran tasarımı, karakter önizlemesi. Karar gereken yerlerde kısa seçenekler ve kendi önerinle sor.
- İşi alt maddelere böl ve sırayı benimle belirle. Uygun alt maddeleri paralel alt ajanlarla yapabilirsin (basit işler Sonnet'e).
- Mevcut mimariye uy: sayılar scripts/tuning.gd'de; player.gd (fizik) ile Visual katmanı ayrı; arayüz UiStyle/UiScreen dilinde; kayıt SaveData'da.
- Modelleme gerekirse Blender + blender-mcp'yi kontrol et; Tripo üretimini ben web sitesinden yaparım.
- Ben onaylamadan kod yazmaya başlama.

Çalışma tarzım: tek seferde tek alt madde. Bitir, doğrula (testler + ekran görüntüsü), commit at, docs/PROGRESS.md'yi güncelle, nasıl test edeceğimi söyle. Görsel bir şeyi göremediysen "güzel oldu" deme. Canlılık katan küçük detayları severim. Beğenmediğim bir şeyin kolayca kaldırılabilmesini isterim. Türkçe konuş. Mağaza bitince CLAUDE.md'deki aşama bildirimi formatıyla Aşama 6'yı bildir ve "devam" yazmamı bekle; kendiliğinden Aşama 7'ye geçme.
````
