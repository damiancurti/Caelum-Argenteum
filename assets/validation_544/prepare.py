"""Package the in-progress #238 presentation component, not a full ability test."""
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
        "ZSCRIPT": b'version "4.14"\n#include "equipment.zs"\n#include "presentation.zs"\n',
        "equipment.zs": (HERE.parent / "validation_541/session.zs").read_bytes(),
        "presentation.zs": (HERE / "presentation.zs").read_bytes(),
        "MAPINFO": b'GameInfo { AddEventHandlers="CA238PresentationProbe" }\n'})}
(out / "probe.cfg").write_text("wait 100; netevent c238_setup; wait 100; netevent c238_start; +attack; wait 105; -attack; wait 5; netevent c238_end; wait 5; quit\n", encoding="utf-8")
(out / "preview.cfg").write_text("language es; con_notifytime 0; wait 100; netevent c238_setup; wait 100; netevent c238_pose 95; wait 5; screenshot lowering.png; netevent c238_pose 50; wait 5; screenshot fists.png; netevent c238_pose 22; wait 5; screenshot turn.png; netevent c238_pose 2; wait 5; screenshot palms.png; netevent c238_pose 0; wait 5; screenshot restored.png; netevent c238_end; wait 5; quit\n", encoding="utf-8")
steps = ["wait 100", "netevent c238_setup", "wait 100"]
for choice in range(9):
    if choice:
        steps += [f"netevent c238_weapon {choice}", "wait 80"]
    steps += ["netevent c238_start", "+attack", "wait 105", "-attack", "wait 10"]
steps += ["netevent c238_unarmed", "wait 80", "netevent c238_start", "+attack", "wait 105", "-attack", "wait 10", "netevent c238_end", "wait 5", "quit"]
(out / "matrix.cfg").write_text("; ".join(steps)+"\n", encoding="utf-8")
(out / "save.cfg").write_text("wait 100; netevent c238_setup; wait 100; netevent c238_pose 20; wait 5; save cast-palms.zds; wait 10; netevent c238_end; wait 5; quit\n", encoding="utf-8")
steps = ["language es", "con_notifytime 0", "wait 100", "netevent c238_setup", "wait 100", "netevent c238_pose 2", "wait 5", "screenshot final-palms.png", "netevent c238_profile 0 0 0", "wait 5", "screenshot wolf-palms.png", "netevent c238_profile 2 1 0", "wait 5", "screenshot female-palms.png", "netevent c238_unarmed", "wait 80", "netevent c238_pose 50", "wait 5", "screenshot unarmed-fists.png", "netevent c238_pose 2", "wait 5", "screenshot unarmed-palms.png", "netevent c238_end", "wait 5", "quit"]
(out / "variants.cfg").write_text("; ".join(steps)+"\n", encoding="utf-8")
manifest["hud_fixture_sha256"] = shared.package(out / "hud.pk3", {
    "ZSCRIPT": b'version "4.14"\n#include "powers.zs"\n#include "hud.zs"\n',
    "powers.zs": (HERE.parent / "validation_530/probe.zs").read_bytes(),
    "hud.zs": (HERE / "hud.zs").read_bytes(),
    "MAPINFO": b'GameInfo { AddEventHandlers="CA255Probe", "CA238HUDProbe" }\n'})
steps = ["con_notifytime 0", "wait 100", "netevent c255_prepare", "wait 50", "netevent c238_hud_setup", "wait 5"]
for mode, name in [(1,"ready"),(0,"unavailable"),(2,"preparing"),(3,"cooldown"),(4,"unimplemented")]:
    steps += ["netevent c255_state 2", f"netevent c238_hud_state {mode}", "wait 10", "netevent c238_hud_check", f"screenshot hud-{name}.png"]
    if mode == 3:
        steps += ["wait 70", "netevent c238_hud_check", "screenshot hud-countdown.png"]
steps += ["netevent c238_hud_done", "wait 5", "quit"]
(out / "hud.cfg").write_text("; ".join(steps)+"\n", encoding="utf-8")
(out / "manifest.json").write_text(json.dumps(manifest, indent=2)+"\n", encoding="utf-8")
print(json.dumps(manifest))
