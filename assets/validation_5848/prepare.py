"""Prepare private vessel exposure checks without changing production artwork."""
from pathlib import Path
import argparse,subprocess,zipfile
R=Path(__file__).resolve().parents[2];H=Path(__file__).resolve().parent;W=R/'build/issue502-vessels'
BASE=R.parent/'issue502-stackables-work/build/issue502-stackables/final47b/caelum_argenteum_dev.pk3'
def pack(path,members):
    path.parent.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(path,'w',zipfile.ZIP_STORED) as z:
        for name,data in sorted(members.items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
p=argparse.ArgumentParser();p.add_argument('--probe',action='store_true');a=p.parse_args()
if a.probe:
    names=set(subprocess.check_output(['git','diff','1d58a455','--name-only','--','src'],cwd=R,text=True).splitlines())
    names.update(subprocess.check_output(['git','ls-files','--others','--exclude-standard','--','src'],cwd=R,text=True).splitlines())
    changed={n[4:] for n in names}
    with zipfile.ZipFile(BASE) as z:pack(W/'probe/caelum_argenteum_dev.pk3',{n:(R/'src'/n).read_bytes() if n in changed else z.read(n) for n in set(z.namelist())|changed})
    print('Probe source changes:',len(changed))
members={'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n','checks.zs':(H/'checks.zs').read_bytes(),
    'MAPINFO':b'GameInfo {AddEventHandlers="CA502VesselChecks"}\ncluster 8548 {hub}\nmap MAP01 "Vessel exposure" {cluster=8548}\nmap CVS502B "Away" {cluster=8548}\n',
    'maps/MAP01.wad':(R/'assets/validation_5826/away.wad').read_bytes(),'maps/CVS502B.wad':(R/'assets/validation_5826/away.wad').read_bytes()}
pack(W/'checks.pk3',members)
for case in ['catalogue','storage','immersion','camp','packed','contact','seed','resume','packedresume','upgrade','legacyseed','legacyload']:
    suffix='; save vessel-current' if case=='seed' else ''
    (W/(case+'.cfg')).write_text(f'wait 105; netevent ca502v_{case}{suffix}; wait 10; quit\n')
legacy=dict(members);legacy['checks.zs']=(H/'legacy.zs').read_bytes();pack(W/'legacy-checks.pk3',legacy)
pack(W/'bridge/legacy-checks.pk3',members)
(W/'legacyseed.cfg').write_text('wait 105; netevent ca502v_legacyseed; save vessel-prior47; wait 10; quit\n')
(W/'hub.cfg').write_text('wait 105; netevent ca502v_seed; netevent ca502v_away; wait 70; netevent ca502v_home; wait 70; netevent ca502v_resume; wait 10; quit\n')
print('Prepared vessel fixtures')

(W/'awaysave.cfg').write_text('wait 105; netevent ca502v_seed; netevent ca502v_away; wait 70; save vessel-away; wait 10; quit\n')
(W/'packedtravel.cfg').write_text('wait 105; netevent ca502v_packedseed; netevent ca502v_away; wait 70; netevent ca502v_packedresume; save vessel-packed; wait 10; quit\n')
