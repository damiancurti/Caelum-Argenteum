"""Freeze a focused #284 runtime and native combat fixture."""
from pathlib import Path
import argparse
import importlib.util
import json
import hashlib
import shutil

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location("room", HERE.parent / "validation_5218/prepare.py")
room = importlib.util.module_from_spec(spec)
spec.loader.exec_module(room)

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--directory", required=True)
    parser.add_argument("--compat", action="store_true")
    parser.add_argument("--legacy", action="store_true")
    parser.add_argument("--runtime", type=Path)
    args = parser.parse_args()
    if not args.directory or any(c not in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_" for c in args.directory):
        parser.error("Plain directory name required.")
    out = ROOT / "build" / args.directory
    out.mkdir(exist_ok=False)
    if args.runtime:
        shutil.copyfile(args.runtime, out / "production.pk3")
        runtime_hash = hashlib.sha256((out / "production.pk3").read_bytes()).hexdigest()
    else:
        runtime_hash = room.package(out / "production.pk3", {
            p.relative_to(ROOT / "src").as_posix(): p.read_bytes()
            for p in (ROOT / "src").rglob("*") if p.is_file()})
    manifest = {"runtime_sha256": runtime_hash}
    source = (HERE / ("compatibility.zs" if args.compat else "demons.zs")).read_text(encoding="utf-8")
    if args.compat and not args.legacy:
        source = source.replace("// CURRENT_CHECK", '''Check(Mandinga.CombatPersonalityRevision==2 && Zupay.CombatPersonalityRevision==2
            && CaelumPersonalityRules.Pack(Mandinga.CombatPersonality)==6
            && CaelumPersonalityRules.Pack(Zupay.CombatPersonality)==80,"saved demons adopt exact approved personalities once");
        Check(Shot.CaelumRockVisualRevision==1 && Shot.CaelumZupayRockVisual
            && Shot.sprite==Actor.GetSpriteIndex("ZROK"),"old flying projectile adopts rock without reconstruction");''')
    handler = "CA284Compat" if args.compat else "CA284Probe"
    manifest["fixture_sha256"] = room.package(out / "demons.pk3", {
        "ZSCRIPT": b'version "4.14"\n#include "demons.zs"\n', "demons.zs": source.encode(),
        "maps/MAP99.wad": room.room(), "maps/MAP98.wad": room.room(),
        "MAPINFO": (f'GameInfo {{ AddEventHandlers="{handler}" }}\ncluster 99 {{ hub }}\n'
            'map MAP99 "Demon combat fixture" { cluster=99 sky1="SKY1",0 }\n'
            'map MAP98 "Demon travel fixture" { cluster=99 sky1="SKY1",0 }\n').encode()})
    for script in HERE.glob("*.cfg"):
        (out / script.name).write_bytes(script.read_bytes())
    (out / "manifest.json").write_text(json.dumps(manifest, indent=2)+"\n", encoding="utf-8")
    print(json.dumps(manifest))

if __name__ == "__main__":
    main()
