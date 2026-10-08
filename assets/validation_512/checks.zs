class CA132Checks : EventHandler
{
    int Checks, Failures, NativeBefore;
    Array<Actor> Blocks;
    void Kill(CaelumPortSiege p,int count)
    {
        for(int i=0;i<p.Attackers.Size() && count>0;i++)
        {
            let b=p.Attackers[i].Body;
            if(b==null || !(b is "CaelumMandinga") || b.health<=0)continue;
            b.DamageMobj(null,null,1000000000,'None',DMG_FORCED);count--;
        }
    }
    void Check(bool ok, String name)
    {
        Checks++;if(!ok)Failures++;
        Console.Printf("CA132 %s %s",ok ? "PASS" : "FAIL",name);
    }
    override void WorldTick()
    {
        let p=CaelumPortSiege.Get();if(p==null || p.Reinforcements==null)return;
        let r=p.Reinforcements;
        for(int i=0;i<p.Attackers.Size();i++)
            if(p.Attackers[i].Body!=null)p.Attackers[i].Body.bInvulnerable=true;
        if(level.time==3)
        {
            Check(r.Enabled && r.Successful==100 && r.Pending==0,"first group includes crew");
            Check(p.Defenders.Size()==600 && p.Machines.Size()==12 && p.Guns.Size()==42,"authored non-Mandinga population");
            Check(p.Attackers.Size()==101 && p.Boss!=null,"commander outside budget");
            Check(CaelumPopulationState.Get().HighDensity,"whole-map threshold already active with defenders");
            Console.Printf("CA132 FIRST success=%d alive=%d pending=%d failed=%d next=%d crews=%d",r.Successful,r.Living,r.Pending,r.PlacementFailures,r.NextOpportunity,r.InitialCrew.Size());
        }
        if(level.time==349)Check(r.Successful==100,"no premature second group");
        if(level.time==353)
        {
            Check(r.Successful==200 && r.Pending==0,"350-tic cadence");

        }
        if(level.time==400)
        {
            for(int i=0;i<18;i++){r.NextOpportunity=level.time;r.Tick(p);}
            Check(r.Living==2000 && r.Successful==2000 && r.Remaining==4000,"cap with 20 complete groups");
            r.NextOpportunity=level.time;r.Tick(p);
            Check(r.Successful==2000 && r.Pending==0,"full cap waits");
            let outsider=CaelumCombatActor(Actor.Spawn("CaelumMandinga",(0,0,0)));
            Check(p.RegisterAttacker(outsider)==null,"external registration stays sealed");outsider.ClearCounters();outsider.Destroy();
        }
        if(level.time==401)
        {
            Kill(p,99);r.NextOpportunity=level.time;r.Tick(p);
            Check(r.Living==1901 && r.Successful==2000,"99 deaths cannot open a group");
        }
        if(level.time==402)
        {
            Kill(p,1);r.NextOpportunity=level.time;r.Tick(p);
            Check(r.Living==2000 && r.Successful==2100,"100 deaths permit one full group");
        }
        if(level.time==403)
        {
            Kill(p,500);r.NextOpportunity=level.time;r.Tick(p);
            Check(r.Successful==2200 && r.Living==1600,"simultaneous vacancies admit only one group");
            r.Tick(p);Check(r.Successful==2200,"same-tic retry cannot bank opportunities");
        }
        if(level.time==404)
        {
            for(int i=5000;i<5100;i++)Blocks.Push(Actor.Spawn("CA132Block",CaelumPortData.FormationPosition(i)));
            NativeBefore=level.total_monsters;
            r.PlacementCursor=5000;r.NextOpportunity=level.time;r.Tick(p);
            Check(level.total_monsters==NativeBefore,"blocked candidates do not inflate native kill total");
            Check(r.Pending==100 && r.Successful==2200 && r.Remaining==3800,"blocked group retains full budget");
        }
        if(level.time==405)
        {
            for(int i=0;i<50;i++)Blocks[i].Destroy();
            r.PlacementCursor=5000;r.NextOpportunity=level.time;r.Tick(p);
            Check(level.total_monsters==NativeBefore+50,"partial group increments native kill total only for real members");
            Check(r.Pending==50 && r.Successful==2250 && r.Remaining==3750,"partial group counts only successful creation");
        }
        if(level.time==407)
            Check(r.Pending==50 && r.NextOpportunity==755 && r.GroupStart==2200 && r.Placed[49] && !r.Placed[50],"pending group and exact saved deadline unchanged before retry");
        if(level.time==450)
        {
            for(int i=50;i<100;i++)Blocks[i].Destroy();
            r.PlacementCursor=5050;r.NextOpportunity=level.time;r.Tick(p);
            Check(r.Pending==0 && r.Successful==2300 && r.Remaining==3700,"pending identities finish without duplicates");
        }
        if(level.time==451)
        {
            Kill(p,10000);r.Tick(p);
            Check(r.Living==0 && r.Remaining==3700 && !p.Victory,"empty field with reserves is not victory");
        }
        if(level.time==452)
        {
            p.Boss.Body.SetOrigin(p.Boss.ExitNode.Pos,false);
            p.ConfirmBossRetreat(p.Boss);
            for(int i=0;i<p.Machines.Size();i++)p.Machines[i].Neutralized=true;
            r.NextOpportunity=level.time;p.Tick();
            Check(p.Victory && p.BossRetreated && r.Stopped && r.Successful==2300,"legitimate victory stops reserves before next opportunity");
            Check(r.Pending==0 && r.Remaining==3700,"unspawned budget remains explicit after terminal victory");
            Console.Printf("CA132 COMPLETE checks=%d failures=%d",Checks,Failures);
        }
    }
}

class CA132Block : Actor { Default { Radius 64; Height 128; +SOLID +NOGRAVITY } States { Spawn: TNT1 A -1; Stop; } }
