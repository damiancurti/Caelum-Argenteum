"""Capture combined environmental options at existing authored scene anchors.

House views enter and return through actual Used/rendered capture/ACK travel.
Only that scene uses the retained diagnostic city setup without normal armies.
Camera teleports, invulnerability/notarget and automatic menu dismissal are
diagnostic. No facade class override, gameplay acceptance or full-route claim.
"""
from pathlib import Path
import argparse,importlib.util,inspect,json,zipfile
ROOT=Path(__file__).resolve().parents[2]

def module(name,path):
    spec=importlib.util.spec_from_file_location(name,ROOT/path)
    result=importlib.util.module_from_spec(spec);spec.loader.exec_module(result);return result

def main():
    p=argparse.ArgumentParser(description=__doc__)
    for n in ['runtime','overlay','inventory','output']:p.add_argument('--'+n,type=Path,required=True)
    p.add_argument('--scene',choices=['house','city','sewer','mansion'],required=True)
    a=p.parse_args();out=a.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
    engine=module('retained_environment_views','assets/validation_v5_17_111/run_material_views.py')
    data=json.loads(a.inventory.read_text(encoding='utf-8'))
    if a.scene=='house':map_name='CAH000';points=data['cameras'][map_name]
    elif a.scene=='city':map_name='MAP03';points=data['cameras'][map_name]
    elif a.scene=='mansion':map_name='MAP01';points=json.loads((ROOT/'assets/source/art/environment_remasters_866/VIEWS.json').read_text())['MAP01']
    else:
        sewer=module('retained_sewer_views','assets/validation_v5_17_102/run_material_views.py')
        map_name='MAP02';points=sewer.cameras()+json.loads((ROOT/'assets/validation_v5_17_116/cameras.json').read_text())['rows']
        layout=json.loads((ROOT/'assets/map02_maze/LAYOUT.json').read_text())
        points.append(dict(name='surface_service_exit',point=layout['boss']['return_start'],angle=90,basis='Existing extraction/return-service center before the keyed boss chamber'))
    material=json.loads((ROOT/'assets/source/art/environment_remasters_866/INVENTORY.json').read_text())
    base=engine.fixture(out,points,[Path(r['file']).stem for r in material['exports']],material['aliases'])
    with zipfile.ZipFile(base) as z:source=z.read('probe.zs').decode('utf-8')
    source=source.replace('if(user==null){Console.Printf("CA866 FAIL player");return;}',
                          f'if(user==null || level.MapName!="{map_name}"){{Console.Printf("CA866 FAIL map/player");return;}}')
    anchor='if(user.CeilingZ-user.FloorZ<user.Height)Console.Printf("CA866 FAIL clearance");'
    assert source.count(anchor)==1
    source=source.replace(anchor,anchor+'\n        if(!user.TestMobjLocation())Console.Printf("CA866 FAIL occupied camera %d",index);')
    house_source='';mapinfo='gameinfo { AddEventHandlers="CA866Views" }\n'
    run_source=inspect.getsource(engine.run)
    if a.scene=='house':
        house_source=(ROOT/'assets/validation_v5_16_2/barracas_house_use_probe.zs').read_text(encoding='utf-8')
        mapinfo='gameinfo { AddEventHandlers="CA866Views","CA454HouseUseProbe" }\ndoomednums {31050=CA454HouseUseCity}\n'
        anchor="commands = ['con_notifytime 0', 'wait 140']";assert run_source.count(anchor)==1
        run_source=run_source.replace(anchor,"commands = ['con_notifytime 0', 'wait 140', 'netevent ca454_house_in 0', 'wait 140']")
        anchor="cfg.write_text('; '.join(commands)+'\\n', encoding='utf-8')";assert run_source.count(anchor)==1
        run_source=run_source.replace(anchor,"commands[-1:-1] = ['netevent ca454_house_inside 0', 'wait 140', 'netevent ca454_house_back 0', 'save checkpoint', 'wait 10']\n    "+anchor)
        # The reusable runner starts the city and waits for real portal travel.
        # Saved input data and the camera guard still identify the private map.
        start_map='MAP03'
    else:start_map=map_name
    engine.FATAL=(*engine.FATAL,'CA454 HOUSE FAIL','CA454 HOUSE USE FAIL','CA454 HOUSE RETURN FAIL')
    exec(compile(run_source,str(ROOT/'assets/validation_v5_17_111/run_material_views.py'),'exec'),engine.__dict__)
    source+='\n'+house_source
    (out/'combined-probe.zs').write_text(source,encoding='utf-8',newline='\n')
    probe=out/'combined-views.pk3'
    with zipfile.ZipFile(probe,'x') as z:
        for name,value in sorted({'ZSCRIPT':'version "4.14.2"\n#include "probe.zs"\n','MAPINFO':mapinfo,'probe.zs':source}.items()):
            z.writestr(zipfile.ZipInfo(name,(2026,11,21,0,0,0)),value.encode())
    runs=[]
    for label in ['control','candidate']:
        row=engine.run(a.runtime.resolve(),a.overlay.resolve(),out,points,probe,label,start_map)
        if a.scene=='house':
            log=(out/label/'engine.log').read_text(encoding='utf-8',errors='replace')
            row['real_house_uses']=log.count('CA454 HOUSE USE PASS');row['exact_house_returns']=log.count('CA454 HOUSE RETURN PASS')
            row['passed']=row['passed'] and row['real_house_uses']==2 and row['exact_house_returns']==1 and (out/label/'checkpoint.zds').is_file()
        runs.append(row)
        (out/label/'RESULTS.json').write_text(json.dumps(row,indent=2)+'\n',encoding='utf-8',newline='\n')
        if not row['passed']:break
    report=dict(issue=881,scene=a.scene,map=map_name,runtime_sha256=engine.SHA(a.runtime),overlay_sha256=engine.SHA(a.overlay),
                engine_sha256=engine.SHA(engine.ENGINE),fixture_sha256=engine.SHA(probe),cameras=points,runs=runs,
                passed=len(runs)==2 and all(r['passed'] for r in runs),qualification=__doc__)
    (out/'RESULTS.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
    raise SystemExit(not report['passed'])
if __name__=='__main__':main()
