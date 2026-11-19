"""Capture matched MAP02 material views and a bounded native corridor walk.

Teleports place diagnostic cameras, not ordinary campaign traversal. Existing
geometry and content remain live. The observer grants invulnerability/notarget
only to its disposable inspection player. No production source is changed.
"""
from pathlib import Path
import argparse,hashlib,json,re,subprocess,time,zipfile

ROOT=Path(__file__).resolve().parents[2]
ENGINE=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
IWAD=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')
FATAL=('Script error','Execution could not continue','VM execution aborted','compile errors','DIED WITH FATAL ERROR','CA847 FAIL')
digest=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()

def cameras():
    layout=json.loads((ROOT/'assets/map02_maze/LAYOUT.json').read_text(encoding='utf-8'))
    manifest=json.loads((ROOT/'assets/map02_maze/MAP02_MANIFEST.json').read_text(encoding='utf-8'))
    section=layout['sections'][0];grid=layout['grid'];half=layout['chamber_width']/2
    junction=section['nodes'][section['entry']]
    a,b=[section['nodes'][i] for i in section['edges'][0]]
    channel=[(a[0]+b[0])/2,(a[1]+b[1])/2-layout['channel_width']/2]
    refuge=manifest['refuges'][0]['center'];offset=layout['refuge_half_size']/2
    gate=layout['boss']['gate']
    return [dict(name='entrance',point=layout['player_start'],angle=90),
            dict(name='junction',point=[junction[0]-half+grid*2,junction[1]-half+grid*2],angle=45),
            dict(name='channel',point=channel,angle=0),
            dict(name='refuge',point=[refuge[0]+offset,refuge[1]-offset],angle=135),
            dict(name='boss_access',point=[gate[0]+layout['passage_width'],gate[1]-layout['channel_width']/2],angle=180)]

def fixture(out,points):
    cases='\n'.join(f'case {i}: point=({r["point"][0]},{r["point"][1]},0); angle={r["angle"]}; break;' for i,r in enumerate(points))
    source='''class CA847Views : EventHandler
{
    int View;
    vector3 WalkStart;
    void Place(int index)
    {
        let user=CaelumPlayer(players[0].mo);
        if(user==null || level.MapName!="MAP02"){Console.Printf("CA847 FAIL map/player");return;}
        vector3 point; double angle;
        switch(index) { CASES default:Console.Printf("CA847 FAIL index");return; }
        user.bInvulnerable=true;user.bNOTARGET=true;
        user.GetPersistentCharacterState(true).DemoNarrativeDelivered=2047;
        user.GetPersistentCharacterState(true).DemoNarrativePending=0;
        user.SetOrigin(point,false);user.FindFloorCeiling();
        user.SetOrigin((point.X,point.Y,user.FloorZ),false);
        user.Angle=angle;user.Pitch=0;user.Vel=(0,0,0);
        Console.Printf("CA847 VIEW %d pos=%.3f,%.3f,%.3f angle=%.3f headroom=%.3f",index,user.Pos.X,user.Pos.Y,user.Pos.Z,user.Angle,user.CeilingZ-user.FloorZ);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca847_next"){Place(View);View++;}
        else if(e.Name=="ca847_walk"){Place(2);WalkStart=players[0].mo.Pos;}
        else if(e.Name=="ca847_done")
        {
            let user=players[0].mo;
            double distance=(user.Pos-WalkStart).Length();
            Console.Printf("CA847 WALK distance=%.3f pos=%.3f,%.3f,%.3f",distance,user.Pos.X,user.Pos.Y,user.Pos.Z);
            Console.Printf("CA847 %s views=%d",View==5 && distance>0?"PASS":"FAIL",View);
        }
    }
}
'''.replace('CASES',cases)
    (out/'probe.zs').write_text(source,encoding='utf-8',newline='\n')
    package=out/'views.pk3'
    with zipfile.ZipFile(package,'w') as z:
        for name,data in sorted({'ZSCRIPT':'version "4.14.2"\n#include "probe.zs"\n','MAPINFO':'gameinfo { AddEventHandlers="CA847Views" }\n','probe.zs':source}.items()):
            z.writestr(zipfile.ZipInfo(name,(2026,11,19,0,0,0)),data.encode())
    return package

def run(runtime,overlay,out,points,probe,label):
    folder=out/label;folder.mkdir()
    config=folder/'session.ini'
    config.write_text('[LastRun]\nVersion=225\n[GlobalSettings]\nvid_preferbackend=1\nvid_vsync=false\nvid_maxfps=0\ncl_capfps=false\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\nsnd_mastervolume=0.05\ni_soundinbackground=true\nvid_fullscreen=false\nvid_defwidth=1280\nvid_defheight=720\nuse_mouse=false\nlanguage=enu\n',encoding='utf-8',newline='\n')
    commands=['wait 140']
    for row in points:commands+=['netevent ca847_next','wait 35','screenshot '+row['name']+'.png','wait 5']
    commands+=['netevent ca847_walk','wait 5','+forward','wait 35','-forward','wait 5','netevent ca847_done','screenshot walk.png','wait 5','quit']
    cfg=folder/'start.cfg';cfg.write_text('; '.join(commands)+'\n',encoding='utf-8',newline='\n')
    command=[str(ENGINE),'-noautoload','-nomouse','-iwad',str(IWAD),'-file',str(runtime),*([str(overlay)] if label=='candidate' else []),str(probe),'-config',str(config),'-savedir',str(folder),'-window','-width','1280','-height','720','-rngseed','428','+logfile',str(folder/'engine.log'),'+map','MAP02','+exec',str(cfg)]
    startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
    timed_out=False
    with (folder/'process.log').open('wb') as stream:
        process=subprocess.Popen(command,cwd=folder,startupinfo=startup,stdout=stream,stderr=stream)
        deadline=time.monotonic()+120
        while process.poll() is None:
            log=folder/'engine.log';text=log.read_text(errors='replace') if log.exists() else ''
            if any(t in text for t in FATAL):break
            if time.monotonic()>deadline:timed_out=True;break
            time.sleep(.25)
        if process.poll() is None:process.terminate();process.wait(timeout=10)
    text=(folder/'engine.log').read_text(errors='replace');errors=[t for t in FATAL if t in text]
    images=[r['name']+'.png' for r in points]+['walk.png']
    result=dict(label=label,passed=not timed_out and not errors and process.returncode==0 and 'CA847 PASS views=5' in text and all((folder/n).exists() for n in images),exit_code=process.returncode,timed_out=timed_out,errors=errors,command=command,markers=[s for s in text.splitlines() if 'CA847 ' in s],images={n:digest(folder/n) for n in images if (folder/n).exists()})
    (folder/'RESULTS.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8',newline='\n');print(json.dumps(result),flush=True)
    return result

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--runtime',type=Path,required=True);p.add_argument('--overlay',type=Path,required=True);p.add_argument('--output',type=Path,required=True);a=p.parse_args()
    out=a.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
    points=cameras();probe=fixture(out,points);results=[]
    for label in ('control','candidate'):
        result=run(a.runtime.resolve(),a.overlay.resolve(),out,points,probe,label);results.append(result)
        if not result['passed']:break
    report=dict(issue=847,runtime_sha256=digest(a.runtime),overlay_sha256=digest(a.overlay),engine_sha256=digest(ENGINE),probe_sha256=digest(probe),cameras=points,runs=results,passed=len(results)==2 and all(r['passed'] for r in results),qualification=__doc__)
    (out/'RESULTS.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
    raise SystemExit(not report['passed'])

if __name__=='__main__':main()
