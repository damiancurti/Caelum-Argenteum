"""Compare map predicates, clock boundaries and reversible saved clock identities."""
from pathlib import Path
import argparse,hashlib,json,re,shutil,subprocess,time,zipfile
ROOT=Path('C:/GZDooMProjects/CaelumArgenteum/build/v517/work-713')
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--runtime',type=Path,required=True);p.add_argument('--reference-runtime',type=Path,required=True);p.add_argument('--output',type=Path,required=True);p.add_argument('--load',type=Path);p.add_argument('--map',choices=['MAP01','CA846N'],default='CA846N');a=p.parse_args()
out=a.output.resolve();out.relative_to(ROOT/'build');out.mkdir(exist_ok=False)
assert '"gzdoom.exe"' not in subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/FO','CSV','/NH']).decode(errors='replace').lower()
with zipfile.ZipFile(a.reference_runtime) as z:
    catalogue=z.read('caelum/world/CaelumWorldCatalogue.zs').decode().replace('\r\n','\n')
    clock=z.read('caelum/world/CaelumWorldClock.zs').decode().replace('\r\n','\n')
    runtime=z.read('caelum/survival/CaelumThermalRuntime.zs').decode().replace('\r\n','\n')
    house=z.read('caelum/world/CaelumHouseHubData.zs').decode()
    known={Path(n).stem for n in z.namelist() if n.startswith('maps/') and n.lower().endswith('.wad')}
known.update(re.findall(r'"([A-Z][A-Z0-9]+)"',catalogue+house))
names=sorted(known|{n.lower() for n in known}|{n.swapcase() for n in known}|{'','MAP1',' MAP01','MAP01 ','MAP01X','mAp01','CAH','CAH-1','CAH160','CAH999','CAH001X'}|{f'ZZ{i:04d}' for i in range(64)})
start=catalogue.index('    static clearscope bool IsLimboMap(');end=catalogue.index('    static clearscope String LocationNameKey(',start)
reference='class CA846CatalogueReference : Object\n{\n'+catalogue[start:end].replace('LocationForMap(mapName)','CaelumWorldCatalogue.LocationForMap(mapName)').replace('== LOCATION_MANSION','== CaelumWorldCatalogue.LOCATION_MANSION')+'}\n'
clock=clock[:clock.index('class CaelumWorldClockTicker')].replace('CaelumWorldClock','CA846ReferenceClock').replace('CaelumWorldCatalogue.IsLimboMap','CA846CatalogueReference.IsLimboMap')
start=runtime.index('    static double Stamp(');end=runtime.index('    static void PlayerStep(',start)
stamp=runtime[start:end].replace(' Stamp(',' ReferenceStamp(',1).replace('CaelumWorldCatalogue.IsLimboMap','CA846CatalogueReference.IsLimboMap')
source=reference+clock+'''
class CA846LocationChecks : EventHandler
{
    CaelumWorldClock Actual;
    CA846ReferenceClock Reference;
    int Revision;
    transient bool Checked;
    int Checks,Errors;
    void Check(bool valid,String message)
    {Checks++;if(!valid)Errors++;Console.Printf("CA846 CHECK %s %s",valid?"PASS":"FAIL",message);}
    void Seed(int kind)
    {
        int days=kind==4?2147483647:kind==0?0:1;
        int tics=kind>=3?CaelumWorldClock.TicsPerDay()-1:kind==2?CaelumWorldClock.TicsPerHour()-1:0;
        int divisor=int(CaelumWorldClock.SecondsPerGameHour("MAP01")/CaelumConstants.REAL_SECONDS_PER_GAME_HOUR);
        int fraction=kind>=2?divisor-1:0;
        Actual.CompletedDays=Reference.CompletedDays=days;
        Actual.DayTics=Reference.DayTics=tics;
        Actual.LimboSubTics=Reference.LimboSubTics=fraction;
        Actual.LocalClockRevision=Reference.LocalClockRevision=kind==0?0:1;
        Actual.LimboDays=Reference.LimboDays=days;
        Actual.LimboDayTics=Reference.LimboDayTics=tics;
    }
    bool Same()
    {return Actual.CompletedDays==Reference.CompletedDays && Actual.DayTics==Reference.DayTics
        && Actual.LimboSubTics==Reference.LimboSubTics && Actual.LocalClockRevision==Reference.LocalClockRevision
        && Actual.LimboDays==Reference.LimboDays && Actual.LimboDayTics==Reference.LimboDayTics;}
    STAMP_FUNCTION
    override void WorldTick()
    {
        if(Checked)return;Checked=true;Checks=Errors=0;
        bool fresh=Revision==0;
        Check(fresh || Revision==1,"saved_revision");
        if(fresh)
        {
            Actual=CaelumWorldClock(Actor.Spawn('CaelumWorldClock',(0,0,64),NO_REPLACE));
            Reference=CA846ReferenceClock(Actor.Spawn('CA846ReferenceClock',(0,0,64),NO_REPLACE));
            if(Actual!=null){Actual.bNoInteraction=true;Actual.bNoGravity=true;}
            if(Reference!=null){Reference.bNoInteraction=true;Reference.bNoGravity=true;}
        }
        Check(Actual!=null && Reference!=null,"original_clock_references");
        if(Actual==null || Reference==null)return;
        int divisor=int(CaelumWorldClock.SecondsPerGameHour("MAP01")/CaelumConstants.REAL_SECONDS_PER_GAME_HOUR);
        Check(fresh || (Same() && Actual.CompletedDays==1 && Actual.DayTics==CaelumWorldClock.TicsPerDay()-1
            && Actual.LimboSubTics==divisor-1 && Actual.LocalClockRevision==1),"saved_fields");
        Check(Actual.Owner==null && Reference.Owner==null,"detached_test_ownership");
        Check(CaelumThermalRuntime.Stamp(null)==0 && ReferenceStamp(null)==0,"null_clock");
        String names[]={MAP_NAMES};
        for(int i=0;i<names.Size();i++)
        {
            Check(CaelumWorldCatalogue.IsLimboMap(names[i])==CA846CatalogueReference.IsLimboMap(names[i]),"map_predicate");
            Check(CaelumWorldClock.SecondsPerGameHour(names[i])==CA846ReferenceClock.SecondsPerGameHour(names[i]),"time_scale");
            Check(CaelumWorldClock.MapTimeScale(names[i])==CA846ReferenceClock.MapTimeScale(names[i]),"map_scale");
        }
        String advances[]={"MAP01","map01","MAP03","CAH159","ZZ846"};
        int steps=divisor*2+1;
        for(int map=0;map<advances.Size();map++)for(int kind=0;kind<5;kind++)
        {
            Seed(kind);Check(CaelumThermalRuntime.Stamp(Actual)==ReferenceStamp(Actual),"stamp_before");
            for(int step=0;step<steps;step++)
            {Actual.AdvanceOnMap(advances[map]);Reference.AdvanceOnMap(advances[map]);Check(Same(),"native_step_boundary");}
            Check(CaelumThermalRuntime.Stamp(Actual)==ReferenceStamp(Actual),"stamp_after");
            Actual.AdvanceTics(CaelumWorldClock.TicsPerDay()+1);Reference.AdvanceTics(CaelumWorldClock.TicsPerDay()+1);
            Check(Same(),"journey_day_boundary");
        }
        Seed(3);Revision=1;
        int expected=5+names.Size()*3+advances.Size()*5*(steps+3);
        Console.Printf("CA846 FIXTURE_COMPLETE fresh=%d map=%s names=%d checks=%d expected=%d errors=%d",fresh,level.MapName,names.Size(),Checks,expected,Errors);
    }
}
'''.replace('STAMP_FUNCTION',stamp).replace('MAP_NAMES',','.join(json.dumps(n,ensure_ascii=True) for n in names))
files={'ZSCRIPT':('version "4.14.2"\n'+source).encode(),'MAPINFO':('gameinfo { AddEventHandlers="CA846LocationChecks" }\nmap '+a.map+' "Clock classification checks" {}\n').encode(),'maps/'+a.map+'.wad':(ROOT/'assets/validation_5826/away.wad').read_bytes()}
checks=out/'checks.pk3'
with zipfile.ZipFile(checks,'x') as z:
    for name,data in sorted(files.items()):z.writestr(zipfile.ZipInfo(name,(2026,11,19,0,0,0)),data)
(out/'checks.zs').write_text(source,encoding='utf-8');(out/'names.json').write_text(json.dumps(names,indent=2)+'\n',encoding='utf-8')
(out/'session.ini').write_text('[GlobalSettings]\nvid_preferbackend=1\nvid_fullscreen=false\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\nsnd_mastervolume=0.05\ni_soundinbackground=true\nvid_maxfps=60\nvid_vsync=false\nvid_defwidth=1280\nvid_defheight=720\nwin_w=1296\nwin_h=759\ncon_notifytime=0\nuse_mouse=false\nlanguage=enu\n',encoding='utf-8')
(out/'commands.cfg').write_text('wait 40; save clock.zds; wait 5; quit\n',encoding='utf-8')
engine=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe');iwad=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD');packages=[a.runtime.resolve(),checks]
launch=['+map',a.map]
if a.load:shutil.copyfile(a.load,out/'input.zds');launch=['-loadgame','input.zds']
command=[str(engine),'-noautoload','-nomouse','-iwad',str(iwad),'-file',*map(str,packages),'-config',str(out/'session.ini'),'-savedir',str(out),'-window','-width','1280','-height','720','+logfile',str(out/'engine.log'),*launch,'+exec',str(out/'commands.cfg')]
startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
markers=('Script error','VM execution aborted','Execution could not continue','DIED WITH FATAL ERROR')
with (out/'process.log').open('wb') as log:
    proc=subprocess.Popen(command,cwd=out,stdout=log,stderr=log,startupinfo=startup);deadline=time.monotonic()+120
    while proc.poll() is None:
        f=out/'engine.log';sample=f.read_text(encoding='utf-8',errors='replace') if f.exists() else ''
        if any(s in sample for s in markers) or time.monotonic()>deadline:proc.terminate();break
        time.sleep(.25)
    code=proc.wait(timeout=15)
log=(out/'engine.log').read_text(encoding='utf-8',errors='replace');result=re.search(r'CA846 FIXTURE_COMPLETE fresh=(\d+) map=(\w+) names=(\d+) checks=(\d+) expected=(\d+) errors=(\d+)',log)
errors=[s for s in markers if s in log]+[s for s in log.splitlines() if s.startswith('CA846 CHECK FAIL')]
passed=code==0 and not errors and result is not None and int(result[1])==int(a.load is None) and result[2]==a.map and int(result[3])==len(names) and result[4]==result[5] and int(result[6])==0 and (out/'clock.zds').is_file()
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
report=dict(issue=846,passed=passed,exit_code=code,command=command,errors=errors,result=list(result.groups()) if result else None,sha256={str(p):sha(p) for p in packages},reference_runtime_sha256=sha(a.reference_runtime),loaded_save_sha256=sha(a.load) if a.load else None,saved_sha256=sha(out/'clock.zds') if (out/'clock.zds').exists() else None)
(out/'RESULTS.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8');print(json.dumps({k:report[k] for k in ('passed','errors','result')}));raise SystemExit(not passed)
