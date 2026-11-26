// Diagnostico de los registros nativos; la colocacion sustituye el recorrido.
class CA454CartographyProbe : EventHandler
{
    int Failures;
    bool Completed;
    void Check(bool okay,String label)
    {
        if(!okay){Failures++;Console.Printf("CA454 CARTOGRAPHY FAIL %s",label);}
    }
    CaelumPoiRegistration Bound(Actor subject)
    {
        let it=ThinkerIterator.Create("CaelumPoiRegistration");CaelumPoiRegistration entry;
        while((entry=CaelumPoiRegistration(it.Next()))!=null)if(entry.Subject==subject)return entry;
        return null;
    }
    void Observe(CaelumPlayer user,vector3 point)
    {
        user.SetOrigin(point,false);user.Vel=(0,0,0);user.FindFloorCeiling();
        CaelumAuthoredCartography.Update(user,user.GetPersistentCharacterState(true));
    }
    void Verify(CaelumPlayer user)
    {
        let record=user.GetPersistentCharacterState(true);
        Check(Completed,"saved completion");
        Check(CaelumCartographyCatalogueData.MatchesCityGeometry(level.GetChecksum()),"loaded geometry admitted");
        for(int i=0;i<CA454DiscoveryExpected.STATIONS;i++)
        {
            let fact=CaelumPoiKnowledge.Find(record,level.MapName,CA454DiscoveryExpected.StationId(i));
            Check(i==0?fact!=null:fact==null,"only used station known");
            if(i==0 && fact!=null)Check(fact.ObservedPosition==CA454DiscoveryExpected.Station(i),"station position persists");
        }
        for(int i=0;i<CA454DiscoveryExpected.STAIRS;i++)
            Check(CaelumPoiKnowledge.Find(record,level.MapName,CaelumBattleRouteData.Id(i+1))!=null,"visited stair persists");
        for(int i=0;i<4;i++)
        {
            let fact=CaelumPoiKnowledge.Find(record,level.MapName,String.Format("city-tower-%d",i));
            Check(fact!=null && fact.ObservedPosition==CA454DiscoveryExpected.Tower(i),"tower identity/position persists");
        }
        let east=CaelumPoiKnowledge.Find(record,level.MapName,"city-east-exit");
        Check(east!=null && east.ObservedPosition==CA454DiscoveryExpected.East(),"east crossing persists");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca454_discovery_start" && e.Name!="ca454_discovery_resume")return;
        let user=CaelumPlayer(players[0].mo);let record=user.GetPersistentCharacterState(true);
        if(e.Name=="ca454_discovery_start")
        {
            user.CharacterCreationComplete=true;user.CreationWizardOpen=false;record.ProfileCommitted=true;user.bInvulnerable=true;
            Check(CaelumBarracasData.IsCurrent()==CA454DiscoveryExpected.REVISED,"geometry revision");
            Check(CaelumCartographyCatalogueData.MatchesCityGeometry(level.GetChecksum()),"fresh geometry admitted");
            int before=record.KnownPois.Size();CaelumCraftingStation first;
            for(int i=0;i<CA454DiscoveryExpected.STATIONS;i++)
            {
                CaelumCraftingStation found;let it=ThinkerIterator.Create("CaelumCraftingStation");CaelumCraftingStation station;
                while((station=CaelumCraftingStation(it.Next()))!=null)
                    if(station.SpawnPoint==CA454DiscoveryExpected.Station(i)){found=station;break;}
                Check(found!=null,"map station exists");if(found==null)continue;
                if(i==0)first=found;
                CaelumAuthoredCartography.BindSubject(found,CaelumPoiData.STATION);
                let binding=Bound(found);
                Check(binding!=null && binding.PoiId==CA454DiscoveryExpected.StationId(i),"native binding retains station ID");
                CaelumAuthoredCartography.BindSubject(found,CaelumPoiData.STATION);
                Check(Bound(found)==binding,"binding idempotence");
                Check(CaelumPoiKnowledge.Find(record,level.MapName,CA454DiscoveryExpected.StationId(i))==null,"binding does not discover station");
            }
            Check(before==record.KnownPois.Size(),"registration reveals no locations");
            Check(first!=null && CaelumPoiKnowledge.RecordUse(user,first,CaelumPoiData.STATION),"one native use record");
            for(int i=0;i<CA454DiscoveryExpected.STAIRS;i++)
            {
                Check(CaelumPoiKnowledge.Find(record,level.MapName,CaelumBattleRouteData.Id(i+1))==null,"stair unknown before visit");
                Observe(user,CA454DiscoveryExpected.Stair(i));
                Check(CaelumPoiKnowledge.Find(record,level.MapName,CaelumBattleRouteData.Id(i+1))!=null,"stair records visited step");
            }
            for(int i=0;i<4;i++)
            {
                Check(CaelumPoiKnowledge.Find(record,level.MapName,String.Format("city-tower-%d",i))==null,"tower unknown before visit");
                Observe(user,CA454DiscoveryExpected.Tower(i));
            }
            vector3 east=CA454DiscoveryExpected.East();
            Observe(user,east-(CaelumPortData.ROUTE_RADIUS,0,0));
            Check(CaelumPoiKnowledge.Find(record,level.MapName,"city-east-exit")==null,"east unknown before crossing");
            Observe(user,east+(CaelumPortData.ROUTE_RADIUS,0,0));
            Completed=true;
        }
        Verify(user);
        int before=record.KnownPois.Size();
        CaelumAuthoredCartography.Update(user,record);
        Check(before==record.KnownPois.Size(),"repeat observation does not duplicate");
        Console.Printf("CA454 CARTOGRAPHY %s phase=%s revised=%d stations=%d stairs=%d towers=4 failures=%d known=%d",
            Failures==0?"PASS":"FAIL",e.Name,CA454DiscoveryExpected.REVISED,CA454DiscoveryExpected.STATIONS,CA454DiscoveryExpected.STAIRS,Failures,record.KnownPois.Size());
    }
}
