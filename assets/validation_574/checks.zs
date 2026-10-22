// Diagnóstico aislado de #470: nunca se distribuye dentro de src.
class CA470Blocker : Actor
{
    Default { Radius 30; Height 72; +SOLID +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
}

class CA470Checks : StaticEventHandler
{
    int Passed,Failed;
    override void UiTick()
    {
        let menu=Menu.GetCurrentMenu();
        if(menu is "ConversationMenu")
        {
            ConversationMenu.SendConversationReply(-1,0);
            menu.Close();
        }
    }
    void Check(bool ok,String label)
    {
        if(ok)Passed++;else Failed++;
        Console.Printf("CA470 %s %s",ok?"PASS":"FAIL",label);
    }
    void Result()
    {
        Console.Printf("CA470 RESULT passed=%d failed=%d map=%s",Passed,Failed,level.MapName);
    }
    int Count(Name kind)
    {
        int count=0;let it=ThinkerIterator.Create(kind);
        while(it.Next()!=null)count++;
        return count;
    }
    CaelumCraftingStation Station(Name kind,Vector3 pos,int group=470)
    {
        let s=CaelumCraftingStation(Actor.Spawn(kind,pos,NO_REPLACE));
        s.CraftingRoomGroup=group;
        return s;
    }
    int Scan(CaelumPlayer u,CaelumCraftingStation s)
    {
        s.CollectCraftingNetwork(u,u.BeginCraftingNetworkScan());
        return u.CraftingNetworkCapabilities;
    }
    void Network(CaelumPlayer u)
    {
        int wb=CaelumCraftingRules.GetStationCapabilityBit(CaelumConstants.CRAFTING_STATION_WORKBENCH);
        int al=CaelumCraftingRules.GetStationCapabilityBit(CaelumConstants.CRAFTING_STATION_ALCHEMY);
        int forge=CaelumCraftingRules.GetStationCapabilityBit(CaelumConstants.CRAFTING_STATION_FORGE);
        Check(wb==16 && al==4096,"old capability bits retained; Alchemy appended");
        Check(CaelumCraftingRules.GetMissingAlchemyStation(0)==CaelumConstants.CRAFTING_STATION_WORKBENCH,"empty network requires Workbench");
        Check(CaelumCraftingRules.GetMissingAlchemyStation(al)==CaelumConstants.CRAFTING_STATION_WORKBENCH,"Alchemy alone requires Workbench");
        Check(CaelumCraftingRules.GetMissingAlchemyStation(wb)==CaelumConstants.CRAFTING_STATION_ALCHEMY,"Workbench alone requires Alchemy");
        Check(CaelumCraftingRules.GetMissingAlchemyStation(wb|al)==CaelumConstants.CRAFTING_STATION_NONE,"combined network satisfies prerequisite");
        let a=Station('CaelumWorkbenchStation',(0,0,0));
        let b=Station('CaelumAlchemyStation',(128,0,0));
        let c=Station('CaelumForgeStation',(256,0,0));
        Check(Scan(u,a)==(wb|al|forge),"inclusive boundary and transitive network");
        b.SetOrigin((128.01,0,0),false);
        Check(Scan(u,a)==wb,"beyond 128 excludes disconnected subnetwork");
        b.SetOrigin((128,0,0),false);b.CraftingRoomGroup=471;
        Check(Scan(u,a)==wb,"different room group excludes nearby station");
        b.CraftingRoomGroup=470;b.SetOrigin((0,0,128),false);
        Check(Scan(u,a)==(wb|al),"elevated station exactly 128 units joins");
        b.SetOrigin((0,0,128.01),false);
        Check(Scan(u,a)==wb,"vertical distance beyond 128 excludes");
        b.SetOrigin((90,0,90),false);
        Check(Scan(u,a)==(wb|al),"diagonal inside spherical boundary joins");
        b.SetOrigin((91,0,91),false);
        Check(Scan(u,a)==wb,"diagonal outside spherical boundary excludes");
        b.SetOrigin((64,0,0),false);c.SetOrigin((96,0,0),false);
        Check(Scan(u,a)==(wb|al|forge),"cycle terminates with all capabilities");
        double start=Object.MSTimeF();
        for(int i=0;i<1000;i++)Scan(u,a);
        Console.Printf("CA470 TIMING three_station_network_1000_ms=%.6f",Object.MSTimeF()-start);
        Check(CaelumCraftingRules.GetStationRecipeCount(CaelumConstants.CRAFTING_STATION_ALCHEMY)==0,"no unauthored standalone Alchemy recipe");
        a.Destroy();b.Destroy();c.Destroy();Result();
    }
    void Placement(CaelumPlayer u)
    {
        Check(Count('CaelumAlchemyStation')==1,"one authored station");
        Check(Count('CaelumAlchemyRoster')==1,"one persistent map roster");
        let it=ThinkerIterator.Create('CaelumAlchemyStation');
        let a=CaelumAlchemyStation(it.Next());
        if(a==null){Result();return;}
        Vector3 expected=CaelumAlchemyData.Position(level.MapName);
        Check((a.Pos-expected).Length()<.01,"approved position retained");
        Check(a.Radius==30 && a.Height==72 && a.Scale.X==.75,"approved 60x60x72 collision and scale");
        Check(a.TestMobjLocation() && Abs(a.FloorZ-a.Pos.Z)<1,"station fits geometry and floor");
        Check(a.args[0]==0 && !a.CanBePushedWith(100000),"station remains fixed");
        Check(a.CraftingRoomGroup==CaelumAlchemyData.Group(level.MapName),"approved workshop group");
        Check(CaelumCraftingRules.GetMissingAlchemyStation(Scan(u,a))==CaelumConstants.CRAFTING_STATION_NONE,"authored network reaches Workbench");
        let ri=ThinkerIterator.Create('CaelumAlchemyRoster');let r=CaelumAlchemyRoster(ri.Next());
        Check(r!=null && r.Issued && r.Revision==1 && r.PendingStation==null,"installation committed at revision 1");
        Console.Printf("CA470 PLACEMENT x=%.2f y=%.2f z=%.2f floor=%.2f network=%d",a.Pos.X,a.Pos.Y,a.Pos.Z,a.FloorZ,u.CraftingNetworkCapabilities);
        // Probar las cuatro aproximaciones locales con la colisión del jugador.
        Vector3 previous=u.Pos;
        int access=0;
        for(int side=0;side<4;side++)
        {
            double angle=side*90;
            u.SetOrigin(a.Pos+(cos(angle)*64,sin(angle)*64,0),false);
            if(u.TestMobjLocation() && a.CanReachFrom(u))access++;
        }
        u.SetOrigin(previous,false);
        Check(access>=1,"at least one clear reachable side");
        Console.Printf("CA470 ACCESS clear_sides=%d",access);
        double start=MSTimeF();
        for(int i=0;i<1000;i++)
        {
            let lookup=ThinkerIterator.Create('CaelumAlchemyRoster');lookup.Next();
        }
        Console.Printf("CA470 TIMING roster_lookup_1000_ms=%.6f",MSTimeF()-start);
        Result();
    }
    void Author(CaelumPlayer u)
    {
        let it=ThinkerIterator.Create('CaelumAlchemyStation');let a=CaelumAlchemyStation(it.Next());
        if(a==null){Console.Printf("CA470 FAIL no station for author scene");return;}
        u.bInvulnerable=true;u.Vel=(0,0,0);
        u.DebugSetAllCraftingRecipesKnown(true);
        // Orientación de prueba, sin alterar posiciones de producción.
        u.SetOrigin(a.Pos+(-48,-48,0),false);u.Angle=45;u.Pitch=0;
        u.CloseCraftingStationSession();
        Console.Printf("CA470 AUTHOR E: open station; Q: close. F1: MAP01; F2: MAP03; F3: save; F4: load.");
        Result();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        if(e.Name=="ca470_network")Network(u);
        if(e.Name=="ca470_placement")Placement(u);
        if(e.Name=="ca470_author")Author(u);
        if(e.Name=="ca470_remove")
        {
            let it=ThinkerIterator.Create('CaelumAlchemyStation');let a=Actor(it.Next());
            if(a!=null)a.Destroy();
        }
        if(e.Name=="ca470_removed")
        {
            Check(Count('CaelumAlchemyStation')==0,"removed station is not reissued");Result();
        }
        if(e.Name=="ca470_use")
        {
            Console.Printf("CA470 VIEW player=(%.2f,%.2f,%.2f) camera_self=%d",u.Pos.X,u.Pos.Y,u.Pos.Z,u.player.camera==u);
            Check(u.CraftingMenuOpen && u.ActiveCraftingStationActor is 'CaelumAlchemyStation',"real Use opens shared Workbench catalogue from Alchemy");Result();
        }
        if(e.Name=="ca470_block")
        {
            let it=ThinkerIterator.Create('CaelumAlchemyStation');let a=Actor(it.Next());
            if(a!=null)a.Destroy();
            let ri=ThinkerIterator.Create('CaelumAlchemyRoster');let r=CaelumAlchemyRoster(ri.Next());
            r.Issued=false;r.Revision=0;
            Actor.Spawn('CA470Blocker',CaelumAlchemyData.Position(level.MapName),NO_REPLACE);
        }
        if(e.Name=="ca470_blocked")
        {
            let ri=ThinkerIterator.Create('CaelumAlchemyRoster');let r=CaelumAlchemyRoster(ri.Next());
            Check(r!=null && !r.Issued && r.Revision==0,"blocked installation remains uncommitted");
            Check(Count('CA470Blocker')==1,"existing obstacle is preserved");Result();
        }
        if(e.Name=="ca470_unblock")
        {
            let it=ThinkerIterator.Create('CA470Blocker');let b=Actor(it.Next());if(b!=null)b.Destroy();
        }
    }
}
