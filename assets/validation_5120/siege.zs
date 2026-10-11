class CA173Siege : StaticEventHandler
{
    int Age;
    bool BoundarySeen;
    double Due;
    static void Check(bool ok,String label){Console.Printf("CA173 %s %s",ok?"PASS":"FAIL",label);}
    override void WorldTick()
    {
        Age++;let u=CaelumPlayer(players[0].mo);if(u==null || !u.CharacterCreationComplete)return;
        let port=CaelumPortSiege.Get();let r=u.GetPersistentCharacterState(true);
        r.DemoNarrativeDelivered=2047;r.DemoNarrativePending=0;
        if(Age==150){u.SetOrigin(CaelumCityData.HouseRoad(0),false);u.Vel=(0,0,0);}
        if(Age==160)
        {
            let clock=CaelumWorldClock.Get(u);let calendar=CaelumCalendarState.Get(u);
            int day=CaelumCityWorld.SiegeDay(),tics=CaelumCityData.SIEGE_HOUR*CaelumWorldClock.TicsPerHour();
            Check(calendar.SetAnchor(clock,day,tics-64,false),"fixture anchors 64 tics before existing siege date");
            port.Calendar(u);CaelumScheduleState.Sync(u);
            Due=CaelumScheduleRules.Stamp(day,tics);
            Check(CaelumCityWorld.Peaceful(),"city still peaceful before exact boundary");
            Check(CaelumTimeSkipState.OpenMenu(u),"skip menu opens immediately before siege");
            let skip=CaelumTimeSkipState.Get(u);if(skip==null)return;
            skip.TargetDay=day;skip.TargetTics=tics+CaelumWorldClock.TicsPerHour();skip.UseTaskDefault=false;
            Check(CaelumTimeSkipState.Start(u),"explicit target beyond siege starts");
            CaelumTimeSkipState.Pump(u);
            Console.Printf("CA173 BOUNDARY due=%.0f now=%.0f elapsed=%d reason=%s",Due,CaelumScheduleState.Now(u),skip.ElapsedTics,skip.LastReason);
            Check(!skip.Active && skip.LastReason=="CA_EVENT_SIEGE_INTERRUPT","siege automatically stops native time skip");
            Check(CaelumScheduleState.Now(u)==Due && skip.ElapsedTics==64,"no accelerated time overshoots siege boundary");
            Check(!CaelumCityWorld.Peaceful() && CaelumTimeSkipRules.BlockReason(u)=="CA_EVENT_SIEGE_INTERRUPT","siege blocks restarting skip");
            CaelumTimeSkipState.FinishSkip(u,"CA_EVENT_SIEGE_INTERRUPT",true);BoundarySeen=true;
        }
        if(BoundarySeen && port.SiegeStarted)
        {
            Check(port.Defenders.Size()==600 && port.Attackers.Size()==6001,"ordinary full siege deploys after interrupted skip");
            Check(CaelumScheduleState.SiegeActive(u,"MAP06"),"shared calendar records active siege");
            BoundarySeen=false;Console.Printf("CA173 SIEGE_DONE");
        }
    }
}
