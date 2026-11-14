"""Measure actual inventory drop classes before/after model installation.

A single sequential baseline/candidate pair in an isolated room; this is not a
crowd budget, campaign performance acceptance or repeatability estimate.
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

def main(default_kind='coins'):
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ['baseline','runtime','presentation-layer','output']:parser.add_argument('--'+name,type=Path,required=True)
    parser.add_argument('--kind',choices=('coins','consumables','water','food','ammunition','documents','ingots','camp','furniture','waterskin','mates','locks','jewelry','books','gems','ores','headwear','gloves','footwear','clothing','shields'),default=default_kind)
    args=parser.parse_args();baseline=args.baseline.resolve(strict=True);runtime=args.runtime.resolve(strict=True);layer=args.presentation_layer.resolve(strict=True)
    existing=subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/FO','CSV','/NH']).decode(errors='replace')
    if '"gzdoom.exe"' in existing.lower():parser.error('Another native engine is running.')
    out=args.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
    report={'issue':702 if args.kind=='shields' else 696 if args.kind=='clothing' else 694 if args.kind=='footwear' else 688 if args.kind=='gloves' else 686 if args.kind=='headwear' else 684 if args.kind=='ores' else 678 if args.kind=='gems' else 676 if args.kind=='books' else 674 if args.kind=='jewelry' else 672 if args.kind=='locks' else 670 if args.kind=='mates' else 668 if args.kind=='waterskin' else 666 if args.kind=='furniture' else 664 if args.kind=='camp' else 658 if args.kind=='ingots' else 656 if args.kind=='documents' else 652 if args.kind=='ammunition' else 647,'kind':args.kind,'scope':__doc__.strip(),'baseline_sha256':digest(baseline),'runtime_sha256':digest(runtime),'engine_sha256':digest(ENGINE),
            'layer_sha256':digest(layer/'ca_presentation.dll'),'runs':[]}
    count={'coins':15,'consumables':9,'water':6,'food':6,'ammunition':7,'documents':6,'ingots':7,'camp':2,'furniture':17,'waterskin':2,'mates':3,'locks':16,'jewelry':9,'books':9,'gems':14,'ores':6,'headwear':5,'gloves':4,'footwear':5,'clothing':11,'shields':4}[args.kind]
    for kind in ['sprites','models']:
        folder=out/f'{kind}-{count}';folder.mkdir()
        if args.kind=='coins':
            config=json.loads((ROOT/'assets/source/art/inventory_models_647/COINS.json').read_text())
            kinds=','.join("'%s'"%(item['class']+suffix) for item in config['variants'].values() for suffix in config['denomination_suffixes'])
        else:
            config=json.loads((ROOT/'assets/source/art/inventory_models_647'/args.kind/'DESIGN.json').read_text())
            variants=[*config['variants'].values(),*config.get('reused_variants',[])]
            extras=[binding for item in config['variants'].values() for binding in item.get('additional_bindings',[]) if binding.get('inventory')]
            kinds=','.join("'%s'"%item['class'] for item in variants+extras)
        source="""class CA647BenchCamera : Actor
{Default {+NOINTERACTION +NOGRAVITY CameraHeight 0;} States {Spawn:TNT1 A -1;Stop;}}
class CA647Bench : EventHandler
{
    int Age;double Previous;Array<double> Tics;Array<Actor> Bodies;
    override bool InputProcess(InputEvent e){return true;}
    override void WorldTick()
    {
        Age++;
        if(Age==5)
        {
            let user=CaelumPlayer(players[0].mo);user.CharacterCreationComplete=true;user.CreationWizardOpen=false;user.bInvisible=true;
            let camera=Actor.Spawn('CA647BenchCamera',(0,-100,110),NO_REPLACE);camera.Angle=90;camera.Pitch=47;players[0].camera=camera;
            static const class<Inventory> kinds[]={KINDS};
            for(int index=0;index<kinds.Size();index++)
                Bodies.Push(Actor.Spawn(kinds[index],((index%5-2)*20,(index/5-1)*20,0),NO_REPLACE));
            Console.Printf("CA647 BENCH bodies=%d",Bodies.Size());
        }
        if(Age==175)Console.Printf("CA647 BEGIN");
        if(Age<175 || Age>875)return;
        double now=MSTimeF();if(Previous>0)Tics.Push(now-Previous);Previous=now;
        if(Age==875)
        {
            Console.Printf("CA647 END");
            for(int index=0;index<Tics.Size();index++)Console.Printf("CA647 TIC %.6f",Tics[index]);
            Console.Printf("CA647 COMPLETE bodies=%d samples=%d",Bodies.Size(),Tics.Size());
        }
    }
}""".replace('KINDS',kinds)
        if args.kind=='mates':
            source=source.replace('(0,-100,110)','(0,-36,25)').replace('camera.Pitch=47','camera.Pitch=30').replace('(index%5-2)*20,(index/5-1)*20','(index-1)*12,0')
        if args.kind in ('ingots','gems','ores'):
            ids=','.join(str(item['item_type'] if args.kind in ('gems','ores') else item['material_id']) for item in config['variants'].values())
            source=source.replace("static const class<Inventory> kinds[]={KINDS};".replace('KINDS',kinds), 'static const int materialIds[]={'+ids+'};')
            source=source.replace('index<kinds.Size()', 'index<materialIds.Size()')
            source=source.replace("Bodies.Push(Actor.Spawn(kinds[index],((index%5-2)*20,(index/5-1)*20,0),NO_REPLACE));", "{let item=CaelumMaterialPickup(Actor.Spawn('CaelumMaterialPickup',((index%5-2)*20,(index/5-1)*20,0),NO_REPLACE));item.args[0]=materialIds[index];item.args[1]=2;item.UpdateMaterialVisuals();Bodies.Push(item);}")
        if args.kind!='coins':
            source=source.replace('(0,-100,110)','(0,-180,180)').replace('camera.Pitch=47','camera.Pitch=43')
            source=source.replace('(index%5-2)*20,(index/5-1)*20','(index%3-1)*55,(index/3-1)*55')
        if args.kind=='gems':source=source.replace('(index%3-1)*55,(index/3-1)*55','(index%5-2)*38,(index/5-1)*50')
        if args.kind=='camp':
            # Original PNG sprites have no bottom offset and clip below floor Z.
            # Raise both cohorts and the camera equally for visible cost evidence.
            source=source.replace('(0,-180,180)','(0,-180,244)')
            source=source.replace("Bodies.Push(Actor.Spawn(kinds[index],((index%3-1)*55,(index/3-1)*55,0),NO_REPLACE));",
                "{let item=Actor.Spawn(kinds[index],((index%3-1)*55,(index/3-1)*55,64),NO_REPLACE);item.bNOGRAVITY=true;Bodies.Push(item);}")
        if args.kind=='furniture':
            # Raw furniture PNGs have no bottom offset. Raise both cohorts equally.
            source=source.replace('(0,-180,180)','(0,-180,244)')
            source=source.replace("Bodies.Push(Actor.Spawn(kinds[index],((index%3-1)*55,(index/3-1)*55,0),NO_REPLACE));",
                "{let item=Actor.Spawn(kinds[index],((index%5-2)*35,(index/5-1.5)*35,64),NO_REPLACE);item.bNOGRAVITY=true;Bodies.Push(item);}")
        if args.kind=='locks':
            source=source.replace('index<kinds.Size()','index<16').replace('Bodies.Push(Actor.Spawn(kinds[index],((index%3-1)*55,(index/3-1)*55,0),NO_REPLACE));',
                '{let item=CaelumLockRules.Create(index%8,((index%4-1.5)*40,(index/4-1.5)*40,0));Bodies.Push(item);}')
        if args.kind=='shields':
            source=source.replace('Bodies.Push(Actor.Spawn(kinds[index],((index%3-1)*55,(index/3-1)*55,0),NO_REPLACE));',
                "{let item=CaelumEquipmentItem(Actor.Spawn('CaelumShieldPickup',((index%2-.5)*55,(index/2-.5)*55,0),NO_REPLACE));item.args[0]=index;item.args[1]=1;item.UpdateWorldSprite();Bodies.Push(item);}")
        if args.kind=='jewelry':
            source=source.replace('Bodies.Push(Actor.Spawn(kinds[index],((index%3-1)*55,(index/3-1)*55,0),NO_REPLACE));',
                '{let item=CaelumEquipmentItem(Actor.Spawn(kinds[index],((index%3-1)*55,(index/3-1)*55,0),NO_REPLACE));item.args[0]=index<4?index:index-4;item.args[1]=1;item.UpdateWorldSprite();Bodies.Push(item);}')
        if args.kind in ('headwear','footwear','clothing'):
            source=source.replace('Bodies.Push(Actor.Spawn(kinds[index],((index%3-1)*55,(index/3-1)*55,0),NO_REPLACE));',
                '{let item=CaelumClothing.Create(user,11+index,CaelumConstants.EQUIPMENT_SIZE_M);item.SetOrigin(((index%3-1)*55,(index/3-1)*55,0),false);item.UpdateWorldSprite();Bodies.Push(item);}'.replace('11+index', ('0' if args.kind=='clothing' else '20' if args.kind=='footwear' else '11')+'+index'))
        if args.kind=='gloves':
            source=source.replace('Bodies.Push(Actor.Spawn(kinds[index],((index%3-1)*55,(index/3-1)*55,0),NO_REPLACE));',
                '{let item=CaelumClothing.Create(user,16+index,CaelumConstants.EQUIPMENT_SIZE_M);item.SetOrigin(((index%2-.5)*55,(index/2-.5)*55,0),false);item.UpdateWorldSprite();Bodies.Push(item);}')
        if args.kind=='clothing':
            source=source.replace('(0,-180,180)','(0,-260,250)').replace('(index%3-1)*55,(index/3-1)*55','(index%4-1.5)*50,(index/4-1)*55')
        if args.kind=='books':
            source=source.replace('index<kinds.Size()','index<9').replace('Bodies.Push(Actor.Spawn(kinds[index],((index%3-1)*55,(index/3-1)*55,0),NO_REPLACE));',
                '{let item=Actor.Spawn(kinds[index/3],((index%3-1)*40,(index/3-1)*48,0),NO_REPLACE);item.args[0]=index<6?CaelumConstants.WEAPON_TYPE_SUPPORT_BOOK:CaelumConstants.MATERIAL_BOOK_BASE;item.args[1]=index%3+1;item.args[4]=CaelumConstants.ESSENCE_QUINTESSENCE+1;if(index<6)CaelumEquipmentItem(item).UpdateWorldSprite();else CaelumMaterialPickup(item).UpdateMaterialVisuals();Bodies.Push(item);}')
        fixture=folder/'fixture.pk3'
        with zipfile.ZipFile(fixture,'w') as package:
            for name,blob in {'ZSCRIPT':('version "4.14.2"\n'+source).encode(),'maps/CA455V.wad':wad(224),
                'MAPINFO':b'gameinfo { AddEventHandlers="CA647Bench" }\nmap CA455V "Coin drop presentation" { sky1="CABASKY",0 nointermission }\n'}.items():
                package.writestr(zipfile.ZipInfo(name,(2026,11,13,0,0,0)),blob)
        (folder/'session.ini').write_text('[LastRun]\nVersion=225\n[GlobalSettings]\nvid_preferbackend=1\nvid_vsync=false\nvid_maxfps=0\ncl_capfps=false\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_fullscreen=false\nvid_defwidth=1280\nvid_defheight=720\nwin_w=1296\nwin_h=759\nuse_mouse=false\nlanguage=enu\n')
        (folder/'commands.cfg').write_text('wait 900; screenshot scene.png; wait 10; quit\n')
        env=os.environ.copy();env.update(VK_LAYER_PATH=str(layer),VK_INSTANCE_LAYERS='VK_LAYER_CA_presentation',CA_PRESENT_TRACE=str(folder/'presents.csv'))
        command=[str(ENGINE),'-noautoload','-nomouse','-iwad',str(IWAD),'-file',str(baseline if kind=='sprites' else runtime),str(fixture),'-config',str(folder/'session.ini'),'-savedir',str(folder),'-window','+logfile',str(folder/'engine.log'),'+map','CA455V','+exec',str(folder/'commands.cfg')]
        startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
        markers={};offset=0;text='';deadline=time.monotonic()+180
        with (folder/'process.log').open('wb') as stream:
            process=subprocess.Popen(command,cwd=folder,env=env,startupinfo=startup,stdout=stream,stderr=stream)
            while process.poll() is None and time.monotonic()<deadline:
                logpath=folder/'engine.log'
                if logpath.exists():
                    with logpath.open('rb') as logstream:logstream.seek(offset);chunk=logstream.read();offset=logstream.tell()
                    text=chunk.decode(errors='replace')
                    for marker in ['BEGIN','END']:
                        if 'CA647 '+marker in text:markers[marker]=time.perf_counter()*1000
                if any(token in text for token in ['Script error','Execution could not continue','VM execution aborted']):break
                time.sleep(.1)
            if process.poll() is None:process.terminate()
            process.wait(timeout=10)
        log=(folder/'engine.log').read_text(errors='replace') if (folder/'engine.log').exists() else ''
        errors=[line for line in log.splitlines() if any(token in line for token in ['Script error','Execution could not continue','VM execution aborted','Unknown command','Unable to load model'])]
        samples=[float(value) for value in re.findall(r'CA647 TIC ([\d.]+)',log)]
        result={'kind':kind,'bodies':count,'pid':process.pid,'exit_code':process.returncode,'errors':errors,'markers_qpc_ms':markers,
            'fixture_sha256':digest(fixture),'passed':process.returncode==0 and not errors and len(samples)==700 and set(markers)=={'BEGIN','END'}}
        if args.kind in ('gems','ores','headwear','gloves','footwear','clothing','shields'):
            observed=[tuple(map(int,values)) for values in re.findall(r'CA647 COMPLETE bodies=(\d+) samples=(\d+)',log)]
            result['observed_completion_counts']=observed
            if observed!=[(count,700)]:
                errors.append(f'Expected {count} native objects and 700 samples: '+str(observed));result['passed']=False
        if result['passed']:
            result['simulation']=summarize(samples)
            result['presentation']=inspect(folder/'presents.csv',process.pid,markers['BEGIN'],markers['END'])
        report['runs'].append(result);(out/'RESULTS.json').write_text(json.dumps(report,indent=2)+'\n')
        print(json.dumps(result),flush=True)
        if not result['passed']:raise SystemExit(1)

if __name__=='__main__':main()
