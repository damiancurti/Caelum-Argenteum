// Isolated routing control: end combat after the real scheduled spawn. Keep
// all surviving bodies, collisions, doors and resource/thermal simulation.
class CA133Routes : EventHandler
{
    bool Verified;
    override void WorldTick()
    {
        let p=CaelumPortSiege.Get();if(p==null)return;
        if(level.time==90)
        {
            let user=CaelumPlayer(players[0].mo);
            let clock=CaelumWorldClock.Get(user,true);
            let calendar=CaelumCalendarState.Get(user,true);calendar.EnsureCampaign(clock);
            calendar.SetAnchor(clock,CaelumCityWorld.SiegeDay(),CaelumCityData.SIEGE_HOUR*CaelumWorldClock.TicsPerHour()-1,false);
        }
        if(level.time==98){p.Victory=true;Console.Printf("CA133 ROUTE_CONTROL combat ended after scheduled first group");}
        if(level.time%TICRATE!=0)return;
        int alive=0,leftHome=0,ground=0,formed=0,yielding=0,crew=0;
        for(int i=0;i<p.Defenders.Size();i++)
        {
            let b=p.Defenders[i];if(b==null || b.health<=0)continue;
            alive++;
            if(b.DeploymentStep>=2)leftHome++;
            if(b.DeploymentComplete)ground++;
            if((b.Pos-b.Station).Length()<=b.Radius*2)formed++;
            if(b.ReturningFromYield)yielding++;
            if(b.FollowingCrewRoute)crew++;
        }
        if(level.time%1750==0)Console.Printf("CA133 ROUTE_PROGRESS tic=%d alive=%d left=%d ground=%d formed=%d",level.time,alive,leftHome,ground,formed);
        if(!Verified && alive==600 && ground==600 && formed==600 && yielding==0 && crew==0)
        {
            Verified=true;
            Console.Printf("CA133 ROUTE_VERIFIED all 600 original bodies reached posts; no unfinished crew route or temporary yield");
        }
        if(level.time>=26250 && level.time%1750==0)
        {
            for(int i=0;i<p.Defenders.Size();i++)
            {
                let b=p.Defenders[i];if(b==null || b.health<=0)continue;
                if((b.Pos-b.Station).Length()>b.Radius*2 || !b.DeploymentComplete || b.ReturningFromYield)
                {
                    Console.Printf("CA133 ROUTE_PENDING id=%d step=%d complete=%d crew=%d/%d pos=%.1f,%.1f,%.1f station=%.1f,%.1f,%.1f",i,b.DeploymentStep,b.DeploymentComplete,b.CrewRouteGun,b.CrewRouteStep,b.Pos.X,b.Pos.Y,b.Pos.Z,b.Station.X,b.Station.Y,b.Station.Z);
                    int house=i%CaelumCityData.HOUSE_COUNT;
                    vector3 point=b.ReturningFromYield ? (b.YieldFor==null ? b.Station : b.YieldDestination)
                        : b.DeploymentStep==0 ? CaelumCityData.DoorInside(house)
                        : b.DeploymentStep==1 ? CaelumCityData.DoorOutside(house)
                        : b.DeploymentStep==2 ? CaelumCityData.HouseRoad(house)
                        : CaelumCityRoutes.Point(i,b.DeploymentStep-3);
                    vector2 next=point.XY;
                    if(b.FollowingCrewRoute && b.NavigationTarget!=null){point=b.NavigationTarget.Pos;next=point.XY;}
                    if((!b.DeploymentComplete || b.ReturningFromYield) && b.CityNavigation!=null && b.CityNavigation.Cursor<b.CityNavigation.PointX.Size())next=b.CityNavigation.Point(b.CityNavigation.Cursor);
                    vector2 delta=next-b.Pos.XY;
                    if(delta.Length()>0)b.CheckMove(b.Pos.XY+delta.Unit()*Min(b.Speed,delta.Length()));
                    let block=CaelumPortDefender(b.BlockingMobj);
                    Console.Printf("CA133 ROUTE_DIAG id=%d yield=%d for=%d goal=%.1f,%.1f next=%.1f,%.1f block=%d line=%d air=%.1f sleep=%d",i,b.ReturningFromYield,b.YieldFor==null ? -1 : b.YieldFor.HomeIdentity,point.X,point.Y,next.X,next.Y,block==null ? -1 : block.HomeIdentity,b.BlockingLine==null ? -1 : b.BlockingLine.Index(),b.CurrentCombatAir,b.ForcedSleepTics);
                    if(i==214)
                    {
                        Console.Printf("CA133 GRID size=%.1f,%.1f floor=%.1f step=%.1f drop=%.1f",b.Radius,b.Height,b.FloorZ,b.MaxStepHeight,b.MaxDropOffHeight);
                        for(int a=0;a<8;a++)
                        {
                            vector2 probe=b.Pos.XY+(Cos(a*45)*8,Sin(a*45)*8);
                            bool ok=b.CheckMove(probe,PCM_DROPOFF);
                            Console.Printf("CA133 GRID angle=%d ok=%d body=%s line=%d",a*45,ok,b.BlockingMobj==null ? 'none' : b.BlockingMobj.GetClassName(),b.BlockingLine==null ? -1 : b.BlockingLine.Index());
                        }
                    }
                }
            }
            Console.Printf("CA133 ROUTE_CONTROL_COMPLETE alive=%d formed=%d",alive,formed);
        }
    }
}
