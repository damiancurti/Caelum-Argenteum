"""Verify the executed #363 packages, native checks, scripts and state ordering."""
from pathlib import Path
import hashlib
import json
import re
import shutil
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).parent
REQUIRED={
    'issue363-baseline02':['unarmed','sword','save','rollback-final'],
    'issue363-current02':['input--1','input-0','input-1','reject-1','reject-2','exhaust',
        'save','active-save','old-unarmed-final','old-punch-final','current-load','active-load'],
    'issue363-current03':['cooldown'],
    'issue363-current04':['hub'],
    'issue363-current05':['final-input'],
}


def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()


def main():
    evidence=HERE/'evidence';evidence.mkdir(exist_ok=True)
    report={'required':[],'excluded':[],'static':{}}
    total=0
    for directory,names in REQUIRED.items():
        work=ROOT/'build'/directory
        manifest=json.loads((work/'manifest.json').read_text(encoding='utf-8'))
        assert sha(work/'production.pk3')==manifest['runtime_sha256']
        assert sha(work/'quick.pk3')==manifest['fixture_sha256']
        for script,digest in manifest['script_hashes'].items():assert sha(work/script)==digest
        shutil.copyfile(work/'manifest.json',evidence/(directory+'--manifest.json'))
        with zipfile.ZipFile(work/'quick.pk3') as archive:
            (evidence/(directory+'--probe.zs')).write_bytes(archive.read('probe.zs'))
        for label in names:
            log=(work/(label+'.txt')).read_text(encoding='utf-8',errors='replace')
            record=json.loads((work/(label+'-run.json')).read_text(encoding='utf-8-sig'))
            assert record['exit_code']==0 and not record.get('failure'),label
            assert not re.search(r'CA363 FAIL|Script error|VM execution aborted|DIED WITH FATAL ERROR|Cannot find savegame',log),label
            assert re.search(r'CA363 DONE passes=\d+ failures=0',log),label
            assert record['runtime_sha256'].lower()==manifest['runtime_sha256'],label
            assert record['fixture_sha256'].lower()==manifest['fixture_sha256'],label
            commands=work/(label+'-commands.cfg')
            assert sha(commands) in manifest['script_hashes'].values(),label
            checks=len(re.findall(r'^CA363 PASS ',log,re.M));total+=checks
            report['required'].append(dict(directory=directory,label=label,checks=checks,
                runtime_sha256=manifest['runtime_sha256'],fixture_sha256=manifest['fixture_sha256'],
                log_sha256=sha(work/(label+'.txt')),engine_sha256=record['engine_sha256'].lower()))
            for suffix in ('.txt','-run.json','-commands.cfg','.ini'):
                source=work/(label+suffix)
                shutil.copyfile(source,evidence/(directory+'--'+source.name))
    old=ROOT/'build/issue363-baseline02/production.pk3'
    new=ROOT/'build/issue363-current05/production.pk3'
    with zipfile.ZipFile(old) as a,zipfile.ZipFile(new) as b:
        assert a.namelist()==b.namelist()
        changed=[n for n in a.namelist() if a.read(n)!=b.read(n)]
        assert changed==['caelum/equipment/CaelumUnarmedWeapon.zs',
            'caelum/world/CaelumPhysicalHazards.zs','caelum/world/CaelumSewerMaze.zs'],changed
        for name in changed[1:]:
            assert a.read(name).decode().replace('\r\n','\n').replace('[Caelum 5.5.4]','[Caelum 5.5.5]')==b.read(name).decode().replace('\r\n','\n')
        before=a.read(changed[0]).decode().replace('\r\n','\n')
        after=b.read(changed[0]).decode().replace('\r\n','\n')
        states=before.split('    States\n',1)[1].rsplit('    }',1)[0]
        assert after.split('    States\n',1)[1].startswith(states)
        report['static']={'runtime_changes':changed,'old_state_sequence_unchanged':True,
            'baseline_sha256':sha(old),'current_sha256':sha(new),
            'save_schema':'No saved fields added or changed. User2 appended after all previous states.'}
    for directory,label,reason in [
        ('issue363-baseline01','sword','Fixture initially supplied only 100 Adrenaline; the valid channel exhausted before the hold check. Superseded by maximum-resource fixture.'),
        ('issue363-current01','unarmed-early','Same insufficient-resource fixture; not a production failure.'),
        ('issue363-current02','old-unarmed','Harness supplied an absolute -loadgame path; GZDoom prepended savedir. Corrected with preserved save copies and relative basenames.'),
        ('issue363-current02','hub','Hub transfers reconstruct inventory identities and EventHandlers. Fixture incorrectly required pointer equality; corrected checks retain the observed stable ItemId.'),
        ('issue363-baseline02','rollback','The stopped suite had not copied the checkpoint yet. Retried after preserving the current checkpoint under the baseline savedir.')]:
        log=ROOT/'build'/directory/(label+'.txt')
        shutil.copyfile(log,evidence/(directory+'--'+log.name))
        report['excluded'].append({'directory':directory,'label':label,'reason':reason,'log_sha256':sha(log)})
    report['native_runs']=len(report['required']);report['checks']=total
    report['limits']=['Author acceptance pending; no performance claim.',
        'Old punch save establishes successful load and later native User2 usability; no in-flight punch-phase assertion.',
        'Fire/User1/User3/User4 preservation is static evidence; these controls were not exercised by the native fixture.']
    (HERE/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({'native_runs':report['native_runs'],'checks':total,'static':report['static']}))


if __name__=='__main__':main()
