"""Package only #417 runtime changes over the verified full #416 build."""
from pathlib import Path
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "build/issue417-incidents"
BASE = ROOT.parent / "issue416-network-work/build/issue416-network/current/caelum_argenteum_dev.pk3"


def pack(path, members):
    path.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(path, "w", zipfile.ZIP_STORED) as archive:
        for name, payload in sorted(members.items()):
            archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), payload)


names = set(subprocess.check_output(["git", "diff", "8ed0caea9", "--name-only", "--", "src"], cwd=ROOT, text=True).splitlines())
names.update(subprocess.check_output(["git", "ls-files", "--others", "--exclude-standard", "--", "src"], cwd=ROOT, text=True).splitlines())
changed = {n[4:] for n in names}
with zipfile.ZipFile(BASE) as source:
    pack(OUT / "probe/caelum_argenteum_dev.pk3", {n: (ROOT / "src" / n).read_bytes() if n in changed else source.read(n)
         for n in set(source.namelist()) | changed})
pack(OUT / "checks.pk3", {
    "ZSCRIPT": b'version "4.14"\n#include "checks.zs"\n',
    "checks.zs": (Path(__file__).parent / "checks.zs").read_bytes(),
    "MAPINFO": b'GameInfo {AddEventHandlers="CA417Checks"}\nmap CNET417 "Travel incident checks" {cluster=8553}\n',
    "maps/CNET417.wad": (ROOT / "assets/validation_5826/away.wad").read_bytes(),
})
(OUT / "core.cfg").write_text("wait 105; netevent ca417_core; wait 10; save incident-repair; wait 10; quit\n", encoding="utf-8")
(OUT / "reload.cfg").write_text("wait 10; netevent ca417_reload; wait 10; quit\n", encoding="utf-8")
(OUT / "bandits.cfg").write_text("wait 105; netevent ca417_prepare_bandits; wait 5; netevent ca417_bandits; wait 10; quit\n", encoding="utf-8")
(OUT / "encounter.cfg").write_text("wait 105; netevent ca417_encounter 0; wait 10; netevent ca417_encounter 1; wait 10; save ambush-native; wait 10; quit\n", encoding="utf-8")
(OUT / "encounter-resume.cfg").write_text("wait 10; netevent ca417_encounter 2; wait 105; netevent ca417_encounter 3; wait 175; netevent ca417_encounter 4; wait 10; quit\n", encoding="utf-8")
(OUT / "native-clock.cfg").write_text("wait 105; netevent ca417_native_clock; wait 10; quit\n", encoding="utf-8")
(OUT / "camp.cfg").write_text("wait 10; netevent ca417_camp 0; wait 5; netevent ca417_camp 1; wait 105; netevent ca417_camp 2; wait 200; netevent ca417_camp 3; wait 10; quit\n", encoding="utf-8")
print(f"Prepared #417 overlay with {len(changed)} source changes")
