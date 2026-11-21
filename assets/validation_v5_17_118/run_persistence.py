"""#879 native default-relative persistence and house-hub verification.

Uses the retained house-use class names and actual Used/rendered ACK travel.
The city setup and invulnerable portal placements are diagnostic. One hidden
unpaused engine at 5% audio; no ordinary traversal or multiplayer acceptance.
"""
from pathlib import Path
import argparse,hashlib,json,math,re,shutil,subprocess,time,zipfile
ROOT=Path(__file__).resolve().parents[2]
ENGINE=Path('C:/Program Files (x86)/GZDoom/gzdoom.exe')
IWAD=Path('C:/Program Files (x86)/Steam/steamapps/common/ultimate doom/base/doom2/DOOM2.WAD')
SHA=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
FATAL=['Script error','Execution could not continue','VM execution aborted','Unknown type','CA454 HOUSE FAIL','CA879 FAIL']

def roundtrip(index):
    return f'netevent ca454_house_in {index}; wait 140; netevent ca454_house_inside {index}; wait 140; netevent ca454_house_back {index}; wait 35; '

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ['old-runtime','new-runtime','output']:parser.add_argument('--'+name,type=Path,required=True)
    args=parser.parse_args();out=args.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
    old=args.old_runtime.resolve(strict=True);new=args.new_runtime.resolve(strict=True)
    assert 'gzdoom.exe' not in subprocess.check_output(['tasklist','/FI','IMAGENAME eq gzdoom.exe','/FO','CSV','/NH'],text=True,errors='replace').lower()
    model=ROOT/'src/models/caelum/architecture/barracas/house-960-1216.obj'
    vertices=[tuple(map(float,s.split()[1:])) for s in model.read_text().splitlines() if s.startswith('v ')]
    radius=math.ceil(max(math.hypot(p[0],p[2]) for p in vertices))
    layout=json.loads((ROOT/'assets/barracas_redesign/LAYOUT.json').read_text())
    expected={((b['bounds'][0]+b['bounds'][2])/2,(b['bounds'][1]+b['bounds'][3])/2):b['angle'] for b in layout['buildings'] if b['kind']=='house'}
    assert len(expected)==160
    source=(ROOT/'assets/validation_v5_16_2/barracas_house_use_probe.zs').read_text(encoding='utf-8')
    anchor='    override void NetworkProcess(ConsoleEvent e)\n    {'
    check='''    void CheckRadius(int expected)
    {
        // Consulta diagnostica acotada a las 160 fachadas al pedir cada muestra.
        let it=ThinkerIterator.Create("CA454Facade31800");Actor item;int count=0;bool ok=true;
        while((item=Actor(it.Next()))!=null)
        {
            count++;
            Console.Printf("CA879 FACADE x=%.6f y=%.6f z=%.6f angle=%.6f radius=%.6f render=%.6f height=%.6f",item.Pos.X,item.Pos.Y,item.Pos.Z,item.Angle,item.Radius,item.RenderRadius,item.Height);
            ok=ok && item.RenderRadius==expected;
        }
        Console.Printf("CA879 %s count=%d expected=%d",ok && count==CaelumCityData.HOUSE_COUNT?"PASS":"FAIL",count,expected);
    }
'''+anchor+'''
        if(e.Name=="ca879_radius"){CheckRadius(e.Args[0]);return;}
'''
    assert source.count(anchor)==1;source=source.replace(anchor,check)
    fixture=out/'house-use.pk3';(out/'probe.zs').write_text(source,encoding='utf-8',newline='\n')
    with zipfile.ZipFile(fixture,'x') as z:
        z.writestr(zipfile.ZipInfo('ZSCRIPT',(2026,11,21,0,0,0)),('version "4.14.2"\n'+source).encode())
        z.writestr(zipfile.ZipInfo('MAPINFO',(2026,11,21,0,0,0)),b'gameinfo { AddEventHandlers="CA454HouseUseProbe" }\ndoomednums {31050=CA454HouseUseCity}\n')
    phases=[
        ('old_fresh',old,None,0,2,1),
        ('upgrade',new,'old_fresh/checkpoint.zds',radius,8,4),
        ('new_reload',new,'upgrade/checkpoint.zds',radius,0,0),
        ('rollback',old,'new_reload/checkpoint.zds',0,2,1),
        ('reupgrade',new,'rollback/checkpoint.zds',radius,0,0),
        ('hub_upgrade',new,'old_fresh/storedhub.zds',radius,1,1),
        ('hub_reload',new,'hub_upgrade/checkpoint.zds',radius,0,0)]
    report=dict(issue=879,scope=__doc__,old_runtime_sha256=SHA(old),new_runtime_sha256=SHA(new),engine_sha256=SHA(ENGINE),fixture_sha256=SHA(fixture),derived_render_radius=radius,runs=[])
    for phase,runtime,load,expected_radius,uses,returns in phases:
        folder=out/phase;folder.mkdir();package=folder/'caelum_argenteum_dev.pk3';shutil.copyfile(runtime,package)
        config=folder/'isolated.ini';config.write_text('[GlobalSettings]\nvid_fullscreen=false\nvid_preferbackend=1\nvid_activeinbackground=true\ni_pauseinbackground=false\nvid_lowerinbackground=false\ni_soundinbackground=true\nsnd_mastervolume=0.05\nvid_maxfps=60\nlanguage=enu\n',encoding='utf-8')
        entry=['+map','MAP03']
        if load:
            shutil.copyfile(out/load,folder/'input.zds');entry=['-loadgame','input.zds']
        if phase=='old_fresh':
            commands='wait 140; netevent ca879_radius 0; save checkpoint; wait 10; netevent ca454_house_in 0; wait 140; save storedhub; wait 10; netevent ca454_house_inside 0; wait 140; netevent ca454_house_back 0; wait 35; netevent ca879_radius 0; '
        elif phase=='hub_upgrade':
            commands=f'wait 35; netevent ca454_house_inside 0; wait 140; netevent ca454_house_back 0; wait 35; netevent ca879_radius {radius}; save checkpoint; wait 10; '
        else:
            commands=f'wait 35; netevent ca879_radius {expected_radius}; save checkpoint; wait 10; '
            if phase=='upgrade':commands+=''.join(roundtrip(i) for i in range(4))
            if phase=='rollback':commands+=roundtrip(0)
        commands+='screenshot scene.png; wait 10; quit;\n'
        cfg=folder/'commands.cfg';cfg.write_text(commands,encoding='utf-8')
        command=[str(ENGINE),'-noautoload','-iwad',str(IWAD),'-file',str(package),str(fixture),'-config',str(config),'-savedir',str(folder),'-window','-width','960','-height','720','+logfile',str(folder/'engine.log'),*entry,'+exec',str(cfg)]
        startup=subprocess.STARTUPINFO();startup.dwFlags|=subprocess.STARTF_USESHOWWINDOW;startup.wShowWindow=0
        timeout=False
        with (folder/'process.log').open('wb') as stream:
            process=subprocess.Popen(command,cwd=folder,stdout=stream,stderr=stream,startupinfo=startup)
            deadline=time.monotonic()+240
            while process.poll() is None:
                log=(folder/'engine.log').read_text(encoding='utf-8',errors='replace') if (folder/'engine.log').exists() else ''
                if any(v in log for v in FATAL):break
                if time.monotonic()>deadline:timeout=True;break
                time.sleep(.25)
            if process.poll() is None:process.terminate();process.wait(timeout=10)
        log=(folder/'engine.log').read_text(encoding='utf-8',errors='replace')
        markers=[line for line in log.splitlines() if 'CA879 ' in line or 'CA454 HOUSE ' in line or any(v in line for v in FATAL)]
        matches=re.findall(r'CA879 FACADE x=([\d.-]+) y=([\d.-]+) z=([\d.-]+) angle=([\d.-]+) radius=([\d.-]+) render=([\d.-]+) height=([\d.-]+)',log)
        samples=2 if phase=='old_fresh' else 1;geometry_ok=len(matches)==len(expected)*samples
        observed=[]
        for offset in range(0,len(matches),len(expected)):
            rows=[list(map(float,row)) for row in matches[offset:offset+len(expected)]]
            positions={(x,y):angle for x,y,z,angle,collision,render,height in rows}
            geometry_ok=geometry_ok and positions==expected and all(z==0 and collision==20 and render==expected_radius and height==16 for x,y,z,angle,collision,render,height in rows)
            observed.append(dict(actors=len(rows),positions_angles_equal=positions==expected))
        passed=process.returncode==0 and not timeout and not any(v in log for v in FATAL) and geometry_ok
        passed=passed and log.count('CA454 HOUSE USE PASS')==uses and log.count('CA454 HOUSE RETURN PASS')==returns and (folder/'checkpoint.zds').is_file()
        row=dict(phase=phase,passed=passed,exit_code=process.returncode,timeout=timeout,load=load,runtime_sha256=SHA(runtime),expected_radius=expected_radius,facade_samples=observed,geometry_equal=geometry_ok,uses=uses,returns=returns,markers=markers,command=command)
        report['runs'].append(row);(out/'RESULTS.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
        print(json.dumps({k:row[k] for k in ['phase','passed','geometry_equal','facade_samples','uses','returns']}),flush=True)
        if not passed:raise SystemExit(1)
    report['passed']=True;(out/'RESULTS.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')

if __name__=='__main__':main()
