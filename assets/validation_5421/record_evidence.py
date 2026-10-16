"""Record completed native runs and verify package/source parity for issue #252."""
from pathlib import Path
from zipfile import ZipFile
import hashlib
import json
import re

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).parent
work=ROOT/'build/issue252-release-5421'
labels=['formulas','earth','environment','defenses','gravity','presentation','falling',
        'input','interruptions','performance','save','gravity-save','roof','load',
        'gravity-load','travel','upgrade','preview','weather-02']
manifest=json.loads((work/'manifest.json').read_text())
repeat=json.loads((ROOT/'build/issue252-determinism-5421/manifest.json').read_text())
assert manifest==repeat,'Frozen runtime/fixture packaging is not deterministic.'
def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()
assert digest(work/'production.pk3')==manifest['runtime_sha256']
assert digest(work/'seal.pk3')==manifest['fixture_sha256']

runs=[]
for directory,label in [(work,label) for label in labels]+[(ROOT/'build/issue252-legacy-01','seed-02')]:
    record=json.loads((directory/(label+'-run.json')).read_text(encoding='utf-8-sig'))
    log=(directory/(label+'.txt')).read_text(encoding='utf-8-sig')
    assert record['exit_code']==0,(directory,label)
    assert not re.search(r'CA252 FAIL|Script error|VM execution aborted|Could not open|DIED WITH FATAL ERROR',log),(directory,label)
    match=re.search(r'CA252 DONE passes=(\d+) failures=0',log)
    assert match,(directory,label)
    if directory==work:
        assert record['runtime_sha256'].lower()==manifest['runtime_sha256']
        assert record['fixture_sha256'].lower()==manifest['fixture_sha256']
    runs.append({'directory':directory.relative_to(ROOT).as_posix(),'label':label,
                 'passes':int(match[1]),'exit_code':record['exit_code'],
                 'log_sha256':digest(directory/(label+'.txt')),
                 'engine_sha256':record['engine_sha256'].lower(),
                 'runtime_sha256':record['runtime_sha256'].lower(),
                 'fixture_sha256':record['fixture_sha256'].lower(),
                 'script_sha256':digest(directory/Path(record['arguments'][record['arguments'].index('+exec')+1].strip('"')).name)})

source={p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()}
for package in [work/'production.pk3',ROOT/'build/caelum_argenteum_dev.pk3']:
    with ZipFile(package) as archive:
        assert set(archive.namelist())==set(source),package
        assert all(archive.read(name)==content for name,content in source.items()),package
validation=json.loads((ROOT/'build/issue252-release-validation.json').read_text(encoding='utf-16'))
assert not validation['errors'],validation['errors']
log=(work/'performance.txt').read_text(encoding='utf-8-sig')
performance=re.search(r'CA252 PERF bodies=500 baselineSamplesMs=([\d.]+) climateSamplesMs=([\d.]+) earth35TicsMs=([\d.]+)',log)
weather=(work/'weather-02.txt').read_text(encoding='utf-8-sig')
assert weather.count('Temperatura=')==6,'Actual local/regional weather reports are missing.'
temperatures=[float(v) for v in re.findall(r'Temperatura=([\d.-]+)',weather)]
assert abs(temperatures[2]-temperatures[4]-1.7)<0.0002,'Stopped local weather retains a climate contribution.'
result={
    'issue':252,'version':'5.4.21','base':'a3b305b6','gameplay_commit':'3a8bba88',
    'presentation_commit':'26a00596','author_acceptance':'pending CA252-01',
    'runtime_sha256':manifest['runtime_sha256'],'fixture_sha256':manifest['fixture_sha256'],
    'native_runs':len(runs),'native_assertions':sum(r['passes'] for r in runs),'runs':runs,
    'source_members':len(source),'normal_package_matches_source':True,'deterministic_packaging':True,
    'static_errors':validation['errors'],'performance_500_service_ms':{
        'baseline_samples':float(performance[1]),'climate_samples':float(performance[2]),
        'earth_35_continuous_steps':float(performance[3])},
    'performance_scope':'Isolated service costs on 500 living combatant bodies; not a full-battle frame-rate claim.',
    'screenshot_sha256':digest(work/'seal-chase.png'),
    'startup_failure':{'run':'build/issue252-legacy-01/seed-01','zip_sha256':'1aff7af8169cb8607ba82be4b61fbddcbfbac19aeb8980d95f179422792c2d2a',
                       'cause':'Launch raced unfinished fixture preparation; no level entered.',
                       'guard':'Completed manifest, required script and exact package hashes before launch.'}}
(HERE/'evidence.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8',newline='\n')
print(json.dumps({k:result[k] for k in ['native_runs','native_assertions','source_members','static_errors','performance_500_service_ms']}))
