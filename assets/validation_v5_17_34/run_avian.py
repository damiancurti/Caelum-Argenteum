"""Inspect the real avian combat class and compare old/new save continuity."""
from pathlib import Path
import argparse
import hashlib
import importlib.util
import json
import math
import shutil
import subprocess
import time
import zipfile
from PIL import Image, ImageChops

ROOT=Path(__file__).resolve().parents[2]
ENGINE=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
IWAD=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')


def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()


def fixture(out,species,studio=False):
    spec=importlib.util.spec_from_file_location('old_room',ROOT/'assets/validation_v5_16_3/run_nahuelito_preview.py')
    old_room=importlib.util.module_from_spec(spec);spec.loader.exec_module(old_room)
    config=json.loads((ROOT/'assets/source/art/avian_711/ANIMATION.json').read_text())
    inspection=json.loads(Path(__file__).with_name('INSPECTION.json').read_text())
    config['inspection']['views']+=inspection['additional_views']
    config['inspection']['action_views']=inspection['action_views']
    species_config=config['species'][species]
    source=(ROOT/'assets/validation_v5_17_5/pombero.zs').read_text(encoding='utf-8')
    source=source.replace('CA461','CA711').replace('ca461','ca711')
    source=source.replace('CaelumBestiary006',species_config['actor']).replace('CA-FOLK-006',species_config['catalogue_id']).replace('duende',species)
    poses=[];coverage=[]
    for index,row in enumerate(config['frames']):
        expression=f"VisualState(Actor.GetSpriteIndex('{row['sprite']}'),{ord(row['letter'])-65})"
        poses.append(f'if(pose=={index})Frozen={expression};')
        coverage.append(f'if({expression}!=null)covered++;')
    views=[]
    for index,view in enumerate(config['inspection']['views']):
        p=view['position'];target=view['target'];delta=[b-a for a,b in zip(p,target)]
        angle=math.degrees(math.atan2(delta[1],delta[0]));pitch=-math.degrees(math.atan2(delta[2],math.hypot(*delta[:2])))
        views.append(f'if(view=={index}){{Camera.SetOrigin(({",".join(map(str,p))}),false);Camera.Angle={angle};Camera.Pitch={pitch};}}')
    for name,value in [('POSE_CASES','\n'.join(poses)),('COVERAGE_CASES','\n'.join(coverage)),('VIEW_CASES','\n'.join(views)),('POSE_COUNT',str(len(poses)))]:source=source.replace(name,value)
    if studio:
        lights=''
        for lamp in config['inspection']['studio']['lights']:
            x,y,z=lamp['position'];red,green,blue=lamp['color'];radius=lamp['radius']
            lights+=('{let lamp=Actor.Spawn(\"CA711Camera\",('+str(x)+','+str(y)+','+str(z)+'),NO_REPLACE);lamp.A_AttachLight(\'Studio\',DynamicLight.PointLight,('+str(red)+'<<16)|('+str(green)+'<<8)|'+str(blue)+','+str(radius)+',0,DynamicLight.LF_ATTENUATE|DynamicLight.LF_NOSHADOWMAP);}')
        source=source.replace('Driver.Subject=Subject;','Driver.Subject=Subject;'+lights)
    files={'ZSCRIPT':('version "4.14.2"\n'+source).encode(),'maps/CA455V.wad':old_room.wad(config['inspection']['studio']['ambient'] if studio else 224),
           'MAPINFO':b'gameinfo { AddEventHandlers="CA711Events" }\nmap CA455V "Avian inherited combat model" { sky1="CABASKY",0 nointermission }\n'}
    package=out/'fixture.pk3'
    with zipfile.ZipFile(package,'w') as archive:
        for name,blob in sorted(files.items()):archive.writestr(zipfile.ZipInfo(name,(2026,11,13,0,0,0)),blob)
    (out/'fixture.zs').write_bytes(source.encode())
    return package,config


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ['runtime','output']:parser.add_argument('--'+name,type=Path,required=True)
    parser.add_argument('--baseline',type=Path);parser.add_argument('--model',type=Path)
    parser.add_argument('--visual-only',action='store_true');parser.add_argument('--interactive',action='store_true')
    parser.add_argument('--studio',action='store_true',help='Use the documented inspection-only lights; separate from ordinary ambient review.')
    parser.add_argument('--species',choices=('cachiru','kakuy','kelenken'),required=True)
    args=parser.parse_args();runtime=args.runtime.resolve(strict=True)
    baseline=args.baseline.resolve(strict=True) if args.baseline else runtime
    overlay=args.model.resolve(strict=True)/'preview.pk3' if args.model else None
    if b'"gzdoom.exe"' in subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/FO','CSV','/NH']).lower():parser.error('Another native engine is running.')
    out=args.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
    package,config=fixture(out,args.species,args.studio)
    common='screenblocks 12; crosshair 0; con_notifytime 0; wait 70; '
    audit='netevent ca711_verify; wait 5; netevent ca711_collision; wait 5; netevent ca711_motion_start; wait 5; netevent ca711_motion_verify; wait 5; '
    captures='gl_interpolate_model_frames false; '+''.join(f'netevent ca711_view {i} {config["inspection"]["action_views"].get(row["action"],0)}; wait 8; netevent ca711_pose_verify; wait 3; screenshot pose-{i:02}-{row["action"]}.png; wait 3; ' for i,row in enumerate(config['frames']))
    captures+=''.join(f'netevent ca711_view {view.get("default_pose",0)} {i}; wait 8; screenshot view-{view["name"]}.png; wait 3; ' for i,view in enumerate(config['inspection']['views'][1:],1))
    used_views=sorted({config['inspection']['action_views'].get(row['action'],0) for row in config['frames']})
    captures+=''.join(f'netevent ca711_view 0 {view}; wait 5; netevent ca711_hide 1; wait 5; screenshot empty-view-{view}.png; wait 5; netevent ca711_hide 0; wait 5; ' for view in used_views)
    captures+='netevent ca711_view 0 0; wait 5; netevent ca711_hide 1; wait 5; screenshot empty.png; wait 5; netevent ca711_hide 0; wait 5; gl_interpolate_model_frames true; '
    phases=[('baseline',baseline,False,None),('old-save-model',runtime,True,'baseline'),('fresh-model',runtime,True,None),
            ('model-reload',runtime,True,'fresh-model'),('rollback',baseline,False,'fresh-model')]
    if args.visual_only or args.interactive:phases=[('visual',runtime,True,None)]
    report=dict(issue=711,species=args.species,studio=args.studio,runtime_sha256=digest(runtime),baseline_sha256=digest(baseline),fixture_sha256=digest(package),
                model_overlay_sha256=digest(overlay) if overlay else None,engine_sha256=digest(ENGINE),runs=[])
    for label,used,candidate,parent in phases:
        folder=out/label;folder.mkdir();ini=folder/'session.ini'
        ini.write_text('[LastRun]\nVersion=225\n[GlobalSettings]\nvid_preferbackend=1\nvid_fullscreen=false\nvid_defwidth=1280\nvid_defheight=720\nwin_w=1296\nwin_h=759\nvid_maxfps=60\nvid_vsync=false\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nlanguage=enu\n')
        entry=['+map','CA455V'];commands=common
        if parent:shutil.copyfile(out/parent/'checkpoint.zds',folder/'input.zds');entry=['-loadgame','input.zds']
        else:commands+='netevent ca711_prepare; wait 70; netevent ca711_snapshot; wait 5; '
        commands+=audit
        if label in ['fresh-model','visual']:commands+=captures+'netevent ca711_verify; wait 5; '
        commands+='netevent ca711_view 0 0; wait 10; save checkpoint; wait 15; quit\n'
        if args.interactive:
            commands=common+'gl_interpolate_model_frames false; netevent ca711_prepare; wait 10; '+''.join(f'bind F{i+1} "netevent ca711_view {pose} {config["inspection"]["action_views"].get(config["frames"][pose]["action"],0)}"; ' for i,pose in enumerate(config['inspection']['keys']))+'\n'
            commands+=''.join(f'bind {i+1} "netevent ca711_view {v.get("default_pose",0)} {i}"; ' for i,v in enumerate(config['inspection']['views']))+'\n'
        cfg=folder/'commands.cfg';cfg.write_text(commands)
        command=[str(ENGINE),'-noautoload','-nomouse','-iwad',str(IWAD),'-file',str(used)]
        if candidate and overlay:command.append(str(overlay))
        command += [str(package),'-config',str(ini),'-savedir',str(folder),'-window','+logfile',str(folder/'engine.log'),*entry,'+exec',str(cfg)]
        if args.interactive:
            print('F1-F10 select documented poses; 1-6 select idle views; 7 shows lying art. Console: netevent ca711_view <pose 0-22> <view 0-6>. Save/reload only this isolated session.',flush=True)
            print(json.dumps({'pose_keys':dict(zip(['F'+str(i+1) for i in range(len(config['inspection']['keys']))],config['inspection']['keys'])),'views':{str(i+1):v['name'] for i,v in enumerate(config['inspection']['views'])}}),flush=True)
            command.remove('-nomouse');subprocess.run(command,cwd=folder,check=True);return
        startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
        tokens=['Script error','Execution could not continue','VM execution aborted','FATAL ERROR','Cannot find savegame']
        with (folder/'process.log').open('wb') as stream:
            process=subprocess.Popen(command,cwd=folder,startupinfo=startup,stdout=stream,stderr=stream);deadline=time.monotonic()+120
            while process.poll() is None and time.monotonic()<deadline:
                logpath=folder/'engine.log';log=logpath.read_text(errors='replace') if logpath.exists() else ''
                if any(token in log for token in tokens):break
                time.sleep(.2)
            if process.poll() is None:process.terminate()
            code=process.wait(timeout=10)
        log=(folder/'engine.log').read_text(errors='replace') if (folder/'engine.log').exists() else ''
        errors=[line for line in log.splitlines() if any(token in line for token in tokens+['CA711 FAIL','Unknown command','Unknown texture','Unable to load model'])]
        assertions=sum(line.startswith('CA711 PASS') for line in log.splitlines())
        expected=16+(len(config['frames'])+12 if label in ['fresh-model','visual'] else 0)
        result=dict(phase=label,exit_code=code,passed=code==0 and not errors and assertions==expected and (folder/'checkpoint.zds').exists(),assertions=assertions,expected_assertions=expected,errors=errors,
                    captures={path.name:digest(path) for path in sorted(folder.glob('*.png'))})
        if label in ['fresh-model','visual'] and result['passed']:
            result['visible_pose_pixels']={}
            for path in sorted(folder.glob('pose-*.png')):
                row=config['frames'][int(path.name.split('-')[1])]
                view=config['inspection']['action_views'].get(row['action'],0)
                with Image.open(folder/f'empty-view-{view}.png') as empty, Image.open(path) as capture:
                    difference=ImageChops.difference(capture.convert('RGB'),empty.convert('RGB'))
                    result['visible_pose_pixels'][path.name]=sum(max(pixel)>16 for pixel in difference.get_flattened_data())
            result['distinct_pose_captures']=len({checksum for name,checksum in result['captures'].items() if name.startswith('pose-')})
            result['passed'] &= len(result['visible_pose_pixels'])==len(config['frames']) and min(result['visible_pose_pixels'].values())>500 and result['distinct_pose_captures']>=12
        report['runs'].append(result);(out/'RESULTS.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
        print(json.dumps({key:result[key] for key in ['phase','passed','assertions','errors']}),flush=True)
        if not result['passed']:raise SystemExit(1)


if __name__=='__main__':main()
