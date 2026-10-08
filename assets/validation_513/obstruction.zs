// Temporary diagnostic obstacle and one explicit native casualty. Neither is
// included in the production package or performance comparison.
class CA133DoorObstacle : Actor
{
    Default { Radius 64; Height 128; +SOLID +NOGRAVITY }
    States { Spawn:TNT1 A -1;Stop; }
}
class CA133Obstruction : EventHandler
{
    Array<CaelumPortDefender> Original;
    Actor Obstacle;
    int Failures;
    void Check(bool ok,String label){if(!ok)Failures++;Console.Printf("CA133 %s %s",ok ? "PASS" : "FAIL",label);}
    override void WorldTick()
    {
        let port=CaelumPortSiege.Get();if(port==null)return;
        if(level.time==70)
        {
            for(int i=0;i<port.Defenders.Size();i++)Original.Push(port.Defenders[i]);
            Original[0].DamageMobj(null,null,1000000000,'None',DMG_FORCED);
            Obstacle=Actor.Spawn("CA133DoorObstacle",CaelumCityData.HouseOrigin(1)+(928,384,0));
        }
        if(level.time==90)
        {
            let user=CaelumPlayer(players[0].mo);let clock=CaelumWorldClock.Get(user,true);
            let calendar=CaelumCalendarState.Get(user,true);calendar.EnsureCampaign(clock);
            calendar.SetAnchor(clock,CaelumCityWorld.SiegeDay(),CaelumCityData.SIEGE_HOUR*CaelumWorldClock.TicsPerHour()-1,false);
        }
        if(level.time==400)
        {
            Check(Original[1].DeploymentStep<2,"closed native collision prevents exit instead of clipping");
            Check(Original[0].health<=0 && port.Defenders[0]==Original[0],"pre-siege casualty is retained and not respawned");
            Obstacle.Destroy();Obstacle=null;
        }
        if(level.time==1750)
        {
            int replaced=0;for(int i=0;i<Original.Size();i++)if(port.Defenders[i]!=Original[i])replaced++;
            Check(replaced==0 && port.Defenders.Size()==600,"scheduled event retains every original actor identity");
            Check(Original[1].DeploymentStep>=2,"blocked soldier resumes physical exit after obstacle clears");
            Check(Original[0].health<=0,"casualty remains dead after crew reassignment");
            Console.Printf("CA133 OBSTRUCTION_COMPLETE failures=%d",Failures);
        }
    }
}
