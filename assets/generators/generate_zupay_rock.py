"""Export a deterministic cosmetic boulder using the unchanged owned Zupay texture."""
from pathlib import Path
import hashlib
import json
import math

ROOT = Path(__file__).resolve().parents[2]
DESIGN = ROOT / "assets/source/art/zupay_rock_5424/DESIGN.json"
BEGIN, END = "// BEGIN ZUPAY ROCK #284", "// END ZUPAY ROCK #284"

def main():
    data = json.loads(DESIGN.read_text(encoding="utf-8"))
    reference = ROOT / data["reference"]["path"]
    if hashlib.sha256(reference.read_bytes()).hexdigest() != data["reference"]["sha256"]:
        raise SystemExit("Reference hash mismatch; review provenance before exporting.")
    dimensions = data["dimensions_map_units"]
    half = [dimensions[key]/2 for key in ("depth", "height", "width")]
    segments, rings = data["segments"], data["rings"]
    points, normals = [], []
    # OBJ Y is up. Irregularity is analytic, with no random/global seed.
    for row in range(rings + 1):
        latitude = -math.pi/2 + row*math.pi/rings
        for column in range(segments):
            longitude = column*math.tau/segments + (row % 2)*math.pi/segments
            unit = (math.cos(latitude)*math.cos(longitude), math.sin(latitude), math.cos(latitude)*math.sin(longitude))
            radius = 1+data["irregularity"]*math.sin(3*longitude+row)*math.cos(latitude)
            points.append(tuple(unit[i]*half[i]*radius for i in range(3)))
            normals.append(unit)
    faces = []
    for row in range(rings):
        for column in range(segments):
            a = row*segments+column
            b = row*segments+(column+1) % segments
            c, d = a+segments, b+segments
            if row > 0:
                faces.append((a, c, b))
            if row < rings-1:
                faces.append((b, c, d))
    lines = ["# Original Caelum Argenteum #284; editable data: "+DESIGN.relative_to(ROOT).as_posix(), "o zupay_rock"]
    lines += ["v %.6f %.6f %.6f" % point for point in points]
    cx, cy = data["uv_center_pixels"]
    rx, ry = data["uv_half_extent_pixels"]
    width, height = data["texture_size"]
    face_uvs = []
    for face in faces:
        a, b, c = (points[index] for index in face)
        u = [b[i]-a[i] for i in range(3)]
        v = [c[i]-a[i] for i in range(3)]
        normal = (u[1]*v[2]-u[2]*v[1], u[2]*v[0]-u[0]*v[2], u[0]*v[1]-u[1]*v[0])
        dominant = max(range(3), key=lambda i: abs(normal[i]))
        horizontal, vertical = (2, 1) if dominant == 0 else (0, 2) if dominant == 1 else (0, 1)
        indexes = []
        for index in face:
            point = points[index]
            pu, pv = point[horizontal]/half[horizontal], point[vertical]/half[vertical]
            lines.append("vt %.8f %.8f" % ((cx+rx*pu)/width, 1-(cy-ry*pv)/height))
            indexes.append(len(face_uvs)*3+len(indexes)+1)
        face_uvs.append(indexes)
    lines += ["s off", "usemtl "+data["material"]]
    lines += ["f "+" ".join(f"{index+1}/{uv}" for index, uv in zip(face, uvs))
              for face, uvs in zip(faces, face_uvs)]
    output = ROOT / "src/models/caelum/projectiles/ca_zupay_rock.obj"
    output.write_text("\n".join(lines)+"\n", encoding="utf-8", newline="\n")
    model = '\n'.join([BEGIN, 'Model CaelumActorExplosiveElementalProjectile', '{',
        ' Path "models/caelum/projectiles"', ' Model 0 "ca_zupay_rock.obj"',
        ' Scale 1 1 1', ' CorrectPixelStretch', ' PitchFromMomentum',
        ' FrameIndex ZROK A 0 0', '}', END])
    path = ROOT / "src/MODELDEF"
    text = path.read_text(encoding="utf-8")
    if BEGIN in text:
        text = text[:text.index(BEGIN)] + model + text[text.index(END)+len(END):]
    else:
        text += "\n"+model+"\n"
    path.write_text(text, encoding="utf-8")
    x, y, w, h = data["fallback_crop"]
    scale = data["fallback_scale"]
    fallback = f'Sprite "ZROKA0", {w}, {h} {{ XScale {scale} YScale {scale} Offset {w//2}, {h//2} Patch "{data["material"]}", {-x}, {-y} }}\n'
    (ROOT / "src/graphics/caelum/zupay_rock.textures").write_text(fallback, encoding="utf-8")
    print(json.dumps({"vertices": len(points), "triangles": len(faces), "obj_sha256": hashlib.sha256(output.read_bytes()).hexdigest()}))

if __name__ == "__main__":
    main()
