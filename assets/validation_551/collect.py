"""Record #310 native observations, failures and exact paired/package comparisons."""
from pathlib import Path
import hashlib
import json
import re
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).parent
DIRECTORIES=('issue310-current01','issue310-current02','issue310-current03',
    'issue310-baseline01','issue310-baseline02','issue310-final01','issue310-final02',
    'issue310-old-controls01','issue310-old-controls02','issue310-final03','issue310-old-controls03',
    'issue310-death01','issue310-old-death01','issue310-cast01','issue310-old-cast01',
    'issue310-cast02','issue310-old-cast02')

def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    runs=[];manifests={}
    for directory in DIRECTORIES:
        work=ROOT/'build'/directory
        manifest=json.loads((work/'manifest.json').read_text(encoding='utf-8'))
        manifests[directory]={k:v for k,v in manifest.items() if k!='source_hashes'}
        manifests[directory]['manifest_sha256']=digest(work/'manifest.json')
        manifests[directory]['changed_source_hashes']={k:v for k,v in manifest['source_hashes'].items()
            if k in ('ZSCRIPT','caelum/player/CaelumPlayer.zs','caelum/player/CaelumCombatDispatch.zs',
                     'caelum/world/CaelumPhysicalHazards.zs','caelum/world/CaelumSewerMaze.zs')}
        for log in sorted(work.glob('*.txt')):
            raw=log.read_text(encoding='utf-8-sig');label=log.stem
            record=work/f'{label}-run.json'
            invocation=json.loads(record.read_text(encoding='utf-8-sig')) if record.exists() else None
            expected_runtime=digest(ROOT/'build/caelum_argenteum_dev.pk3') if label=='normal-package-sweep' else manifest['runtime_sha256']
            expected_fixture=manifest['guards_sha256'] if label.startswith('guards-') else manifest['fixture_sha256']
            provenance_valid=bool(invocation and invocation.get('exit_code')==0
                and invocation.get('runtime_sha256','').lower()==expected_runtime.lower()
                and invocation.get('fixture_sha256','').lower()==expected_fixture.lower())
            observations=[l for l in raw.splitlines() if l.startswith(('CA309 ','CA310 '))]
            errors=[l for l in raw.splitlines() if re.search(r'Script error|Unknown identifier|VM execution|FATAL ERROR|Cannot find savegame',l)]
            done=re.findall(r'^CA309 DONE passes=(\d+) failures=(\d+)$',raw,re.M)
            runs.append(dict(directory=directory,label=label,completed=provenance_valid and len(done)==1 and done[0][1]=='0'
                and not errors and 'CA309 FAIL' not in raw,
                checks=int(done[0][0])+int(done[0][1]) if len(done)==1 else None,
                log_sha256=digest(log),errors=errors,provenance_valid=provenance_valid,
                observations=observations,invocation=invocation))
    report=dict(issue=310,release='5.5.1',manifests=manifests,runs=runs)
    (HERE/'evidence.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    required=[('issue310-final02','guards-02'),('issue310-final03','normal-package-sweep'),
        ('issue310-final03','paired-03'),('issue310-old-controls03','paired-03'),
        ('issue310-final03','two-pawns-01'),('issue310-final03','auto-01'),
        ('issue310-final03','held-load-current'),('issue310-final03','boundaries-current')]
    required += [(f'issue310-{directory}',f'stun-{kind}-{suffix}')
        for directory,suffix in (('final03','current'),('old-controls03','baseline')) for kind in (0,)]
    required += [('issue310-cast02','switch-cast-current'),('issue310-old-cast02','switch-cast-baseline')]
    required += [(f'issue310-{directory}',f'death-{kind}-{suffix}')
        for directory,suffix in (('death01','current'),('old-death01','baseline')) for kind in (0,1)]
    required += [('issue310-final03',f'{action}-{kind}-current') for kind in (0,1,2)
        for action in ('save','load','hub','switch')]
    required += [('issue310-final03',f'load-{kind}-legacy') for kind in (0,1,2)]
    for directory,label in required:
        run=next((r for r in runs if r['directory']==directory and r['label']==label),None)
        assert run is not None and run['completed'],f'Missing/failed required run: {directory}/{label}'
    death_pairs=[]
    for kind in (0,1):
        observations=[]
        for directory,suffix in (('issue310-old-death01','baseline'),('issue310-death01','current')):
            run=next(r for r in runs if r['directory']==directory and r['label']==f'death-{kind}-{suffix}')
            observations.append([s for s in run['observations'] if s.startswith('CA310 DEATH ')])
        assert len(observations[0])==1 and observations[0]==observations[1]
        death_pairs+=observations[0]
    saves=[]
    for kind in (0,1,2):
        source=ROOT/f'build/issue309-persist{3 if kind==0 else 4:02d}/action-{kind}.zds'
        target=ROOT/f'build/issue310-final03/legacy-action-{kind}.zds'
        assert digest(source)==digest(target)
        saves.append(dict(origin='5.5.0 / #309',source=str(source.relative_to(ROOT)),
            loaded_copy=str(target.relative_to(ROOT)),sha256=digest(source)))
    pair=[]
    for directory in ('issue310-old-controls03','issue310-final03'):
        run=next(r for r in runs if r['directory']==directory and r['label']=='paired-03')
        assert run['completed'],f'Incomplete paired run: {directory}'
        pair.append(run)
    old,new=(manifests[r['directory']] for r in pair)
    assert pair[0]['invocation']['engine_sha256']==pair[1]['invocation']['engine_sha256']
    assert old['fixture_sha256']==new['fixture_sha256']
    assert old['script_hashes']==new['script_hashes']
    observations=[[s for s in r['observations'] if s.startswith(('CA310 TRACE ','CA310 CASE ','CA310 SWEEP '))] for r in pair]
    if observations[0]!=observations[1]:
        first=next(((i,a,b) for i,(a,b) in enumerate(zip(*observations)) if a!=b),None)
        raise AssertionError(f'Paired trajectory differs: counts={list(map(len,observations))}; first={first}')
    cases=[s for s in observations[0] if s.startswith('CA310 CASE ')]
    assert [int(re.search(r'id=(\d+)',s)[1]) for s in cases]==list(range(20))
    assert len([s for s in observations[0] if s.startswith('CA310 SWEEP ')])==1
    with zipfile.ZipFile(ROOT/'build/issue310-final03/production.pk3') as frozen, zipfile.ZipFile(ROOT/'build/caelum_argenteum_dev.pk3') as normal:
        assert sorted(frozen.namelist())==sorted(normal.namelist())
        assert all(frozen.read(n)==normal.read(n) for n in frozen.namelist())
        count=len(normal.namelist())
    comparison=dict(result='PASS',required_runs=required,old_saves=saves,death_pairs=death_pairs,paired_directories=[r['directory'] for r in pair],
        identical_observations=len(observations[0]),cases=cases,
        normal_package_members=count,normal_package_sha256=digest(ROOT/'build/caelum_argenteum_dev.pk3'),
        baseline_sha256=old['runtime_sha256'],current_sha256=new['runtime_sha256'])
    (HERE/'comparison.json').write_text(json.dumps(comparison,indent=2)+'\n',encoding='utf-8')
    print(json.dumps(dict(result='PASS',required_runs=len(required),
        identical_observations=len(observations[0]),normal_package_members=count)))
    print(f'Preserved {len(runs)} runs, {sum(r["completed"] for r in runs)} completed successfully.')

if __name__=='__main__':main()
