class CA447Port : CaelumPortSiege
{
    override void Tick() {}
}

class CA447Defender : CaelumPortDefender
{
    override void Tick() {}
}

class CA447Commander : CaelumPortCommander
{
    override void Tick() {}
}

class CA447Machine : CaelumHostileMachine
{
    override void Tick() {}
    Default { Health 100; Radius 8; Height 8; +NOBLOCKMAP }
    States { Spawn: TNT1 A -1; Stop; }
}

class CA447Checks : EventHandler
{
    CA447Port Port;
    CA447Defender First,Second;
    int Checks,Failures,Stage;
    double Deadline;

    void Check(bool okay,String label)
    {
        Checks++;
        if(!okay)Failures++;
        Console.Printf("CA447 %s %s",okay?"PASS":"FAIL",label);
    }

    void Seed()
    {
        if(Port!=null)return;
        Port=CA447Port(Actor.Spawn('CA447Port',(0,256,0),NO_REPLACE));
        Port.args[0]=CaelumCityData.LAYOUT_REVISION;Port.SetupRevision=CaelumCityData.LAYOUT_REVISION;
        Port.SiegeStarted=true;
        for(int i=0;i<6;i++)
        {
            let exit=CaelumSiegeRouteNode(Actor.Spawn('CaelumSiegeRouteNode',(CaelumPortData.GateX(i),-22528,0),NO_REPLACE));
            exit.IsExit=true;Port.Exits.Push(exit);
        }
        let commander=CA447Commander(Actor.Spawn('CA447Commander',Port.Exits[0].Pos,NO_REPLACE));
        Port.Boss=Port.RegisterAttacker(commander);Port.Boss.ExitNode=Port.Exits[0];
        for(int i=0;i<12;i++)
            Port.RegisterMachine(CA447Machine(Actor.Spawn('CA447Machine',(-1000+i*64,1000,0),NO_REPLACE)));
        Port.RosterSealed=true;
        First=CA447Defender(Actor.Spawn('CA447Defender',(-256,256,0),NO_REPLACE));
        Second=CA447Defender(Actor.Spawn('CA447Defender',(256,256,0),NO_REPLACE));
        First.Port=Second.Port=Port;Port.Defenders.Push(First);Port.Defenders.Push(Second);
        Port.Reinforcements=new('CaelumSiegeReinforcements');
        let reserve=Port.Reinforcements;
        reserve.Revision=CaelumReinforcementData.REVISION;reserve.Enabled=true;
        reserve.Successful=CaelumReinforcementData.TOTAL-1;reserve.Remaining=1;
        reserve.NextOpportunity=level.time+175;
        Stage=1;
        Console.Printf("CA447 SEEDED");
    }

    void Initial()
    {
        Check(Port!=null && First.health>0 && Second.health>0,"native defenders initialized");
        if(Port==null)return;
        double now=CaelumBattleDirector.CivilNow(Port);
        Port.EnsureDirector(now);
        let director=Port.Director;let reserve=Port.Reinforcements;
        Check(now>=0 && director!=null,"director anchored to shared civil time");
        if(director==null)return;
        Check(director.Phase==CaelumBattleData.ACTIVE && director.Defenders.Size()==2,"legacy roster migrated once");
        Check(reserve.Successful==CaelumReinforcementData.TOTAL-1 && reserve.Remaining==1,"migration preserves spent finite reserve");
        Deadline=director.NextWaveCivil;
        Port.EnsureDirector(now+86400);
        Check(director.NextWaveCivil==Deadline && director.Defenders.Size()==2,"idempotent migration preserves deadline and identities");
        Check(!director.WaveDue(Deadline-1) && director.WaveDue(Deadline),"civil deadline exact boundary");
        director.RecordWave(Deadline);
        Check(!director.WaveDue(Deadline) && director.NextWaveCivil>Deadline,"same opportunity cannot repeat");
        Deadline=director.NextWaveCivil;
        First.health=0;First.Die(null,null,0,'None');
        CaelumBattleDirector.DefenderChanged(First);
        Port.ObserveBattle(now);
        Check(!director.Defeated && director.DefeatCount==0,"one living defender prevents defeat");
        Stage=2;
        Console.Printf("CA447 CHECKPOINT READY failures=%d",Failures);
    }

    void Restored()
    {
        Check(Stage==2 && Port!=null,"restored intended pre-outcome checkpoint");
        if(Port==null)return;
        let director=Port.Director;let reserve=Port.Reinforcements;
        Check(director.NextWaveCivil==Deadline && reserve.Remaining==1,"save preserves deadline and final reserve");
        Check(director.Defenders.Size()==2 && director.Defenders[0].ConfirmedDead,"save preserves exact casualty identity");
        reserve.NextOpportunity=level.time;director.NextWaveCivil=CaelumBattleDirector.CivilNow(Port);
        reserve.Tick(Port);
        Check(reserve.Successful==CaelumReinforcementData.TOTAL && reserve.Remaining==0,"last real arrival consumes final finite slot");
        int arrivals=Port.Attackers.Size();reserve.Opportunity(Port);
        Check(Port.Attackers.Size()==arrivals && reserve.Remaining==0,"spent reserves never replenish");
        Second.health=0;Second.Die(null,null,0,'None');
        CaelumBattleDirector.DefenderChanged(Second);
        Port.ObserveBattle(CaelumBattleDirector.CivilNow(Port));
        Check(director.Defeated && director.DefeatCount==1 && reserve.Stopped,"last defender commits defeat and stops reserves");
        Port.ObserveBattle(CaelumBattleDirector.CivilNow(Port)+86400);
        Check(director.DefeatCount==1,"calendar replay cannot repeat defeat");
        Check(playeringame[0] && players[0].mo.health>0,"defeat retains a living playable survivor");
        Port.ConfirmBossRetreat(Port.Boss);
        Check(Port.BossRetreated && !Port.Boss.ConfirmedDead,"living commander retreat is confirmed at its actual exit");
        for(int i=0;i<11;i++)Port.Machines[i].DestroyByTarot();
        Port.ResolveVictory();
        Check(!Port.Victory,"eleven machines cannot finish the authored battle");
        Port.Machines[11].DestroyByTarot();Port.ObserveBattle(CaelumBattleDirector.CivilNow(Port)+86400);
        Check(Port.Victory && Port.NeutralizedCount==12,"all original objectives produce actual victory");
        Check(director.Won && director.Defeated && director.VictoryCount==1 && director.Phase==CaelumBattleData.LIBERATED,"later victory retains original defeat identity");
        Port.ObserveBattle(CaelumBattleDirector.CivilNow(Port)+172800);
        Check(director.VictoryCount==1 && reserve.Remaining==0,"later world updates cannot repeat outcome or reserves");
        Stage=3;
        Console.Printf("CA447 RESULT %s checks=%d failures=%d",Failures==0?"PASS":"FAIL",Checks,Failures);
    }

    void LegacyRestored()
    {
        Check(Port!=null && Port.Director==null,"pre-director save has no synthesized outcome");
        if(Port==null)return;
        let reserve=Port.Reinforcements;
        int successful=reserve.Successful,remaining=reserve.Remaining;
        Port.EnsureDirector();
        Check(Port.Director!=null && Port.Director.Revision==1,"native old-save migration creates revision one");
        Check(Port.Director.Defenders.Size()==2 && Port.Defenders[0]==First && Port.Defenders[1]==Second,"native migration retains exact bodies");
        Check(reserve.Successful==successful && reserve.Remaining==remaining,"native migration retains spent reserves");
        double due=Port.Director.NextWaveCivil;Port.EnsureDirector();
        Check(Port.Director.NextWaveCivil==due && Port.Director.Defenders.Size()==2,"native old-save migration is idempotent");
        Console.Printf("CA447 LEGACY %s failures=%d",Failures==0?"PASS":"FAIL",Failures);
    }

    void Catchup()
    {
        if(Port==null)return;
        let user=CaelumPlayer(players[0].mo);
        double now=CaelumBattleDirector.CivilNow(Port);
        First.bInvulnerable=Second.bInvulnerable=true;
        Port.Boss.Body.bInvulnerable=true;
        Port.AbsentBattle=new('CaelumAbsentBattle');
        Port.AbsentBattle.Capture(Port,user,now);
        double end=now+2*CaelumBattleData.WaveCivilSeconds();
        Port.AbsentBattle.SyncTo(end);
        Check(Port.Reinforcements.Remaining==0 && Port.Reinforcements.Successful==CaelumReinforcementData.TOTAL,"unloaded calendar consumes the final reserve once");
        int arrivals=Port.Attackers.Size(),waves=Port.Director.WaveCount;
        Port.AbsentBattle.SyncTo(end);
        Check(Port.Attackers.Size()==arrivals && Port.Director.WaveCount==waves,"same calendar boundary cannot replay arrivals");
        let clock=CaelumWorldClock.Get(user,true);let calendar=CaelumCalendarState.Get(user,true);
        int day=int(Floor(end/86400));
        calendar.SetAnchor(clock,day,int((end-double(day)*86400)*CaelumWorldClock.TicsPerHour()/3600),false);
        Port.AbsentBattle.FinishRestore();
        Check(!Port.AbsentBattle.Away && !Port.AbsentBattle.Busy,"catch-up resumes native ownership");
        Console.Printf("CA447 CATCHUP %s failures=%d",Failures==0?"PASS":"FAIL",Failures);
    }

    void VerifyTravel()
    {
        Console.Printf("CA447 TRAVEL STATE stage=%d firstHealth=%d secondHealth=%d dead=%d phase=%d defeated=%d",
            Stage,First!=null?First.health:-1,Second!=null?Second.health:-1,
            Port!=null && Port.Director!=null?int(Port.Director.Defenders[0].ConfirmedDead):-1,
            Port!=null && Port.Director!=null?Port.Director.Phase:-1,
            Port!=null && Port.Director!=null?int(Port.Director.Defeated):-1);
        Check(Stage==2 && Port!=null && Port.Director!=null,"hub return retains the original director and checkpoint");
        if(Port==null || Port.Director==null)return;
        Check(Port.Director.Defenders.Size()==2 && Port.Director.Defenders[0].Body==First
            && Port.Director.Defenders[1].Body==Second,"hub return retains exact defender identities");
        Check(Port.Director.Defenders[0].ConfirmedDead && !Port.Director.Defeated,"hub return retains casualty without inventing defeat");
        Check(Port.Director.NextWaveCivil==Deadline && Port.Reinforcements.Remaining==1,"hub return does not restart the reserve deadline or budget");
        Console.Printf("CA447 TRAVEL %s failures=%d",Failures==0?"PASS":"FAIL",Failures);
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca447_seed")Seed();
        else if(e.Name=="ca447_initial")Initial();
        else if(e.Name=="ca447_restored")Restored();
        else if(e.Name=="ca447_legacy")LegacyRestored();
        else if(e.Name=="ca447_catchup")Catchup();
        else if(e.Name=="ca447_travel")
        {
            // Aislamos persistencia: el combate ausente real no debe matar al testigo.
            Second.bInvulnerable=true;
            Port.Boss.Body.bInvulnerable=true;
            Level.ChangeLevel('T447',0,CHANGELEVEL_NOINTERMISSION);
        }
        else if(e.Name=="ca447_return")Level.ChangeLevel('MAP03',0,CHANGELEVEL_NOINTERMISSION);
        else if(e.Name=="ca447_verifytravel")VerifyTravel();
    }
}
