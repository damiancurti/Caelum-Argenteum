"""Deterministic private altitude fixture; reuses #414's WAD serializer."""
from pathlib import Path
import importlib.util
import zipfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
OUT = ROOT / "build/issue413"
spec = importlib.util.spec_from_file_location("water_fixture", HERE.parent / "validation_580/prepare.py")
water = importlib.util.module_from_spec(spec)
spec.loader.exec_module(water)


def room():
    text = ['namespace="ZDoom";']
    for index, height in enumerate((0, 0, 0)):
        x = index * 1024
        for vx, vy in ((x, 0), (x, 512), (x+512, 512), (x+512, 0)):
            text.append(f'vertex {{ x={vx}; y={vy}; }}')
        for side in range(4):
            text.append(f'sidedef {{ sector={index}; texturemiddle="CMST01"; }}')
            text.append(f'linedef {{ v1={index*4+side}; v2={index*4+(side+1)%4}; sidefront={index*4+side}; blocking=true; }}')
        text.append(f'sector {{ heightfloor={height}; heightceiling={height+512}; texturefloor="CMST02"; textureceiling="CMST02"; lightlevel=208; }}')
    text.append('thing { x=256; y=256; type=1; angle=90; skill1=true; skill2=true; skill3=true; skill4=true; skill5=true; single=true; coop=true; dm=true; }')
    return '\n'.join(text)+'\n'


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    common = {
        "MAPINFO": b'GameInfo { AddEventHandlers="CA413Checks" }\ncluster 8413 { hub }\nmap CAA413 "Altitude laboratory" { cluster=8413 }\nmap CAA413B "Altitude hub checkpoint" { cluster=8413 }\n',
        "maps/CAA413.wad": water.wad(room(), "CAA413"),
        "maps/CAA413B.wad": water.wad(room(), "CAA413B"),
        "ZSCRIPT": b'version "4.14"\n#include "checks.zs"\n',
    }
    for filename, source in (("checks.pk3", "checks.zs"), ("legacy-checks.pk3", "legacy.zs")):
        if not (HERE/source).exists():
            continue
        members = dict(common, **{"checks.zs": (HERE/source).read_bytes()})
        with zipfile.ZipFile(OUT/filename, "w", zipfile.ZIP_STORED) as archive:
            for name, content in sorted(members.items()):
                archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), content)
    with zipfile.ZipFile(OUT/"performance.pk3", "w", zipfile.ZIP_STORED) as archive:
        for name, content in sorted({"ZSCRIPT": b'version "4.14"\n'+(HERE/"performance.zs").read_bytes(), "MAPINFO": b'GameInfo { AddEventHandlers="CA413Performance" }\n'}.items()):
            archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), content)
    bridge = OUT/"bridge"
    bridge.mkdir(exist_ok=True)
    (bridge/"legacy-checks.pk3").write_bytes((OUT/"checks.pk3").read_bytes())
    scripts = {
        "suite": "wait 35; netevent ca413_suite; wait 5; quit",
        "save": "wait 35; netevent ca413_seed; wait 5; save ca413-adapted-v3; wait 5; quit",
        "load": "wait 5; netevent ca413_loaded; wait 5; quit",
        "hub": "wait 5; netevent ca413_loaded; changemap CAA413B; wait 35; netevent ca413_loaded; changemap CAA413; wait 35; netevent ca413_loaded; wait 5; quit",
        "legacy-save": "wait 35; netevent ca413_legacy; wait 5; save ca413-legacy; wait 5; quit",
        "migrate": "wait 5; netevent ca413_migrate; save ca413-migrated; wait 5; quit",
        "rollback": "wait 5; netevent ca413_legacy; wait 5; quit",
        "interactive": 'exec ../../assets/playtest/default_controls.cfg\nlanguage es\nbind F1 "netevent ca413_sea"\nbind F2 "netevent ca413_mid"\nbind F3 "netevent ca413_high"\nbind F4 "netevent ca413_adapt"\nbind F5 "netevent ca413_spend"\nbind F6 "netevent ca413_report"\nbind F7 "netevent ca413_race"\nwait 35; netevent ca413_prepare; netevent ca413_help; toggleconsole',
    }
    scripts["resume"] = scripts["interactive"].replace('netevent ca413_prepare;', 'netevent ca413_report;')
    for name, text in scripts.items():
        (OUT/f"{name}.cfg").write_text(text+'\n', encoding="utf-8", newline="\n")
    print("Prepared #413 altitude, save, migration and author fixtures.")


if __name__ == '__main__':
    main()
