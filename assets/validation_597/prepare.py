"""Build deterministic native fixtures for #423; keep generated packages local."""
from pathlib import Path
import hashlib
import json
import shutil
import struct
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
OUT = ROOT / "build/issue423"


def wad(large=False):
    text = '''namespace="ZDoom";
vertex{x=-512;y=-512;} vertex{x=512;y=-512;}
vertex{x=512;y=512;} vertex{x=-512;y=512;}
sector{heightfloor=0;heightceiling=256;texturefloor="FLOOR4_8";textureceiling="CEIL3_5";lightlevel=192;}
sidedef{sector=0;texturemiddle="STARTAN3";}
linedef{v1=1;v2=0;sidefront=0;blocking=true;}
linedef{v1=2;v2=1;sidefront=0;blocking=true;}
linedef{v1=3;v2=2;sidefront=0;blocking=true;}
linedef{v1=0;v2=3;sidefront=0;blocking=true;}
thing{x=0;y=0;type=1;skill1=true;skill2=true;skill3=true;skill4=true;skill5=true;single=true;coop=true;}
'''.encode()
    if large:text=text.replace(b"512",b"2048")
    lumps = [("MAP01", b""), ("TEXTMAP", text), ("ENDMAP", b"")]
    body = bytearray(); directory = bytearray()
    for name, data in lumps:
        directory += struct.pack("<ii8s", 12 + len(body), len(data), name.encode())
        body += data
    return struct.pack("<4sii", b"PWAD", len(lumps), 12 + len(body)) + body + directory


def package(path, script):
    members = {"ZSCRIPT": b'version "4.14"\n#include "checks.zs"\n',
               "checks.zs": script.encode(), "maps/CA423A.wad": wad(), "maps/CA423B.wad": wad(), "maps/CA423P.wad": wad(True),
               "MAPINFO": b'''GameInfo { AddEventHandlers="CA423Checks" }
map CA423P "600 peaceful guards" { }
cluster 597 { hub }
map CA423A "Port wardrobe gallery" { cluster=597 next=CA423B }
map CA423B "Private social dialogue B" { cluster=597 next=CA423A }
'''}
    with zipfile.ZipFile(path, "w", zipfile.ZIP_STORED) as archive:
        for name, data in sorted(members.items()):
            archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), data)


def main():
    for name in ("current", "legacy"):
        (OUT / name).mkdir(parents=True, exist_ok=True)
    source = (HERE / "checks.zs").read_text(encoding="utf-8")
    package(OUT / "current/checks.pk3", source)
    with zipfile.ZipFile(OUT / "current/city-checks.pk3", "w", zipfile.ZIP_STORED) as archive:
        for name,data in {"ZSCRIPT":b'version "4.14"\n#include "checks.zs"\n',"checks.zs":source.encode(),"MAPINFO":b'GameInfo { AddEventHandlers="CA423Checks" }\n'}.items():
            archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)

    legacy = source[:source.index("    void Visual")]
    legacy += ''.join([]) + "    override void NetworkProcess(ConsoleEvent e) { let u=CaelumPlayer(players[e.Player].mo); if(u==null)return; if(e.Name==\"ca423_seed\")Seed(u); if(e.Name==\"ca423_population\")Population(u); if(e.Name==\"ca423_pitch\")u.Pitch=e.Args[0]; if(e.Name==\"ca423_done\")Console.Printf(\"CA423 RESULT checks=%d failures=%d\",Checks,Failures); }\n}\n"
    package(OUT / "legacy/checks.pk3", legacy)
    baseline = ROOT / "build/issue424/current/caelum_argenteum_dev.pk3"
    target = OUT / "legacy/caelum_argenteum_dev.pk3"
    if not target.exists():
        shutil.copy2(baseline, target)
    manifest = {p.relative_to(OUT).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest()
                for p in OUT.glob("*/*.pk3")}
    (OUT / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print("Prepared #423 fixtures and preserved baseline.")


if __name__ == "__main__":
    main()
