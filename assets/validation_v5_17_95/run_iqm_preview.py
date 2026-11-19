"""Compare diagnostic skeletal IQM with the unchanged seven MD3 modules."""
from pathlib import Path
import argparse,hashlib,json,re,struct,subprocess,sys,time,zipfile
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'assets/validation_v5_17_92'))
from run_underbody import write_console_chain,wad
ENGINE=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
IWAD=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()

def candidate_package(candidate,target):
    """Build a deterministic overlay from tracked source exports, not a shipped PK3."""
    manifest=json.loads((candidate/'manifest.json').read_text(encoding='utf-8'))
    with zipfile.ZipFile(target,'w') as package:
        for name,expected in sorted(manifest['sha256'].items()):
            path=candidate/name;assert digest(path)==expected,name
            package.writestr(zipfile.ZipInfo(name,(2026,11,19,0,0,0)),path.read_bytes())
    return target

def view_data(candidate,runtime):
    cfg=json.loads((ROOT/'assets/source/art/iqm_assessment_834/DESIGN.json').read_text(encoding='utf-8'))
    modules=json.loads((ROOT/cfg['module_config']).read_text(encoding='utf-8'))
    design=json.loads((ROOT/cfg['source_design']).read_text(encoding='utf-8'));bounds=[[] for _ in range(375)]
    with zipfile.ZipFile(runtime) as package:
        for key in modules['groups']:
            md3=package.read(modules['module_path']+'/'+key+'.md3');h=struct.unpack_from('<4sI64s9I',md3)
            iqm=(candidate/cfg['model_path']/(key+'.iqm')).read_bytes();q=struct.unpack_from('<16s27I',iqm)
            assert h[4]==375 and q[20]==375
            for i in range(375):
                bounds[i].append(struct.unpack_from('<6f',md3,h[8]+i*56))
                bounds[i].append(struct.unpack_from('<6f',iqm,q[23]+i*32))
    centers=[];distances=[];offset=0
    for row in design['export_actions'].values():
        count=len(row['frames']);all_bounds=[b for frame in bounds[offset:offset+count] for b in frame]
        low=[min(b[i] for b in all_bounds) for i in range(3)];high=[max(b[i+3] for b in all_bounds) for i in range(3)]
        centers.append([(a+b)/2 for a,b in zip(low,high)]);distances.append(max(205,.9*max(b-a for a,b in zip(low,high))));offset+=count
    source='class CA834Data : Object { static clearscope Vector3 Focus(int pose) {\n'
    for axis,name in enumerate('xyz'):source+=' static const double '+name+'[]={'+','.join(f'{p[axis]:.6f}' for p in centers)+'};\n'
    source+=' int i=Clamp(pose,0,23);return(x[i],y[i],z[i]);}\nstatic clearscope double Distance(int pose){static const double values[]={'+','.join(f'{v:.6f}' for v in distances)+'};return values[Clamp(pose,0,23)];}\n'
    names=','.join("'"+key+".iqm'" for key in modules['groups'])
    legacy_names=','.join("'"+key+".md3'" for key in modules['groups'])
    retained=','.join('1' if key in cfg['hybrid_md3_modules'] else '0' for key in modules['groups'])
    source+='static play void Show(Actor body,int slot,bool visible,bool hybrid){static const name files[]={'+names+'};\n'
    source+='static const name oldFiles[]={'+legacy_names+'};static const int retained[]={'+retained+'};\n'
    source+='if(hybrid && retained[slot])body.A_ChangeModel(\'None\',slot,"models/caelum/characters/domingo",oldFiles[slot],slot,"models/caelum/characters/domingo",\'domingo_skin.png\',visible?0:CMDL_HIDEMODEL);\nelse '
    source+=f'body.A_ChangeModel(\'None\',slot,"{cfg["model_path"]}",files[slot],slot,"models/caelum/characters/domingo",\'domingo_skin.png\',visible?0:CMDL_HIDEMODEL);'+'}\n}\n'
    return source

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ['runtime','candidate','output']:parser.add_argument('--'+name,type=Path,required=True)
    parser.add_argument('--quick',action='store_true');args=parser.parse_args()
    runtime=args.runtime.resolve(strict=True);candidate=args.candidate.resolve(strict=True);out=args.output.resolve();out.relative_to(ROOT/'build')
    tasks=subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/FO','CSV','/NH']).decode(errors='replace')
    if '"gzdoom.exe"' in tasks.lower():parser.error('Another native engine is running.')
    out.mkdir(parents=True,exist_ok=False)
    overlay=candidate_package(candidate,out/'candidate.pk3')
    with zipfile.ZipFile(runtime) as package:reference=package.read('caelum/data/domingo_modules.modeldef').decode('utf-8').replace('CaelumDomingoPilotBody','CA834MD3Preview')
    fixture=out/'fixture.pk3';source=view_data(candidate,runtime)+Path(__file__).with_name('iqm_preview.zs').read_text(encoding='utf-8')
    with zipfile.ZipFile(fixture,'w') as package:
        for name,blob in {'maps/CA455V.wad':wad(224),'ZSCRIPT':('version "4.14.2"\n'+source).encode(),'MODELDEF':reference.encode(),
          'MAPINFO':b'gameinfo { AddEventHandlers="CA834PreviewEvents" }\nmap CA455V "Native skeletal format comparison" { sky1="CABASKY",0 nointermission }\n'}.items():
            package.writestr(zipfile.ZipInfo(name,(2026,11,19,0,0,0)),blob)
    (out/'session.ini').write_text('[LastRun]\nVersion=225\n[GlobalSettings]\nvid_fullscreen=false\nvid_preferbackend=1\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\nlanguage=enu\nvid_defwidth=1280\nvid_defheight=720\nwin_w=1296\nwin_h=759\n')
    poses=[0,2,8,10,17] if args.quick else list(range(24));captures=[]
    fresh='screenblocks 12; fov 60; crosshair 0; con_notifytime 0; wait 140; netevent ca834_prepare; wait 20; '
    cases=[(pose,view) for pose in poses for view in ([7] if args.quick else [3,7])]
    if not args.quick:cases.extend((0,view) for view in [0,2,4,6])
    for pose,view in cases:
        fresh+=f'netevent ca834_pose {pose}; netevent ca834_rotate {view}; '
        for kind,label in [(0,'md3'),(1,'iqm'),(2,'hybrid')]:
            name=f'{label}-pose{pose:02d}-view{view}.png';captures.append(name)
            fresh+=f'netevent ca834_select {kind}; wait 70; screenshot {name}; wait 5; '
    for kind in [1,2]:
        fresh+=f'netevent ca834_select {kind}; '
        for slot in range(7):fresh+=f'netevent ca834_module {slot} 0; wait 10; netevent ca834_module {slot} 1; wait 10; '
        fresh+='netevent ca834_restore; netevent ca834_animate; wait 11; netevent ca834_motion; '
    fresh+='netevent ca834_saved; '
    for kind,label in [(1,'iqm'),(2,'hybrid')]:
        fresh+=f'netevent ca834_select {kind}; wait 70; screenshot {label}-saved.png; wait 5; netevent ca834_verify {kind}; save {label}; wait 20; '
    fresh+='quit;'
    phases=[('fresh',fresh,['+map','CA455V'])]
    for kind,label in [(1,'iqm'),(2,'hybrid')]:
        reload=f'screenblocks 12; fov 60; crosshair 0; con_notifytime 0; wait 70; netevent ca834_verify {kind}; screenshot {label}-reloaded.png; wait 5; quit;'
        phases.append(('reload-'+label,reload,['-loadgame',label+'.zds']))
    report={'issue':834,'quick':args.quick,'runtime_sha256':digest(runtime),'candidate_sha256':digest(overlay),'manifest_sha256':digest(candidate/'manifest.json'),'fixture_sha256':digest(fixture),'engine_sha256':digest(ENGINE),'runs':[]}
    expected_fresh=1+len(cases)*4+2*(1+14+1+1)+2*(1+6)
    for label,commands,entry in phases:
        write_console_chain(out,label,commands)
        command=[str(ENGINE),'-noautoload','-nomouse','-iwad',str(IWAD),'-file',str(runtime),str(overlay),str(fixture),'-config',str(out/'session.ini'),'-savedir',str(out),'-window','+logfile',str(out/(label+'.log')),*entry,'+exec',str(out/(label+'.cfg'))]
        startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
        with (out/(label+'-process.log')).open('wb') as stream:
            process=subprocess.Popen(command,cwd=out,stdout=stream,stderr=stream,startupinfo=startup);deadline=time.monotonic()+600
            while process.poll() is None and time.monotonic()<deadline:
                log=(out/(label+'.log')).read_text(errors='replace') if (out/(label+'.log')).exists() else ''
                if any(token in log for token in ['Script error','Execution could not continue','VM execution aborted']):break
                time.sleep(.2)
            if process.poll() is None:process.terminate()
            code=process.wait(timeout=10)
        log=(out/(label+'.log')).read_text(errors='replace') if (out/(label+'.log')).exists() else ''
        errors=[line for line in log.splitlines() if any(token in line for token in ['Script error','Execution could not continue','VM execution aborted','Unknown command','Unable to load model','CA834 FAIL'])]
        count=sum(line.startswith('CA834 PASS') for line in log.splitlines());expected=expected_fresh if label=='fresh' else 6
        result={'phase':label,'exit_code':code,'assertions':count,'expected_assertions':expected,'errors':errors,'passed':code==0 and not errors and count==expected}
        report['runs'].append(result);report['captures']={p.name:digest(p) for p in sorted(out.glob('*.png'))};(out/'RESULTS.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
        print(json.dumps(result),flush=True)
        if not result['passed']:raise SystemExit(1)
    report['saved_visibility_pixel_match']={label:report['captures'][label+'-saved.png']==report['captures'][label+'-reloaded.png'] for label in ['iqm','hybrid']}
    assert set(captures+[label+'-'+phase+'.png' for label in ['iqm','hybrid'] for phase in ['saved','reloaded']])==set(report['captures'])
    (out/'RESULTS.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    assert all(report['saved_visibility_pixel_match'].values()),'Saved/reloaded selection renders differently.'

if __name__=='__main__':main()
