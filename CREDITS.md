# Krediler

## Kod ve araçlar

| Ne | Kaynak | Lisans | Nerede |
|---|---|---|---|
| GUT — Godot Unit Testing 9.7.1 | https://github.com/bitwes/Gut/releases/tag/v9.7.1 (Tom "Butch" Wesley) | MIT | `addons/gut/` |
| Godot Engine 4.7 (oyun motoru; varsayılan yazı tipi de motorla gelir) | https://godotengine.org | MIT (motor); yazı tipi lisansı Godot'nun "Third-party licenses" listesinde | Motor (projeye gömülü değil) |
| blender-mcp Blender eklentisi (geliştirme aracı, oyuna dahil değil) | https://github.com/ahujasid/blender-mcp (Siddharth Ahuja) | MIT | `tools/blender/addon.py` |

## Görseller ve modeller

Dünya görselleri (kule, platformlar, süsler, gökyüzü, parçacıklar) kodla/shader ile üretilir; dış görsel dosyası yok.

| Ne | Kaynak | Lisans | Nerede |
|---|---|---|---|
| Kartal karakter konsept görseli | Proje sahibi tarafından ChatGPT ile üretildi | Proje sahibine ait | `docs/concept/hero_chibi_v1.jpg` |
| Kartal karakter 3D modeli | Konsept görselinden Tripo (tripo3d.ai, ücretsiz plan, H2.5) ile üretildi; Blender'da sadeleştirildi, dokusu düzenlendi | Tripo ücretsiz plan koşulları (herkese açık model) | `assets/models/` |

## Ses ve müzik

| Ne | Kaynak | Lisans | Nerede |
|---|---|---|---|
| Ses efektleri (zıplama, iniş, duvar, kombo, bölüm, oyun sonu, vuuş, arayüz tıkları, yeni rekor fanfarı, güçlendirme alma, roket, elmas) | Proje içinde kodla sentezlendi: `tools/sfx/generate_sfx.py` (dış kaynak yok) | MIT (proje kodu) | `assets/audio/sfx/` |

Oyuna müzik dahil değildir: oyuncu kendi müziklerini (mp3/ogg/wav) masaüstünde radyo paneline ekler (`user://music`); web'de müzik yoktur. Projede dış kaynaklı ses dosyası yoktur.

## Yazı tipi

Ayrı bir yazı tipi dosyası eklenmedi; Godot'nun varsayılan yazı tipi kullanılır (kullanıcı kararı, Aşama 5).
