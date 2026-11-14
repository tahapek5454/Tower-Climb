# Karakterin şapkalarını kodla modeller ve assets/models/accessories.glb'ye dışa aktarır (Blender içinde).
# Kullanım: assets/models/source/eagle_hero.blend açıkken (dosya kaydedilmez, sahne temiz bırakılır)
#   exec(open(r"<repo>/tools/blender/accessories.py", encoding="utf-8").read()); run(r"<repo>")
# Yalnız kurup bakmak için: build() → (look) → cleanup().
#
# Her şapka kimliğiyle (ShopCatalog: hat_cap …) aynı adlı ayrı bir nesnedir. Orijin kafa kemiğinin başında
# (model uzayı 0, 0, 0.66); şapka nesnesinin dönüşü hafif geriye eğimdir. Godot (CharacterModel) şapkayı
# `head` kemiğine bağlar ve glb'deki dönüşümü olduğu gibi kullanır.
# Hareketli parçalar şapkanın çocuğudur: adı "_spin" ile biten yerel dikey ekseninde döner (pervane),
# "_sway" ile biten kendi orijini etrafında sallanır (ponpon, püskül).
# Eksenler (Blender): karakter -Y'ye bakar, +Z yukarı, +X karakterin solu.
# Renkler malzeme taban rengidir (sRGB yazılır); Godot toon_flat + dış çizgiyle çizer.
import math

import bmesh
import bpy
from mathutils import Matrix, Vector

COLLECTION = "Accessories"
HEAD_ORIGIN = Vector((0.0, 0.0, 0.66))
# Kafanın tepe kubbesi (şapka yerel uzayı): taban halkası z, ön-arka merkezi y.
BASE_Z = 0.285
CENTER_Y = 0.03
# Şapkalar biraz geriye yatık (derece; karakter -Y'ye baktığı için +X ekseninde eksi).
TILT_BACK = 8.0
SEGMENTS = 20

COLORS = {
    "cap": (0.36, 0.52, 0.70), "cap_visor": (0.28, 0.40, 0.56), "cream": (0.94, 0.90, 0.82),
    "beanie": (0.80, 0.50, 0.38), "beanie_cuff": (0.70, 0.42, 0.33),
    "party_a": (0.86, 0.52, 0.62), "party_b": (0.96, 0.90, 0.78), "party_pom": (0.96, 0.80, 0.40),
    "straw": (0.90, 0.78, 0.48), "straw_band": (0.72, 0.36, 0.33),
    "fez": (0.58, 0.20, 0.25), "tassel": (0.14, 0.13, 0.15),
    "cowboy": (0.58, 0.40, 0.26), "cowboy_band": (0.33, 0.23, 0.16),
    "prop_red": (0.84, 0.42, 0.40), "prop_yellow": (0.94, 0.80, 0.42), "prop_blue": (0.40, 0.58, 0.80),
    "prop_green": (0.46, 0.70, 0.50), "prop_blade": (0.88, 0.88, 0.86), "prop_hub": (0.36, 0.38, 0.44),
    "top": (0.22, 0.22, 0.27), "top_band": (0.62, 0.30, 0.34),
    "santa": (0.80, 0.24, 0.24), "fur": (0.96, 0.95, 0.92),
    "gold": (0.95, 0.76, 0.32), "gem_red": (0.80, 0.25, 0.30), "gem_teal": (0.30, 0.70, 0.72),
}


def _srgb_to_linear(c: float) -> float:
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def _material(key: str) -> bpy.types.Material:
    name = "acc_" + key
    mat = bpy.data.materials.get(name)
    if mat is None:
        mat = bpy.data.materials.new(name)
        mat.use_nodes = True
    rgb = COLORS[key]
    bsdf = next(n for n in mat.node_tree.nodes if n.type == "BSDF_PRINCIPLED")
    bsdf.inputs[0].default_value = (*[_srgb_to_linear(v) for v in rgb], 1.0)
    bsdf.inputs["Roughness"].default_value = 0.8
    mat.diffuse_color = (*rgb, 1.0)
    return mat


class Part:
    """Tek nesnenin geometrisi: dönel profillerden (lathe) parçalar, her biri bir malzemeyle."""

    def __init__(self):
        self.bm = bmesh.new()
        self.keys: list[str] = []

    def _mat_index(self, key: str) -> int:
        if key not in self.keys:
            self.keys.append(key)
        return self.keys.index(key)

    def lathe(self, profile, key, at=(0, 0, 0), scale=(1, 1, 1), rot=None, segments=SEGMENTS,
              closed=False, deform=None, key_fn=None, radial=None):
        """profile: (yarıçap, z) noktaları alttan üste. deform(x, y, z) → (x, y, z) yerel biçimlendirme.
        radial(açı) → yarıçap çarpanı (örgü dişi, yıldız). key_fn(açı) → yüzün malzeme anahtarı."""
        bm = self.bm
        rot = rot or Matrix.Identity(3)
        offset = Vector(at)
        angles = [2.0 * math.pi * i / segments for i in range(segments)]
        rings = []
        for r, z in profile:
            if r < 1e-6:
                p = Vector((0.0, 0.0, z * scale[2]))
                rings.append([bm.verts.new(offset + rot @ p)])
                continue
            ring = []
            for a in angles:
                rr = r * (radial(a) if radial else 1.0)
                x, y, zz = rr * math.cos(a) * scale[0], rr * math.sin(a) * scale[1], z * scale[2]
                if deform:
                    x, y, zz = deform(x, y, zz)
                ring.append(bm.verts.new(offset + rot @ Vector((x, y, zz))))
            rings.append(ring)
        pairs = list(zip(rings[:-1], rings[1:]))
        if closed:
            pairs.append((rings[-1], rings[0]))
        default = self._mat_index(key)
        for low, high in pairs:
            for i in range(segments):
                j = (i + 1) % segments
                if len(low) == 1:
                    verts = (low[0], high[i], high[j])
                elif len(high) == 1:
                    verts = (low[i], low[j], high[0])
                else:
                    verts = (low[i], low[j], high[j], high[i])
                face = bm.faces.new(verts)
                face.smooth = True
                face.material_index = self._mat_index(key_fn(angles[i] + math.pi / segments)) \
                    if key_fn else default
        if not closed:
            for ring in (rings[0], rings[-1]):
                if len(ring) > 2:
                    face = bm.faces.new(ring)
                    face.smooth = True
                    face.material_index = default
        return self

    def sphere(self, radius, key, at=(0, 0, 0), scale=(1, 1, 1), rot=None, segments=12):
        steps = max(segments // 2, 4)
        profile = [(radius * math.sin(math.pi * i / steps), -radius * math.cos(math.pi * i / steps))
                   for i in range(steps + 1)]
        profile[0] = (0.0, -radius)
        profile[-1] = (0.0, radius)
        return self.lathe(profile, key, at, scale, rot, segments)

    def to_object(self, name: str, parent=None, location=(0, 0, 0), rotation=(0, 0, 0)):
        bm = self.bm
        bmesh.ops.remove_doubles(bm, verts=bm.verts, dist=1e-6)
        bmesh.ops.recalc_face_normals(bm, faces=bm.faces)
        for edge in bm.edges:
            if edge.is_manifold and edge.calc_face_angle(0.0) > math.radians(55.0):
                edge.smooth = False
        mesh = bpy.data.meshes.new(name)
        bm.to_mesh(mesh)
        bm.free()
        for key in self.keys:
            mesh.materials.append(_material(key))
        obj = bpy.data.objects.new(name, mesh)
        obj.location = location
        obj.rotation_euler = rotation
        if parent is not None:
            obj.parent = parent
        bpy.data.collections[COLLECTION].objects.link(obj)
        return obj


def _rot_x(deg):
    return Matrix.Rotation(math.radians(deg), 3, "X")


def _rot_y(deg):
    return Matrix.Rotation(math.radians(deg), 3, "Y")


def _dome(radius, height, z0, steps=6, inner=0.0):
    """Tabanı z0'da, yüksekliği height olan yarım elipsoit profili (alttan üste)."""
    pts = []
    for i in range(steps + 1):
        a = 0.5 * math.pi * i / steps
        pts.append((radius * math.cos(a), z0 + height * math.sin(a)))
    pts[-1] = (0.0, z0 + height)
    if inner > 0.0:
        pts.insert(0, (radius - inner, z0 - 0.004))
    return pts


def _brim(radius, z, thickness, lip=0.0):
    """Yuvarlak kenarlı yassı disk (şapka siperi / kenarı)."""
    t = thickness
    return [(0.0, z), (radius - t, z), (radius, z + t * 0.5 + lip), (radius - t, z + t), (0.0, z + t)]


def _hat(name):
    return Part(), name


def _finish(part, name):
    rotation = (math.radians(-TILT_BACK), 0.0, 0.0)
    return part.to_object(name, location=HEAD_ORIGIN, rotation=rotation)


C = (0.0, CENTER_Y, 0.0)


def hat_cap():
    p, n = _hat("hat_cap")
    p.lathe(_dome(0.218, 0.17, BASE_Z, inner=0.01), "cap", at=C, scale=(1, 0.9, 1))
    # Siper: önde (-Y) yarım ay, hafif aşağı eğik.
    visor = [(0.0, 0.0), (0.15, 0.0), (0.165, 0.008), (0.15, 0.018), (0.0, 0.018)]
    p.lathe(visor, "cap_visor", at=(0.0, CENTER_Y - 0.13, BASE_Z + 0.02), scale=(1.15, 1.0, 1.0),
            rot=_rot_x(12), deform=lambda x, y, z: (x, min(y, 0.03), z))
    p.sphere(0.03, "cream", at=(0.0, CENTER_Y, BASE_Z + 0.165), scale=(1, 1, 0.6))
    return _finish(p, n)


def hat_beanie():
    p, n = _hat("hat_beanie")
    rib = lambda a: 1.0 + 0.035 * math.cos(a * 14)  # noqa: E731 — örgü dişleri
    p.lathe(_dome(0.212, 0.21, BASE_Z + 0.03, steps=7), "beanie", at=C, scale=(1, 0.9, 1), radial=rib,
            segments=28)
    cuff = [(0.205, BASE_Z - 0.035), (0.232, BASE_Z - 0.03), (0.236, BASE_Z + 0.02), (0.228, BASE_Z + 0.06),
            (0.205, BASE_Z + 0.065)]
    p.lathe(cuff, "beanie_cuff", at=C, scale=(1, 0.9, 1), radial=rib, segments=28, closed=False)
    p.sphere(0.075, "cream", at=(0.0, CENTER_Y, BASE_Z + 0.27), segments=14,
             scale=(1.0, 1.0, 0.9))
    return _finish(p, n)


def hat_party():
    p, n = _hat("hat_party")
    height = 0.40
    base = BASE_Z + 0.03
    bands = 4
    rot = _rot_y(-12)
    at = (0.03, CENTER_Y, 0.0)
    for i in range(bands):
        z0 = height * i / bands
        z1 = height * (i + 1) / bands
        r0 = 0.17 * (1.0 - z0 / height)
        r1 = 0.17 * (1.0 - z1 / height)
        prof = [(r0, base + z0), (r1, base + z1)]
        if i == bands - 1:
            prof = [(r0, base + z0), (0.0, base + z1)]
        p.lathe(prof, "party_a" if i % 2 == 0 else "party_b", at=at, rot=rot)
    # Alt kenar fırfırı + uçta ponpon.
    frill = [(0.15, base - 0.02), (0.195, base + 0.0), (0.185, base + 0.035), (0.14, base + 0.035)]
    p.lathe(frill, "party_b", at=at, rot=rot, closed=True, radial=lambda a: 1.0 + 0.08 * math.cos(a * 10),
            segments=30)
    tip = rot @ Vector((0.0, 0.0, base + height))
    p.sphere(0.058, "party_pom", at=Vector(at) + tip)
    return _finish(p, n)


def hat_straw():
    p, n = _hat("hat_straw")
    p.lathe(_brim(0.37, BASE_Z + 0.035, 0.022, lip=0.01), "straw", at=C, scale=(1, 0.92, 1),
            deform=lambda x, y, z: (x, y, z - 0.10 * (x * x + y * y)))
    crown = [(0.0, BASE_Z), (0.19, BASE_Z), (0.188, BASE_Z + 0.09), (0.16, BASE_Z + 0.135),
             (0.0, BASE_Z + 0.145)]
    p.lathe(crown, "straw", at=C, scale=(1, 0.92, 1))
    band = [(0.193, BASE_Z + 0.04), (0.195, BASE_Z + 0.085)]
    p.lathe(band, "straw_band", at=C, scale=(1, 0.92, 1), closed=False)
    return _finish(p, n)


def hat_fez():
    p, n = _hat("hat_fez")
    body = [(0.0, BASE_Z + 0.03), (0.17, BASE_Z + 0.03), (0.14, BASE_Z + 0.25), (0.0, BASE_Z + 0.255)]
    p.lathe(body, "fez", at=C)
    p.sphere(0.024, "tassel", at=(0.0, CENTER_Y, BASE_Z + 0.255), scale=(1, 1, 0.6))
    hat = _finish(p, n)
    # Püskül: tepeden arkaya sarkan ip + püskül; orijin tepede, sallanır.
    t = Part()
    t.lathe([(0.011, 0.0), (0.011, 0.175)], "tassel", rot=_rot_x(-96), segments=8)
    end = _rot_x(-96) @ Vector((0.0, 0.0, 0.175))
    t.lathe([(0.0, 0.0), (0.016, -0.012), (0.04, -0.11), (0.0, -0.118)], "tassel", at=end, segments=10)
    t.to_object("hat_fez_sway", parent=hat, location=(0.0, CENTER_Y, BASE_Z + 0.255))
    return hat


def hat_cowboy():
    p, n = _hat("hat_cowboy")
    # Kenar: yanlar yukarı kıvrık, ön/arka hafif aşağı.
    p.lathe(_brim(0.345, BASE_Z + 0.04, 0.022), "cowboy", at=C, scale=(1, 0.88, 1),
            deform=lambda x, y, z: (x, y, z + 0.85 * max(abs(x) - 0.17, 0.0) ** 2 * 4.0 - 0.06 * y * y * 4))
    crown = [(0.0, BASE_Z), (0.175, BASE_Z), (0.172, BASE_Z + 0.12), (0.15, BASE_Z + 0.175),
             (0.06, BASE_Z + 0.16), (0.0, BASE_Z + 0.14)]
    p.lathe(crown, "cowboy", at=C, scale=(1, 0.86, 1),
            deform=lambda x, y, z: (x * (1.0 - 0.18 * max(z - BASE_Z - 0.12, 0) / 0.06), y, z))
    band = [(0.179, BASE_Z + 0.045), (0.177, BASE_Z + 0.085)]
    p.lathe(band, "cowboy_band", at=C, scale=(1, 0.86, 1), closed=False)
    return _finish(p, n)


def hat_propeller():
    p, n = _hat("hat_propeller")
    panels = ["prop_red", "prop_yellow", "prop_blue", "prop_green"]
    p.lathe(_dome(0.214, 0.175, BASE_Z, inner=0.01), "prop_red", at=C, scale=(1, 0.9, 1), segments=24,
            key_fn=lambda a: panels[int(a / (math.pi * 0.5)) % 4])
    p.lathe([(0.012, BASE_Z + 0.16), (0.012, BASE_Z + 0.23)], "prop_hub", at=C, segments=8)
    hat = _finish(p, n)
    spin = Part()
    blade = (0.13, 0.018, 0.012)
    for side in (-1.0, 1.0):
        spin.sphere(1.0, "prop_blade", at=(side * 0.1, 0.0, 0.0), scale=(blade[0] * 0.75, blade[1] * 2.0,
                    blade[2]), rot=Matrix.Rotation(math.radians(side * 14), 3, "X"))
    spin.sphere(0.03, "prop_hub", scale=(1, 1, 0.8))
    spin.to_object("hat_propeller_spin", parent=hat, location=(0.0, CENTER_Y, BASE_Z + 0.235))
    return hat


def hat_top():
    p, n = _hat("hat_top")
    p.lathe(_brim(0.26, BASE_Z + 0.06, 0.02), "top", at=C, scale=(1, 0.88, 1),
            deform=lambda x, y, z: (x, y, z + 0.5 * max(abs(x) - 0.14, 0.0) ** 2 * 4.0))
    body = [(0.0, BASE_Z + 0.04), (0.155, BASE_Z + 0.04), (0.148, BASE_Z + 0.20), (0.165, BASE_Z + 0.33),
            (0.0, BASE_Z + 0.335)]
    p.lathe(body, "top", at=C, scale=(1, 0.88, 1))
    band = [(0.156, BASE_Z + 0.08), (0.152, BASE_Z + 0.14)]
    p.lathe(band, "top_band", at=C, scale=(1, 0.88, 1), closed=False)
    return _finish(p, n)


def hat_santa():
    p, n = _hat("hat_santa")
    # Kafa tüyleri aşağı doğru genişler: şapka kafadan belirgin geniş olmalı, kürk bandı kalın bir simit
    # gibi kafayı sarmalı (dar olunca tüyler bandın altından taşıyor ve şapka kafaya gömülü görünüyor).
    base = BASE_Z + 0.01
    ring, tube = 0.232, 0.058
    fur = [(ring + tube * math.cos(2.0 * math.pi * i / 8), tube * math.sin(2.0 * math.pi * i / 8))
           for i in range(8)]
    p.lathe(fur, "fur", at=(0.0, CENTER_Y, base - 0.02), scale=(1, 0.92, 1), closed=True, segments=24)
    # Gövde simidin iç yamacından çıkar (yüzeyler çakışmasın: kırmızı ile beyaz iç içe geçmesin) ve
    # yükseldikçe geriye yatar. Döndürme yok: taban düz kalır, arkada bandın içine batmaz.
    lean = lambda x, y, z: (x, y + 1.6 * max(z - base, 0.0) ** 2, z)  # noqa: E731
    body = [(0.0, base - 0.03), (0.205, base - 0.03), (0.205, base + 0.02), (0.185, base + 0.10),
            (0.135, base + 0.20), (0.075, base + 0.265), (0.0, base + 0.27)]
    p.lathe(body, "santa", at=C, scale=(1, 0.92, 1), deform=lean)
    hat = _finish(p, n)
    # Sarkan uç + ponpon: orijin gövdenin tepesinde, geriye ve aşağı sarkar; sallanır.
    tip = Part()
    rot = _rot_x(-125)
    tip.lathe([(0.075, -0.03), (0.062, 0.07), (0.035, 0.19), (0.0, 0.20)], "santa", rot=rot)
    end = rot @ Vector((0.0, 0.0, 0.20))
    tip.sphere(0.075, "fur", at=end, segments=14)
    top_z = base + 0.245
    tip.to_object("hat_santa_sway", parent=hat, location=(0.0, CENTER_Y + 1.6 * 0.245 ** 2, top_z))
    return hat


def hat_crown():
    p, n = _hat("hat_crown")
    z = BASE_Z + 0.06
    band = [(0.0, z), (0.165, z), (0.167, z + 0.075), (0.145, z + 0.075), (0.145, z + 0.01), (0.0, z + 0.01)]
    p.lathe(band, "gold", at=C, segments=24)
    points = 5
    for i in range(points):
        a = 2.0 * math.pi * i / points + math.pi * 0.5
        x, y = 0.155 * math.cos(a), CENTER_Y + 0.155 * math.sin(a)
        p.lathe([(0.045, 0.0), (0.0, 0.10)], "gold", at=(x, y, z + 0.07), segments=6)
        p.sphere(0.024, "gold", at=(x, y, z + 0.175), segments=10)
        # Bantta taş: dışa doğru basık küre.
        gx, gy = 0.167 * math.cos(a), CENTER_Y + 0.167 * math.sin(a)
        p.sphere(0.022, "gem_red" if i % 2 == 0 else "gem_teal", at=(gx, gy, z + 0.035), segments=10,
                 scale=(1, 1, 1))
    return _finish(p, n)


HATS = [hat_cap, hat_beanie, hat_party, hat_straw, hat_fez, hat_cowboy, hat_propeller, hat_top, hat_santa,
        hat_crown]


def cleanup() -> None:
    coll = bpy.data.collections.get(COLLECTION)
    if coll is not None:
        for obj in list(coll.objects):
            mesh = obj.data
            bpy.data.objects.remove(obj)
            if mesh is not None and mesh.users == 0:
                bpy.data.meshes.remove(mesh)
        bpy.data.collections.remove(coll)
    for mat in list(bpy.data.materials):
        if mat.name.startswith("acc_") and mat.users == 0:
            bpy.data.materials.remove(mat)


def build(spread: float = 0.0) -> list:
    """Şapkaları kurar. spread > 0: bakmak için yan yana dizer (dışa aktarımda 0 olmalı)."""
    cleanup()
    coll = bpy.data.collections.new(COLLECTION)
    bpy.context.scene.collection.children.link(coll)
    hats = [make() for make in HATS]
    if spread > 0.0:
        for i, hat in enumerate(hats):
            hat.location.x += (i - (len(hats) - 1) * 0.5) * spread
    return hats


def export(path: str) -> None:
    coll = bpy.data.collections[COLLECTION]
    for obj in bpy.context.view_layer.objects:
        obj.select_set(obj.name in coll.objects)
    bpy.ops.export_scene.gltf(filepath=path, export_format="GLB", use_selection=True, export_apply=True,
                              export_yup=True, export_animations=False, export_skins=False,
                              export_materials="EXPORT", export_normals=True, export_texcoords=False)


def run(repo: str) -> None:
    selected = [o.name for o in bpy.context.selected_objects]
    active = bpy.context.view_layer.objects.active
    build()
    export(repo + "/assets/models/accessories.glb")
    cleanup()
    for obj in bpy.context.view_layer.objects:
        obj.select_set(obj.name in selected)
    bpy.context.view_layer.objects.active = active
    print("accessories.glb:", len(HATS), "hats")
