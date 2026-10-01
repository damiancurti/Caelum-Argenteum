"""Prepare native control-isolation and retained-surface regression evidence."""
import json,math,shutil
from pathlib import Path
ROOT=next(p for p in Path(__file__).resolve().parents if (p/'build_dev.ps1').is_file())
spec=json.loads((ROOT/'assets/map01_mansion/CONTROL_RELOCATION.json').read_text())
report=json.loads((ROOT/'assets/map01_mansion/EXTERIOR_GENERATED.json').read_text())
qa=ROOT/'build/issue61_boundary_qa';qa.mkdir(exist_ok=True)
for name in ('ZSCRIPT','MAPINFO','Checks.zs','DoorChecks.zs','Tour.zs','Followup.zs','Bounds.zs'):
    shutil.copyfile(ROOT/'assets/validation_4370/followup/native'/name,qa/name)
p=qa/'Checks.zs';p.write_text(p.read_text().replace('i<level.Lines.Size()',f'i<{report["cave"]["before"]["linedef"]}'),encoding='utf-8')
x,y,z=spec['reported_position'];pitch,angle,_=spec['reported_angles']
code=[f'''class Issue61BoundaryView : Issue61View {{ override bool Use(bool pickup) {{
Super.Use(pickup);Owner.SetOrigin(({x},{y},{z}),false);Owner.Angle={angle};Owner.Pitch={pitch};
Console.Printf("QA61_BOUNDARY_SITE sector=%d",Owner.CurSector.Index());return true; }} }}''',
'''class Issue61SurfaceSnapshot : CaelumSocialDebugAction { override bool Use(bool pickup) {
let p=Spawn("Issue61Body");p.bSolid=false;FLineTraceData hit;int count=0;
for(int x=-1536;x<=2048;x+=256)for(int y=-768;y<=768;y+=256)
for(int z=-256;z<=640;z+=128) {
bool found=p.LineTrace(0,1024,90,TRF_THRUACTORS|TRF_ABSPOSITION,z,x,y,hit);
Console.Printf("QA61_SURFACE x=%d y=%d z=%d hit=%d height=%.4f",x,y,z,found,found?hit.HitLocation.Z:0);count++;
}
p.Destroy();Console.Printf("QA61_SURFACE_DONE samples=%d",count);return true; } }''',
'''class Issue61BoundaryChecks : CaelumSocialDebugAction { override bool Use(bool pickup) {
int failed=0,samples=0,moves=0;let p=Spawn("Issue61Body");p.bThruActors=true;
''']
a,b,c,d,step=spec['native_scan']
code += [f'''for(int x={a};x<={c};x+={step})for(int y={b};y<={d};y+={step}) {{
let s=level.PointInSector((x,y));double floor=s.floorplane.ZatPoint((x,y));
bool ok=s.Index()=={report['cave']['outer_sector']} && abs(floor)<0.01 && s.ceilingplane.ZatPoint((x,y))>1000;
samples++;if(!ok){{failed++;if(failed<=4)Console.Printf("QA61_BOUNDARY_BAD_POINT %d %d sector=%d",x,y,s.Index());}}
for(int axis=0;axis<2;axis++)for(int direction=-1;direction<=1;direction+=2) {{
p.SetOrigin((x,y,0),false);vector2 target=(x+(axis==0?24*direction:0),y+(axis==1?24*direction:0));moves++;
if(!p.TryMove(target,true))failed++;
}}
}}
Console.Printf("QA61_BOUNDARY_GRID %s samples=%d moves=%d failures=%d",failed==0?"PASS":"FAIL",samples,moves,failed);
failed=0;''']
centers=0
for item in report['control_relocations']:
    a,b,c,d=item['old_bounds'];cx=(a+c)/2;cy=(b+d)/2
    if not -30000<cx<30000 or not -30000<cy<30000:continue
    centers+=1
    code.append(f'if(level.PointInSector(({cx},{cy})).Index()!={report["cave"]["outer_sector"]})failed++;')
code += [f'Console.Printf("QA61_OLD_CONTROLS %s count={centers} failures=%d",failed==0?"PASS":"FAIL",failed);p.Destroy();return true; }} }}']
route=[spec['reported_position'],[26300,29408,0],[27600,29500,0],[28900,29500,0],[spec['reported_position'][0],spec['reported_position'][1],0]]
point='vector3 Point(int i){switch(i){'+''.join(f'case {i}:return ({x},{y},{z});' for i,(x,y,z) in enumerate(route))+'}return (0,0,0);}'
code += ['class Issue61BoundaryWalker : Actor {int waypoint;int ticks;',point,
'''override void Tick(){Super.Tick();if(target==null){Destroy();return;}ticks++;
if(ticks>1500){Console.Printf("QA61_BOUNDARY_PLAYER FAIL timeout waypoint=%d",waypoint);target.Vel=(0,0,0);Destroy();return;}
vector3 destination=Point(waypoint);vector2 delta=destination.XY-target.Pos.XY;
if(delta.Length()<8){Console.Printf("QA61_BOUNDARY_PLAYER_POINT %d z=%.2f",waypoint,target.Pos.Z);waypoint++;
''',f'''if(waypoint=={len(route)}){{Console.Printf("QA61_BOUNDARY_PLAYER %s ticks=%d noclip=%d nogravity=%d",!target.bNoClip && !target.bNoGravity && abs(target.Pos.Z)<0.01?"PASS":"FAIL",ticks,target.bNoClip,target.bNoGravity);target.Vel=(0,0,0);Destroy();return;}}destination=Point(waypoint);delta=destination.XY-target.Pos.XY;}}''',
'''target.Vel.X=delta.X/delta.Length()*6;target.Vel.Y=delta.Y/delta.Length()*6;target.Angle=delta.Angle();target.Pitch=8;}
Default {+NOINTERACTION} States {Spawn:TNT1 A -1;Stop;} }
class Issue61BoundaryWalk : Issue61BoundaryView {override bool Use(bool pickup){Super.Use(pickup);Owner.bNoClip=false;Owner.bNoGravity=false;Owner.Vel=(0,0,0);let w=Issue61BoundaryWalker(Spawn("Issue61BoundaryWalker"));w.target=Owner;return true;}}''']
views=[('author',spec['reported_position'],angle,pitch),('old_control',[26024,29384,0],90,15),('strip',[27400,29500,0],0,20),('corner',[29500,29600,0],225,15),('south',[27500,28800,0],90,15)]
seq=ROOT/'build/issue61_boundary_views';seq.mkdir(exist_ok=True)
for i,(name,(x,y,z),yaw,pitch) in enumerate(views):
    cname=f'Issue61BoundaryV{i}';code.append(f'class {cname} : Issue61View {{override bool Use(bool pickup){{Super.Use(pickup);Owner.SetOrigin(({x},{y},{z}),false);Owner.Angle={yaw};Owner.Pitch={pitch};Console.Printf("QA61_BOUNDARY_VIEW {name} sector=%d",Owner.CurSector.Index());return true;}}}}')
    nextcmd=f'exec build/issue61_boundary_views/{i+1}.cfg' if i+1<len(views) else 'echo QA61_BOUNDARY_VIEWS_DONE; quit'
    (seq/f'{i}.cfg').write_text(f'give {cname};use {cname};wait 140;screenshot build/issue61_boundary_{name}.png;wait 15;{nextcmd}\n')
(qa/'Boundary.zs').write_text('\n'.join(code)+'\n',encoding='utf-8')
with (qa/'ZSCRIPT').open('a',encoding='utf-8') as out:out.write('\n#include "Boundary.zs"\n')
print('Prepared boundary grid, surface snapshot, original door regressions and physical walk.')
