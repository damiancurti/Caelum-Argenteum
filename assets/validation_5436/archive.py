"""Archive scoped native evidence and reject incomplete house-door checks."""
from pathlib import Path
import gzip
import hashlib
import json
import re
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).parent
EXPECTED={'normal1':6,'normal3':6,'vehicle4-1':13,'vehicle4-0':8,'vehicle3-1':14,'vehicle3-0':9}
RUNTIME_FILES=('caelum/world/CaelumHouseHub.zs','caelum/core/CaelumConstants.zs','caelum/player/CaelumPlayer.zs','caelum/ui/CaelumMenuAudio.zs')

def digest(data):return hashlib.sha256(data).hexdigest()
def read_json(path):return json.loads(path.read_text(encoding='utf-8-sig'))
def frozen(folder,label,count):
    manifest=read_json(folder/'manifest.json');run=read_json(folder/f'{label}-run.json')
    assert run['exit_code']==0,(folder,label,run)
    for item,key in (('production.pk3','runtime_sha256'),('quick.pk3','fixture_sha256')):
        assert digest((folder/item).read_bytes())==manifest[key]==run[key].lower(),(folder,label,key)
    log=(folder/f'{label}.txt').read_bytes();text=log.decode('utf-8',errors='replace')
    assert not re.search(r'CA282 FAIL|Script error|VM execution aborted|JIT error',text),(folder,label)
    marks=re.findall(r'CA282 DONE passes=(\d+) failures=(\d+)',text)
    assert marks and tuple(map(int,marks[-1]))==(count,0),(folder,label,marks)
    assert len(re.findall(r'^CA282 PASS ',text,re.M))==count,(folder,label,'actual assertions')
    return manifest,run,text

def retain(folder):
    target=HERE/'evidence'/folder.name;target.mkdir(parents=True,exist_ok=True)
    for p in folder.iterdir():
        if p.suffix in ('.json','.cfg'):(target/p.name).write_bytes(p.read_bytes())
        elif p.suffix=='.txt':(target/(p.name+'.gz')).write_bytes(gzip.compress(p.read_bytes(),mtime=0))
    with zipfile.ZipFile(folder/'quick.pk3') as source:
        for name in source.namelist():
            if name.endswith('.zs') or name in ('MAPINFO','ZSCRIPT'):(target/name).write_bytes(source.read(name))
    with zipfile.ZipFile(folder/'production.pk3') as source:
        for name in RUNTIME_FILES:(target/(Path(name).name+'.gz')).write_bytes(gzip.compress(source.read(name),mtime=0))
    saves=[]
    for p in folder.rglob('*.zds'):
        with zipfile.ZipFile(p) as z:info=json.loads(z.read('info.json'))
        saves.append({'file':p.relative_to(folder).as_posix(),'sha256':digest(p.read_bytes()),'info':info})
    (target/'save-identities.json').write_text(json.dumps(saves,indent=2)+'\n',encoding='utf-8')

def main():
    main=ROOT/'build/issue334-candidate01';reload=ROOT/'build/issue334-reload01'
    checks=[]
    for label,count in EXPECTED.items():
        folder=ROOT/'build/issue334-cart01' if label.startswith('vehicle3') else main
        manifest,run,text=frozen(folder,label,count)
        if label.endswith('-1'):
            assert 'CA334 FIRST_HOUSE_OVERLAY active=0 frame=0 wipe=0' in text,label
            assert re.search(r'CA334 EVENT name=ca_map_depart arg0=-1 arg1=0 map=MAP03',text),label
        if label.startswith('normal'):
            assert text.count('Game saved.')==2,label
        checks.append({'directory':folder.name,'label':label,'assertions':count,'runtime_sha256':manifest['runtime_sha256'],'fixture_sha256':manifest['fixture_sha256']})
    assert len({c['runtime_sha256'] for c in checks})==1
    for label in ('load-inside','load-outside'):
        manifest,run,text=frozen(reload,label,4)
        assert manifest['runtime_sha256']==checks[0]['runtime_sha256']
        checks.append({'directory':reload.name,'label':label,'assertions':4,'runtime_sha256':manifest['runtime_sha256'],'fixture_sha256':manifest['fixture_sha256']})
    frozen(ROOT/'build/issue334-vehicle01','ship-early',12)
    frozen(ROOT/'build/issue334-baseline01','normal1',6)
    for name in ('issue334-candidate01','issue334-cart01','issue334-reload01','issue334-vehicle01','issue334-baseline01'):retain(ROOT/'build'/name)
    files={p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()}
    for p in (main/'production.pk3',ROOT/'build/caelum_argenteum_dev.pk3'):
        with zipfile.ZipFile(p) as z:
            assert set(z.namelist())==set(files),p
            for name,raw in files.items():assert z.read(name)==raw,(p,name)
    report={'issue':334,'release':'5.4.36','baseline_commit':'5ac918a8','final_runtime_sha256':checks[0]['runtime_sha256'],
        'runs':len(checks),'assertions':sum(c['assertions'] for c in checks),'checks':checks,
        'normal_source_tested_members':len(files),'gate_passed':True,'author_acceptance':'CA334-01 accepted 2026-10-18; explicit house-transition approval; no reported qualifications',
        'limitation':'Early house approach is injected after real vehicle travel; ordinary author-reported wipe remains unconfirmed.'}
    (HERE/'evidence.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({k:v for k,v in report.items() if k!='checks'}))

if __name__=='__main__':main()
