"""Reconstruct the last pushed #415 runtime for an identical loading comparison."""
from pathlib import Path
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[2]
WORK = ROOT / "build/issue415-rounds"
REVISION = "e22e1496705343369cc7ee17fa37067ae31a8149"


def pack(path, members):
    path.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(path, "w", zipfile.ZIP_STORED) as archive:
        for name, payload in sorted(members.items()):
            archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), payload)


with zipfile.ZipFile(WORK / "probe/caelum_argenteum_dev.pk3") as archive:
    members = {name: archive.read(name) for name in archive.namelist()}
changed = subprocess.check_output(["git", "diff", REVISION, "--name-only", "--", "src"], cwd=ROOT, text=True).splitlines()
for name in changed:
    members[name[4:]] = subprocess.check_output(["git", "show", REVISION + ":" + name], cwd=ROOT)
pack(WORK / "load-baseline/caelum_argenteum_dev.pk3", members)
with zipfile.ZipFile(WORK / "checks.pk3") as archive:
    fixture = {name: archive.read(name) for name in archive.namelist()}
fixture["ZSCRIPT"] = fixture["ZSCRIPT"].replace(b'#include "cache.zs"\n', b"")
fixture["MAPINFO"] = fixture["MAPINFO"].replace(b'GameInfo {AddEventHandlers="CA415CacheChecks"}\n', b"")
pack(WORK / "loadchecks.pk3", fixture)
print(f"Preserved baseline {REVISION}; {len(changed)} source replacements")
