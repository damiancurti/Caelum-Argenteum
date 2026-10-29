"""Prepare deterministic interior placement checks without replacing campaign geometry."""
from pathlib import Path
import zipfile
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue411-interior';WORK.mkdir(parents=True,exist_ok=True)
legacy=(ROOT/'assets/validation_5826/checks.zs').read_text(encoding='utf-8')
# Existing saves restore their original diagnostic handler, not a newly listed one.
legacy=legacy.replace("if(e.Name=='ca410rd_profile')",'''if(e.Name=='ca411in_migration')
        {let check=new('CA411InteriorChecks');check.Migration(u);Console.Printf("CA411IN RESULT passed=%d failed=%d",check.Passed,check.Failed);return;}
        if(e.Name=='ca410rd_profile')''',1)
members={'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n#include "legacy-reading.zs"\n','checks.zs':(HERE/'checks.zs').read_bytes(),
         'legacy-reading.zs':legacy.encode('utf-8'),
         'MAPINFO':b'GameInfo {AddEventHandlers="CA411InteriorChecks"}\ncluster 8522 {hub}\nmap MAP01 "Mansion"{cluster=8522}\nmap CBTH410 "Away"{cluster=8522}\n',
         'maps/CBTH410.wad':(ROOT/'assets/validation_5826/away.wad').read_bytes()}
with zipfile.ZipFile(WORK/'checks.pk3','w',zipfile.ZIP_STORED) as z:
 for name,data in sorted(members.items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
prefix='wait1; netevent ca411in_profile; wait210; '
commands={'core':prefix+'netevent ca411in_core; wait5; quit',
 'seed':prefix+'netevent ca411in_core; wait5; save interior-progress; wait5; quit',
 'resume':'wait210; netevent ca411in_resume; wait5; quit',
 'hub':prefix+'netevent ca411in_core; wait5; changemap CBTH410; wait70; changemap MAP01; wait210; netevent ca411in_resume; wait5; quit',
 'property':prefix+'netevent ca411in_property; wait5; quit',
 'migration':'wait210; netevent ca411in_migration; wait5; quit',
 'city':prefix+'netevent ca411in_city; wait5; quit',
 'view':prefix+'netevent ca411in_core; wait70; screenshot interior-view.png; wait5; quit'}
for name,s in commands.items():
 for n in [1,5,70,210]:s=s.replace('wait'+str(n)+';','wait '+str(n)+';')
 (WORK/(name+'.cfg')).write_text(s+'\n',encoding='utf-8')
print('Prepared interior placement diagnostics.')
