"""Capture native orientation/animation and save continuation of the #455 pilot.

The generated visual actor uses a temporary flat viewing map and optional studio
lighting. This is not an encounter, gameplay AI, collision or author-acceptance test.
"""
from pathlib import Path
import argparse
import hashlib
import json
import math
import struct
import subprocess
import time
import zipfile

ROOT=Path(__file__).resolve().parents[2]


def wad(ambient=224):
    text=['namespace="ZDoom";']
    points=[(1024,-1024),(-1024,-1024),(-1024,1024),(1024,1024)]
    for x,y in points:text.append(f'vertex {{ x={x}; y={y}; }}')
    text.append('sector { heightfloor=0; heightceiling=768; texturefloor="CMST01"; textureceiling="F_SKY1"; lightlevel='+str(ambient)+'; }')
    for i in range(4):
        text.append('sidedef { sector=0; texturemiddle="CMST01"; }')
        text.append(f'linedef {{ v1={i}; v2={(i+1)%4}; sidefront={i}; blocking=true; }}')
    text.append('thing { type=1; x=400; y=-480; angle=130; skill1=true; skill2=true; skill3=true; skill4=true; skill5=true; single=true; coop=true; }')
    data='\n'.join(text).encode();lumps=[('CA455V',b''),('TEXTMAP',data),('ENDMAP',b'')]
    body=bytearray();directory=bytearray()
    for name,value in lumps:
        directory.extend(struct.pack('<ii8s',12+len(body),len(value),name.encode().ljust(8,b'\0')));body.extend(value)
    return struct.pack('<4sii',b'PWAD',3,12+len(body))+body+directory


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--model',type=Path,required=True)
    parser.add_argument('--runtime',type=Path,required=True)
    parser.add_argument('--kind',choices=('nahuelito','pombero'),default='nahuelito')
    parser.add_argument('--interactive',action='store_true',help='Leave the visual scene open for author review, without reporting an automatic pass.')
    args=parser.parse_args();out=args.output.resolve();out.mkdir(parents=True,exist_ok=True)
    views=[('three-quarter',(300,-330,190),8,0),('front',(400,0,160),4,0),
           ('side',(0,-400,160),4,0),('rear',(-440,0,160),4,0),
           ('rotated',(300,-330,190),8,90),('swim-down',(300,-330,190),8,0),
           ('swim-up',(300,-330,190),8,0),('head',(200,-125,190),0,0)]
    head_target=(110,0,229);body_target=(0,0,120);lighting={'ambient':224,'lights':[]}
    if args.kind=='pombero':
        preview=json.loads((ROOT/'assets/source/art/pombero_455/DESIGN.json').read_text(encoding='utf-8'))['preview']
        views=preview['views'];head_target=preview['head_target'];body_target=preview['body_target']
        lighting=preview['lighting']
    source='''class CA455Camera : Actor { Default { +NOINTERACTION +NOGRAVITY } States { Spawn: TNT1 A -1; Stop; } }
class CA455VisualDriver : Actor
{
    Actor Subject; Actor View; int Sample; int ViewIndex; State MotionSnapshot;
    Default { +NOINTERACTION +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
    override void Tick()
    {
        Super.Tick();
        if(Subject!=null && Sample==0)Subject.SetState(Subject.FindState("Frame0"),false);
        if(Subject!=null && Sample==22)Subject.SetState(Subject.FindState("Frame22"),false);
        if(Subject!=null && Sample==34)Subject.SetState(Subject.FindState("Frame34"),false);
    }
    void Configure(int index)
    {
        ViewIndex=index;
        if(Subject==null)Subject=Actor.Spawn("CA455NahuelitoPreview",(0,0,0),NO_REPLACE);
        if(View==null)View=Actor.Spawn("CA455Camera",(0,0,160),NO_REPLACE);
        Sample=0; Subject.Angle=0;
'''
    for i,(name,p,pitch,angle) in enumerate(views):
        target=head_target if name=='head' else body_target
        camera_angle=math.degrees(math.atan2(target[1]-p[1],target[0]-p[0]));sample=22 if name.endswith('-down') else 34 if name.endswith('-up') else 0
        source+=f'if(index=={i}){{View.SetOrigin(({p[0]},{p[1]},{p[2]}),false);View.Angle={camera_angle};View.Pitch={pitch};Subject.Angle={angle};Sample={sample};}}\n'
    source+='''View.ClearInterpolation(); Subject.ClearInterpolation(); players[0].camera=View;
        Console.Printf("CA455 VIEW index=%d sample=%d angle=%.1f",ViewIndex,Sample,Subject.Angle);
    }
}
class CA455VisualEvents : EventHandler
{
    override void NetworkProcess(ConsoleEvent e)
    {
        let driver=CA455VisualDriver(ActorIterator.Create(455001,"CA455VisualDriver").Next());
        if(driver==null)
        {
            driver=CA455VisualDriver(Actor.Spawn("CA455VisualDriver",(0,0,0),NO_REPLACE));
            driver.ChangeTID(455001);
        }
'''
    for i in range(len(views)):source+=f'if(e.Name=="ca455view{i}")driver.Configure({i});\n'
    source+='''if(e.Name=="ca455animate") { driver.Sample=-1;driver.Subject.SetStateLabel("Swim");Console.Printf("CA455 ANIMATION running"); }
        if(e.Name=="ca455motion_a")driver.MotionSnapshot=driver.Subject.CurState;
        if(e.Name=="ca455motion_b")Console.Printf("CA455 MOTION result=%s",driver.Subject.CurState!=driver.MotionSnapshot?"PASS":"FAIL");
        if(e.Name=="ca455verify")
        {
            int subjects=0;let it=ThinkerIterator.Create("CA455NahuelitoPreview");
            while(it.Next()!=null)subjects++;
            bool ok=subjects==1 && driver.Subject!=null && driver.View!=null && players[0].camera==driver.View;
            Console.Printf("CA455 VERIFY subjects=%d state=%d view=%d result=%s",subjects,driver.Sample,driver.ViewIndex,ok?"PASS":"FAIL");
        }
    }
}'''
    fixture=out/'fixture.pk3'
    if args.kind=='pombero':
        source=source.replace('CA455NahuelitoPreview','CA455PomberoPreview').replace('"Swim"','"Walk"')
        source=source.replace('class CA455Camera : Actor { Default {','class CA455Camera : Actor { Default { CameraHeight 0; Height 0; Radius 0;')
        # Preview-only studio lights persist with the driver; never respawn on load.
        source=source.replace('Actor Subject; Actor View;','Actor Subject; Actor View; bool LightingReady;')
        light_source='if(!LightingReady) { LightingReady=true;'
        for light in lighting['lights']:
            x,y,z=light['position'];red,green,blue=light['color'];radius=light['radius']
            light_source+=f'{{let lamp=Actor.Spawn("CA455Camera",({x},{y},{z}),NO_REPLACE);lamp.A_AttachLight(\'Pilot\',DynamicLight.PointLight,( {red} << 16 ) | ( {green} << 8 ) | {blue},{radius},0,DynamicLight.LF_ATTENUATE|DynamicLight.LF_NOSHADOWMAP);}}'
        source=source.replace('ViewIndex=index;',light_source+'} ViewIndex=index;')
    with zipfile.ZipFile(fixture,'w',zipfile.ZIP_DEFLATED) as package:
        for name,value in {'maps/CA455V.wad':wad(lighting['ambient']),'ZSCRIPT':('version "4.14.2"\n'+source).encode(),
                           'MAPINFO':('map CA455V "'+args.kind.title()+' visual pilot" { sky1="CABASKY",0 nointermission }\ngameinfo { AddEventHandlers="CA455VisualEvents" }').encode()}.items():
            info=zipfile.ZipInfo(name,(2026,11,12,0,0,0));package.writestr(info,value)
    config=out/'isolated.ini';config.write_text('[GlobalSettings]\nvid_fullscreen=false\nvid_preferbackend=1\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\nlanguage=en\n')
    commands='wait 140; '+ '; '.join(f'netevent ca455view{i}; wait 10; screenshot {name}.png' for i,(name,_,_,_) in enumerate(views))
    if args.kind=='pombero':commands='screenblocks 12; crosshair 0; con_notifytime 0; '+commands
    commands+='; netevent ca455view0; wait 10; netevent ca455animate; wait 2; netevent ca455motion_a; screenshot animate-a.png; wait 30; netevent ca455motion_b; screenshot animate-b.png; netevent ca455verify; save pilot.zds; wait 35; quit\n'
    (out/'commands.cfg').write_text(commands)
    engine=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe');iwad=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')
    common=[str(engine),'-noautoload','-iwad',str(iwad),'-file',str(args.runtime.resolve()),str(args.model.resolve()/'preview.pk3'),str(fixture),'-config',str(config),'-savedir',str(out),'-window','-width','1280','-height','720']
    startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
    if args.interactive:
        script='wait 140; netevent ca455view0; netevent ca455animate; '
        script+='; '.join(f'bind F{i+1} "netevent ca455view{i}"' for i in range(len(views)))
        script+='; bind F9 "netevent ca455animate"; echo "F1-F8: viewpoints and poses. F9: animation. Close the game to finish review."\n'
        (out/'interactive.cfg').write_text(script)
        print(args.kind.title()+' visual review: F1-F8 viewpoints/poses, F9 animation. Close the game to finish. No automatic acceptance.')
        startup.wShowWindow=1
        subprocess.run(common+['+logfile',str(out/'interactive.log'),'+map','CA455V','+exec',str(out/'interactive.cfg')],cwd=out,startupinfo=startup,check=True)
        return
    def run(label,extra):
        command=common+['+logfile',str(out/(label+'.log'))]+extra
        with (out/(label+'-process.log')).open('wb') as log:
            proc=subprocess.Popen(command,cwd=out,stdout=log,stderr=log,startupinfo=startup)
            try:code=proc.wait(timeout=120)
            except subprocess.TimeoutExpired:proc.terminate();proc.wait(timeout=10);raise
        text=(out/(label+'.log')).read_text(encoding='utf-8',errors='replace')
        errors=[key for key in ['Script error','Execution could not continue','VM execution aborted','Unknown type','Unable to load model','result=FAIL'] if key in text]
        return {'exit_code':code,'errors':errors,'verify_pass':'CA455 VERIFY subjects=1' in text and 'result=PASS' in text,
                'native_state_advanced':'CA455 MOTION result=PASS' in text}
    result=run('fresh',['+map','CA455V','+exec',str(out/'commands.cfg')])
    if result['exit_code']!=0 or result['errors'] or not result['verify_pass'] or not result['native_state_advanced']:
        (out/'RESULTS.json').write_text(json.dumps({'fresh':result,'scope':__doc__},indent=2)+'\n')
        raise SystemExit(json.dumps(result))
    (out/'reload.cfg').write_text('wait 140; netevent ca455verify; screenshot reload.png; wait 10; quit\n')
    reload=run('reload',['-loadgame','pilot.zds','+exec',str(out/'reload.cfg')])
    captures=[name for name,_,_,_ in views]+['animate-a','animate-b','reload']
    report={'issue':455,'subject':args.kind,'scope':__doc__,'engine_sha256':hashlib.sha256(engine.read_bytes()).hexdigest(),
            'runtime_sha256':hashlib.sha256(args.runtime.read_bytes()).hexdigest(),
            'model_sha256':hashlib.sha256((args.model/'preview.pk3').read_bytes()).hexdigest(),
            'fresh':result,'reload':reload,'captures':{name:hashlib.sha256((out/(name+'.png')).read_bytes()).hexdigest() for name in captures if (out/(name+'.png')).is_file()},
            'animation_capture_changed':(out/'animate-a.png').read_bytes()!=(out/'animate-b.png').read_bytes()}
    (out/'RESULTS.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report))
    assert reload['exit_code']==0 and not reload['errors'] and reload['verify_pass'] and len(report['captures'])==len(captures)


if __name__=='__main__':main()
