// Generado desde LAYOUT.json y generate_map02_maze.py.
class CaelumMazeLayout : Object play
{
    const REVISION = 6;
    static bool IsRedesigned(){let marker=ActorIterator.Create(44800,"CaelumMazeLayoutMarker").Next();return level.MapName=="MAP02" && marker!=null && marker.args[0]==6;}
    static bool IsCurrent(){return level.MapName=="MAP02" && ActorIterator.Create(44800,"CaelumMazeLayoutMarker").Next()!=null;}
    static vector3 TravelPosition(int id)
    {
        if(IsRedesigned())return CaelumMazeLayout6.TravelPosition(id);
        if(id==2)return (704,7008,0);
        if(id==4)return (2368,7008,0);
        if(id==6)return (704,7904,0);
        if(id==14)return (1536,8352,0);
        return (0,0,0);
    }
    const TIME_ADVANCE_ZONE_COUNT = 10;
    static vector3 TimeAdvanceZonePosition(int index)
    {
        if(IsRedesigned())return CaelumMazeLayout6.TimeAdvanceZonePosition(index);
        if(index==0)return (-448,320,0);
        if(index==1)return (320,-448,0);
        if(index==2)return (-2560,-5280,0);
        if(index==3)return (-6304,-1536,0);
        if(index==4)return (1184,-1536,0);
        if(index==5)return (-2560,2208,0);
        if(index==6)return (2464,-2368,0);
        if(index==7)return (-1280,1376,0);
        if(index==8)return (6208,1376,0);
        if(index==9)return (2464,5120,0);
        return (0,0,0);
    }
    static vector3 ArrivalChairPosition(){
        if(IsRedesigned())return CaelumMazeLayout6.ArrivalChairPosition();return (-448,-448,0);}
    static vector3 ArrivalBedPosition(){
        if(IsRedesigned())return CaelumMazeLayout6.ArrivalBedPosition();return (-448,320,0);}
    static vector3 ArrivalWorkbenchPosition(){
        if(IsRedesigned())return CaelumMazeLayout6.ArrivalWorkbenchPosition();return (320,-448,0);}
    static bool IsCardinal(){let marker=ActorIterator.Create(44800,"CaelumMazeLayoutMarker").Next();return level.MapName=="MAP02" && marker!=null && marker.args[0]>=3;}
    static Inventory CreateDeathDrop(int tid)
    {
        if(IsRedesigned())return CaelumMazeLayout6.CreateDeathDrop(tid);
        if((tid>=47000 && tid<47024) || (tid>=48000 && tid<48048))return CreateDeathDrop0(tid);
        if((tid>=47024 && tid<47048) || (tid>=48048 && tid<48096))return CreateDeathDrop1(tid);
        if((tid>=47048 && tid<47072) || (tid>=48096 && tid<48144))return CreateDeathDrop2(tid);
        if((tid>=47072 && tid<47096) || (tid>=48144 && tid<48192))return CreateDeathDrop3(tid);
        return null;
    }
    static bool HasDeathDrop(int tid)
    {
        if(IsRedesigned())return CaelumMazeLayout6.HasDeathDrop(tid);return (tid>=47000 && tid<=47008) || tid==47022 || (tid>=47024 && tid<=47030) || tid==47038 || tid==47043 || (tid>=47048 && tid<=47055) || (tid>=47062 && tid<=47063) || (tid>=47072 && tid<=47078) || (tid>=47086 && tid<=47087) || (tid>=48000 && tid<=48191);}
    static Inventory CreateDeathDrop0(int tid)
    {
        Inventory item;
        if(tid==47000){item=Inventory(Actor.Spawn("CaelumArrowAmmo",(-1344,-5472,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48000){item=Inventory(Actor.Spawn("CaelumFoodRation",(-1728,-5344,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48001){item=Inventory(Actor.Spawn("CaelumWaterRation",(-1344,-5216,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47001){item=Inventory(Actor.Spawn("CaelumMazeSouthCellKey",(-576,-5472,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48002){item=Inventory(Actor.Spawn("CaelumFoodRation",(-960,-5344,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48003){item=Inventory(Actor.Spawn("CaelumWaterRation",(-576,-5216,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47002){item=Inventory(Actor.Spawn("CaelumArrowAmmo",(192,-5472,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48004){item=Inventory(Actor.Spawn("CaelumFoodRation",(-192,-5344,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48005){item=Inventory(Actor.Spawn("CaelumWaterRation",(192,-5216,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47003){item=Inventory(Actor.Spawn("CaelumArrowAmmo",(960,-5472,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48006){item=Inventory(Actor.Spawn("CaelumFoodRation",(576,-5344,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48007){item=Inventory(Actor.Spawn("CaelumWaterRation",(960,-5216,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47004){item=Inventory(Actor.Spawn("CaelumBoltAmmo",(1728,-5472,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48008){item=Inventory(Actor.Spawn("CaelumFoodRation",(1344,-5344,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48009){item=Inventory(Actor.Spawn("CaelumWaterRation",(1728,-5216,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47005){item=Inventory(Actor.Spawn("CaelumArrowAmmo",(-1344,-4704,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48010){item=Inventory(Actor.Spawn("CaelumFoodRation",(-1728,-4576,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48011){item=Inventory(Actor.Spawn("CaelumWaterRation",(-1344,-4448,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47006){item=Inventory(Actor.Spawn("CaelumArrowAmmo",(-576,-4704,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48012){item=Inventory(Actor.Spawn("CaelumFoodRation",(-960,-4576,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48013){item=Inventory(Actor.Spawn("CaelumWaterRation",(-576,-4448,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47007){item=Inventory(Actor.Spawn("CaelumBoltAmmo",(192,-4704,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48014){item=Inventory(Actor.Spawn("CaelumFoodRation",(-192,-4576,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48015){item=Inventory(Actor.Spawn("CaelumWaterRation",(192,-4448,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47008){item=Inventory(Actor.Spawn("CaelumBoltAmmo",(960,-4704,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48016){item=Inventory(Actor.Spawn("CaelumFoodRation",(576,-4576,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48017){item=Inventory(Actor.Spawn("CaelumWaterRation",(960,-4448,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48018){item=Inventory(Actor.Spawn("CaelumFoodRation",(1344,-4576,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48019){item=Inventory(Actor.Spawn("CaelumWaterRation",(1728,-4448,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48020){item=Inventory(Actor.Spawn("CaelumFoodRation",(-1728,-3808,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48021){item=Inventory(Actor.Spawn("CaelumWaterRation",(-1344,-3680,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48022){item=Inventory(Actor.Spawn("CaelumFoodRation",(-960,-3808,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48023){item=Inventory(Actor.Spawn("CaelumWaterRation",(-576,-3680,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48024){item=Inventory(Actor.Spawn("CaelumFoodRation",(-192,-3808,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48025){item=Inventory(Actor.Spawn("CaelumWaterRation",(192,-3680,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48026){item=Inventory(Actor.Spawn("CaelumFoodRation",(576,-3808,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48027){item=Inventory(Actor.Spawn("CaelumWaterRation",(960,-3680,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48028){item=Inventory(Actor.Spawn("CaelumFoodRation",(1344,-3808,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48029){item=Inventory(Actor.Spawn("CaelumWaterRation",(1728,-3680,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48030){item=Inventory(Actor.Spawn("CaelumFoodRation",(-1728,-3040,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48031){item=Inventory(Actor.Spawn("CaelumWaterRation",(-1344,-2912,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48032){item=Inventory(Actor.Spawn("CaelumFoodRation",(-960,-3040,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48033){item=Inventory(Actor.Spawn("CaelumWaterRation",(-576,-2912,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48034){item=Inventory(Actor.Spawn("CaelumFoodRation",(-192,-3040,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48035){item=Inventory(Actor.Spawn("CaelumWaterRation",(192,-2912,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48036){item=Inventory(Actor.Spawn("CaelumFoodRation",(576,-3040,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48037){item=Inventory(Actor.Spawn("CaelumWaterRation",(960,-2912,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48038){item=Inventory(Actor.Spawn("CaelumFoodRation",(1344,-3040,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48039){item=Inventory(Actor.Spawn("CaelumWaterRation",(1728,-2912,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48040){item=Inventory(Actor.Spawn("CaelumFoodRation",(-1728,-2272,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48041){item=Inventory(Actor.Spawn("CaelumWaterRation",(-1344,-2144,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48042){item=Inventory(Actor.Spawn("CaelumFoodRation",(-960,-2272,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48043){item=Inventory(Actor.Spawn("CaelumWaterRation",(-576,-2144,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47022){item=Inventory(Actor.Spawn("CaelumMazeSluiceKey",(960,-2400,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48044){item=Inventory(Actor.Spawn("CaelumFoodRation",(576,-2272,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48045){item=Inventory(Actor.Spawn("CaelumWaterRation",(960,-2144,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48046){item=Inventory(Actor.Spawn("CaelumFoodRation",(1344,-2272,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48047){item=Inventory(Actor.Spawn("CaelumWaterRation",(1728,-2144,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        return null;
    }
    static Inventory CreateDeathDrop1(int tid)
    {
        Inventory item;
        if(tid==47024){item=Inventory(Actor.Spawn("CaelumArrowAmmo",(-5088,-1728,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48048){item=Inventory(Actor.Spawn("CaelumFoodRation",(-5472,-1600,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48049){item=Inventory(Actor.Spawn("CaelumWaterRation",(-5088,-1472,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47025){item=Inventory(Actor.Spawn("CaelumArrowAmmo",(-4320,-1728,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48050){item=Inventory(Actor.Spawn("CaelumFoodRation",(-4704,-1600,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48051){item=Inventory(Actor.Spawn("CaelumWaterRation",(-4320,-1472,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47026){item=Inventory(Actor.Spawn("CaelumArrowAmmo",(-3552,-1728,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48052){item=Inventory(Actor.Spawn("CaelumFoodRation",(-3936,-1600,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48053){item=Inventory(Actor.Spawn("CaelumWaterRation",(-3552,-1472,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47027){item=Inventory(Actor.Spawn("CaelumBoltAmmo",(-2784,-1728,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48054){item=Inventory(Actor.Spawn("CaelumFoodRation",(-3168,-1600,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48055){item=Inventory(Actor.Spawn("CaelumWaterRation",(-2784,-1472,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47028){item=Inventory(Actor.Spawn("CaelumBoltAmmo",(-2016,-1728,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48056){item=Inventory(Actor.Spawn("CaelumFoodRation",(-2400,-1600,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48057){item=Inventory(Actor.Spawn("CaelumWaterRation",(-2016,-1472,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47029){item=Inventory(Actor.Spawn("CaelumArrowAmmo",(-5088,-960,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48058){item=Inventory(Actor.Spawn("CaelumFoodRation",(-5472,-832,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48059){item=Inventory(Actor.Spawn("CaelumWaterRation",(-5088,-704,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47030){item=Inventory(Actor.Spawn("CaelumBoltAmmo",(-4320,-960,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48060){item=Inventory(Actor.Spawn("CaelumFoodRation",(-4704,-832,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48061){item=Inventory(Actor.Spawn("CaelumWaterRation",(-4320,-704,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48062){item=Inventory(Actor.Spawn("CaelumFoodRation",(-3936,-832,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48063){item=Inventory(Actor.Spawn("CaelumWaterRation",(-3552,-704,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48064){item=Inventory(Actor.Spawn("CaelumFoodRation",(-3168,-832,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48065){item=Inventory(Actor.Spawn("CaelumWaterRation",(-2784,-704,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48066){item=Inventory(Actor.Spawn("CaelumFoodRation",(-2400,-832,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48067){item=Inventory(Actor.Spawn("CaelumWaterRation",(-2016,-704,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48068){item=Inventory(Actor.Spawn("CaelumFoodRation",(-5472,-64,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48069){item=Inventory(Actor.Spawn("CaelumWaterRation",(-5088,64,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48070){item=Inventory(Actor.Spawn("CaelumFoodRation",(-4704,-64,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48071){item=Inventory(Actor.Spawn("CaelumWaterRation",(-4320,64,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48072){item=Inventory(Actor.Spawn("CaelumFoodRation",(-3936,-64,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48073){item=Inventory(Actor.Spawn("CaelumWaterRation",(-3552,64,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48074){item=Inventory(Actor.Spawn("CaelumFoodRation",(-3168,-64,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48075){item=Inventory(Actor.Spawn("CaelumWaterRation",(-2784,64,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47038){item=Inventory(Actor.Spawn("CaelumMazeCryptKey",(-5088,576,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48076){item=Inventory(Actor.Spawn("CaelumFoodRation",(-5472,704,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48077){item=Inventory(Actor.Spawn("CaelumWaterRation",(-5088,832,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48078){item=Inventory(Actor.Spawn("CaelumFoodRation",(-4704,704,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48079){item=Inventory(Actor.Spawn("CaelumWaterRation",(-4320,832,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48080){item=Inventory(Actor.Spawn("CaelumFoodRation",(-3936,704,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48081){item=Inventory(Actor.Spawn("CaelumWaterRation",(-3552,832,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48082){item=Inventory(Actor.Spawn("CaelumFoodRation",(-3168,704,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48083){item=Inventory(Actor.Spawn("CaelumWaterRation",(-2784,832,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48084){item=Inventory(Actor.Spawn("CaelumFoodRation",(-2400,704,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48085){item=Inventory(Actor.Spawn("CaelumWaterRation",(-2016,832,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47043){item=Inventory(Actor.Spawn("CaelumMazeWestCellKey",(-5088,1344,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48086){item=Inventory(Actor.Spawn("CaelumFoodRation",(-5472,1472,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48087){item=Inventory(Actor.Spawn("CaelumWaterRation",(-5088,1600,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48088){item=Inventory(Actor.Spawn("CaelumFoodRation",(-4704,1472,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48089){item=Inventory(Actor.Spawn("CaelumWaterRation",(-4320,1600,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48090){item=Inventory(Actor.Spawn("CaelumFoodRation",(-3936,1472,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48091){item=Inventory(Actor.Spawn("CaelumWaterRation",(-3552,1600,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48092){item=Inventory(Actor.Spawn("CaelumFoodRation",(-3168,1472,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48093){item=Inventory(Actor.Spawn("CaelumWaterRation",(-2784,1600,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48094){item=Inventory(Actor.Spawn("CaelumFoodRation",(-2400,1472,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48095){item=Inventory(Actor.Spawn("CaelumWaterRation",(-2016,1600,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        return null;
    }
    static Inventory CreateDeathDrop2(int tid)
    {
        Inventory item;
        if(tid==47048){item=Inventory(Actor.Spawn("CaelumArrowAmmo",(2400,-1728,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48096){item=Inventory(Actor.Spawn("CaelumFoodRation",(2016,-1600,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48097){item=Inventory(Actor.Spawn("CaelumWaterRation",(2400,-1472,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47049){item=Inventory(Actor.Spawn("CaelumArrowAmmo",(3168,-1728,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48098){item=Inventory(Actor.Spawn("CaelumFoodRation",(2784,-1600,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48099){item=Inventory(Actor.Spawn("CaelumWaterRation",(3168,-1472,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47050){item=Inventory(Actor.Spawn("CaelumArrowAmmo",(3936,-1728,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48100){item=Inventory(Actor.Spawn("CaelumFoodRation",(3552,-1600,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48101){item=Inventory(Actor.Spawn("CaelumWaterRation",(3936,-1472,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47051){item=Inventory(Actor.Spawn("CaelumBoltAmmo",(4704,-1728,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48102){item=Inventory(Actor.Spawn("CaelumFoodRation",(4320,-1600,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48103){item=Inventory(Actor.Spawn("CaelumWaterRation",(4704,-1472,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47052){item=Inventory(Actor.Spawn("CaelumArrowAmmo",(5472,-1728,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48104){item=Inventory(Actor.Spawn("CaelumFoodRation",(5088,-1600,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48105){item=Inventory(Actor.Spawn("CaelumWaterRation",(5472,-1472,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47053){item=Inventory(Actor.Spawn("CaelumArrowAmmo",(2400,-960,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48106){item=Inventory(Actor.Spawn("CaelumFoodRation",(2016,-832,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48107){item=Inventory(Actor.Spawn("CaelumWaterRation",(2400,-704,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47054){item=Inventory(Actor.Spawn("CaelumBoltAmmo",(3168,-960,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48108){item=Inventory(Actor.Spawn("CaelumFoodRation",(2784,-832,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48109){item=Inventory(Actor.Spawn("CaelumWaterRation",(3168,-704,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47055){item=Inventory(Actor.Spawn("CaelumBoltAmmo",(3936,-960,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48110){item=Inventory(Actor.Spawn("CaelumFoodRation",(3552,-832,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48111){item=Inventory(Actor.Spawn("CaelumWaterRation",(3936,-704,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48112){item=Inventory(Actor.Spawn("CaelumFoodRation",(4320,-832,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48113){item=Inventory(Actor.Spawn("CaelumWaterRation",(4704,-704,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48114){item=Inventory(Actor.Spawn("CaelumFoodRation",(5088,-832,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48115){item=Inventory(Actor.Spawn("CaelumWaterRation",(5472,-704,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48116){item=Inventory(Actor.Spawn("CaelumFoodRation",(2784,-64,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48117){item=Inventory(Actor.Spawn("CaelumWaterRation",(3168,64,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48118){item=Inventory(Actor.Spawn("CaelumFoodRation",(3552,-64,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48119){item=Inventory(Actor.Spawn("CaelumWaterRation",(3936,64,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48120){item=Inventory(Actor.Spawn("CaelumFoodRation",(4320,-64,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48121){item=Inventory(Actor.Spawn("CaelumWaterRation",(4704,64,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48122){item=Inventory(Actor.Spawn("CaelumFoodRation",(5088,-64,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48123){item=Inventory(Actor.Spawn("CaelumWaterRation",(5472,64,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47062){item=Inventory(Actor.Spawn("CaelumMazeSanctumKey",(2400,576,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48124){item=Inventory(Actor.Spawn("CaelumFoodRation",(2016,704,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48125){item=Inventory(Actor.Spawn("CaelumWaterRation",(2400,832,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47063){item=Inventory(Actor.Spawn("CaelumMazeEastCellKey",(3168,576,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48126){item=Inventory(Actor.Spawn("CaelumFoodRation",(2784,704,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48127){item=Inventory(Actor.Spawn("CaelumWaterRation",(3168,832,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48128){item=Inventory(Actor.Spawn("CaelumFoodRation",(3552,704,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48129){item=Inventory(Actor.Spawn("CaelumWaterRation",(3936,832,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48130){item=Inventory(Actor.Spawn("CaelumFoodRation",(4320,704,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48131){item=Inventory(Actor.Spawn("CaelumWaterRation",(4704,832,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48132){item=Inventory(Actor.Spawn("CaelumFoodRation",(5088,704,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48133){item=Inventory(Actor.Spawn("CaelumWaterRation",(5472,832,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48134){item=Inventory(Actor.Spawn("CaelumFoodRation",(2016,1472,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48135){item=Inventory(Actor.Spawn("CaelumWaterRation",(2400,1600,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48136){item=Inventory(Actor.Spawn("CaelumFoodRation",(2784,1472,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48137){item=Inventory(Actor.Spawn("CaelumWaterRation",(3168,1600,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48138){item=Inventory(Actor.Spawn("CaelumFoodRation",(3552,1472,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48139){item=Inventory(Actor.Spawn("CaelumWaterRation",(3936,1600,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48140){item=Inventory(Actor.Spawn("CaelumFoodRation",(4320,1472,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48141){item=Inventory(Actor.Spawn("CaelumWaterRation",(4704,1600,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48142){item=Inventory(Actor.Spawn("CaelumFoodRation",(5088,1472,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48143){item=Inventory(Actor.Spawn("CaelumWaterRation",(5472,1600,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        return null;
    }
    static Inventory CreateDeathDrop3(int tid)
    {
        Inventory item;
        if(tid==47072){item=Inventory(Actor.Spawn("CaelumArrowAmmo",(-1344,2016,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48144){item=Inventory(Actor.Spawn("CaelumFoodRation",(-1728,2144,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48145){item=Inventory(Actor.Spawn("CaelumWaterRation",(-1344,2272,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47073){item=Inventory(Actor.Spawn("CaelumArrowAmmo",(-576,2016,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48146){item=Inventory(Actor.Spawn("CaelumFoodRation",(-960,2144,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48147){item=Inventory(Actor.Spawn("CaelumWaterRation",(-576,2272,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47074){item=Inventory(Actor.Spawn("CaelumArrowAmmo",(960,2016,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48148){item=Inventory(Actor.Spawn("CaelumFoodRation",(576,2144,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48149){item=Inventory(Actor.Spawn("CaelumWaterRation",(960,2272,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47075){item=Inventory(Actor.Spawn("CaelumBoltAmmo",(1728,2016,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48150){item=Inventory(Actor.Spawn("CaelumFoodRation",(1344,2144,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48151){item=Inventory(Actor.Spawn("CaelumWaterRation",(1728,2272,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47076){item=Inventory(Actor.Spawn("CaelumBoltAmmo",(-1344,2784,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48152){item=Inventory(Actor.Spawn("CaelumFoodRation",(-1728,2912,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48153){item=Inventory(Actor.Spawn("CaelumWaterRation",(-1344,3040,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47077){item=Inventory(Actor.Spawn("CaelumArrowAmmo",(-576,2784,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48154){item=Inventory(Actor.Spawn("CaelumFoodRation",(-960,2912,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48155){item=Inventory(Actor.Spawn("CaelumWaterRation",(-576,3040,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47078){item=Inventory(Actor.Spawn("CaelumBoltAmmo",(192,2784,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48156){item=Inventory(Actor.Spawn("CaelumFoodRation",(-192,2912,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48157){item=Inventory(Actor.Spawn("CaelumWaterRation",(192,3040,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48158){item=Inventory(Actor.Spawn("CaelumFoodRation",(576,2912,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48159){item=Inventory(Actor.Spawn("CaelumWaterRation",(960,3040,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48160){item=Inventory(Actor.Spawn("CaelumFoodRation",(1344,2912,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48161){item=Inventory(Actor.Spawn("CaelumWaterRation",(1728,3040,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48162){item=Inventory(Actor.Spawn("CaelumFoodRation",(-1728,3680,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48163){item=Inventory(Actor.Spawn("CaelumWaterRation",(-1344,3808,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48164){item=Inventory(Actor.Spawn("CaelumFoodRation",(-960,3680,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48165){item=Inventory(Actor.Spawn("CaelumWaterRation",(-576,3808,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48166){item=Inventory(Actor.Spawn("CaelumFoodRation",(-192,3680,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48167){item=Inventory(Actor.Spawn("CaelumWaterRation",(192,3808,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48168){item=Inventory(Actor.Spawn("CaelumFoodRation",(576,3680,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48169){item=Inventory(Actor.Spawn("CaelumWaterRation",(960,3808,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48170){item=Inventory(Actor.Spawn("CaelumFoodRation",(1344,3680,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48171){item=Inventory(Actor.Spawn("CaelumWaterRation",(1728,3808,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47086){item=Inventory(Actor.Spawn("CaelumMazeNorthKey",(-1344,4320,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48172){item=Inventory(Actor.Spawn("CaelumFoodRation",(-1728,4448,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48173){item=Inventory(Actor.Spawn("CaelumWaterRation",(-1344,4576,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47087){item=Inventory(Actor.Spawn("CaelumMazeNorthCellKey",(-576,4320,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48174){item=Inventory(Actor.Spawn("CaelumFoodRation",(-960,4448,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48175){item=Inventory(Actor.Spawn("CaelumWaterRation",(-576,4576,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48176){item=Inventory(Actor.Spawn("CaelumFoodRation",(-192,4448,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48177){item=Inventory(Actor.Spawn("CaelumWaterRation",(192,4576,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48178){item=Inventory(Actor.Spawn("CaelumFoodRation",(576,4448,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48179){item=Inventory(Actor.Spawn("CaelumWaterRation",(960,4576,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48180){item=Inventory(Actor.Spawn("CaelumFoodRation",(1344,4448,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48181){item=Inventory(Actor.Spawn("CaelumWaterRation",(1728,4576,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48182){item=Inventory(Actor.Spawn("CaelumFoodRation",(-1728,5216,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48183){item=Inventory(Actor.Spawn("CaelumWaterRation",(-1344,5344,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48184){item=Inventory(Actor.Spawn("CaelumFoodRation",(-960,5216,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48185){item=Inventory(Actor.Spawn("CaelumWaterRation",(-576,5344,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48186){item=Inventory(Actor.Spawn("CaelumFoodRation",(-192,5216,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48187){item=Inventory(Actor.Spawn("CaelumWaterRation",(192,5344,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48188){item=Inventory(Actor.Spawn("CaelumFoodRation",(576,5216,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48189){item=Inventory(Actor.Spawn("CaelumWaterRation",(960,5344,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48190){item=Inventory(Actor.Spawn("CaelumFoodRation",(1344,5216,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48191){item=Inventory(Actor.Spawn("CaelumWaterRation",(1728,5344,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        return null;
    }
    const RETURN_FLOOR = -160;
    const RETURN_CEILING = -32;
    const RETURN_SPEED = 16;
    const RETURN_ELEVATOR_TAG = 44900;
    static bool IsFloodedReturn(){let marker=ActorIterator.Create(44800,"CaelumMazeLayoutMarker").Next();return level.MapName=="MAP02" && marker!=null && marker.args[0]>=4;}
    static bool IsReturnGrate(int tag){return tag==44910 || tag==44911 || tag==44912 || tag==44913;}
    static bool IsInsideElevator(vector2 p){return p.X>-256 && p.X<256 && p.Y>-256 && p.Y<256;}
    static bool IsGrateExterior(int index,vector2 p)
    {
        if(index==0)return p.Y<=-288;
        if(index==1)return p.X<=-288;
        if(index==2)return p.X>=288;
        if(index==3)return p.Y>=288;
        return false;
    }
    static int PitEntrance(int trap)
    {
        if(trap==43916)return 44700;
        if(trap==43925)return 44701;
        if(trap==43929)return 44701;
        if(trap==43930)return 44701;
        if(trap==43933)return 44701;
        return 0;
    }
}

// Generado desde LAYOUT.json y generate_map02_maze.py.
class CaelumMazeLayout6 : Object play
{
    const REVISION = 6;
    static bool IsCurrent(){return level.MapName=="MAP02" && ActorIterator.Create(44800,"CaelumMazeLayoutMarker").Next()!=null;}
    static vector3 TravelPosition(int id)
    {
        if(id==2)return (-2208,7072,0);
        if(id==4)return (-1888,7072,0);
        if(id==6)return (-2208,7360,0);
        if(id==14)return (-1888,7360,0);
        return (0,0,0);
    }
    const TIME_ADVANCE_ZONE_COUNT = 10;
    static vector3 TimeAdvanceZonePosition(int index)
    {
        if(index==0)return (-448,-4672,0);
        if(index==1)return (320,-5312,0);
        if(index==2)return (-4096,-3072,0);
        if(index==3)return (-7168,5120,0);
        if(index==4)return (7168,5120,0);
        if(index==5)return (-1024,9216,0);
        if(index==6)return (4000,-4256,0);
        if(index==7)return (-5216,96,0);
        if(index==8)return (5024,96,0);
        if(index==9)return (8096,7008,0);
        return (0,0,0);
    }
    static vector3 ArrivalChairPosition(){return (-448,-5312,0);}
    static vector3 ArrivalBedPosition(){return (-448,-4672,0);}
    static vector3 ArrivalWorkbenchPosition(){return (320,-5312,0);}
    static bool IsCardinal(){let marker=ActorIterator.Create(44800,"CaelumMazeLayoutMarker").Next();return level.MapName=="MAP02" && marker!=null && marker.args[0]>=3;}
    static Inventory CreateDeathDrop(int tid)
    {
        if((tid>=47000 && tid<47024) || (tid>=48000 && tid<48048))return CreateDeathDrop0(tid);
        if((tid>=47024 && tid<47048) || (tid>=48048 && tid<48096))return CreateDeathDrop1(tid);
        if((tid>=47048 && tid<47072) || (tid>=48096 && tid<48144))return CreateDeathDrop2(tid);
        if((tid>=47072 && tid<47096) || (tid>=48144 && tid<48192))return CreateDeathDrop3(tid);
        return null;
    }
    static bool HasDeathDrop(int tid)
    {return (tid>=47000 && tid<=47008) || tid==47022 || (tid>=47024 && tid<=47030) || tid==47038 || tid==47043 || (tid>=47048 && tid<=47055) || (tid>=47062 && tid<=47063) || (tid>=47072 && tid<=47078) || (tid>=47086 && tid<=47087) || (tid>=48000 && tid<=48191);}
    static Inventory CreateDeathDrop0(int tid)
    {
        Inventory item;
        if(tid==47000){item=Inventory(Actor.Spawn("CaelumArrowAmmo",(2400,-4192,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48000){item=Inventory(Actor.Spawn("CaelumFoodRation",(2208,-4224,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48001){item=Inventory(Actor.Spawn("CaelumWaterRation",(2400,-4000,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47001){item=Inventory(Actor.Spawn("CaelumMazeSouthCellKey",(-2976,-1120,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48002){item=Inventory(Actor.Spawn("CaelumFoodRation",(-3168,-1152,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48003){item=Inventory(Actor.Spawn("CaelumWaterRation",(-2976,-928,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47002){item=Inventory(Actor.Spawn("CaelumArrowAmmo",(1632,-4192,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48004){item=Inventory(Actor.Spawn("CaelumFoodRation",(1440,-4224,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48005){item=Inventory(Actor.Spawn("CaelumWaterRation",(1632,-4000,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47003){item=Inventory(Actor.Spawn("CaelumArrowAmmo",(3168,-4192,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48006){item=Inventory(Actor.Spawn("CaelumFoodRation",(2976,-4224,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48007){item=Inventory(Actor.Spawn("CaelumWaterRation",(3168,-4000,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47004){item=Inventory(Actor.Spawn("CaelumBoltAmmo",(-2976,-3168,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48008){item=Inventory(Actor.Spawn("CaelumFoodRation",(-3168,-3200,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48009){item=Inventory(Actor.Spawn("CaelumWaterRation",(-2976,-2976,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47005){item=Inventory(Actor.Spawn("CaelumArrowAmmo",(-1440,-3168,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48010){item=Inventory(Actor.Spawn("CaelumFoodRation",(-1632,-3200,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48011){item=Inventory(Actor.Spawn("CaelumWaterRation",(-1440,-2976,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47006){item=Inventory(Actor.Spawn("CaelumArrowAmmo",(96,-3168,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48012){item=Inventory(Actor.Spawn("CaelumFoodRation",(-96,-3200,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48013){item=Inventory(Actor.Spawn("CaelumWaterRation",(96,-2976,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47007){item=Inventory(Actor.Spawn("CaelumBoltAmmo",(1632,-3168,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48014){item=Inventory(Actor.Spawn("CaelumFoodRation",(1440,-3200,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48015){item=Inventory(Actor.Spawn("CaelumWaterRation",(1632,-2976,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47008){item=Inventory(Actor.Spawn("CaelumBoltAmmo",(3168,-3168,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48016){item=Inventory(Actor.Spawn("CaelumFoodRation",(2976,-3200,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48017){item=Inventory(Actor.Spawn("CaelumWaterRation",(3168,-2976,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48018){item=Inventory(Actor.Spawn("CaelumFoodRation",(-3168,-2176,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48019){item=Inventory(Actor.Spawn("CaelumWaterRation",(-2976,-1952,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48020){item=Inventory(Actor.Spawn("CaelumFoodRation",(-1632,-2176,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48021){item=Inventory(Actor.Spawn("CaelumWaterRation",(-1440,-1952,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48022){item=Inventory(Actor.Spawn("CaelumFoodRation",(-96,-2176,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48023){item=Inventory(Actor.Spawn("CaelumWaterRation",(96,-1952,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48024){item=Inventory(Actor.Spawn("CaelumFoodRation",(1440,-2176,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48025){item=Inventory(Actor.Spawn("CaelumWaterRation",(1632,-1952,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48026){item=Inventory(Actor.Spawn("CaelumFoodRation",(2976,-2176,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48027){item=Inventory(Actor.Spawn("CaelumWaterRation",(3168,-1952,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48028){item=Inventory(Actor.Spawn("CaelumFoodRation",(-1632,-4224,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48029){item=Inventory(Actor.Spawn("CaelumWaterRation",(-1440,-4000,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48030){item=Inventory(Actor.Spawn("CaelumFoodRation",(-1632,-1152,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48031){item=Inventory(Actor.Spawn("CaelumWaterRation",(-1440,-928,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48032){item=Inventory(Actor.Spawn("CaelumFoodRation",(-96,-1152,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48033){item=Inventory(Actor.Spawn("CaelumWaterRation",(96,-928,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48034){item=Inventory(Actor.Spawn("CaelumFoodRation",(1440,-1152,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48035){item=Inventory(Actor.Spawn("CaelumWaterRation",(1632,-928,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48036){item=Inventory(Actor.Spawn("CaelumFoodRation",(2976,-1152,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48037){item=Inventory(Actor.Spawn("CaelumWaterRation",(3168,-928,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48038){item=Inventory(Actor.Spawn("CaelumFoodRation",(-2400,-4224,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48039){item=Inventory(Actor.Spawn("CaelumWaterRation",(-2208,-4000,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48040){item=Inventory(Actor.Spawn("CaelumFoodRation",(-864,-4224,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48041){item=Inventory(Actor.Spawn("CaelumWaterRation",(-672,-4000,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48042){item=Inventory(Actor.Spawn("CaelumFoodRation",(672,-4224,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48043){item=Inventory(Actor.Spawn("CaelumWaterRation",(864,-4000,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47022){item=Inventory(Actor.Spawn("CaelumMazeSluiceKey",(-2976,-4192,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48044){item=Inventory(Actor.Spawn("CaelumFoodRation",(-3168,-4224,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48045){item=Inventory(Actor.Spawn("CaelumWaterRation",(-2976,-4000,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48046){item=Inventory(Actor.Spawn("CaelumFoodRation",(-2400,-3200,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48047){item=Inventory(Actor.Spawn("CaelumWaterRation",(-2208,-2976,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        return null;
    }
    static Inventory CreateDeathDrop1(int tid)
    {
        Inventory item;
        if(tid==47024){item=Inventory(Actor.Spawn("CaelumArrowAmmo",(-7072,4000,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48048){item=Inventory(Actor.Spawn("CaelumFoodRation",(-7264,3968,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48049){item=Inventory(Actor.Spawn("CaelumWaterRation",(-7072,4192,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47025){item=Inventory(Actor.Spawn("CaelumArrowAmmo",(-7072,1440,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48050){item=Inventory(Actor.Spawn("CaelumFoodRation",(-7264,1408,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48051){item=Inventory(Actor.Spawn("CaelumWaterRation",(-7072,1632,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47026){item=Inventory(Actor.Spawn("CaelumArrowAmmo",(-5024,928,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48052){item=Inventory(Actor.Spawn("CaelumFoodRation",(-5216,896,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48053){item=Inventory(Actor.Spawn("CaelumWaterRation",(-5024,1120,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47027){item=Inventory(Actor.Spawn("CaelumBoltAmmo",(-4000,928,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48054){item=Inventory(Actor.Spawn("CaelumFoodRation",(-4192,896,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48055){item=Inventory(Actor.Spawn("CaelumWaterRation",(-4000,1120,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47028){item=Inventory(Actor.Spawn("CaelumBoltAmmo",(-7072,1952,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48056){item=Inventory(Actor.Spawn("CaelumFoodRation",(-7264,1920,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48057){item=Inventory(Actor.Spawn("CaelumWaterRation",(-7072,2144,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47029){item=Inventory(Actor.Spawn("CaelumArrowAmmo",(-6048,1952,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48058){item=Inventory(Actor.Spawn("CaelumFoodRation",(-6240,1920,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48059){item=Inventory(Actor.Spawn("CaelumWaterRation",(-6048,2144,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47030){item=Inventory(Actor.Spawn("CaelumBoltAmmo",(-5024,1952,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48060){item=Inventory(Actor.Spawn("CaelumFoodRation",(-5216,1920,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48061){item=Inventory(Actor.Spawn("CaelumWaterRation",(-5024,2144,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48062){item=Inventory(Actor.Spawn("CaelumFoodRation",(-4192,1920,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48063){item=Inventory(Actor.Spawn("CaelumWaterRation",(-4000,2144,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48064){item=Inventory(Actor.Spawn("CaelumFoodRation",(-3168,1920,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48065){item=Inventory(Actor.Spawn("CaelumWaterRation",(-2976,2144,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48066){item=Inventory(Actor.Spawn("CaelumFoodRation",(-7264,2944,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48067){item=Inventory(Actor.Spawn("CaelumWaterRation",(-7072,3168,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48068){item=Inventory(Actor.Spawn("CaelumFoodRation",(-6240,2944,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48069){item=Inventory(Actor.Spawn("CaelumWaterRation",(-6048,3168,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48070){item=Inventory(Actor.Spawn("CaelumFoodRation",(-5216,2944,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48071){item=Inventory(Actor.Spawn("CaelumWaterRation",(-5024,3168,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48072){item=Inventory(Actor.Spawn("CaelumFoodRation",(-4192,2944,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48073){item=Inventory(Actor.Spawn("CaelumWaterRation",(-4000,3168,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48074){item=Inventory(Actor.Spawn("CaelumFoodRation",(-3168,2944,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48075){item=Inventory(Actor.Spawn("CaelumWaterRation",(-2976,3168,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47038){item=Inventory(Actor.Spawn("CaelumMazeCryptKey",(-7072,928,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48076){item=Inventory(Actor.Spawn("CaelumFoodRation",(-7264,896,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48077){item=Inventory(Actor.Spawn("CaelumWaterRation",(-7072,1120,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48078){item=Inventory(Actor.Spawn("CaelumFoodRation",(-6240,3968,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48079){item=Inventory(Actor.Spawn("CaelumWaterRation",(-6048,4192,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48080){item=Inventory(Actor.Spawn("CaelumFoodRation",(-5216,3968,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48081){item=Inventory(Actor.Spawn("CaelumWaterRation",(-5024,4192,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48082){item=Inventory(Actor.Spawn("CaelumFoodRation",(-4192,3968,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48083){item=Inventory(Actor.Spawn("CaelumWaterRation",(-4000,4192,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48084){item=Inventory(Actor.Spawn("CaelumFoodRation",(-3168,3968,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48085){item=Inventory(Actor.Spawn("CaelumWaterRation",(-2976,4192,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47043){item=Inventory(Actor.Spawn("CaelumMazeWestCellKey",(-6048,928,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48086){item=Inventory(Actor.Spawn("CaelumFoodRation",(-6240,896,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48087){item=Inventory(Actor.Spawn("CaelumWaterRation",(-6048,1120,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48088){item=Inventory(Actor.Spawn("CaelumFoodRation",(-6240,1408,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48089){item=Inventory(Actor.Spawn("CaelumWaterRation",(-6048,1632,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48090){item=Inventory(Actor.Spawn("CaelumFoodRation",(-5216,1408,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48091){item=Inventory(Actor.Spawn("CaelumWaterRation",(-5024,1632,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48092){item=Inventory(Actor.Spawn("CaelumFoodRation",(-3680,896,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48093){item=Inventory(Actor.Spawn("CaelumWaterRation",(-3488,1120,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48094){item=Inventory(Actor.Spawn("CaelumFoodRation",(-3168,1408,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48095){item=Inventory(Actor.Spawn("CaelumWaterRation",(-2976,1632,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        return null;
    }
    static Inventory CreateDeathDrop2(int tid)
    {
        Inventory item;
        if(tid==47048){item=Inventory(Actor.Spawn("CaelumArrowAmmo",(7264,928,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48096){item=Inventory(Actor.Spawn("CaelumFoodRation",(7072,896,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48097){item=Inventory(Actor.Spawn("CaelumWaterRation",(7264,1120,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47049){item=Inventory(Actor.Spawn("CaelumArrowAmmo",(6240,4000,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48098){item=Inventory(Actor.Spawn("CaelumFoodRation",(6048,3968,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48099){item=Inventory(Actor.Spawn("CaelumWaterRation",(6240,4192,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47050){item=Inventory(Actor.Spawn("CaelumArrowAmmo",(5216,928,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48100){item=Inventory(Actor.Spawn("CaelumFoodRation",(5024,896,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48101){item=Inventory(Actor.Spawn("CaelumWaterRation",(5216,1120,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47051){item=Inventory(Actor.Spawn("CaelumBoltAmmo",(7264,4000,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48102){item=Inventory(Actor.Spawn("CaelumFoodRation",(7072,3968,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48103){item=Inventory(Actor.Spawn("CaelumWaterRation",(7264,4192,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47052){item=Inventory(Actor.Spawn("CaelumArrowAmmo",(7264,1952,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48104){item=Inventory(Actor.Spawn("CaelumFoodRation",(7072,1920,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48105){item=Inventory(Actor.Spawn("CaelumWaterRation",(7264,2144,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47053){item=Inventory(Actor.Spawn("CaelumArrowAmmo",(6240,1952,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48106){item=Inventory(Actor.Spawn("CaelumFoodRation",(6048,1920,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48107){item=Inventory(Actor.Spawn("CaelumWaterRation",(6240,2144,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47054){item=Inventory(Actor.Spawn("CaelumBoltAmmo",(5216,1952,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48108){item=Inventory(Actor.Spawn("CaelumFoodRation",(5024,1920,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48109){item=Inventory(Actor.Spawn("CaelumWaterRation",(5216,2144,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47055){item=Inventory(Actor.Spawn("CaelumBoltAmmo",(4192,1952,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48110){item=Inventory(Actor.Spawn("CaelumFoodRation",(4000,1920,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48111){item=Inventory(Actor.Spawn("CaelumWaterRation",(4192,2144,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48112){item=Inventory(Actor.Spawn("CaelumFoodRation",(2976,1920,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48113){item=Inventory(Actor.Spawn("CaelumWaterRation",(3168,2144,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48114){item=Inventory(Actor.Spawn("CaelumFoodRation",(7072,2944,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48115){item=Inventory(Actor.Spawn("CaelumWaterRation",(7264,3168,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48116){item=Inventory(Actor.Spawn("CaelumFoodRation",(6048,2944,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48117){item=Inventory(Actor.Spawn("CaelumWaterRation",(6240,3168,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48118){item=Inventory(Actor.Spawn("CaelumFoodRation",(5024,2944,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48119){item=Inventory(Actor.Spawn("CaelumWaterRation",(5216,3168,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48120){item=Inventory(Actor.Spawn("CaelumFoodRation",(4000,2944,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48121){item=Inventory(Actor.Spawn("CaelumWaterRation",(4192,3168,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48122){item=Inventory(Actor.Spawn("CaelumFoodRation",(2976,2944,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48123){item=Inventory(Actor.Spawn("CaelumWaterRation",(3168,3168,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47062){item=Inventory(Actor.Spawn("CaelumMazeSanctumKey",(4192,928,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48124){item=Inventory(Actor.Spawn("CaelumFoodRation",(4000,896,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48125){item=Inventory(Actor.Spawn("CaelumWaterRation",(4192,1120,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47063){item=Inventory(Actor.Spawn("CaelumMazeEastCellKey",(6240,928,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48126){item=Inventory(Actor.Spawn("CaelumFoodRation",(6048,896,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48127){item=Inventory(Actor.Spawn("CaelumWaterRation",(6240,1120,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48128){item=Inventory(Actor.Spawn("CaelumFoodRation",(5024,3968,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48129){item=Inventory(Actor.Spawn("CaelumWaterRation",(5216,4192,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48130){item=Inventory(Actor.Spawn("CaelumFoodRation",(4000,3968,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48131){item=Inventory(Actor.Spawn("CaelumWaterRation",(4192,4192,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48132){item=Inventory(Actor.Spawn("CaelumFoodRation",(2976,3968,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48133){item=Inventory(Actor.Spawn("CaelumWaterRation",(3168,4192,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48134){item=Inventory(Actor.Spawn("CaelumFoodRation",(7072,1408,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48135){item=Inventory(Actor.Spawn("CaelumWaterRation",(7264,1632,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48136){item=Inventory(Actor.Spawn("CaelumFoodRation",(6048,1408,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48137){item=Inventory(Actor.Spawn("CaelumWaterRation",(6240,1632,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48138){item=Inventory(Actor.Spawn("CaelumFoodRation",(5024,1408,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48139){item=Inventory(Actor.Spawn("CaelumWaterRation",(5216,1632,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48140){item=Inventory(Actor.Spawn("CaelumFoodRation",(3488,896,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48141){item=Inventory(Actor.Spawn("CaelumWaterRation",(3680,1120,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48142){item=Inventory(Actor.Spawn("CaelumFoodRation",(2976,1408,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48143){item=Inventory(Actor.Spawn("CaelumWaterRation",(3168,1632,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        return null;
    }
    static Inventory CreateDeathDrop3(int tid)
    {
        Inventory item;
        if(tid==47072){item=Inventory(Actor.Spawn("CaelumArrowAmmo",(-928,6048,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48144){item=Inventory(Actor.Spawn("CaelumFoodRation",(-1120,6016,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48145){item=Inventory(Actor.Spawn("CaelumWaterRation",(-928,6240,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47073){item=Inventory(Actor.Spawn("CaelumArrowAmmo",(2144,6048,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48146){item=Inventory(Actor.Spawn("CaelumFoodRation",(1952,6016,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48147){item=Inventory(Actor.Spawn("CaelumWaterRation",(2144,6240,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47074){item=Inventory(Actor.Spawn("CaelumArrowAmmo",(5216,6048,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48148){item=Inventory(Actor.Spawn("CaelumFoodRation",(5024,6016,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48149){item=Inventory(Actor.Spawn("CaelumWaterRation",(5216,6240,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47075){item=Inventory(Actor.Spawn("CaelumBoltAmmo",(7264,6048,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48150){item=Inventory(Actor.Spawn("CaelumFoodRation",(7072,6016,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48151){item=Inventory(Actor.Spawn("CaelumWaterRation",(7264,6240,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47076){item=Inventory(Actor.Spawn("CaelumBoltAmmo",(-928,7072,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48152){item=Inventory(Actor.Spawn("CaelumFoodRation",(-1120,7040,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48153){item=Inventory(Actor.Spawn("CaelumWaterRation",(-928,7264,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47077){item=Inventory(Actor.Spawn("CaelumArrowAmmo",(1120,7072,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48154){item=Inventory(Actor.Spawn("CaelumFoodRation",(928,7040,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48155){item=Inventory(Actor.Spawn("CaelumWaterRation",(1120,7264,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47078){item=Inventory(Actor.Spawn("CaelumBoltAmmo",(3168,7072,0),NO_REPLACE));if(item!=null)item.Amount=20;return item;}
        if(tid==48156){item=Inventory(Actor.Spawn("CaelumFoodRation",(2976,7040,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48157){item=Inventory(Actor.Spawn("CaelumWaterRation",(3168,7264,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48158){item=Inventory(Actor.Spawn("CaelumFoodRation",(5024,7040,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48159){item=Inventory(Actor.Spawn("CaelumWaterRation",(5216,7264,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48160){item=Inventory(Actor.Spawn("CaelumFoodRation",(7072,7040,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48161){item=Inventory(Actor.Spawn("CaelumWaterRation",(7264,7264,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48162){item=Inventory(Actor.Spawn("CaelumFoodRation",(-1120,8064,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48163){item=Inventory(Actor.Spawn("CaelumWaterRation",(-928,8288,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48164){item=Inventory(Actor.Spawn("CaelumFoodRation",(928,8064,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48165){item=Inventory(Actor.Spawn("CaelumWaterRation",(1120,8288,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48166){item=Inventory(Actor.Spawn("CaelumFoodRation",(2976,8064,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48167){item=Inventory(Actor.Spawn("CaelumWaterRation",(3168,8288,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48168){item=Inventory(Actor.Spawn("CaelumFoodRation",(5024,8064,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48169){item=Inventory(Actor.Spawn("CaelumWaterRation",(5216,8288,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48170){item=Inventory(Actor.Spawn("CaelumFoodRation",(-96,6016,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48171){item=Inventory(Actor.Spawn("CaelumWaterRation",(96,6240,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47086){item=Inventory(Actor.Spawn("CaelumMazeNorthKey",(7264,8096,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48172){item=Inventory(Actor.Spawn("CaelumFoodRation",(7072,8064,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48173){item=Inventory(Actor.Spawn("CaelumWaterRation",(7264,8288,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==47087){item=Inventory(Actor.Spawn("CaelumMazeNorthCellKey",(3168,6048,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48174){item=Inventory(Actor.Spawn("CaelumFoodRation",(2976,6016,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48175){item=Inventory(Actor.Spawn("CaelumWaterRation",(3168,6240,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48176){item=Inventory(Actor.Spawn("CaelumFoodRation",(4000,6016,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48177){item=Inventory(Actor.Spawn("CaelumWaterRation",(4192,6240,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48178){item=Inventory(Actor.Spawn("CaelumFoodRation",(6048,6016,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48179){item=Inventory(Actor.Spawn("CaelumWaterRation",(6240,6240,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48180){item=Inventory(Actor.Spawn("CaelumFoodRation",(1952,7040,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48181){item=Inventory(Actor.Spawn("CaelumWaterRation",(2144,7264,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48182){item=Inventory(Actor.Spawn("CaelumFoodRation",(-96,8064,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48183){item=Inventory(Actor.Spawn("CaelumWaterRation",(96,8288,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48184){item=Inventory(Actor.Spawn("CaelumFoodRation",(1952,8064,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48185){item=Inventory(Actor.Spawn("CaelumWaterRation",(2144,8288,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48186){item=Inventory(Actor.Spawn("CaelumFoodRation",(4000,8064,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48187){item=Inventory(Actor.Spawn("CaelumWaterRation",(4192,8288,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48188){item=Inventory(Actor.Spawn("CaelumFoodRation",(6048,8064,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48189){item=Inventory(Actor.Spawn("CaelumWaterRation",(6240,8288,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48190){item=Inventory(Actor.Spawn("CaelumFoodRation",(-1120,6528,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        if(tid==48191){item=Inventory(Actor.Spawn("CaelumWaterRation",(-928,6752,0),NO_REPLACE));if(item!=null)item.Amount=1;return item;}
        return null;
    }
    const RETURN_FLOOR = -160;
    const RETURN_CEILING = -32;
    const RETURN_SPEED = 16;
    const RETURN_ELEVATOR_TAG = 44900;
    static bool IsFloodedReturn(){let marker=ActorIterator.Create(44800,"CaelumMazeLayoutMarker").Next();return level.MapName=="MAP02" && marker!=null && marker.args[0]>=4;}
    static bool IsReturnGrate(int tag){return tag==44910 || tag==44911 || tag==44912 || tag==44913;}
    static bool IsInsideElevator(vector2 p){return p.X>-256 && p.X<256 && p.Y>-256 && p.Y<256;}
    static bool IsGrateExterior(int index,vector2 p)
    {
        if(index==0)return p.Y<=-288;
        if(index==1)return p.X<=-288;
        if(index==2)return p.X>=288;
        if(index==3)return p.Y>=288;
        return false;
    }
    static int PitEntrance(int trap)
    {
        if(trap==43916)return 44700;
        if(trap==43925)return 44701;
        if(trap==43929)return 44701;
        if(trap==43930)return 44701;
        if(trap==43933)return 44701;
        return 0;
    }
    static vector3 BossEscapePosition(){return (-5888,8832,-16);}
}
