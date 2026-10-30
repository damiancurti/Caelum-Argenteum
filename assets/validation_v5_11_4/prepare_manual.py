"""Assemble local, uniquely named author checks without production overrides."""
from pathlib import Path
import zipfile
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'build/issue430'
files={'manual.zs':(Path(__file__).parent/'manual.zs').read_bytes()}
movement=(ROOT/'assets/validation_v5_11_1/movement.zs').read_text(encoding='utf-8')
movement=movement.replace('CA429Movement','CA511Movement').replace('CA429Body','CA511Marcher').replace("'ca429_march'","'ca511_march'")
movement=movement.replace("if(e.Name!='ca511_march')return;","if(e.Name!='ca511_march' || Active)return;")
files['manual_march.zs']=('class CA511Marcher : CaelumPortDefender { override void Tick() {} }\n'+movement).encode()
with zipfile.ZipFile(ROOT/'build/issue429/checks-full.pk3') as z:
 for name in ('maps/CA429A.wad','maps/CA429B.wad'):files[name]=z.read(name)
files['ZSCRIPT']=b'version "4.14"\n#include "manual.zs"\n#include "manual_march.zs"\n'
files['MAPINFO']=b'GameInfo { AddEventHandlers="CA511Manual","CA511Movement" }\nmap CA429A "Formation checks" {}\nmap CA429B "Formation passage" {}\n'
for label,entries in [('manual',files)]:
 with zipfile.ZipFile(OUT/(label+'.pk3'),'w') as z:
  for name,data in sorted(entries.items()):z.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),data)
print('Prepared local manual fixture.')
