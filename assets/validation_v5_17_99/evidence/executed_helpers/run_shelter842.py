"""Native bounded shelter geometry and reversible save fixture."""
from pathlib import Path
import argparse,hashlib,json,re,shutil,struct,subprocess,time,zipfile
ROOT=Path(__file__).resolve().parents[2]/'build/v517/work-713'
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--runtime',type=Path,required=True);p.add_argument('--reference-runtime',type=Path,required=True);p.add_argument('--candidate',type=Path);p.add_argument('--load',type=Path);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
out=a.output.resolve();out.relative_to(ROOT/'build');out.mkdir(exist_ok=False)
assert '"gzdoom.exe"' not in subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/FO','CSV','/NH']).decode(errors='replace').lower()
with zipfile.ZipFile(a.reference_runtime) as package:reference=package.read('caelum/survival/CaelumThermalEnvironment.zs').decode('utf-8').replace('\r\n','\n')
reference=reference[:reference.index('// Caché de referencia climática compartida')].replace('class CaelumThermalShelter','class CA842ShelterReference',1)
rooms=[dict(name='open',center=(-6000,-3000),bounds=(-2048,-2048,2048,2048),expected=0),dict(name='two_parallel',center=(0,-3000),bounds=(-128,-2048,128,2048),expected=0),dict(name='three_connected',center=(6000,-3000),bounds=(-128,-128,128,2048),expected=1),dict(name='four_connected',center=(-6000,3000),bounds=(-128,-128,128,128),expected=1),dict(name='one_plane',center=(0,3000),bounds=(-2048,-2048,128,2048),expected=0),dict(name='segmented_planes',center=(6000,3000),bounds=(-128,-128,128,128),expected=-1)]
text=['namespace="ZDoom";'];vertex=0;side=0
for i,room in enumerate(rooms):
    cx,cy=room['center'];x1,y1,x2,y2=room['bounds'];points=[(x1,y1),(x1,y2),(x2,y2),(x2,y1)]
    if i==5:points=[(x1,y1),(x1,0),(x1,y2),(0,y2),(x2,y2),(x2,0),(x2,y1),(0,y1)]
    for x,y in points:text.append(f'vertex{{x={cx+x};y={cy+y};}}')
    text.append(f'sector{{heightfloor=0;heightceiling=256;texturefloor="FLOOR0_1";textureceiling="CEIL1_1";lightlevel=192;id={i+1};}}')
    for j in range(len(points)):
        text.append(f'sidedef{{sector={i};texturemiddle="STARTAN3";}}')
        text.append(f'linedef{{v1={vertex+j};v2={vertex+(j+1)%len(points)};sidefront={side};blocking=true;}}');side+=1
    vertex+=len(points)
text.append('thing{x=-6000;y=-3000;type=1;angle=0;skill1=true;skill2=true;skill3=true;skill4=true;skill5=true;single=true;}')
textmap=('\n'.join(text)+'\n').encode();lumps=[('MAP01',b''),('TEXTMAP',textmap),('ENDMAP',b'')];body=bytearray();directory=bytearray()
for name,data in lumps:directory+=struct.pack('<ii8s',12+len(body),len(data),name.encode());body+=data
wad=struct.pack('<4sii',b'PWAD',len(lumps),12+len(body))+body+directory
source=reference+'''
class CA842ShelterBody : Actor
{int Index;Default {+NOINTERACTION +NOGRAVITY Radius 16;Height 56;} States {Spawn:TNT1 A -1;Stop;}}
class CA842ShelterFixture : EventHandler
{
    Array<CA842ShelterBody> Bodies;
    int SavedRevision;
    transient bool Checked;
    int Checks,Errors;
    void Check(bool valid,String message)
    {Checks++;if(!valid)Errors++;Console.Printf("CA842 CHECK %s %s",valid?"PASS":"FAIL",message);}
    override void WorldTick()
    {
        if(Checked)return;Checked=true;Checks=Errors=0;
        vector3 points[]={POINTS};
        int expected[]={EXPECTED};
        bool fresh=SavedRevision==0;
        if(fresh)
        {
            for(int i=0;i<6;i++)
            {let probe=CA842ShelterBody(Actor.Spawn('CA842ShelterBody',points[i],NO_REPLACE));if(probe!=null)probe.Index=i;Bodies.Push(probe);}
            SavedRevision=1;
        }
        Check(SavedRevision==1,"saved_revision");Check(Bodies.Size()==6,"saved_body_count");
        for(int i=0;i<Bodies.Size();i++)
        {
            let probe=Bodies[i];Check(probe!=null,"saved_body");if(probe==null)continue;
            Check(probe.Index==i && probe.Pos==points[i] && probe.Height==56,"saved_identity_geometry");
            bool actual=CaelumThermalShelter.WindBlocked(probe),reference=CA842ShelterReference.WindBlocked(probe);
            Check(actual==reference,"original_geometry");
            if(expected[i]>=0)Check(actual==(expected[i]!=0),"authored_three_plane_boundary");
            for(int step=0;step<4;step++)
            {
                probe.SetOrigin(points[i]+(step*8,step*5,step*24),false);probe.Height=56+step*16;
                bool current=CaelumThermalShelter.WindBlocked(probe);
                Check(current==CA842ShelterReference.WindBlocked(probe),"moved_height_geometry");
                Check(current==CaelumThermalShelter.WindBlocked(probe),"repeat_stability");
            }
            probe.SetOrigin(points[i],false);probe.Height=56;
        }
        Console.Printf("CA842 FIXTURE_COMPLETE fresh=%d checks=%d errors=%d",fresh,Checks,Errors);
    }
}
'''.replace('POINTS',','.join('('+str(r['center'][0])+','+str(r['center'][1])+',0)' for r in rooms)).replace('EXPECTED',','.join(str(r['expected']) for r in rooms))
files={'ZSCRIPT':('version "4.14.2"\n'+source).encode(),'MAPINFO':b'gameinfo { AddEventHandlers="CA842ShelterFixture" }\nmap CA842S "Shelter geometry checks" {}\n','maps/CA842S.wad':wad}
checks=out/'checks.pk3'
with zipfile.ZipFile(checks,'x') as package:
    for name,data in sorted(files.items()):package.writestr(zipfile.ZipInfo(name,(2026,11,19,0,0,0)),data)
(out/'checks.zs').write_text(source,encoding='utf-8');(out/'TEXTMAP.txt').write_bytes(textmap);(out/'rooms.json').write_text(json.dumps(rooms,indent=2)+'\n')
(out/'session.ini').write_text('[GlobalSettings]\nvid_preferbackend=1\nvid_fullscreen=false\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\nsnd_mastervolume=0.05\ni_soundinbackground=true\nvid_maxfps=60\nvid_vsync=false\nvid_defwidth=1280\nvid_defheight=720\nwin_w=1296\nwin_h=759\ncon_notifytime=0\nuse_mouse=false\nlanguage=enu\n',encoding='utf-8')
(out/'commands.cfg').write_text('wait 40; save shelter.zds; wait 5; quit\n',encoding='utf-8')
engine=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe');iwad=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD');packages=[a.runtime.resolve()]+([a.candidate.resolve()] if a.candidate else [])+[checks]
launch=['+map','CA842S']
if a.load:shutil.copyfile(a.load,out/'input.zds');launch=['-loadgame','input.zds']
command=[str(engine),'-noautoload','-nomouse','-iwad',str(iwad),'-file',*map(str,packages),'-config',str(out/'session.ini'),'-savedir',str(out),'-window','-width','1280','-height','720','+logfile',str(out/'engine.log'),*launch,'+exec',str(out/'commands.cfg')]
startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
with (out/'process.log').open('wb') as log:
    proc=subprocess.Popen(command,cwd=out,stdout=log,stderr=log,startupinfo=startup);deadline=time.monotonic()+90
    while proc.poll() is None:
        f=out/'engine.log';sample=f.read_text(encoding='utf-8',errors='replace') if f.exists() else ''
        if any(s in sample for s in ('Script error','VM execution aborted','Execution could not continue','DIED WITH FATAL ERROR')) or time.monotonic()>deadline:proc.terminate();break
        time.sleep(.25)
    code=proc.wait(timeout=15)
log=(out/'engine.log').read_text(encoding='utf-8',errors='replace');result=re.search(r'CA842 FIXTURE_COMPLETE fresh=(\d+) checks=(\d+) errors=(\d+)',log)
errors=[s for s in ('Script error','VM execution aborted','Execution could not continue','DIED WITH FATAL ERROR','CA842 CHECK FAIL') if s in log]
passed=code==0 and not errors and result is not None and int(result[2])==73 and int(result[3])==0 and int(result[1])==int(a.load is None) and (out/'shelter.zds').is_file()
sha=lambda path:hashlib.sha256(path.read_bytes()).hexdigest()
report=dict(issue=842,passed=passed,exit_code=code,command=command,errors=errors,result=list(result.groups()) if result else None,sha256={str(path):sha(path) for path in packages},reference_runtime_sha256=sha(a.reference_runtime),loaded_save_sha256=sha(a.load) if a.load else None,saved_sha256=sha(out/'shelter.zds') if (out/'shelter.zds').exists() else None,checks=[line for line in log.splitlines() if line.startswith('CA842 CHECK')])
(out/'RESULTS.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8');print(json.dumps({k:v for k,v in report.items() if k in ('passed','errors','result')}));raise SystemExit(not passed)
