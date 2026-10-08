// Focused post-formation casualty/replacement control. No NPC relocation,
// resource reset, invulnerability or blocker removal is used.
class CA133Replacement : StaticEventHandler
{
    int Elapsed,Failures;
    bool Ready,Verified;
    Array<CaelumPortDefender> Original;
    CaelumPortDefender First,Second;
    CaelumCannon Gun;
    void Check(bool ok,String label)
    {if(!ok)Failures++;Console.Printf("CA133 %s %s",ok ? "PASS" : "FAIL",label);}
    override void WorldLoaded(WorldEvent e)
    {Ready=e.IsSaveGame && level.MapName=="MAP06";}
    override void WorldTick()
    {
        if(!Ready)return;
        Elapsed++;
        let port=CaelumPortSiege.Get();
        if(Elapsed==1)
        {
            for(int i=0;i<port.Defenders.Size();i++)Original.Push(port.Defenders[i]);
            First=Original[20];Second=Original[21];Gun=First.Gun;
            Check(Gun!=null && Gun==Second.Gun && !Gun.Neutralized,"formed original artillery pair exists");
            First.DamageMobj(null,null,1000000000,'None',DMG_FORCED);
            Second.DamageMobj(null,null,1000000000,'None',DMG_FORCED);
            port.RefillCrews();
            Check(Gun.Operators.Size()==2 && Gun.Operators[0]!=First && Gun.Operators[1]!=Second,
                "native crew refill selects surviving original infantry");
        }
        int pending=0;
        for(int i=0;i<Gun.Operators.Size();i++)
        {
            let b=CaelumPortDefender(Gun.Operators[i]);
            if(b==null || b.health<=0 || b.FollowingCrewRoute || (b.Pos-b.Station).Length()>b.Radius*2)pending++;
            if(Elapsed%350==0 && b!=null)
                Console.Printf("CA133 REPLACEMENT elapsed=%d id=%d crew=%d/%d pos=%.1f,%.1f,%.1f distance=%.1f",Elapsed,b.HomeIdentity,b.CrewRouteGun,b.CrewRouteStep,b.Pos.X,b.Pos.Y,b.Pos.Z,(b.Pos-b.Station).Length());
        }
        if(!Verified && pending==0)
        {
            Verified=true;int changed=0;
            for(int i=0;i<Original.Size();i++)if(port.Defenders[i]!=Original[i])changed++;
            Check(changed==0 && port.Defenders.Size()==600 && First.health<=0 && Second.health<=0,
                "replacement preserves roster identity and both casualties");
            Console.Printf("CA133 REPLACEMENT_COMPLETE elapsed=%d failures=%d",Elapsed,Failures);
        }
    }
}
