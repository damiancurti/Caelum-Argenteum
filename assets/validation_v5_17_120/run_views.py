"""Compare only ceiling assignments while retaining the same combined art.

House travel uses the retained diagnostic city setup and actual Used/render ACK.
Camera teleports/invulnerability/notarget/menu dismissal remain diagnostic.
"""
from pathlib import Path
import argparse, importlib.util, inspect, json, zipfile

ROOT = Path(__file__).resolve().parents[2]


def module(name, path):
    spec=importlib.util.spec_from_file_location(name, ROOT/path)
    result=importlib.util.module_from_spec(spec);spec.loader.exec_module(result);return result


def surface_probe(manifest, map_name):
    builder=module('ceiling_source_reader','assets/generators/build_interior_ceiling_review.py')
    row=next(r for r in manifest['maps'] if r['map']==map_name)
    blob=(ROOT/'src/maps'/(map_name+'.wad')).read_bytes()
    _, text=builder.textmap(blob);sectors=builder.blocks(text,'sector')
    changed={(r['sector'],r['field']):r for r in row['edits']}
    indices=range(len(sectors)) if map_name.startswith('CAH') else sorted({i for i,_ in changed})
    code=['    void CheckSurfaces() {',f'        String checksum=level.GetChecksum();bool candidate=checksum=="{row["candidate_checksum"]}";',
          f'        bool okay=candidate || checksum=="{row["source_checksum"]}";']
    for i in indices:
        fields=builder.fields(sectors[i]);code.append(f'        {{let s=level.Sectors[{i}];')
        for side in ['floor','ceiling']:
            field='texture'+side;old=fields[field]
            value=f'(candidate?"{changed[i,field]["after"]}":{old})' if (i,field) in changed else old
            code.append(f'        okay=okay && TexMan.GetName(s.GetTexture(Sector.{side}))=={value};')
            code.append(f'        okay=okay && s.{side}plane.ZatPoint((0,0))=={fields["height"+side]};')
        code.append('        }')
    code.append('        okay=okay && CaelumJusticeGeometry.Get()!=null;')
    if map_name=='MAP03':
        arena=manifest['justice_map03'];point=','.join(str(n) for n in arena['center'])
        code.append(f'        okay=okay && CaelumJusticeGeometry.SectorIndex(level.MapName)=={arena["sector"]} && (CaelumJusticeGeometry.Center(level.MapName)-({point})).Length()==0;')
    code += [f'        Console.Printf("CA883 SURFACE %s candidate=%d sectors=%d checksum=%s",okay?"PASS":"FAIL",candidate,{len(indices)},checksum);','    }']
    return '\n'.join(code)+'\n'


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    for name in ['runtime','control-overlay','overlay','manifest','output']:
        parser.add_argument('--'+name,type=Path,required=True)
    parser.add_argument('--scene',choices=['house','city'],required=True)
    args=parser.parse_args();out=args.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
    engine=module('retained_ceiling_views','assets/validation_v5_17_111/run_material_views.py')
    inventory=json.loads((ROOT/'assets/source/art/environment_review_881/INVENTORY.json').read_text())
    manifest=json.loads(args.manifest.read_text(encoding='utf-8'))
    map_name='CAH000' if args.scene=='house' else 'MAP03'
    points=inventory['cameras'][map_name]
    if args.scene=='city':
        points=[r for r in points if r['name'].startswith('municipality_')]
        # The retained low sky ends at the roof height; it is not a walkable
        # rooftop camera. Preserve that accepted geometry and inspect its cap
        # through the source-byte audit and native control-sector assertion.
    material=json.loads((ROOT/'assets/source/art/environment_remasters_866/INVENTORY.json').read_text())
    base=engine.fixture(out,points,[Path(r['file']).stem for r in material['exports']],material['aliases'])
    with zipfile.ZipFile(base) as archive:source=archive.read('probe.zs').decode('utf-8')
    for i,point in enumerate(points):
        if 'z' in point:
            old=f'case {i}: point=({point["point"][0]},{point["point"][1]},0);'
            new=old.replace(',0);',f',{point["z"]});');assert source.count(old)==1;source=source.replace(old,new)
    source=source.replace('if(user==null){Console.Printf("CA866 FAIL player");return;}',f'if(user==null || level.MapName!="{map_name}"){{Console.Printf("CA866 FAIL map/player");return;}}')
    anchor='    void Place(int index)';assert source.count(anchor)==1
    source=source.replace(anchor,surface_probe(manifest,map_name)+anchor)
    anchor='if(user.CeilingZ-user.FloorZ<user.Height)Console.Printf("CA866 FAIL clearance");';assert source.count(anchor)==1
    source=source.replace(anchor,anchor+'\n        if(!user.TestMobjLocation())Console.Printf("CA866 FAIL occupied camera %d",index);\n        CheckSurfaces();')
    run_source=inspect.getsource(engine.run)
    old="*([str(overlay)] if label=='candidate' else [])";assert run_source.count(old)==1
    run_source=run_source.replace(old,'str(overlay)')
    mapinfo='gameinfo { AddEventHandlers="CA866Views" }\n';start_map=map_name
    if args.scene=='house':
        source+='\n'+(ROOT/'assets/validation_v5_16_2/barracas_house_use_probe.zs').read_text(encoding='utf-8')
        mapinfo='gameinfo { AddEventHandlers="CA866Views","CA454HouseUseProbe" }\ndoomednums {31050=CA454HouseUseCity}\n'
        old="commands = ['con_notifytime 0', 'wait 140']";assert run_source.count(old)==1
        run_source=run_source.replace(old,"commands = ['con_notifytime 0', 'wait 140', 'netevent ca454_house_in 0', 'wait 140']")
        old="cfg.write_text('; '.join(commands)+'\\n', encoding='utf-8')";assert run_source.count(old)==1
        run_source=run_source.replace(old,"commands[-1:-1] = ['netevent ca454_house_inside 0', 'wait 140', 'netevent ca454_house_back 0', 'save checkpoint', 'wait 10']\n    "+old)
        start_map='MAP03'
    engine.FATAL=(*engine.FATAL,'CA883 SURFACE FAIL','CA454 HOUSE FAIL','CA454 HOUSE USE FAIL','CA454 HOUSE RETURN FAIL')
    exec(compile(run_source,str(ROOT/'assets/validation_v5_17_111/run_material_views.py'),'exec'),engine.__dict__)
    (out/'probe.zs').write_text(source,encoding='utf-8',newline='\n')
    probe=out/'ceiling-views.pk3'
    with zipfile.ZipFile(probe,'x') as archive:
        for name,value in sorted({'ZSCRIPT':'version "4.14.2"\n#include "probe.zs"\n','MAPINFO':mapinfo,'probe.zs':source}.items()):
            archive.writestr(zipfile.ZipInfo(name,(2026,11,21,0,0,0)),value.encode('utf-8'))
    runs=[]
    for label,overlay in [('control',args.control_overlay),('candidate',args.overlay)]:
        row=engine.run(args.runtime.resolve(),overlay.resolve(),out,points,probe,label,start_map)
        log=(out/label/'engine.log').read_text(encoding='utf-8',errors='replace')
        row['surface_passes']=log.count(f'CA883 SURFACE PASS candidate={int(label=="candidate")} ')
        row['passed']=row['passed'] and row['surface_passes']==len(points)+1
        if args.scene=='house':
            row['real_house_uses']=log.count('CA454 HOUSE USE PASS');row['exact_house_returns']=log.count('CA454 HOUSE RETURN PASS')
            row['passed']=row['passed'] and row['real_house_uses']==2 and row['exact_house_returns']==1 and (out/label/'checkpoint.zds').is_file()
        runs.append(row);(out/label/'RESULTS.json').write_text(json.dumps(row,indent=2)+'\n',encoding='utf-8',newline='\n')
        if not row['passed']:break
    report=dict(issue=883,scene=args.scene,map=map_name,cameras=points,runtime_sha256=engine.SHA(args.runtime),
                control_overlay_sha256=engine.SHA(args.control_overlay),overlay_sha256=engine.SHA(args.overlay),
                engine_sha256=engine.SHA(engine.ENGINE),fixture_sha256=engine.SHA(probe),runs=runs,
                passed=len(runs)==2 and all(r['passed'] for r in runs),qualification=__doc__)
    (out/'RESULTS.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
    raise SystemExit(not report['passed'])


if __name__=='__main__':main()
