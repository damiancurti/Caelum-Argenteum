"""Exercise actual review-fixture item/rotation events without changing their logic."""
from pathlib import Path
import argparse,hashlib,json,re,subprocess,sys,time,zipfile

def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--workspace',type=Path,default=Path(__file__).resolve().parents[2])
    parser.add_argument('--runtime',type=Path,required=True)
    parser.add_argument('--output',type=Path,required=True)
    parser.add_argument('--sources',type=Path,required=True)
    parser.add_argument('--expect-broken',action='store_true')
    args=parser.parse_args();root=args.workspace.resolve(strict=True);runtime=args.runtime.resolve(strict=True)
    out=args.output.resolve();out.relative_to(root/'build');out.mkdir(parents=True,exist_ok=False)
    sources=json.loads(args.sources.read_text(encoding='utf-8'))
    existing=subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/FO','CSV','/NH']).decode(errors='replace')
    if '"gzdoom.exe"' in existing.lower():parser.error('Another native engine is running.')
    sys.path.insert(0,str(root/'assets/validation_v5_16_3'));from run_nahuelito_preview import wad
    engine=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
    iwad=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')
    assembled=[];handlers=[];input_hashes={};expected=[]
    commands='screenblocks 12; crosshair 0; con_notifytime 0; fov 30; wait 140; '
    for item in sources:
        family=item['family'];marker=item['marker'];path=root/item['fixture'];original=path.read_text(encoding='utf-8')
        input_hashes[item['fixture']]=digest(path)
        base=root/'assets/source/art/inventory_models_647'/family
        config=json.loads((base/'DESIGN.json').read_text());manifest=json.loads((base/'EXPORT.json').read_text());count=len(config['variants'])
        source=original.replace('ITEM_IDS',','.join(str(v['item_type']) for v in config['variants'].values()))
        bounds=[v['native_bounds'][0] for v in manifest['variants'].values()]
        source=source.replace('DETAIL_EXTENTS',','.join(str(max(b['max'][k]-b['min'][k] for k in range(3))) for b in bounds))
        source=source.replace('DETAIL_HEIGHTS',','.join(str((b['max'][2]+b['min'][2])/2) for b in bounds))
        needle='    override void NetworkProcess(ConsoleEvent e)\n    {';assert source.count(needle)==1
        observe='''
        if(e.Name=="ca745_FAMILY_assert")
        {
            bool okay=DetailIndex==e.Args[0] && DetailAngle==e.Args[1];
            if(DetailIndex<0 || DetailIndex>=Drops.Size())okay=false;
            else
            {
                let item=Drops[DetailIndex];bool raised=e.Args[1]==0;
                okay=okay && item.bNOGRAVITY==raised && players[0].camera==Camera;
                okay=okay && (raised?item.Pos.Z-item.floorz>63:abs(item.Pos.Z-item.floorz)<0.01);
            }
            Console.Printf("CA745 CHECK FAMILY expected=%d/%d observed=%d/%d result=%s",e.Args[0],e.Args[1],DetailIndex,DetailAngle,okay?"PASS":"FAIL");
        }
        if(e.Name=="ca745_FAMILY_done")for(int i=0;i<Drops.Size();i++)Drops[i].bInvisible=true;
'''.replace('FAMILY',family)
        source=source.replace(needle,needle+observe)
        # Only observation is injected; all original event-control statements remain exact.
        assert source.replace(observe,'')==original.replace('ITEM_IDS',','.join(str(v['item_type']) for v in config['variants'].values())).replace('DETAIL_EXTENTS',','.join(str(max(b['max'][k]-b['min'][k] for k in range(3))) for b in bounds)).replace('DETAIL_HEIGHTS',','.join(str((b['max'][2]+b['min'][2])/2) for b in bounds))
        assembled.append(source);handlers.append(item['handler'])
        (out/(family+'-original.zs')).write_bytes(path.read_bytes())
        (out/(family+'-observed.zs')).write_text(source,encoding='utf-8',newline='\n')
        commands+=f'netevent {marker}_prepare; wait 35; '
        for index in range(count):
            commands+=f'netevent {marker}_detail {(index-1)%count} 90; wait 3; netevent {marker}_next; wait 3; netevent ca745_{family}_assert {index} 90; '
            expected.append((family,index,90))
            for angle in [160,225,270,0,90]:
                commands+=f'netevent {marker}_rotate; wait 3; netevent ca745_{family}_assert {index} {angle}; '
                expected.append((family,index,angle))
                if angle==0:commands+=f'wait 10; screenshot {family}-{index}-underside.png; wait 3; '
        commands+=f'netevent ca745_{family}_done; wait 3; '
    commands+='wait 10; quit; '
    code='version "4.14.2"\n'+'\n'.join(assembled)
    mapinfo='gameinfo { AddEventHandlers='+','.join('"'+n+'"' for n in handlers)+' }\nmap CA455V "Review controls" { sky1="CABASKY",0 nointermission }\n'
    (out/'ZSCRIPT.txt').write_text(code,encoding='utf-8',newline='\n');(out/'MAPINFO.txt').write_text(mapinfo,encoding='utf-8',newline='\n')
    fixture=out/'fixture.pk3'
    with zipfile.ZipFile(fixture,'w') as package:
        for name,blob in [('ZSCRIPT',code.encode()),('MAPINFO',mapinfo.encode()),('maps/CA455V.wad',wad())]:package.writestr(name,blob)
    chunks=['']
    for command in commands.split(';'):
        if not command.strip():continue
        if len(chunks[-1])+len(command)>1400:chunks.append('')
        chunks[-1]+=command.strip()+'; '
    paths=[out/f'controls-{i}.cfg' for i in range(len(chunks))]
    for i,(path,chunk) in enumerate(zip(paths,chunks)):
        path.write_text(chunk+(f'exec "{paths[i+1].as_posix()}";' if i+1<len(paths) else '')+'\n')
    ini=out/'session.ini';ini.write_text('[GlobalSettings]\nvid_renderer=1\nvid_preferbackend=1\nvid_fullscreen=false\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\nlanguage=en\nvid_defwidth=1280\nvid_defheight=720\nwin_w=1296\nwin_h=759\n[LastRun]\nVersion=225\n')
    command=[str(engine),'-noautoload','-nomouse','-iwad',str(iwad),'-file',str(runtime),str(fixture),'-config',str(ini),'-savedir',str(out),'-window','-width','1280','-height','720','+logfile',str(out/'engine.log'),'+map','CA455V','+exec',str(paths[0])]
    startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
    with (out/'process.log').open('wb') as stream:
        process=subprocess.Popen(command,cwd=out,stdout=stream,stderr=stream,startupinfo=startup)
        deadline=time.monotonic()+150
        while process.poll() is None and time.monotonic()<deadline:
            log=(out/'engine.log').read_text(errors='replace') if (out/'engine.log').exists() else ''
            if any(t in log for t in ['Script error','Execution could not continue','VM execution aborted']):break
            time.sleep(.2)
        if process.poll() is None:process.terminate()
        status=process.wait(timeout=10)
    log=(out/'engine.log').read_text(errors='replace') if (out/'engine.log').exists() else ''
    checks=re.findall(r'CA745 CHECK (\w+) expected=(\d+)/(\d+) observed=(\d+)/(\d+) result=(PASS|FAIL)',log)
    assert [(f,int(i),int(a)) for f,i,a,_,_,_ in checks]==expected,'Missing, duplicate or misordered control probes'
    faults=[v for v in checks if v[-1]=='FAIL'];errors=[line for line in log.splitlines() if any(t in line for t in ['Script error','Execution could not continue','VM execution aborted']) or re.search(r'CA(?:731|733|741) FAIL',line)]
    expected_faults=len(expected)//3 if args.expect_broken else 0
    passed=status==0 and not errors and len(faults)==expected_faults
    report=dict(issue=745,passed=passed,expect_broken=args.expect_broken,checks=len(checks),expected_faults=expected_faults,observed_faults=faults,errors=errors,exit_code=status,runtime_sha256=digest(runtime),engine_sha256=digest(engine),fixture_sha256=digest(fixture),source_sha256=input_hashes,scope='Actual fixture F9/F10 event chains, item index, angle, camera and raised/grounded state. No production change or author acceptance.',author_accepted=False)
    (out/'RESULTS.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(json.dumps({k:report[k] for k in ['passed','checks','expected_faults','errors','exit_code']}));raise SystemExit(not passed)

if __name__=='__main__':main()
