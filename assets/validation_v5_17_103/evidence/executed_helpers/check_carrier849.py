"""Verify the exact measured candidate and every final package member."""
from pathlib import Path
import argparse,hashlib,json,subprocess,zipfile
ROOT=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
p=argparse.ArgumentParser(description=__doc__)
for flag in ('runtime','baseline','candidate','output'):p.add_argument('--'+flag,type=Path,required=True)
a=p.parse_args();sha=lambda b:hashlib.sha256(b).hexdigest()
paths=['caelum/survival/CaelumContaminationState.zs','caelum/survival/CaelumContaminationObject.zs']
diagnostics=['caelum/world/CaelumPhysicalHazards.zs','caelum/world/CaelumSewerMaze.zs']
with zipfile.ZipFile(a.baseline) as old,zipfile.ZipFile(a.runtime) as new,zipfile.ZipFile(a.candidate) as prototype:
    names=set(new.namelist());assert names==set(old.namelist())
    assert names=={p.relative_to(ROOT/'src').as_posix() for p in (ROOT/'src').rglob('*') if p.is_file()}
    changed=[]
    for name in sorted(names):
        data=new.read(name);assert data==(ROOT/'src'/name).read_bytes(),name
        if data!=old.read(name):changed.append(name)
    assert changed==sorted(paths+diagnostics),changed
    assert set(prototype.namelist())==set(paths)
    for name in paths:assert new.read(name)==prototype.read(name)
    for name in diagnostics:assert old.read(name).replace(b'[Caelum 5.17.102]',b'[Caelum 5.17.103]')==new.read(name)
    source_sha={name:sha(new.read(name)) for name in paths}
assert not subprocess.check_output(['git','diff','--name-only','HEAD','--','pending_test.txt'],cwd=ROOT).strip()
report=dict(issue=849,passed=True,runtime_sha256=sha(a.runtime.read_bytes()),baseline_sha256=sha(a.baseline.read_bytes()),candidate_source_sha256=source_sha,runtime_members=len(names),runtime_bytes=a.runtime.stat().st_size,changed=changed,no_added_or_removed_members=True,source_package_exact=True,prototype_source_exact=True,author_queue_unchanged=True,qualification='Only native-carrier dispatch, its equivalent exposure eligibility shortcut and two version diagnostics change. Candidate preparation proves ancestry and exact movement of migration/ownership bodies. All other runtime members remain byte-identical.')
a.output.write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n');print(json.dumps(report,indent=2))
