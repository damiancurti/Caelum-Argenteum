"""Compare original and fixed production facade classes, plus optional joinery.

Reuses the retained #878 cameras/probe without its diagnostic class replacement.
The actual production class supplies RenderRadius in each runtime. Camera
teleports, invulnerability/notarget and menu dismissal remain diagnostic.
"""
from pathlib import Path
import argparse,importlib.util,inspect,json,zipfile
ROOT=Path(__file__).resolve().parents[2]
p=argparse.ArgumentParser(description=__doc__)
for name in ['old-runtime','new-runtime','joinery','output']:p.add_argument('--'+name,type=Path,required=True)
a=p.parse_args();out=a.output.resolve();out.relative_to(ROOT/'build');out.mkdir(parents=True,exist_ok=False)
previous=ROOT/'assets/validation_v5_17_111/run_material_views.py'
spec=importlib.util.spec_from_file_location('retained_facade_views',previous);module=importlib.util.module_from_spec(spec);spec.loader.exec_module(module)
# Keep the retained hidden/unpaused native launch unchanged; allow descriptive
# labels with an optional overlay so both actual runtimes can be tested directly.
run_source=inspect.getsource(module.run)
old="*([str(overlay)] if label=='candidate' else [])"
assert run_source.count(old)==1
exec(compile(run_source.replace(old,'*([str(overlay)] if overlay else [])'),str(previous),'exec'),module.__dict__)
evidence=ROOT/'assets/validation_v5_17_117/evidence/views'
retained=json.loads((evidence/'RESULTS.json').read_text());points=retained['cameras']
source=(evidence/'probe.zs').read_text(encoding='utf-8')
old='nearest.FloorZ,nearest.Angle,best);'
assert source.count(old)==1
assert source.count('angle=%.3f distance=%.3f",index,count')==1
source=source.replace('angle=%.3f distance=%.3f",index,count','angle=%.3f distance=%.3f render=%.3f",index,count')
source=source.replace(old,'nearest.FloorZ,nearest.Angle,best,nearest.RenderRadius);')
(out/'probe.zs').write_text(source,encoding='utf-8',newline='\n')
probe=out/'facade-views.pk3'
with zipfile.ZipFile(probe,'x') as z:
    members={'ZSCRIPT':b'version "4.14.2"\n#include "probe.zs"\n',
             'MAPINFO':b'gameinfo { AddEventHandlers="CA866Views" }\n','probe.zs':source.encode()}
    for name,data in sorted(members.items()):z.writestr(zipfile.ZipInfo(name,(2026,11,21,0,0,0)),data)
results=[]
for label,runtime,overlay in [('control',a.old_runtime,None),('fixed',a.new_runtime,None),('joinery',a.new_runtime,a.joinery)]:
    row=module.run(runtime.resolve(),overlay.resolve() if overlay else None,out,points,probe,label,'MAP03')
    expected=0 if label=='control' else 781
    diagnostics=[s for s in row['markers'] if ' FACADE ' in s]
    row['native_render_radius_equal']=len(diagnostics)==10 and all(s.endswith(f'render={expected:.3f}') for s in diagnostics)
    row['passed']=row['passed'] and row['native_render_radius_equal']
    (out/label/'RESULTS.json').write_text(json.dumps(row,indent=2)+'\n',encoding='utf-8',newline='\n')
    results.append(row)
    if not row['passed']:break
report=dict(issue=879,old_runtime_sha256=module.SHA(a.old_runtime),new_runtime_sha256=module.SHA(a.new_runtime),joinery_sha256=module.SHA(a.joinery),fixture_sha256=module.SHA(probe),engine_sha256=module.SHA(module.ENGINE),cameras=points,production_classes=True,diagnostic_class_override=False,runs=results,passed=len(results)==3 and all(r['passed'] for r in results),qualification=__doc__)
(out/'RESULTS.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8',newline='\n')
raise SystemExit(not report['passed'])
