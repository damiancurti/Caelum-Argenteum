"""Reuse the owned #318 four-door geometry, without running its old suites."""
from pathlib import Path
import subprocess
import zipfile

R = Path(__file__).resolve().parents[2]
W = R / "build/issue415-rounds"
source = R.parents[1] / "build/issue318-native-08/current/probe.pk3"
if not source.exists():
    source = R / "build/issue415-door-fixture/current/probe.pk3"
    if not source.exists():
        subprocess.run(["python", str(R / "assets/validation_issue318/native_doors_fixture.py"),
                        "--directory", "issue415-door-fixture"], cwd=R, check=True)
with zipfile.ZipFile(source) as archive:
    geometry = archive.read("maps/MAP98.wad")
with zipfile.ZipFile(W / "checks.pk3") as archive:
    members = {name: archive.read(name) for name in archive.namelist()}
members["maps/MAP98.wad"] = geometry
members["MAPINFO"] += b'\nmap MAP98 "Theft native-door access" {cluster=8551}\n'
with zipfile.ZipFile(W / "theft-doors.pk3", "w", zipfile.ZIP_STORED) as archive:
    for name, data in sorted(members.items()):
        archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), data)
(W / "theftdoors.cfg").write_text("wait 105; netevent ca415t_prepare; wait 3; netevent ca415t_doors; wait 10; quit\n", encoding="utf-8")
print("Prepared owned native-door geometry; no earlier stress suite was run")
