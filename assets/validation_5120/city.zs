class CA173City : StaticEventHandler
{
    int Age;
    bool Loaded;
    CaelumHingedDoorLeaf Door;
    static void Check(bool ok,String label){Console.Printf("CA173 %s %s",ok?"PASS":"FAIL",label);}
    static int Leaves(bool interior)
    {
        int count=0;let it=ThinkerIterator.Create("CaelumHingedDoorLeaf");CaelumHingedDoorLeaf leaf;
        while((leaf=CaelumHingedDoorLeaf(it.Next()))!=null)
            if((leaf.args[0]>=CaelumCityData.INTERIOR_DOOR_GROUP_BASE)==interior)count++;
        return count;
    }
    static CaelumHingedDoorLeaf FindDoor(int opening)
    {
        let it=ThinkerIterator.Create("CaelumHingedDoorLeaf");CaelumHingedDoorLeaf leaf;
        while((leaf=CaelumHingedDoorLeaf(it.Next()))!=null)
            if(leaf.args[0]==CaelumCityData.InteriorDoorGroup(0,opening))return leaf;
        return null;
    }
    static vector2 DoorXY(int door){vector3 p=CaelumCityData.InteriorDoorCenter(0,door);return p.XY;}
    override void WorldLoaded(WorldEvent e){Age=0;Loaded=e.IsSaveGame;}
    override void WorldTick()
    {
        Age++;let u=CaelumPlayer(players[0].mo);if(u==null || !u.CharacterCreationComplete)return;
        let r=u.GetPersistentCharacterState(true);r.DemoNarrativeDelivered=2047;r.DemoNarrativePending=0;
        let port=CaelumPortSiege.Get();
        if(Age==100)
        {
            Check(port!=null && port.InteriorDoorRevision==1,"interior door revision installed");
            Check(Leaves(true)==640 && Leaves(false)==320,"320 interior openings and 160 entrance pairs");
            Check(port.Defenders.Size()==600 && port.Attackers.Size()==0 && !port.SiegeStarted,"peaceful roster unchanged");
            if(Loaded){Console.Printf("CA173 CITY_RELOAD_DONE");return;}
            Door=FindDoor(0);vector3 center=CaelumCityData.InteriorDoorCenter(0,0);
            u.SetOrigin(center+(48,0,0),false);u.Vel=(0,0,0);u.Angle=180;u.Pitch=0;
        }
        if(Loaded)return;
        if(Age==110)
        {
            Console.Printf("CA173 DOOR user=(%.1f,%.1f,%.1f) leaf=(%.1f,%.1f,%.1f) closed=(%.1f,%.1f,%.1f) axis=%d side=%d solid=%d sight=%d radius=%.1f height=%.1f progress=%d",u.Pos.X,u.Pos.Y,u.Pos.Z,Door.Pos.X,Door.Pos.Y,Door.Pos.Z,Door.ClosedPosition.X,Door.ClosedPosition.Y,Door.ClosedPosition.Z,Door.args[2],Door.args[1],Door.bSolid,u.CheckSight(Door),u.Radius,u.Height,Door.SlideProgress);
            Check(!u.CheckMove(DoorXY(0),PCM_DROPOFF),"closed bedroom door blocks native movement");
            Check(Door!=null && Door.Used(u),"bedroom door opens through native Use hook");
        }
        if(Age==135)
        {
            Check(Door.SlideProgress==64,"bedroom door completes hinge animation");
            Check(u.TryMove(DoorXY(0),true),"native collision permits crossing open bedroom door");
            u.SetOrigin(CaelumCityData.InteriorDoorCenter(0,1)+(0,-48,0),false);u.Vel=(0,0,0);u.Angle=90;
            Door=FindDoor(1);
        }
        if(Age==150)
        {
            Check(!u.CheckMove(DoorXY(1),PCM_DROPOFF),"closed bathroom door blocks native movement");
            Check(Door!=null && Door.Used(u),"bathroom door opens through native Use hook");
        }
        if(Age==175)
        {
            Check(Door.SlideProgress==64 && u.TryMove(DoorXY(1),true),"native collision permits crossing open bathroom door");
            u.SetOrigin(CaelumCityData.BedPosition(0)+(64,0,0),false);u.Vel=(0,0,0);
        }
        if(Age==190)
        {
            Check(CaelumCityWorld.Peaceful() && CaelumTimeAdvanceState.InSafeZone(u),"peaceful MAP06 is safe for time skip");
            Check(CaelumTimeSkipRules.FindFurniture(u,true)!=null,"bed in same home is accessible across internal door");
            let other=Actor.Spawn("CaelumTimeAdvanceZone",CaelumCityData.BedPosition(1));
            Check(!CaelumTimeSkipRules.Accessible(u,other),"other house supplies and furniture are not globally shared");
            u.SetOrigin(CaelumCityData.HouseRoad(0),false);u.Vel=(0,0,0);
        }
        if(Age==205)
        {
            String reason=CaelumTimeSkipRules.BlockReason(u);Console.Printf("CA173 SKIP_REASON %s",reason);
            Check(reason.Length()==0 && CaelumTimeSkipState.OpenMenu(u),"native skip opens from peaceful street");
            let skip=CaelumTimeSkipState.Get(u);if(skip==null)return;
            Check(CaelumTimeSkipState.Start(u),"native time skip starts");
            CaelumTimeSkipState.Pump(u);
            Check(skip.ElapsedTics>0,"native skip advances actual clock and resources");
            CaelumTimeSkipState.FinishSkip(u,"CA_SKIP_CANCELLED",true);
            Check(!skip.Active && skip.ElapsedTics>0,"cancel keeps elapsed simulation");
            Console.Printf("CA173 CITY_DONE");
        }
    }
}
