"""Verify metadata-only scope against the preceding commit and tested package."""
from pathlib import Path
import argparse
import hashlib
import json
import re
import subprocess
import sys
import zipfile

ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'assets/generators'))
from validate_beast_men_models import identity_policy_errors


def digest(blob):
    return hashlib.sha256(blob).hexdigest()


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ['baseline-runtime','runtime','output']:
        parser.add_argument('--'+name,type=Path,required=True)
    args=parser.parse_args();out=args.output.resolve();out.relative_to(ROOT/'build')
    evidence=Path(__file__).with_name('evidence')
    proof=json.loads((evidence/'metadata-proof.json').read_text())
    baseline=proof['baseline_commit']
    def original(name):
        return subprocess.check_output(['git','show',baseline+':'+name],cwd=ROOT)
    rows={}
    for folder in proof['models']:
        relative='assets/source/art/'+folder
        old_bytes=original(relative+'/ANIMATION.json')
        old=json.loads(old_bytes)
        current=json.loads((ROOT/relative/'ANIMATION.json').read_text())
        old_policy=json.dumps(old['identity_policy']).encode()
        new_policy=json.dumps(current['identity_policy']).encode()
        assert old_bytes.count(old_policy)==1
        assert old_bytes.replace(old_policy,new_policy)==(ROOT/relative/'ANIMATION.json').read_bytes()
        assert identity_policy_errors(old) and not identity_policy_errors(current)
        assert {k:v for k,v in old.items() if k!='identity_policy'}=={k:v for k,v in current.items() if k!='identity_policy'}
        old_export=json.loads(original(relative+'/EXPORT.json'))
        new_export=json.loads((ROOT/relative/'EXPORT.json').read_text())
        assert {k:v for k,v in old_export.items() if k!='source_sha256'}=={k:v for k,v in new_export.items() if k!='source_sha256'}
        assert set(old_export['source_sha256'])==set(new_export['source_sha256'])
        changed=[n for n,h in old_export['source_sha256'].items() if new_export['source_sha256'][n]!=h]
        assert changed==[relative+'/ANIMATION.json']
        for name,want in old_export['sha256'].items():
            p=ROOT/relative/name if name.startswith('editable/') else ROOT/'src'/name
            assert digest(p.read_bytes())==want,name
        rows[folder]=dict(original_policy_rejected=True,current_policy_passes=True,
                          other_metadata_unchanged=True,source_bytes_only_policy_changed=True,
                          unchanged_artifacts=len(old_export['sha256']))
    for name in ['pending_test.txt','assets/source/art/heads_803/PROVENANCE.json']:
        assert original(name)==(ROOT/name).read_bytes(),name
    version=re.search(r'Current release:\s*(\d+\.\d+\.\d+[a-z]?)',(ROOT/'README.md').read_text())[1]
    old_version=re.search(rb'Current release:\s*(\d+\.\d+\.\d+[a-z]?)',original('README.md'))[1]
    with zipfile.ZipFile(args.baseline_runtime) as old,zipfile.ZipFile(args.runtime) as current:
        paths={p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
        assert set(paths)==set(current.namelist())==set(old.namelist())
        assert len(paths)==len(current.namelist())==len(old.namelist())
        assert all(current.read(n)==p.read_bytes() for n,p in paths.items())
        changed=sorted(n for n in paths if old.read(n)!=current.read(n))
        assert changed==['caelum/world/CaelumPhysicalHazards.zs','caelum/world/CaelumSewerMaze.zs']
        for n in changed:
            assert old.read(n).count(old_version)==1
            assert old.read(n).replace(old_version,version.encode())==current.read(n)
    report=dict(issue=805,passed=True,baseline_commit=baseline,models=rows,
                runtime_sha256=digest(args.runtime.read_bytes()),baseline_runtime_sha256=digest(args.baseline_runtime.read_bytes()),
                source_entries=len(paths),exact_source_bytes=True,changed_runtime_members=changed,
                runtime_behavior_and_art_unchanged=True,pending_author_tests_unchanged=True,historical_provenance_unchanged=True)
    out.write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(json.dumps(report))


if __name__=='__main__':
    main()
