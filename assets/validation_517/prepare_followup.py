"""Package #136 follow-up fixtures deterministically; never modify author saves."""
from pathlib import Path
import importlib.util
import subprocess

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
OUT=ROOT/'build/issue136'
spec=importlib.util.spec_from_file_location('ca136_prepare',HERE/'prepare.py')
base=importlib.util.module_from_spec(spec)
spec.loader.exec_module(base)

def main():
    if 'gzdoom.exe' in subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/NH'],text=True).lower():
        raise SystemExit('Finish native runs before replacing fixtures.')
    base.main()
    package=base.previous.package
    (OUT/'heat-fixed').mkdir(exist_ok=True)
    package('heat-fixed/caelum_argenteum_dev.pk3',{
        p.relative_to(ROOT/'src').as_posix():p.read_bytes() for p in (ROOT/'src').rglob('*') if p.is_file()})
    package('heat-observer.pk3',{
        'ZSCRIPT':b'version "4.14"\n#include "observer.zs"\n',
        'observer.zs':(HERE/'heat_followup.zs').read_bytes(),
        'MAPINFO':b'GameInfo { AddEventHandlers="CA136HeatFollowup" }\n',
        'CVARINFO':b'server int ca136_heat_mode=0;\n'})
    package('activity-budget.pk3',{
        'ZSCRIPT':b'version "4.14"\n#include "activity_budget.zs"\n',
        'activity_budget.zs':(HERE/'activity_budget.zs').read_bytes(),
        'MAPINFO':b'GameInfo { AddEventHandlers="CA136ActivityBudget" }\n'})
    # A server cvar is restored from the save after launch commands. This
    # observer variant must never normalize the state it is verifying.
    (OUT/'heat-reload').mkdir(exist_ok=True)
    package('heat-reload/heat-observer.pk3',{
        'ZSCRIPT':b'version "4.14"\n#include "observer.zs"\n',
        'observer.zs':(HERE/'heat_followup.zs').read_bytes().replace(
            b'int mode=CVar.GetCVar("ca136_heat_mode").GetInt();',b'int mode=4;'),
        'MAPINFO':b'GameInfo { AddEventHandlers="CA136HeatFollowup" }\n',
        'CVARINFO':b'server int ca136_heat_mode=0;\n'})
    (OUT/'heat-motion.cfg').write_text('unbindall;ca136_heat_mode 1;wait 70;+forward;wait 210;-forward;wait 140;+forward;wait 210;-forward;wait 140;+forward;wait 210;-forward;wait 780;quit\n')
    (OUT/'heat-motion-save.cfg').write_text((OUT/'heat-motion.cfg').read_text().replace('wait 70;+forward;wait 210;', 'wait 70;+forward;wait 100;save heat-action-state;wait 110;',1))
    (OUT/'heat.cfg').write_text('unbindall;wait 1760;quit\n')
    (OUT/'heat-fire.cfg').write_text('unbindall;ca136_heat_mode 2;wait 70;+attack;wait 65;-attack;+reload;wait 2;-reload;wait 200;+attack;wait 65;-attack;+reload;wait 2;-reload;wait 200;+attack;wait 65;-attack;wait 1091;quit\n')
    (OUT/'heat-reload.cfg').write_text('unbindall;ca136_heat_mode 4;wait 40;quit\n')
    (OUT/'heat-rollback.cfg').write_text('unbindall;wait 40;quit\n')
    swim='unbindall;ca136_heat_mode 5;cl_run false;wait 70;+forward;wait 350;-forward;wait 70;cl_run true;+forward;wait 350;-forward;wait 920;quit\n'
    (OUT/'swim.cfg').write_text(swim)
    (OUT/'push.cfg').write_text(swim.replace('ca136_heat_mode 5','ca136_heat_mode 6'))
    (OUT/'fp-followup-b.cfg').write_text('unbindall;wait 120;screenshot fp-ready.png;+zoom;wait 2;-zoom;wait 40;screenshot fp-aim.png;+attack;wait 60;-attack;+reload;wait 2;-reload;wait 12;screenshot fp-open.png;wait 90;screenshot fp-load.png;wait 110;ca136_mode 5;wait 105;screenshot fp-single.png;wait 110;ca136_mode 6;wait 105;screenshot fp-partial.png;wait 110;ca136_mode 7;wait 160;screenshot carbine-ready.png;+zoom;wait 2;-zoom;wait 40;screenshot carbine-aim.png;ca136_mode 9;wait 10;quit\n')
    print('Prepared thermal budget and copied-save observers.')

if __name__=='__main__':main()
