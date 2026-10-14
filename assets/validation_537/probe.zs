// Pruebas de producción sobre actores y geometría reales; los teletransportes
// sólo preparan cada caso y no equivalen a aceptación de recorrido manual.
class CA234Probe : StaticEventHandler
{
    int Failures;
    Actor Service;
    String ExpectedId;
    void Check(bool ok,String label)
    {if(!ok)Failures++;Console.Printf("CA234 %s %s",ok?"PASS":"FAIL",label);}
    void Move(CaelumPlayer user,Vector3 pos)
    {user.SetOrigin(pos,false);user.Vel=(0,0,0);CaelumWorldProgress.Update(user);}
    bool Known(CaelumPersistentCharacterState record,String id)
    {return CaelumPoiKnowledge.Find(record,level.MapName,id)!=null;}
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name=="c234_close")while(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();
        if(e.Name=="c234_done")Console.Printf("CA234 DONE failures=%d",Failures);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[e.Player].mo);if(user==null)return;
        let record=user.GetPersistentCharacterState(false);if(record==null)return;
        if(e.Name=="c234_release")
        {
            user.ClosePalomoMerchant();user.CloseCraftingStationSession();
            user.SetCraftingJournalState(false);CaelumJourneyPlan.Cancel(user);
        }
        if(e.Name=="c234_markers")
        {
            int facts=0,markers=0;
            for(int i=0;i<record.KnownPois.Size();i++)if(record.KnownPois[i].MapId==level.MapName)facts++;
            let it=ThinkerIterator.Create("CaelumKnownPoiMarker");CaelumKnownPoiMarker marker;
            while((marker=CaelumKnownPoiMarker(it.Next()))!=null)if(!marker.bDormant)markers++;
            Check(facts==markers,"derived-markers-match-only-current-map-facts");
        }
        if(e.Name=="c234_empty")
        {
            Check(record.KnownPois.Size()==0,"world-preparation-does-not-reveal-catalogue");
            Check(record.LocalKnowledgeRevision==2,"empty-revision-two-migration");
            Check(!CaelumMapNoteData.ValidCategory(CaelumPoiData.ROOM),"manual-note-categories-remain-six");
        }
        if(e.Name=="c234_native_grate")
        {
            Service=ActorIterator.Create(44700,"CaelumMazeBarredGate").Next();
            ExpectedId="maze-grate-44700";
            Move(user,Service.Pos+(64,0,0));user.Angle=180;user.Pitch=0;
            Check(!Known(record,ExpectedId),"native-grate-unknown-before-input");
        }
        if(e.Name=="c234_native_gate")
        {
            let port=CaelumPortSiege.Get();Service=port.Gates[0];
            ExpectedId=String.Format("port-r%d-gate-0",port.args[0]);
            Move(user,Service.Pos+(0,64,0));user.Angle=270;user.Pitch=0;
            Check(!Known(record,ExpectedId),"native-city-gate-unknown-before-input");
        }
        if(e.Name=="c234_rooms")
        {
            Move(user,(0,400,0));
            Check(Known(record,"mansion-room-workshop-rulo"),"ground-workshop-entry");
            Check(!Known(record,"mansion-room-bedroom-rulo"),"ground-does-not-discover-upper-bedroom");
            Check(!Known(record,"mansion-room-workshop-ronnie"),"other-workshop-unknown-before-entry");
            Move(user,(736,400,0));
            Check(Known(record,"mansion-room-workshop-ronnie"),"east-side-door-strip-is-room-interior");
            Check(!Known(record,"mansion-room-bedroom-ronnie"),"east-side-door-does-not-discover-upper-bedroom");
            Move(user,(-400,400,136));
            Check(Known(record,"mansion-room-bedroom-rulo"),"upper-bedroom-entry");
            Check(!Known(record,"mansion-bed-101"),"bedroom-entry-does-not-discover-bed");
            Move(user,(0,0,264));Check(Known(record,"mansion-room-upper-workshop"),"second-floor-entry");
            int before=record.KnownPois.Size();
            Move(user,(1800,-330,0));Move(user,(1890,-330,0));Move(user,(1917,316,-384));
            Check(record.KnownPois.Size()==before,"secret-and-stacked-cave-add-no-annotation");
            String checksum=record.CartographyChecksum;record.CartographyChecksum="legacy-unrecognized";
            Move(user,(1000,-450,136));
            Check(!Known(record,"mansion-room-bedroom-argento"),"unknown-layout-does-not-use-current-room-bounds");
            record.CartographyChecksum=checksum;
            Move(user,(-400,400,136));
        }
        if(e.Name=="c234_bed")
        {
            Service=CaelumRestFurnitureTrial.Find(101);ExpectedId="mansion-bed-101";
            Check(Service!=null,"actual-mansion-bed-exists-after-startup");
            Move(user,Service.Pos+(0,-72,0));user.Angle=90;user.Pitch=20;
            Check(!Known(record,ExpectedId),"bed-stays-unknown-before-native-use");
        }
        if(e.Name=="c234_station")
        {
            user.ClosePalomoMerchant();user.CloseCraftingStationSession();
            let it=ThinkerIterator.Create("CaelumCraftingStation");CaelumCraftingStation station;
            while((station=CaelumCraftingStation(it.Next()))!=null)
                if(station.CraftingRoomGroup==1 && station.GetCraftingStationType()==CaelumConstants.CRAFTING_STATION_WORKBENCH)
                {Service=station;break;}
            ExpectedId="mansion-station-1-4";
            Check(Service!=null,"actual-mansion-workbench-exists");
            Move(user,Service.Pos+(0,-80,0));user.Angle=90;user.Pitch=0;
            Check(!Known(record,ExpectedId),"station-stays-unknown-before-native-use");
        }
        if(e.Name=="c234_used")
        {
            Check(Service!=null && Known(record,ExpectedId),"native-use-recorded-"..ExpectedId);
            let fact=CaelumPoiKnowledge.Find(record,level.MapName,ExpectedId);
            Check(fact!=null && fact.ObservedPosition==Service.Pos,"observed-position-is-actual-service");
        }
        if(e.Name=="c234_grates")
        {
            let gate=CaelumMazeBarredGate(ActorIterator.Create(44700,"CaelumMazeBarredGate").Next());
            Check(gate!=null,"real-west-section-grate");if(gate==null)return;
            Check(!gate.Opened && Known(record,"maze-grate-44700"),"native-input-remembers-locked-grate");
            Check(!gate.Open(user),"missing-key-keeps-native-lock");
            let fact=CaelumPoiKnowledge.Find(record,level.MapName,"maze-grate-44700");
            Check(fact!=null && fact.ObservedAccess==CaelumPoiData.ACCESS_CLOSED,"blocked-use-remembers-closed-grate");
            Check(record.KnownPois.Size()==1,"blocked-use-does-not-reveal-other-grates");
            gate.Opened=true;gate.ApplyOpening();
            Check(fact.ObservedAccess==CaelumPoiData.ACCESS_CLOSED,"remote-change-does-not-update-personal-observation");
            gate.Open(user);
            Check(fact.ObservedAccess==CaelumPoiData.ACCESS_OPEN,"repeat-use-observes-open-grate");
            Move(user,gate.Pos+(96,0,0));user.Angle=180;
        }
        if(e.Name=="c234_return_grate")
        {
            let gate=CaelumMazeReturnGrate(ActorIterator.Create(44910,"CaelumMazeReturnGrate").Next());
            Check(gate!=null,"existing-lower-return-grate");
            Move(user,(0,-192,0));gate.UseReturn(user);
            Check(!Known(record,"maze-return-44910"),"upper-elevator-control-does-not-reveal-hidden-lower-grate");
            Move(user,(0,-320,-160));gate.UseReturn(user);
            let fact=CaelumPoiKnowledge.Find(record,level.MapName,"maze-return-44910");
            Check(fact!=null && fact.ObservedAccess==2 && fact.ObservedPosition==gate.Pos,"lower-use-observes-real-open-return-grate");
            Check(!Known(record,"maze-return-44911"),"using-one-return-does-not-reveal-other-return-grates");
            Move(user,(-1440,0,0));user.Angle=180;
        }
        if(e.Name=="c234_city")
        {
            Check(CaelumCityData.Enabled(),"current-city-controller");
            let port=CaelumPortSiege.Get();Check(port!=null && port.Gates.Size()==8,"existing-eight-physical-gates");
            for(int i=0;i<8;i++)
            {
                let gate=port.Gates[i];Move(user,gate.Pos+(-Sin(gate.Angle)*80,Cos(gate.Angle)*80,0));
                int old=gate.args[2];gate.args[2]=0;
                Check(!gate.Used(user),String.Format("gate-%d-access-still-blocked",i));gate.args[2]=old;
                Check(Known(record,String.Format("port-r%d-gate-%d",port.args[0],i)),String.Format("gate-%d-individually-known",i));
            }
            Check(!Known(record,"city-east-exit"),"east-arch-unknown-before-crossing");
            Move(user,(576,576,0));Move(user,(1152,576,0));
            Check(Known(record,"city-east-exit"),"east-arch-known-after-crossing");
            for(int i=0;i<4;i++)
            {
                Check(!Known(record,String.Format("city-tower-%d",i)),String.Format("tower-%d-unknown-before-entry",i));
                // El primer caso entra sobre el parapeto real de 400 MU.
                Move(user,i==0?(-30072,15808,400):CaelumCartographyCatalogueData.TowerPosition(i));
                Check(Known(record,String.Format("city-tower-%d",i)),String.Format("tower-%d-known-after-entry",i));
            }
            let vendor=CaelumCityMerchant.Find(0);
            Check(vendor!=null,"actual-city-vendor");
            CaelumPoiKnowledge.RecordUse(user,vendor,CaelumPoiData.MERCHANT);
            Check(Known(record,"city-shop-0"),"city-vendor-stable-identity");
            Check(!Known(record,"city-shop-1"),"other-shop-still-unknown");
            let bed=CaelumRestFurnitureTrial.Find(CaelumCityData.FURNITURE_SLOT_BASE);
            CaelumPoiKnowledge.RecordUse(user,bed,CaelumPoiData.BED);
            Check(Known(record,"city-bed-0"),"city-bed-stable-identity");
            let cart=CaelumTravelVehicle(CaelumVehicleWorld.Find("CaelumCoveredCart"));
            Move(user,cart.BoardingPoint);cart.Board(user);
            Check(Known(record,"port-covered-cart"),"existing-cart-known-even-when-route-disabled");
            let ship=CaelumTravelVehicle(CaelumVehicleWorld.Find("CaelumMerchantShip"));
            Move(user,ship.BoardingPoint);ship.Board(user);
            Check(Known(record,"port-merchant-ship"),"existing-ship-known-even-when-route-disabled");
            Move(user,(576,576,0));
        }
        if(e.Name=="c234_reload")
        {
            Check(record.LocalKnowledgeRevision==2,"reloaded-revision-two");
            if(level.MapName=="MAP01")Check(Known(record,"mansion-bed-101") && Known(record,"mansion-station-1-4"),"reloaded-mansion-services");
            if(level.MapName=="MAP02")
            {
                let fact=CaelumPoiKnowledge.Find(record,level.MapName,"maze-grate-44700");
                Check(fact!=null && fact.ObservedAccess==2,"reloaded-grate-observation");
            }
            if(level.MapName=="MAP06")Check(Known(record,"city-east-exit") && Known(record,"port-merchant-ship"),"reloaded-city-facts");
            int serial=record.LocalKnowledgeSerial;CaelumPoiKnowledge.Ensure(record);CaelumPoiKnowledge.Ensure(record);
            Check(serial==record.LocalKnowledgeSerial,"reloaded-migration-idempotent");
        }
        if(e.Name=="c234_legacy_geometry")
        {
            Console.Printf("CA234 LEGACY CHECKSUM %s",level.GetChecksum());
            Check(level.GetChecksum()!=CaelumCartographyCatalogueData.MAP01_CHECKSUM,"loaded-old-geometry-checksum");
            Move(user,(-300,400,0));Move(user,(-400,400,136));Move(user,(0,0,264));
            Check(!Known(record,"mansion-room-workshop-rulo") && !Known(record,"mansion-room-bedroom-rulo")
                && !Known(record,"mansion-room-upper-workshop"),"old-geometry-does-not-gain-current-room-regions");
        }
        if(e.Name=="c234_migrated")
        {
            Check(record.LocalKnowledgeRevision==2,"genuine-536-save-migrates-to-two");
            Check(record.KnownPois.Size()==0,"old-map-visit-does-not-infer-local-discoveries");
            Check(record.ManualNotes.Size()==1,"old-manual-note-preserved");
        }
        if(e.Name=="c234_hub")
        {
            let fact=CaelumPoiKnowledge.Find(record,"MAP02","maze-grate-44700");
            Check(fact!=null && fact.ObservedAccess==2,"hub-keeps-original-grate-observation");
            if(level.MapName=="MAP04")
                Check(CaelumPoiKnowledge.Find(record,"MAP04","maze-grate-44700")==null,"other-map-does-not-copy-place-identity");
            if(level.MapName=="MAP02")
            {
                let gate=CaelumMazeBarredGate(ActorIterator.Create(44700,"CaelumMazeBarredGate").Next());
                Check(gate!=null && gate.Opened,"native-hub-keeps-opened-gate");
            }
        }
        if(e.Name=="c234_legacy_city")
        {
            let port=CaelumPortSiege.Get();
            Check(port!=null && !CaelumCityData.Enabled(),"legacy-port-controller-keeps-own-layout");
            Check(level.GetChecksum()!=CaelumCartographyCatalogueData.MAP06_CHECKSUM,"legacy-city-geometry-checksum");
            let gate=port.Gates[0];Move(user,gate.Pos+(0,64,0));
            CaelumPoiKnowledge.RecordUse(user,gate,CaelumPoiData.EXIT);
            let fact=CaelumPoiKnowledge.Find(record,level.MapName,String.Format("port-r%d-gate-0",port.args[0]));
            Check(fact!=null && fact.ObservedPosition==gate.Pos && fact.NameKey=="CA_POI_PORT_GATE_LEGACY","legacy-gate-uses-real-position-and-neutral-name");
            Check(!Known(record,"city-tower-0") && !Known(record,"city-east-exit"),"legacy-port-does-not-gain-current-city-landmarks");
        }
        if(e.Name=="c234_done")Console.Printf("CA234 DONE failures=%d",Failures);
    }
}
