"""Create private #472 native test fixtures from the retained owned test room."""
from pathlib import Path
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
OUT = ROOT / "build/issue472"
OUT.mkdir(parents=True, exist_ok=True)
common = Path(subprocess.check_output(["git", "rev-parse", "--path-format=absolute", "--git-common-dir"], cwd=ROOT, text=True).strip()).parent
with zipfile.ZipFile(common / "build/issue405/checks.pk3") as original:
    room = original.read("maps/CARESRC.wad")
entries = {"ZSCRIPT": b'version "4.14"\n#include "checks.zs"\n',
           "MAPINFO": b'GameInfo { AddEventHandlers="CA472Checks" }\nmap CAMATE1 "Mate checks" {next="CAMATE2"}\nmap CAMATE2 "Mate travel" {}\n',
           "checks.zs": (HERE / "checks.zs").read_bytes(), "maps/CAMATE1.wad": room, "maps/CAMATE2.wad": room}
with zipfile.ZipFile(OUT / "checks.pk3", "w", zipfile.ZIP_STORED) as package:
    for name, data in sorted(entries.items()):
        package.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), data)
for name, script in {name: f"wait 105; netevent ca472_{name}; wait {560 if name == 'recovery' else 10}; quit" for name in ("basics", "transactions", "crafting", "catalogue", "recovery", "transfer")}.items():
    (OUT / f"{name}.cfg").write_text(script + "\n", encoding="utf-8")
print(f"Prepared {OUT}")

extra = {
    "seed": "wait 105; netevent ca472_seed; wait 2; save mate472; wait 3; quit",
    "resume": "wait 3; netevent ca472_resume; wait 3; quit",
    "mate-travel": "wait 105; netevent ca472_travel; wait 70; quit",
    "legacy-seed": "wait 105; netevent ca472_legacy_seed; wait 2; save old471; wait 3; quit",
    "legacy-resume": "wait 3; netevent ca472_legacy_resume; wait 3; quit",
    "preview": "wait 105; language esn; netevent ca472_preview 1; wait 35; screenshot " + (OUT / "mate-panel.png").as_posix() + "; wait 3; quit",
    "keys": "wait 105; netevent ca472_preview; wait 35; event ca472_keys 0; wait 3; netevent ca472_keys_check 0; event ca472_keys 1; wait 3; netevent ca472_keys_check 1; event ca472_keys 2; wait 3; netevent ca472_keys_check 2; event ca472_keys 3; wait 3; netevent ca472_keys_check 3; event ca472_keys 4; wait 3; netevent ca472_keys_check 4; wait 3; quit",
}
for name, script in extra.items():
    (OUT / f"{name}.cfg").write_text(script + "\n", encoding="utf-8")

legacy_entries = {**entries, "checks.zs": (HERE / "legacy_checks.zs").read_bytes()}
with zipfile.ZipFile(OUT / "legacy-checks.pk3", "w", zipfile.ZIP_STORED) as package:
    for name, data in sorted(legacy_entries.items()):
        package.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), data)

(OUT / "migrated").mkdir(exist_ok=True)
(OUT / "migrated/legacy-checks.pk3").write_bytes((OUT / "checks.pk3").read_bytes())

for variant in range(3):
    (OUT / f"visual{variant}.cfg").write_text(f"wait 105; language esn; netevent ca472_preview {variant}; wait 35; screenshot mate-{variant}.png; netevent ca472_inventory; ca_journal_open 1; ca_journal_page 0; wait 35; screenshot inventory-{variant}.png; ca_journal_open 0; netevent ca472_gallery; wait 35; screenshot world-{variant}.png; wait 3; quit\n", encoding="utf-8")
(OUT / "workshop.cfg").write_text("wait 105; language esn; netevent ca472_workshop; wait 35; screenshot workshop.png; wait 3; quit\n", encoding="utf-8")

(OUT / "map.cfg").write_text("wait 140; netevent ca472_map; wait 5; quit\n", encoding="utf-8")
