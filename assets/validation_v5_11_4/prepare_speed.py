"""Build a wide private room to measure native companion displacement."""
from pathlib import Path
import struct
import zipfile

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "build/issue430"
OUT.mkdir(parents=True, exist_ok=True)
text = '''namespace="ZDoom";
vertex{x=-4096;y=-1024;} vertex{x=4096;y=-1024;}
vertex{x=4096;y=1024;} vertex{x=-4096;y=1024;}
sector{heightfloor=0;heightceiling=512;texturefloor="FLOOR4_8";textureceiling="CEIL3_5";lightlevel=192;}
sidedef{sector=0;texturemiddle="STARTAN3";}
linedef{v1=1;v2=0;sidefront=0;blocking=true;}
linedef{v1=2;v2=1;sidefront=0;blocking=true;}
linedef{v1=3;v2=2;sidefront=0;blocking=true;}
linedef{v1=0;v2=3;sidefront=0;blocking=true;}
thing{x=0;y=0;type=1;skill1=true;skill2=true;skill3=true;skill4=true;skill5=true;single=true;coop=true;}
'''.encode()
body = bytearray()
directory = bytearray()
for name, data in (("MAP02", b""), ("TEXTMAP", text), ("ENDMAP", b"")):
    directory += struct.pack("<ii8s", 12 + len(body), len(data), name.encode())
    body += data
wad = struct.pack("<4sii", b"PWAD", 3, 12 + len(body)) + body + directory
files = {"ZSCRIPT": b'version "4.14"\n#include "speed_checks.zs"\n',
         "speed_checks.zs": Path(__file__).with_name("speed_checks.zs").read_bytes(),
         "maps/MAP02.wad": wad,
         "MAPINFO": b'GameInfo { AddEventHandlers="CA430SpeedChecks" }\n'}
with zipfile.ZipFile(OUT / "speed.pk3", "w") as archive:
    for name, data in sorted(files.items()):
        archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), data)
with zipfile.ZipFile(OUT / "pair.pk3", "w") as archive:
    for name, data in {"ZSCRIPT": b'version "4.14"\n#include "pair_checks.zs"\n',
                       "pair_checks.zs": Path(__file__).with_name("pair_checks.zs").read_bytes(),
                       "MAPINFO": b'GameInfo { AddEventHandlers="CA430PairChecks" }\n'}.items():
        archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), data)
