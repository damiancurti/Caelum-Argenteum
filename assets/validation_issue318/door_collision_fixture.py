"""Add an owned legacy control pair to the final native isolated room."""
from pathlib import Path
import shutil
import zipfile
from geometry_probe import read_wad,pack_wad
from geometry_verify import package

ROOT=Path(__file__).resolve().parents[2];HERE=Path(__file__).resolve().parent
work=ROOT/'build/issue318-door-collision-01/current';work.mkdir(parents=True,exist_ok=False)
source=ROOT/'build/issue318-native-08/current'
shutil.copyfile(source/'runtime.pk3',work/'runtime.pk3')
with zipfile.ZipFile(source/'probe.pk3') as z:(work/'room-source.wad').write_bytes(z.read('maps/MAP98.wad'))
lumps=read_wad(work/'room-source.wad');text=dict(lumps)['TEXTMAP'].decode()
for side in (-1,1):text+=f'thing {{ type=18099; x={side*32}; y=256; arg0=500; arg1={side}; arg2=0; skill1=true; skill2=true; skill3=true; skill4=true; skill5=true; single=true; coop=true; }}\n'
wad=pack_wad([(name,text.encode() if name=='TEXTMAP' else data) for name,data in lumps])
package(work/'probe.pk3',{'maps/MAP98.wad':wad,'ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n',
    'checks.zs':(HERE/'door_collision_checks.zs').read_bytes(),
    'MAPINFO':b'GameInfo { AddEventHandlers="CA318CollisionChecks" }\nmap MAP98 "Collision comparison" { next="MAP98" }\n'})
(work/'test.cfg').write_text('wait 70; netevent collision_begin; wait 50; netevent collision_done; wait 5; quit\n')
(work/'manifest.json').write_text('{}\n')
print(work)
