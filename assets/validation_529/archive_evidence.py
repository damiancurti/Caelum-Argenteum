"""Archive selected native evidence, source hashes and official package parity."""
from pathlib import Path
import hashlib
import json
import shutil
import subprocess
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue192'
RUNS=['final-matrix','final-collision','final-diagnostic','official-comparison',
      'creator-es-03','creator-en-final','save-old-01','save-upgrade-final',
      'save-repeat-final','save-rollback-03','travel-final']

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    raw=HERE/'raw';raw.mkdir(exist_ok=True)
    evidence={};archive_hashes={}
    for label in RUNS:
        for suffix in ['.txt','-run.json']:
            source=WORK/(label+suffix)
            shutil.copy2(source,raw/source.name)
            evidence[source.name]=digest(source)
            if suffix=='.txt':
                clean='\n'.join(line.rstrip() for line in source.read_text(encoding='utf-8-sig').splitlines())+'\n'
                (raw/source.name).write_text(clean,encoding='utf-8',newline='\n')
            archive_hashes[source.name]=digest(raw/source.name)
    summaries={}
    for label in RUNS:
        log=(WORK/(label+'.txt')).read_text(encoding='utf-8-sig')
        run=json.loads((WORK/(label+'-run.json')).read_text(encoding='utf-8-sig'))
        assert 'CA192 FAIL' not in log and 'CA192 DONE failures=0' in log and run['exit_code']==0
        summaries[label]={'passes':log.count('CA192 PASS '),'runtime_sha256':run['runtime_sha256']}
    power=json.loads((WORK/'power-request.json').read_text(encoding='utf-8-sig'))
    assert power['release_result'] and power['active_plan_before']==power['active_plan_after']
    shutil.copy2(WORK/'power-request.json',raw/'power-request.json')
    with zipfile.ZipFile(WORK/'official.pk3') as archive:
        members={p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
        assert set(members)==set(archive.namelist())
        assert all(archive.read(name)==p.read_bytes() for name,p in members.items())
    validation=subprocess.run(['python','validate_project.py'],cwd=ROOT,capture_output=True,text=True,check=True).stdout
    (raw/'static.json').write_text(validation,encoding='utf-8')
    audit={'baseline':'52e3bd01','official_package_sha256':digest(WORK/'official.pk3'),
           'runs':summaries,'source_members':len(members),'package_matches_source':True,
           'sources':{name:digest(p) for name,p in members.items() if name.endswith('.zs') or name in ['ZSCRIPT','LANGUAGE']},
           'original_evidence_sha256':evidence,'archived_evidence_sha256':archive_hashes,
           'log_normalization':'UTF-8 LF, trailing whitespace removed; original hashes retained separately',
           'fixtures':{p.name:digest(p) for p in HERE.glob('*') if p.suffix in ['.zs','.cfg','.ps1','.py']},
           'fixture_text_note':'native.zs trailing EOF blank removed after tests; no code change','power':power,'local_save_sha256':{p.name:digest(p) for p in [WORK/'ca192-old.zds',WORK/'ca192-selected.zds']}}
    (HERE/'AUDIT.json').write_text(json.dumps(audit,indent=2,sort_keys=True)+'\n',encoding='utf-8')
    print(f'Archived {len(RUNS)} native runs; {len(members)} official members match source; keep-awake released.')

if __name__=='__main__':
    main()
