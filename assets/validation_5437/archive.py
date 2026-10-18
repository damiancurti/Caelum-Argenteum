"""Gate and preserve current MAP03 attribution, never packaging engine or IWAD."""
from pathlib import Path
import gzip
import hashlib
import json
import re
import subprocess
import sys
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).parent
LABELS=('peace-forward','peace-ground','siege-city','siege-front')
folders=('issue318-current-base03','issue318-current-profile02')
records=[]
for name in folders:
    folder=ROOT/'build'/name
    subprocess.run([sys.executable,str(HERE/'report.py'),name,'--verify'],cwd=ROOT,check=True,stdout=subprocess.DEVNULL)
    target=HERE/'evidence'/name;target.mkdir(parents=True,exist_ok=True)
    report=json.loads((folder/'attribution.json').read_text())
    manifest=json.loads((folder/'manifest.json').read_text())
    bench=(folder/'benchmarks.txt').read_bytes()
    starts=[m.start() for m in re.finditer(rb'^Map MAP03:',bench,re.M)]+[len(bench)]
    assert len(starts)==5 and starts[0]==0
    stamps=[]
    for i,label in enumerate(LABELS):
        run=json.loads((folder/(label+'-run.json')).read_text(encoding='utf-8-sig'))
        stamps.append(run['started_utc'])
        log=(folder/(label+'.txt')).read_text(encoding='utf-8')
        assert log.count('Benchmark info saved')==1,(name,label)
        part=bench[starts[i]:starts[i+1]]
        assert re.search(rb'^\d+ fps\r?$',part,re.M),(name,label)
        # Readable excerpt; the whole compressed file and byte offsets retain
        # the exact original bytes, including native trailing blank lines.
        (target/(label+'-bench.txt')).write_text(part.decode('utf-8').replace('\r\n','\n').rstrip()+'\n',encoding='utf-8',newline='\n')
        (target/(label+'-bench-range.json')).write_text(json.dumps({'start':starts[i],'end':starts[i+1],
            'bench_sha256':hashlib.sha256(bench).hexdigest(),'assignment':'unique bench per completed run, chronological order'})+'\n',encoding='utf-8')
        records.append({'directory':name,'case':label,'runtime_sha256':manifest['runtime_sha256'],
            'fixture_sha256':manifest['fixture_sha256'],'native_fps_snapshot':int(re.search(rb'^(\d+) fps',part,re.M)[1]),
            'simulation_tics_per_second':report['cases'][label]['simulation_tics_per_second']})
    assert stamps==sorted(stamps),(name,'benchmark order')
    for p in folder.iterdir():
        if p.suffix in ('.json','.cfg','.png'):(target/p.name).write_bytes(p.read_bytes())
        elif p.suffix=='.txt':(target/(p.name+'.gz')).write_bytes(gzip.compress(p.read_bytes(),mtime=0))
    with zipfile.ZipFile(folder/'quick.pk3') as z:
        for filename in z.namelist():
            assert '/' not in filename,filename
            (target/filename).write_bytes(z.read(filename))
with zipfile.ZipFile(ROOT/'build/issue318-current-base03/production.pk3') as z:
    source={p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()}
    assert set(source)==set(z.namelist())
    differences=[]
    for name,data in source.items():
        if data==z.read(name):continue
        assert name in ('caelum/world/CaelumPhysicalHazards.zs','caelum/world/CaelumSewerMaze.zs'),name
        assert data.replace(b'[Caelum 5.4.37]',b'[Caelum 5.4.36]').replace(b'\r\n',b'\n')==z.read(name).replace(b'\r\n',b'\n'),name
        differences.append(name)
final=ROOT/'build/issue318-current-final01'
final_manifest=json.loads((final/'manifest.json').read_text())
final_run=json.loads((final/'peace-forward-run.json').read_text(encoding='utf-8-sig'))
assert final_run['exit_code']==0
final_log=(final/'peace-forward.txt').read_text(encoding='utf-8')
assert final_log.count('CA282 DONE passes=1 failures=0')==1
assert not re.search(r'CA(?:318|282) FAIL|Script error|VM execution aborted|JIT error',final_log)
for filename,key in (('production.pk3','runtime_sha256'),('quick.pk3','fixture_sha256')):
    assert hashlib.sha256((final/filename).read_bytes()).hexdigest()==final_manifest[key]==final_run[key].lower()
for package in (final/'production.pk3',ROOT/'build/caelum_argenteum_dev.pk3'):
    with zipfile.ZipFile(package) as z:
        assert set(z.namelist())==set(source),package
        for name,data in source.items():assert z.read(name)==data,(package,name)
target=HERE/'evidence'/final.name;target.mkdir(parents=True,exist_ok=True)
for p in final.iterdir():
    if p.suffix in ('.json','.cfg'):(target/p.name).write_bytes(p.read_bytes())
    elif p.suffix=='.txt':(target/(p.name+'.gz')).write_bytes(gzip.compress(p.read_bytes(),mtime=0))
report={'issue':318,'release':'5.4.37','measurement_base':'ac7a7143','runs':len(records),'cases':records,
    'measurement_gate_passed':True,'source_members':len(source),'post_measurement_differences':differences,
    'final_label_smoke':{'directory':final.name,'case':'peace-forward','runtime_sha256':final_manifest['runtime_sha256'],
        'assertions':1,'normal_tested_source_members':len(source),'benchmark_excluded':'Final compile smoke overlapped packaging; not a performance sample.'},
    'limits':['Native bench FPS/CPU values are later snapshots, not window means or ETW presentation.',
        'UI callback intervals use full wall-clock containment and are not displayed FPS.',
        'Exclusive method scopes include uninstrumented children and probe overhead; the table is not a whole CPU partition.',
        'One matrix per runtime, roughly ten seconds per observation; no full-siege or stable60FPS acceptance.'],
    'author_acceptance':'All existing #318 checks remain pending; no manual acceptance inferred.'}
(HERE/'evidence.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
print(json.dumps({k:v for k,v in report.items() if k!='cases'}))
