// Observe the real new-city workload with a controlled civil calendar/camera.
// The shared observer protects its camera player. NPC health, collision,
// resources and combat remain unchanged.
class CA133Combined : EventHandler
{
    Actor PeaceView;
    override void WorldTick()
    {
        let port=CaelumPortSiege.Get();if(port==null)return;
        int attackTic=CVar.GetCVar("ca133_attack_tic").GetInt();
        if(level.time>=70 && level.time<attackTic && players[0].mo!=null)
        {
            let user=CaelumPlayer(players[0].mo);user.CreationWizardOpen=false;
            if(PeaceView==null)PeaceView=Actor.Spawn("CaelumSiegeRouteNode",CaelumCityData.DoorOutside(0)+(128,0,256));
            PeaceView.Angle=180;players[0].camera=PeaceView;
        }
        if(level.time==attackTic)
        {
            let user=CaelumPlayer(players[0].mo);let clock=CaelumWorldClock.Get(user,true);
            let calendar=CaelumCalendarState.Get(user,true);calendar.EnsureCampaign(clock);
            calendar.SetAnchor(clock,CaelumCityWorld.SiegeDay(),CaelumCityData.SIEGE_HOUR*CaelumWorldClock.TicsPerHour()-1,false);
        }
        if(level.time%35!=0)return;
        int alive=0,left=0,arrived=0,shots=0,reloads=0,reloading=0;
        for(int i=0;i<port.Defenders.Size();i++)
        {
            let body=port.Defenders[i];if(body==null)continue;
            if(body.health>0)alive++;
            if(body.DeploymentStep>=2)left++;
            if(body.DeploymentComplete)arrived++;
            if(body.Carbine!=null){shots+=body.Carbine.ShotCount;reloads+=body.Carbine.ReloadCount;if(body.Carbine.ReloadRemaining>0)reloading++;}
        }
        Console.Printf("CA133 CITY tic=%d ms=%.6f alive=%d left=%d arrived=%d shots=%d reloads=%d reloading=%d pathQueue=%d",level.time,MSTimeF(),alive,left,arrived,shots,reloads,reloading,port.CityPathQueue.Size());
    }
}
