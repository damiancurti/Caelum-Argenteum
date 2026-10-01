"""Prepare repeatable native cave cameras and distant-floor checks."""
import json,math,shutil
from pathlib import Path
ROOT=next(p for p in Path(__file__).resolve().parents if (p/'build_dev.ps1').is_file())
report=json.loads((ROOT/'assets/map01_mansion/EXTERIOR_GENERATED.json').read_text())
spec=json.loads((ROOT/'assets/map01_mansion/CAVE.json').read_text())
fixture=ROOT/'build/issue61_cave_qa'
fixture.mkdir(exist_ok=True)
for name in ('ZSCRIPT','MAPINFO','Checks.zs','DoorChecks.zs','Tour.zs','Followup.zs','Bounds.zs'):
    shutil.copy2(ROOT/'assets/validation_4370/followup/native'/name,fixture/name)
p=fixture/'Checks.zs';text=p.read_text();text=text.replace('i<level.Lines.Size()',f'i<{report["cave"]["before"]["linedef"]}');p.write_text(text,encoding='utf-8')
views=report['cave']['views']
views.append(dict(name='saved_site',world=spec['reported_position'],yaw=spec['reported_angles'][1],pitch=spec['reported_angles'][0]))
views.append(dict(name='previous_ground',world=[17455,7394,0],yaw=180,pitch=35))
for i,(x,y) in enumerate([(x,y) for x in (-29000,0,29000) for y in (-29000,0,29000) if x or y]):
    views.append(dict(name=f'far_{i}',world=[x,y,0],yaw=math.degrees(math.atan2(-y,-x)),pitch=35))
code=[];commands=[]
for i,v in enumerate(views):
    x,y,z=v['world'];name=f'Issue61CaveView{i}'
    code.append(f'''class {name} : Issue61View {{ override bool Use(bool pickup) {{ Super.Use(pickup); Owner.SetOrigin(({x},{y},{z}),false); Owner.Angle={v['yaw']};Owner.Pitch={v['pitch']}; Console.Printf("QA61_CAVE_VIEW {v['name']} sector=%d floor=%.2f",Owner.CurSector.Index(),Owner.CurSector.floorplane.ZatPoint(Owner.Pos.XY));return true; }} }}''')
    commands.append(f'give {name}; use {name}; wait 125; screenshot build/issue61_cave_{v["name"]}.png; wait 15')
(fixture/'Cave.zs').write_text('\n'.join(code)+'\n',encoding='utf-8')
with (fixture/'ZSCRIPT').open('a',encoding='utf-8') as out:out.write('\n#include "Cave.zs"\n')
seq=ROOT/'build/issue61_cave_views';seq.mkdir(exist_ok=True)
for i,c in enumerate(commands):
    following=f'exec build/issue61_cave_views/{i+1}.cfg' if i+1<len(commands) and i!=7 else 'echo QA61_CAVE_VIEWS_DONE; quit'
    (seq/f'{i}.cfg').write_text(c+'; '+following+'\n',encoding='utf-8')
print('Prepared',len(views),'native cave and distant-floor views')
route=report['cave']['walk_route']
route=route+list(reversed(route[:-1]))
point='vector3 Point(int i) { switch(i) {'+''.join(f'case {i}: return ({x},{y},{z});' for i,(x,y,z) in enumerate(route))+'} return (0,0,0); }'
checks=['class Issue61CaveChecks : CaelumSocialDebugAction {',point,
        f'double ExpectedFloor(vector2 p) {{ double u=(p.X-{spec["origin"][0]})*cos({spec["angle"]})+(p.Y-{spec["origin"][1]})*sin({spec["angle"]});return -{spec["depth"]}*clamp(u/{spec["descent_length"]},0.0,1.0); }}',
        'int BadFloor(vector3 p) {double actual=level.PointInSector(p.XY).floorplane.ZatPoint(p.XY);return abs(actual-p.Z)>0.01;}']
import sys
sys.path.insert(0,str(ROOT/'assets/generators'))
from repair_map01_mansion import read_map
obj=read_map(ROOT/'src/maps/MAP01.wad')
for index,t in enumerate(report['cave']['triangles']):
    if index%32==0:checks.append(f'int Floors{index//32}() {{ int failed=0;')
    pts=[obj['vertex'][i] for i in t['vertices']]
    x=sum(p['x'] for p in pts)/3;y=sum(p['y'] for p in pts)/3;z=sum(t['floor'])/3
    checks.append(f'failed+=BadFloor(({x},{y},{z}));')
    if index%32==31 or index==len(report['cave']['triangles'])-1:checks.append('return failed; }')
checks += ['override bool Use(bool pickup) { int failed=0;']
checks += [f'failed+=Floors{i}();' for i in range(math.ceil(len(report['cave']['triangles'])/32))]
checks += [f'Console.Printf("QA61_CAVE_FLOORS %s samples={len(report["cave"]["triangles"])} failures=%d",failed==0?"PASS":"FAIL",failed);',
'''let p=Spawn("Issue61Body",Point(0));p.bThruActors=true;
let stats=new("CaelumDerivedStats");
for(int tier=1;tier<=7;tier+=3) {
double factor=stats.GetHeightMetersForTier(tier)/1.8;p.A_SetSize(16*factor,56*factor);
p.SetOrigin(Point(0),false);failed=0;int steps=0;
''',f'for(int i=1;i<{len(route)};i++) {{',
'''vector3 begin=Point(i-1);vector3 end=Point(i);
int samples=int((end-begin).Length()/2)+1;
for(int j=1;j<=samples;j++) {
vector3 wanted=begin+(end-begin)*(double(j)/samples);
if(!p.TryMove(wanted.XY,true)) {failed++;Console.Printf("QA61_CAVE_BLOCK tier=%d segment=%d pos=%.1f %.1f %.1f",tier,i,p.Pos.X,p.Pos.Y,p.Pos.Z);break;}
// La sonda sin gravedad se apoya en el plano nativo de cada paso; FloorZ
// conserva la cota del contacto anterior al cambiar de triángulo inclinado.
double support=level.PointInSector(p.Pos.XY).floorplane.ZatPoint(p.Pos.XY);
if(abs(support-ExpectedFloor(wanted.XY))>0.1) {failed++;Console.Printf("QA61_CAVE_HEIGHT tier=%d segment=%d actual=%.2f expected=%.2f",tier,i,support,ExpectedFloor(wanted.XY));break;}
p.SetOrigin((p.Pos.X,p.Pos.Y,support),false);
steps++;
}
}
Console.Printf("QA61_CAVE_ROUTE %s tier=%d steps=%d failures=%d",failed==0?"PASS":"FAIL",tier,steps,failed);
}
p.Destroy();
''']
for gem in report['cave']['gems']:
    name=gem['classname']
    checks += [f'''{{ let it=ThinkerIterator.Create("{name}");Actor g=Actor(it.Next());
bool ok=g!=null;
if(g!=null) {{int before=g.Health;int damage=g.DamageMobj(Owner,Owner,10000,'Melee');
ok= !g.bShootable && !g.bSpecial && !(g is 'Inventory') && !(g is 'CaelumRockEnvironmentProp') && damage==0 && g.Health==before && abs(g.Pos.Z-g.CurSector.floorplane.ZatPoint(g.Pos.XY))<0.1;}}
Console.Printf("QA61_CAVE_GEM %s {name}",ok?"PASS":"FAIL"); }}''']
# Crossing above the underground roof, including both roof/terrain transitions.
spec=json.loads((ROOT/'assets/map01_mansion/CAVE.json').read_text())
def world(u,v):
    a=math.radians(spec['angle']);x,y=spec['origin'];return x+math.cos(a)*u-math.sin(a)*v,y+math.sin(a)*u+math.cos(a)*v
rx,ry=world(256,-512);ex,ey=world(256,512)
checks += [f'''p=Spawn("Issue61Body",({rx},{ry},0));p.bThruActors=true;failed=0;
for(int i=0;i<=512;i++) {{vector2 xy=({rx},{ry})+(({ex},{ey})-({rx},{ry}))*(double(i)/512);
if(!p.TryMove(xy,true)){{failed++;break;}}p.SetOrigin((p.Pos.X,p.Pos.Y,p.FloorZ),false);
if(i==256)Console.Printf("QA61_CAVE_ROOF_CENTER %s z=%.2f",p.Pos.Z>120?"PASS":"FAIL",p.Pos.Z);
}}
Console.Printf("QA61_CAVE_ROOF_CROSSING %s failures=%d",failed==0?"PASS":"FAIL",failed);p.Destroy();
return true; }} }}''']
checks += ['class Issue61CaveWalker : Actor { int waypoint;int ticks;',point,
'''override void Tick() {Super.Tick(); if(target==null){Destroy();return;} ticks++;
if(ticks>1500){Console.Printf("QA61_CAVE_PLAYER FAIL timeout waypoint=%d pos=%.1f %.1f %.1f",waypoint,target.Pos.X,target.Pos.Y,target.Pos.Z);target.Vel=(0,0,0);Destroy();return;}
vector3 goal=Point(waypoint);vector2 delta=goal.XY-target.Pos.XY;
if(delta.Length()<6){Console.Printf("QA61_CAVE_PLAYER_WAYPOINT %d z=%.2f",waypoint,target.Pos.Z);waypoint++;''',
f'''if(waypoint=={len(route)}){{Console.Printf("QA61_CAVE_PLAYER %s ticks=%d noclip=%d nogravity=%d",!target.bNoClip && !target.bNoGravity?"PASS":"FAIL",ticks,target.bNoClip,target.bNoGravity);target.Vel=(0,0,0);Destroy();return;}}goal=Point(waypoint);delta=goal.XY-target.Pos.XY;}}''',
'''target.Vel.X=delta.X/delta.Length()*4;target.Vel.Y=delta.Y/delta.Length()*4;target.Angle=delta.Angle();target.Pitch=10;
} Default { +NOINTERACTION } States { Spawn: TNT1 A -1; Stop; } }
class Issue61CaveWalk : Issue61View { override bool Use(bool pickup) {Super.Use(pickup);''',
f'''Owner.SetOrigin(({route[0][0]},{route[0][1]},0),false);Owner.Vel=(0,0,0);Owner.bNoClip=false;Owner.bNoGravity=false;
let w=Issue61CaveWalker(Spawn("Issue61CaveWalker"));w.target=Owner;return true; }} }}''']
(fixture/'CaveChecks.zs').write_text('\n'.join(checks)+'\n',encoding='utf-8')
with (fixture/'ZSCRIPT').open('a',encoding='utf-8') as out:out.write('#include "CaveChecks.zs"\n')
