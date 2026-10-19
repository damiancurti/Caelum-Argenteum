"""Validate frozen #313 inputs, native checks and serialized ammunition state."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).parent
FINAL='faf4d3e0b391533316c0a0d68300758e73987a5959f4d30385ad0a02c9bc46a9'
OLD='4693f37eb27a0d3bd7502f8c6bb4f379ac697243dbd69e3d606b9040d329a5de'
# Counts are checks executed in this process, not serialized handler counters.
REQUIRED={
    'issue313-current03':{'inventory':65,'fire':32,'ranged':1028,'current-save':2},
    'issue313-current04':{'current-load':33,'old-upgrade':33,
                          'upgraded-reload':33,'original-rollback':33,
                          'upgraded-rollback':33},
    'issue313-current05':{'hub':29},
    'issue313-current08':{'preview-smoke':0},
    'issue313-original02':{'original-save':2},
}

def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()

def save_state(p):
    with zipfile.ZipFile(p) as z:
        objects=[]
        for n in z.namelist():
            if n.endswith(('.map.json','.mapd.json')):objects+=json.loads(z.read(n))['objects']
    result={'sha256':sha(p),'ammo':[]}
    for o in objects:
        if 'class:CaelumCarbineAmmo' in o:
            result['ammo'].append({'class':o['classtype'],'amount':o['class:Inventory']['Amount'],
                                   'in_box':o['class:CaelumCarbineAmmo']['InMagicBox']})
        if o['classtype']=='CA313Probe':result['probe']=o['class:CA313Probe']
        if o['classtype']=='CaelumCarbineProjectile':
            result['projectile']={k:v for k,v in o.items() if k.startswith('class:Caelum') or k in ('vel','statnum','flags')}
        if o['classtype']=='CaelumPlayer':
            result['magazines']={k:v for k,v in o.get('class:CaelumPlayer',{}).items() if 'magazine' in k.lower()}
    assert sorted((a['class'],a['amount'],a['in_box']) for a in result['ammo'])==[
        ('CaelumArrowAmmo',100,0),('CaelumBoltAmmo',100,0),('CaelumCarbineAmmo',100,0),('CaelumShotgunAmmo',100,0)]
    assert result['probe']['SavedFlight'] is not None and result['probe']['FlightDamage']==100
    assert result['probe']['FlightType']==2 and result['probe']['FlightTier']==1
    assert result['projectile'] and result['magazines']
    return result

def main():
    out=HERE/'evidence';out.mkdir(exist_ok=True)
    report={'required':[],'excluded':[],'saves':{},'notes':[
        'Author acceptance is separate. No FPS claim.',
        'Current03 production is final; current04 only clears the fixture selection ItemId before selecting ammunition.',
        'Saved projectile is a real missile suspended with STAT_STATIC: serialization is tested, resumed flight is not.',
        'Hub checks inventory and magazines only; the injected static missile is absent on return. It is tested by direct save/load.',
        'Exploratory failures are retained and excluded from successful gates.']}
    seen=set();engines=set()
    for directory in sorted((ROOT/'build').glob('issue313-*')):
        mp=directory/'manifest.json'
        if not mp.is_file():continue
        manifest=json.loads(mp.read_text(encoding='utf-8'))
        shutil.copyfile(mp,out/(directory.name+'--manifest.json'))
        for rp in sorted(directory.glob('*-run.json')):
            record=json.loads(rp.read_text(encoding='utf-8-sig'));label=record['label']
            lp=directory/(label+'.txt');log=lp.read_text(encoding='utf-8',errors='replace') if lp.exists() else ''
            markers=re.findall(r'CA194 DONE failures=(\d+) passes=(\d+)',log)
            problems=[s for s in log.splitlines() if re.search(r'CA(?:194|192) FAIL|Script error|VM execution aborted|DIED WITH FATAL ERROR|Cannot find savegame|This savegame needs|Not in a level|different level',s)]
            required=label in REQUIRED.get(directory.name,{})
            entry={'directory':directory.name,'label':label,'exit_code':record.get('exit_code'),
                   'checks':len(re.findall(r'^CA(?:194|192) PASS ',log,re.M)),
                   'markers':markers,'problems':problems,'record_sha256':sha(rp),
                   'log_sha256':sha(lp) if lp.exists() else None}
            for p in (rp,lp):
                if p.exists():shutil.copyfile(p,out/(directory.name+'--'+p.name))
            if not required:report['excluded'].append(entry);continue
            assert record.get('exit_code')==0 and markers and not problems,entry
            assert all(int(f)==0 for f,_ in markers),entry
            assert entry['checks']==REQUIRED[directory.name][label],entry
            args=[s.strip('"') for s in record['arguments']];index=args.index('-file')
            runtime=Path(args[index+1]);fixture=Path(args[index+2]);command=Path(args[args.index('+exec')+1])
            expected=OLD if label in ('original-save','original-rollback','upgraded-rollback') else FINAL
            assert sha(runtime)==record['runtime_sha256'].lower()==expected,entry
            assert sha(fixture)==record['fixture_sha256'].lower()==manifest['fixtures'][fixture.name],entry
            assert sha(command) in manifest['script_hashes'].values(),entry
            for n,digest in manifest['script_hashes'].items():assert sha(directory/n)==digest,(directory,n)
            for p in (command,directory/(label+'.ini')):
                shutil.copyfile(p,out/(directory.name+'--'+p.name))
            entry['executed_script_sha256']=sha(command);entry['runtime_sha256']=expected
            assert (directory.name,label) not in seen,'Duplicate required run label'
            seen.add((directory.name,label));engines.add(record['engine_sha256'].lower());report['required'].append(entry)
        if directory.name in REQUIRED:
            with zipfile.ZipFile(directory/'qa.pk3') as z:
                (out/(directory.name+'--frozen-probe.zs')).write_bytes(z.read('probe.zs'))
    assert seen=={(d,n) for d,names in REQUIRED.items() for n in names},'Missing required runs'
    assert len(engines)==1
    for label,rel in {
        'current':'issue313-current03/ca313-ammo.zds',
        'original':'issue313-original02/ca313-ammo.zds',
        'original_copy':'issue313-current04/original-ammo.zds',
        'upgraded':'issue313-current04/ca313-upgraded.zds',
    }.items():report['saves'][label]=save_state(ROOT/'build'/rel)
    assert report['saves']['original']['sha256']==report['saves']['original_copy']['sha256']
    assert report['saves']['original']['probe']['SavedUnit']==0.003
    assert report['saves']['current']['probe']['SavedUnit']==0.04
    # Only the five intended production members differ from the accepted baseline.
    def members(p):
        with zipfile.ZipFile(p) as z:return {n:z.read(n) for n in z.namelist()}
    before=members(ROOT/'build/issue312-final02/production.pk3')
    after=members(ROOT/'build/issue313-current04/production.pk3')
    assert before.keys()==after.keys()
    changed=sorted(n for n in before if before[n]!=after[n])
    expected=['caelum/core/CaelumConstants.zs','caelum/equipment/CaelumInventoryService.zs',
              'caelum/equipment/CaelumShotgunRules.zs','caelum/world/CaelumPhysicalHazards.zs','caelum/world/CaelumSewerMaze.zs']
    assert changed==expected,changed
    report['changed_production_members']=changed;report['engine_sha256']=engines.pop()
    report['native_checks']=sum(r['checks'] for r in report['required'])
    report['runtime_sha256']=FINAL
    preview=ROOT/'build/issue313-current08/preview.png'
    assert preview.is_file()
    shutil.copyfile(preview,out/'preview.png');report['preview_image_sha256']=sha(preview)
    (HERE/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(json.dumps({'runs':len(seen),'checks':report['native_checks'],'changed_members':changed}))

if __name__=='__main__':main()
