"""Package the #251 cloud asset in an isolated original preview room."""
import argparse
import importlib.util
import json
from pathlib import Path
import struct
import zlib

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location("package541", HERE.parent / "validation_541/prepare.py")
shared = importlib.util.module_from_spec(spec)
spec.loader.exec_module(shared)
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--directory", required=True)
args = parser.parse_args()
if not args.directory or any(c not in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_" for c in args.directory):
    parser.error("Use a plain directory name.")
out = ROOT / "build" / args.directory
out.mkdir(exist_ok=False)
design = json.loads((ROOT / "assets/rain_cloud/DESIGN.json").read_text())

def chunk(kind, data):
    return struct.pack(">I", len(data))+kind+data+struct.pack(">I", zlib.crc32(kind+data))

rows = bytearray()
for y in range(64):
    rows.append(0)
    for x in range(64):
        v = 125 if (x//16+y//16)%2 else 162
        rows.extend((v,v,v,255))
checker = (b"\x89PNG\r\n\x1a\n"+chunk(b"IHDR", struct.pack(">IIBBBBB",64,64,8,6,0,0,0))
           +chunk(b"IDAT",zlib.compress(bytes(rows),9))+chunk(b"IEND",b""))
# Clockwise box; all art and geometry in this preview room are original.
parts = ['namespace="zdoom";', 'thing { x=0; y=0; angle=0; type=1; skill1=true; skill2=true; skill3=true; skill4=true; skill5=true; single=true; }',
         'sector { heightfloor=0; heightceiling=512; texturefloor="C251TEST"; textureceiling="C251TEST"; lightlevel=224; }']
for x,y in [(-512,-512),(-512,512),(512,512),(512,-512)]:
    parts.append(f'vertex {{ x={x}; y={y}; }}')
for i in range(4):
    parts += ['sidedef { sector=0; texturemiddle="C251TEST"; }',
              f'linedef {{ v1={i}; v2={(i+1)%4}; sidefront={i}; blocking=true; }}']
lumps = [("MAP02",b""),("TEXTMAP","\n".join(parts).encode()),("ENDMAP",b"")]
body,directory = bytearray(),bytearray()
for name,payload in lumps:
    directory.extend(struct.pack('<II8s',12+len(body),len(payload),name.encode()))
    body.extend(payload)
wad = struct.pack('<4sII',b'PWAD',len(lumps),12+len(body))+body+directory
fixture = {
    "ZSCRIPT": b'version "4.14"\n#include "probe.zs"\n',
    "probe.zs": (HERE / "probe.zs").read_bytes().replace(b'Alpha 0.64;',f'Alpha {design["preview"]["alpha"]};'.encode()),
    "MODELDEF": (f'Model CA251CloudPreview {{ Path "{design["runtime_directory"]}" Model 0 "{design["model"]}" '
                 f'Scale {design["preview"]["scale"]} {design["preview"]["scale"]} {design["preview"]["scale"]} CorrectPixelStretch ForceCullBackFaces FrameIndex CARK A 0 0 }}\n').encode(),
    "MAPINFO": b'GameInfo { AddEventHandlers="CA251CloudProbe" }\n',
    "maps/MAP02.wad": wad,
    "textures/C251TEST.png": checker,
}
manifest = {"production_sha256": shared.package(out/"production.pk3", {
    p.relative_to(ROOT/"src").as_posix():p.read_bytes() for p in (ROOT/"src").rglob("*") if p.is_file()}),
    "fixture_sha256": shared.package(out/"probe.pk3",fixture)}
steps = ["con_notifytime 0","wait 100","netevent c251_setup","wait 25"]
for angle,height,pitch,name in [(0,0,0,"front"),(90,0,0,"side"),(180,0,0,"back"),(270,0,0,"other-side"),(0,116,30,"above"),(0,0,-12,"below")]:
    steps += [f"netevent c251_view {angle} {height} {pitch}","wait 8",f"screenshot cloud-{name}.png"]
steps += ["netevent c251_done","wait 5","quit"]
(out/"preview.cfg").write_text("; ".join(steps)+"\n",encoding="utf-8")
(out/"manifest.json").write_text(json.dumps(manifest,indent=2)+"\n",encoding="utf-8")
print(json.dumps(manifest))
