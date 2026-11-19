"""Verify every final package byte and the sole behavior-preserving predicate edit."""
from pathlib import Path
import argparse,hashlib,json,subprocess,zipfile
ROOT=Path(__file__).resolve().parents[2]/'build/v517/work-713'
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--runtime',type=Path,required=True);p.add_argument('--baseline',type=Path,required=True);p.add_argument('--candidate',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
sha=lambda b:hashlib.sha256(b).hexdigest();path='caelum/survival/CaelumThermalEnvironment.zs'
with zipfile.ZipFile(a.baseline) as old,zipfile.ZipFile(a.runtime) as new,zipfile.ZipFile(a.candidate) as prototype:
    oldnames=set(old.namelist());newnames=set(new.namelist());assert oldnames==newnames
    assert newnames=={p.relative_to(ROOT/'src').as_posix() for p in (ROOT/'src').rglob('*') if p.is_file()}
    changed=[]
    for name in sorted(newnames):
        data=new.read(name);assert data==(ROOT/'src'/name).read_bytes(),name
        if old.read(name)!=data:changed.append(name)
    assert changed==sorted([path,'caelum/world/CaelumPhysicalHazards.zs','caelum/world/CaelumSewerMaze.zs']),changed
    assert new.read(path)==prototype.read(path)
    for name in changed:
        if name!=path:assert old.read(name).replace(b'[Caelum 5.17.98]',b'[Caelum 5.17.99]')==new.read(name)
    oldsource=old.read(path).decode('utf-8').replace('\r\n','\n');newsource=new.read(path).decode('utf-8').replace('\r\n','\n')
    start=oldsource.index('        for(int first=0;first<count;first++)');end=oldsource.index('        return false;',start)
    first=newsource.index('        // En un grafo no dirigido');last=newsource.index('        return false;',first)
    assert oldsource[:start]==newsource[:first] and oldsource[end:]==newsource[last:]
    assert 'neighbors[first]>=2 || neighbors[second]>=2' in newsource[first:last]
    source_sha=sha(new.read(path));members=len(newnames)
assert not subprocess.check_output(['git','diff','--name-only','HEAD','--','pending_test.txt'],cwd=ROOT).strip()
report=dict(issue=842,passed=True,runtime_sha256=sha(a.runtime.read_bytes()),baseline_sha256=sha(a.baseline.read_bytes()),candidate_source_sha256=source_sha,runtime_members=members,runtime_bytes=a.runtime.stat().st_size,changed=changed,no_added_or_removed_members=True,source_package_exact=True,prototype_source_exact=True,all_outside_connectivity_block_exact=True,author_queue_unchanged=True,qualification='Only the bounded connectivity implementation and two diagnostic version strings change. Every trace, plane-deduplication operation, caller, field declaration, save schema, thermal value and all other runtime members remain byte-identical.')
a.output.write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8');print(json.dumps(report,indent=2))
