// Pruebas aisladas: nunca se empaquetan en src ni alteran campañas del autor.
class CA487Blocker : Actor
{
    Default { Radius 30; Height 72; +SOLID +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
}

class CA487Checks : StaticEventHandler
{
    int Passed,Failed;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA487 %s %s",ok?"PASS":"FAIL",label);}
    void Result(){Console.Printf("CA487 RESULT passed=%d failed=%d map=%s",Passed,Failed,level.MapName);}
    int Count(Name kind)
    {int n=0;let it=ThinkerIterator.Create(kind);while(it.Next()!=null)n++;return n;}
    CaelumFermentationStation Barrel()
    {let it=ThinkerIterator.Create('CaelumFermentationStation');return CaelumFermentationStation(it.Next());}
    CaelumFermentationRoster Roster()
    {let it=ThinkerIterator.Create('CaelumFermentationRoster');return CaelumFermentationRoster(it.Next());}
    int Scan(CaelumPlayer u,CaelumCraftingStation s)
    {s.CollectCraftingNetwork(u,u.BeginCraftingNetworkScan());return u.CraftingNetworkCapabilities;}
    void Placement(CaelumPlayer u)
    {
        let b=Barrel();Check(b!=null,"barrel installed");if(b==null){Result();return;}
        Check(Count('CaelumFermentationStation')==1,"one barrel per approved map");
        Check(Count('CaelumFermentationRoster')==1,"one persistent barrel roster");
        Check(Count('CaelumAlchemyStation')==1,"existing Chemistry preserved");
        Check((b.Pos-CaelumFermentationData.Position(level.MapName)).Length()<.01,"approved placement");
        Check(b.Radius==30 && b.Height==72 && b.Scale.X==.75,"approved dimensions and scale");
        Check(b.bSolid,"new barrel has solid collision");
        Check(b.TestMobjLocation() && Abs(b.FloorZ-b.Pos.Z)<1,"collision and floor fit");
        Check(b.args[0]==0 && !b.CanBePushedWith(100000),"fixed barrel");
        Check(b.CraftingRoomGroup==CaelumFermentationData.Group(level.MapName),"approved workshop group");
        Check(CaelumCraftingRules.GetMissingFermentationStation(Scan(u,b))==CaelumConstants.CRAFTING_STATION_NONE,"network reaches Chemistry and Workbench");
        let r=Roster();Check(r!=null && r.Issued && r.Revision==1 && r.PendingStation==null,"idempotent revision-1 installation committed");
        Vector3 old=u.Pos;int access=0;
        for(int i=0;i<4;i++)
        {u.SetOrigin(b.Pos+(cos(i*90)*64,sin(i*90)*64,0),false);if(u.TestMobjLocation() && b.CanReachFrom(u))access++;}
        u.SetOrigin(old,false);Check(access>=1,"clear reachable approach");
        Check(CaelumFermentationData.WORKING_CAPACITY_LITERS==3402,"approved derived working capacity");
        Check(CaelumFermentationData.INTERIOR_CAPACITY_LITERS>4252 && CaelumFermentationData.INTERIOR_CAPACITY_LITERS<4253,"derived internal volume");
        Console.Printf("CA487 ACCESS clear_sides=%d",access);Result();
    }
    void Network(CaelumPlayer u)
    {
        let b=CaelumFermentationStation(Actor.Spawn('CaelumFermentationStation',(224,0,0),NO_REPLACE));
        let w=CaelumWorkbenchStation(Actor.Spawn('CaelumWorkbenchStation',(112,0,0),NO_REPLACE));
        let c=CaelumAlchemyStation(Actor.Spawn('CaelumAlchemyStation',(0,0,0),NO_REPLACE));
        b.CraftingRoomGroup=487;w.CraftingRoomGroup=487;c.CraftingRoomGroup=487;
        u.SetOrigin((224,-64,0),false);u.CharacterCreationComplete=true;
        int full=Scan(u,b);
        Check(CaelumCraftingRules.GetMissingFermentationStation(full)==-1,"transitive Chemistry connection through Workbench");
        u.OpenCraftingNetwork(b);Check(u.CraftingMenuOpen && u.ActiveCraftingStationActor==b,"connected barrel opens ordinary catalogue");
        c.CraftingRoomGroup=488;u.CraftingSessionValidationTics=0;
        Check(!u.RefreshActiveCraftingStationSession(false) && !u.CraftingMenuOpen,"disconnect closes barrel session");
        Scan(u,b);u.OpenCraftingNetwork(b);Check(!u.CraftingMenuOpen,"different-room Chemistry cannot operate barrel");
        c.CraftingRoomGroup=487;c.SetOrigin((-32,0,0),false);
        Scan(u,b);u.OpenCraftingNetwork(b);Check(!u.CraftingMenuOpen,"out-of-link Chemistry cannot operate barrel");
        c.SetOrigin((0,0,0),false);w.CraftingRoomGroup=488;
        Scan(u,b);u.OpenCraftingNetwork(b);Check(!u.CraftingMenuOpen,"missing Workbench remains blocked");
        w.CraftingRoomGroup=487;Scan(u,b);u.OpenCraftingNetwork(b);Check(u.CraftingMenuOpen,"restored network reopens barrel");
        Check(CaelumCraftingRules.GetStationRecipeCount(13)==0,"no invented fermentation recipes");
        Check(CaelumCraftingRules.StationAccessAllowed(12,0),"existing Chemistry access policy unchanged");
        Check(CaelumCraftingRules.GetStationCapabilityBit(13)==8192 && CaelumCraftingRules.GetStationCapabilityBit(12)==4096,"append-only station capability");
        u.CloseCraftingStationSession();u.SetCraftingJournalState(false);b.Destroy();w.Destroy();c.Destroy();Result();
    }
    void Author(CaelumPlayer u)
    {
        let b=Barrel();if(b==null){Check(false,"barrel exists for author scene");Result();return;}
        u.bInvulnerable=true;u.Vel=(0,0,0);u.SetOrigin(b.Pos+(0,-64,0),false);u.Angle=90;u.Pitch=0;
        u.CloseCraftingStationSession();u.SetCraftingJournalState(false);
        Console.Printf("CA487 AUTHOR E: use; Q: close; F1/F2: MAP01/MAP03; F3/F4: save/load; F5/F6: disconnect/reconnect Chemistry; F7/F8: English/Spanish.");Result();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        if(e.Name=="ca487_placement")Placement(u);
        if(e.Name=="ca487_network")Network(u);
        if(e.Name=="ca487_author")Author(u);
        if(e.Name=="ca487_side" || e.Name=="ca487_back")
        {
            let b=Barrel();bool side=e.Name=="ca487_side";
            u.SetOrigin(b.Pos+(side?(96,0,0):(0,96,0)),false);
            u.Angle=side?180:270;u.Pitch=0;
        }
        if(e.Name=="ca487_collision")
        {
            let b=Barrel();Check(u.Pos.Y<=b.Pos.Y-b.Radius-u.Radius+1,"real forward input stops at barrel collision");
            Check((b.Pos-CaelumFermentationData.Position(level.MapName)).Length()<.01,"forward input cannot move fixed barrel");Result();
        }
        if(e.Name=="ca487_use")
        {Check(u.CraftingMenuOpen && u.ActiveCraftingStationActor==Barrel(),"real Use opens barrel");Result();}
        if(e.Name=="ca487_remove"){let b=Barrel();if(b!=null)b.Destroy();}
        if(e.Name=="ca487_removed"){Check(Count('CaelumFermentationStation')==0 && Roster().Issued,"removed barrel is not reissued");Result();}
        if(e.Name=="ca487_block")
        {
            let b=Barrel();if(b!=null)b.Destroy();let r=Roster();r.Issued=false;r.Revision=0;
            Actor.Spawn('CA487Blocker',CaelumFermentationData.Position(level.MapName),NO_REPLACE);
        }
        if(e.Name=="ca487_blocked")
        {Check(!Roster().Issued && Roster().Revision==0 && Count('CA487Blocker')==1,"blocked installation preserves obstacle and waits");Result();}
        if(e.Name=="ca487_unblock")
        {let it=ThinkerIterator.Create('CA487Blocker');let b=Actor(it.Next());if(b!=null)b.Destroy();}
        if(e.Name=="ca487_disconnect" || e.Name=="ca487_reconnect")
        {
            let it=ThinkerIterator.Create('CaelumAlchemyStation');let c=CaelumAlchemyStation(it.Next());
            if(c!=null)c.CraftingRoomGroup=e.Name=="ca487_disconnect"?487:CaelumAlchemyData.Group(level.MapName);
        }
    }
}
