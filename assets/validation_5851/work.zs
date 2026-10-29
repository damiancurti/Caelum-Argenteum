class CA415WorkChecks : EventHandler
{
    CaelumAbsentBattle Battle;
    CaelumCombatActor First,Second;
    int Passed,Failed,FirstShots,SecondShots;
    CaelumAbsentArrival Arrival;
    int ArrivalFirstShots,ArrivalSecondShots,ArrivalNative,ArrivalWorld;
    void Check(bool value,String label)
    {if(value)Passed++;else Failed++;Console.Printf("CA415W %s %s",value?"PASS":"FAIL",label);}

    void Prepare(CaelumPlayer user)
    {
        let soldier=CaelumPortDefender(ThinkerIterator.Create('CA415RoundSoldier').Next());
        First=soldier;Second=CaelumCombatActor(ThinkerIterator.Create('CA415RoundDemon').Next());
        soldier.Carbine=new('CaelumCityCarbine');soldier.Carbine.Initialize(soldier);
        First.bFriendly=true;Second.bFriendly=false;First.target=Second;Second.target=First;
        First.EffectiveCombatEvasionChance=Second.EffectiveCombatEvasionChance=0;
        First.CombatToughness=Second.CombatToughness=0;First.CombatArmor=Second.CombatArmor=null;
        First.health=First.CombatMaximumHealth=Second.health=Second.CombatMaximumHealth=1000000;
        Second.CombatIntelligence=100;
        First.CurrentCombatAir=First.MaximumCombatAir;Second.CurrentCombatAnima=Second.MaximumCombatAnima;
        Battle=new('CaelumAbsentBattle');Battle.ActiveScale=1;
        let firstRow=Battle.Add(First);let secondRow=Battle.Add(Second);
        firstRow.Opponent=secondRow;secondRow.Opponent=firstRow;Battle.Round();
        First.health=First.CombatMaximumHealth=Second.health=Second.CombatMaximumHealth=1;
        firstRow.Remaining=secondRow.Remaining=0;firstRow.Preparing=secondRow.Preparing=true;
        firstRow.Recovering=secondRow.Recovering=false;
        First.CurrentCombatAir=First.MaximumCombatAir;Second.CurrentCombatAnima=Second.MaximumCombatAnima;
        First.CombatLucidityPhysicalStunRemaining=Second.CombatLucidityPhysicalStunRemaining=0;
        First.ForcedSleepTics=Second.ForcedSleepTics=0;
        FirstShots=firstRow.Shots;SecondShots=secondRow.Shots;
        Battle.Work.Begin(Battle,17,1,false);
        Check(Battle.Work.End==17,"staged interval retains its nonzero destination timestamp");
        while(Battle.Work.Phase<9)Battle.Work.Advance(1);
        Check(First.health==1 && Second.health==1,"chunked action phases keep both round-start combatants alive before simultaneous commit");
        Check(firstRow.Shots>FirstShots && secondRow.Shots>SecondShots && firstRow.PendingLife>0 && secondRow.PendingLife>0,"all staged attacks spend their actual resources and queue both lethal results");
        Check(Battle.Work.Phase==9 && Battle.Work.Index==0 && !Battle.Work.Complete,"partial round exposes an exact resumable phase and cursor");
    }

    void Complete()
    {
        Check(Battle.Work.Battle==Battle && Battle.Work.Phase==9 && Battle.Work.Index==0 && Battle.Work.End==17,"saved work restores the authoritative battle, timestamp and pending commit cursor");
        int firstShots=First.AbsentCombatant.Shots,secondShots=Second.AbsentCombatant.Shots;
        Battle.Work.Advance(1);
        Check(Battle.Work.Index==1 && First.health<=0 && Second.health==1,"one work unit commits only its bounded slice");
        while(!Battle.Work.Advance(1)){}
        Check(First.health<=0 && Second.health<=0 && First.bCorpse && Second.bCorpse,"remaining slices apply both native casualties and finish the simultaneous round");
        Check(First.AbsentCombatant.Shots==firstShots && Second.AbsentCombatant.Shots==secondShots,"resuming after save does not replay attacks or pay their resources twice");
        int rounds=Battle.Rounds;Battle.Work.Advance(1);
        Check(rounds==2 && Battle.Rounds==rounds,"completed work cannot commit the same round again");
    }

    void ArrivalSave(CaelumPlayer user)
    {
        Prepare(user);
        Battle.SourceMap=level.MapName;Battle.Away=true;Battle.Busy=true;
        Battle.SchemaRevision=CaelumAbsentBattle.REVISION;Battle.Stamp=16;Battle.Observer=user;
        Arrival=CaelumAbsentArrival(Actor.Spawn('CaelumAbsentArrival',(0,0,0),NO_REPLACE));
        Arrival.Observer=user;Arrival.Battles.Push(Battle);Arrival.Prepared=true;
        Arrival.TargetTime=17;Arrival.IntervalPending=true;Arrival.Running=true;
        ArrivalFirstShots=First.AbsentCombatant.Shots;ArrivalSecondShots=Second.AbsentCombatant.Shots;
        ArrivalNative=level.time;ArrivalWorld=CaelumWorldClock.Get(user).DayTics;
        Battle.Restore(user);
        Check(Battle.Away && Battle.Busy && Battle.Work.Phase==9 && First.health==1 && Second.health==1,
            "a second restore cannot interrupt or finalize an active partial round");
        // Do not publish to the static UI cache yet: the native save must
        // retain this exact partial phase. WorldLoaded discovers it on load.
        Check(Arrival.IntervalPending && Battle.Work.Phase==9,"native save fixture retains a partially committed arrival job");
    }
    void ArrivalLoaded()
    {
        Check(Arrival!=null && !Arrival.Running && Arrival.BattleCursor==1,"loading restores and completes the saved arrival job without an extra travel");
        Check(Arrival.Battles[0]==Battle && First.AbsentCombatant.Battle==Battle,"loaded arrival keeps authoritative object and body identity");
        Check(!Battle.Away && !Battle.Busy && Battle.Stamp==17 && Battle.Fraction==0 && Battle.Rounds==2,"resumed arrival commits its timestamp and releases the native encounter exactly once");
        Check(First.health<=0 && Second.health<=0 && First.bCorpse && Second.bCorpse,"saved simultaneous pending casualties both reach native death");
        Check(First.AbsentCombatant.Shots==ArrivalFirstShots && Second.AbsentCombatant.Shots==ArrivalSecondShots,"saved arrival does not repay or repeat the prepared attacks");
        Check(!level.isFrozen(),"completed saved arrival releases its temporary native freeze");
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[e.Player].mo);if(user==null)return;
        if(e.Name=="ca415r_worksave")Prepare(user);
        else if(e.Name=="ca415r_workload")Complete();
        else if(e.Name=="ca415r_arrivalsave")ArrivalSave(user);
        else if(e.Name=="ca415r_workarrival")ArrivalLoaded();
        else return;
        Console.Printf("CA415W RESULT passed=%d failed=%d",Passed,Failed);
    }
}
