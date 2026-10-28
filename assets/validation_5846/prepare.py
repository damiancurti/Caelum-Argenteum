"""Create isolated native NPC absence fixtures and a source overlay."""
from pathlib import Path
import argparse
import subprocess
import zipfile

R=Path(__file__).resolve().parents[2];H=Path(__file__).resolve().parent;W=R/'build/issue502-unloaded-npc'
BASE=R.parent/'issue502-contact-work/build/issue502-contact/final45a/caelum_argenteum_dev.pk3'

def pack(path,members):
    path.parent.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(path,'w',zipfile.ZIP_STORED) as z:
        for name,data in sorted(members.items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)

p=argparse.ArgumentParser();p.add_argument('--probe',action='store_true');a=p.parse_args()
if a.probe:
    names=set(subprocess.check_output(['git','diff','8ab70cb7','--name-only','--','src'],cwd=R,text=True).splitlines())
    names.update(subprocess.check_output(['git','ls-files','--others','--exclude-standard','--','src'],cwd=R,text=True).splitlines())
    changed={n[4:] for n in names}
    with zipfile.ZipFile(BASE) as z:pack(W/'probe/caelum_argenteum_dev.pk3',{n:(R/'src'/n).read_bytes() if n in changed else z.read(n) for n in set(z.namelist())|changed})
    print('Probe source changes:',len(changed))

members={'ZSCRIPT':b'version "4.14"\n#include "base.zs"\n#include "checks.zs"\n',
    'base.zs':(R/'assets/validation_5812/npc_checks.zs').read_bytes(),
    'checks.zs':(H/'checks.zs').read_bytes(),
    'MAPINFO':b'GameInfo {AddEventHandlers="CA502AbsentChecks"}\ncluster 8546 {hub}\nmap CUN502 "Absent NPC" {cluster=8546}\nmap CUN502B "Away" {cluster=8546}\n',
    'maps/CUN502.wad':(R/'assets/validation_5826/away.wad').read_bytes(),
    'maps/CUN502B.wad':(R/'assets/validation_5826/away.wad').read_bytes()}
pack(W/'checks.pk3',members)
for case in ['core','exposure','clock','perf','warm','guards']:
    (W/(case+'.cfg')).write_text(f'wait 105; netevent ca502u_prepare; wait 3; netevent ca502u_{case}; wait 10; quit\n')
(W/'seed.cfg').write_text('wait 105; netevent ca502u_prepare; wait 3; netevent ca502u_seed; save absent-current; wait 10; quit\n')
(W/'hub.cfg').write_text('wait 105; netevent ca502u_prepare; wait 3; netevent ca502u_seed; netevent ca502u_away; wait 35; netevent ca502u_home; wait 35; netevent ca502u_resume; wait 10; quit\n')
print('Prepared absent NPC fixtures')

(W/'resume.cfg').write_text('wait 105; netevent ca502u_resume; wait 10; quit\n')

(W/'production.cfg').write_text('wait 105; netevent ca502u_prepare; wait 3; netevent ca502u_productionseed; netevent ca502u_away; wait 35; netevent ca502u_traveltime; netevent ca502u_home; wait 35; netevent ca502u_productionreturn; wait 10; quit\n')

legacy=dict(members);legacy['checks.zs']=(H/'legacy.zs').read_bytes();pack(W/'legacy-checks.pk3',legacy)
(W/'legacyseed.cfg').write_text('wait 105; netevent ca502u_prepare; wait 3; netevent ca502u_legacyseed; wait 3; save absent-prior45b; wait 10; quit\n')
(W/'legacyload.cfg').write_text('wait 105; netevent ca502u_legacyload; wait 10; quit\n')
(W/'upgrade.cfg').write_text('wait 105; netevent ca502u_upgrade; wait 10; quit\n')

(W/'bridge').mkdir(exist_ok=True)
(W/'bridge/legacy-checks.pk3').write_bytes((W/'checks.pk3').read_bytes())

(W/'resident.cfg').write_text('wait 105; netevent ca502u_prepare; wait 3; netevent ca502u_residentseed; netevent ca502u_away; wait 35; netevent ca502u_traveltime; netevent ca502u_home; wait 35; netevent ca502u_residentreturn; wait 10; quit\n')

(W/'lethal.cfg').write_text('wait 105; netevent ca502u_prepare; wait 3; netevent ca502u_productionseed; netevent ca502u_away; wait 35; netevent ca502u_lethaltime; netevent ca502u_home; wait 35; netevent ca502u_lethalreturn; wait 10; quit\n')

(W/'captureperf.cfg').write_text('wait 105; netevent ca502u_prepare; wait 3; netevent ca502u_captureprepare; wait 3; netevent ca502u_captureperf; wait 10; quit\n')

(W/'hub.cfg').write_bytes((W/'production.cfg').read_bytes())
