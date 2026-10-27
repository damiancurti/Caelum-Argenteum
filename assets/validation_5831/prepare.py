"""Build isolated furniture acquisition checks and reproducible probe packages."""
from pathlib import Path
import argparse
import zipfile
import struct
ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
WORK=ROOT/'build/issue410-storage-acquisition'
WORK.mkdir(parents=True,exist_ok=True)
a=argparse.ArgumentParser();a.add_argument('--probe',action='store_true');args=a.parse_args()
if args.probe:
 (WORK/'probe').mkdir(exist_ok=True)
 with zipfile.ZipFile(WORK/'probe/caelum_argenteum_dev.pk3','w',zipfile.ZIP_STORED) as z:
  for p in sorted((ROOT/'src').rglob('*')):
   if p.is_file():z.writestr(zipfile.ZipInfo(p.relative_to(ROOT/'src').as_posix(),(2000,1,1,0,0,0)),p.read_bytes())
if (HERE/'checks.zs').exists():
 text='namespace="ZDoom";\n'
 for x,y in [(-1024,-1024),(-1024,1024),(1024,1024),(1024,-1024)]:text+=f'vertex {{x={x};y={y};}}\n'
 for i in range(4):text+=f'sidedef {{sector=0;texturemiddle="CMST01";}}\nlinedef {{v1={i};v2={(i+1)%4};sidefront={i};blocking=true;}}\n'
 text+='sector {heightfloor=0;heightceiling=256;texturefloor="CMST01";textureceiling="CMST01";lightlevel=224;}\nthing {x=0;y=-256;type=1;angle=90;}\n'
 lumps=[('CSUP410',b''),('TEXTMAP',text.encode()),('ENDMAP',b'')];payload=b''.join(d for _,d in lumps);directory=b'';offset=12
 for n,d in lumps:directory+=struct.pack('<ii8s',offset,len(d),n.encode());offset+=len(d)
 flat=b'PWAD'+struct.pack('<ii',len(lumps),12+len(payload))+payload+directory
 legacy=(ROOT/'assets/validation_5826/checks.zs').read_text(encoding='utf-8')
 legacy=legacy.replace("if(e.Name=='ca410rd_profile')","if(e.Name=='ca410sf_legacy'){let c=new('CA410StorageChecks');c.Legacy(u);c.Result();return;}\n        if(e.Name=='ca410rd_profile')",1)
 members={'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n#include "legacy.zs"\n','checks.zs':(HERE/'checks.zs').read_bytes(),'legacy.zs':legacy.encode(),
 'MAPINFO':b'GameInfo {AddEventHandlers="CA410StorageChecks"}\ncluster 8522 {hub}\nmap CSUP410 "Storage supplies"{cluster=8522}\nmap MAP01 "Mansion"{cluster=8522}\nmap CBTH410 "Away"{cluster=8522}\n',
 'maps/CSUP410.wad':flat,'maps/CBTH410.wad':(ROOT/'assets/validation_5826/away.wad').read_bytes()}
 with zipfile.ZipFile(WORK/'checks.pk3','w',zipfile.ZIP_STORED) as z:
  for n,d in sorted(members.items()):z.writestr(zipfile.ZipInfo(n,(2000,1,1,0,0,0)),d)
 for case in ['catalogue','craft','trade','placement','items','resume','legacy']:
  (WORK/(case+'.cfg')).write_text('wait 210; netevent ca410sf_'+case+'; wait 35; quit\n',encoding='utf-8')
 (WORK/'seed.cfg').write_text('wait 210; netevent ca410sf_seed; wait 35; save storage-furniture; wait 35; quit\n',encoding='utf-8')
 (WORK/'hub.cfg').write_text('wait 210; netevent ca410sf_seed; wait 35; changemap CBTH410; wait 70; changemap MAP01; wait 210; netevent ca410sf_resume; wait 35; quit\n',encoding='utf-8')
 (WORK/'inventory.cfg').write_text('wait 210; netevent ca410sf_inventory; ca_journal_page 0; ca_journal_open true; wait 70; screenshot storage-inventory.png; netevent ca410sf_wardrobe; wait 70; screenshot storage-wardrobe.png; wait 35; quit\n',encoding='utf-8')
 (WORK/'shop.cfg').write_text('wait 210; netevent ca410sf_shop; wait 70; screenshot storage-shop.png; wait 35; quit\n',encoding='utf-8')
print('Prepared storage furniture diagnostics.')
