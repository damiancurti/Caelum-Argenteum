// Isolated population control: compress only setup, then use normal cadence,
// damage, movement and combat. Never included in the playable package.
class CA132CapStart : StaticEventHandler
{
    override void WorldTick()
    {
        if(level.time!=3)return;
        let p=CaelumPortSiege.Get();if(p==null || p.Reinforcements==null)return;
        let r=p.Reinforcements;
        for(int group=0;group<19;group++){r.NextOpportunity=level.time;r.Tick(p);}
        if(r.Successful!=2000 || r.Living!=2000 || r.Pending!=0)Console.Printf("CA132 FAIL cap control setup");
        else Console.Printf("CA132 CAP CONTROL 2000 native Mandingas; normal damage and 350-tic cadence resume now");
    }
}
