class Issue61StationObserver : EventHandler {
Array<CaelumCraftingStation> original;
override void WorldLoaded(WorldEvent e) {
if(e.IsSaveGame)return;
let it=ThinkerIterator.Create("CaelumCraftingStation");CaelumCraftingStation s;
while((s=CaelumCraftingStation(it.Next()))!=null)original.Push(s);
Console.Printf("QA61_STATION_ORIGINAL count=%d",original.Size());
}
}
class Issue61StationChecks : CaelumSocialDebugAction {
override bool Use(bool pickup) {
int total=0,outside=0;int counts[6];int caps[6];int bad=0;
let it=ThinkerIterator.Create("CaelumCraftingStation");CaelumCraftingStation s;
let user=CaelumPlayer(Owner);
while((s=CaelumCraftingStation(it.Next()))!=null) {
total++;int group=s.CraftingRoomGroup;
if(group<1||group>5||abs(s.Pos.Y)>640){outside++;Console.Printf("QA61_STATION_OUTSIDE %s pos=%.4f %.4f %.4f floor=%.4f group=%d",s.GetClassName(),s.Pos.X,s.Pos.Y,s.Pos.Z,s.FloorZ,group);continue;}
counts[group]++;caps[group]|=CaelumCraftingRules.GetStationCapabilityBit(s.GetCraftingStationType());
if(group<5 && abs(s.Pos.Z)>0.01 || group==5 && abs(s.Pos.Z-264)>0.01)bad++;
if(abs(s.Radius-30)>0.01||abs(s.Height-72)>0.01)bad++;
}
Console.Printf("QA61_STATION_COUNTS %s total=%d outside=%d invalid=%d groups=%d,%d,%d,%d,%d",total==38&&outside==0&&bad==0&&counts[1]==5&&counts[2]==7&&counts[3]==5&&counts[4]==9&&counts[5]==12?"PASS":"FAIL",total,outside,bad,counts[1],counts[2],counts[3],counts[4],counts[5]);
bad=0;int scanned=0;it=ThinkerIterator.Create("CaelumCraftingStation");
while((s=CaelumCraftingStation(it.Next()))!=null)if(s.CraftingRoomGroup>=1 && s.CraftingRoomGroup<=5) {
int token=user.BeginCraftingNetworkScan();s.CollectCraftingNetwork(user,token);scanned++;
if(user.CraftingNetworkCapabilities!=caps[s.CraftingRoomGroup])bad++;
}
Console.Printf("QA61_STATION_NETWORKS %s scans=%d failures=%d",scanned==38&&bad==0?"PASS":"FAIL",scanned,bad);
vector3 previous=Owner.Pos;bool solid=Owner.bSolid;Owner.bSolid=false;
bad=0;int approaches=0;let probe=Spawn("Issue61Body");
it=ThinkerIterator.Create("CaelumCraftingStation");
while((s=CaelumCraftingStation(it.Next()))!=null)if(s.CraftingRoomGroup>=1 && s.CraftingRoomGroup<=5) {
vector2 front=s.Angle.ToVector();probe.SetOrigin(s.Pos+(front.X*84,front.Y*84,0),false);
bool ok=probe.TryMove(s.Pos.XY+front*60,true);approaches++;
Owner.SetOrigin(s.Pos+(front.X*60,front.Y*60,0),false);
if(!ok||!s.CanReachFrom(Owner)){bad++;Console.Printf("QA61_STATION_ACCESS_BAD group=%d type=%s",s.CraftingRoomGroup,s.GetClassName());}
}
probe.Destroy();Owner.SetOrigin(previous,false);Owner.bSolid=solid;
Console.Printf("QA61_STATION_ACCESS %s approaches=%d failures=%d",approaches==38&&bad==0?"PASS":"FAIL",approaches,bad);
let observer=Issue61StationObserver(EventHandler.Find("Issue61StationObserver"));int retained=0;
if(observer!=null)for(int i=0;i<observer.original.Size();i++)if(observer.original[i]!=null&&observer.original[i].CraftingRoomGroup>=1&&observer.original[i].CraftingRoomGroup<=5)retained++;
Console.Printf("QA61_STATION_IDENTITY %s retained=%d original=%d",observer!=null&&observer.original.Size()==18&&retained==18?"PASS":"FAIL",retained,observer==null?0:observer.original.Size());
return true; }
}
class Issue61StationRepeat : CaelumSocialDebugAction {
override bool Use(bool pickup) {
let c=CaelumMainM00QuestController(EventHandler.Find("CaelumMainM00QuestController"));
c.MansionLayoutPrepared=false;c.ChannelInfrastructureRecovered=false;c.ExpandedStationsPrepared=false;c.StationAccessPrepared=false;
Console.Printf("QA61_STATION_REPEAT_REQUESTED");return true;
}}
class Issue61StationView0 : Issue61View {override bool Use(bool pickup){Super.Use(pickup);Owner.SetOrigin((0,1370,70),false);Owner.Angle=270;Owner.Pitch=17;Console.Printf("QA61_STATION_VIEW north");return true;}}
class Issue61StationView1 : Issue61View {override bool Use(bool pickup){Super.Use(pickup);Owner.SetOrigin((-304,210,0),false);Owner.Angle=90;Owner.Pitch=8;Console.Printf("QA61_STATION_VIEW rulo");return true;}}
class Issue61StationView2 : Issue61View {override bool Use(bool pickup){Super.Use(pickup);Owner.SetOrigin((1150,245,0),false);Owner.Angle=135;Owner.Pitch=8;Console.Printf("QA61_STATION_VIEW ronnie");return true;}}
class Issue61StationView3 : Issue61View {override bool Use(bool pickup){Super.Use(pickup);Owner.SetOrigin((1080,-235,0),false);Owner.Angle=270;Owner.Pitch=8;Console.Printf("QA61_STATION_VIEW argento");return true;}}
class Issue61StationView4 : Issue61View {override bool Use(bool pickup){Super.Use(pickup);Owner.SetOrigin((-270,-180,0),false);Owner.Angle=245;Owner.Pitch=10;Console.Printf("QA61_STATION_VIEW caella");return true;}}
class Issue61StationView5 : Issue61View {override bool Use(bool pickup){Super.Use(pickup);Owner.SetOrigin((380,0,264),false);Owner.Angle=180;Owner.Pitch=8;Console.Printf("QA61_STATION_VIEW upstairs");return true;}}
