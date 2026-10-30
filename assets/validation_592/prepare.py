"""Build deterministic native fixtures for #419; keep generated packages local."""
from pathlib import Path
import hashlib
import json
import shutil
import struct
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
OUT = ROOT / "build/issue419"


def wad():
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
    lumps = [("MAP01", b""), ("TEXTMAP", text), ("ENDMAP", b"")]
    body = bytearray(); directory = bytearray()
    for name, data in lumps:
        directory += struct.pack("<ii8s", 12 + len(body), len(data), name.encode())
        body += data
    return struct.pack("<4sii", b"PWAD", len(lumps), 12 + len(body)) + body + directory


def package(path, script):
    members = {"ZSCRIPT": b'version "4.14"\n#include "checks.zs"\n',
               "checks.zs": script.encode(), "maps/CA419A.wad": wad(), "maps/CA419B.wad": wad(),
               "MAPINFO": b'''GameInfo { AddEventHandlers="CA419Checks" }
cluster 592 { hub }
map CA419A "Private social dialogue A" { cluster=592 next=CA419B }
map CA419B "Private social dialogue B" { cluster=592 next=CA419A }
'''}
    with zipfile.ZipFile(path, "w", zipfile.ZIP_STORED) as archive:
        for name, data in sorted(members.items()):
            archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), data)


def main():
    for name in ("current", "legacy"):
        (OUT / name).mkdir(parents=True, exist_ok=True)
    source = (HERE / "checks.zs").read_text(encoding="utf-8")
    package(OUT / "current/checks.pk3", source)
    # Same class/schema for native save loading; old code never references new APIs.
    legacy = "class CA419Checks : EventHandler\n{\n    int Failures, Checks;\n"
    legacy += "    CaelumAnchoredResident Representative;\n"
    legacy += source[source.index("    void Check"):source.index("    void Rules")]
    legacy += '''    override void NetworkProcess(ConsoleEvent e) {
        let u=CaelumPlayer(players[e.Player].mo); if(u==null)return;
        if(e.Name=="ca419_seed")Seed(u);
        if(e.Name=="ca419_open")Open(u);
        if(e.Name=="ca419_done")Console.Printf("CA419 RESULT checks=%d failures=%d",Checks,Failures);
    }
}
'''
    package(OUT / "legacy/checks.pk3", legacy)
    baseline = ROOT.parent / "issue420-work/build/issue420/current/caelum_argenteum_dev.pk3"
    target = OUT / "legacy/caelum_argenteum_dev.pk3"
    if not target.exists():
        shutil.copy2(baseline, target)
    manifest = {p.relative_to(OUT).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest()
                for p in OUT.glob("*/*.pk3")}
    (OUT / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print("Prepared #419 fixtures and preserved baseline.")


if __name__ == "__main__":
    main()
