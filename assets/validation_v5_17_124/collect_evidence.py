"""Retain bounded native evidence without distributing runtime/test packages or saves."""
import hashlib
import json
import shutil
import subprocess
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
DEST=Path(__file__).with_name('evidence')

def main():
    DEST.mkdir(exist_ok=True)
    report={'issue':460,'version':'5.17.124','author_acceptance':'pending CA460-MOTION-01',
            'environment':'Windows11; GZDoom4.14.2; Vulkan RTX3070Ti; unpaused background; 5% master volume; 60FPS cap; 1520x825',
            'source':{},'native':[],'known_failed_attempts':[]}
    changed=subprocess.check_output(['git','diff','--name-only','0953a15e056d02ea65e24b62c7b3be4909b1451c','--','src'],cwd=ROOT,text=True).splitlines()
    changed+=subprocess.check_output(['git','ls-files','--others','--exclude-standard','--','src'],cwd=ROOT,text=True).splitlines()
    report['source']={p:hashlib.sha256((ROOT/p).read_bytes()).hexdigest() for p in sorted(changed)}
    runs=['issue460-transitions02','issue460-meals02','issue460-visual01','issue460-upgrade01','issue460-rollback03','issue460-presentation01']
    for run in runs:
        source=ROOT/'build'/run;summary=json.loads((source/'SUMMARY.json').read_text())
        report['native'].append({'directory':run,**summary})
        target=DEST/run;target.mkdir(exist_ok=True)
        shutil.copyfile(source/'SUMMARY.json',target/'SUMMARY.json')
        for case in summary['runs']:
            for name in ['native.log','stdout.txt','commands.cfg','command.json']:
                p=source/case['name']/name
                if p.exists():
                    q=target/case['name']/name;q.parent.mkdir(exist_ok=True);shutil.copyfile(p,q)
    for run,case,reason in [
        ('issue460-meals01','input','Fixture used nonexistent ShieldModel.ItemType; corrected to ShieldType.'),
        ('issue460-legacy01','import','Raw backward load warns about unknown appended states and meal paths; not valid visual rollback.'),
        ('issue460-rollback01','import','Replacing modelData with JSON null rejected by native save reader.'),
        ('issue460-rollback02','import','Bare ActorModelData reset rejected; final converter preserves object shape.')]:
        source=ROOT/'build'/run/case/'stdout.txt';target=DEST/'attempts'/(run+'.txt');target.parent.mkdir(exist_ok=True)
        shutil.copyfile(source,target);report['known_failed_attempts'].append({'run':run,'reason':reason})
    for run,case,name,target in [('issue460-transitions02','chair','entering.png','chair-entry.png'),
                                ('issue460-visual01','eat','meal.png','eat-seated.png'),
                                ('issue460-upgrade01','drink','meal.png','drink-lying.png')]:
        shutil.copyfile(ROOT/'build'/run/case/name,DEST/target)
    report['static_models']=json.loads((ROOT/'build/issue460-model-checks.json').read_text())
    a=ROOT/'build/issue460-rollback-copy03/inside.zds';b=ROOT/'build/issue460-rollback-copy04/inside.zds'
    report['rollback_idempotent']=a.read_bytes()==b.read_bytes()
    report['rollback']=json.loads(a.with_suffix('.migration.json').read_text())
    report['reuse']='Transition/meal evidence applies to unchanged paths. Later exhaustion reset is covered by upgrade01; final native compilation/presentation uses that source. Fresh current package still requires author acceptance.'
    report['limitations']=['Optional supported modular body only; other appearances retain fallback poses.',
        'Five-second frame windows measure this single-body fixture, not all maps or siege fluency.',
        'Initial minimized captures were inadequate; later visible-background captures were inspected.',
        'Independent beta packaging and final consolidated terminal belong to remaining issues.']
    (DEST/'SUMMARY.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print('Retained',sum(len(r['runs']) for r in report['native']),'native phases; pending author review')

if __name__=='__main__':main()
