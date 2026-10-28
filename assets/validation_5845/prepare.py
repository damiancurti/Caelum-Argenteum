"""Create isolated native dining contamination fixtures and a source overlay."""
from pathlib import Path
import argparse
import subprocess
import zipfile

R=Path(__file__).resolve().parents[2];H=Path(__file__).resolve().parent;W=R/'build/issue502-contact'
BASE=R.parent/'issue410-decor-work/build/issue410-decor/final44b/caelum_argenteum_dev.pk3'

def pack(path,members):
    path.parent.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(path,'w',zipfile.ZIP_STORED) as z:
        for name,data in sorted(members.items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)

p=argparse.ArgumentParser();p.add_argument('--probe',action='store_true');a=p.parse_args()
if a.probe:
    names=set(subprocess.check_output(['git','diff','666328b5','--name-only','--','src'],cwd=R,text=True).splitlines())
    names.update(subprocess.check_output(['git','ls-files','--others','--exclude-standard','--','src'],cwd=R,text=True).splitlines())
    changed={n[4:] for n in names}
    with zipfile.ZipFile(BASE) as z:pack(W/'probe/caelum_argenteum_dev.pk3',{n:(R/'src'/n).read_bytes() if n in changed else z.read(n) for n in set(z.namelist())|changed})
    print('Probe source changes:',len(changed))
members={'ZSCRIPT':b'version "4.14"\n#include "base.zs"\n#include "dining.zs"\n#include "checks.zs"\n',
    'base.zs':(R/'assets/validation_5836/checks.zs').read_bytes().replace(b'CA410RF',b'CA502D'),
    'dining.zs':(R/'assets/validation_5840/checks.zs').read_bytes().replace(b'CA410DS',b'CA502D'),
    'checks.zs':(H/'checks.zs').read_bytes(),
    'MAPINFO':b'GameInfo {AddEventHandlers="CA502DiningChecks"}\nmap CBTH410 "Away" {cluster=434}\n',
    'maps/CBTH410.wad':(R/'assets/validation_5826/away.wad').read_bytes()}
pack(W/'checks.pk3',members)
members['checks.zs']=(H/'legacy.zs').read_bytes();pack(W/'legacy-checks.pk3',members)
for case in ['core','resume','upgrade','legacyload']:
    (W/(case+'.cfg')).write_text(f'wait 210; netevent ca502d_{case}; wait 10; quit\n')
(W/'seed.cfg').write_text('wait 210; netevent ca502d_seed; wait 10; save contact-current; wait 10; quit\n')
(W/'legacyseed.cfg').write_text('wait 210; netevent ca502d_legacyseed; wait 10; save contact-prior44; wait 10; quit\n')
(W/'hub.cfg').write_text('wait 210; netevent ca502d_seed; wait 10; netevent ca502d_away; wait 70; netevent ca502d_home; wait 210; netevent ca502d_resume; wait 10; quit\n')
(W/'input.cfg').write_text('wait 210; netevent ca502d_input 0; wait 35; netevent ca502d_input 1; wait 10; quit\n')
print('Dining contamination fixtures ready')
