// Board/Confirm y portal son reales; sólo la aproximación final se adelanta.
class CA334VehicleProbe : CA334Probe
{
    CaelumTravelVehicle Vehicle;
    CaelumHousePortal Door;
    int Stage,SequenceBefore,Mode;
    bool Early,Fixed;
    ui bool RequestedConfirm,RequestedDoor,CapturedHouse;
    ui int SawVehicleFrames,SawHouseFrames,VisibleWipe;
    ui bool SawHouseOverlay;

    override void RenderOverlay(RenderEvent e)
    {
        Super.RenderOverlay(e);
        let audio=CaelumMenuAudio(StaticEventHandler.Find("CaelumMenuAudio"));
        if(audio==null)return;
        if(Stage==1 && level.MapName=="TCOAST" && audio.SnapshotMap=="TCOAST"
            && audio.SnapshotFrames>=2 && !RequestedConfirm)
        {RequestedConfirm=true;EventHandler.SendNetworkEvent("c334_confirm");}
        if(level.MapName=="MAP03" && audio.VehicleArrival)
        {
            SawVehicleFrames++;
            if(Early && !RequestedDoor)
            {
                RequestedDoor=true;
                Console.Printf("CA334 VEHICLE_ARRIVAL wipe=%d frame=%d snapshots=%d",audio.TravelWipe,audio.ArrivalFrames,audio.SnapshotFrames);
                EventHandler.SendNetworkEvent("c334_early_house");
            }
        }
        if(level.MapName=="CAH158")
        {
            SawHouseFrames++;SawHouseOverlay=SawHouseOverlay || audio.VehicleArrival;
            if(!CapturedHouse)
            {
                CapturedHouse=true;
                Console.Printf("CA334 FIRST_HOUSE_OVERLAY active=%d frame=%d wipe=%d",audio.VehicleArrival,audio.ArrivalFrames,audio.TravelWipe);
            }
        }
    }

    override void InterfaceProcess(ConsoleEvent e)
    {
        Super.InterfaceProcess(e);
        let audio=CaelumMenuAudio(StaticEventHandler.Find("CaelumMenuAudio"));
        if(e.Name=="c334_before_house" && audio!=null)
        {
            Console.Printf("CA334 PRE_RESET active=%d frames=%d wipe=%d",audio.VehicleArrival,audio.ArrivalFrames,audio.TravelWipe);
            EventHandler.SendNetworkEvent("c334_enter_house",audio.VehicleArrival?1:0,audio.ArrivalFrames,audio.TravelWipe);
        }
        if(e.Name=="ca_vehicle_wipe_visible")VisibleWipe=e.Args[0];
        if(e.Name=="c334_report")EventHandler.SendNetworkEvent("c334_report_values",SawVehicleFrames,SawHouseFrames,SawHouseOverlay?1:0);
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        Super.NetworkProcess(e);
        if(e.Name=="c334_vehicle_seed")
        {
            Setup();Manual=true;Early=e.Args[1]!=0;Fixed=e.Args[2]!=0;Mode=e.Args[0];
            User.PersistCharacterState();CaelumWorldClock.Get(User,true);
            let record=User.GetPersistentCharacterState(true);record.DemoNarrativeDelivered=2047;record.DemoNarrativePending=0;
            User.CurrentHunger=User.CurrentThirst=100;
            Give('CaelumFoodRation',200);Give('CaelumWaterRation',200);User.OnNativeInventoryChanged();
            let it=ThinkerIterator.Create("CaelumTravelVehicle");
            while((Vehicle=CaelumTravelVehicle(it.Next()))!=null)if(Vehicle.TravelMode()==Mode)break;
            Check(Vehicle!=null && Vehicle.Ready,"existing prepared vehicle is available");if(Vehicle==null)return;
            User.SetOrigin(Vehicle.BoardingPoint,false);User.FindFloorCeiling();User.Vel=(0,0,0);
            let journey=CaelumJourneyState.Get(User);SequenceBefore=journey!=null?journey.Sequence:0;
            Console.Printf("CA334 START mode=%d day=%d position=%.3f,%.3f,%.3f",Mode,CaelumTimeSkipState.NowDay(User),User.Pos.X,User.Pos.Y,User.Pos.Z);
        }
        if(e.Name=="c334_board")
        {
            Console.Printf("CA334 BOARD can=%d rule=%s ground=%d water=%d",CaelumTravelService.CanDepart(User,11),CaelumJourneyRules.BlockReason(User),User.player.onground,User.WaterLevel);
            Check(Vehicle!=null && Vehicle.Board(User),"native vehicle Board opens journey preview");
            let plan=CaelumJourneyPlan.Get(User);
            Check(plan!=null && plan.Open && plan.SourceVehicle==Vehicle && plan.ConnectionId==11 && plan.TravelMode==Mode,"preview binds actual vehicle and coast-to-city route");
            if(plan!=null && plan.Open)
            {
                Check(plan.Available!=null && plan.Available.Health>0,"ordinary provision forecast survives journey");
                Stage=1;
            }
        }
        if(e.Name=="c334_confirm")
        {
            Check(CaelumJourneyPlan.Confirm(User),"native journey confirmation commits the trip");Stage=2;
        }
        if(e.Name=="c334_early_house")
        {
            User=CaelumPlayer(players[consoleplayer].mo);
            let journey=CaelumJourneyState.Get(User);let record=User.GetPersistentCharacterState(false);
            Console.Printf("CA334 BEFORE_POSITION status=%d pending=%d wipe=%d",journey!=null?journey.Status:-1,record.WorldPendingConnection,User.PendingTravelWipe);
            Check(journey!=null && journey.Status==CaelumJourneyState.STATUS_ARRIVED && journey.Sequence==SequenceBefore+1 && record.WorldPendingConnection==0,"journey arrival resolved natively exactly once");
            let it=ThinkerIterator.Create("CaelumHousePortal");
            while((Door=CaelumHousePortal(it.Next()))!=null)if(Door.args[0]==158 && Door.args[1]==0)break;
            Check(Door!=null,"nearest authored house portal exists");if(Door==null)return;
            User.SetOrigin(Door.Pos+(User.UseRange/2,0,0),false);User.FindFloorCeiling();
            User.Vel=(0,0,0);User.Angle=180;User.Pitch=0;User.FolkloreInteractionUseLatched=false;
            EventHandler.SendInterfaceEvent(consoleplayer,"c334_before_house");
        }
        if(e.Name=="c334_enter_house")
        {
            Check(e.Args[0]!=0 && e.Args[1]<35 && e.Args[2]==(Mode==CaelumJourneyState.MODE_SHIP?1:3),"pre-reset UI observes incomplete authentic vehicle presentation");
            Check(Door!=null && CaelumUseGeometry.AimedAt(User,Door) && Door.Used(User),"real house portal accepts the accelerated diagnostic approach");Stage=3;
        }
        if(e.Name=="c334_vehiclecheck")EventHandler.SendInterfaceEvent(consoleplayer,"c334_report");
        if(e.Name=="c334_report_values")
        {
            Check(e.Args[0]>0,"native vehicle arrival overlay was rendered");
            if(Early)
            {
                Check(level.MapName=="CAH158" && e.Args[1]>0,"journey then house arrival completed");
                Check(Fixed?e.Args[2]==0:e.Args[2]!=0,Fixed?"house entry clears inherited vehicle overlay":"baseline retains previous vehicle overlay inside house");
            }
            Console.Printf("CA282 DONE passes=%d failures=%d",Passed,Failed);
        }
    }
}
