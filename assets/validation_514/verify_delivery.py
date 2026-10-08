"""Bind #140 evidence to runtime sources without distributing test packages."""
from pathlib import Path
import hashlib
import json
import subprocess
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue140'


def digest(data):
    return hashlib.sha256(data).hexdigest()


def main():
    src=ROOT/'src'
    sources={p.relative_to(src).as_posix():digest(p.read_bytes()) for p in src.rglob('*') if p.is_file()}
    report={'issue':140,'release':'5.1.4','baseline':'dd8e18bdf12f91648b6d982991c9fda10b787627',
        'runtime_members':len(sources),'source_tree_sha256':digest(json.dumps(sources,sort_keys=True,separators=(',',':')).encode()),
        'packages':{},'post_mechanic_changes':[],'completed_runs':{}}
    for name,path in [('production',WORK/'production.pk3'),('standard',ROOT/'build/caelum_argenteum_dev.pk3'),
                      ('legacy_city',WORK/'legacy/caelum_argenteum_dev.pk3')]:
        with zipfile.ZipFile(path) as z:
            current={n:digest(z.read(n)) for n in z.namelist() if not n.endswith('/')}
        changes=[n for n in sources if sources[n]!=current.get(n)]
        assert set(current)==set(sources)
        assert changes==(['maps/MAP06.wad'] if name=='legacy_city' else []),(name,changes)
        report['packages'][name]={'sha256':digest(path.read_bytes()),'source_differences':changes}
    with zipfile.ZipFile(WORK/'final-tested-runtime.pk3') as tested,zipfile.ZipFile(WORK/'production.pk3') as new:
        assert set(tested.namelist())==set(new.namelist())
        changes=sorted(n for n in tested.namelist() if tested.read(n)!=new.read(n))
        assert changes==['caelum/hud/CaelumHUDOverlay.zs','caelum/hud/CaelumThermalHUD.zs'],changes
        report['post_mechanic_changes']=changes
        report['tested_runtime_sha256']=digest((WORK/'final-tested-runtime.pk3').read_bytes())
    hud=json.loads((HERE/'hud-color-d-run.json').read_text(encoding='utf-8-sig'))
    assert hud['package_sha256'].lower()==report['packages']['production']['sha256']
    report['final_hud_run']='hud-color-d'
    for p in sorted(HERE.glob('*-run.json')):
        r=json.loads(p.read_text(encoding='utf-8-sig'))
        assert 'completed_utc' in r,p
        log=HERE/(r['label']+'.txt')
        report['completed_runs'][r['label']]={'package_sha256':r['package_sha256'],
            'addon_sha256':r['addon_sha256'],'log_sha256':digest(log.read_bytes()),'expected':r.get('expected')}
    report['limitations']=['No paired mass-scene performance claim: author deferred it.',
        'Microtiming measures only a dry solver workload, not frames or full actor updates.',
        'Old component runs retain individual package hashes; only qualified evidence is reused.',
        'Original CA140-01/02 accepted before firearm/shivering extension; later scope has separate evidence.']
    validation=subprocess.run(['python','validate_project.py'],cwd=ROOT,capture_output=True,text=True,encoding='utf-8')
    assert validation.returncode==0,validation.stdout+validation.stderr
    (HERE/'STATIC.json').write_text(validation.stdout,encoding='utf-8')
    report['static_sha256']=digest((HERE/'STATIC.json').read_bytes())
    (HERE/'MANIFEST.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print('Source/package comparison and static validation passed; manifest updated.')


if __name__=='__main__':
    main()
