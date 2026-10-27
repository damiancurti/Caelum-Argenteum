"""Prepare deterministic diagnostics; overlays are development-only."""
from pathlib import Path
import subprocess
import sys
import zipfile
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue410-sofas'
WORK.mkdir(parents=True,exist_ok=True)
legacy=(ROOT/'assets/validation_5826/checks.zs').read_text(encoding='utf-8')
legacy=legacy.replace("if(e.Name=='ca410rd_profile')",'''if(e.Name=='ca410sf_migration')
        {let check=new('CA410SofaChecks');check.Migration(u);Console.Printf("CA410SF RESULT passed=%d failed=%d",check.Passed,check.Failed);return;}
        if(e.Name=='ca410rd_profile')''',1)
members={'MAPINFO':b'GameInfo { AddEventHandlers="CA410SofaChecks" }\ncluster 8522 {hub}\nmap MAP01 "Mansion"{cluster=8522}\nmap CBTH410 "Away"{cluster=8522}\n',
         'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n#include "legacy-reading.zs"\n',
         'legacy-reading.zs':legacy.encode('utf-8'),
         'maps/CBTH410.wad':(ROOT/'assets/validation_5826/away.wad').read_bytes(),
         'checks.zs':(HERE/'checks.zs').read_bytes()}
if '--overlay' in sys.argv:
    names=set(subprocess.check_output(['git','diff','--name-only','HEAD','--','src'],cwd=ROOT,text=True).splitlines())
    names.update(subprocess.check_output(['git','ls-files','--others','--exclude-standard','--','src'],cwd=ROOT,text=True).splitlines())
    for name in names:
        p=ROOT/name
        if p.name in ('ZSCRIPT','MODELDEF','TEXTURES'):continue
        if p.is_file():members[p.relative_to(ROOT/'src').as_posix()]=p.read_bytes()
with zipfile.ZipFile(WORK/'checks.pk3','w',zipfile.ZIP_STORED) as z:
    for name,data in sorted(members.items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
prefix='wait 1; netevent ca410sf_profile; wait 210; '
commands={'input':prefix+'netevent ca410sf_input 0; wait 35; +use; wait 10; -use; wait 5; netevent ca410sf_input 1; wait 5; quit','core':prefix+'netevent ca410sf_core; wait 5; quit',
          'seed':prefix+'netevent ca410sf_seed; wait 35; save sofa-seat; wait 5; quit',
          'resume':'wait 70; netevent ca410sf_resume; wait 5; quit'}
commands['lifecycle']=prefix+'netevent ca410sf_lifecycle 0; wait 5; netevent ca410sf_destroyed; wait 5; quit'
commands['hub']=prefix+'netevent ca410sf_seed; wait 5; changemap CBTH410; wait 70; changemap MAP01; wait 210; netevent ca410sf_lifecycle 1; wait 5; quit'
commands['migration']='wait 210; netevent ca410sf_migration; wait 5; quit'
commands['target']=prefix+'netevent ca410sf_target; wait 35; screenshot sofa-target.png; wait 35; quit'
for kind,count in ((0,2),(1,3)):
    for slot in range(count):
        name=f'view{kind}-{slot}'
        commands[name]=prefix+f'netevent ca410sf_view {kind} {slot}; wait 35; screenshot sofa-{name}.png; wait 5; quit'
for name,script in commands.items():(WORK/(name+'.cfg')).write_text(script.replace('wait 5;','wait 35;')+'\n',encoding='utf-8')
print('Prepared sofa diagnostics.')
