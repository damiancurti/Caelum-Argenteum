"""Prepare an isolated #238 save check, with an optional old-runtime visual bridge."""
import argparse
import importlib.util
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location("package541", HERE.parent / "validation_541/prepare.py")
shared = importlib.util.module_from_spec(spec)
spec.loader.exec_module(shared)
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--directory", required=True)
parser.add_argument("--runtime", type=Path, required=True)
parser.add_argument("--save", type=Path)
parser.add_argument("--mode", choices=["old", "old-bridge", "current", "legacy-current"], required=True)
args = parser.parse_args()
if not args.directory or any(c not in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_" for c in args.directory):
    parser.error("Use a plain directory name.")
out = ROOT / "build" / args.directory
out.mkdir(exist_ok=False)
shutil.copyfile(args.runtime, out / "production.pk3")
if args.save:
    shutil.copyfile(args.save, out / "stage.zds")
entries = {"compatibility.zs": (HERE / "compatibility.zs").read_bytes()}
zscript = 'version "4.14"\n#include "compatibility.zs"\n'
handler = "CA238CompatibilityProbe"
if args.mode in ("current", "legacy-current"):
    entries["current.zs"] = (HERE / "compatibility_current.zs").read_bytes()
    zscript += '#include "current.zs"\n'
    handler = "CA238CompatibilityCurrent"
if args.mode == "old-bridge":
    entries["bridge.zs"] = (HERE / "rollback_bridge.zs").read_bytes()
    zscript += '#include "bridge.zs"\n'
entries["ZSCRIPT"] = zscript.encode()
entries["MAPINFO"] = ('GameInfo { AddEventHandlers="'+handler+'" }\n').encode()
print(shared.package(out / "probe-v2.pk3", entries))
prefix = "wait 5; netevent c238_legacy; " if args.mode == "legacy-current" else ""
(out / "verify.cfg").write_text(prefix+"wait 100; quit\n", encoding="utf-8")
(out / "seed.cfg").write_text("wait 60; netevent c238_seed; wait 40; save legacy-base.zds; wait 5; quit\n", encoding="utf-8")
