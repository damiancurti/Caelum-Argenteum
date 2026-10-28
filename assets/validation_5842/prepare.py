"""Build deterministic private furniture-history fixtures and probe package."""
from pathlib import Path
import argparse, subprocess, zipfile, shutil
R=Path(__file__).resolve().parents[2]; H=Path(__file__).resolve().parent
W=R/'build/issue502-furnishing'; W.mkdir(parents=True,exist_ok=True)
P=R.parent/'issue502-house-absence-work/build/issue502-house-absence'
p=argparse.ArgumentParser();p.add_argument('--probe',action='store_true');a=p.parse_args()
def pack(path,members):
    path.parent.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(path,'w',zipfile.ZIP_STORED) as z:
        for name,data in sorted(members.items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
if a.probe:
    names=set(subprocess.check_output(['git','diff','6544753f','--name-only','--','src'],cwd=R,text=True).splitlines())
    names.update(subprocess.check_output(['git','ls-files','--others','--exclude-standard','--','src'],cwd=R,text=True).splitlines())
    changed={n[4:] for n in names}
    with zipfile.ZipFile(P/'final41b/caelum_argenteum_dev.pk3') as z:
        pack(W/'probe/caelum_argenteum_dev.pk3',{n:(R/'src'/n).read_bytes() if n in changed else z.read(n) for n in set(z.namelist())|changed})
    print('Probe changed files:',len(changed))
base=(R/'assets/validation_5812/domestic_checks.zs').read_text(encoding='utf-8').replace('CA502D ','CA502H ')
common={'ZSCRIPT':b'version "4.14"\n#include "prior.zs"\n#include "checks.zs"\n','prior.zs':base.encode(),
    'MAPINFO':b'GameInfo {AddEventHandlers="CA502FurnitureChecks"}\n'}
pack(W/'checks.pk3',common|{'checks.zs':(H/'furniture_checks.zs').read_bytes()})
# The prior runtime uses the same persisted diagnostic classes and seed path.
# It has no references to newly added production types or fields.
current=(H/'furniture_checks.zs').read_text(encoding='utf-8')
start=current.index('    // CURRENT-ONLY-BEGIN')
end=current.index('    // CURRENT-ONLY-END')+len('    // CURRENT-ONLY-END')
legacy=current[:start]+'''    void Away(CaelumPlayer u) {Check(true,"original runtime fixture loads");}
    void Returned(CaelumPlayer u) {Check(true,"original runtime save remains loadable");}
    void Core(CaelumPlayer u) {Check(true,"original runtime diagnostic ready");}
    void Migrated(CaelumPlayer u) {CheckPrior(u);}
'''+current[end:]
pack(W/'legacy-checks.pk3',common|{'checks.zs':legacy.encode()})
scripts={
 'seed':'wait 350; netevent ca502f_market; wait 3; changemap CAH000; wait 150; netevent ca502f_seed; wait 3; save furniture-home; wait 3; changemap MAP01; wait 100; netevent ca502f_away; wait 3; save furniture-away; wait 3; changemap CAH000; wait 150; netevent ca502f_back; wait 3; save furniture-back; wait 3; quit',
 'reload':'wait 70; netevent ca502f_back; wait 3; quit',
 'away-load':'wait 70; netevent ca502f_away; wait 3; changemap CAH000; wait 150; netevent ca502f_back; wait 3; quit',
 'samehub':'wait 70; changemap MAP03; wait 100; netevent ca502f_away; wait 3; changemap CAH000; wait 150; netevent ca502f_back; wait 3; quit',
 'core':'wait 70; netevent ca502f_core; wait 3; quit',
 'prior':'wait 350; netevent ca502f_market; wait 3; changemap CAH000; wait 150; netevent ca502f_seed; wait 3; save furniture-prior41; wait 3; quit',
 'migration':'wait 70; netevent ca502f_migrated; wait 3; changemap MAP01; wait 100; netevent ca502f_away; wait 3; changemap CAH000; wait 150; netevent ca502f_back; wait 3; save furniture-migrated; wait 3; quit',
 'rollback':'wait 70; netevent ca502f_migrated; wait 3; quit',
 'clean':'wait 70; netevent ca502f_clean; wait 3; save furniture-clean; wait 3; quit',
 'clean-load':'wait 70; netevent ca502f_clean_saved; wait 3; changemap MAP01; wait 100; changemap CAH000; wait 150; netevent ca502f_clean_saved; wait 3; quit'}
for name,text in scripts.items():(W/(name+'.cfg')).write_text(text+'\n',encoding='utf-8')
subprocess.run(['python',str(R/'assets/validation_5841/prepare.py')],cwd=R,check=True)
reg=R/'build/issue502-house-absence'
shutil.copy2(reg/'domestic-checks.pk3',W/'regression-checks.pk3')
for case in ['core','shortages','skipped']:
    shutil.copy2(reg/('domestic-'+case+'.cfg'),W/('reg-'+case+'.cfg'))
print('Private fixture prepared')
