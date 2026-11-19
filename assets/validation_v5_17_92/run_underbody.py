"""Inspect independent anatomy, retained clothing and all accepted action samples."""
from pathlib import Path
import argparse,hashlib,json,re,subprocess,sys,time,zipfile
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'assets/validation_v5_16_3'))
from run_nahuelito_preview import wad
ENGINE=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
IWAD=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()

def write_console_chain(out,label,commands):
    # Separate exec lines run independently of earlier wait commands. Chain
    # short single-line files instead, keeping the final exec behind each wait.
    chunks=[];current=[];length=0
    for command in commands.strip().split(';'):
        command=command.strip()
        if not command:continue
        if length+len(command)+2>2800:
            chunks.append(current);current=[];length=0
        current.append(command);length+=len(command)+2
    if current:chunks.append(current)
    names=[label+'.cfg']+[f'{label}-part{i+1:02d}.cfg' for i in range(1,len(chunks))]
    for i,chunk in enumerate(chunks):
        if i+1<len(chunks):chunk.append(f'exec "{names[i+1]}"')
        line='; '.join(chunk)+'\n';assert len(line.encode())<4096
        (out/names[i]).write_text(line)

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    for n in ['runtime','output']:parser.add_argument('--'+n,type=Path,required=True)
    parser.add_argument('--model',type=Path,help='Optional candidate export; otherwise use the complete runtime.')
    parser.add_argument('--quick',action='store_true');parser.add_argument('--interactive',action='store_true')
    args=parser.parse_args();runtime=args.runtime.resolve(strict=True);model=args.model.resolve(strict=True) if args.model else None;out=args.output.resolve();out.relative_to(ROOT/'build')
    tasks=subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/FO','CSV','/NH']).decode(errors='replace')
    if '"gzdoom.exe"' in tasks.lower():parser.error('Close the existing engine before this sequential test.')
    out.mkdir(parents=True,exist_ok=False)
    definition=(model/'MODELDEF').read_text() if model else (ROOT/'assets/source/art/underbody_827/underbody_preview.modeldef').read_text()
    sys.path.insert(0,str(ROOT/'assets/generators'))
    from validate_underbody import validate_binding
    binding_errors=validate_binding(definition)
    if binding_errors:parser.error('; '.join(binding_errors))
    legacy='Model CA827LegacyPreview\n{\n Path "models/caelum/domingo"\n Model 0 "domingo.md3"\n Skin 0 "domingo_skin.png"\n Scale 1 1 1\n DontCullBackFaces\n'
    legacy+=''.join(f' FrameIndex D3{i//26:02X} {chr(65+i%26)} 0 {i}\n' for i in range(375))+'}\n'
    fixture=out/'fixture.pk3'
    with zipfile.ZipFile(fixture,'w') as archive:
        blobs={'maps/CA455V.wad':wad(112),'ZSCRIPT':b'version "4.14.2"\n'+Path(__file__).with_name('underbody_preview.zs').read_bytes(),
         'GLDEFS':b'pointlight CA827Key { color 1.0 0.9 0.8 size 220 }\npointlight CA827Fill { color 0.6 0.7 1.0 size 180 }\nobject CA827KeyLight { frame TNT1 { light CA827Key } }\nobject CA827FillLight { frame TNT1 { light CA827Fill } }\n',
         'MODELDEF':(legacy+('' if model else definition)).encode(),'MAPINFO':b'gameinfo { AddEventHandlers="CA827PreviewEvents" }\nmap CA455V "Modular anatomy inspection" { sky1="CABASKY",0 nointermission }\n'}
        for n,b in blobs.items():archive.writestr(zipfile.ZipInfo(n,(2026,11,16,0,0,0)),b)
    (out/'session.ini').write_text('[LastRun]\nVersion=225\n[GlobalSettings]\nvid_fullscreen=false\nvid_preferbackend=1\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\nlanguage=enu\nvid_defwidth=1280\nvid_defheight=720\nwin_w=1296\nwin_h=759\n')
    start='screenblocks 12; fov 60; crosshair 0; con_notifytime 0; gl_lights 1; gl_light_models 1; wait 140; netevent ca827_prepare; wait 20; '
    fresh=start;captures=[]
    for mode in ([2,1] if args.quick else [0,1,2,3]):
        fresh+=f'netevent ca827_mode {mode}; '
        for view in ([0,2,4] if args.quick else range(8)):
            name=f'mode{mode}-view{view}.png';captures.append(name)
            fresh+=f'netevent ca827_rotate {view}; wait 12; screenshot {name}; wait 5; '
    fresh+='netevent ca827_mode 2; netevent ca827_rotate 7; '
    for pose in ([1,8] if args.quick else range(24)):
        name=f'pose{pose:02d}.png';captures.append(name)
        fresh+=f'netevent ca827_pose {pose}; wait 12; screenshot {name}; wait 5; '
    fresh+='netevent ca827_animate; wait 11; netevent ca827_motion; netevent ca827_freeze; netevent ca827_rotate 0; netevent ca827_saved; wait 15; screenshot hidden.png; wait 5; netevent ca827_verify; save anatomy; wait 20; quit\n'
    reload='screenblocks 12; fov 60; crosshair 0; con_notifytime 0; wait 35; netevent ca827_verify; screenshot reloaded.png; wait 5; netevent ca827_mode 2; wait 15; screenshot reload-restored.png; wait 5; quit\n'
    runs=[('fresh',fresh,['+map','CA455V']),('reload',reload,['-loadgame','anatomy.zds'])]
    if args.interactive:
        commands=start+'bind F1 "netevent ca827_mode 0"; bind F2 "netevent ca827_mode 1"; bind F3 "netevent ca827_mode 2"; bind F4 "netevent ca827_mode 3"; bind F5 "netevent ca827_nextview"; bind F6 "netevent ca827_nextpose"; bind F7 "netevent ca827_animate"; bind F8 "netevent ca827_freeze";\n'
        runs=[('interactive',commands,['+map','CA455V'])]
        print('F1 original / F2 assembly / F3 construction anatomy / F4 clothing / F5 rotate / F6 pose / F7 walk / F8 freeze. No automatic acceptance.',flush=True)
    report={'issue':827,'runtime_sha256':digest(runtime),'model_sha256':digest(model/'preview.pk3') if model else None,'fixture_sha256':digest(fixture),'engine_sha256':digest(ENGINE),'quick':args.quick,'runs':[]}
    for label,commands,entry in runs:
        write_console_chain(out,label,commands)
        command=[str(ENGINE),'-noautoload','-iwad',str(IWAD),'-file',str(runtime),*([str(model/'preview.pk3')] if model else []),str(fixture),'-config',str(out/'session.ini'),'-savedir',str(out),'-window','+logfile',str(out/(label+'.log')),*entry,'+exec',str(out/(label+'.cfg'))]
        if args.interactive:subprocess.run(command,cwd=out,check=True);return
        command.insert(2,'-nomouse');startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
        with (out/(label+'-process.log')).open('wb') as stream:
            process=subprocess.Popen(command,cwd=out,stdout=stream,stderr=stream,startupinfo=startup);deadline=time.monotonic()+180
            while process.poll() is None and time.monotonic()<deadline:
                p=out/(label+'.log');log=p.read_text(errors='replace') if p.exists() else ''
                if any(k in log for k in ['Script error','Execution could not continue','VM execution aborted']):break
                time.sleep(.2)
            if process.poll() is None:process.terminate()
            code=process.wait(timeout=10)
        p=out/(label+'.log');log=p.read_text(errors='replace') if p.exists() else ''
        errors=[l for l in log.splitlines() if any(k in l for k in ['Script error','Execution could not continue','VM execution aborted','Unknown command','Unable to load model','CA827 FAIL'])]
        count=sum(l.startswith('CA827 PASS') for l in log.splitlines());expected=5 if label=='reload' else 6+(2 if args.quick else 24)
        result={'phase':label,'exit_code':code,'assertions':count,'expected_assertions':expected,'errors':errors,'passed':code==0 and not errors and count==expected and 'CA827 COMPLETE failures=0' in log}
        report['runs'].append(result);report['captures']={p.name:digest(p) for p in sorted(out.glob('*.png'))}
        (out/'RESULTS.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(result),flush=True)
        if not result['passed']:raise SystemExit(1)
    report['saved_visibility_pixel_match']=report['captures']['hidden.png']==report['captures']['reloaded.png']
    (out/'RESULTS.json').write_text(json.dumps(report,indent=2)+'\n')
    assert report['saved_visibility_pixel_match'],'Saved visibility differs after reload.'
    assert all(n in report['captures'] for n in captures)

if __name__=='__main__':main()
