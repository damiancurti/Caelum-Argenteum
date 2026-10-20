"""Prepare focused native container scenarios, outside the production package."""
from pathlib import Path
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
OUT = ROOT / "build/issue381"
OUT.mkdir(parents=True, exist_ok=True)
members = {
    "ZSCRIPT": b'version "4.14"\n#include "legacy.zs"\n#include "checks.zs"\n',
    "MAPINFO": b'GameInfo { AddEventHandlers = "CA381LegacyChecks", "CA381Checks" }\n',
    "checks.zs": (HERE / "checks.zs").read_bytes(),
    "legacy.zs": (HERE / "legacy.zs").read_bytes(),
}
legacy = {
    "ZSCRIPT": b'version "4.14"\n#include "legacy.zs"\n',
    "MAPINFO": b'GameInfo { AddEventHandlers = "CA381LegacyChecks" }\n',
    "legacy.zs": members["legacy.zs"],
}
for filename, files in (("checks.pk3", members), ("legacy-checks.pk3", legacy)):
    with zipfile.ZipFile(OUT / filename, "w", zipfile.ZIP_STORED) as archive:
        for name, content in sorted(files.items()):
            archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), content)
scripts = {
    "suite": "wait 35; netevent ca381_suite; wait 5; quit",
    "save": "wait 35; netevent ca381_save; wait 5; save ca381-current; wait 5; quit",
    "verify": "wait 5; netevent ca381_verify; netevent ca381_openverify; wait 5; quit",
    "legacy-save": "wait 35; netevent ca381_legacy_save; wait 5; save ca381-legacy; wait 5; quit",
    "legacy-verify": "wait 5; netevent ca381_legacy_verify; wait 5; quit",
    "upgrade": "wait 5; netevent ca381_legacy_verify; netevent ca381_upgrade; wait 5; save ca381-upgraded; wait 5; quit",
    "upgraded-verify": "wait 5; netevent ca381_legacy_verify; netevent ca381_upgrade_verify; wait 5; quit",
    "downgrade": "wait 5; netevent ca381_downgrade; wait 5; save ca381-reversed; wait 5; quit",
    "cardinal": "wait 35; changemap MAP02; wait 35; netevent ca381_cardinal; wait 5; save ca381-cardinal; wait 10; "
                "changemap THAZARD; wait 35; netevent ca381_cardinal_verify; "
                "changemap MAP02; wait 35; netevent ca381_cardinal_verify; wait 5; quit",
    "cardinal-verify": "wait 70; netevent ca381_cardinal_verify; wait 35; quit",
    "supply": "wait 35; changemap MAP01; wait 35; netevent ca381_supply; wait 5; quit",
    "ui": "wait 35; netevent ca381_save; wait 10; screenshot storage-en.png; wait 5; "
          "language es; wait 5; netevent ca_container_move 1; wait 10; screenshot storage-es.png; wait 5; quit",
    "interactive": "exec ../../assets/playtest/default_controls.cfg; wait 35; netevent ca381_save; "
                   "wait 5; netevent ca_container_close; toggleconsole",
    "travel": "wait 5; netevent ca381_verify; changemap THAZARD; wait 35; netevent ca381_verify; "
              "changemap TMAINT; wait 35; netevent ca381_verify; changemap MAP02; wait 35; "
              "netevent ca381_verify; changemap MAP01; wait 35; netevent ca381_verify; wait 5; quit",
}
for name, commands in scripts.items():
    (OUT / f"{name}.cfg").write_text(commands + "\n", encoding="utf-8")
