// Controlador pasivo solo del ensayo: los seis carriles antiguos no representan
// los tres frentes nuevos. El mapa distribuido conserva su controlador real.
class CA454PassiveCity : CaelumPortSiege
{
    override void Tick()
    {
        if(SetupRevision>0 || !CaelumCityWorld.Prepare())return;
        CaelumHouseResidents.Get(true).PrepareCity(self);SetupRevision=3;
        RentalAgent=CaelumRentalAgent(Spawn("CaelumRentalAgent",CaelumPortQuestData.AgentPosition(),NO_REPLACE));
        RentalAgentRevision=CaelumPortQuestData.REVISION;
    }
}
class CA454CandidateProbe : EventHandler
{
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca454_inside"){CaelumDeadTraveler.ChangeMap("CAH069",0,CHANGELEVEL_NOINTERMISSION);return;}
        if(e.Name=="ca454_outside"){CaelumDeadTraveler.ChangeMap("MAP03",70,CHANGELEVEL_NOINTERMISSION);return;}
        if(e.Name!="ca454_candidate" && e.Name!="ca454_candidate_return")return;
        let user=CaelumPlayerAuthority.FromNetworkPlayer(e.Player);int failed=0;
        if(user==null || !user.CharacterCreationComplete){Console.Printf("CA454 CANDIDATE FAIL missing player");return;}
        user.bInvulnerable=true;
        let arrival=CaelumArrivalHousehold.Get(false);int identities=0;
        if(arrival==null || arrival.Entries.Size()!=4)failed++;
        else for(int i=0;i<arrival.Entries.Size();i++)
        {
            let row=arrival.Entries[i];identities|=1<<row.Index;
            vector3 target=CaelumCityData.HouseOrigin(69)+CaelumArrivalHouseholdData.Offset(row.Index);
            bool ok=row.Body!=null && !row.Body.bDestroyed && row.Body.GetClassName()==CaelumArrivalHouseholdData.Kind(row.Index)
                && (row.Position-target).Length()<1 && row.Parked==(level.MapName=="MAP03");
            if(level.MapName=="CAH069" && row.Body!=null)ok=ok && (row.Body.Pos-target).Length()<1;
            if(!ok){failed++;Console.Printf("CA454 CANDIDATE ARRIVAL FAIL item=%d parked=%d",row.Index,row.Parked);}
        }
        if(identities!=15)failed++;
        if(level.MapName=="CAH069")
        {
            if(CaelumBarracasData.IsCurrent())failed++;
            if((CaelumCityData.ChestPosition(69)-CaelumCityData.HouseOrigin(69)-(864,832,0)).Length()>0.01)failed++;
            Console.Printf("CA454 CANDIDATE %s map=CAH069 failures=%d",failed==0?"PASS":"FAIL",failed);return;
        }
        let port=CaelumPortSiege.Get();
        if(port==null || port.SetupRevision==0 || !CaelumBarracasData.IsCurrent())failed++;
        for(int i=0;i<160;i++)
        {
            if((CaelumCityData.DoorOutside(i)-CaelumBarracasData.DoorOutside(i)).Length()>0.01)failed++;
            if((CaelumCityData.ChestPosition(i)-CaelumCityData.HouseOrigin(i)-(864,832,0)).Length()>0.01)failed++;
        }
        int vendors=0;
        // Censo tipado solo al pedir el informe, limitado a los64 comercios.
        let it=ThinkerIterator.Create("CaelumCityMerchant");CaelumCityMerchant vendor;
        while((vendor=CaelumCityMerchant(it.Next()))!=null)
        {
            vendors++;
            bool fit=vendor.TestMobjLocation() && Abs(vendor.Pos.Z-vendor.FloorZ)<1;
            if(!fit || (vendor.Pos-CaelumBarracasData.ShopPosition(vendor.ShopIdentity)).Length()>1)
            {failed++;Console.Printf("CA454 CANDIDATE VENDOR FAIL id=%d pos=(%.1f,%.1f,%.1f) floor=%.1f",vendor.ShopIdentity,vendor.Pos.X,vendor.Pos.Y,vendor.Pos.Z,vendor.FloorZ);}
        }
        if(vendors!=64)failed++;
        Array<CaelumCraftingStation> stations;
        let si=ThinkerIterator.Create("CaelumCraftingStation");CaelumCraftingStation station;
        while((station=CaelumCraftingStation(si.Next()))!=null)stations.Push(station);
        for(int i=0;i<CA454FactoryExpected.COUNT;i++)
        {
            int matches=0;
            for(uint j=0;j<stations.Size();j++)
            {
                let body=stations[j];
                if(body.GetClassName()!=CA454FactoryExpected.Kind(i) || (body.Pos-CA454FactoryExpected.Point(i)).Length()>1)continue;
                matches++;
                if(!body.TestMobjLocation() || Abs(body.Pos.Z-body.FloorZ)>1){failed++;Console.Printf("CA454 CANDIDATE FACTORY FAIL index=%d kind=%s",i,body.GetClassName());}
            }
            if(matches!=1){failed++;Console.Printf("CA454 CANDIDATE FACTORY COUNT FAIL index=%d count=%d",i,matches);}
        }
        if(e.Name=="ca454_candidate_return" && (user.Pos-CaelumBarracasData.DoorOutside(69)).Length()>1)failed++;
        if(port!=null && (port.RentalAgent==null || !port.RentalAgent.TestMobjLocation()))failed++;
        int vehicles=0;
        let vi=ThinkerIterator.Create("CaelumTravelVehicle");CaelumTravelVehicle vehicle;
        while((vehicle=CaelumTravelVehicle(vi.Next()))!=null)
        {
            vehicles++;
            if(!vehicle.Ready){failed++;Console.Printf("CA454 CANDIDATE VEHICLE FAIL %s",vehicle.GetClassName());}
        }
        if(vehicles!=4)failed++;
        Console.Printf("CA454 CANDIDATE %s map=MAP03 failures=%d vendors=%d vehicles=%d factory_stations=%d return_distance=%.1f",failed==0?"PASS":"FAIL",failed,vendors,vehicles,CA454FactoryExpected.COUNT,(user.Pos-CaelumBarracasData.DoorOutside(69)).Length());
    }
}
