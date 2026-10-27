"""Build immutable compiler probes; delivery still uses build_dev.ps1."""
from pathlib import Path
import sys
import zipfile

ROOT = Path(__file__).resolve().parents[2]
target = ROOT / 'build/issue410-cooking' / sys.argv[1] / 'caelum_argenteum_dev.pk3'
if target.exists():
    raise RuntimeError('Use a new probe name to preserve evidence.')
target.parent.mkdir(parents=True, exist_ok=True)
with zipfile.ZipFile(target, 'w', zipfile.ZIP_STORED) as package:
    for path in sorted((ROOT / 'src').rglob('*')):
        if path.is_file():
            package.writestr(zipfile.ZipInfo(path.relative_to(ROOT / 'src').as_posix(),
                                            (2000, 1, 1, 0, 0, 0)), path.read_bytes())
print(target)
