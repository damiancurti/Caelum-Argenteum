class CA433Body : CaelumCombatActor
{
    override void Tick() { }
    Default { Health 100; Radius 16; Height 56; Speed 1; +SHOOTABLE +SOLID }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA433Checks : EventHandler
{
    CA433Body Observer,Enemy,Ally;
    int Passes,Failures;
    void Check(bool ok,String label)
    {if(ok){Passes++;Console.Printf("CA433 PASS %s",label);}else{Failures++;Console.Printf("CA433 FAIL %s",label);}}
    void Empty()
    {
        let evidence=CaelumVisualPerception.Evidence(Observer);
        evidence.Memory=null;evidence.Suspicion=0;evidence.VisibleNow=false;evidence.PreviousSampleVisible=false;
        evidence.Subject=null;evidence.CandidateCacheReady=false;evidence.EmptySearchUntil=0;
        Observer.target=null;Observer.SiegeCombatant=null;Ally.SiegeCombatant=null;
        Enemy.SetOrigin((1800,0,0),false);Ally.SetOrigin((-1800,0,0),false);
        Observer.SetOrigin((0,0,0),false);Observer.Angle=0;
        CaelumVisualPerception.Candidate(Observer);
    }
    void Seed()
    {
        let user=CaelumPlayer(players[0].mo);
        user.CharacterCreationComplete=true;user.CreationWizardOpen=false;user.ApplyCharacterProfile();
        user.bInvulnerable=true;user.bShootable=false;user.SetOrigin((-1900,-1900,0),false);
        Observer=CA433Body(Actor.Spawn('CA433Body',(0,0,0),NO_REPLACE));
        Enemy=CA433Body(Actor.Spawn('CA433Body',(1800,0,0),NO_REPLACE));Enemy.bFriendly=true;
        Ally=CA433Body(Actor.Spawn('CA433Body',(-1800,0,0),NO_REPLACE));
        Observer.CombatAgility=Enemy.CombatAgility=Ally.CombatAgility=0;Observer.CombatEffectiveInsight=0;
        Empty();let evidence=Observer.VisualEvidence;
        Check(evidence.EmptySearchUntil==level.time+5,"empty isolated query schedules exactly five active tics");
        int skipped=evidence.EmptySearchSkipped;CaelumVisualPerception.Candidate(Observer);
        Check(evidence.EmptySearchSkipped==skipped+1,"repeated empty query reuses its bounded deadline");
        Observer.Angle=90;
        Check(!CaelumVisualPerception.ReuseEmptySearch(Observer,evidence),"turning immediately restores evaluation");
        Empty();Observer.SetOrigin((1,0,0),false);
        Check(!CaelumVisualPerception.ReuseEmptySearch(Observer,evidence),"movement immediately restores evaluation");
        Empty();Enemy.SetOrigin((100,0,0),false);evidence.EmptySearchUntil=level.time;
        evidence.CandidateCacheReady=false;
        Check(CaelumVisualPerception.Candidate(Observer)==Enemy && evidence.EmptySearchUntil==0,
            "deadline discovers entering target and cancels empty cadence");
        Empty();Ally.SetOrigin((100,0,0),false);evidence.EmptySearchUntil=0;evidence.CandidateCacheReady=false;
        CaelumVisualPerception.Candidate(Observer);
        Check(evidence.EmptySearchUntil==0,"visible nonhostile actor also prevents throttling");
        Empty();Ally.SetOrigin((100,0,0),false);
        CaelumNoise.Deliver(Observer,Ally,CaelumNoiseData.SHOUT,2048);
        Check(evidence.EmptySearchUntil==0 && evidence.HasHeardNoise && evidence.Suspicion>0,
            "audible noise wakes evaluation immediately without revealing source");
        Empty();evidence.Damaged(Observer,Enemy);
        Check(evidence.EmptySearchUntil==0 && evidence.Suspicion==100 && evidence.IdentifiedSubject==null,
            "hidden damage wakes alert without inventing attacker identity");
        Empty();Enemy.SetOrigin((32,0,0),false);Observer.CollidedWith(Enemy,true);
        Check(evidence.EmptySearchUntil==0 && evidence.IdentifiedSubject==Enemy,
            "native collision callback immediately recognizes direct contact");
        Empty();Ally.SetOrigin((100,0,0),false);
        let encounter=CaelumSiegeEncounter(Actor.Spawn('CaelumSiegeEncounter',(0,0,0),NO_REPLACE));
        let command=new('CaelumSiegeCombatant');command.Body=Ally;command.Encounter=encounter;command.CommandLeader=command;
        let member=new('CaelumSiegeCombatant');member.Body=Observer;member.Encounter=encounter;member.CommandLeader=command;
        Observer.SiegeCombatant=member;Ally.SiegeCombatant=command;
        let packet=new('CaelumPerceptionRecord');packet.Subject=Enemy;packet.Position=Enemy.Pos;
        packet.ObservedTic=level.time;packet.OriginalWitness=Ally;
        bool delivered=CaelumCommunication.Receive(Observer,Ally,packet,true);
        Check(delivered && evidence.EmptySearchUntil==0 && evidence.GetMemory().Find(Enemy)!=null,
            "valid audible order wakes and retains original recorded point");
        evidence.EmptySearchUntil=level.time+5;
        Check(!CaelumVisualPerception.ReuseEmptySearch(Observer,evidence),"fresh private memory prevents throttling");
        Check(!Observer.bNoInteraction && Observer.bSolid && Observer.bShootable,"candidate never sleeps or unlinks physical actor");
        Console.Printf("CA433 RESULT wake checks complete passes=%d failures=%d",Passes,Failures);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=='ca433_seed')Seed();
        if(e.Name=='ca433_reload')
        {
            let evidence=Observer.VisualEvidence;
            Check(evidence.EmptySearchUntil==0 && !evidence.CandidateCacheReady,"save reload rebuilds only disposable query caches");
            Check(evidence.GetMemory().Find(Enemy)!=null,"save reload preserves private evidence");
            Console.Printf("CA433 RESULT reload complete passes=%d failures=%d",Passes,Failures);
        }
    }
}
