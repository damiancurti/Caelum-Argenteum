"""Package the focused #416 overlay and owned isolated native fixture."""
from pathlib import Path
import subprocess
import zipfile

R = Path(__file__).resolve().parents[2]
H = Path(__file__).resolve().parent
W = R / "build/issue416-network"
BASE = R.parent / "issue415-combat-work/build/issue415-rounds/probe/caelum_argenteum_dev.pk3"


def pack(path, contents):
    path.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(path, "w", zipfile.ZIP_STORED) as archive:
        for name, payload in sorted(contents.items()):
            archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), payload)


changed = set(subprocess.check_output(["git", "diff", "e22e14967", "--name-only", "--", "src"], cwd=R, text=True).splitlines())
changed.update(subprocess.check_output(["git", "ls-files", "--others", "--exclude-standard", "--", "src"], cwd=R, text=True).splitlines())
changed = {name[4:] for name in changed}
if any(name.startswith("localization/") for name in changed):
    changed.add("LANGUAGE")
with zipfile.ZipFile(BASE) as old:
    pack(W / "probe/caelum_argenteum_dev.pk3", {
        name: (R / "src" / name).read_bytes() if name in changed else old.read(name)
        for name in set(old.namelist()) | changed})
pack(W / "checks.pk3", {
    "ZSCRIPT": b'version "4.14"\n#include "checks.zs"\n',
    "checks.zs": (H / "checks.zs").read_bytes(),
    "MAPINFO": b'GameInfo {AddEventHandlers="CA416Checks"}\nmap CNET416 "Transport checks" {cluster=8552}\n',
    "maps/CNET416.wad": (R / "assets/validation_5826/away.wad").read_bytes(),
})
(W / "catalogue.cfg").write_text("wait 105; netevent ca416_catalogue; wait 10; quit\n", encoding="utf-8")
print(f"Prepared #416 overlay: {len(changed)} source members")

(W/"city.cfg").write_text("wait 105; netevent ca416_city; wait 10; quit\n", encoding="utf-8")
(W/"cityvisual.cfg").write_text("wait 105; netevent ca416_city; netevent ca416_camera 0; wait 10; screenshot "+(W/"city-overview.png").as_posix()+"; netevent ca416_camera 1; wait 10; screenshot "+(W/"city-street.png").as_posix()+"; netevent ca416_camera 2; wait 10; screenshot "+(W/"city-dock.png").as_posix()+"; netevent ca416_camera 3; wait 10; screenshot "+(W/"city-interior.png").as_posix()+"; wait 10; quit\n",encoding="utf-8")

(W/"services.cfg").write_text("wait 105; netevent ca416_services; wait 10; save city-services; wait 10; quit\n",encoding="utf-8")
(W/"services-load.cfg").write_text("wait 10; netevent ca416_services 1; wait 10; quit\n",encoding="utf-8")

(W/"tickets.cfg").write_text("wait 105; netevent ca416_tickets; wait 10; save city-ticket; wait 10; quit\n",encoding="utf-8")
(W/"tickets-load.cfg").write_text("wait 10; netevent ca416_tickets 1; wait 10; quit\n",encoding="utf-8")
