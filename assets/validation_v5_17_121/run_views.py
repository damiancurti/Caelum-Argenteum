"""Compare the fixed municipal furnishing proposal with its inherited art control.

Camera teleports and bounded local actor checks are diagnostic only. The normal
city setup and retained vendor remain active; no new service is exercised.
"""
from pathlib import Path
import argparse,importlib.util,inspect,json,math,zipfile

ROOT=Path(__file__).resolve().parents[2]
def module(name,path):
    spec=importlib.util.spec_from_file_location(name,ROOT/path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m

def cameras(manifest):
    inventory=json.loads((ROOT/'assets/source/art/environment_review_881/INVENTORY.json').read_text())
    points=[p for p in inventory['cameras']['MAP03'] if p['name'].startswith('municipality_')]
    layout=json.loads((ROOT/'assets/barracas_redesign/LAYOUT.json').read_text());grid=layout['grid']
    for bay in manifest['office_bays']:
        chair=next(p for p in manifest['positions'] if p['zone']==bay['name'] and p['kind']=='chair')
        points.append(dict(name=bay['name'],point=[chair['point'][0],chair['point'][1]-grid*2],angle=(chair['angle']+180)%360,
                           basis='Existing owned workstation, viewed from the retained grid circulation gap'))
    shelves=[p for p in manifest['positions'] if p['zone']=='archive'];middle=shelves[len(shelves)//2]
    door=json.loads((ROOT/'assets/map06_port/CITY.json').read_text())['profiles']['shop']['door_width']
    for name,distance in [('archive',door),('archive_detail',door/2)]:
        points.append(dict(name=name,point=[middle['point'][0]+distance,middle['point'][1]],angle=middle['angle'],basis='Owned archive shelf row and retained shop doorway width'))
    return points

def scene_probe(manifest,allow_default=False):
    a,b,c,d=manifest['civic']['bounds'];radius=math.ceil(math.hypot(c-a,d-b))
    runtime=json.loads((ROOT/'assets/barracas_redesign/RUNTIME.json').read_text())
    vendor=next(r for r in runtime['shops'] if r['building_id']==manifest['civic']['id']);x,y,z=vendor['vendor']
    matches=[]
    for p in manifest['positions']:
        dim=manifest['dimensions'][p['kind']];point=','.join(f'{v:.9f}' for v in p['point'])
        matches.append(f'(kind==\'{dim["class"]}\' && (body.Pos-({point})).Length()<.01 && Abs(body.Radius-{dim["radius"]:.9f})<.01 && Abs(body.Height-{dim["height"]:.9f})<.01)')
    default_check=f' || level.GetChecksum()=="{manifest["default_checksum"]}"' if allow_default else ''
    return f'''    bool Matches(Actor body)
    {{Name kind=body.GetClassName();return {' || '.join(matches)};}}
    void CheckScene()
    {{
        let user=players[0].mo;bool candidate=level.GetChecksum()=="{manifest['candidate_checksum']}";
        bool okay=candidate || level.GetChecksum()=="{manifest['source_checksum']}"{default_check};
        int count=0,bad=0;Array<Actor> seen;
        let nearby=BlockThingsIterator.Create(user,{radius});
        while(nearby.Next())
        {{
            let body=nearby.thing;Name kind=body.GetClassName();
            if(kind!='CA886SceneDesk' && kind!='CA886SceneChair' && kind!='CA886SceneShelf')continue;
            bool duplicate=false;for(int i=0;i<seen.Size();i++)if(seen[i]==body)duplicate=true;
            if(duplicate)continue;seen.Push(body);count++;
            if(!Matches(body) || !body.TestMobjLocation() || !body.bSOLID || body.bUSESPECIAL
               || body is 'CaelumReadingDesk' || body is 'CaelumReadingShelf' || body is 'CaelumRestFurniture' || body is 'Inventory')bad++;
        }}
        let vendor=CaelumDomesticMarket.Find({vendor['identity']});
        bool service=vendor!=null && vendor.ShopIdentity=={vendor['identity']} && (vendor.Pos-({x},{y},{z})).Length()<.01;
        okay=okay && count==(candidate?{len(manifest['positions'])}:0) && bad==0 && service;
        okay=okay && level.Sectors.Size()=={manifest['geometry_counts']['sector']} && CaelumJusticeGeometry.Get()!=null;
        Console.Printf("CA886 SCENE %s candidate=%d props=%d invalid=%d vendor=%d",okay?"PASS":"FAIL",candidate,count,bad,service);
    }}
'''

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ['runtime','control-overlay','overlay','manifest','output']:parser.add_argument('--'+name,type=Path,required=True)
    args=parser.parse_args();out=args.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
    manifest=json.loads(args.manifest.read_text());points=cameras(manifest)
    engine=module('retained_municipal_views','assets/validation_v5_17_111/run_material_views.py')
    materials=json.loads((ROOT/'assets/source/art/environment_remasters_866/INVENTORY.json').read_text())
    base=engine.fixture(out,points,[Path(r['file']).stem for r in materials['exports']],materials['aliases'])
    with zipfile.ZipFile(base) as z:source=z.read('probe.zs').decode()
    anchor='    void Place(int index)';assert source.count(anchor)==1;source=source.replace(anchor,scene_probe(manifest)+anchor)
    anchor='if(user.CeilingZ-user.FloorZ<user.Height)Console.Printf("CA866 FAIL clearance");';assert source.count(anchor)==1
    source=source.replace(anchor,anchor+'\n        if(!user.TestMobjLocation())Console.Printf("CA866 FAIL occupied camera");\n        CheckScene();')
    run_source=inspect.getsource(engine.run);old="*([str(overlay)] if label=='candidate' else [])";assert run_source.count(old)==1
    run_source=run_source.replace(old,'str(overlay)');engine.FATAL=(*engine.FATAL,'CA886 SCENE FAIL','Unexpected JIT error')
    exec(compile(run_source,str(ROOT/'assets/validation_v5_17_111/run_material_views.py'),'exec'),engine.__dict__)
    (out/'probe.zs').write_text(source,encoding='utf-8',newline='\n');probe=out/'municipal-views.pk3'
    with zipfile.ZipFile(probe,'x') as z:
        for name,value in sorted({'ZSCRIPT':'version "4.14.2"\n#include "probe.zs"\n','MAPINFO':'gameinfo {AddEventHandlers="CA866Views"}\n','probe.zs':source}.items()):
            z.writestr(zipfile.ZipInfo(name,(2026,11,21,0,0,0)),value.encode())
    runs=[]
    for label,overlay in [('control',args.control_overlay),('candidate',args.overlay)]:
        row=engine.run(args.runtime.resolve(),overlay.resolve(),out,points,probe,label,'MAP03')
        log=(out/label/'engine.log').read_text(encoding='utf-8',errors='replace')
        row['scene_passes']=log.count(f'CA886 SCENE PASS candidate={int(label=="candidate")} ')
        row['passed']=row['passed'] and row['scene_passes']==len(points)+1
        runs.append(row);(out/label/'RESULTS.json').write_text(json.dumps(row,indent=2)+'\n',encoding='utf-8',newline='\n')
        if not row['passed']:break
    report=dict(issue=886,cameras=points,runtime_sha256=engine.SHA(args.runtime),control_sha256=engine.SHA(args.control_overlay),
                candidate_sha256=engine.SHA(args.overlay),fixture_sha256=engine.SHA(probe),runs=runs,
                passed=len(runs)==2 and all(r['passed'] for r in runs),qualification=__doc__,author_acceptance=False)
    (out/'RESULTS.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
    raise SystemExit(not report['passed'])

if __name__=='__main__':main()
