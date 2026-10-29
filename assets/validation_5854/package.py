"""Package exact current src bytes without compression for isolated native review."""
from pathlib import Path
import zipfile,json,hashlib,sys
R=Path(__file__).resolve().parents[2];name=sys.argv[1] if len(sys.argv)>1 else 'review54b'
out=R/'build/issue417-incidents'/name/'caelum_argenteum_dev.pk3';out.parent.mkdir(parents=True,exist_ok=True)
paths=sorted(p for p in (R/'src').rglob('*') if p.is_file())
with zipfile.ZipFile(out,'w') as z:
 for p in paths:z.writestr(zipfile.ZipInfo(p.relative_to(R/'src').as_posix(),(2000,1,1,0,0,0)),p.read_bytes())
with zipfile.ZipFile(out) as z:assert all(z.read(p.relative_to(R/'src').as_posix())==p.read_bytes() for p in paths)
report={'package':str(out),'sha256':hashlib.file_digest(out.open('rb'),'sha256').hexdigest(),'exact_source_members':len(paths)}
(out.parent/'source-match.json').write_text(json.dumps(report,indent=2)+'\n');print(report)
