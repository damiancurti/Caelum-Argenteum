"""Collect #407 native evidence, package equivalence and bounded render samples."""
from pathlib import Path
import hashlib
import json
import math
import re
import shutil
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue407'
FINAL=['final-'+name for name in ['contract','trade','craft','storage','regression',
    'upgrade','upgrade-load','legacy-task-load','save','load','travel','task-save','task-load',
    'campaign','gallery','author-smoke','author-save','author-load','live','performance']]
BASELINE=['legacy-save','legacy-task-save','rollback']
DELIVERY=['delivery-contract','delivery-author-smoke']


def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    native=HERE/'native';native.mkdir(exist_ok=True)
    package=WORK/'current/caelum_argenteum_dev.pk3';package_hash=sha(package)
    functional_package=WORK/'final/caelum_argenteum_dev.pk3';functional_hash=sha(functional_package)
    runs=[];total=0;baseline_total=0
    for meta in sorted(WORK.glob('*-run.json')):
        record=json.loads(meta.read_text(encoding='utf-8-sig'));label=record['label'];log=WORK/f'{label}.txt'
        if not log.exists():continue
        text=log.read_text(encoding='utf-8',errors='replace')
        passed=len(re.findall(r'CA(?:407|376) PASS ',text));failed=len(re.findall(r'CA(?:407|376) FAIL ',text))
        selected=label in FINAL or label in BASELINE or label in DELIVERY
        if selected:
            assert record.get('exit_code')==0 and not record.get('timed_out'),label
            assert passed>0 and failed==0,label
            assert not re.search(r'Script error|VM execution aborted|failed=[1-9]|Cannot find savegame|This savegame needs',text),label
            if label in FINAL:
                assert record['package_sha256'].lower()==functional_hash,label
                total+=passed
            elif label in DELIVERY:
                assert record['package_sha256'].lower()==package_hash,label
                total+=passed
            else:baseline_total+=passed
        shutil.copy2(log,native/log.name)
        runs.append({**record,'selected':selected,'passed':passed,'failed':failed,'log_sha256':sha(log)})
    assert {r['label'] for r in runs if r['selected']}==set(FINAL+BASELINE+DELIVERY)
    with zipfile.ZipFile(package) as shipped,zipfile.ZipFile(functional_package) as tested:
        assert set(shipped.namelist())==set(tested.namelist())
        delta=[name for name in shipped.namelist() if shipped.read(name)!=tested.read(name)]
        assert set(delta)=={'caelum/world/CaelumPhysicalHazards.zs','caelum/world/CaelumSewerMaze.zs'}
        for name in delta:assert tested.read(name).replace(b'[Caelum 5.7.4]',b'[Caelum 5.7.5]')==shipped.read(name)
    with zipfile.ZipFile(package) as z:
        files={p.relative_to(ROOT/'src').as_posix():p for p in (ROOT/'src').rglob('*') if p.is_file()}
        assert set(z.namelist())==set(files)
        for name,p in files.items():assert z.read(name)==p.read_bytes(),name
    originals=json.loads((WORK/'original-saves.json').read_text(encoding='utf-8'))
    for name,digest in originals.items():assert sha(WORK/name)==digest,name
    perf=(WORK/'final-performance.txt').read_text(encoding='utf-8')
    frames=list(map(float,re.findall(r'CA407 FRAME ([\d.]+)',perf)))
    start=re.search(r'CA407 PERF BEGIN tic=(\d+) ms=([\d.]+)',perf)
    end=re.search(r'CA407 PERF END tic=(\d+) ms=([\d.]+)',perf)
    assert len(frames)>500 and start and end
    ordered=sorted(frames)
    performance={'sample':'two new 3D material drops in the isolated room, visible window, 1280x720 Vulkan, 60-FPS cap',
        'render_callbacks':len(frames),'mean_ms':sum(frames)/len(frames),
        'p95_ms':ordered[math.ceil(len(frames)*.95)-1],'p99_ms':ordered[math.ceil(len(frames)*.99)-1],
        'worst_ms':max(frames),'render_callback_fps':len(frames)*1000/sum(frames),
        'simulation_tics_per_second':(int(end[1])-int(start[1]))*1000/(float(end[2])-float(start[2])),
        'presentation':'Not measured: PresentMon access was denied in #470 on this same environment. Render callbacks are not application presentation, monitor refresh or GPU timing.'}
    captures={name:sha(WORK/name) for name in ['marine-front.png','marine-side.png','iodine-menu.png']}
    report={'issue':407,'version':'5.7.5','selected_current_runs':len(FINAL+DELIVERY),'current_passed':total,
        'baseline_runs':len(BASELINE),'baseline_passed':baseline_total,'failed':0,
        'package_sha256':package_hash,'source_matching_members':len(files),
        'tested_functional_package_sha256':functional_hash,'delivery_delta':delta,
        'delivery_delta_validation':'Only two diagnostic release strings changed; exact byte replacement checked for both members. All other 16,462 members are identical. Contract and physical Use repeated on the shipped package.',
        'original_saves':originals,'performance':performance,'local_captures':captures,
        'determinism':json.loads((WORK/'determinism.json').read_text(encoding='utf-8')),
        'static':json.loads((WORK/'static-final.json').read_text(encoding='utf-8')),
        'author_acceptance':'CA407-01 pending; previous issue acceptance does not accept this patch.','runs':runs}
    assert report['static']['errors']==[]
    (HERE/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(json.dumps({k:report[k] for k in ['selected_current_runs','current_passed','baseline_runs','baseline_passed','package_sha256','source_matching_members','performance']},indent=2))


if __name__=='__main__':main()
