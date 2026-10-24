"""Package current sources quickly for isolated compiler iterations; final delivery uses build_dev.ps1."""
from pathlib import Path
import sys,zipfile
ROOT=Path(__file__).resolve().parents[2]
output=ROOT/'build/issue411'/sys.argv[1]/'caelum_argenteum_dev.pk3'
if output.exists():raise SystemExit('Preserve earlier probes: choose another label')
output.parent.mkdir(parents=True,exist_ok=True)
with zipfile.ZipFile(output,'w',zipfile.ZIP_STORED) as archive:
 for source in sorted((ROOT/'src').rglob('*')):
  if source.is_file():archive.writestr(zipfile.ZipInfo(source.relative_to(ROOT/'src').as_posix(),(2000,1,1,0,0,0)),source.read_bytes())
print(output)
