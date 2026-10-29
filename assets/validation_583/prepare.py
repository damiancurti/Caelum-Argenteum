"""Build the private #410 core checks; never distribute the fixture PK3."""
from pathlib import Path
import importlib.util
import zipfile

HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[1]
WORK=ROOT/'build/issue410'


def main():
    WORK.mkdir(parents=True,exist_ok=True)
    spec=importlib.util.spec_from_file_location('room580',ROOT/'assets/validation_580/prepare.py')
    module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
    members={'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n',
             'checks.zs':(HERE/'checks.zs').read_bytes(),
             'MAPINFO':b'GameInfo { AddEventHandlers="CA410Checks" }\ncluster 8410 { hub }\nmap CAF410 "Food checks" { cluster=8410 }\nmap CAF410B "Food return" { cluster=8410 }\n',
             'maps/CAF410.wad':module.wad(module.room(),'CAF410'),
             'maps/CAF410B.wad':module.wad(module.room(),'CAF410B')}
    with zipfile.ZipFile(WORK/'checks.pk3','w',zipfile.ZIP_STORED) as archive:
        for name,blob in sorted(members.items()):
            archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)
    scripts={'core':'wait 35; netevent ca410_core; wait 5; quit',
             'save':'wait 35; netevent ca410_seed; save ca410-illness; wait 5; quit',
             'load':'wait 70; netevent ca410_loaded; wait 5; quit',
             'visual':'language es; wait 35; netevent ca410_preview; wait 5; showpop 3; wait 15; screenshot "food-contamination-hud.png"; wait 5; quit',
             'live':'wait 35; netevent ca410_harm; wait 70; netevent ca410_harmcheck; netevent ca410_immune; wait 70; netevent ca410_immunecheck; netevent ca410_potential; wait 40; netevent ca410_potentialcheck; netevent ca410_report; wait 5; quit',
             'hub':'wait 5; netevent ca410_loaded; changemap CAF410B; wait 35; netevent ca410_loaded; changemap CAF410; wait 35; netevent ca410_loaded; wait 5; quit',
             'old-save':'wait 35; netevent ca410_oldseed; save ca410-pre-feature; wait 5; quit',
             'old-load':'wait 35; netevent ca410_oldload; wait 5; quit'}
    for name,script in scripts.items():
        (WORK/(name+'.cfg')).write_text(script+'\n',encoding='utf-8')
    controls='''exec ../../assets/playtest/default_controls.cfg
language es
bind F1 "netevent ca410_harm"
bind F2 "netevent ca410_immune"
bind F3 "netevent ca410_potential"
bind F4 "netevent ca410_report; toggleconsole"
bind F5 "showpop 3"
'''
    (WORK/'interactive.cfg').write_text(controls+'wait 35; netevent ca410_preview; wait 5; showpop 3\n',encoding='utf-8')
    (WORK/'resume.cfg').write_text(controls+'wait 70; netevent ca410_report\n',encoding='utf-8')
    bridge=(HERE/'compatibility.zs').read_text(encoding='utf-8')
    migration='''let illness=CaelumFoodIllness.Get(u);
            Check(illness!=null && illness.Revision==1 && illness.Contamination==0
                && illness.DamageFraction==0,"pre-feature save migrates illness to clean revision one");
            illness.Contamination=12.5;illness.Ensure();
            Check(illness.Contamination==12.5,"repeat migration preserves newly acquired contamination");'''
    for mode in ('legacy','bridge-current'):
        bridge_members={name:blob for name,blob in members.items() if name.startswith('maps/')}
        bridge_members.update({'ZSCRIPT':b'version "4.14"\n#include "compatibility.zs"\n',
            'MAPINFO':members['MAPINFO'].replace(b'CA410Checks',b'CA410Compatibility'),
            'compatibility.zs':bridge.replace('// CURRENT_MIGRATION_CHECKS',migration if mode=='bridge-current' else '').encode('utf-8')})
        (WORK/'bridge').mkdir(exist_ok=True)
        filename='legacy-checks.pk3' if mode=='legacy' else 'bridge/legacy-checks.pk3'
        with zipfile.ZipFile(WORK/filename,'w',zipfile.ZIP_STORED) as archive:
            for name,blob in sorted(bridge_members.items()):
                archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)


if __name__=='__main__':
    main()
