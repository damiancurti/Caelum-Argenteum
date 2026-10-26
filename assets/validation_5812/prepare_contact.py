"""Build a deterministic, unshipped native actor-contact laboratory."""
from pathlib import Path
import struct
import zipfile

here=Path(__file__).resolve().parent
out=here.parents[1]/'build/issue502-hygiene'
text=['namespace="ZDoom";']
for x,y in [(-320,-320),(-320,320),(320,320),(320,-320)]:
    text.append(f'vertex {{x={x};y={y};}}')
text.append('sector {heightfloor=0;heightceiling=160;texturefloor="FLAT5_4";textureceiling="CEIL1_1";lightlevel=192;}')
for i in range(4):
    text.append('sidedef {sector=0;texturemiddle="STARTAN3";}')
    text.append(f'linedef {{v1={i};v2={(i+1)%4};sidefront={i};blocking=true;}}')
flags='skill1=true;skill2=true;skill3=true;skill4=true;skill5=true;single=true;coop=true;dm=true;'
text.append('thing {x=-160;y=-120;angle=55;type=1;'+flags+'}')
text.append('thing {x=200;y=200;type=30950;arg0=1;arg1=5;'+flags+'}')
lumps=[('CAC502',b''),('TEXTMAP','\n'.join(text).encode()),('ENDMAP',b'')]
data=bytearray(b'PWAD'+struct.pack('<ii',len(lumps),0));directory=[]
for name,blob in lumps:
    directory.append((len(data),len(blob),name.encode().ljust(8,b'\0')));data.extend(blob)
offset=len(data)
for row in directory:data.extend(struct.pack('<ii8s',*row))
struct.pack_into('<i',data,8,offset)
members={'ZSCRIPT':b'version "4.14.2"\n#include "checks.zs"\n',
         'checks.zs':(here/'contact_checks.zs').read_bytes(),
         'maps/CAC502.wad':bytes(data),
         'MAPINFO':b'GameInfo { AddEventHandlers="CA502ContactChecks" }\nmap CAC502 "Continuous contact laboratory" {levelnum=503 cluster=434 nointermission next="CAH001" sky1="SKY1"}\n'}
with zipfile.ZipFile(out/'contact-checks.pk3','w',zipfile.ZIP_STORED) as archive:
    for name,blob in sorted(members.items()):archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)
# Saves require the original addon's basename, even when its test code evolves.
bridge=out/'contact-bridge';bridge.mkdir(exist_ok=True)
(bridge/'contact-legacy-checks.pk3').write_bytes((out/'contact-checks.pk3').read_bytes())
legacy=members['checks.zs'].split(b'class CA502ContactChecks')[0]+b'''class CA502ContactChecks : EventHandler {
override void NetworkProcess(ConsoleEvent e){
let u=CaelumPlayer(players[e.Player].mo);
if(e.Name=='ca502c_old_save'){
let a=CA502ContactRat(Actor.Spawn('CA502ContactRat',(-80,0,0),NO_REPLACE));a.ChangeTid(905041);
let b=CA502ContactRat(Actor.Spawn('CA502ContactRat',(-48,0,0),NO_REPLACE));b.ChangeTid(905042);
a.Mass=b.Mass=80;a.DisableCaelumImpactContacts=b.DisableCaelumImpactContacts=true;
CaelumContaminationStorage.Set(a,80);CaelumContaminationStorage.Set(b,20);
let p=CA502ContactProof(u.GiveInventoryType('CA502ContactProof'));p.SourceBody=a;p.Recipient=b;p.Saved=20;
Console.Printf("CA502C PASS old runtime saved original concentrations");
}else if(e.Name=='ca502c_old_verify'){
let a=ActorIterator.Create(905041),b=ActorIterator.Create(905042);
bool ok=CaelumContaminationStorage.Value(a.Next())==80 && CaelumContaminationStorage.Value(b.Next())==20;
Console.Printf("CA502C %s original save remains readable in original runtime",ok?"PASS":"FAIL");
}else return;Console.Printf("CA502C LEGACY");}}
'''
members['checks.zs']=legacy
with zipfile.ZipFile(out/'contact-legacy-checks.pk3','w',zipfile.ZIP_STORED) as archive:
    for name,blob in sorted(members.items()):archive.writestr(zipfile.ZipInfo(name,(2000,1,1,0,0,0)),blob)
scripts={
 'contact-old-save':'wait 70; netevent ca502c_old_save; save ca502c-old; wait 3; quit',
 'contact-old-verify':'wait 1; netevent ca502c_old_verify; wait 3; quit',
 'contact-legacy':'wait 1; netevent ca502c_legacy; save ca502c-migrated; wait 3; quit',
 'contact-clock':'wait 70; netevent ca502c_prepare; wait 3; netevent ca502c_join; wait 175; netevent ca502c_save; netevent ca502c_separate; wait 70; netevent ca502c_stopped; netevent ca502c_rejoin; wait 175; netevent ca502c_resumed; wait 3; quit',
 'contact-core':'wait 70; netevent ca502c_prepare; wait 3; netevent ca502c_core; wait 3; quit',
 'contact-save':'wait 70; netevent ca502c_prepare; wait 3; netevent ca502c_join; wait 175; netevent ca502c_save; save ca502c-current; wait 3; quit',
 'contact-load':'wait 1; netevent ca502c_load; wait 3; quit',
 'contact-hub':'wait 1; changemap CAH001; wait 70; changemap CAC502; wait 35; netevent ca502c_load; wait 3; quit',
 'contact-manual':'wait 70; netevent ca502c_prepare; wait 3; netevent ca502c_join; bind F1 "netevent ca502c_join"; bind F2 "netevent ca502c_read"; bind F3 "netevent ca502c_separate"; bind F4 "netevent ca502c_rejoin"; bind F6 toggleconsole',
}
for name,commands in scripts.items():(out/(name+'.cfg')).write_text(commands+'\n',encoding='utf-8',newline='\n')
print('Prepared native contact laboratory.')
