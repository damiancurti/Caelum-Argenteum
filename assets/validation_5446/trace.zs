// Observacion privada del viaje real, sin cambiar la presentacion.
class CA353Performance : EventHandler
{
    int Age,StartTic;
    bool SeedReady,Started,Finished;
    CaelumPortSiege Port;
    Array<CaelumCombatActor> Bodies;
    Array<double> Stamps;
    ui double LastFrame;
    ui Array<double> FrameMS,FrameTimes;
    ui Array<int> FrameTics;
    ui bool Flushed;
}
class CA334NativeTrace : StaticEventHandler
{
    override bool InputProcess(InputEvent e){return true;}
    ui int BeforeFrames,AfterFrames;
    ui bool Queued,Arrived;
    ui bool SawActiveArrival;
    ui double QueuedTime,LastTime;
    bool InterruptArrival;
    int Passes,Failures;
    void Check(bool value,String label)
    {if(value)Passes++;else{Failures++;Console.Printf("CA282 FAIL %s",label);}}
    override void InterfaceProcess(ConsoleEvent e)
    {
        if(e.Name=="c334_assert_observed")EventHandler.SendNetworkEvent("c334_observed_result",SawActiveArrival?1:0);
        if(e.Name=="ca_house_capture_begin" || e.Name=="ca_house_capture_cancel" || e.Name=="ca_vehicle_wipe_visible")
        {
            let audio=CaelumMenuAudio(StaticEventHandler.Find("CaelumMenuAudio"));
            Console.Printf("CA334 PRESENT name=%s arg=%d map=%s snapshots=%d house=%d suspended=%d globalwipe=%d",e.Name,e.Args[0],level.MapName,audio.SnapshotFrames,audio.HouseArrival,audio.CaptureSuspended,CVar.FindCVar("wipetype").GetInt());
        }
        if(e.Name=="c334_queued")
        {Queued=true;Arrived=false;BeforeFrames=0;QueuedTime=MSTimeF();Console.Printf("CA334 QUEUED map=%s",level.MapName);}
        if(e.Name=="ca_map_depart" && Queued)
            Console.Printf("CA334 DEPART map=%s frames=%d elapsed=%.6f",level.MapName,BeforeFrames,MSTimeF()-QueuedTime);
        if(e.Name=="ca_map_arrive" && Queued)
        {
            Arrived=true;AfterFrames=0;Console.Printf("CA334 ARRIVE map=%s frames=%d elapsed=%.6f",level.MapName,BeforeFrames,MSTimeF()-QueuedTime);
            let audio=CaelumMenuAudio(StaticEventHandler.Find("CaelumMenuAudio"));
            if(e.Args[0]==0 && audio.HousePresentationActive && audio.HouseArrived)SawActiveArrival=true;
            if(InterruptArrival && level.MapName=="MAP03")EventHandler.SendNetworkEvent("c334_interrupt");
        }
    }
    override void RenderOverlay(RenderEvent e)
    {
        if(!Queued)return;
        if(!Arrived)BeforeFrames++;
        else if(AfterFrames++<5)
            Console.Printf("CA334 AFTER map=%s frame=%d gap=%.6f tic=%d",level.MapName,AfterFrames,MSTimeF()-LastTime,level.time);
        LastTime=MSTimeF();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let audio=CaelumMenuAudio(StaticEventHandler.Find("CaelumMenuAudio"));
        let user=CaelumPlayer(players[0].mo);
        if(e.Name=="c334_lifecycle_controls")
        {
            let door=CaelumHousePortal(ThinkerIterator.Create("CaelumHousePortal").Next());
            Check(audio.RequestHouseDoor(user,door),"first request starts");int serial=audio.HouseRequest;
            Check(!audio.RequestHouseDoor(user,door) && audio.HouseRequest==serial,"duplicate request cannot replace the active serial");
            Check(user.PendingTravelWipe==0,"capture does not prepare player travel state");
            int hp=user.health;user.health=0;audio.WorldTick();user.health=hp;
            Check(!audio.HousePresentationActive && audio.PendingHousePortal==null,"death cancels pending capture");
            Check(audio.RequestHouseDoor(user,door),"new request after cancellation starts");
            audio.NewGame();
            Check(!audio.HousePresentationActive && !audio.CaptureSuspended,"NewGame callback releases capture");
            Console.Printf("CA282 DONE passes=%d failures=%d",Passes,Failures);
        }
        if(e.Name=="c334_pending_check")Check(audio.HousePresentationActive && !audio.HouseTravelCommitted,"actual native save starts while capture is pending");
        if(e.Name=="c334_arrival_check")EventHandler.SendInterfaceEvent(consoleplayer,"c334_assert_observed");
        if(e.Name=="c334_observed_result")Check(e.Args[0]==1,"native arrival was active before interruption");
        if(e.Name=="c334_interrupt_enabled")InterruptArrival=true;
        if(e.Name=="c334_interrupt")
        {
            Check(audio.HousePresentationActive && audio.HouseArrived,"second transition starts during house arrival");
            InterruptArrival=false;
            Level.ChangeLevel("CAH009",0,CHANGELEVEL_NOINTERMISSION);
        }
        if(e.Name=="c334_cancel_checked")
        {
            String expected=e.Args[0]==0?"CAH008":e.Args[0]==1?"MAP03":"CAH009";
            Check(level.MapName==expected,"load/cancel retains expected map");
            Check(!audio.HousePresentationActive && !audio.HouseTravelCommitted && !audio.HouseArrived,"load/cancel clears play transition ownership");
            Check(audio.PendingHousePortal==null && audio.PendingHouseUser==null && !audio.CaptureSuspended,"load/cancel releases references and camera");
            Check(user.PendingTravelWipe==0,"load/cancel leaves no pending player wipe");
            Console.Printf("CA282 DONE passes=%d failures=%d",Passes,Failures);
        }
        if(e.Name=="c334_position")
        {
            let it=ThinkerIterator.Create("CaelumHousePortal");CaelumHousePortal door;
            while((door=CaelumHousePortal(it.Next()))!=null)if(door.args[0]==8)break;
            if(user==null || door==null){Console.Printf("CA282 FAIL missing door/player");return;}
            double side=door.args[1]==0?1:-1;
            user.SetOrigin(door.Pos+(side*user.UseRange/2,0,0),false);
            user.FindFloorCeiling();user.Vel=(0,0,0);user.Angle=side>0?180:0;user.Pitch=0;
            user.FolkloreInteractionUseLatched=false;
            Console.Printf("CA334 POSITION map=%s aimed=%d",level.MapName,CaelumUseGeometry.AimedAt(user,door));
        }
        if(e.Name=="c334_done")
        {
            if(level.MapName=="MAP03" && !audio.HousePresentationActive && !audio.CaptureSuspended)Console.Printf("CA282 DONE passes=1 failures=0");
            else Console.Printf("CA282 FAIL wrong destination %s",level.MapName);
        }
    }
}
