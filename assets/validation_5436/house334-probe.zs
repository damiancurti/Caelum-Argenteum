// Diagnóstico aislado: Use atraviesa el portal real y conserva el autosave.
class CA334Probe : CA282Probe
{
    ui int TraceFrames;
    ui double LastFrame;
    bool LoadedSave;
    override void WorldLoaded(WorldEvent e)
    {
        Console.Printf("CA334 LOAD map=%s save=%d",level.MapName,e.IsSaveGame);
        LoadedSave=e.IsSaveGame;
    }
    override void InterfaceProcess(ConsoleEvent e)
    {
        if(e.Name=="c334_loaded_ui")
        {
            let audio=CaelumMenuAudio(StaticEventHandler.Find("CaelumMenuAudio"));
            EventHandler.SendNetworkEvent("c334_loaded_ui_result",audio!=null && audio.VehicleArrival?1:0);
        }
        if(e.Name=="ca_map_depart" || e.Name=="ca_map_arrive")
        {
            Console.Printf("CA334 EVENT name=%s arg0=%d arg1=%d map=%s",e.Name,e.Args[0],e.Args[1],level.MapName);
            if(e.Name=="ca_map_arrive"){TraceFrames=60;LastFrame=0;}
        }
    }
    override void RenderOverlay(RenderEvent e)
    {
        if(TraceFrames<=0)return;
        let audio=CaelumMenuAudio(StaticEventHandler.Find("CaelumMenuAudio"));
        double now=MSTimeF();
        if(audio!=null)Console.Printf("CA334 FRAME map=%s left=%d dt=%.3f wipe=%d arrival=%d count=%d snapshots=%d pending=%d",
            level.MapName,TraceFrames,LastFrame==0?0:now-LastFrame,audio.TravelWipe,audio.VehicleArrival,
            audio.ArrivalFrames,audio.SnapshotFrames,audio.TravelPresentationPending);
        LastFrame=now;TraceFrames--;
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        Super.NetworkProcess(e);
        if(e.Name=="c334_seed")
        {
            Setup();let record=User.GetPersistentCharacterState(true);
            record.DemoNarrativeDelivered=2047;record.DemoNarrativePending=0;
            Console.Printf("CA334 SETTINGS wipe=%d tally=%d",CVar.FindCVar("wipetype").GetInt(),CVar.FindCVar("sv_alwaystally").GetInt());
        }
        if(e.Name=="c334_position")
        {
            User=CaelumPlayer(players[consoleplayer].mo);
            let it=ThinkerIterator.Create("CaelumHousePortal");CaelumHousePortal door;
            while((door=CaelumHousePortal(it.Next()))!=null)if(door.args[0]==e.Args[0])break;
            Check(door!=null,"physical house portal exists");if(door==null)return;
            double side=door.args[1]==0?1:-1;
            User.SetOrigin(door.Pos+(side*User.UseRange/2,0,0),false);
            User.FindFloorCeiling();User.Vel=(0,0,0);User.Angle=side>0?180:0;User.Pitch=0;
            User.FolkloreInteractionUseLatched=false;
            Check(CaelumUseGeometry.AimedAt(User,door),"physical Use is in range and aimed");
            Console.Printf("CA334 BEFORE map=%s pendingwipe=%d",level.MapName,User.PendingTravelWipe);
        }
        if(e.Name=="c334_inside")Check(level.MapName==CaelumHouseHubData.MapName(e.Args[0]),"Use enters expected interior");
        if(e.Name=="c334_outside")Check(level.MapName=="MAP03","Use returns to current city");
        if(e.Name=="c334_loaded")
        {
            User=CaelumPlayer(players[consoleplayer].mo);
            Check(LoadedSave,"native autosave loading callback actually ran");
            Check(level.MapName==(e.Args[0]==0?"CAH000":"MAP03"),"autosave restores its actual destination map");
            Check(User!=null && User.health>0 && User.CharacterCreationComplete
                && User.GetPersistentCharacterState(false)!=null,"autosave restores live committed character");
            EventHandler.SendInterfaceEvent(consoleplayer,"c334_loaded_ui");
        }
        if(e.Name=="c334_loaded_ui_result")Check(e.Args[0]==0,"loaded autosave has no inherited vehicle overlay");
    }
}
