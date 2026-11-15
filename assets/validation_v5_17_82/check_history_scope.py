"""Authenticate restored release labels and preserve all other historical content."""
from pathlib import Path
import argparse
import hashlib
import json
import re
import subprocess
import zipfile

ROOT=Path(__file__).resolve().parents[2]


def digest(blob):
    return hashlib.sha256(blob).hexdigest()


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ['baseline-runtime','runtime','output']:
        parser.add_argument('--'+name,type=Path,required=True)
    args=parser.parse_args();out=args.output.resolve();out.relative_to(ROOT/'build')
    audit=json.loads((Path(__file__).with_name('evidence')/'heading-audit.json').read_text())
    baseline=audit['baseline_commit'];cache={}
    def original(commit,name):
        key=(commit,name)
        if key not in cache:cache[key]=subprocess.check_output(['git','show',commit+':'+name],cwd=ROOT)
        return cache[key]
    repaired={(r['document'],r['issue']):r for r in audit['repairs']}
    assert len(audit['rows'])==40 and len(repaired)==4
    for row in audit['rows']:
        origin=original(row['original_commit'],row['document']).decode('utf-8')
        before=original(baseline,row['document']).decode('utf-8')
        current=(ROOT/row['document']).read_text(encoding='utf-8')
        assert origin.splitlines().count(row['original_heading'])==1
        assert before.splitlines().count(row['before_heading'])==1
        expected=repaired.get((row['document'],row['issue']),{}).get('after_heading',row['before_heading'])
        assert current.splitlines().count(expected)==1
        assert re.search(r'5\.17\.\d+',expected)[0]==row['original_version']
    preserved=[]
    for name in sorted({r['document'] for r in audit['rows']}):
        current=(ROOT/name).read_text(encoding='utf-8')
        start=current.index('\n## 5.17.82');end=current.index('\n## ',start+4)
        normalized=current[:start]+current[end:]
        normalized,count=re.subn(r'(Documentation version:\s*\*\*)5\.17\.82',r'\g<1>5.17.81',normalized,count=1)
        assert count==1
        for row in audit['repairs']:
            if row['document']==name:
                assert normalized.splitlines().count(row['after_heading'])==1
                normalized=normalized.replace(row['after_heading'],row['before_heading'],1)
        assert normalized==original(baseline,name).decode('utf-8'),name
        preserved.append(name)
    assert original(baseline,'pending_test.txt')==(ROOT/'pending_test.txt').read_bytes()
    changes=subprocess.check_output(['git','diff',baseline,'--name-only','--','assets/source/art','src/models'],cwd=ROOT,text=True)
    assert not changes.strip(),changes
    with zipfile.ZipFile(args.baseline_runtime) as old,zipfile.ZipFile(args.runtime) as current:
        paths={p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
        assert set(paths)==set(current.namelist())==set(old.namelist())
        assert len(paths)==len(current.namelist())==len(old.namelist())
        assert all(current.read(n)==p.read_bytes() for n,p in paths.items())
        changed=sorted(n for n in paths if current.read(n)!=old.read(n))
        assert changed==['caelum/world/CaelumPhysicalHazards.zs','caelum/world/CaelumSewerMaze.zs']
        for n in changed:
            assert old.read(n).count(b'5.17.81')==1
            assert old.read(n).replace(b'5.17.81',b'5.17.82')==current.read(n)
    report=dict(issue=806,passed=True,baseline_commit=baseline,authenticated_headings=40,
                restored_headings=4,historical_content_preserved=preserved,
                pending_author_tests_unchanged=True,art_sources_and_models_unchanged=True,
                runtime_sha256=digest(args.runtime.read_bytes()),baseline_runtime_sha256=digest(args.baseline_runtime.read_bytes()),
                source_entries=len(paths),exact_source_bytes=True,changed_runtime_members=changed,
                runtime_behavior_and_art_unchanged=True)
    out.write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(json.dumps(report))


if __name__=='__main__':
    main()
