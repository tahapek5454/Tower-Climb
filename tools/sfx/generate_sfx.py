"""Tower Climb ses efektlerini sentezler (sadece Python standart kütüphanesi).

Çıktı: assets/audio/sfx/*.wav (44,1 kHz, mono, 16 bit). Rastgelelik sabit tohumlu: her çalıştırmada
aynı sesler üretilir. Üslup: yumuşak, şeker gibi (sinüs/üçgen ağırlıklı; sert kare dalga yok).
Kullanım (proje kökünden):  python tools/sfx/generate_sfx.py
Bir sesi beğenmezsen buradaki sayıları değiştirip yeniden çalıştır ya da aynı adla kendi .wav'ını koy.
"""

import math
import os
import random
import struct
import wave

RATE = 44100
PEAK = 0.62  # normalleştirme tepe genliği (yumuşak, kanalı doldurmasın)
OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "..", "assets", "audio", "sfx")

rng = random.Random(1234)


def silence(seconds):
    return [0.0] * int(RATE * seconds)


def env(t, attack, decay):
    """Hızlı yükselen, üstel sönen zarf."""
    if t < attack:
        return t / attack
    return math.exp(-(t - attack) / decay)


def mix(target, source, start_seconds=0.0, gain=1.0):
    start = int(start_seconds * RATE)
    for i, value in enumerate(source):
        if start + i < len(target):
            target[start + i] += value * gain
    return target


def sweep_tone(length, f_from, f_to, sweep_time, attack, decay, harmonics=((1, 1.0),),
               vibrato=0.0, vibrato_rate=0.0, triangle=False):
    """Perdesi üstel kayan ton. harmonics: (kat, genlik) listesi."""
    samples = []
    phase = 0.0
    for i in range(int(RATE * length)):
        t = i / RATE
        k = min(t / sweep_time, 1.0) if sweep_time > 0 else 1.0
        freq = f_from * (f_to / f_from) ** k
        freq *= 1.0 + vibrato * math.sin(2 * math.pi * vibrato_rate * t)
        phase += 2 * math.pi * freq / RATE
        value = 0.0
        for mult, amp in harmonics:
            p = phase * mult
            if triangle:
                value += amp * (2 / math.pi) * math.asin(math.sin(p))
            else:
                value += amp * math.sin(p)
        samples.append(value * env(t, attack, decay))
    return samples


def bell(length, freq, decay, partials=((1.0, 1.0), (2.0, 0.32), (3.01, 0.12), (4.2, 0.05))):
    """Yumuşak zil: üstel sönen harmonikler (yüksekler daha hızlı söner)."""
    samples = []
    for i in range(int(RATE * length)):
        t = i / RATE
        value = 0.0
        for mult, amp in partials:
            value += amp * math.sin(2 * math.pi * freq * mult * t) * math.exp(-t / (decay / mult ** 0.5))
        samples.append(value * min(t / 0.003, 1.0))
    return samples


def noise_burst(length, cutoff_from, cutoff_to, attack, decay, highpass=0.0):
    """Süzgeçli gürültü (tek kutuplu alçak geçiren, istenirse yüksek geçiren)."""
    samples = []
    low = 0.0
    low2 = 0.0
    for i in range(int(RATE * length)):
        t = i / RATE
        k = t / length
        cutoff = cutoff_from * (cutoff_to / cutoff_from) ** k
        a = 1.0 - math.exp(-2 * math.pi * cutoff / RATE)
        low += a * (rng.uniform(-1.0, 1.0) - low)
        value = low
        if highpass > 0.0:
            b = 1.0 - math.exp(-2 * math.pi * highpass / RATE)
            low2 += b * (low - low2)
            value = low - low2
        samples.append(value * env(t, attack, decay))
    return samples


def normalize(samples, peak=PEAK):
    top = max(abs(v) for v in samples) or 1.0
    fade = int(RATE * 0.004)  # sonda tık olmasın
    out = [v * peak / top for v in samples]
    for i in range(fade):
        out[-1 - i] *= i / fade
    return out


def write(name, samples):
    os.makedirs(OUT_DIR, exist_ok=True)
    path = os.path.join(OUT_DIR, name + ".wav")
    with wave.open(path, "wb") as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(RATE)
        f.writeframes(b"".join(struct.pack("<h", int(max(-1.0, min(1.0, v)) * 32767)) for v in samples))
    print("yazıldı:", os.path.normpath(path), f"({len(samples) / RATE:.2f} s)")


def jump():
    # Yumuşak "boing": yukarı kayan sinüs + hafif titreşim.
    return sweep_tone(0.24, 240, 640, 0.11, 0.004, 0.075, ((1, 1.0), (2, 0.22)), vibrato=0.025, vibrato_rate=22)


def land():
    # Tok "pof": aşağı kayan alçak sinüs + kısa, boğuk gürültü.
    tone = sweep_tone(0.2, 170, 62, 0.09, 0.002, 0.05, ((1, 1.0), (2, 0.15)))
    return mix(tone, noise_burst(0.06, 1400, 300, 0.001, 0.015), gain=0.55)


def wall():
    # "Bonk": aşağı kayan üçgen + çok kısa tıkırtı.
    tone = sweep_tone(0.22, 430, 290, 0.06, 0.002, 0.055, ((1, 1.0),), triangle=True)
    return mix(tone, noise_burst(0.02, 6000, 3000, 0.0005, 0.004, highpass=1500), gain=0.5)


def combo():
    # Kısa "çın": oyun içinde her kombo zıplayışında perdesi yükselir.
    return bell(0.55, 784, 0.22)


def combo_end():
    # Yükselen dört notalı arpej (Do-Mi-Sol-Do), zil tınısı.
    out = silence(1.0)
    for i, freq in enumerate((1046.5, 1318.5, 1568.0, 2093.0)):
        mix(out, bell(0.7, freq, 0.25 if i < 3 else 0.4), start_seconds=i * 0.07, gain=0.8 if i < 3 else 1.0)
    return out


def section():
    # Bölüm platformu: hızlı arpej + akor + parıltı tıngırtıları.
    out = silence(1.6)
    notes = (784.0, 1046.5, 1318.5, 1568.0)
    for i, freq in enumerate(notes):
        mix(out, bell(0.5, freq, 0.18), start_seconds=i * 0.085, gain=0.7)
    for freq in (1046.5, 1318.5, 1568.0, 2093.0):
        mix(out, bell(1.2, freq, 0.5), start_seconds=0.36, gain=0.45)
    for i in range(7):
        mix(out, bell(0.3, rng.uniform(2600, 4200), 0.07), start_seconds=0.4 + i * 0.09, gain=0.18)
    return out


def game_over():
    # Alçalan üç nota (Sol-Mi-Do), yumuşak "vah vah"; sonuncusu biraz aşağı süzülür.
    out = silence(1.2)
    soft_square = ((1, 1.0), (3, 0.18), (5, 0.06))
    for i, freq in enumerate((392.0, 329.6, 261.6)):
        last = i == 2
        tone = sweep_tone(0.6 if last else 0.26, freq, freq * (0.93 if last else 1.0), 0.5,
                          0.01, 0.25 if last else 0.12, soft_square, vibrato=0.012 if last else 0.0, vibrato_rate=6)
        mix(out, tone, start_seconds=i * 0.24)
    return out


def whoosh():
    # Takla "vuuş": süzgeci açılıp kapanan gürültü. Kullanıcı ilk sürümü yüksek/sert buldu →
    # daha boğuk (tavan 1100 Hz, iki kat süzgeç) ve daha yavaş yükselip inen, biraz daha uzun.
    length = 0.42
    samples = []
    low = 0.0
    low2 = 0.0
    for i in range(int(RATE * length)):
        t = i / RATE
        k = t / length
        cutoff = 220 + 900 * math.sin(math.pi * k)
        a = 1.0 - math.exp(-2 * math.pi * cutoff / RATE)
        low += a * (rng.uniform(-1.0, 1.0) - low)
        low2 += a * (low - low2)
        samples.append(low2 * math.sin(math.pi * k) ** 2.2)
    return samples


def ui_hover():
    # Menü üzerine gelme: çok kısa, yumuşak, yüksek "tik" (sönümlü sinüs).
    return sweep_tone(0.07, 880, 960, 0.03, 0.002, 0.018, ((1, 1.0), (2, 0.12)))


def ui_click():
    # Menü tıklama: iki katlı küçük "pop" (alt nota + hemen üstüne tiz nota).
    out = sweep_tone(0.16, 520, 700, 0.05, 0.002, 0.045, ((1, 1.0), (2, 0.2)))
    return mix(out, sweep_tone(0.12, 1040, 1100, 0.04, 0.002, 0.03, ((1, 1.0),)), start_seconds=0.03, gain=0.5)


def ui_back():
    # Geri/kapat: aşağı kayan yumuşak "pof" (tıklamanın tersi yönü).
    return sweep_tone(0.15, 620, 380, 0.07, 0.002, 0.04, ((1, 1.0), (2, 0.15)))


def record():
    # Yeni rekor fanfarı: hızlı yükselen beş notalı arpej (Do-Mi-Sol-Do-Mi), sonunda parlak akor ve
    # saçılan parıltılar. "section"dan daha uzun ve daha kutlama gibi.
    out = silence(2.4)
    notes = (523.3, 659.3, 784.0, 1046.5, 1318.5)
    for i, freq in enumerate(notes):
        mix(out, bell(0.6, freq, 0.22), start_seconds=i * 0.095, gain=0.75)
    for freq in (1046.5, 1318.5, 1568.0, 2093.0):
        mix(out, bell(1.6, freq, 0.7), start_seconds=0.5, gain=0.5)
    for i in range(10):
        mix(out, bell(0.3, rng.uniform(2800, 4600), 0.07), start_seconds=0.55 + i * 0.1, gain=0.16)
    return out


def pickup():
    # Güçlendirme alma: hızlı yükselen üç notalı parlak zil + küçük parıltı.
    out = silence(0.7)
    for i, freq in enumerate((784.0, 1046.5, 1568.0)):
        mix(out, bell(0.5, freq, 0.16), start_seconds=i * 0.055, gain=0.8)
    for i in range(4):
        mix(out, bell(0.2, rng.uniform(3000, 4400), 0.05), start_seconds=0.16 + i * 0.06, gain=0.15)
    return out


def jetpack():
    # Roket uçuşu (~3,4 s; uçuş 3 s): kalkışta kısa "fooş" patlaması, ardından boğuk, hafif dalgalanan
    # gürleme (iki kat süzgeçli gürültü + alçak uğultu), sonda yumuşak sönme. Yumuşak üslup: tiz hışırtı yok.
    length = 3.4
    samples = []
    low = 0.0
    low2 = 0.0
    phase = 0.0
    for i in range(int(RATE * length)):
        t = i / RATE
        launch = math.exp(-t / 0.18)
        wobble = 1.0 + 0.12 * math.sin(2 * math.pi * 7.0 * t) + 0.08 * math.sin(2 * math.pi * 11.3 * t)
        cutoff = (520 + 900 * launch) * wobble
        a = 1.0 - math.exp(-2 * math.pi * cutoff / RATE)
        low += a * (rng.uniform(-1.0, 1.0) - low)
        low2 += a * (low - low2)
        phase += 2 * math.pi * (62 + 30 * launch) / RATE
        hum = 0.22 * math.sin(phase) + 0.08 * math.sin(2 * phase)
        fade_in = min(t / 0.03, 1.0)
        fade_out = min(max((length - t) / 0.5, 0.0), 1.0) ** 1.5
        samples.append((low2 * (2.2 + 1.6 * launch) + hum) * fade_in * fade_out)
    return samples


def jetpack_end():
    # Roket sönmesi: aşağı kayan kısa "pfff" + küçük tok "pop".
    out = noise_burst(0.32, 1400, 260, 0.01, 0.09)
    return mix(out, sweep_tone(0.2, 300, 140, 0.1, 0.004, 0.06, ((1, 1.0), (2, 0.2))), gain=0.8)


def diamond():
    # Elmas: kristal gibi iki notalı parlak "tiriing" (Mi-Si, yüksek), arkasında kısa ince parıltı.
    out = silence(0.6)
    mix(out, bell(0.5, 1318.5, 0.12, ((1.0, 1.0), (2.76, 0.25), (5.4, 0.08))), gain=0.7)
    mix(out, bell(0.55, 1975.5, 0.16, ((1.0, 1.0), (2.76, 0.22), (5.4, 0.07))), start_seconds=0.06, gain=0.8)
    for i in range(3):
        mix(out, bell(0.15, rng.uniform(4200, 5600), 0.035), start_seconds=0.1 + i * 0.05, gain=0.12)
    return out


def heart():
    # Kalp kazanma: sıcak, yumuşak iki notalı yükselen zil (Sol-Do), altında hafif "tuk-tuk" kalp atışı.
    out = silence(0.8)
    mix(out, sweep_tone(0.12, 120, 80, 0.08, 0.004, 0.04), gain=0.5)
    mix(out, sweep_tone(0.12, 120, 80, 0.08, 0.004, 0.04), start_seconds=0.13, gain=0.4)
    mix(out, bell(0.6, 784.0, 0.2, ((1.0, 1.0), (2.0, 0.2), (3.0, 0.06))), start_seconds=0.02, gain=0.6)
    mix(out, bell(0.65, 1046.5, 0.26, ((1.0, 1.0), (2.0, 0.2), (3.0, 0.06))), start_seconds=0.14, gain=0.7)
    return out


def rescue():
    # Kalple kurtarma: aşağıdan yukarı hızla yükselen yumuşak "vuuup" + parlak, umut veren üç notalı akor.
    out = silence(1.1)
    mix(out, noise_burst(0.45, 300, 2600, 0.12, 0.2), gain=0.7)
    mix(out, sweep_tone(0.45, 220, 880, 0.35, 0.02, 0.18, ((1, 1.0), (2, 0.18)), triangle=True), gain=0.5)
    for i, freq in enumerate((659.3, 830.6, 987.8)):
        mix(out, bell(0.7, freq, 0.28), start_seconds=0.28 + i * 0.05, gain=0.55)
    return out


def hourglass():
    # Zaman yavaşlıyor: tatlı bir zil, ardından yavaşça aşağı süzülen yumuşak "vuuum" (bant yavaşlaması
    # gibi) ve uzayan, hafif titreşimli tını.
    out = silence(1.4)
    mix(out, bell(0.8, 1174.7, 0.3), gain=0.55)
    mix(out, sweep_tone(1.3, 660, 220, 1.0, 0.03, 0.45, ((1, 1.0), (2, 0.15)), vibrato=0.02,
                        vibrato_rate=5.0, triangle=True), start_seconds=0.05, gain=0.6)
    mix(out, noise_burst(0.9, 1800, 300, 0.05, 0.3), start_seconds=0.05, gain=0.25)
    return out


def hourglass_end():
    # Zaman normale dönüyor: kısa, yukarı kayan yumuşak "vuup" + küçük tık.
    out = sweep_tone(0.45, 260, 620, 0.3, 0.02, 0.14, ((1, 1.0), (2, 0.15)), triangle=True)
    return mix(out, bell(0.3, 1568.0, 0.08), start_seconds=0.26, gain=0.35)


def achievement():
    # Başarım bildirimi: üç notalı (Mi-Sol-Do) yumuşak, parlak çan + küçük parıltı; "record"dan çok daha küçük.
    out = silence(1.0)
    for i, freq in enumerate((659.3, 784.0, 1046.5)):
        mix(out, bell(0.55, freq, 0.2), start_seconds=i * 0.09, gain=0.75)
    mix(out, bell(0.8, 1568.0, 0.35), start_seconds=0.22, gain=0.3)
    for i in range(3):
        mix(out, bell(0.25, rng.uniform(3000, 4400), 0.06), start_seconds=0.3 + i * 0.08, gain=0.12)
    return out


def record_line():
    # Rekor çizgisi geçildi: kısa, parlak, yükselen iki notalı çan (Sol-Re, yüksek); "record" fanfarından
    # çok daha küçük ve kısa.
    out = silence(0.7)
    mix(out, bell(0.5, 1568.0, 0.14, ((1.0, 1.0), (2.76, 0.2), (5.4, 0.06))), gain=0.7)
    mix(out, bell(0.6, 2349.3, 0.2, ((1.0, 1.0), (2.76, 0.2), (5.4, 0.06))), start_seconds=0.11, gain=0.8)
    return out


def crumble_crack():
    # Çatlayan platforma basıldı: kuru, ufak taş çıtırtısı (üç kısa "çıt") + boğuk gıcırtı.
    out = silence(0.4)
    for i in range(3):
        mix(out, noise_burst(0.05, 5200, 1800, 0.0008, 0.01, highpass=900),
            start_seconds=i * rng.uniform(0.05, 0.08), gain=0.55 - i * 0.12)
    mix(out, sweep_tone(0.3, 210, 150, 0.25, 0.02, 0.09, ((1, 1.0), (2, 0.2)), triangle=True), gain=0.35)
    return out


def crumble():
    # Platform çöküyor: yumuşak, boğuk bir "kürt" (alçak gürültü) + dağılan küçük taş tıkırtıları.
    out = silence(0.9)
    mix(out, noise_burst(0.5, 1600, 160, 0.006, 0.16), gain=0.9)
    mix(out, sweep_tone(0.35, 120, 55, 0.25, 0.004, 0.1, ((1, 1.0), (2, 0.12))), gain=0.5)
    for i in range(6):
        mix(out, bell(0.08, rng.uniform(1500, 2600), 0.018, ((1.0, 1.0), (2.3, 0.2))),
            start_seconds=0.08 + i * rng.uniform(0.05, 0.09), gain=0.18)
    return out


def magnet():
    # Mıknatıs: yumuşak, yukarı süzülen "vuuum" (alçak uğultu, hafif titreşimli) ve üstünde dağılan
    # ince parıltılar (elmaslar geliyor).
    out = silence(1.2)
    mix(out, sweep_tone(0.9, 140, 330, 0.7, 0.06, 0.35, ((1, 1.0), (2, 0.3), (3, 0.08)), vibrato=0.015,
                        vibrato_rate=7.0, triangle=True), gain=0.55)
    mix(out, noise_burst(0.6, 400, 1600, 0.2, 0.25), gain=0.18)
    for i in range(5):
        mix(out, bell(0.3, rng.uniform(2600, 4200), 0.07), start_seconds=0.35 + i * 0.09, gain=0.2)
    return out


def magnet_end():
    # Mıknatıs sönüyor: aşağı inen kısa, yumuşak "vuuu" + küçük tok tık.
    out = sweep_tone(0.45, 330, 150, 0.35, 0.02, 0.16, ((1, 1.0), (2, 0.2)), triangle=True)
    return mix(out, bell(0.25, 880.0, 0.06), start_seconds=0.3, gain=0.25)


def revive_offer():
    # Devam kartı açıldı: iki yumuşak, tok kalp atışı ("tuk-tuk") ve üstünde soru sorar gibi hafifçe
    # yükselen sıcak zil (Do-Mi). Rastgelelik kullanmaz (sözlükteki sırası başka sesleri etkilemez).
    out = silence(0.9)
    mix(out, sweep_tone(0.14, 110, 70, 0.1, 0.004, 0.05, ((1, 1.0), (2, 0.15))), gain=0.7)
    mix(out, sweep_tone(0.14, 110, 70, 0.1, 0.004, 0.05, ((1, 1.0), (2, 0.15))), start_seconds=0.16, gain=0.55)
    mix(out, bell(0.6, 523.3, 0.22, ((1.0, 1.0), (2.0, 0.2), (3.0, 0.05))), start_seconds=0.3, gain=0.45)
    mix(out, bell(0.55, 659.3, 0.24, ((1.0, 1.0), (2.0, 0.2), (3.0, 0.05))), start_seconds=0.42, gain=0.5)
    return out


def revive():
    # Elmasla devam: kalp parlayıp patlıyor — kısa "vuup" yükselişi, parlak dört notalı akor (Do-Mi-Sol-Do)
    # ve sabit perdeli ince parıltılar. Rastgelelik kullanmaz.
    out = silence(1.3)
    mix(out, sweep_tone(0.3, 260, 1040, 0.22, 0.01, 0.12, ((1, 1.0), (2, 0.15)), triangle=True), gain=0.45)
    for i, freq in enumerate((523.3, 659.3, 784.0, 1046.5)):
        mix(out, bell(0.9, freq, 0.32), start_seconds=0.12 + i * 0.04, gain=0.5)
    for i, freq in enumerate((3136.0, 3729.3, 4186.0, 3520.0)):
        mix(out, bell(0.25, freq, 0.06), start_seconds=0.22 + i * 0.07, gain=0.14)
    return out


# Yeni sesler sözlüğün SONUNA eklenir: rastgelelik sırası değişmez, eski sesler aynı üretilir.
SOUNDS = {
    "jump": jump, "land": land, "wall": wall, "combo": combo, "combo_end": combo_end,
    "section": section, "game_over": game_over, "whoosh": whoosh,
    "ui_hover": ui_hover, "ui_click": ui_click, "ui_back": ui_back, "record": record,
    "pickup": pickup, "jetpack": jetpack, "jetpack_end": jetpack_end,
    "diamond": diamond, "heart": heart, "rescue": rescue,
    "hourglass": hourglass, "hourglass_end": hourglass_end,
    "achievement": achievement,
    "record_line": record_line,
    "crumble_crack": crumble_crack, "crumble": crumble,
    "magnet": magnet, "magnet_end": magnet_end,
    "revive_offer": revive_offer, "revive": revive,
}


if __name__ == "__main__":
    for sound_name, make in SOUNDS.items():
        write(sound_name, normalize(make()))
