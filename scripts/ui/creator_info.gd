class_name CreatorInfo
extends RefCounted
## Ana menünün sağ altındaki yapımcı kartının bilgileri (tek yapılandırma yeri).
## Kartı tamamen kaldırmak için ENABLED = false. Bağlantı eklemek/çıkarmak için LINKS'i düzenle;
## icon: &"github" ya da &"web" (CreatorBadge çizer).

const ENABLED: bool = true
const CAPTION: String = "Oyunu yapan"
const NAME: String = "Taha Pek"
const LINKS: Array[Dictionary] = [
	{"icon": &"github", "text": "tahapek5454", "url": "https://github.com/tahapek5454"},
	{"icon": &"web", "text": "www.tahapek.com", "url": "https://www.tahapek.com"},
]
