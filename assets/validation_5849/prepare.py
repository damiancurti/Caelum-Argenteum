"""Build private physical-contamination fixtures and a source-overlay probe."""
from pathlib import Path
import argparse, subprocess, zipfile
R=Path(__file__).resolve().parents[2]
H=Path(__file__).resolve().parent
W=R/'build/issue502-physical'
BASE=R.parent/'issue502-vessels-work/build/issue502-vessels/final48b/caelum_argenteum_dev.pk3'

def pack(path,members):
    path.parent.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(path,'w',zipfile.ZIP_STORED) as z:
        for name,data in sorted(members.items()):
            z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)

p=argparse.ArgumentParser();p.add_argument('--probe',action='store_true');a=p.parse_args()
if a.probe:
    names=set(subprocess.check_output(['git','diff','874d038d','--name-only','--','src'],cwd=R,text=True,stderr=subprocess.DEVNULL).splitlines())
    names.update(subprocess.check_output(['git','ls-files','--others','--exclude-standard','--','src'],cwd=R,text=True).splitlines())
    changed={n[4:] for n in names}
    with zipfile.ZipFile(BASE) as z:
        pack(W/'probe/caelum_argenteum_dev.pk3',{n:(R/'src'/n).read_bytes() if n in changed else z.read(n) for n in set(z.namelist())|changed})
    print('Probe source changes:',len(changed))
pack(W/'checks.pk3',{
    'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n',
    'checks.zs':(H/'checks.zs').read_bytes(),
    'MAPINFO':b'GameInfo {AddEventHandlers="CA502PhysicalChecks"}\ncluster 8549 {hub}\nmap MAP01 "Physical contact" {cluster=8549}\nmap CPH502B "Away" {cluster=8549}\n',
    'maps/MAP01.wad':(R/'assets/validation_5826/away.wad').read_bytes(),
    'maps/CPH502B.wad':(R/'assets/validation_5826/away.wad').read_bytes()})
for case in ['catalogue','food','forecast','storage','contact','support','absent','seed','resume']:
    suffix='; save physical-current' if case=='seed' else ''
    (W/(case+'.cfg')).write_text(f'wait 105; netevent ca502p_{case}{suffix}; wait 10; quit\n')
print('Prepared physical-contact fixtures')

(W/'hub.cfg').write_text('wait 105; netevent ca502p_seed; netevent ca502p_away; wait 35; netevent ca502p_home; wait 35; netevent ca502p_resume; wait 10; quit\n')
(W/'absent.cfg').write_text('wait 105; netevent ca502p_npcprepare; wait 3; netevent ca502p_absent; wait 10; quit\n')

with zipfile.ZipFile(W/'checks.pk3') as z:current={n:z.read(n) for n in z.namelist()}
legacy=dict(current);legacy['checks.zs']=(H/'legacy.zs').read_bytes()
pack(W/'legacy-checks.pk3',legacy);pack(W/'bridge/legacy-checks.pk3',current)
(W/'legacyseed.cfg').write_text('wait 105; netevent ca502p_legacyseed; save physical-prior48; wait 10; quit\n')
(W/'legacyload.cfg').write_text('wait 105; netevent ca502p_legacyload; wait 10; quit\n')
