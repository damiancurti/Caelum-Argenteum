"""Package the deterministic thermal equivalence grid without production edits."""
from pathlib import Path
import hashlib
import json
import zipfile

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'build/issue431/accuracy'
OUT.mkdir(parents=True, exist_ok=True)
package = OUT / 'checks.pk3'
files = {
    'ZSCRIPT': b'version "4.14"\n#include "thermal_accuracy.zs"\n',
    'MAPINFO': b'GameInfo { AddEventHandlers="CA511ThermalAccuracy" }\n',
    'thermal_accuracy.zs': (Path(__file__).parent / 'thermal_accuracy.zs').read_bytes(),
}
with zipfile.ZipFile(package, 'w', zipfile.ZIP_STORED) as archive:
    for name, data in sorted(files.items()):
        archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), data)
print(json.dumps({'package': str(package), 'sha256': hashlib.sha256(package.read_bytes()).hexdigest()}))
variant = ROOT / 'build/issue431/simplified-siege.pk3'
if variant.is_file():
    with zipfile.ZipFile(variant) as archive:
        files.update({name: archive.read(name) for name in archive.namelist()})
    package = OUT / 'simplified.pk3'
    with zipfile.ZipFile(package, 'w', zipfile.ZIP_STORED) as archive:
        for name, data in sorted(files.items()):
            archive.writestr(zipfile.ZipInfo(name, (2000, 1, 1, 0, 0, 0)), data)
    print(json.dumps({'package': str(package), 'sha256': hashlib.sha256(package.read_bytes()).hexdigest()}))
