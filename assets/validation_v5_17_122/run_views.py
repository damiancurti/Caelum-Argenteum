"""Compare private waterline masonry with unchanged native channel geometry.

Camera teleports, invulnerability/notarget and menu dismissal are diagnostic.
Targeted side checks run only on explicit camera events, not in production ticks.
"""
from pathlib import Path
import argparse, importlib.util, inspect, json, math, zipfile

ROOT = Path(__file__).resolve().parents[2]


def module(name, path):
    spec = importlib.util.spec_from_file_location(name, ROOT/path)
    result = importlib.util.module_from_spec(spec); spec.loader.exec_module(result)
    return result


def cameras(manifest):
    old = module('retained_waterline_cameras', 'assets/validation_v5_17_102/run_material_views.py')
    points = old.cameras()
    retained = json.loads((ROOT/'assets/validation_v5_17_116/cameras.json').read_text())
    points += [r for r in retained['rows'] if r['name'] == 'maintenance']
    cfg = json.loads((ROOT/'assets/map02_maze/LAYOUT.json').read_text())
    source = json.loads((ROOT/'assets/map02_maze/MAP02_MANIFEST.json').read_text())
    cells = {(r[0],r[1]):r[2:] for r in source['cells']}; grid = cfg['grid']
    anchor = next(r['point'] for r in points if r['name'] == 'channel')
    for axis, name in [(0,'waterline_horizontal'), (1,'waterline_vertical')]:
        possible = []
        for row in manifest['edits']:
            a,b = row['points']
            if a[1-axis] != b[1-axis]:
                continue
            midpoint = [(a[i]+b[i])/2 for i in range(2)]
            for direction in [-1,1]:
                point = midpoint.copy(); point[1-axis] += direction*cfg['channel_width']/2
                cell = cells.get(tuple(math.floor(v/grid)*grid for v in point))
                if cell is None or cell[0] != -cfg['channel_depth'] or not cell[4]:
                    continue
                # The camera is in the middle of the existing water channel.
                # Native player occupancy is checked again in the engine.
                possible.append((math.dist(midpoint,anchor), row['side'], dict(name=name, point=point,
                    angle=0, target=[*midpoint,(row['lower_floor']+row['upper_floor'])/2],
                    side=row['side'], basis='Existing changed riser, channel midpoint and native player eye height')))
        assert possible, name
        points.append(min(possible, key=lambda item:(item[0],item[1]))[2])
    return points


def surface_probe(manifest, allow_default=False):
    sector_count = manifest['geometry_counts']['sector']
    indices = ','.join(str(r['line']*sector_count+r['water_sector']) for r in manifest['edits'])
    center = ','.join(map(str, manifest['justice']['center']))
    default = manifest['default_map']
    accepted = f' || checksum=="{default["checksum"]}"' if allow_default else ''
    return f'''    void CheckSurfaces()
    {{
        String checksum=level.GetChecksum();
        bool candidate=checksum=="{manifest['candidate_checksum']}";
        bool original=checksum=="{default['checksum']}";
        bool okay=candidate || checksum=="{manifest['source_checksum']}"{accepted};
        int checked=0,bad=0;
        if(!original)
        {{
            static const int indices[]={{{indices}}};
            for(int i=0;i<indices.Size();i++)
            {{
                int encoded=indices[i];int waterIndex=encoded%{sector_count};int lineIndex=encoded/{sector_count};
                if(lineIndex>=level.Lines.Size()){{bad++;continue;}}
                let line=level.Lines[lineIndex];
                let side=line.sidedef[0];
                if(side==null || side.sector.sectornum!=waterIndex)side=line.sidedef[1];
                if(side==null || side.sector.sectornum!=waterIndex){{bad++;continue;}}
                checked++;
                String expected=candidate?"CA887WET":"CA875WAL";
                if(TexMan.GetName(side.GetTexture(Side.bottom))!=expected)bad++;
            }}
            let texture=TexMan.CheckForTexture(candidate?"CA887WET":"CA875WAL",TexMan.Type_Wall);
            let size=TexMan.GetScaledSize(texture);
            okay=okay && size.X=={manifest['texture']['display_repeat_mu']} && size.Y=={manifest['texture']['display_repeat_mu']};
            okay=okay && level.Lines.Size()=={manifest['geometry_counts']['linedef']};
        }}
        int arena=original?{default['justice_sector']}:{manifest['justice']['sector']};
        int sectors=original?{default['sectors']}:{manifest['geometry_counts']['sector']};
        okay=okay && bad==0 && checked==(original?0:{manifest['edited_sides']}) && level.Sectors.Size()==sectors;
        okay=okay && CaelumJusticeGeometry.Get()!=null && CaelumJusticeGeometry.SectorIndex(level.MapName)==arena;
        okay=okay && (CaelumJusticeGeometry.Center(level.MapName)-({center})).Length()<.001;
        Console.Printf("CA887 SURFACE %s candidate=%d default=%d sides=%d bad=%d arena=%d checksum=%s",okay?"PASS":"FAIL",candidate,original,checked,bad,arena,checksum);
    }}
'''


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ['runtime','control-overlay','overlay','manifest','output']:
        parser.add_argument('--'+name,type=Path,required=True)
    args = parser.parse_args(); out = args.output.resolve(); out.relative_to(ROOT/'build')
    out.mkdir(parents=True,exist_ok=False)
    manifest = json.loads(args.manifest.read_text(encoding='utf-8')); points = cameras(manifest)
    engine = module('retained_waterline_views','assets/validation_v5_17_111/run_material_views.py')
    base = engine.fixture(out,points,[],['CA875WAL'])
    with zipfile.ZipFile(base) as archive:
        source = archive.read('probe.zs').decode('utf-8')
    repeat = manifest['texture']['display_repeat_mu']
    source = source.replace('size.X!=128 || size.Y!=128',f'size.X!={repeat} || size.Y!={repeat}')
    anchor = '    void Place(int index)'; assert source.count(anchor)==1
    source = source.replace(anchor,surface_probe(manifest)+anchor)
    anchor = 'user.Angle=angle;user.Pitch=pitch;user.Vel=(0,0,0);'; assert source.count(anchor)==1
    aiming = []
    for i,row in enumerate(points):
        if 'target' not in row:
            continue
        target = ','.join(map(str,row['target']))
        aiming.append(f'if(index=={i}){{vector3 target=({target});user.Angle=VectorAngle(target.X-user.Pos.X,target.Y-user.Pos.Y);user.Pitch=VectorAngle((target.XY-user.Pos.XY).Length(),user.Pos.Z+user.ViewHeight-target.Z);}}')
    source = source.replace(anchor,anchor+'\n        '+'\n        '.join(aiming))
    anchor = 'if(user.CeilingZ-user.FloorZ<user.Height)Console.Printf("CA866 FAIL clearance");'; assert source.count(anchor)==1
    source = source.replace(anchor,anchor+'\n        if(!user.TestMobjLocation())Console.Printf("CA866 FAIL occupied camera %d",index);\n        CheckSurfaces();')
    run_source = inspect.getsource(engine.run)
    anchor = "*([str(overlay)] if label=='candidate' else [])"; assert run_source.count(anchor)==1
    run_source = run_source.replace(anchor,'str(overlay)')
    engine.FATAL = (*engine.FATAL,'CA887 SURFACE FAIL','Unexpected JIT error')
    exec(compile(run_source,str(ROOT/'assets/validation_v5_17_111/run_material_views.py'),'exec'),engine.__dict__)
    (out/'probe.zs').write_text(source,encoding='utf-8',newline='\n')
    probe = out/'waterline-views.pk3'
    with zipfile.ZipFile(probe,'x') as archive:
        for name,value in sorted({'ZSCRIPT':'version "4.14.2"\n#include "probe.zs"\n','MAPINFO':'gameinfo {AddEventHandlers="CA866Views"}\n','probe.zs':source}.items()):
            archive.writestr(zipfile.ZipInfo(name,(2026,11,21,0,0,0)),value.encode('utf-8'))
    runs = []
    for label,overlay in [('control',args.control_overlay),('candidate',args.overlay)]:
        row = engine.run(args.runtime.resolve(),overlay.resolve(),out,points,probe,label,'MAP02')
        log = (out/label/'engine.log').read_text(encoding='utf-8',errors='replace')
        row['surface_passes'] = log.count(f'CA887 SURFACE PASS candidate={int(label=="candidate")} default=0 ')
        row['passed'] = row['passed'] and row['surface_passes']==len(points)+1
        runs.append(row)
        (out/label/'RESULTS.json').write_text(json.dumps(row,indent=2)+'\n',encoding='utf-8',newline='\n')
        if not row['passed']:
            break
    report = dict(issue=887,map='MAP02',cameras=points,runs=runs,runtime_sha256=engine.SHA(args.runtime),
                  control_sha256=engine.SHA(args.control_overlay),candidate_sha256=engine.SHA(args.overlay),
                  fixture_sha256=engine.SHA(probe),passed=len(runs)==2 and all(r['passed'] for r in runs),
                  qualification=__doc__,author_acceptance=False)
    (out/'RESULTS.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
    raise SystemExit(not report['passed'])


if __name__=='__main__':
    main()
