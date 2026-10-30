"""Build deterministic native visual-perception fixtures; packages stay local."""
from pathlib import Path
import importlib.util
import zipfile
import struct
import argparse
import shutil
ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
OUT = ROOT / "build/issue425"
spec = importlib.util.spec_from_file_location("prior_fixture", ROOT / "assets/validation_597/prepare.py")
prior = importlib.util.module_from_spec(spec)
spec.loader.exec_module(prior)
def room():
    source=prior.wad(True)
    count,offset=struct.unpack_from("<ii",source,4)
    entries=[struct.unpack_from("<ii8s",source,offset+i*16) for i in range(count)]
    text=source[entries[1][0]:entries[1][0]+entries[1][1]]
    text+=b"""
vertex{x=512;y=512;} vertex{x=576;y=512;}
vertex{x=576;y=1024;} vertex{x=512;y=1024;}
linedef{v1=4;v2=5;sidefront=0;blocking=true;}
linedef{v1=5;v2=6;sidefront=0;blocking=true;}
linedef{v1=6;v2=7;sidefront=0;blocking=true;}
linedef{v1=7;v2=4;sidefront=0;blocking=true;}
"""
    lumps=[("MAP01",b""),("TEXTMAP",text),("ENDMAP",b"")]
    body=bytearray();directory=bytearray()
    for name,data in lumps:
        directory+=struct.pack("<ii8s",12+len(body),len(data),name.encode());body+=data
    return struct.pack("<4sii",b"PWAD",len(lumps),12+len(body))+body+directory

def main():
    parser=argparse.ArgumentParser()
    parser.add_argument("--legacy-package",type=Path)
    args=parser.parse_args()
    (OUT / "current").mkdir(parents=True, exist_ok=True)
    members = {"ZSCRIPT": b'version "4.14"\n#include "checks.zs"\n',
        "checks.zs": (HERE / "checks.zs").read_bytes(), "maps/CA425A.wad": room(),
        "MAPINFO": b'GameInfo { AddEventHandlers="CA425Checks" }\nmap CA425A "Visual perception checks" { }\n'}
    with zipfile.ZipFile(OUT / "current/checks.pk3", "w", zipfile.ZIP_STORED) as archive:
        for name, data in sorted(members.items()):
            archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), data)
    if args.legacy_package:
        (OUT / "legacy").mkdir(exist_ok=True)
        target=OUT / "legacy/caelum_argenteum_dev.pk3"
        if not target.exists():shutil.copy2(args.legacy_package,target)
        legacy=(HERE / "legacy.zs").read_bytes()
        old=dict(members);old["checks.zs"]=legacy
        with zipfile.ZipFile(OUT / "legacy/checks.pk3","w",zipfile.ZIP_STORED) as archive:
            for name,data in sorted(old.items()):
                archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
    print("Prepared #425 native fixture.")
if __name__ == "__main__":
    main()
