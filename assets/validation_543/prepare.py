"""Package isolated issue #254 native checks without modifying production."""
import argparse
import importlib.util
import json
from pathlib import Path

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
manifest = {
    "production_sha256": shared.package(out / "production.pk3", {
        p.relative_to(ROOT / "src").as_posix(): p.read_bytes()
        for p in (ROOT / "src").rglob("*") if p.is_file()}),
    "fixture_sha256": shared.package(out / "probe.pk3", {
        "ZSCRIPT": b'version "4.14"\n#include "probe.zs"\n',
        "probe.zs": (HERE / "probe.zs").read_bytes(),
        "MAPINFO": b'GameInfo { AddEventHandlers="CA254Probe" }\n'})}
(out / "probe.cfg").write_text("wait 460; quit\n", encoding="utf-8")
manifest["session_sha256"] = shared.package(out / "session.pk3", {
    "ZSCRIPT": b'version "4.14"\n#include "session.zs"\n',
    "session.zs": (HERE / "session.zs").read_bytes(),
    "MAPINFO": b'GameInfo { AddEventHandlers="CA254Session" }\n'})
scripts = {
    "seed": "wait 100; netevent c254_seed; wait 5; save migration-old.zds; wait 10; quit",
    "load": "wait 10; netevent c254_verify; save migration-current.zds; wait 10; quit",
    "verify": "wait 10; netevent c254_verify; wait 10; quit",
    "travel": "wait 10; changemap MAP03; wait 100; changemap MAP02; wait 100; netevent c254_verify_hub; wait 10; quit",
    "manual": 'language es; bind F6 "netevent c254_next"; bind F7 "netevent c254_hit"; bind F8 "netevent c254_kill"; wait 100; netevent c254_manual',
    "preview": "language es; wait 100; netevent c254_manual; wait 25; screenshot preview.png; wait 5; quit",
}
for name,text in scripts.items():
    (out / (name+".cfg")).write_text(text+"\n", encoding="utf-8")
(out / "manifest.json").write_text(json.dumps(manifest, indent=2)+"\n", encoding="utf-8")
print(json.dumps(manifest))
