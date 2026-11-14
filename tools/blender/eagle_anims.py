# Kartal karakterin animasyonlarını üretir (Blender içinde çalıştırılır).
# Kullanım: assets/models/source/eagle_hero.blend açıkken
#   exec(open(r"<repo>/tools/blender/eagle_anims.py", encoding="utf-8").read())
#
# Eksenler (armatür uzayı): karakter -Y'ye bakar, yukarı +Z, sol taraf (.L) +X.
#   rx > 0 : sarkan uzuvlar (bacak, kol) GERİYE, dik kemikler (omurga, kafa) ÖNE eğilir.
#   side>0 : kol yana doğru yukarı kalkar (iki tarafta da aynı anlam).
#   rz     : dikey eksende burulma.
import math

import bpy
from mathutils import Quaternion, Vector

RIG_NAME = "EagleRig"
FPS = 30
THIGH_LEN = 0.13
SHIN_LEN = 0.11

rig = bpy.data.objects[RIG_NAME]
BONES = [b.name for b in rig.data.bones if b.name != "root"]


def _quat(bone_name: str, rx: float = 0.0, side: float = 0.0, rz: float = 0.0) -> Quaternion:
    """Armatür uzayındaki açıları kemiğin yerel pose quaternion'una çevirir."""
    sign = -1.0 if bone_name.endswith(".L") else 1.0
    q = (
        Quaternion((0, 0, 1), math.radians(rz))
        @ Quaternion((0, 1, 0), math.radians(side * sign))
        @ Quaternion((1, 0, 0), math.radians(rx))
    )
    rest = rig.data.bones[bone_name].matrix_local.to_quaternion()
    return rest.inverted() @ q @ rest


def _crouch(a_deg: float) -> tuple[float, float, float]:
    """Uyluk açısı a için ayağı yerde tutan baldır/ayak açısı ve kalça inişi."""
    a = math.radians(max(a_deg, 0.0))
    rel = math.asin(min(1.0, THIGH_LEN * math.sin(a) / SHIN_LEN))
    drop = THIGH_LEN + SHIN_LEN - (THIGH_LEN * math.cos(a) + SHIN_LEN * math.cos(rel))
    b = math.degrees(a + rel)
    return b, a_deg - b, drop


# --- Pozlar: {kemik: dict(rx=, side=, rz=)} + "_hips_dz" -----------------------

def pose_idle(t: float) -> dict:
    p = 2.0 * math.pi * t
    b = math.sin(p)
    pose = {
        "spine": dict(rx=1.5 * b),
        "chest": dict(rx=1.5 * b),
        "head": dict(rx=-2.5 * b, rz=2.0 * math.sin(p + 1.0)),
        "tail": dict(rx=6.0 * b, rz=14.0 * math.sin(2 * p)),
        "tail_tip": dict(rz=12.0 * math.sin(2 * p - 0.9)),
    }
    for s in (".L", ".R"):
        pose["upper_arm" + s] = dict(side=-8.0 + 3.0 * b, rx=4.0)
        pose["forearm" + s] = dict(rx=-10.0 - 2.0 * b)
    return pose


def pose_run(t: float) -> dict:
    p = 2.0 * math.pi * t
    pose = {
        "hips": dict(rz=-7.0 * math.sin(p)),
        "spine": dict(rx=18.0),
        "chest": dict(rx=8.0, rz=12.0 * math.sin(p)),
        "head": dict(rx=-18.0, rz=-5.0 * math.sin(p)),
        "tail": dict(rx=25.0 + 8.0 * math.cos(2 * p - 1.0), rz=12.0 * math.sin(p - 0.8)),
        "tail_tip": dict(rx=10.0 * math.cos(2 * p - 2.0), rz=10.0 * math.sin(p - 1.6)),
        "_hips_dz": -0.02 + 0.018 * math.cos(2 * p),
    }
    for s, ph in ((".L", p), (".R", p + math.pi)):
        sn, cs = math.sin(ph), math.cos(ph)
        pose["thigh" + s] = dict(rx=-(8.0 + 52.0 * sn))
        pose["shin" + s] = dict(rx=12.0 + 70.0 * (0.5 + 0.5 * cs) ** 1.5)
        pose["foot" + s] = dict(rx=-12.0 * sn)
        pose["upper_arm" + s] = dict(rx=-5.0 + 52.0 * sn, side=-12.0)
        pose["forearm" + s] = dict(rx=-70.0 + 15.0 * sn)
    return pose


JUMP_POSE = {
    "spine": dict(rx=-6.0),
    "chest": dict(rx=-6.0),
    "head": dict(rx=-10.0),
    "thigh.L": dict(rx=-45.0),
    "shin.L": dict(rx=70.0),
    "thigh.R": dict(rx=15.0),
    "shin.R": dict(rx=20.0),
    "foot.R": dict(rx=30.0),
    "upper_arm.L": dict(side=60.0, rx=35.0),
    "upper_arm.R": dict(side=60.0, rx=35.0),
    "forearm.L": dict(side=15.0),
    "forearm.R": dict(side=15.0),
    "tail": dict(rx=-20.0),
    "tail_tip": dict(rx=-10.0),
}

JUMP_START = {
    "upper_arm.L": dict(side=15.0),
    "upper_arm.R": dict(side=15.0),
    "foot.L": dict(rx=25.0),
    "foot.R": dict(rx=25.0),
}

TUCK_POSE = {
    "spine": dict(rx=25.0),
    "chest": dict(rx=20.0),
    "head": dict(rx=25.0),
    "tail": dict(rx=-30.0),
    "tail_tip": dict(rx=-20.0),
}
for _s in (".L", ".R"):
    TUCK_POSE["thigh" + _s] = dict(rx=-95.0)
    TUCK_POSE["shin" + _s] = dict(rx=110.0)
    TUCK_POSE["upper_arm" + _s] = dict(rx=-70.0, side=-10.0)
    TUCK_POSE["forearm" + _s] = dict(rx=-60.0)


# Yıldız takla pozu: kollar ve bacaklar yana açık. Oyunda model kameraya dönükken oynar,
# böylece ekran düzleminde dönen bir "yan takla" (çark) olur.
STAR_POSE = {
    "spine": dict(rx=-4.0),
    "head": dict(rx=-6.0),
    "tail": dict(rx=15.0),
}
for _s in (".L", ".R"):
    STAR_POSE["upper_arm" + _s] = dict(side=106.0)
    STAR_POSE["forearm" + _s] = dict(side=8.0)
    STAR_POSE["thigh" + _s] = dict(side=42.0)
    STAR_POSE["shin" + _s] = dict(side=4.0)
    STAR_POSE["foot" + _s] = dict(rx=20.0)


# Ters takla (geriye salto): önce gövde geriye kavislenir, kollar geriye savrulur (itiş; yandan
# bakışta yüzü kapatmasın diye yukarı değil);
# sonra dizler göğse çekilir, eller baldırları tutar, baş hafif geride kalır (gidilen yöne bakar).
BACK_ARCH_POSE = {
    "spine": dict(rx=-12.0),
    "chest": dict(rx=-8.0),
    "head": dict(rx=-14.0),
    "tail": dict(rx=25.0),
    "tail_tip": dict(rx=15.0),
}
BACK_TUCK_POSE = {
    "spine": dict(rx=22.0),
    "chest": dict(rx=16.0),
    "head": dict(rx=-14.0),
    "tail": dict(rx=-28.0),
    "tail_tip": dict(rx=-20.0),
}
for _s in (".L", ".R"):
    BACK_ARCH_POSE["upper_arm" + _s] = dict(side=32.0, rx=58.0)
    BACK_ARCH_POSE["forearm" + _s] = dict(rx=-12.0)
    BACK_ARCH_POSE["thigh" + _s] = dict(rx=12.0)
    BACK_ARCH_POSE["shin" + _s] = dict(rx=14.0)
    BACK_ARCH_POSE["foot" + _s] = dict(rx=30.0)
    BACK_TUCK_POSE["thigh" + _s] = dict(rx=-100.0)
    BACK_TUCK_POSE["shin" + _s] = dict(rx=115.0)
    BACK_TUCK_POSE["foot" + _s] = dict(rx=15.0)
    BACK_TUCK_POSE["upper_arm" + _s] = dict(rx=-58.0, side=-6.0)
    BACK_TUCK_POSE["forearm" + _s] = dict(rx=-72.0)


# Silindirik dönüş (dikey eksende burgu): kollar önce açık (dönüşü başlatan savruluş), sonra
# göğse kapanır (buz patencisi gibi); dizler kırık, biri daha yukarıda (simetrik durmasın).
TWIST_OPEN_POSE = {
    "spine": dict(rx=-4.0),
    "head": dict(rx=-8.0),
    "tail": dict(rx=10.0),
    "thigh.L": dict(rx=-30.0),
    "shin.L": dict(rx=45.0),
    "thigh.R": dict(rx=-8.0),
    "shin.R": dict(rx=20.0),
    "foot.L": dict(rx=20.0),
    "foot.R": dict(rx=25.0),
}
TWIST_POSE = {
    "spine": dict(rx=4.0),
    "chest": dict(rx=2.0),
    "head": dict(rx=-6.0),
    "tail": dict(rx=-6.0, rz=12.0),
    "tail_tip": dict(rx=-6.0, rz=10.0),
    "thigh.L": dict(rx=-88.0),
    "shin.L": dict(rx=118.0),
    "foot.L": dict(rx=22.0),
    "thigh.R": dict(rx=-32.0),
    "shin.R": dict(rx=78.0),
    "foot.R": dict(rx=28.0),
}
# Kapanan kollar: üst kol öne ve içe, ön kol dirsekten bükülüp göğsün önünde içe döner.
# rz yanlara göre ters işaretlidir (ön kollar ortada buluşsun).
TWIST_ARM_SIDE = -35.0
TWIST_ARM_RX = -48.0
TWIST_FOREARM_RX = -70.0
TWIST_FOREARM_RZ = 95.0
for _s, _rz in ((".L", -1.0), (".R", 1.0)):
    TWIST_OPEN_POSE["upper_arm" + _s] = dict(side=58.0, rx=-8.0)
    TWIST_OPEN_POSE["forearm" + _s] = dict(rx=-18.0)
    TWIST_POSE["upper_arm" + _s] = dict(side=TWIST_ARM_SIDE, rx=TWIST_ARM_RX)
    TWIST_POSE["forearm" + _s] = dict(rx=TWIST_FOREARM_RX, rz=_rz * TWIST_FOREARM_RZ)


def pose_fly(t: float) -> dict:
    """Roketle uçuş (süpermen): kollar yukarı dik, gövde gergin, bacaklar bitişik; hafif titreşim döngüsü."""
    p = 2.0 * math.pi * t
    sn = math.sin(p)
    pose = {
        "spine": dict(rx=-5.0 + 1.5 * sn),
        "chest": dict(rx=-6.0),
        "head": dict(rx=-16.0 + 2.0 * math.sin(p + 0.8)),
        "tail": dict(rx=-18.0 + 10.0 * math.sin(2 * p), rz=10.0 * sn),
        "tail_tip": dict(rx=-10.0 + 12.0 * math.sin(2 * p - 0.9), rz=8.0 * math.sin(p - 0.8)),
        "_arm_stretch": FLY_ARM_STRETCH,
    }
    for s, ph in ((".L", 0.0), (".R", math.pi)):
        kick = math.sin(2 * p + ph)
        pose["upper_arm" + s] = dict(side=FLY_ARM_SIDE + 2.5 * math.sin(p + ph), rx=FLY_ARM_RX)
        pose["forearm" + s] = dict(side=FLY_FOREARM_SIDE)
        pose["thigh" + s] = dict(rx=8.0 + 5.0 * kick)
        pose["shin" + s] = dict(rx=10.0 + 6.0 * kick)
        pose["foot" + s] = dict(rx=38.0)
    return pose


# Uçuş pozunda kol açıları. Kollar dinlenmede ~32° dışa sarkar: side=122 ≈ başın iki yanında "V".
# rx > 0 kalkık kolu geriye iter (yandan bakışta yüzü kapatmasın). Kollar kısa olduğu için üst kol
# bu pozda boyuna uzatılır (çizgi film esnemesi) → eller başın hizasına çıkar.
FLY_ARM_SIDE = 122.0
FLY_ARM_RX = 14.0
FLY_FOREARM_SIDE = 22.0
FLY_ARM_STRETCH = 1.3


def pose_fall(t: float) -> dict:
    p = 2.0 * math.pi * t
    sn, cs = math.sin(p), math.cos(p)
    pose = {
        "spine": dict(rx=10.0),
        "head": dict(rx=10.0),
        "thigh.L": dict(rx=-40.0 + 16.0 * sn),
        "thigh.R": dict(rx=-12.0 - 16.0 * sn),
        "shin.L": dict(rx=55.0 + 15.0 * cs),
        "shin.R": dict(rx=40.0 - 15.0 * cs),
        "foot.L": dict(rx=15.0),
        "foot.R": dict(rx=15.0),
        "tail": dict(rx=35.0 + 6.0 * math.sin(2 * p)),
        "tail_tip": dict(rx=15.0 + 8.0 * math.sin(2 * p - 1.0)),
    }
    for s in (".L", ".R"):
        pose["upper_arm" + s] = dict(side=72.0 + 20.0 * math.sin(2 * p), rx=30.0)
        pose["forearm" + s] = dict(side=12.0 * math.sin(2 * p - 1.0))
    return pose


def pose_flap(t: float) -> dict:
    """Zıplama pozunda iki kanat çırpışı; sonunda zıplama pozuna döner."""
    pose = {k: dict(v) for k, v in JUMP_POSE.items()}
    wing = 22.0 + 38.0 * math.cos(4.0 * math.pi * t)
    lag = 25.0 * math.sin(4.0 * math.pi * t)
    for s in (".L", ".R"):
        pose["upper_arm" + s] = dict(side=wing, rx=35.0 - 30.0 * (60.0 - wing) / 76.0)
        pose["forearm" + s] = dict(side=15.0 + lag)
    pose["chest"] = dict(rx=-6.0 + 5.0 * math.sin(4.0 * math.pi * t))
    return pose


def pose_land(k: float) -> dict:
    """k=1 en derin çömelme, k=0 düz duruş (idle başlangıcıyla aynı kollar)."""
    kk = max(k, 0.0)
    a = 55.0 * kk
    b, foot, drop = _crouch(a)
    pose = {
        "spine": dict(rx=30.0 * k),
        "chest": dict(rx=8.0 * k),
        "head": dict(rx=-20.0 * k),
        "tail": dict(rx=30.0 * k),
        "_hips_dz": -drop,
    }
    for s in (".L", ".R"):
        pose["thigh" + s] = dict(rx=-a)
        pose["shin" + s] = dict(rx=b)
        pose["foot" + s] = dict(rx=foot)
        pose["upper_arm" + s] = dict(side=-8.0 + 50.0 * kk, rx=4.0 + 30.0 * kk)
        pose["forearm" + s] = dict(rx=-10.0)
    return pose


def _blend(p0: dict, p1: dict, w: float) -> dict:
    out: dict = {}
    for name in set(p0) | set(p1):
        if name.startswith("_"):
            out[name] = p0.get(name, 0.0) * (1 - w) + p1.get(name, 0.0) * w
            continue
        a, b = p0.get(name, {}), p1.get(name, {})
        out[name] = {k: a.get(k, 0.0) * (1 - w) + b.get(k, 0.0) * w for k in ("rx", "side", "rz")}
    return out


def _smooth(w: float) -> float:
    w = min(max(w, 0.0), 1.0)
    return w * w * (3.0 - 2.0 * w)


# --- Anahtarlama --------------------------------------------------------------

_last_q: dict = {}


def _apply(pose: dict, frame: int) -> None:
    hips_rest = rig.data.bones["hips"].matrix_local.to_quaternion()
    for name in BONES:
        pb = rig.pose.bones[name]
        pb.rotation_mode = "QUATERNION"
        q = _quat(name, **pose.get(name, {}))
        prev = _last_q.get(name)
        if prev is not None and prev.dot(q) < 0.0:
            q.negate()
        _last_q[name] = q.copy()
        pb.rotation_quaternion = q
        pb.keyframe_insert("rotation_quaternion", frame=frame)
    # Üst kol boyuna esnemesi (yalnız uçuşta 1'den farklı); her animasyonda anahtarlanır ki
    # başka animasyona geçince kol eski boyuna dönsün.
    for name in ("upper_arm.L", "upper_arm.R"):
        pb = rig.pose.bones[name]
        pb.scale = (1.0, pose.get("_arm_stretch", 1.0), 1.0)
        pb.keyframe_insert("scale", frame=frame)
    hips = rig.pose.bones["hips"]
    hips.location = hips_rest.inverted() @ Vector((0.0, 0.0, pose.get("_hips_dz", 0.0)))
    hips.keyframe_insert("location", frame=frame)


def _make(name: str, frames: list[int], pose_at) -> None:
    old = bpy.data.actions.get(name)
    if old:
        bpy.data.actions.remove(old)
    act = bpy.data.actions.new(name)
    act.use_fake_user = True
    rig.animation_data.action = act
    _last_q.clear()
    for f in frames:
        _apply(pose_at(f), f)
    act.frame_start = frames[0]
    act.frame_end = frames[-1]
    act.use_frame_range = True


def build() -> None:
    bpy.context.scene.render.fps = FPS
    if rig.animation_data is None:
        rig.animation_data_create()
    for tr in list(rig.animation_data.nla_tracks):
        rig.animation_data.nla_tracks.remove(tr)

    _make("idle", list(range(0, 61, 3)), lambda f: pose_idle(f / 60.0))
    _make("run", list(range(0, 17)), lambda f: pose_run(f / 16.0))
    _make("jump", [0, 2, 5, 8],
          lambda f: _blend(JUMP_START, JUMP_POSE, _smooth(f / 5.0)))
    _make("fall", list(range(0, 21, 2)), lambda f: pose_fall(f / 20.0))
    land_k = {0: 1.0, 2: 0.92, 4: 0.6, 6: 0.25, 8: -0.06, 10: 0.0}
    _make("land", list(land_k), lambda f: pose_land(land_k[f]))
    _make("tuck", [0, 10], lambda f: TUCK_POSE)
    _make("flap", list(range(0, 17)), lambda f: pose_flap(f / 16.0))
    _make("star", [0, 10], lambda f: STAR_POSE)
    _make("fly", list(range(0, 13)), lambda f: pose_fly(f / 12.0))
    _make("back_tuck", [0, 2, 4, 6, 8, 12],
          lambda f: _blend(BACK_ARCH_POSE, BACK_TUCK_POSE, _smooth((f - 1.0) / 6.0)))
    _make("twist", [0, 2, 4, 6, 10],
          lambda f: _blend(TWIST_OPEN_POSE, TWIST_POSE, _smooth(f / 5.0)))

    # Dışa aktarım için her action bir NLA şeridine konur.
    rig.animation_data.action = None
    for name in ("idle", "run", "jump", "fall", "land", "tuck", "flap", "star", "fly",
                 "back_tuck", "twist"):
        act = bpy.data.actions[name]
        track = rig.animation_data.nla_tracks.new()
        track.name = name
        track.strips.new(name, int(act.frame_start), act)
        track.mute = True
    print("animasyonlar:", [a.name for a in bpy.data.actions])


build()
