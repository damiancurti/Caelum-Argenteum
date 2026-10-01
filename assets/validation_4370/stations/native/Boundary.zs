class Issue61BoundaryView : Issue61View { override bool Use(bool pickup) {
Super.Use(pickup);Owner.SetOrigin((25630.19463978812,29408.004523812844,0),false);Owner.Angle=379.3359375;Owner.Pitch=8.0859375;
Console.Printf("QA61_BOUNDARY_SITE sector=%d",Owner.CurSector.Index());return true; } }
class Issue61SurfaceSnapshot : CaelumSocialDebugAction { override bool Use(bool pickup) {
let p=Spawn("Issue61Body");p.bSolid=false;FLineTraceData hit;int count=0;
for(int x=-1536;x<=2048;x+=256)for(int y=-768;y<=768;y+=256)
for(int z=-256;z<=640;z+=128) {
bool found=p.LineTrace(0,1024,90,TRF_THRUACTORS|TRF_ABSPOSITION,z,x,y,hit);
Console.Printf("QA61_SURFACE x=%d y=%d z=%d hit=%d height=%.4f",x,y,z,found,found?hit.HitLocation.Z:0);count++;
}
p.Destroy();Console.Printf("QA61_SURFACE_DONE samples=%d",count);return true; } }
class Issue61BoundaryChecks : CaelumSocialDebugAction { override bool Use(bool pickup) {
int failed=0,samples=0,moves=0;let p=Spawn("Issue61Body");p.bThruActors=true;

for(int x=25000;x<=29900;x+=100)for(int y=28500;y<=29900;y+=100) {
let s=level.PointInSector((x,y));double floor=s.floorplane.ZatPoint((x,y));
bool ok=s.Index()==6527 && abs(floor)<0.01 && s.ceilingplane.ZatPoint((x,y))>1000;
samples++;if(!ok){failed++;if(failed<=4)Console.Printf("QA61_BOUNDARY_BAD_POINT %d %d sector=%d",x,y,s.Index());}
for(int axis=0;axis<2;axis++)for(int direction=-1;direction<=1;direction+=2) {
p.SetOrigin((x,y,0),false);vector2 target=(x+(axis==0?24*direction:0),y+(axis==1?24*direction:0));moves++;
if(!p.TryMove(target,true))failed++;
}
}
Console.Printf("QA61_BOUNDARY_GRID %s samples=%d moves=%d failures=%d",failed==0?"PASS":"FAIL",samples,moves,failed);
failed=0;
if(level.PointInSector((28584.0,29896.0)).Index()!=6527)failed++;
if(level.PointInSector((28648.0,29896.0)).Index()!=6527)failed++;
if(level.PointInSector((28712.0,29896.0)).Index()!=6527)failed++;
if(level.PointInSector((28776.0,29896.0)).Index()!=6527)failed++;
if(level.PointInSector((28840.0,29896.0)).Index()!=6527)failed++;
if(level.PointInSector((28904.0,29896.0)).Index()!=6527)failed++;
if(level.PointInSector((28968.0,29896.0)).Index()!=6527)failed++;
if(level.PointInSector((29032.0,29896.0)).Index()!=6527)failed++;
if(level.PointInSector((29096.0,29896.0)).Index()!=6527)failed++;
if(level.PointInSector((29160.0,29896.0)).Index()!=6527)failed++;
if(level.PointInSector((29224.0,29896.0)).Index()!=6527)failed++;
if(level.PointInSector((29288.0,29896.0)).Index()!=6527)failed++;
if(level.PointInSector((29864.0,29832.0)).Index()!=6527)failed++;
if(level.PointInSector((29928.0,29832.0)).Index()!=6527)failed++;
if(level.PointInSector((29992.0,29832.0)).Index()!=6527)failed++;
if(level.PointInSector((27304.0,29960.0)).Index()!=6527)failed++;
if(level.PointInSector((27368.0,29960.0)).Index()!=6527)failed++;
if(level.PointInSector((27432.0,29960.0)).Index()!=6527)failed++;
if(level.PointInSector((27496.0,29960.0)).Index()!=6527)failed++;
if(level.PointInSector((27560.0,29960.0)).Index()!=6527)failed++;
if(level.PointInSector((27624.0,29960.0)).Index()!=6527)failed++;
if(level.PointInSector((27688.0,29960.0)).Index()!=6527)failed++;
if(level.PointInSector((27752.0,29960.0)).Index()!=6527)failed++;
if(level.PointInSector((27816.0,29960.0)).Index()!=6527)failed++;
if(level.PointInSector((27880.0,29960.0)).Index()!=6527)failed++;
if(level.PointInSector((27944.0,29960.0)).Index()!=6527)failed++;
if(level.PointInSector((28008.0,29960.0)).Index()!=6527)failed++;
if(level.PointInSector((28072.0,29960.0)).Index()!=6527)failed++;
if(level.PointInSector((26024.0,29704.0)).Index()!=6527)failed++;
if(level.PointInSector((26088.0,29704.0)).Index()!=6527)failed++;
if(level.PointInSector((27304.0,29704.0)).Index()!=6527)failed++;
if(level.PointInSector((27368.0,29704.0)).Index()!=6527)failed++;
if(level.PointInSector((27432.0,29704.0)).Index()!=6527)failed++;
if(level.PointInSector((27496.0,29704.0)).Index()!=6527)failed++;
if(level.PointInSector((27560.0,29704.0)).Index()!=6527)failed++;
if(level.PointInSector((27624.0,29704.0)).Index()!=6527)failed++;
if(level.PointInSector((28584.0,29704.0)).Index()!=6527)failed++;
if(level.PointInSector((28648.0,29704.0)).Index()!=6527)failed++;
if(level.PointInSector((28712.0,29704.0)).Index()!=6527)failed++;
if(level.PointInSector((28776.0,29704.0)).Index()!=6527)failed++;
if(level.PointInSector((27304.0,29640.0)).Index()!=6527)failed++;
if(level.PointInSector((26024.0,29384.0)).Index()!=6527)failed++;
if(level.PointInSector((26088.0,29384.0)).Index()!=6527)failed++;
if(level.PointInSector((26152.0,29384.0)).Index()!=6527)failed++;
if(level.PointInSector((26216.0,29384.0)).Index()!=6527)failed++;
if(level.PointInSector((26280.0,29384.0)).Index()!=6527)failed++;
if(level.PointInSector((26344.0,29384.0)).Index()!=6527)failed++;
if(level.PointInSector((26408.0,29384.0)).Index()!=6527)failed++;
if(level.PointInSector((26472.0,29384.0)).Index()!=6527)failed++;
if(level.PointInSector((26536.0,29384.0)).Index()!=6527)failed++;
if(level.PointInSector((26600.0,29384.0)).Index()!=6527)failed++;
if(level.PointInSector((26664.0,29384.0)).Index()!=6527)failed++;
if(level.PointInSector((26728.0,29384.0)).Index()!=6527)failed++;
if(level.PointInSector((26792.0,29384.0)).Index()!=6527)failed++;
if(level.PointInSector((26856.0,29384.0)).Index()!=6527)failed++;
if(level.PointInSector((26920.0,29384.0)).Index()!=6527)failed++;
if(level.PointInSector((26984.0,29384.0)).Index()!=6527)failed++;
if(level.PointInSector((27048.0,29384.0)).Index()!=6527)failed++;
if(level.PointInSector((27112.0,29384.0)).Index()!=6527)failed++;
if(level.PointInSector((27176.0,29384.0)).Index()!=6527)failed++;
if(level.PointInSector((27240.0,29384.0)).Index()!=6527)failed++;
if(level.PointInSector((27304.0,29384.0)).Index()!=6527)failed++;
if(level.PointInSector((27368.0,29384.0)).Index()!=6527)failed++;
if(level.PointInSector((26024.0,29256.0)).Index()!=6527)failed++;
Console.Printf("QA61_OLD_CONTROLS %s count=64 failures=%d",failed==0?"PASS":"FAIL",failed);p.Destroy();return true; } }
class Issue61BoundaryWalker : Actor {int waypoint;int ticks;
vector3 Point(int i){switch(i){case 0:return (25630.19463978812,29408.004523812844,0);case 1:return (26300,29408,0);case 2:return (27600,29500,0);case 3:return (28900,29500,0);case 4:return (25630.19463978812,29408.004523812844,0);}return (0,0,0);}
override void Tick(){Super.Tick();if(target==null){Destroy();return;}ticks++;
if(ticks>1500){Console.Printf("QA61_BOUNDARY_PLAYER FAIL timeout waypoint=%d",waypoint);target.Vel=(0,0,0);Destroy();return;}
vector3 destination=Point(waypoint);vector2 delta=destination.XY-target.Pos.XY;
if(delta.Length()<8){Console.Printf("QA61_BOUNDARY_PLAYER_POINT %d z=%.2f",waypoint,target.Pos.Z);waypoint++;

if(waypoint==5){Console.Printf("QA61_BOUNDARY_PLAYER %s ticks=%d noclip=%d nogravity=%d",!target.bNoClip && !target.bNoGravity && abs(target.Pos.Z)<0.01?"PASS":"FAIL",ticks,target.bNoClip,target.bNoGravity);target.Vel=(0,0,0);Destroy();return;}destination=Point(waypoint);delta=destination.XY-target.Pos.XY;}
target.Vel.X=delta.X/delta.Length()*6;target.Vel.Y=delta.Y/delta.Length()*6;target.Angle=delta.Angle();target.Pitch=8;}
Default {+NOINTERACTION} States {Spawn:TNT1 A -1;Stop;} }
class Issue61BoundaryWalk : Issue61BoundaryView {override bool Use(bool pickup){Super.Use(pickup);Owner.bNoClip=false;Owner.bNoGravity=false;Owner.Vel=(0,0,0);let w=Issue61BoundaryWalker(Spawn("Issue61BoundaryWalker"));w.target=Owner;return true;}}
class Issue61BoundaryV0 : Issue61View {override bool Use(bool pickup){Super.Use(pickup);Owner.SetOrigin((25630.19463978812,29408.004523812844,0),false);Owner.Angle=379.3359375;Owner.Pitch=8.0859375;Console.Printf("QA61_BOUNDARY_VIEW author sector=%d",Owner.CurSector.Index());return true;}}
class Issue61BoundaryV1 : Issue61View {override bool Use(bool pickup){Super.Use(pickup);Owner.SetOrigin((26024,29384,0),false);Owner.Angle=90;Owner.Pitch=15;Console.Printf("QA61_BOUNDARY_VIEW old_control sector=%d",Owner.CurSector.Index());return true;}}
class Issue61BoundaryV2 : Issue61View {override bool Use(bool pickup){Super.Use(pickup);Owner.SetOrigin((27400,29500,0),false);Owner.Angle=0;Owner.Pitch=20;Console.Printf("QA61_BOUNDARY_VIEW strip sector=%d",Owner.CurSector.Index());return true;}}
class Issue61BoundaryV3 : Issue61View {override bool Use(bool pickup){Super.Use(pickup);Owner.SetOrigin((29500,29600,0),false);Owner.Angle=225;Owner.Pitch=15;Console.Printf("QA61_BOUNDARY_VIEW corner sector=%d",Owner.CurSector.Index());return true;}}
class Issue61BoundaryV4 : Issue61View {override bool Use(bool pickup){Super.Use(pickup);Owner.SetOrigin((27500,28800,0),false);Owner.Angle=90;Owner.Pitch=15;Console.Printf("QA61_BOUNDARY_VIEW south sector=%d",Owner.CurSector.Index());return true;}}
