"""Measure fixed versus seven-slot MD3 presentation in a controlled art room.

One and64 noninteractive visual bodies reuse #283's inspection population.
These are not combatants or an all-character/campaign performance acceptance.
"""
from pathlib import Path
import argparse
import hashlib
import importlib.util
import json
import os
import re
import subprocess
import sys
import time
import zipfile

ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'assets/validation_v5_16_3'))
from run_nahuelito_preview import wad
sys.path.insert(0,str(ROOT/'assets/validation_v5_12_7'))
from analyze_vulkan_presents import inspect,summarize
ENGINE=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
IWAD=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')

def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ['runtime','presentation-layer','output']:parser.add_argument('--'+name,type=Path,required=True)
    args=parser.parse_args();runtime=args.runtime.resolve(strict=True);layer=args.presentation_layer.resolve(strict=True)
    existing=subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/FO','CSV','/NH']).decode(errors='replace')
    if '"gzdoom.exe"' in existing.lower():parser.error('Another native engine is running.')
    out=args.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
    report={'issue':458,'scope':__doc__.strip(),'runtime_sha256':digest(runtime),'engine_sha256':digest(ENGINE),
            'layer_sha256':digest(layer/'ca_presentation.dll'),'runs':[]}
    for count,kind in [(1,'fixed'),(1,'modular'),(64,'modular'),(64,'fixed')]:
        folder=out/f'{kind}-{count}';folder.mkdir()
        source='''class CA458BenchBody : CaelumDomingoPilotFrames
{Default {+NOINTERACTION +NOGRAVITY +NOBLOCKMAP RenderRadius 240;}}
class CA458BenchCamera : Actor
{Default {+NOINTERACTION +NOGRAVITY CameraHeight 0;} States {Spawn:TNT1 A -1;Stop;}}
class CA458Bench : EventHandler
{
    int Age;double Previous;Array<double> Tics;Array<Actor> Bodies;
    override bool InputProcess(InputEvent e){return true;}
    override void WorldTick()
    {
        Age++;
        if(Age==5)
        {
            let user=CaelumPlayer(players[0].mo);user.CharacterCreationComplete=true;user.CreationWizardOpen=false;user.bInvisible=true;
            let camera=Actor.Spawn('CA458BenchCamera',(900,-900,750),NO_REPLACE);camera.Angle=135;camera.Pitch=27;players[0].camera=camera;
            for(int index=0;index<COUNT;index++)
            {
                vector3 point=COUNT==1?(0,0,0):((index%8)*140-490,(index/8)*140-490,0);
                Bodies.Push(Actor.Spawn('CA458BenchBody',point,NO_REPLACE));
            }
            Console.Printf("CA458 BENCH bodies=%d",Bodies.Size());
        }
        if(Age==175)Console.Printf("CA458 BEGIN");
        if(Age<175 || Age>875)return;
        double now=MSTimeF();if(Previous>0)Tics.Push(now-Previous);Previous=now;
        if(Age==875)
        {
            Console.Printf("CA458 END");
            for(int index=0;index<Tics.Size();index++)Console.Printf("CA458 TIC %.6f",Tics[index]);
            Console.Printf("CA458 COMPLETE bodies=%d samples=%d",Bodies.Size(),Tics.Size());
        }
    }
}'''.replace('COUNT',str(count))
        if kind=='modular':
            definition=(ROOT/'src/caelum/data/domingo_modules.modeldef').read_text().replace('CaelumDomingoPilotBody','CA458BenchBody')
        else:
            definition='Model CA458BenchBody\n{\n Path "models/caelum/domingo"\n Model 0 "domingo.md3"\n Skin 0 "domingo_skin.png"\n Scale 1 1 1\n DontCullBackFaces\n'
            definition+=''.join(f' FrameIndex D3{i//26:02X} {chr(65+i%26)} 0 {i}\n' for i in range(375))+'}\n'
        fixture=folder/'fixture.pk3'
        with zipfile.ZipFile(fixture,'w') as package:
            for name,blob in {'ZSCRIPT':('version "4.14.2"\n'+source).encode(),'MODELDEF':definition.encode(),'maps/CA455V.wad':wad(224),
                'MAPINFO':b'gameinfo { AddEventHandlers="CA458Bench" }\nmap CA455V "Character module presentation" { sky1="CABASKY",0 nointermission }\n'}.items():
                package.writestr(zipfile.ZipInfo(name,(2026,11,13,0,0,0)),blob)
        (folder/'session.ini').write_text('[LastRun]\nVersion=225\n[GlobalSettings]\nvid_preferbackend=1\nvid_vsync=false\nvid_maxfps=0\ncl_capfps=false\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_fullscreen=false\nvid_defwidth=1280\nvid_defheight=720\nwin_w=1296\nwin_h=759\nuse_mouse=false\nlanguage=enu\n')
        (folder/'commands.cfg').write_text('wait 900; screenshot scene.png; wait 10; quit\n')
        env=os.environ.copy();env.update(VK_LAYER_PATH=str(layer),VK_INSTANCE_LAYERS='VK_LAYER_CA_presentation',CA_PRESENT_TRACE=str(folder/'presents.csv'))
        command=[str(ENGINE),'-noautoload','-nomouse','-iwad',str(IWAD),'-file',str(runtime),str(fixture),'-config',str(folder/'session.ini'),'-savedir',str(folder),'-window','+logfile',str(folder/'engine.log'),'+map','CA455V','+exec',str(folder/'commands.cfg')]
        startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
        markers={};offset=0;deadline=time.monotonic()+180
        with (folder/'process.log').open('wb') as stream:
            process=subprocess.Popen(command,cwd=folder,env=env,startupinfo=startup,stdout=stream,stderr=stream)
            while process.poll() is None and time.monotonic()<deadline:
                logpath=folder/'engine.log'
                if logpath.exists():
                    with logpath.open('rb') as logstream:logstream.seek(offset);chunk=logstream.read();offset=logstream.tell()
                    text=chunk.decode(errors='replace')
                    for marker in ['BEGIN','END']:
                        if 'CA458 '+marker in text:markers[marker]=time.perf_counter()*1000
                time.sleep(.1)
            if process.poll() is None:process.terminate()
            process.wait(timeout=10)
        log=(folder/'engine.log').read_text(errors='replace') if (folder/'engine.log').exists() else ''
        errors=[line for line in log.splitlines() if any(token in line for token in ['Script error','Execution could not continue','VM execution aborted','Unknown command','Unable to load model'])]
        samples=[float(value) for value in re.findall(r'CA458 TIC ([\d.]+)',log)]
        result={'kind':kind,'bodies':count,'pid':process.pid,'exit_code':process.returncode,'errors':errors,'markers_qpc_ms':markers,
            'fixture_sha256':digest(fixture),'passed':process.returncode==0 and not errors and len(samples)==700 and set(markers)=={'BEGIN','END'}}
        if result['passed']:
            result['simulation']=summarize(samples)
            result['presentation']=inspect(folder/'presents.csv',process.pid,markers['BEGIN'],markers['END'])
        report['runs'].append(result);(out/'RESULTS.json').write_text(json.dumps(report,indent=2)+'\n')
        print(json.dumps(result),flush=True)
        if not result['passed']:raise SystemExit(1)

if __name__=='__main__':main()
