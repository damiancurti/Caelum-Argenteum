"""Verify the exact null guard, unchanged non-null body and every package member."""
from pathlib import Path
import argparse,hashlib,json,subprocess,zipfile
ROOT=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--runtime',type=Path,required=True);p.add_argument('--baseline',type=Path,required=True);p.add_argument('--candidate',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
sha=lambda b:hashlib.sha256(b).hexdigest();path='caelum/survival/CaelumContaminationStack.zs'
guard='        // Un contacto sin inventario no puede contener una pila.\n        if(item==null)return false;\n'.replace('\n','\r\n').encode()
with zipfile.ZipFile(a.baseline) as old,zipfile.ZipFile(a.runtime) as new,zipfile.ZipFile(a.candidate) as prototype:
    oldnames=set(old.namelist());newnames=set(new.namelist());assert oldnames==newnames
    assert newnames=={p.relative_to(ROOT/'src').as_posix() for p in (ROOT/'src').rglob('*') if p.is_file()}
    changed=[]
    for name in sorted(newnames):
        data=new.read(name);assert data==(ROOT/'src'/name).read_bytes(),name
        if old.read(name)!=data:changed.append(name)
    assert changed==sorted([path,'caelum/world/CaelumPhysicalHazards.zs','caelum/world/CaelumSewerMaze.zs']),changed
    assert new.read(path)==prototype.read(path)
    assert new.read(path).count(guard)==1 and new.read(path).replace(guard,b'')==old.read(path)
    for name in changed:
        if name!=path:assert old.read(name).replace(b'[Caelum 5.17.99]',b'[Caelum 5.17.100]')==new.read(name)
    source_sha=sha(new.read(path));members=len(newnames)
assert not subprocess.check_output(['git','diff','--name-only','HEAD','--','pending_test.txt'],cwd=ROOT).strip()
report=dict(issue=844,passed=True,runtime_sha256=sha(a.runtime.read_bytes()),baseline_sha256=sha(a.baseline.read_bytes()),candidate_source_sha256=source_sha,runtime_members=members,runtime_bytes=a.runtime.stat().st_size,changed=changed,no_added_or_removed_members=True,source_package_exact=True,prototype_source_exact=True,all_outside_null_guard_exact=True,author_queue_unchanged=True,qualification='Only an immediate null-inventory false return, its comment and two diagnostic version strings change. All non-null eligibility, callers, contact/migration/ownership logic, fields, timing and resources remain exact.')
a.output.write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8');print(json.dumps(report,indent=2))
