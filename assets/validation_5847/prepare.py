"""Build deterministic, private native stack contamination fixtures."""
from pathlib import Path
import argparse
import subprocess
import zipfile

R=Path(__file__).resolve().parents[2]
H=Path(__file__).resolve().parent
W=R/'build/issue502-stackables'
BASE=R.parent/'issue502-unloaded-npc-work/build/issue502-unloaded-npc/final46e/caelum_argenteum_dev.pk3'

def pack(path,members):
    path.parent.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(path,'w',zipfile.ZIP_STORED) as z:
        for name,data in sorted(members.items()):
            z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)

p=argparse.ArgumentParser();p.add_argument('--probe',action='store_true');a=p.parse_args()
if a.probe:
    names=set(subprocess.check_output(['git','diff','0ca084ba','--name-only','--','src'],cwd=R,text=True).splitlines())
    names.update(subprocess.check_output(['git','ls-files','--others','--exclude-standard','--','src'],cwd=R,text=True).splitlines())
    changed={n[4:] for n in names}
    with zipfile.ZipFile(BASE) as z:
        pack(W/'probe/caelum_argenteum_dev.pk3',{n:(R/'src'/n).read_bytes() if n in changed else z.read(n) for n in set(z.namelist())|changed})
    print('Probe source changes:',len(changed))
members={'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n',
    'checks.zs':(H/'checks.zs').read_bytes(),
    'MAPINFO':b'GameInfo {AddEventHandlers="CA502StackChecks"}\ncluster 8547 {hub}\nmap CST502 "Stack exposure" {cluster=8547}\nmap CST502B "Away" {cluster=8547}\n',
    'maps/CST502.wad':(R/'assets/validation_5826/away.wad').read_bytes(),
    'maps/CST502B.wad':(R/'assets/validation_5826/away.wad').read_bytes()}
pack(W/'checks.pk3',members)
for case in ['core','native','exposure','contact','storage','ground','perf','seed','resume','upgrade','legacyseed','legacyload','catalogue','npc','merchant','rebase']:
    suffix='; save stack-current' if case=='seed' else ''
    (W/(case+'.cfg')).write_text(f'wait 105; netevent ca502s_{case}{suffix}; wait 10; quit\n')
legacy=dict(members);legacy['checks.zs']=(H/'legacy.zs').read_bytes();pack(W/'legacy-checks.pk3',legacy)
pack(W/'bridge/legacy-checks.pk3',members)
(W/'legacyseed.cfg').write_text('wait 105; netevent ca502s_legacyseed; save stack-prior46; wait 10; quit\n')
(W/'hub.cfg').write_text('wait 105; netevent ca502s_seed; netevent ca502s_away; wait 70; netevent ca502s_home; wait 70; netevent ca502s_resume; wait 10; quit\n')
(W/'groundlive.cfg').write_text('wait 105; netevent ca502s_groundseed; wait 105; netevent ca502s_groundlive; wait 10; quit\n')
print('Prepared stack fixtures')
