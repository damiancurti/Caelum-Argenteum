"""Build deterministic stored-reading diagnostics; production maps stay unchanged."""
from pathlib import Path
import zipfile,subprocess,sys
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue410-reading'
WORK.mkdir(parents=True,exist_ok=True)
members={'MAPINFO':b'GameInfo { AddEventHandlers="CA410ReadingChecks" }\ncluster 8522 {hub}\nmap MAP01 "Mansion" {cluster=8522}\nmap CBTH410 "Away" {cluster=8522}\n','ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n','checks.zs':(HERE/'checks.zs').read_bytes(),'maps/CBTH410.wad':(HERE/'away.wad').read_bytes()}
if '--overlay' in sys.argv:
 names=set(subprocess.check_output(['git','diff','--name-only','HEAD','--','src'],cwd=ROOT,text=True).splitlines())
 names.update(subprocess.check_output(['git','ls-files','--others','--exclude-standard','--','src'],cwd=ROOT,text=True).splitlines())
 for name in names:
  p=ROOT/name
  if p.name in ('ZSCRIPT','MODELDEF','TEXTURES'):continue
  if p.is_file():members[p.relative_to(ROOT/'src').as_posix()]=p.read_bytes()
with zipfile.ZipFile(WORK/'checks.pk3','w',zipfile.ZIP_STORED) as z:
 for name,data in sorted(members.items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
prefix='wait 1; netevent ca410rd_profile; wait 210; '
commands={'core':prefix+'netevent ca410rd_core; wait 5; quit','seed':prefix+'netevent ca410rd_seed; wait 5; save reading-progress; wait 5; quit','resume':'wait 210; netevent ca410rd_resume; wait 5; quit','hub':prefix+'netevent ca410rd_seed; wait 5; changemap CBTH410; wait 70; changemap MAP01; wait 210; netevent ca410rd_resume 1; wait 5; quit'}
for i in range(3):commands['view'+str(i)]=prefix+'netevent ca410rd_view '+str(i)+'; wait 70; screenshot reading-view'+str(i)+'.png; wait 5; quit'
for kind in ('limits','access'):commands[kind]=prefix+'netevent ca410rd_'+kind+'; wait 5; quit'
commands['input']=prefix+'netevent ca410rd_view 1; wait 5; netevent ca_recipe_read; wait 5; netevent ca410rd_input 0; netevent ca_recipe_read; wait 36; netevent ca410rd_input 1; quit'
commands['oldseed']=prefix+'netevent ca410rd_oldseed; wait 5; save reading-legacy; wait 5; quit'
commands['rollback']='wait 210; netevent ca410rd_rollback; wait 5; quit'
commands['migration']='wait 210; netevent ca410rd_migration; wait 5; quit'
with zipfile.ZipFile(WORK/'legacy.pk3','w',zipfile.ZIP_STORED) as z:
 for name,data in sorted({'ZSCRIPT':members['ZSCRIPT'],'checks.zs':(HERE/'legacy.zs').read_bytes(),'MAPINFO':members['MAPINFO'],'maps/CBTH410.wad':members['maps/CBTH410.wad']}.items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
for name,script in commands.items():(WORK/(name+'.cfg')).write_text(script+'\n',encoding='utf-8')
print('Prepared stored-reading native checks.')
