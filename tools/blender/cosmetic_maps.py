# Kıyafet boyama için iki doku üretir (Blender içinde çalıştırılır; sahneyi ve dosyayı değiştirmez):
#   eagle_hero_cosmetic_mask.png  R = tişört bölgesi, G = pantolon bölgesi (yumuşak kenarlı)
#   eagle_hero_rest_position.png  RGB = dinlenme pozundaki model uzayı konumu (desenler için;
#                                 dikişte kırılmaz, animasyonda kaymaz)
# İkisi de EagleHero'nun mevcut UV'sini kullanır; eagle_hero.glb'yi yeniden dışa aktarmak gerekmez.
# Kullanım: assets/models/source/eagle_hero.blend açıkken
#   exec(open(r"<repo>/tools/blender/cosmetic_maps.py", encoding="utf-8").read()); build(r"<repo>")
#
# Konum kodlaması (Blender ekseni → doku kanalı): R = (x - POS_MIN.x) / POS_SIZE.x, G = y, B = z.
# Godot tarafındaki karşılığı CosmeticPaint.POS_MIN / POS_SIZE (aynı sayılar).
import bpy
import numpy as np

MESH_NAME = "EagleHero"
SIZE = 1024
POS_MIN = (-0.40, -0.32, -0.02)
POS_SIZE = (0.80, 0.64, 1.12)
# Boş piksellere doğru taşırma (doku filtrelemesinde ada kenarı dışarıdan renk almasın).
MARGIN_PX = 6

# Bölgeler (model uzayı, metre). Tişört: göğüs/karın + kısa kollar; pantolon: kalça–baldır.
SHIRT_Z = (0.385, 0.70)
SHIRT_LUM = (0.20, 0.46)
PANTS_Z = (0.085, 0.41)
PANTS_MAX_LUM = 0.20
# Bacakların yarı genişliği (sarkan eller bunun dışında kalır).
PANTS_HALF_X = 0.18


def _raster(me):
    me.calc_loop_triangles()
    uv_layer = me.uv_layers.active.data
    count = len(me.loop_triangles)
    tri_loops = np.zeros(count * 3, dtype=np.int32)
    me.loop_triangles.foreach_get("loops", tri_loops)
    tri_verts = np.zeros(count * 3, dtype=np.int32)
    me.loop_triangles.foreach_get("vertices", tri_verts)
    uvs = np.zeros(len(uv_layer) * 2, dtype=np.float64)
    uv_layer.foreach_get("uv", uvs)
    uvs = uvs.reshape(-1, 2)[tri_loops].reshape(count, 3, 2) * SIZE
    cos = np.zeros(len(me.vertices) * 3, dtype=np.float64)
    me.vertices.foreach_get("co", cos)
    cos = cos.reshape(-1, 3)[tri_verts].reshape(count, 3, 3)

    pos = np.zeros((SIZE, SIZE, 3), dtype=np.float64)
    filled = np.zeros((SIZE, SIZE), dtype=bool)
    for t in range(count):
        a, b, c = uvs[t]
        x0 = max(int(np.floor(min(a[0], b[0], c[0]))) - 1, 0)
        x1 = min(int(np.ceil(max(a[0], b[0], c[0]))) + 1, SIZE - 1)
        y0 = max(int(np.floor(min(a[1], b[1], c[1]))) - 1, 0)
        y1 = min(int(np.ceil(max(a[1], b[1], c[1]))) + 1, SIZE - 1)
        den = (b[1] - c[1]) * (a[0] - c[0]) + (c[0] - b[0]) * (a[1] - c[1])
        if abs(den) < 1e-12:
            continue
        xs, ys = np.meshgrid(np.arange(x0, x1 + 1) + 0.5, np.arange(y0, y1 + 1) + 0.5)
        w0 = ((b[1] - c[1]) * (xs - c[0]) + (c[0] - b[0]) * (ys - c[1])) / den
        w1 = ((c[1] - a[1]) * (xs - c[0]) + (a[0] - c[0]) * (ys - c[1])) / den
        w2 = 1.0 - w0 - w1
        eps = -0.02
        inside = (w0 >= eps) & (w1 >= eps) & (w2 >= eps)
        if not inside.any():
            continue
        p = w0[..., None] * cos[t, 0] + w1[..., None] * cos[t, 1] + w2[..., None] * cos[t, 2]
        iy, ix = np.nonzero(inside)
        pos[iy + y0, ix + x0] = p[iy, ix]
        filled[iy + y0, ix + x0] = True
    return pos, filled


def _dilate(values, filled, steps):
    values = values.copy()
    filled = filled.copy()
    for _i in range(steps):
        acc = np.zeros_like(values)
        hits = np.zeros(filled.shape, dtype=np.float64)
        for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            f = np.roll(filled, (dy, dx), axis=(0, 1))
            v = np.roll(values, (dy, dx), axis=(0, 1))
            acc += v * f[..., None]
            hits += f
        grow = (~filled) & (hits > 0)
        values[grow] = acc[grow] / hits[grow][:, None]
        filled = filled | grow
    return values


def _albedo(me):
    image = None
    for node in me.materials[0].node_tree.nodes:
        if node.type == "TEX_IMAGE":
            image = node.image
    w, h = image.size[0], image.size[1]
    px = np.zeros(w * h * 4, dtype=np.float32)
    image.pixels.foreach_get(px)
    px = px.reshape(h, w, 4)[..., :3]
    if w != SIZE:
        ys = (np.arange(SIZE) * h // SIZE)
        xs = (np.arange(SIZE) * w // SIZE)
        px = px[ys][:, xs]
    return px


def _smooth(mask, passes):
    for _i in range(passes):
        mask = (mask * 4 + np.roll(mask, 1, 0) + np.roll(mask, -1, 0) + np.roll(mask, 1, 1)
                + np.roll(mask, -1, 1)) / 8.0
    return mask


def _ramp(value, lo, hi):
    return np.clip((value - lo) / (hi - lo), 0.0, 1.0)


def _regions(pos, albedo, filled):
    """Bölgeler renkten ve konumdan çıkar: tişört dokuda tek açık kurşuni-mavi tondur (Blender piksel değeri, doğrusal: ~0,30),
    pantolon ve kol tüyleri koyu (~0,13) → pantolon konumla (kalça–baldır, gövde genişliği) ayrılır.
    Beyaz kafa/kuyruk ve turuncu ayak/gaga renkleriyle dışarıda kalır."""
    x, z = pos[..., 0], pos[..., 2]
    lum = albedo.mean(axis=2)
    sat = albedo.max(axis=2) - albedo.min(axis=2)
    grey = 1.0 - _ramp(sat, 0.09, 0.14)
    shirt_tone = _ramp(lum, SHIRT_LUM[0] - 0.03, SHIRT_LUM[0]) * (1.0 - _ramp(lum, SHIRT_LUM[1], SHIRT_LUM[1] + 0.05))
    shirt = grey * shirt_tone * _ramp(z, SHIRT_Z[0] - 0.01, SHIRT_Z[0] + 0.01) \
        * (1.0 - _ramp(z, SHIRT_Z[1] - 0.01, SHIRT_Z[1] + 0.01))
    dark = 1.0 - _ramp(lum, PANTS_MAX_LUM - 0.03, PANTS_MAX_LUM + 0.02)
    legs = 1.0 - _ramp(np.abs(x), PANTS_HALF_X - 0.01, PANTS_HALF_X + 0.01)
    pants = grey * dark * legs * _ramp(z, PANTS_Z[0] - 0.01, PANTS_Z[0] + 0.01) \
        * (1.0 - _ramp(z, PANTS_Z[1] - 0.01, PANTS_Z[1] + 0.01))
    return shirt * filled, pants * filled


def _save(name, rgb, path):
    h, w = rgb.shape[:2]
    image = bpy.data.images.new(name, w, h, alpha=False, float_buffer=False)
    image.colorspace_settings.name = "Non-Color"
    rgba = np.ones((h, w, 4), dtype=np.float32)
    rgba[..., :3] = np.clip(rgb, 0.0, 1.0)
    image.pixels.foreach_set(rgba.ravel())
    image.filepath_raw = path
    image.file_format = "PNG"
    image.save()
    bpy.data.images.remove(image)


def build(repo: str) -> None:
    me = bpy.data.objects[MESH_NAME].data
    pos, filled = _raster(me)
    albedo = _albedo(me)
    shirt, pants = _regions(pos, albedo, filled)
    shirt = _smooth(shirt, 1) * filled
    pants = _smooth(pants, 1) * filled
    mask = np.stack([shirt, pants, np.zeros_like(shirt)], axis=2)
    mask = _dilate(mask, filled, MARGIN_PX)
    norm = (pos - np.array(POS_MIN)) / np.array(POS_SIZE)
    norm = _dilate(norm, filled, MARGIN_PX)
    _save("cosmetic_mask_tmp", mask, repo + "/assets/models/eagle_hero_cosmetic_mask.png")
    _save("rest_position_tmp", norm, repo + "/assets/models/eagle_hero_rest_position.png")
    print("cosmetic maps:", int(filled.sum()), "px;",
          "shirt", round(float(shirt.sum())), "pants", round(float(pants.sum())))
