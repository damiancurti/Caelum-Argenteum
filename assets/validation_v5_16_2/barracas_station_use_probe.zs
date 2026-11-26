// Acceso normal a las 96 estaciones existentes, con geometria y red reales.
class CA454StationUseCity : CaelumPortSiege
{
    override void Tick()
    {
        if(SetupRevision>0 || !CaelumCityWorld.Prepare())return;
        CaelumHouseResidents.Get(true).PrepareCity(self);SetupRevision=3;
    }
}
class CA454StationUseProbe : EventHandler
{
    CaelumCraftingStation Current;
    int Opened,Failures;
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca454_station_aim" && e.Name!="ca454_station_check" && e.Name!="ca454_station_report")return;
        let user=CaelumPlayer(players[0].mo);
        if(e.Name=="ca454_station_report")
        {
            user.CloseCraftingStationSession();user.SetCraftingJournalState(false);
            Console.Printf("CA454 STATION COMPLETE %s opened=%d failures=%d",Opened==CA454FactoryExpected.COUNT && Failures==0?"PASS":"FAIL",Opened,Failures);return;
        }
        int index=e.Args[0];
        if(e.Name=="ca454_station_check")
        {
            bool okay=Current!=null && user.CraftingMenuOpen && user.ActiveCraftingStationActor==Current;
            if(okay)Opened++;else Failures++;
            Console.Printf("CA454 STATION USE %s id=%d kind=%s capabilities=%d",okay?"PASS":"FAIL",index,Current!=null?Current.GetClassName():'None',user.CraftingNetworkCapabilities);return;
        }
        user.CloseCraftingStationSession();user.SetCraftingJournalState(false);user.CraftingStationUseLatched=false;
        user.GetPersistentCharacterState(true).MagicBoxOwned=true;user.MagicBoxOwned=true;user.bInvulnerable=true;
        Current=null;let it=ThinkerIterator.Create("CaelumCraftingStation");CaelumCraftingStation station;
        while((station=CaelumCraftingStation(it.Next()))!=null)
            if(station.GetClassName()==CA454FactoryExpected.Kind(index) && (station.Pos-CA454FactoryExpected.Point(index)).Length()<1)
            {Current=station;break;}
        if(Current==null){Failures++;Console.Printf("CA454 STATION FAIL missing id=%d",index);return;}
        bool fit=false;
        for(int side=0;side<8;side++)
        {
            double angle=Current.Angle+side*45;
            user.SetOrigin(Current.Pos+(Cos(angle),Sin(angle),0)*64,false);user.FindFloorCeiling();
            user.Angle=angle+180;user.Pitch=VectorAngle(64,user.ViewHeight-Current.Height/2);
            user.Vel=(0,0,0);user.ClearInterpolation();
            fit=user.TestMobjLocation() && Current.CanReachFrom(user) && CaelumUseGeometry.AimedAt(user,Current);
            if(fit)break;
        }
        if(!fit){Failures++;Console.Printf("CA454 STATION FAIL standing space id=%d",index);}
    }
}
