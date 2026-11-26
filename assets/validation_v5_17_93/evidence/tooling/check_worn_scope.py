"""Check additive fitted resources, exact packaging and repeatable exports."""
from pathlib import Path
import argparse,hashlib,json,subprocess,zipfile
ROOT=Path(__file__).resolve().parents[2]
BASE='27af73b81c9427b71e218349a7f896485155858c'


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ['runtime','export-one','export-two','output']:parser.add_argument('--'+name,type=Path,required=True)
    args=parser.parse_args();digest=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
    original=subprocess.check_output(['git','ls-tree','-r','--name-only',BASE,'--','src'],cwd=ROOT,text=True).splitlines()
    cfg=json.loads((ROOT/'assets/source/art/worn_clothing_829/EXPORT.json').read_text())
    assert not cfg.get('preview_only'),'A provisional fitting overlay cannot establish final delivery.'
    for folder in [args.export_one,args.export_two]:
        assert not json.loads((folder/'manifest.json').read_text()).get('preview_only'),'Repeatability requires complete exports.'
    additions=['src/licenses/WORN_CLOTHING_829.txt']+['src/'+p for p in cfg['sha256'] if p!='MODELDEF']
    versions=['src/caelum/world/CaelumPhysicalHazards.zs','src/caelum/world/CaelumSewerMaze.zs']
    paths={p.relative_to(ROOT).as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
    assert set(paths)==set(original)|set(additions),'Unexpected runtime addition/removal.'
    with zipfile.ZipFile(args.runtime) as package:
        assert len(package.namelist())==len(paths) and set(package.namelist())=={n[4:] for n in paths}
        for name,path in paths.items():assert package.read(name[4:])==path.read_bytes(),name
    changed=subprocess.check_output(['git','diff','--name-only',BASE,'--','src'],cwd=ROOT,text=True).splitlines()
    assert set(changed)-set(additions)==set(versions),'Existing runtime art/behavior changed.'
    for name in versions:
        before=subprocess.check_output(['git','show',BASE+':'+name],cwd=ROOT)
        assert before.replace(b'5.17.92',b'5.17.93').replace(b'\r\n',b'\n')==paths[name].read_bytes().replace(b'\r\n',b'\n'),name
    retained={}
    for folder in ['assets/source/art/domingo_3d_pilot','assets/source/art/character_modules_458','assets/source/art/underbody_827']:
        names=subprocess.check_output(['git','ls-tree','-r','--name-only',BASE,'--',folder],cwd=ROOT,text=True).splitlines()
        for name in names:
            before=subprocess.check_output(['git','show',BASE+':'+name],cwd=ROOT)
            assert before==(ROOT/name).read_bytes(),name
            retained[name]=digest(ROOT/name)
    repeated={}
    for path in sorted(args.export_one.rglob('*')):
        if not path.is_file():continue
        name=path.relative_to(args.export_one).as_posix()
        assert path.read_bytes()==(args.export_two/name).read_bytes(),name
        repeated[name]=digest(path)
    assert len(repeated)==len(cfg['sha256'])+2
    report=dict(issue=829,base_commit=BASE,runtime_sha256=digest(args.runtime),source_entries=len(paths),package_exact_source_bytes=True,
                retained_inputs=retained,repeated_exports=repeated,additions=additions,changed_existing_runtime=versions,
                existing_runtime_art_and_behavior_preserved=True)
    args.output.write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(json.dumps(dict(passed=True,source_entries=len(paths),repeated_files=len(repeated),retained_inputs=len(retained))))


if __name__=='__main__':main()
