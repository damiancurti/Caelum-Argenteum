// Private controls derived from #357, with explicit current recognition prerequisites.
class CA855AbilityMandinga : CaelumMandinga { override void Tick() {} }
class CA855AbilityZupay : CaelumZupayColossus { override void Tick() {} }
class CA855AbilityVictim : Actor
{
    Default { Health 1000; Radius 16; Height 56; +SHOOTABLE +SOLID +INVULNERABLE +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA853NavigationProbe : EventHandler
{
    CaelumCombatActor Demon,Boss;
    Actor Victim,Goal;
    int Started,Checks,Failures;
    bool Pending;
    void Check(bool okay,String label)
    {Checks++;if(!okay)Failures++;Console.Printf("CA836 EDGE %s ability: %s",okay?"PASS":"FAIL",label);}
    void Ready(CaelumCombatActor body)
    {
        CaelumDemonService.StopBreath(body,true,false);
        body.SetStateLabel("RestLying");body.Angle=0;
        body.RecoveryPhase=0;body.ForcedSleepTics=0;body.CombatLucidityPhysicalStunRemaining=0;
        body.CaelumDiagnosticPassiveAI=false;body.CaelumMassAIScheduleActive=false;
        body.CurrentCombatAnima=body.MaximumCombatAnima;
        if(body.ThermalState==null)body.ThermalState=new("CaelumThermalState");
        body.ThermalState.Exposure=0;body.ThermalState.Severity=0;
        Victim.SetOrigin(CaelumDemonBreath.Mouth(body)+(CaelumDemonBreathRules.Range()/2,0,-Victim.Height/2),false);
        Goal.SetOrigin(body.Pos+(80,0,0),false);
        // This fixture tests ability routing; two-second acquisition is tested separately.
        CaelumVisualPerception.Evidence(body).GetMemory().Remember(Victim,Victim.Pos,level.time,body);
    }
    void Cases(CaelumCombatActor body)
    {
        Console.Printf("CA855 FAMILY %s",body.GetClassName());
        Check(body.CombatProfileInitialized && body.MaximumCombatAnima>0,"native profile initialized");
        Ready(body);body.target=Goal;
        Check(!CaelumDemonBreath.CanReach(body,Goal),"navigation marker excluded from breath reach");
        double before=body.CurrentCombatAnima;
        CaelumDemonService.UpdateBreath(body);
        Check(body.DemonBreath==null,"navigation alone does not start fire");
        Check(body.CurrentCombatAnima==before,"navigation alone spends no Anima");
        Check(Goal.bShootable && Goal.bInvulnerable && Goal.bNoTarget,"native route flags retained");
        Check(body.target==Goal,"native route reference retained");

        Ready(body);body.target=Victim;
        Check(CaelumVisualPerception.Identify(body,Victim),"legitimate visible target has known identity");
        Check(CaelumDemonBreath.CanReach(body,Victim),"legitimate nearby target reachable");
        before=body.CurrentCombatAnima;
        double cost=body.GetMagicAnimaCost(CaelumDemonBreathRules.ANIMA_PER_SECOND)/TICRATE;
        Check(cost>0 && cost<before,"native per-tic cost is positive and payable");
        CaelumDemonService.UpdateBreath(body);
        Check(body.DemonBreath!=null,"legitimate nearby target starts emission");
        Check(Abs(body.CurrentCombatAnima-(before-cost))<0.0000001,"legitimate emission pays exactly once");
        let prior=body.DemonBreath;double paid=prior!=null?prior.TotalPaidSeconds:0;
        CaelumDemonService.UpdateBreath(body);
        Check(body.DemonBreath==prior && prior!=null,"continued combat retains owned emission");
        Check(prior!=null && Abs(prior.TotalPaidSeconds-paid-1.0/TICRATE)<0.0000001,"continued combat pays one emission tic");
        Check(Abs(body.CurrentCombatAnima-(before-cost*2))<0.0000001,"continued combat deducts exactly two costs");
        body.target=Goal;before=body.CurrentCombatAnima;
        CaelumDemonService.UpdateBreath(body);
        Check(body.DemonBreath==null && (prior==null || prior.bDestroyed),"route switch retires active combat emission");
        Check(body.CurrentCombatAnima==before,"route switch makes no extra charge");
        Check(!body.InStateSequence(body.CurState,body.FindState("RacialBreath")),"route switch releases breathing pose");

        Ready(body);body.target=Victim;body.CurrentCombatAnima=0;
        CaelumDemonService.UpdateBreath(body);
        Check(body.DemonBreath==null && body.CurrentCombatAnima==0,"empty Anima prevents emission");
        Ready(body);Victim.SetOrigin(body.Pos+(1500,0,0),false);body.target=Victim;
        CaelumDemonService.UpdateBreath(body);
        Check(body.DemonBreath==null,"distant target prevents emission");

        Ready(body);body.target=Goal;body.ThermalState.Exposure=-1;body.ThermalState.Severity=1;
        CaelumDemonService.UpdateBreath(body);
        Check(body.DemonBreath!=null,"cold can emit with a navigation target");
        Check(body.DemonBreath!=null && Abs(body.DemonBreath.Direction.Z)<0.0000001,"cold does not aim down at route marker");
        Ready(body);body.target=Goal;
        let binding=CaelumBolasFlight(Actor.Spawn("CaelumBolasFlight",body.Pos,NO_REPLACE));binding.AttachVictim(body);
        Check(CaelumBolas.Restrained(body),"native bolas restrain body");before=body.CurrentCombatAnima;
        CaelumDemonService.UpdateBreath(body);
        Check(body.DemonBreath!=null,"restraint can emit with a navigation target");
        Check(!CaelumBolas.Restrained(body),"paid native fire releases bolas");
        Check(Abs(body.CurrentCombatAnima-(before-cost))<0.0000001,"restraint emission pays exactly once");
        CaelumDemonService.UpdateBreath(body);
        Check(body.DemonBreath==null,"emission stops once only navigation remains");

        for(int gate=0;gate<7;gate++)
        {
            Ready(body);body.target=Goal;body.ThermalState.Exposure=-1;body.ThermalState.Severity=1;
            CaelumDemonService.UpdateBreath(body);prior=body.DemonBreath;before=body.CurrentCombatAnima;
            Check(prior!=null,"interrupt starts from real cold emission");
            int previousHealth=body.health;
            if(gate==0)body.ForcedSleepTics=35;
            if(gate==1)body.CombatLucidityPhysicalStunRemaining=1;
            if(gate==2)body.RecoveryPhase=1;
            if(gate==3)body.SetStateLabel("Pain");
            if(gate==4)body.CaelumDiagnosticPassiveAI=true;
            if(gate==5)body.CaelumMassAIScheduleActive=true;
            if(gate==6)body.health=0;
            CaelumDemonService.UpdateBreath(body);
            Console.Printf("CA855 INTERRUPTION gate=%d",gate);
            Check(body.DemonBreath==null && (prior==null || prior.bDestroyed),"blocking condition retires emission");
            Check(body.CurrentCombatAnima==before,"blocking condition does not charge");
            body.health=previousHealth;
        }
        Ready(body);
        let boss=CaelumZupayColossus(body);
        if(boss!=null)
        {
            body.target=Goal;body.ThermalState.Exposure=-1;body.ThermalState.Severity=1;
            boss.SewerFleeing=true;before=body.CurrentCombatAnima;CaelumDemonService.UpdateBreath(body);
            Check(body.DemonBreath==null && body.CurrentCombatAnima==before,"Zupay fleeing blocks cold emission");boss.SewerFleeing=false;
        }
        Ready(body);body.target=null;
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!='ca853seed')return;
        let user=CaelumPlayer(players[0].mo);user.player.cheats|=CF_GODMODE;user.SetOrigin((-1700,-1700,0),false);
        Demon=CaelumCombatActor(Actor.Spawn('CA855AbilityMandinga',(-512,-512,0),NO_REPLACE));
        Boss=CaelumCombatActor(Actor.Spawn('CA855AbilityZupay',(-512,512,0),NO_REPLACE));
        Victim=Actor.Spawn('CA855AbilityVictim',(0,0,0),NO_REPLACE);
        Goal=Actor.Spawn('CaelumSewerEscapeTarget',(0,1500,0),NO_REPLACE);
        Check(Demon!=null && Boss!=null && Victim!=null && Goal!=null,"native fixture bodies exist");
        Demon.CurSector.SetLightLevel(255);Started=level.time;Pending=true;
    }
    override void WorldTick()
    {
        if(!Pending || level.time-Started<2)return;
        Pending=false;Cases(Demon);Cases(Boss);
        Console.Printf("CA836 EDGE_RESULT checks=%d failures=%d result=%s",Checks,Failures,Failures==0?"PASS":"FAIL");
    }
}
