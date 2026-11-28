"""Compare the exported scalp and helmet roof using vertical rays in neutral model space."""
from pathlib import Path
import json
import sys

import numpy as np

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "assets/generators"))
from character_mesh_frames import read_model


def crown_masks(material):
    # The wearable exporter preserves face order per source MD3 surface.
    # Match its neutral inventory faces to the separately named metal bowl in the OBJ.
    source = ROOT / "assets/source/art/inventory_models_647/armor_helmets/editable" / (material+".obj")
    vertices = []
    triangles = set()
    group = None
    for line in source.read_text("utf8").splitlines():
        fields = line.split()
        if not fields:
            continue
        if fields[0] == "v":
            x, z, neg_y = map(float, fields[1:4])
            vertices.append(tuple(round(v*64) for v in (x, -neg_y, z)))
        elif fields[0] == "g":
            group = fields[1]
        elif fields[0] == "f" and group == "hollow_crown":
            triangles.add(tuple(sorted(vertices[int(i.split("/")[0])-1] for i in fields[1:])))
    raw = ROOT / "src/models/caelum/inventory/armor_helmets" / (material+".md3")
    masks = []
    for mesh in read_model(raw.read_bytes()):
        quantized = np.rint(64*mesh.positions[0]).astype(int).tolist()
        masks.append(np.array([tuple(sorted(tuple(quantized[index]) for index in face)) in triangles
                               for face in mesh.faces]))
    assert sum(int(m.sum()) for m in masks) == len(triangles) > 0
    return masks


def roof(path, xy, masks=None):
    meshes = read_model(path.read_bytes())
    tris = np.concatenate([m.positions[0, m.faces if masks is None else m.faces[masks[i]], :]
                           for i, m in enumerate(meshes)]).astype("float64")
    origin = tris[:, 0]
    a = tris[:, 1] - origin
    b = tris[:, 2] - origin
    determinant = a[:, 0]*b[:, 1] - a[:, 1]*b[:, 0]
    ok = np.abs(determinant) > 1e-8
    origin, a, b, determinant = origin[ok], a[ok], b[ok], determinant[ok]
    result = np.full(len(xy), -np.inf)
    for start in range(0, len(xy), 32):
        points = xy[start:start+32]
        x = points[:, 0:1] - origin[:, 0]
        y = points[:, 1:2] - origin[:, 1]
        u = (x*b[:, 1]-y*b[:, 0]) / determinant
        v = (a[:, 0]*y-a[:, 1]*x) / determinant
        z = origin[:, 2] + u*a[:, 2] + v*b[:, 2]
        z[(u < 0) | (v < 0) | (u+v > 1)] = -np.inf
        result[start:start+len(points)] = z.max(axis=1)
    return result


def check():
    players = ROOT / "src/models/caelum/players"
    axis = np.arange(-25, 26, 1.5)
    xy = np.stack(np.meshgrid(axis+0.17, axis+0.29), axis=-1).reshape(-1, 2)
    minimum = float("inf")
    count = 0
    masks = [crown_masks(name) for name in ("magic", "light", "medium", "heavy")]
    for family in range(7):
        roofs = [roof(players/"gear"/(f"a0_{material}"+(f"_f{family}" if family else "")+".md3"), xy, masks[material])
                 for material in range(4)]
        for identity in (family*2, family*2+1):
            # Include all faces and all haircuts; the highest visible surface
            # at each ray bounds every possible face and hairstyle pairing.
            faces = sorted(players.glob(f"head{identity}_*.md3"))
            hair = sorted(players.glob(f"hair{identity}_*.md3"))
            scalp = np.max([roof(path, xy) for path in faces+hair], axis=0)
            # The check covers the upper skull. Faces, lower hair and the visor
            # openings are intentionally visible below this transverse plane.
            crown = scalp >= (np.max(scalp) - 11)
            for material, surface in enumerate(roofs):
                clearance = (surface[crown] - scalp[crown]).min()
                if clearance <= 0:
                    raise ValueError(f"Helmet intersects crown: body {identity}, material {material}, {clearance:.3f}")
                minimum = min(minimum, clearance)
                count += int(crown.sum())
    return {"body_material_pairs": 56, "upper_skull_rays": count,
            "minimum_roof_clearance_model_units": round(float(minimum), 3)}


if __name__ == "__main__":
    print(json.dumps(check()))
