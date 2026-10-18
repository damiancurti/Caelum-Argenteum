class CA318CeilingChecks : CA318HouseChecks
{
override void NetworkProcess(ConsoleEvent e)
{
Super.NetworkProcess(e);
let user=CaelumPlayer(players[0].mo);
if(e.Name=="ceilings_check"){
let probe=Actor.Spawn("CaelumSummoningProbe",(0,0,0),NO_REPLACE);
probe.A_SetSize(GetDefaultByType("CaelumPlayer").Radius,CaelumPortData.DEFENDER_HEIGHT);
for(int i=0;i<160;i++){probe.SetOrigin(CaelumCityData.DoorOutside(i),false);probe.FindFloorCeiling();Check(probe.TestMobjLocation(),String.Format("house%d doorstep fits defender",i));Check(probe.CeilingZ==184,String.Format("house%d expected ceiling",i));}
probe.SetOrigin((-29824.0,15872.0,384),false);probe.FindFloorCeiling();Check(probe.TestMobjLocation(),"wall/tower0 standing room");Check(probe.CeilingZ==1024,"wall/tower0 high ceiling retained");
probe.SetOrigin((896.0,15872.0,384),false);probe.FindFloorCeiling();Check(probe.TestMobjLocation(),"wall/tower1 standing room");Check(probe.CeilingZ==1024,"wall/tower1 high ceiling retained");
probe.SetOrigin((-29824.0,-14336.0,384),false);probe.FindFloorCeiling();Check(probe.TestMobjLocation(),"wall/tower2 standing room");Check(probe.CeilingZ==1024,"wall/tower2 high ceiling retained");
probe.SetOrigin((896.0,-14336.0,384),false);probe.FindFloorCeiling();Check(probe.TestMobjLocation(),"wall/tower3 standing room");Check(probe.CeilingZ==1024,"wall/tower3 high ceiling retained");
probe.SetOrigin((-27776.0,-14368.0,256),false);probe.FindFloorCeiling();Check(probe.TestMobjLocation(),"wall/tower4 standing room");Check(probe.CeilingZ==1024,"wall/tower4 high ceiling retained");
probe.SetOrigin((-23936.0,-14368.0,256),false);probe.FindFloorCeiling();Check(probe.TestMobjLocation(),"wall/tower5 standing room");Check(probe.CeilingZ==1024,"wall/tower5 high ceiling retained");
probe.SetOrigin((-20096.0,-14368.0,256),false);probe.FindFloorCeiling();Check(probe.TestMobjLocation(),"wall/tower6 standing room");Check(probe.CeilingZ==1024,"wall/tower6 high ceiling retained");
probe.SetOrigin((-16256.0,-14368.0,256),false);probe.FindFloorCeiling();Check(probe.TestMobjLocation(),"wall/tower7 standing room");Check(probe.CeilingZ==1024,"wall/tower7 high ceiling retained");
probe.SetOrigin((-12416.0,-14368.0,256),false);probe.FindFloorCeiling();Check(probe.TestMobjLocation(),"wall/tower8 standing room");Check(probe.CeilingZ==1024,"wall/tower8 high ceiling retained");
probe.SetOrigin((-8576.0,-14368.0,256),false);probe.FindFloorCeiling();Check(probe.TestMobjLocation(),"wall/tower9 standing room");Check(probe.CeilingZ==1024,"wall/tower9 high ceiling retained");
probe.SetOrigin((-4736.0,-14368.0,256),false);probe.FindFloorCeiling();Check(probe.TestMobjLocation(),"wall/tower10 standing room");Check(probe.CeilingZ==1024,"wall/tower10 high ceiling retained");
probe.SetOrigin((-896.0,-14368.0,256),false);probe.FindFloorCeiling();Check(probe.TestMobjLocation(),"wall/tower11 standing room");Check(probe.CeilingZ==1024,"wall/tower11 high ceiling retained");
probe.SetOrigin((-29472.0,15456.0,256),false);probe.FindFloorCeiling();Check(probe.TestMobjLocation(),"wall/tower12 standing room");Check(probe.CeilingZ==1024,"wall/tower12 high ceiling retained");
probe.SetOrigin((544.0,15456.0,256),false);probe.FindFloorCeiling();Check(probe.TestMobjLocation(),"wall/tower13 standing room");Check(probe.CeilingZ==1024,"wall/tower13 high ceiling retained");
probe.SetOrigin((-29472.0,-13920.0,256),false);probe.FindFloorCeiling();Check(probe.TestMobjLocation(),"wall/tower14 standing room");Check(probe.CeilingZ==1024,"wall/tower14 high ceiling retained");
probe.SetOrigin((544.0,-13920.0,256),false);probe.FindFloorCeiling();Check(probe.TestMobjLocation(),"wall/tower15 standing room");Check(probe.CeilingZ==1024,"wall/tower15 high ceiling retained");
probe.SetOrigin((-27776.0,15904.0,256),false);probe.FindFloorCeiling();Check(probe.TestMobjLocation(),"wall/tower16 standing room");Check(probe.CeilingZ==1024,"wall/tower16 high ceiling retained");
probe.SetOrigin((-23936.0,15904.0,256),false);probe.FindFloorCeiling();Check(probe.TestMobjLocation(),"wall/tower17 standing room");Check(probe.CeilingZ==1024,"wall/tower17 high ceiling retained");
probe.SetOrigin((-20096.0,15904.0,256),false);probe.FindFloorCeiling();Check(probe.TestMobjLocation(),"wall/tower18 standing room");Check(probe.CeilingZ==1024,"wall/tower18 high ceiling retained");
probe.SetOrigin((-16256.0,15904.0,256),false);probe.FindFloorCeiling();Check(probe.TestMobjLocation(),"wall/tower19 standing room");Check(probe.CeilingZ==1024,"wall/tower19 high ceiling retained");
probe.SetOrigin((-12416.0,15904.0,256),false);probe.FindFloorCeiling();Check(probe.TestMobjLocation(),"wall/tower20 standing room");Check(probe.CeilingZ==1024,"wall/tower20 high ceiling retained");
probe.SetOrigin((-8576.0,15904.0,256),false);probe.FindFloorCeiling();Check(probe.TestMobjLocation(),"wall/tower21 standing room");Check(probe.CeilingZ==1024,"wall/tower21 high ceiling retained");
probe.SetOrigin((-4736.0,15904.0,256),false);probe.FindFloorCeiling();Check(probe.TestMobjLocation(),"wall/tower22 standing room");Check(probe.CeilingZ==1024,"wall/tower22 high ceiling retained");
probe.SetOrigin((-896.0,15904.0,256),false);probe.FindFloorCeiling();Check(probe.TestMobjLocation(),"wall/tower23 standing room");Check(probe.CeilingZ==1024,"wall/tower23 high ceiling retained");
probe.SetOrigin((-29600.0,-12544.0,256),false);probe.FindFloorCeiling();Check(probe.TestMobjLocation(),"wall/tower24 standing room");Check(probe.CeilingZ==1024,"wall/tower24 high ceiling retained");
probe.SetOrigin((-29600.0,-8704.0,256),false);probe.FindFloorCeiling();Check(probe.TestMobjLocation(),"wall/tower25 standing room");Check(probe.CeilingZ==1024,"wall/tower25 high ceiling retained");
probe.SetOrigin((-29600.0,-4864.0,256),false);probe.FindFloorCeiling();Check(probe.TestMobjLocation(),"wall/tower26 standing room");Check(probe.CeilingZ==1024,"wall/tower26 high ceiling retained");
probe.SetOrigin((-29600.0,-1024.0,256),false);probe.FindFloorCeiling();Check(probe.TestMobjLocation(),"wall/tower27 standing room");Check(probe.CeilingZ==1024,"wall/tower27 high ceiling retained");
probe.SetOrigin((-29600.0,2816.0,256),false);probe.FindFloorCeiling();Check(probe.TestMobjLocation(),"wall/tower28 standing room");Check(probe.CeilingZ==1024,"wall/tower28 high ceiling retained");
probe.SetOrigin((-29600.0,6656.0,256),false);probe.FindFloorCeiling();Check(probe.TestMobjLocation(),"wall/tower29 standing room");Check(probe.CeilingZ==1024,"wall/tower29 high ceiling retained");
probe.SetOrigin((-29600.0,10496.0,256),false);probe.FindFloorCeiling();Check(probe.TestMobjLocation(),"wall/tower30 standing room");Check(probe.CeilingZ==1024,"wall/tower30 high ceiling retained");
probe.SetOrigin((-29600.0,14336.0,256),false);probe.FindFloorCeiling();Check(probe.TestMobjLocation(),"wall/tower31 standing room");Check(probe.CeilingZ==1024,"wall/tower31 high ceiling retained");
probe.SetOrigin((672.0,-12544.0,256),false);probe.FindFloorCeiling();Check(probe.TestMobjLocation(),"wall/tower32 standing room");Check(probe.CeilingZ==1024,"wall/tower32 high ceiling retained");
probe.SetOrigin((672.0,-8704.0,256),false);probe.FindFloorCeiling();Check(probe.TestMobjLocation(),"wall/tower33 standing room");Check(probe.CeilingZ==1024,"wall/tower33 high ceiling retained");
probe.SetOrigin((672.0,-4864.0,256),false);probe.FindFloorCeiling();Check(probe.TestMobjLocation(),"wall/tower34 standing room");Check(probe.CeilingZ==1024,"wall/tower34 high ceiling retained");
probe.SetOrigin((672.0,-1024.0,256),false);probe.FindFloorCeiling();Check(probe.TestMobjLocation(),"wall/tower35 standing room");Check(probe.CeilingZ==1024,"wall/tower35 high ceiling retained");
probe.SetOrigin((672.0,2816.0,256),false);probe.FindFloorCeiling();Check(probe.TestMobjLocation(),"wall/tower36 standing room");Check(probe.CeilingZ==1024,"wall/tower36 high ceiling retained");
probe.SetOrigin((672.0,6656.0,256),false);probe.FindFloorCeiling();Check(probe.TestMobjLocation(),"wall/tower37 standing room");Check(probe.CeilingZ==1024,"wall/tower37 high ceiling retained");
probe.SetOrigin((672.0,10496.0,256),false);probe.FindFloorCeiling();Check(probe.TestMobjLocation(),"wall/tower38 standing room");Check(probe.CeilingZ==1024,"wall/tower38 high ceiling retained");
probe.SetOrigin((672.0,14336.0,256),false);probe.FindFloorCeiling();Check(probe.TestMobjLocation(),"wall/tower39 standing room");Check(probe.CeilingZ==1024,"wall/tower39 high ceiling retained");
probe.SetOrigin((-21408.0,-12192.0,184),false);probe.FindFloorCeiling();Check(!probe.TestMobjLocation(),"closed roof has no standing headroom");probe.Destroy();}
if(e.Name=="ceilings_fly"){user.SetOrigin(CaelumCityData.DoorOutside(0),false);user.FindFloorCeiling();user.bNoGravity=true;user.Vel=(0,0,user.CeilingZ);}
if(e.Name=="ceilings_fly_checked"){Check(user.Pos.Z+user.Height<=user.CeilingZ+0.01,"upward movement stops below low sky");Check(user.Pos.Z>user.FloorZ,"upward movement actually occurred");user.bNoGravity=false;user.Vel=(0,0,0);}
if(e.Name=="ceilings_view"){switch(e.Args[0]){
case 0:user.SetOrigin((-20832,-12416,0),false);user.Angle=180;user.Pitch=0;break;
case 1:user.SetOrigin((-29824.0,15872.0,384),false);user.Angle=315;user.Pitch=0;break;
case 2:user.SetOrigin((-14464,-14000,0),false);user.Angle=90;user.Pitch=-20;break;
case 3:user.SetOrigin((0,320,0),false);user.Angle=180;user.Pitch=-20;break;
}user.FindFloorCeiling();user.Vel=(0,0,0);Check(user.TestMobjLocation(),"capture viewpoint fits");}
}
}
