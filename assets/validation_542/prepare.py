"""Package the isolated issue #261 development checks without production mutation."""
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
        "ZSCRIPT": b'version "4.14"\n#include "checks/probe.zs"\n',
        "checks/probe.zs": (HERE / "probe.zs").read_bytes(),
        "MAPINFO": b'GameInfo { AddEventHandlers="CA261Probe" }\n'})}
(out / "probe.cfg").write_text("wait 100; netevent c261_audit; wait 15; quit\n", encoding="utf-8")
manifest["session_sha256"] = shared.package(out / "session.pk3", {
    "ZSCRIPT": b'version "4.14"\n#include "checks/session.zs"\n',
    "checks/session.zs": (HERE / "session.zs").read_bytes(),
    "MAPINFO": b'GameInfo { AddEventHandlers="CA261Session" }\n'})
scripts = {
    "seed": "wait 100; netevent c261_seed; wait 5; save migration-old.zds; wait 10; quit",
    "load": "wait 10; netevent c261_verify; save migration-current.zds; wait 10; quit",
    "verify": "wait 10; netevent c261_verify; wait 10; quit",
    "rollback": "wait 10; netevent c261_verify_old; wait 10; quit",
    "cycles": "wait 100; netevent c261_seed; wait 15; " + "netevent c261_cycle; wait 15; "*12 + "quit",
    "travel": "wait 100; netevent c261_seed; wait 15; changemap MAP03; wait 100; netevent c261_travel_verify; wait 10; changemap MAP02; wait 100; netevent c261_travel_verify; wait 10; quit",
    "preview": "language es; wait 100; netevent c261_seed; wait 20; ca_journal_page 1; ca_journal_open true; wait 15; screenshot preview.png; wait 5; quit",
    "details": "language es; wait 100; netevent c261_seed; wait 20; netevent c261_details; wait 15; screenshot details.png; wait 5; quit",
    "manual": 'language es; bind F6 "netevent c261_cycle"; wait 100; netevent c261_seed; wait 20; ca_journal_page 1; ca_journal_open true',
}
for name, text in scripts.items():
    (out / (name+".cfg")).write_text(text+"\n", encoding="utf-8")
(out / "manifest.json").write_text(json.dumps(manifest, indent=2)+"\n", encoding="utf-8")
print(json.dumps(manifest))
