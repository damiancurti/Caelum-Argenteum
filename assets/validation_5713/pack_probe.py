"""Package current src quickly for compiler probes; final delivery uses build_dev.ps1."""
from pathlib import Path
import zipfile

ROOT = Path(__file__).resolve().parents[2]
target = ROOT / "build/issue471-batches/probe/caelum_argenteum_dev.pk3"
target.parent.mkdir(parents=True, exist_ok=True)
with zipfile.ZipFile(target, "w", zipfile.ZIP_STORED) as package:
    for path in sorted((ROOT / "src").rglob("*")):
        if path.is_file():
            package.writestr(zipfile.ZipInfo(path.relative_to(ROOT / "src").as_posix(),
                                            (2000, 1, 1, 0, 0, 0)), path.read_bytes())
print(f"Compiler probe package: {target}")
