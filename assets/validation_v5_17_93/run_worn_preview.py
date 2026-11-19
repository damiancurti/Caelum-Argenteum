"""Inspect candidate garment combinations with native poses and saved visibility."""
from pathlib import Path
import argparse,hashlib,json,re,subprocess,sys,time,zipfile
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'assets/validation_v5_17_92'))
from run_underbody import write_console_chain,wad
ENGINE=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
IWAD=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')
def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()


def camera_data(manifest):
    """Frame whole actions, including horizontal rest/death and raised hands."""
    grouped={}
    for pose in manifest['pose_bounds']:grouped.setdefault(pose['action'],[]).extend(pose['modules'].values())
    centers=[];distances=[]
    for bounds in grouped.values():
        low=[min(row[0][axis] for row in bounds) for axis in range(3)]
        high=[max(row[1][axis] for row in bounds) for axis in range(3)]
        centers.append([(a+b)/2 for a,b in zip(low,high)])
        distances.append(max(205,.9*max(b-a for a,b in zip(low,high))))
    assert len(centers)==24
    source='class CA829ViewData : Object {\n static clearscope Vector3 Focus(int pose) {\n'
    for axis,name in enumerate(['x','y','z']):source+=' static const double '+name+'[]={'+','.join(f'{p[axis]:.6f}' for p in centers)+'};\n'
    source+=' int i=Clamp(pose,0,23); return (x[i],y[i],z[i]); }\n static clearscope double Distance(int pose) {\n'
    source+=' static const double values[]={'+','.join(f'{v:.6f}' for v in distances)+'}; return values[Clamp(pose,0,23)]; }\n'
    art=ROOT/'assets/source/art/worn_clothing_829'
    visibility=json.loads((art/'VISIBILITY.json').read_text());cfg=json.loads((art/'DESIGN.json').read_text())
    slots=visibility['fixture_slots'];mask=lambda names:sum(1<<slots.index(name) for name in names)
    masks=[mask(visibility['body_items_hidden'][row[0]]) for row in cfg['combinations']]
    source+=' static clearscope int Hidden(int body,int head,int hands,int feet) {\n'
    source+=' static const int bodies[]={'+','.join(map(str,masks))+'};\n'
    source+=f' int hidden=body<0?{mask(visibility["body_absent_hidden"])}:bodies[Clamp(body,0,10)];\n'
    for region,rule in visibility['other_regions'].items():source+=f' hidden|={region}<0?{mask(rule["absent_hidden"])}:{mask(rule["present_hidden"])};\n'
    source+=' return hidden; }\n}\n'
    hems=cfg['trouser_hems'];variants=list(hems['variants']);body_ids=[row[0] for row in cfg['combinations']]
    paths=['pants_'+key+'_'+variant+'.md3' for key in body_ids for variant in variants]
    foot_variants=[variants.index(hems['foot_items'][key]) for key in hems['foot_order']]
    addition=' static clearscope name PantsFile(int body,int feet) {\n'
    addition+=' static const name files[]={'+','.join("'"+name+"'" for name in paths)+'};\n'
    addition+=' static const int foot[]={'+','.join(map(str,foot_variants))+'};\n'
    addition+=f' int variant=feet<0?{variants.index("bare")}:foot[Clamp(feet,0,4)]; return files[Clamp(body,0,10)*{len(variants)}+variant]; }}\n'
    source=source[:-2]+addition+'}\n'
    detail_centers=[]
    for column in [1,2,3]:
        names={row[column] for row in cfg['combinations'] if row[column]}
        if column==1:names.add('hair_lower')
        bounds=[manifest['pose_bounds'][0]['modules'][key] for key in names]
        detail_centers.append([(min(b[0][axis] for b in bounds)+max(b[1][axis] for b in bounds))/2 for axis in range(3)])
    addition=' static clearscope Vector3 DetailFocus(int detail) {\n'
    for axis,name in enumerate(['x','y','z']):addition+=' static const double '+name+'[]={'+','.join(f'{p[axis]:.6f}' for p in detail_centers)+'};\n'
    addition+=' int i=Clamp(detail-1,0,2); return (x[i],y[i],z[i]); }\n'
    addition+=' static clearscope double DetailDistance(int detail) {return detail==1?75:detail==2?90:80;}\n'
    source=source[:-2]+addition+'}\n'
    return source,{'centers':centers,'distances':distances,'detail_centers':detail_centers,'visibility_sha256':digest(art/'VISIBILITY.json')}


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ['runtime','output']:parser.add_argument('--'+name,type=Path,required=True)
    parser.add_argument('--model',type=Path,help='Optional candidate export overlay; otherwise inspect installed runtime assets.')
    parser.add_argument('--quick',action='store_true');parser.add_argument('--interactive',action='store_true')
    args=parser.parse_args();runtime=args.runtime.resolve(strict=True);model=args.model.resolve(strict=True) if args.model else None;out=args.output.resolve();out.relative_to(ROOT/'build')
    definition=(model/'MODELDEF' if model else ROOT/'assets/source/art/worn_clothing_829/worn_preview.modeldef').read_text()
    sys.path.insert(0,str(ROOT/'assets/generators'))
    from validate_underbody import validate_binding
    problems=validate_binding(definition,slots=15)
    if problems:parser.error('; '.join(problems))
    tasks=subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/FO','CSV','/NH']).decode(errors='replace')
    if '"gzdoom.exe"' in tasks.lower():parser.error('Close the existing engine before this sequential test.')
    out.mkdir(parents=True,exist_ok=False);fixture=out/'fixture.pk3'
    manifest=json.loads((model/'manifest.json' if model else ROOT/'assets/source/art/worn_clothing_829/EXPORT.json').read_text())
    camera_source,cameras=camera_data(manifest)
    (out/'CAMERAS.json').write_text(json.dumps(cameras,indent=2)+'\n')
    with zipfile.ZipFile(fixture,'w') as package:
        blobs={'maps/CA455V.wad':wad(112),'ZSCRIPT':b'version "4.14.2"\n'+camera_source.encode()+Path(__file__).with_name('worn_preview.zs').read_bytes(),
          'GLDEFS':b'pointlight CA829Key { color 1.0 0.9 0.8 size 220 }\npointlight CA829Fill { color 0.6 0.7 1.0 size 180 }\nobject CA829KeyLight { frame TNT1 { light CA829Key } }\nobject CA829FillLight { frame TNT1 { light CA829Fill } }\n',
          'MAPINFO':b'gameinfo { AddEventHandlers="CA829PreviewEvents" }\nmap CA455V "Worn garment fitting" { sky1="CABASKY",0 nointermission }\n'}
        if not model:blobs['MODELDEF']=definition.encode()
        for name,blob in blobs.items():package.writestr(zipfile.ZipInfo(name,(2026,11,18,0,0,0)),blob)
    (out/'session.ini').write_text('[LastRun]\nVersion=225\n[GlobalSettings]\nvid_fullscreen=false\nvid_preferbackend=1\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\nlanguage=enu\nvid_defwidth=1280\nvid_defheight=720\nwin_w=1296\nwin_h=759\n')
    start='screenblocks 12; fov 60; crosshair 0; con_notifytime 0; gl_lights 1; gl_light_models 1; wait 140; netevent ca829_prepare; wait 20; '
    cases=[(-1,0),(-1,2),(2,0),(2,2),(0,0),(0,2),(7,0),(7,2)] if args.quick else [(kind,view) for kind in range(-1,11) for view in [0,2,4,6]]
    poses=[(2,8),(2,3),(7,1),(7,8),(7,3),(7,10),(7,17),(7,23),(0,2),(0,8),(0,9),(0,10),(1,8),(1,9),(4,8),(4,2),(4,10),(4,17),(10,8),(10,2),(10,10),(10,17)] if args.quick else [(kind,pose) for kind in [2,0,7] for pose in range(24)]
    if not args.quick:poses.extend((kind,pose) for kind in [1,3,4,5,6,8,9,10] for pose in [2,3,8,9,10,17])
    fresh=start;captures=[]
    for kind,view in cases:
        name=f'outfit{kind:02d}-view{view}.png';captures.append(name)
        fresh+=f'netevent ca829_combo {kind}; netevent ca829_rotate {view}; wait 70; netevent ca829_viewcheck; screenshot {name}; wait 5; '
    for kind,pose in poses:
        name=f'outfit{kind:02d}-pose{pose:02d}.png';captures.append(name)
        fresh+=f'netevent ca829_combo {kind}; netevent ca829_rotate 7; netevent ca829_pose {pose}; wait 35; screenshot {name}; wait 5; '
    independent=0;details=0
    if not args.quick:
        for region,count in enumerate([11,5,4,5]):
            fresh+='netevent ca829_combo 2; netevent ca829_freeze; netevent ca829_rotate 7; '
            for item in range(-1,count):
                fresh+=f'netevent ca829_region {region} {item}; wait 10; ';independent+=1
                if item in [-1,count-1]:
                    name=f'region{region}-item{item}.png';captures.append(name)
                    fresh+=f'wait 60; screenshot {name}; wait 5; '
        for region in range(4):
            fresh+=f'netevent ca829_combo 2; netevent ca829_nextregion {region}; wait 5; ';independent+=1
        # Exercise every body/footwear hem, including restoration of bare feet.
        for kind in range(11):
            fresh+=f'netevent ca829_combo {kind}; netevent ca829_freeze; netevent ca829_nextdetail; netevent ca829_nextdetail; netevent ca829_nextdetail; netevent ca829_rotate 2; '
            for item in range(-1,5):
                fresh+=f'netevent ca829_region 3 {item}; wait 10; ';independent+=1
                if kind in [0,2,5,8,10]:
                    name=f'hem-body{kind:02d}-foot{item}.png';captures.append(name)
                    fresh+=f'wait 60; screenshot {name}; wait 5; '
    # Footwear must also be inspected without trousers hiding the retained foot.
    for region,count in ([(3,5)] if args.quick else [(1,5),(2,4),(3,5)]):
        for item in range(count):
            for view in [0,2]:
                name=f'detail{region}-item{item}-view{view}.png';captures.append(name)
                fresh+=f'netevent ca829_detail {region} {item}; netevent ca829_rotate {view}; wait 70; screenshot {name}; wait 5; ';details+=1
    fresh+='netevent ca829_animate; wait 11; netevent ca829_motion; netevent ca829_freeze; netevent ca829_rotate 0; netevent ca829_saved; wait 70; screenshot saved.png; wait 5; netevent ca829_verify; save wardrobe; wait 20; quit\n'
    reload='screenblocks 12; fov 60; crosshair 0; con_notifytime 0; wait 70; netevent ca829_verify; screenshot reloaded.png; wait 5; quit\n'
    runs=[('fresh',fresh,['+map','CA455V']),('reload',reload,['-loadgame','wardrobe.zds'])]
    if args.interactive:
        commands=start+'bind F1 "netevent ca829_nextcombo"; bind F2 "netevent ca829_combo -1"; bind F3 "netevent ca829_combo 2"; bind F4 "netevent ca829_nextview"; bind F5 "netevent ca829_nextpose"; bind F6 "netevent ca829_animate"; bind F7 "netevent ca829_freeze";\n'
        commands=commands.rstrip()+' bind F8 "netevent ca829_nextregion 0"; bind F9 "netevent ca829_nextregion 1"; bind F10 "netevent ca829_nextregion 2"; bind F11 "netevent ca829_nextregion 3";\n'
        commands=commands.rstrip()+' bind F12 "netevent ca829_nextdetail";\n'
        runs=[('interactive',commands,['+map','CA455V'])]
        print('F1 outfit / F2 uncovered / F3 casual / F4 rotate / F5 pose / F6 walk / F7 freeze; F8 body / F9 hat / F10 gloves / F11 shoes (cycle includes removal); F12 whole/head/hands/feet detail. Candidate art only.',flush=True)
    report={'issue':829,'runtime_sha256':digest(runtime),'model_sha256':digest(model/'preview.pk3') if model else None,'preview_only':bool(manifest.get('preview_only')),'fixture_sha256':digest(fixture),'engine_sha256':digest(ENGINE),'quick':args.quick,'runs':[]}
    for label,commands,entry in runs:
        write_console_chain(out,label,commands)
        command=[str(ENGINE),'-noautoload','-iwad',str(IWAD),'-file',str(runtime),*([str(model/'preview.pk3')] if model else []),str(fixture),'-config',str(out/'session.ini'),'-savedir',str(out),'-window','+logfile',str(out/(label+'.log')),*entry,'+exec',str(out/(label+'.cfg'))]
        if args.interactive:subprocess.run(command,cwd=out,check=True);return
        command.insert(2,'-nomouse');startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
        with (out/(label+'-process.log')).open('wb') as stream:
            process=subprocess.Popen(command,cwd=out,stdout=stream,stderr=stream,startupinfo=startup);deadline=time.monotonic()+600
            while process.poll() is None and time.monotonic()<deadline:
                path=out/(label+'.log');log=path.read_text(errors='replace') if path.exists() else ''
                if any(token in log for token in ['Script error','Execution could not continue','VM execution aborted']):break
                time.sleep(.2)
            if process.poll() is None:process.terminate()
            code=process.wait(timeout=10)
        path=out/(label+'.log');log=path.read_text(errors='replace') if path.exists() else ''
        errors=[line for line in log.splitlines() if any(token in line for token in ['Script error','Execution could not continue','VM execution aborted','Unknown command','Unable to load model','CA829 FAIL'])]
        count=sum(line.startswith('CA829 PASS') for line in log.splitlines());expected=5 if label=='reload' else len(cases)+len(poses)+independent+details+6
        result={'phase':label,'exit_code':code,'assertions':count,'expected_assertions':expected,'errors':errors,'passed':code==0 and not errors and count==expected and 'CA829 COMPLETE failures=0' in log}
        report['runs'].append(result);report['captures']={p.name:digest(p) for p in sorted(out.glob('*.png'))}
        (out/'RESULTS.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(result),flush=True)
        if not result['passed']:raise SystemExit(1)
    report['saved_visibility_pixel_match']=report['captures']['saved.png']==report['captures']['reloaded.png']
    (out/'RESULTS.json').write_text(json.dumps(report,indent=2)+'\n')
    assert report['saved_visibility_pixel_match'],'Saved wardrobe visibility differs after reload.'
    assert all(name in report['captures'] for name in captures)


if __name__=='__main__':main()
