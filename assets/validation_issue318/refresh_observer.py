"""Freeze a new observer revision without replacing earlier evidence."""
from pathlib import Path
import argparse
import hashlib
import json
import zipfile
ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).resolve().parent
p=argparse.ArgumentParser(description=__doc__);p.add_argument('name');a=p.parse_args()
directory=ROOT/'build/issue318-audit-02';out=directory/a.name
assert not out.exists()
with zipfile.ZipFile(directory/'base/observer.pk3') as z:members={n:z.read(n) for n in z.namelist()}
members['observer.zs']=(HERE/'observer.zs').read_bytes()
with zipfile.ZipFile(out,'w') as z:
    for name,data in sorted(members.items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
out.with_suffix('.json').write_text(json.dumps({'sha256':hashlib.sha256(out.read_bytes()).hexdigest(),'source_sha256':hashlib.sha256(members['observer.zs']).hexdigest()},indent=2)+'\n')
print(out)
