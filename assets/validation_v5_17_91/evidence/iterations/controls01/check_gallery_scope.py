"""Prove #825 fixture repeatability and unchanged production behavior/art."""
from pathlib import Path
import argparse,hashlib,json,subprocess,zipfile
ROOT=Path(__file__).resolve().parents[2]
BASE='160473b3d41426cc1821c2a7a566286dc3b9bfa4'


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--runtime',type=Path,required=True);p.add_argument('--output',type=Path,required=True)
    a=p.parse_args();sha=lambda q:hashlib.sha256(q.read_bytes()).hexdigest()
    retained={}
    for number in [682,709]:
        name=f'assets/source/art/regional_gallery_{number}/GALLERY.json'
        old=subprocess.check_output(['git','show',BASE+':'+name],cwd=ROOT)
        assert (ROOT/name).read_bytes()==old
        retained[name]=sha(ROOT/name)
    one=ROOT/'build/issue825-export01';two=ROOT/'build/issue825-export02'
    names=sorted(q.name for q in one.iterdir() if q.is_file())
    assert names==['GALLERY_MANIFEST.json','TEXTMAP.txt','gallery.pk3','gallery.zs']
    assert all((one/n).read_bytes()==(two/n).read_bytes() for n in names)
    paths={q.relative_to(ROOT/'src').as_posix():q for q in (ROOT/'src').rglob('*') if q.is_file()}
    with zipfile.ZipFile(a.runtime) as z:
        assert len(z.namelist())==len(paths) and set(z.namelist())==set(paths)
        assert all(z.read(n)==q.read_bytes() for n,q in paths.items())
    changed=subprocess.check_output(['git','diff','--name-only',BASE,'--','src'],cwd=ROOT,text=True).splitlines()
    assert changed==['src/caelum/world/CaelumPhysicalHazards.zs','src/caelum/world/CaelumSewerMaze.zs']
    for name in changed:
        old=subprocess.check_output(['git','show',BASE+':'+name],cwd=ROOT).decode()
        assert old.replace('5.17.90','5.17.91')==(ROOT/name).read_text(encoding='utf-8')
    report=dict(issue=825,base_commit=BASE,runtime_sha256=sha(a.runtime),source_entries=len(paths),package_exact_source_bytes=True,retained_gallery_sha256=retained,repeated_files=4,repeated_fixtures={n:sha(one/n) for n in names},changed_runtime_resources=changed,all_production_art_and_behavior_exact=True)
    a.output.write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(json.dumps(dict(passed=True,repeated_files=4,source_entries=len(paths))))


if __name__=='__main__':main()
