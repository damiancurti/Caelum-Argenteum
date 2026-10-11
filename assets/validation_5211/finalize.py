"""Archive text-only evidence and verify official package provenance for #194."""
from pathlib import Path
import hashlib
import json
import re
import subprocess
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue194'
FINAL=['release-energy','release-combat','release-player','release-motion',
       'release-siege','release-pressure','release-contacts-save','release-contacts-reload']


def digest(data):
    return hashlib.sha256(data).hexdigest()


def write_json(path, value):
    path.write_text(json.dumps(value,indent=2,ensure_ascii=False)+'\n',encoding='utf-8',newline='\n')


def main():
    validation=subprocess.run(['python','-X','utf8','validate_project.py'],cwd=ROOT,capture_output=True,text=True,encoding='utf-8',check=True)
    official=ROOT/'build/caelum_argenteum_dev.pk3'
    tested=WORK/'production.pk3'
    with zipfile.ZipFile(official) as package, zipfile.ZipFile(tested) as matrix:
        expected={p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
        assert set(package.namelist())==set(expected)
        assert all(package.read(name)==path.read_bytes() for name,path in expected.items())
        differences=[name for name in package.namelist() if package.read(name)!=matrix.read(name)]
        # The final validator required the MAP02 diagnostic release label to advance.
        if differences:
            assert differences==['caelum/world/CaelumSewerMaze.zs']
            assert package.read(differences[0])==matrix.read(differences[0]).replace(b'[Caelum 5.2.10]',b'[Caelum 5.2.11]')
        members={name:digest(package.read(name)) for name in sorted(package.namelist()) if name.lower().endswith('.zs') or name=='ZSCRIPT'}
    counts={}
    for label in FINAL+['legacy-baseline-save','legacy-production-reload']:
        log=(WORK/f'{label}.txt').read_text(encoding='utf-8-sig')
        marker=re.search(r'CA194 DONE failures=0 passes=(\d+)',log)
        assert marker and 'CA194 FAIL' not in log,label
        counts[label]=int(marker[1])
    assert sum(counts[label] for label in FINAL)==240
    native_compile=json.loads((WORK/'official-compile-run.json').read_text(encoding='utf-8-sig'))
    assert native_compile['exit_code']==0
    assert native_compile['runtime_sha256'].lower()==digest(official.read_bytes())
    power=json.loads((WORK/'power-request.json').read_text(encoding='utf-8-sig'))
    assert power.get('release_result') and power['active_plan_before']==power['active_plan_after']
    evidence=HERE/'evidence';evidence.mkdir(exist_ok=True)
    for path in sorted(WORK.iterdir()):
        if path.name.endswith('-run.json') or (path.suffix=='.txt' and (WORK/f'{path.stem}-run.json').exists()) or path.name in ('power-request.json','manifest.json'):
            (evidence/path.name).write_text(path.read_text(encoding='utf-8-sig'),encoding='utf-8',newline='\n')
    (evidence/'validate-project.json').write_text(validation.stdout,encoding='utf-8',newline='\n')
    write_json(HERE/'STATIC.json',{
        'version':'5.2.11','baseline':'e9af270778aa4d9ea0d1323101d120019076c41e',
        'official_sha256':digest(official.read_bytes()),'matrix_runtime_sha256':digest(tested.read_bytes()),
        'official_source_members':len(expected),'all_official_members_equal_src':True,
        'matrix_to_official_differences':differences,
        'difference_reason':'Only MAP02 diagnostic version label: 5.2.10 -> 5.2.11; no gameplay delta.',
        'runtime_source_sha256':members,'validator':json.loads(validation.stdout),
        'official_native_compile':'evidence/official-compile-run.json'})
    write_json(HERE/'AUDIT.json',{
        'current_matrix_passes':240,'native_pass_counts':counts,
        'author_acceptance':'CA194-01 pending',
        'evidence_newlines':'UTF-8 without BOM, LF; content and failures preserved.',
        'native_text_runs':len(list(evidence.glob('*-run.json'))),
        'power_request_released_utc':power['released_utc'],
        'fixture_hashes':{p.name:digest(p.read_bytes()) for p in sorted(HERE.iterdir()) if p.suffix in ('.zs','.cfg','.py','.ps1')},
        'review':'Independent read-only agent review; geometry/wear/pressure/cushion findings corrected and tested.'})
    print(f'Archived {len(list(evidence.glob("*-run.json")))} native runs; 240 current + 6 legacy-load assertions; {len(expected)} exact official members.')


if __name__=='__main__':
    main()
