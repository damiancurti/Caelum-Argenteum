"""Prepare private fermentation-state save/travel tests, without recipe balance."""
from pathlib import Path
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
OUT = ROOT / "build/issue471-batches"
OUT.mkdir(parents=True, exist_ok=True)
common = Path(subprocess.check_output(
    ["git", "rev-parse", "--path-format=absolute", "--git-common-dir"],
    cwd=ROOT, text=True).strip()).parent
with zipfile.ZipFile(common / "build/issue405/checks.pk3") as source:
    room = source.read("maps/CARESRC.wad")
members = {
    "ZSCRIPT": b'version "4.14"\n#include "checks.zs"\n',
    "MAPINFO": b'GameInfo { AddEventHandlers="CA471BatchChecks" }\n'
               b'map CABAT1 "Batch persistence A" { next="CABAT2" }\n'
               b'map CABAT2 "Batch persistence B" {}\n',
    "checks.zs": (HERE / "batch_checks.zs").read_bytes(),
    "maps/CABAT1.wad": room,
    "maps/CABAT2.wad": room,
}
with zipfile.ZipFile(OUT / "checks.pk3", "w", zipfile.ZIP_STORED) as package:
    for name, data in sorted(members.items()):
        package.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), data)
scripts = {
    "seed": "wait 105; netevent ca471b_seed; wait 5; save ca471b-seeded; wait 10; quit",
    "resume": "wait 105; netevent ca471b_resume; wait 10; quit",
    "travel": "wait 105; netevent ca471b_seed; wait 5; netevent ca471b_go; wait 105; netevent ca471b_arrived; wait 10; quit",
}
for name, script in scripts.items():
    (OUT / f"{name}.cfg").write_text(script + "\n", encoding="utf-8")
print(f"Prepared {OUT}")

integration = dict(members)
integration["checks.zs"] = (HERE / "integration_checks.zs").read_bytes()
integration["MAPINFO"] = b'GameInfo { AddEventHandlers="CA471IntegrationChecks" }\nmap CABAT1 "Chemistry transaction tests" {next="CABAT2"}\nmap CABAT2 "Chemistry travel tests" {}\n'
with zipfile.ZipFile(OUT / "integration-checks.pk3", "w", zipfile.ZIP_STORED) as package:
    for name, data in sorted(integration.items()):
        package.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), data)
for name, command in {
    "transactions": "netevent ca471i_transactions; wait 10; quit",
    "processes": "netevent ca471i_processes; wait 10; quit",
    "catalogue": "netevent ca471i_catalogue; wait 10; quit",
    "shared": "addbot; wait 105; netevent ca471i_shared; wait 10; quit",
    "transaction-travel": "netevent ca471i_seed; wait 5; netevent ca471i_go; wait 105; netevent ca471i_destination; wait 5; netevent ca471i_back; wait 105; netevent ca471i_returned; wait 10; quit",
    "transaction-seed": "netevent ca471i_seed; wait 5; save ca471i-seeded; wait 10; quit",
    "transaction-load": "netevent ca471i_resume; wait 10; quit",
    "restock": "netevent ca471i_restock; wait 10; quit",
    "water-seed": "netevent ca471i_water_seed; wait 5; save ca471i-water; wait 10; quit",
    "water-load": "netevent ca471i_water_resume; wait 10; quit",
    "keys": "netevent ca471i_preview 0; wait 20; event ca471i_keys 0; wait 5; netevent ca471i_keycheck 0; event ca471i_keys 1; wait 5; netevent ca471i_keycheck 1; event ca471i_keys 2; wait 5; netevent ca471i_keycheck 2; event ca471i_keys 3; wait 5; netevent ca471i_keycheck 3; wait 10; quit",
    "preview": "language esn; netevent ca471i_preview 0; wait 35; screenshot barrel-empty.png; netevent ca471i_preview 1; wait 35; screenshot barrel-active.png; netevent ca471i_preview 2; wait 35; screenshot barrel-ready.png; netevent ca471i_preview 3; wait 35; screenshot chemistry-menu.png; netevent ca471i_preview 4; wait 35; screenshot supplies.png; wait 10; quit",
}.items():
    (OUT / f"{name}.cfg").write_text("wait 105; " + command + "\n", encoding="utf-8")
