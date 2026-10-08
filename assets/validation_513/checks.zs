class CA133Checks : EventHandler
{
    int Checks, Failures;
    void Check(bool ok,String name)
    {
        Checks++;if(!ok)Failures++;
        Console.Printf("CA133 %s %s",ok ? "PASS" : "FAIL",name);
    }
    override void WorldTick()
    {
        let p=CaelumPortSiege.Get();
        if(level.time%100==0 && p!=null && p.Defenders.Size()==600)
        {
            let b=p.Defenders[504];vector3 dest=CaelumCityData.DoorOutside(b.HomeIdentity%160);
            Console.Printf("CA133 TRACK tic=%d id=%d step=%d pos=%.1f,%.1f goal=%.1f,%.1f velocity=%.1f,%.1f recovery=%d radius=%.1f sight=%d",level.time,b.HomeIdentity,b.DeploymentStep,b.Pos.X,b.Pos.Y,dest.X,dest.Y,b.Vel.X,b.Vel.Y,b.RecoveryPhase,b.Radius,b.NavigationTarget!=null && b.CheckSight(b.NavigationTarget));
        }
        if(level.time==90)
        {
            let user=CaelumPlayer(players[0].mo);
            let clock=CaelumWorldClock.Get(user,true);
            let calendar=CaelumCalendarState.Get(user,true);
            calendar.EnsureCampaign(clock);
            calendar.SetAnchor(clock,CaelumCityWorld.SiegeDay(),CaelumCityData.SIEGE_HOUR*CaelumWorldClock.TicsPerHour()-1,false);
        }
        if(level.time==96)
        {
            Check(p!=null && p.SiegeStarted && p.RosterSealed,"civil date starts attack without waiting for deployment");
            Check(p!=null && p.Defenders.Size()==600 && p.Attackers.Size()==101,"date retains soldiers and starts first 100 plus commander");
        }
        if(level.time==1400 && p!=null)
        {
            int departed=0,active=0,complete=0;
            for(int i=0;i<p.Defenders.Size();i++)
            {
                let b=p.Defenders[i];if(b==null || b.health<=0)continue;
                active++;
                vector3 home=CaelumCityData.HouseOrigin(i%160);
                if(b.DeploymentStep>=2)departed++;
                else Console.Printf("CA133 BLOCKED id=%d step=%d pos=%.1f,%.1f,%.1f home=%.1f,%.1f door=%d hold=%d speed=%.3f",i,b.DeploymentStep,b.Pos.X,b.Pos.Y,b.Pos.Z,home.X,home.Y,b.HomeDoor==null ? -1 : b.HomeDoor.SlideProgress,b.HomeDoor==null ? -1 : b.HomeDoor.HoldTimer,b.Speed);
                if(b.DeploymentComplete)complete++;
            }
            Console.Printf("CA133 ROUTES alive=%d left_house=%d ground_arrived=%d",active,departed,complete);
            Check(departed==active,"all surviving soldiers physically leave their houses");
            Console.Printf("CA133 COMPLETE checks=%d failures=%d",Checks,Failures);
        }
        if(level.time!=70)return;
        Check(p!=null && p.SetupRevision==3,"new city initialized");
        int tables=0,chairs=0,beds=0;
        for(int i=0;i<CaelumCityData.HOUSE_COUNT;i++)
        {
            let table=CaelumDiningWorld.Find(CaelumCityData.FURNITURE_SLOT_BASE+i);
            if(table!=null)
            {
                tables++;
                for(int j=0;j<table.SeatCount();j++)if(table.Chairs[j]!=null)chairs++;
            }
            if(CaelumRestFurnitureTrial.Find(CaelumCityData.FURNITURE_SLOT_BASE+i)!=null)beds++;
        }
        Console.Printf("CA133 FURNITURE tables=%d chairs=%d beds=%d",tables,chairs,beds);
        Check(tables==160 && chairs==960 && beds==160,"all medium tables, six chairs and beds fit");
        Check(p!=null && p.Defenders.Size()==600,"600 original soldiers housed");
        Check(p!=null && p.Attackers.Size()==0 && !p.SiegeStarted && !p.RosterSealed,"peace before civil siege date");
        int bad=0;
        if(p!=null)for(int i=0;i<p.Defenders.Size();i++)
        {
            let b=p.Defenders[i];
            if(b==null || !b.TestMobjLocation() || (b.Pos-CaelumCityData.HomePosition(i)).Length()>1)
            {bad++;Console.Printf("CA133 BADHOME i=%d pos=%s",i,b==null ? "null" : String.Format("%.1f,%.1f,%.1f",b.Pos.X,b.Pos.Y,b.Pos.Z));}
        }
        Check(bad==0,"every native soldier occupies a clear home position");
    }
}
