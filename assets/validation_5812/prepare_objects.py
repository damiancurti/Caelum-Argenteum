"""Deterministic object exposure laboratory; no production maps/assets included."""
from pathlib import Path
import struct
import zipfile

here=Path(__file__).resolve().parent
out=here.parents[1]/'build/issue502-hygiene'
text=['namespace="ZDoom";']
for x,y in [(-256,-256),(-256,256),(0,256),(0,-256),(256,256),(256,-256)]:
    text.append(f'vertex {{x={x};y={y};}}')
for roof in ['CEIL1_1','F_SKY1']:
    text.append(f'sector {{heightfloor=0;heightceiling=160;texturefloor="FLAT5_4";textureceiling="{roof}";lightlevel=192;user_ca_contamination_class=2;}}')
sides=0
for a,b,front,back in [(0,1,0,-1),(1,2,0,-1),(2,4,1,-1),(4,5,1,-1),(5,3,1,-1),(3,0,0,-1),(2,3,0,1)]:
    text.append(f'sidedef {{sector={front};texturemiddle="'+('STARTAN3' if back<0 else '-')+'";}')
    extra='blocking=true;' if back<0 else f'sideback={sides+1};twosided=true;'
    text.append(f'linedef {{v1={a};v2={b};sidefront={sides};{extra}}}')
    sides+=1
    if back>=0:text.append(f'sidedef {{sector={back};}}');sides+=1
flags='skill1=true;skill2=true;skill3=true;skill4=true;skill5=true;single=true;coop=true;dm=true;'
text+=['thing {x=-192;y=-128;angle=48;type=1;'+flags+'}',
       'thing {x=-200;y=200;type=30950;arg0=1;arg1=5;'+flags+'}']
lumps=[('CAO502',b''),('TEXTMAP','\n'.join(text).encode()),('ENDMAP',b'')]
data=bytearray(b'PWAD'+struct.pack('<ii',len(lumps),0));directory=[]
for name,blob in lumps:directory.append((len(data),len(blob),name.encode().ljust(8,b'\0')));data.extend(blob)
offset=len(data)
for row in directory:data.extend(struct.pack('<ii8s',*row))
struct.pack_into('<i',data,8,offset)
source=(here/'object_checks.zs').read_bytes().replace(b'#include "math.zs"',(here/'object_math.zs').read_bytes()+(here/'object_numeric.zs').read_bytes())
members={'ZSCRIPT':b'version "4.14.2"\n#include "checks.zs"\n','checks.zs':source,'maps/CAO502.wad':bytes(data),
         'MENUDEF':b'ListMenu CaelumLiveMenu { Class CA502ObjectMenu }\n',
         'MAPINFO':b'GameInfo { AddEventHandlers="CA502ObjectChecks" }\nmap CAO502 "World object exposure laboratory" {levelnum=504 cluster=434 nointermission next="CAH001" sky1="SKY1"}\n'}
def write(name,members):
    with zipfile.ZipFile(out/name,'w',zipfile.ZIP_STORED) as archive:
        for name,blob in sorted(members.items()):archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)
write('object-checks.pk3',members)
bridge=out/'object-bridge';bridge.mkdir(exist_ok=True)
(bridge/'object-legacy-checks.pk3').write_bytes((out/'object-checks.pk3').read_bytes())
legacy=source.split(b'class CA502ObjectChecks')[0]+b'''class CA502ObjectChecks : EventHandler {
override void NetworkProcess(ConsoleEvent e){
if(e.Name=='ca502o_old_save'){
let a=Actor.Spawn('CA502ObjectProp',(-64,64,0),NO_REPLACE);a.ChangeTid(905051);
let b=Actor.Spawn('CA502ObjectProp',(64,64,0),NO_REPLACE);b.ChangeTid(905052);
CaelumContaminationStorage.Set(b,80);
players[e.Player].mo.GiveInventoryType('CA502ObjectProof');
Console.Printf("CA502O PASS original objects initialized without exposure feature");
}else if(e.Name=='ca502o_old_verify'){
let a=ActorIterator.Create(905051),b=ActorIterator.Create(905052);
bool ok=CaelumContaminationStorage.Value(a.Next())==0 && CaelumContaminationStorage.Value(b.Next())==80;
Console.Printf("CA502O %s original save remains readable in original runtime",ok?"PASS":"FAIL");
}else return;Console.Printf("CA502O LEGACY");}}
'''
members['checks.zs']=legacy;members['MENUDEF']=b'';write('object-legacy-checks.pk3',members)
scripts={
 'object-census':'wait 350; netevent ca502o_census; wait 3; quit',
 'object-core':'wait 70; netevent ca502o_prepare; wait 3; netevent ca502o_core; netevent ca502o_math; wait 3; quit',
 'object-rain':'wait 70; netevent ca502o_prepare; wait 3; netevent ca502o_rain; netevent ca502o_halfhour; netevent ca502o_halfhour; wait 3; quit',
 'object-storage':'wait 70; netevent ca502o_prepare; wait 3; netevent ca502o_reset; netevent ca502o_store; wait 175; netevent ca502o_stored_check; netevent ca502o_drop; wait 175; netevent ca502o_dropped_check; wait 3; quit',
 'object-save':'wait 70; netevent ca502o_prepare; wait 3; netevent ca502o_reset; wait 175; netevent ca502o_save; save ca502o-current; wait 3; quit',
 'object-load':'wait 1; netevent ca502o_load; wait 3; quit',
 'object-hub':'wait 1; changemap CAH001; wait 70; changemap CAO502; wait 1; netevent ca502o_load; wait 3; quit',
 'object-old-save':'wait 70; netevent ca502o_old_save; save ca502o-old; wait 3; quit',
 'object-old-verify':'wait 1; netevent ca502o_old_verify; wait 3; quit',
 'object-legacy':'wait 1; netevent ca502o_legacy; save ca502o-migrated; wait 3; quit',
 'object-manual':'wait 70; netevent ca502o_prepare; wait 3; netevent ca502o_reset; bind F1 "netevent ca502o_reset"; bind F2 "netevent ca502o_read"; bind F3 "netevent ca502o_store"; bind F4 "netevent ca502o_drop"; bind F5 "netevent ca502o_rain"; bind F6 "netevent ca502o_halfhour"',
}
for name,commands in scripts.items():(out/(name+'.cfg')).write_text(commands+'\n',encoding='utf-8',newline='\n')
print('Prepared object exposure native laboratory.')
