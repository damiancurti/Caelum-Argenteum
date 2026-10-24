"""Build a deterministic, private #414 native water feasibility fixture."""
from pathlib import Path
import json
import struct
import zipfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
OUT = ROOT / "build/issue414"
DATA = json.loads((HERE / "fixture.json").read_text(encoding="utf-8"))


def wad(text, name):
    payload = bytearray()
    directory = bytearray()
    for key, value in [(name, b""), ("TEXTMAP", text.encode()), ("ENDMAP", b"")]:
        directory += struct.pack("<ii8s", 12 + len(payload), len(value), key.encode().ljust(8, b"\0"))
        payload += value
    return struct.pack("<4sii", b"PWAD", 3, 12 + len(payload)) + payload + directory


def room():
    vertices, sides, lines, sectors, edges = [], [], [], [], {}
    vertex_ids = {}

    def vertex(point):
        if point not in vertex_ids:
            vertex_ids[point] = len(vertices)
            vertices.append(dict(x=point[0], y=point[1]))
        return vertex_ids[point]

    def rectangle(x, y, size, sector, volume=None):
        points = [(x, y), (x, y + size), (x + size, y + size), (x + size, y)]
        for i, (a, b) in enumerate(zip(points, points[1:] + points[:1])):
            side = len(sides)
            sides.append(dict(sector=sector, texturemiddle="CMST01", texturetop="CMST01", texturebottom="CMST01"))
            key = tuple(sorted((a, b)))
            if key in edges:
                line = lines[edges[key]]
                line.update(sideback=side, twosided=True)
                line.pop("blocking", None)
                sides[line["sidefront"]]["texturemiddle"] = "-"
                sides[side]["texturemiddle"] = "-"
                if key == ((256, 0), (256, 256)):
                    line.update(id=DATA["gate_line_id"], blocking=True, blocksight=True)
                    sides[line["sidefront"]]["texturemiddle"] = "CMST01"
                    sides[side]["texturemiddle"] = "CMST01"
            else:
                line = dict(v1=vertex(a), v2=vertex(b), sidefront=side, blocking=True)
                if volume is not None and i == 0:
                    line.update(special=160, arg0=volume, arg1=2, arg2=0, arg3=128)
                edges[key] = len(lines)
                lines.append(line)

    for item in DATA["volumes"]:
        sector = len(sectors)
        sectors.append(dict(id=item["id"], heightfloor=0, heightceiling=DATA["ceiling_units"],
                            texturefloor="CMST02", textureceiling="CMST02", lightlevel=208))
        rectangle(*(v * DATA["cell_units"] for v in item["cell"]), DATA["cell_units"], sector)
    # The dry observation walkway is outside the water targets.
    dry = len(sectors)
    sectors.append(dict(heightfloor=192, heightceiling=384, texturefloor="CMST01", textureceiling="CMST02", lightlevel=224))
    rectangle(0, 256, 256, dry)
    rectangle(256, 256, 256, dry)
    for i, item in enumerate(DATA["volumes"]):
        sector = len(sectors)
        sectors.append(dict(heightfloor=0, heightceiling=item["height"], texturefloor="FWATER1", textureceiling="FWATER1",
                            lightlevel=176, user_ca414_id=item["id"], user_ca_water_quality=item["quality"],
                            user_ca_potable_water=1 if item["quality"] == 0 else 0))
        rectangle(-1024 + i * 128, -1024, 64, sector, item["id"])
    def block(kind, row):
        def value(v):
            if isinstance(v, str):
                return json.dumps(v)
            if isinstance(v, bool):
                return str(v).lower()
            return str(v)
        return kind + " { " + " ".join(f"{k}={value(v)};" for k, v in row.items()) + " }"
    result = ['namespace="ZDoom";']
    for kind, collection in [("vertex", vertices), ("sidedef", sides), ("linedef", lines), ("sector", sectors)]:
        result.extend(block(kind, row) for row in collection)
    result.append('thing { x=128; y=320; angle=270; type=1; skill1=true; skill2=true; skill3=true; skill4=true; skill5=true; single=true; coop=true; dm=true; }')
    return "\n".join(result) + "\n"


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    data = "class CA414Data : Object {\n"
    data += f'const STEP = {DATA["surface_step_per_tic"]};\nconst AREA = {DATA["cell_units"] ** 2}.0;\n'
    data += f'const GATE = {DATA["gate_line_id"]};\n}}\n'
    members = {
        "ZSCRIPT": b'version "4.14"\n#include "data.zs"\n#include "checks.zs"\n',
        "data.zs": data.encode(),
        "checks.zs": (HERE / "checks.zs").read_bytes(),
        "MAPINFO": b'GameInfo { AddEventHandlers="CA414Checks" }\ncluster 8414 { hub }\nmap CAW414 "Connected water feasibility" { cluster=8414 }\nmap CAW414B "Return checkpoint" { cluster=8414 }\n',
        "maps/CAW414.wad": wad(room(), "CAW414"),
        "maps/CAW414B.wad": wad(room(), "CAW414B"),
    }
    with zipfile.ZipFile(OUT / "checks.pk3", "w", zipfile.ZIP_STORED) as archive:
        for name, content in sorted(members.items()):
            archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), content)
    scripts = {
        "suite": "wait 35; netevent ca414_initial; netevent ca414_open; wait 20; netevent ca414_partial; netevent ca414_close; wait 10; netevent ca414_stopped; netevent ca414_open; wait 100; netevent ca414_final; netevent ca414_left; wait 5; netevent ca414_wet; netevent ca414_dry; wait 5; netevent ca414_drycheck; wait 5; quit",
        "save": "wait 35; netevent ca414_open; wait 20; netevent ca414_close; netevent ca414_partial; wait 5; save ca414-partial; wait 5; quit",
        "load": "wait 5; netevent ca414_partial; netevent ca414_stopped; netevent ca414_open; wait 100; netevent ca414_final; save ca414-final; wait 5; quit",
        "hub": "wait 5; netevent ca414_final; wait 5; changemap CAW414B; wait 35; netevent ca414_initial; wait 5; changemap CAW414; wait 35; netevent ca414_final; wait 5; quit",
        "flow-save": "wait 35; netevent ca414_open; wait 20; netevent ca414_partial; wait 2; save ca414-flow; wait 5; quit",
        "flow-load": "wait 5; netevent ca414_partial; wait 100; netevent ca414_final; wait 5; quit",
        "capture": 'r_drawplayersprites false; wait 35; netevent ca414_initial; netevent ca414_view; wait 10; screenshot "levels-before.png"; netevent ca414_open; wait 100; netevent ca414_final; wait 10; screenshot "levels-after.png"; wait 5; quit',
        "interactive": 'exec ../../assets/playtest/default_controls.cfg\nlanguage es\nbind F1 "netevent ca414_open"\nbind F2 "netevent ca414_close"\nbind F3 "netevent ca414_left"\nbind F4 "netevent ca414_right"\nbind F5 "netevent ca414_dry"\nbind F6 "netevent ca414_report"\nbind F7 "netevent ca414_view"\nwait 35; netevent ca414_initial; netevent ca414_view; netevent ca414_help; toggleconsole',
    }
    # Loading must not assert initial levels or reposition the saved character.
    scripts["resume"] = scripts["interactive"].replace(
        'netevent ca414_initial; netevent ca414_view;', 'netevent ca414_report;')
    for name, text in scripts.items():
        (OUT / f"{name}.cfg").write_text(text + "\n", encoding="utf-8", newline="\n")
    print("Prepared private #414 geometry, controls and save/hub checks.")


if __name__ == "__main__":
    main()
