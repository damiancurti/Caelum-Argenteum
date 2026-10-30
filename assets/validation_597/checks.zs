class CA423Checks : EventHandler
{
    int Checks,Failures;
    Array<CaelumPortDefender> Guards;
    Array<Actor> Prisoners;
    ui Array<double> FrameTimes;
    ui double LastFrame;
    override void RenderOverlay(RenderEvent e)
    {
        double now=MSTimeF();
        if(LastFrame>0 && FrameTimes.Size()<4096)FrameTimes.Push(now-LastFrame);
        LastFrame=now;
    }
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name=="ca423_resetframes"){FrameTimes.Clear();LastFrame=0;return;}
        if(e.Name!="ca423_frames" || FrameTimes.Size()==0)return;
        double sum=0;
        for(int i=0;i<FrameTimes.Size();i++)
        {
            sum+=FrameTimes[i];
            for(int j=i;j>0 && FrameTimes[j]<FrameTimes[j-1];j--)
            {double t=FrameTimes[j];FrameTimes[j]=FrameTimes[j-1];FrameTimes[j-1]=t;}
        }
        int n=FrameTimes.Size();
        Console.Printf("CA423 FRAMES callbacks=%d mean_ms=%.6f p95_ms=%.6f p99_ms=%.6f max_ms=%.6f",n,sum/n,FrameTimes[int((n-1)*.95)],FrameTimes[int((n-1)*.99)],FrameTimes[n-1]);
    }
    void Check(bool ok,String label)
    {Checks++;if(!ok)Failures++;Console.Printf("CA423 %s %s",ok?"PASS":"FAIL",label);}
    void Seed(CaelumPlayer u)
    {
        u.player.cheats|=CF_GODMODE;u.SetOrigin((-220,0,0),false);u.Angle=0;
        let r=u.GetPersistentCharacterState(true);r.DemoNarrativeRevision=1;r.DemoNarrativeDelivered=2047;
        for(int i=0;i<4;i++)
        {
            let g=CaelumPortDefender(Actor.Spawn("CaelumPortDefender",(80,-210+i*140,0)));
            g.HomeRevision=1;g.HomeIdentity=i;g.DeploymentComplete=true;g.Station=g.Pos;g.Angle=180;
            Guards.Push(g);
        }
        Class<Actor> kinds[4]={"CaelumPrisonerUnitario","CaelumPrisonerFederal","CaelumPrisonerBestia","CaelumPrisonerTarot"};
        for(int i=0;i<4;i++)
        {
            let p=Actor.Spawn(kinds[i],(260,-210+i*140,0));p.Angle=180;Prisoners.Push(p);
        }
        Check(Guards.Size()==4 && Prisoners.Size()==4,"four real guards and four original prisoner classes");
        u.PersistCharacterState();
    }
    void Population(CaelumPlayer u)
    {
        u.player.cheats|=CF_GODMODE;u.SetOrigin((-1400,0,0),false);u.Angle=0;
        for(int i=0;i<600;i++)
        {
            let g=CaelumPortDefender(Actor.Spawn("CaelumPortDefender",(-1100+(i%30)*72,-720+(i/30)*72,0)));
            g.HomeRevision=1;g.HomeIdentity=i;g.DeploymentComplete=true;g.Station=g.Pos;g.Angle=180;g.bDormant=true;
            Guards.Push(g);
        }
        Check(Guards.Size()==600,"600 peaceful diagnostic guards, no attackers");
    }
    void Visual(CaelumPlayer u)
    {
        Check(Guards.Size()==4,"legacy actor references preserved");
        for(int i=0;i<Guards.Size();i++)
        {
            let g=Guards[i];let sword=g.Sword;let shield=g.Shield;int hp=g.health;double mass=g.Mass,height=g.GetPhysiologicalHeight();
            g.RestoreWardrobeState();g.ApplyWardrobe();
            Check(g.WardrobeRevision==1 && g.WardrobeFace==i,String.Format("guard %d semantic face migration",i));
            Check(g.sprite==CaelumPortWardrobeData.SpriteFor(g,i),String.Format("guard %d registered native uniform",i));
            Check(g.Sword==sword && g.Shield==shield && g.health==hp && g.Mass==mass && g.GetPhysiologicalHeight()==height,String.Format("guard %d ownership and physical stats unchanged",i));
            int face=g.WardrobeFace;g.RestoreWardrobeState();g.ApplyWardrobe();
            Check(g.WardrobeFace==face,"idempotent appearance application");
        }
        let probe=Guards[0];int source[5]={probe.GetSpriteIndex("DOID"),probe.GetSpriteIndex("DOWK"),probe.GetSpriteIndex("DOMI"),probe.GetSpriteIndex("CAGN"),probe.GetSpriteIndex("CAGC")};
        int frames[10]={0,1,10,16,18,19,24,3,2,3};
        int kinds[10]={0,1,2,2,2,2,2,3,4,4};
        int expected[10]={0,2,3,4,6,7,8,12,16,16};
        for(int j=0;j<10;j++)
        {
            probe.sprite=source[kinds[j]];probe.frame=frames[j];probe.ApplyWardrobe();
            Check(probe.frame==expected[j],String.Format("pose mapping %d",j));
        }
        probe.RestoreWardrobeState();probe.ApplyWardrobe();
        let bandit=CaelumPortDefender(Actor.Spawn("CaelumTravelBandit",(-400,400,0)));
        int before=bandit.sprite;bandit.ApplyWardrobe();
        Check(!bandit.WardrobeApplied && bandit.sprite==before,"bandit subclass excluded from guard uniform");
        bandit.Destroy();
        double start=MSTimeF();
        for(int k=0;k<10000;k++){probe.RestoreWardrobeState();probe.ApplyWardrobe();}
        Console.Printf("CA423 TIMING 10000_local_restore_apply_ms=%.6f",MSTimeF()-start);
    }
    void Reload(CaelumPlayer u)
    {
        bool good=Guards.Size()==4;
        for(int i=0;i<Guards.Size();i++)good=good && Guards[i]!=null && Guards[i].WardrobeFace==i && Guards[i].WardrobeRevision==1;
        Check(good,"saved semantic guard identities survive reload/hub");
        Check(Prisoners.Size()==4 && Prisoners[0].GetClassName()=='CaelumPrisonerUnitario' && Prisoners[3].GetClassName()=='CaelumPrisonerTarot',"prisoner identities persist");
    }
    void Death(int step)
    {
        let g=Guards[3];
        if(step==0){g.bInvulnerable=false;g.DamageMobj(null,null,1000000,'None',DMG_FORCED);return;}
        Check(g.WardrobeFace==3 && g.frame==8 && g.health<=0,"dead guard retains face and fallen uniform");
    }
    void City(CaelumPlayer u)
    {
        let port=CaelumPortSiege.Get();Check(port!=null,"real campaign port active");
        if(port==null)return;
        int uniforms=0,existing=0;
        for(int i=0;i<port.Defenders.Size();i++)
        {
            let g=port.Defenders[i];if(g!=null && g.GetClassName()=='CaelumPortDefender')
            {existing++;g.RestoreWardrobeState();g.ApplyWardrobe();if(g.WardrobeRevision==1)uniforms++;}
        }
        Check(uniforms==existing && port.Defenders.Size()==CaelumHouseHubData.RESIDENT_COUNT,"city registry preserves deferred household bodies");
        Console.Printf("CA423 CITY slots=%d instantiated_guards=%d uniforms=%d",port.Defenders.Size(),existing,uniforms);
    }
    void House()
    {
        let roster=CaelumHouseResidents.Get();int bodies=0,good=0;
        if(roster!=null)for(int i=0;i<roster.Residents.Size();i++)
        {
            let entry=roster.Residents[i];let g=entry.Body;
            if(g==null || entry.Suspended)continue;
            bodies++;if(g.WardrobeRevision==1 && g.WardrobeFace==i%4 && g.WardrobeApplied)good++;
        }
        Check(bodies>0 && bodies==good,"real household residents wear stable assigned uniforms");
        Console.Printf("CA423 HOUSE bodies=%d uniforms=%d",bodies,good);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="ca423_seed")Seed(u);
        if(e.Name=="ca423_population")Population(u);
        if(e.Name=="ca423_pitch")u.Pitch=e.Args[0];
        if(e.Name=="ca423_visual")Visual(u);
        if(e.Name=="ca423_reload")Reload(u);
        if(e.Name=="ca423_death")Death(e.Args[0]);
        if(e.Name=="ca423_city")City(u);
        if(e.Name=="ca423_house")House();
        if(e.Name=="ca423_done")Console.Printf("CA423 RESULT checks=%d failures=%d",Checks,Failures);
    }
}
