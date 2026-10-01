"""Prepare focused outer-ground view coverage from the generated partition."""
from pathlib import Path
import json
ROOT=next(p for p in Path(__file__).resolve().parents if (p/'build_dev.ps1').is_file())
report=json.loads((ROOT/'assets/map01_mansion/EXTERIOR_GENERATED.json').read_text())
qa=ROOT/'build/issue61_qa'
code=[]
destination=ROOT/'build/issue61_bounds';destination.mkdir(exist_ok=True)
for i,cell in enumerate(report['exterior_partition']['cells']):
    commands=['wait 100','vid_fps 1','con_notifytime 0'] if i==0 else []
    if cell['sector']==0:x,y=3840,0
    else:a,b,c,d=cell['bounds'];x,y=(a+c)/2,(b+d)/2
    code += [f'class Issue61Bound{i} : Issue61FarGround','{',f'    override bool Use(bool pickup) {{ Super.Use(pickup);Owner.SetOrigin(({x},{y},0),false);Owner.Angle=45;Owner.Pitch=30;Console.Printf("QA61_BOUND {i} sector=%d floor=%.1f",Owner.CurSector.Index(),Owner.CurSector.floorplane.ZatPoint(Owner.Pos.XY));return true; }}','}']
    commands += [f'give Issue61Bound{i}','wait 105',f'screenshot build/issue61_bound_{i}.png','wait 20']
    commands += [f'exec build/issue61_bounds/sequence_{i+1}.cfg'] if i<8 else ['echo QA61_BOUNDS_DONE','quit']
    command='; '.join(commands)+'\n';assert len(command)<1024
    (destination/f'sequence_{i}.cfg').write_text(command,encoding='utf-8')
(qa/'Bounds.zs').write_text('\n'.join(code)+'\n',encoding='utf-8')
source=(qa/'ZSCRIPT').read_text(encoding='utf-8')
if '#include "Bounds.zs"' not in source:source+='\n#include "Bounds.zs"\n'
(qa/'ZSCRIPT').write_text(source,encoding='utf-8')
# Chained single-line configs preserve native wait ordering across all views.
(ROOT/'build/issue61_bound_views.cfg').write_text('exec build/issue61_bounds/sequence_0.cfg\n',encoding='utf-8')
print('Prepared nine exterior view points.')
