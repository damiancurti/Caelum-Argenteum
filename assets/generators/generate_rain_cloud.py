"""Generate an original normalized rain-cloud volume for #251 and future weather.

Python standard library only. Marching tetrahedra joins the density lobes into
one closed shell, avoiding translucent internal sphere intersections. Art-space
dimensions and the isolated preview settings are not gameplay balance values.
"""
from __future__ import annotations

import hashlib
import json
import math
from pathlib import Path
import struct
import zlib

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / "assets/rain_cloud/DESIGN.json"
TETRAHEDRA = [(0, 5, 1, 6), (0, 1, 2, 6), (0, 2, 3, 6),
              (0, 3, 7, 6), (0, 7, 4, 6), (0, 4, 5, 6)]
EDGES = [(0, 1), (0, 2), (0, 3), (1, 2), (1, 3), (2, 3)]


def sub(a, b):
    return tuple(x-y for x, y in zip(a, b))


def dot(a, b):
    return sum(x*y for x, y in zip(a, b))


def cross(a, b):
    return (a[1]*b[2]-a[2]*b[1], a[2]*b[0]-a[0]*b[2], a[0]*b[1]-a[1]*b[0])


def normal(a):
    length = math.sqrt(dot(a, a))
    if length < 1e-12:
        raise ValueError("Degenerate cloud normal")
    return tuple(x/length for x in a)


def png_chunk(kind, payload):
    return struct.pack(">I", len(payload))+kind+payload+struct.pack(">I", zlib.crc32(kind+payload))


def palette_png(data):
    count = data["samples"]
    rows = bytearray()
    for i in range(count):
        # OBJ v=1 samples the top of the texture.
        fraction = 1-i/(count-1)
        color = [round(a+(b-a)*fraction) for a, b in zip(data["low"], data["high"])]
        rows.extend([0, *color, 255])
    return (b"\x89PNG\r\n\x1a\n" + png_chunk(b"IHDR", struct.pack(">IIBBBBB", 1, count, 8, 6, 0, 0, 0))
            + png_chunk(b"IDAT", zlib.compress(bytes(rows), 9))+png_chunk(b"IEND", b""))


def generate(data):
    sharpness = 2*data["density_shape_power"]
    def density(point):
        total = 0.0
        for lobe in data["lobes"]:
            q = sum(((p-c)/r)**2 for p, c, r in zip(point, lobe["center"], lobe["radii"]))
            total += math.exp(-sharpness*q)
        return total-data["density_threshold"]**data["density_shape_power"]

    def outward(point):
        gradient = [0.0]*3
        for lobe in data["lobes"]:
            d = sub(point, lobe["center"])
            radii = lobe["radii"]
            weight = math.exp(-sharpness*sum((v/r)**2 for v, r in zip(d, radii)))
            for i in range(3):
                gradient[i] += 2*sharpness*d[i]/radii[i]**2*weight
        return normal(gradient)

    nx, ny, nz = data["grid"]
    low, high = data["bounds"]
    points = [(low[0]+(high[0]-low[0])*x/nx,
               low[1]+(high[1]-low[1])*y/ny,
               low[2]+(high[2]-low[2])*z/nz)
              for z in range(nz+1) for y in range(ny+1) for x in range(nx+1)]
    values = [density(p) for p in points]
    stride = nx+1
    layer = stride*(ny+1)
    vertices, faces, cache = [], [], {}

    def crossing(a, b):
        key = tuple(sorted((a, b)))
        if key not in cache:
            t = values[a]/(values[a]-values[b])
            cache[key] = len(vertices)
            vertices.append(tuple(x+(y-x)*t for x, y in zip(points[a], points[b])))
        return cache[key]

    for z in range(nz):
        for y in range(ny):
            for x in range(nx):
                base = x+stride*y+layer*z
                cube = [base, base+1, base+stride+1, base+stride,
                        base+layer, base+layer+1, base+layer+stride+1, base+layer+stride]
                if all(values[i] >= 0 for i in cube) or all(values[i] < 0 for i in cube):
                    continue
                for corners in TETRAHEDRA:
                    tet = [cube[i] for i in corners]
                    poly = [crossing(tet[a], tet[b]) for a, b in EDGES
                            if (values[tet[a]] >= 0) != (values[tet[b]] >= 0)]
                    if not poly:
                        continue
                    center = tuple(sum(vertices[i][k] for i in poly)/len(poly) for k in range(3))
                    n = outward(center)
                    u = normal(sub(vertices[poly[0]], center))
                    v = cross(n, u)
                    poly.sort(key=lambda i: math.atan2(dot(sub(vertices[i], center), v), dot(sub(vertices[i], center), u)))
                    for i in range(1, len(poly)-1):
                        face = (poly[0], poly[i], poly[i+1])
                        a, b, c = [vertices[j] for j in face]
                        if dot(cross(sub(b, a), sub(c, a)), n) < 0:
                            face = tuple(reversed(face))
                        faces.append(face)

    # The source grid fully encloses one manifold volume. No open edges or
    # overlapping internal sphere shells are acceptable for this material.
    edge_counts = {}
    for face in faces:
        for a, b in zip(face, face[1:]+face[:1]):
            key = tuple(sorted((a, b)))
            edge_counts[key] = edge_counts.get(key, 0)+1
    if set(edge_counts.values()) != {2}:
        raise ValueError("Cloud shell is not closed")
    if len(vertices)-len(edge_counts)+len(faces) != 2:
        raise ValueError("Cloud shell must not contain handles or internal cavities")
    bounds = [(min(p[i] for p in vertices), max(p[i] for p in vertices)) for i in range(3)]
    factor = 2/(bounds[0][1]-bounds[0][0])
    center = ((bounds[0][0]+bounds[0][1])/2, bounds[1][0], (bounds[2][0]+bounds[2][1])/2)
    normals = [outward(p) for p in vertices]
    light = normal((-0.35, 0.85, 0.4))
    shades = []
    for p, n in zip(vertices, normals):
        height = (p[1]-bounds[1][0])/(bounds[1][1]-bounds[1][0])
        softness = 0.055*math.sin(11*p[0]+4*p[2])*math.cos(9*p[2]-5*p[1])
        shades.append(min(0.98, max(0.02, 0.16+0.45*height+0.30*max(0, dot(n, light))+softness)))
    vertices = [tuple((p[i]-center[i])*factor for i in range(3)) for p in vertices]
    lines = ["# Original Caelum Argenteum rain cloud, issue #251.",
             "# Normalized art mesh; X width 2, Y up/base 0, Z depth. No collision/size rule.",
             "# Source: assets/rain_cloud/DESIGN.json; generator: generate_rain_cloud.py.",
             "o caelum_rain_cloud", "s 1"]
    lines += ["v "+" ".join(f"{x:.8f}" for x in p) for p in vertices]
    lines += [f"vt 0.50000000 {s:.8f}" for s in shades]
    lines += ["vn "+" ".join(f"{x:.8f}" for x in n) for n in normals]
    lines += [f'usemtl {data["runtime_directory"]}/{data["texture"]}']
    lines += ["f "+" ".join(f"{i+1}/{i+1}/{i+1}" for i in face) for face in faces]
    stats = {"vertices": len(vertices), "triangles": len(faces), "closed_edges": len(edge_counts),
             "bounds": [[min(p[i] for p in vertices), max(p[i] for p in vertices)] for i in range(3)]}
    return ("\n".join(lines)+"\n").encode(), stats


def main():
    data = json.loads(SOURCE.read_text(encoding="utf-8"))
    model, stats = generate(data)
    output = ROOT / "src" / data["runtime_directory"]
    output.mkdir(parents=True, exist_ok=True)
    hashes = {}
    for name, payload in [(data["model"], model), (data["texture"], palette_png(data["palette"]))]:
        (output/name).write_bytes(payload)
        hashes[name] = hashlib.sha256(payload).hexdigest()
    material = data["material"]
    shader = '''// Generado desde assets/rain_cloud/DESIGN.json; sin reloj ni estado de juego.
// Atenuar el contorno y excluir caras posteriores de la nube translúcida.
void SetupMaterial(inout Material material)
{
    SetMaterialProps(material, vTexCoord.st);
    vec3 outward = normalize(vWorldNormal.xyz);
    vec3 toEye = normalize(uCameraPos.xyz - pixelpos.xyz);
    float facing = max(0.0, dot(outward, toEye));
    material.Base.a *= step(0.0001, facing) * mix(EDGE_OPACITY, 1.0, smoothstep(0.0, FADE_END, facing));
}
'''.replace("EDGE_OPACITY",str(material["edge_opacity"])).replace("FADE_END",str(material["facing_fade_end"]))
    shader_path = ROOT/"src/shaders/caelum/rain_cloud.fp"
    shader_path.parent.mkdir(parents=True,exist_ok=True)
    shader_path.write_bytes(shader.encode("utf-8"))
    hashes["rain_cloud.fp"] = hashlib.sha256(shader_path.read_bytes()).hexdigest()
    manifest = {"issue": 251, "source_sha256": hashlib.sha256(SOURCE.read_bytes()).hexdigest(),
                "generator_sha256": hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                "geometry": stats, "outputs": hashes}
    (SOURCE.parent/"manifest.json").write_text(json.dumps(manifest, indent=2)+"\n", encoding="utf-8", newline="\n")
    print(json.dumps(manifest, indent=2))


if __name__ == "__main__":
    main()
