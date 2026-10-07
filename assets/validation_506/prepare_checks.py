"""Create small native maps and functional addons without shipping fixtures."""
from pathlib import Path
import struct
import subprocess
import zipfile

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
OUT=ROOT/'build/issue128'
processes=subprocess.run(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/NH'],capture_output=True,text=True,check=True).stdout
if 'gzdoom.exe' in processes.lower():raise SystemExit('Stop the native run before replacing diagnostic fixtures.')

def room_map(name):
    chunks=['namespace = "ZDoom";']
    for sector,(x1,y1,x2,y2) in enumerate([(-16000,-16000,16000,16000),(-512,17408,512,18432)]):
        chunks.append('sector { heightfloor=0; heightceiling=2048; texturefloor="CMGR03"; textureceiling="CMST01"; lightlevel=208; }')
        corners=[(x1,y1),(x1,y2),(x2,y2),(x2,y1)]
        for i,(x,y) in enumerate(corners):
            n=sector*4+i
            chunks.append(f'vertex {{ x={x}; y={y}; }}')
            chunks.append(f'sidedef {{ sector={sector}; texturemiddle="CMST01"; }}')
            chunks.append(f'linedef {{ v1={n}; v2={sector*4+(i+1)%4}; sidefront={n}; blocking=true; }}')
    chunks.append('thing { x=-4096; y=0; angle=0; type=1; skill1=true; skill2=true; skill3=true; skill4=true; skill5=true; single=true; coop=true; }')
    lumps=[(name,b''),('TEXTMAP','\n'.join(chunks).encode()),('ENDMAP',b'')]
    body=bytearray();directory=bytearray()
    for key,data in lumps:
        directory+=struct.pack('<ii8s',12+len(body),len(data),key.encode().ljust(8,b'\0'))
        body+=data
    return struct.pack('<4sii',b'PWAD',len(lumps),12+len(body))+body+directory

def package(name,members):
    with zipfile.ZipFile(OUT/name,'w',zipfile.ZIP_STORED) as z:
        for key,data in sorted(members.items()):z.writestr(zipfile.ZipInfo(key,(2000,1,1,0,0,0)),data)

maps={'maps/QA128A.wad':room_map('QA128A'),'maps/QA128B.wad':room_map('QA128B')}
info=b'map QA128A "Population authority trial" { levelnum=1281 cluster=128 next="QA128B" }\nmap QA128B "Population travel trial" { levelnum=1282 cluster=128 next="QA128A" }\ncluster 128 { hub }\n'
package('checks.pk3',dict(maps,**{'MAPINFO':info+b'GameInfo { AddEventHandlers="CA128Checks", "CA128Lifecycle" }\n','ZSCRIPT':b'version "4.14"\n#include "checks.zs"\n','checks.zs':(HERE/'checks.zs').read_bytes()}))
with zipfile.ZipFile(OUT/'observer.pk3') as z:
    observer={n:z.read(n) for n in z.namelist()}
observer['ZSCRIPT']+=b'\n#include "battle.zs"\n'
observer['MAPINFO']=b'GameInfo { AddEventHandlers="CA121Profiler", "CA121Observer", "CA116InputProbe", "CA128Battle" }\n'
observer['battle.zs']=(HERE/'battle.zs').read_bytes()
package('battle.pk3',observer)
with zipfile.ZipFile(OUT/'current.pk3') as z:
    guarded={n:z.read(n) for n in z.namelist()}
path='caelum/world/CaelumSiegeEncounter.zs'
source=guarded[path].decode('utf-8-sig').replace('\r\n','\n')
source=source.replace('    int TargetRefreshTic;', '    int TargetRefreshTic;\n    int CA128GuardStamp;')
needle='if(entry.Encounter==Encounter && IsNearby(entry))RememberGuard(entry);'
assert source.count(needle)==2
source=source.replace(needle,'if(entry.Encounter==Encounter && IsNearby(entry)){RememberGuard(entry);entry.CA128GuardStamp=level.time*64+RegistryIndex+1;}')
source=source.replace('        if (LocalGuards.Size() == 0) return;', '''        if(population!=null && population.HighDensity)
        {
            int expected=0;
            for(int i=0;i<Encounter.Attackers.Size();i++)
            {
                let entry=Encounter.Attackers[i];if(!IsNearby(entry))continue;
                expected++;
                if(entry.CA128GuardStamp!=level.time*64+RegistryIndex+1)
                    ThrowAbortException("CA128 guard oracle omitted an eligible body");
            }
            if(level.time%35==0)Console.Printf("CA128 GUARD_VERIFIED tic=%d machine=%d expected=%d",level.time,RegistryIndex,expected);
        }
        if (LocalGuards.Size() == 0) return;''')
guarded[path]=source.encode('utf-8')
package('guard-oracle.pk3',guarded)
for variant in ['current','no-stagger','no-candidates']:
    with zipfile.ZipFile(OUT/(variant+'.pk3')) as z:
        counted={n:z.read(n) for n in z.namelist()}
    path='caelum/world/CaelumPortSiege.zs'
    source=counted[path].decode('utf-8-sig').replace('\r\n','\n')
    source=source.replace('        TargetCandidates.Clear();\n        for(int p=', '        CA128Counters.Get().Lists++;TargetCandidates.Clear();\n        for(int p=')
    source=source.replace('        RefreshCandidates();\n        Actor victim;', '        RefreshCandidates();\n        CA128Counters.Get().Queries++;CA128Counters.Get().CandidateVisits+=TargetCandidates.Size();\n        Actor victim;')
    counted[path]=source.encode('utf-8')
    counted['ZSCRIPT']+=b'\n#include "ca128_counters.zs"\n'
    counted['ca128_counters.zs']=(HERE/'counters.zs').read_bytes()
    package('counters-'+variant+'.pk3',counted)
counter_addon=dict(observer)
counter_addon['MAPINFO']=b'GameInfo { AddEventHandlers="CA121Profiler", "CA121Observer", "CA116InputProbe", "CA128Battle", "CA128Counters" }\n'
package('counters.pk3',counter_addon)
(OUT/'checks.cfg').write_text('wait 35; save ca128_checks; wait 35; quit\n')
(OUT/'counters.cfg').write_text('wait 770; quit\n')
for name in ['visual.cfg','upgrade.cfg','rollback.cfg','travel.cfg','load-checks.cfg']:
    (OUT/name).write_bytes((HERE/name).read_bytes())
print('Prepared isolated threshold, leader, occlusion and guard tests')
