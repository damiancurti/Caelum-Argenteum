"""Verify the final model package and repeated exports without changing gameplay."""
from pathlib import Path
import argparse,hashlib,json,zipfile

ROOT=Path(__file__).resolve().parents[2]


def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ['runtime','baseline','first-export','second-export','output']:
        parser.add_argument('--'+name,type=Path,required=True)
    args=parser.parse_args()
    a=args.first_export.resolve(strict=True);b=args.second_export.resolve(strict=True)
    files=sorted(p.relative_to(a).as_posix() for p in a.rglob('*') if p.is_file())
    expected_exports={'caelum/data/distinct_form_combat.modeldef','manifest.json','preview.pk3',
        'models/caelum/folklore/distinctforms/materials.png'}
    for kind in ['xalpen', 'luzmala', 'anchimallen', 'huayrapuca']:
        expected_exports.update({f'editable/{kind}.obj',f'editable/{kind}.mtl',
            f'models/caelum/folklore/distinctforms/{kind}.md3'})
    assert set(files)==expected_exports
    assert {p.relative_to(b).as_posix() for p in b.rglob('*') if p.is_file()}==expected_exports
    assert all((a/n).read_bytes()==(b/n).read_bytes() for n in files)
    source={p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
    with zipfile.ZipFile(args.runtime) as new,zipfile.ZipFile(args.baseline) as old:
        assert len(new.namelist())==len(source) and set(new.namelist())==set(source)
        assert all(new.read(n)==p.read_bytes() for n,p in source.items())
        before=set(old.namelist());after=set(new.namelist());assert not before-after
        added=sorted(after-before)
        expected=['caelum/data/distinct_form_combat.modeldef']+['models/caelum/folklore/distinctforms/'+n for n in ['xalpen.md3', 'luzmala.md3', 'anchimallen.md3', 'huayrapuca.md3', 'materials.png']]
        assert added==sorted(expected)
        changed=sorted(n for n in before if old.read(n)!=new.read(n))
        assert changed==['MODELDEF','caelum/world/CaelumPhysicalHazards.zs','caelum/world/CaelumSewerMaze.zs']
        for n in changed[1:]:assert old.read(n).replace(b'5.17.89',b'5.17.90')==new.read(n)
        line=b'#include "caelum/data/distinct_form_combat.modeldef"'
        assert new.read('MODELDEF')==old.read('MODELDEF').rstrip()+b'\n'+line+b'\n'
    result=dict(issue=822,runtime_sha256=digest(args.runtime),baseline_sha256=digest(args.baseline),
        package_exact_source_bytes=True,source_entries=len(source),added_resources=added,
        changed_resources=changed,all_other_runtime_bytes_identical=True,
        repeated_files=len(files),export_sha256={n:digest(a/n) for n in files})
    args.output.write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(json.dumps(dict(passed=True,source_entries=len(source),repeated_files=len(files))))


if __name__=='__main__':main()
