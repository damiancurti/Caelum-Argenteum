"""Package the isolated container travel experiment, never production content."""
from pathlib import Path
import zipfile

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
OUT = ROOT / "build/issue381"
OUT.mkdir(parents=True, exist_ok=True)
members = {
    "ZSCRIPT": b'version "4.14"\n#include "probe.zs"\n',
    "MAPINFO": b'GameInfo { AddEventHandlers = "CA381Probe" }\n',
    "probe.zs": (HERE / "travel_probe.zs").read_bytes(),
}
with zipfile.ZipFile(OUT / "checks.pk3", "w", zipfile.ZIP_STORED) as archive:
    for name, content in sorted(members.items()):
        archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), content)
(OUT / "probe.cfg").write_text(
    "wait 35; netevent ca381_probe; wait 5; netevent ca381_verify; "
    "changemap THAZARD; wait 35; netevent ca381_verify; "
    "changemap TMAINT; wait 35; netevent ca381_verify; "
    "changemap MAP02; wait 35; netevent ca381_verify; "
    "changemap MAP01; wait 35; netevent ca381_verify; wait 5; quit\n",
    encoding="utf-8")
