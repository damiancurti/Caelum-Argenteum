"""Check municipal routes, prop collision, native vendor Use and disposable saves."""
from pathlib import Path
import argparse,hashlib,importlib.util,json,math,shutil,subprocess,sys,time,zipfile

ROOT=Path(__file__).resolve().parents[2]
ENGINE=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
IWAD=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')
SHA=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
FATAL=['Script error','Execution could not continue','Cannot find savegame','VM execution aborted','Unexpected JIT error','REGT_ADDROF not implemented','CA866 FAIL','CA886 SCENE FAIL','CA886 ROUTE FAIL','CA886 COLLISION FAIL','CA886 SERVICE FAIL']

def fixture(manifest,views,out):
    spec=importlib.util.spec_from_file_location('municipal_views',Path(__file__).with_name('run_views.py'))
    module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
    source=(views/'probe.zs').read_text(encoding='utf-8')
    old=module.scene_probe(manifest);assert source.count(old)==1
    source=source.replace(old,module.scene_probe(manifest,allow_default=True))
    points=module.cameras(manifest);by_name={r['name']:r for r in points}
    grid=json.loads((ROOT/'assets/barracas_redesign/LAYOUT.json').read_text())['grid']
    city=json.loads((ROOT/'assets/barracas_redesign/RUNTIME.json').read_text())
    vendor=next(r for r in city['shops'] if r['building_id']==manifest['civic']['id']);vx,vy,vz=vendor['vendor']
    entrance=by_name['municipality_entrance']['point'];inside=by_name['municipality_inside']['point']
    offices=[r['point'] for r in points if r['name'].startswith('office_')];archive=by_name['archive']['point']
    court=manifest['courtyard'];center=[(court[0]+court[2])/2,(court[1]+court[3])/2]
    route=[entrance,inside,center,inside,[inside[0],offices[0][1]],*reversed(offices),
           [archive[0],offices[0][1]],archive,[archive[0],vy+grid],[vx+grid,vy+grid],[vx+grid,vy]]
    route_calls='\n'.join(f'        okay=WalkTo(({x:.9f},{y:.9f})) && okay;' for x,y in route[1:])
    positions='\n'.join(f'        probe.SetOrigin(({p["point"][0]:.9f},{p["point"][1]:.9f},0),false);probe.FindFloorCeiling();if(!probe.TestMobjLocation())blocked++;' for p in manifest['positions'])
    detail_index=next(i for i,r in enumerate(points) if r['name']=='archive_detail')
    source+=f'''
class CA886CollisionProbe : Actor
{{ Default {{Radius 1;Height 1;+SOLID +CANPASS +NOGRAVITY RenderStyle "None";}} States {{Spawn:TNT1 A -1;Stop;}} }}
class CA886Routes : CA866Views
{{
    int Moves;
    bool WalkTo(vector2 target)
    {{
        let user=players[0].mo;
        int steps=int(Ceil((target-user.Pos.XY).Length()/{grid/4}));
        for(int i=steps;i>0;i--)
        {{
            vector2 step=(target-user.Pos.XY)/i;
            if(!user.TryMove(user.Pos.XY+step,0))return false;
            Moves++;
        }}
        return (target-user.Pos.XY).Length()<.01;
    }}
    void Routes()
    {{
        let user=CaelumPlayer(players[0].mo);user.ClosePalomoMerchant();user.Vel=(0,0,0);
        Console.Printf("CA886 SERVICE PREP previous_box=%d wizard=%d",user.MagicBoxOwned,user.CreationWizardOpen);
        user.MagicBoxOwned=true;let record=user.GetPersistentCharacterState(true);record.MagicBoxOwned=true;user.PersistCharacterState();
        user.SetOrigin(({entrance[0]},{entrance[1]},0),false);user.FindFloorCeiling();
        user.SetOrigin((user.Pos.X,user.Pos.Y,user.FloorZ),false);
        bool okay=user.TestMobjLocation();Moves=0;
{route_calls}
        user.Angle=180;user.Pitch=0;user.Vel=(0,0,0);user.FolkloreInteractionUseLatched=false;
        Console.Printf("CA886 ROUTE %s moves=%d pos=%.3f,%.3f,%.3f",okay?"PASS":"FAIL",Moves,user.Pos.X,user.Pos.Y,user.Pos.Z);
        CheckScene();
        let probe=Actor.Spawn('CA886CollisionProbe',user.Pos,NO_REPLACE);
        if(probe==null){{Console.Printf("CA886 COLLISION FAIL missing probe");return;}}
        probe.A_SetSize(user.Radius,user.Height,false);int blocked=0;
{positions}
        bool candidate=level.GetChecksum()=="{manifest['candidate_checksum']}";
        Console.Printf("CA886 COLLISION %s blocked=%d samples={len(manifest['positions'])} radius=%.3f height=%.3f",blocked==(candidate?{len(manifest['positions'])}:0)?"PASS":"FAIL",blocked,probe.Radius,probe.Height);
        probe.Destroy();
    }}
    override void NetworkProcess(ConsoleEvent e)
    {{
        if(e.Name=="ca886_routes")Routes();
        else if(e.Name=="ca886_service")
        {{
            let user=CaelumPlayer(players[0].mo);let vendor=CaelumDomesticMarket.Find({vendor['identity']});
            Console.Printf("CA886 SERVICE STATE box=%d wizard=%d aim=%d range=%.3f distance=%.3f angle=%.3f pitch=%.3f latched=%d menu=%d trade=%d available=%d",user.MagicBoxOwned,user.CreationWizardOpen,CaelumUseGeometry.AimedAt(user,vendor),user.UseRange,user.Distance3D(vendor),user.Angle,user.Pitch,user.FolkloreInteractionUseLatched,user.PalomoMerchantMenuOpen,user.CityTrade!=null,CaelumBattleConsequences.MerchantAvailable(user,vendor));
            bool okay=user.PalomoMerchantMenuOpen && user.CityTrade!=null && user.CityTrade.Vendor==vendor;
            Console.Printf("CA886 SERVICE %s identity=%d",okay?"PASS":"FAIL",vendor==null?-1:vendor.ShopIdentity);
            user.ClosePalomoMerchant();
        }}
        else if(e.Name=="ca886_spanish"){{Place({detail_index});Console.Printf("CA886 LABEL %s",StringTable.Localize("CA886_SCENE_SHELF",false));}}
        else Super.NetworkProcess(e);
    }}
}}
'''
    (out/'probe.zs').write_text(source,encoding='utf-8',newline='\n')
    (out/'route.json').write_text(json.dumps(dict(points=route,vendor=vendor,probe_step=grid/4,scope='Continuous native TryMove from the valid entrance through the courtyard, all office bays, archive and unchanged vendor approach. Centre collision samples use a non-player probe at the current player dimensions; this is not all-map or largest-body acceptance.'),indent=2)+'\n',encoding='utf-8')
    package=out/'routes.pk3'
    with zipfile.ZipFile(package,'x') as z:
        for name,value in sorted({'ZSCRIPT':'version "4.14.2"\n#include "probe.zs"\n','MAPINFO':'gameinfo {AddEventHandlers="CA886Routes"}\n','probe.zs':source}.items()):
            z.writestr(zipfile.ZipInfo(name,(2026,11,21,0,0,0)),value.encode('utf-8'))
    return package

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ['runtime','control-overlay','overlay','manifest','views','output']:parser.add_argument('--'+name,type=Path,required=True)
    args=parser.parse_args()
    assert 'gzdoom.exe' not in subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/FO','CSV','/NH'],text=True,errors='replace').lower()
    out=args.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
    manifest=json.loads(args.manifest.read_text());assert SHA(args.runtime)==manifest['runtime_sha256'] and SHA(args.overlay)==manifest['package_sha256']
    package=fixture(manifest,args.views,out);runs=[]
    startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
    for phase in ['control','candidate_fresh','candidate_reload','default_restored']:
        folder=out/phase;folder.mkdir();candidate=phase.startswith('candidate')
        overlays=[args.overlay.resolve()] if candidate else [args.control_overlay.resolve()] if phase=='control' else []
        config=folder/'session.ini';config.write_text('[LastRun]\nVersion=225\n[GlobalSettings]\nvid_preferbackend=1\nvid_fullscreen=false\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\nvid_maxfps=60\nsnd_mastervolume=0.05\ni_soundinbackground=true\nvid_defwidth=1280\nvid_defheight=720\nwin_w=1296\nwin_h=759\nuse_mouse=false\nlanguage=enu\n',encoding='utf-8')
        entry=['+map','MAP03']
        if phase=='candidate_reload':
            original=out/'candidate_fresh/checkpoint.zds';copied=folder/'checkpoint.zds';shutil.copyfile(original,copied);assert original.read_bytes()==copied.read_bytes()
            entry=['-loadgame','checkpoint.zds']
        commands='con_notifytime 0; wait 140; netevent ca886_routes; wait 2; +use; wait 3; -use; wait 3; netevent ca886_service; language es; netevent ca886_spanish; wait 5; screenshot label-es.png; save checkpoint; wait 10; echo CA886_ROUTES_COMPLETE; quit\n'
        (folder/'start.cfg').write_text(commands,encoding='utf-8')
        command=[str(ENGINE),'-noautoload','-nomouse','-iwad',str(IWAD),'-file',str(args.runtime.resolve()),*[str(p) for p in overlays],str(package),'-config',str(config),'-savedir',str(folder),'-rngseed','428',*entry,'+logfile',str(folder/'engine.log'),'+exec',str(folder/'start.cfg')]
        timeout=False
        with (folder/'process.log').open('wb') as stream:
            process=subprocess.Popen(command,cwd=folder,startupinfo=startup,stdout=stream,stderr=stream);deadline=time.monotonic()+180
            while process.poll() is None:
                path=folder/'engine.log';text=path.read_text(encoding='utf-8',errors='replace') if path.exists() else ''
                if any(marker in text for marker in FATAL):break
                if time.monotonic()>deadline:timeout=True;break
                time.sleep(.25)
            if process.poll() is None:process.terminate();process.wait(timeout=10)
        path=folder/'engine.log';text=path.read_text(encoding='utf-8',errors='replace') if path.exists() else ''
        diagnostics=text+(folder/'process.log').read_text(encoding='utf-8',errors='replace')
        errors=[m for m in FATAL if m in diagnostics]
        row=dict(phase=phase,command=command,exit_code=process.returncode,timed_out=timeout,errors=errors,
                 markers=[l for l in text.splitlines() if 'CA886 ' in l],checkpoint_exists=(folder/'checkpoint.zds').is_file())
        row['passed']=process.returncode==0 and not timeout and not errors and row['checkpoint_exists'] and 'CA886_ROUTES_COMPLETE' in text and text.count('CA886 ROUTE PASS')==1 and text.count('CA886 COLLISION PASS')==1 and text.count('CA886 SERVICE PASS')==1 and text.count(f'CA886 SCENE PASS candidate={int(candidate)} ')==2
        if candidate:row['passed']=row['passed'] and 'CA886 LABEL Estantería de archivo' in text
        (folder/'RESULTS.json').write_text(json.dumps(row,indent=2)+'\n',encoding='utf-8');runs.append(row)
        print(json.dumps(dict(phase=phase,passed=row['passed'],errors=errors,markers=row['markers'])),flush=True)
        if not row['passed']:break
    report=dict(issue=886,runs=runs,passed=len(runs)==4 and all(r['passed'] for r in runs),runtime_sha256=SHA(args.runtime),candidate_sha256=SHA(args.overlay),fixture_sha256=SHA(package),author_acceptance=False,qualification=__doc__)
    (out/'RESULTS.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    raise SystemExit(not report['passed'])

if __name__=='__main__':main()
