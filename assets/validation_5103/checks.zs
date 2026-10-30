class CA428Probe : CaelumCombatActor
{
    override void Tick() { if(GetClassName()!='CA428Probe')Super.Tick(); }
    Default { Health 100; Radius 16; Height 56; Speed 4; +SHOOTABLE +SOLID +ISMONSTER }
    States { Spawn: TNT1 A -1; Stop; See: TNT1 A -1; Stop; }
}

class CA428LiveProbe : CA428Probe
{
    States { Spawn: TNT1 A 3 A_CaelumBudgetedLook; Loop; See: TNT1 A 3 A_CaelumBudgetedChase; Loop; }
}

class CA428UnlinkedProbe : CA428Probe
{
    override void Tick() { }
    Default { +NOBLOCKMAP }
}

class CA428RoutePort : CaelumPortSiege
{
    override void PostBeginPlay() { }
    override void Tick() { }
}

class CA428Checks : EventHandler
{
    CA428Probe Leader,Member,Receiver,Stranger,Threat,Second;
    CaelumSiegeEncounter Encounter;
    int Stage,Start,OriginalTic,Passes,Failures;
    vector3 OriginalPoint;

    void Check(bool ok,String label)
    {if(ok){Passes++;Console.Printf("CA428 PASS %s",label);}else{Failures++;Console.Printf("CA428 FAIL %s",label);}}

    CA428Probe Body(vector3 point,bool friendly=false,bool live=false,bool unlinked=false)
    {
        let body=CA428Probe(Actor.Spawn(unlinked ? "CA428UnlinkedProbe" : live ? "CA428LiveProbe" : "CA428Probe",point,NO_REPLACE));
        body.bFriendly=friendly;body.Angle=0;body.CombatEffectiveInsight=0;body.CombatAgility=0;
        CaelumVisualPerception.Evidence(body);return body;
    }

    void Group(CA428Probe body)
    {
        let entry=new("CaelumSiegeCombatant");entry.Body=body;entry.Encounter=Encounter;
        body.SiegeCombatant=entry;
        entry.CommandLeader=body==Leader ? entry : Leader.SiegeCombatant;
    }

    void Seed()
    {
        let user=CaelumPlayer(players[0].mo);user.bNoClip=true;user.SetOrigin((-1500,-1500,0),false);user.bShootable=false;
        Encounter=CaelumSiegeEncounter(Actor.Spawn("CaelumSiegeEncounter",(-1600,0,0),NO_REPLACE));
        Leader=Body((0,0,0));Group(Leader);
        Member=Body((0,200,0));Group(Member);
        Receiver=Body((0,450,0),false,false,true);Group(Receiver);
        Stranger=Body((0,650,0));Threat=Body((300,0,0),true);
        Start=level.time;Stage=1;Passes=Failures=0;
    }

    void Reports()
    {
        let evidence=CaelumVisualPerception.Evidence(Member);
        let packet=evidence.GetMemory().Find(Threat);
        Check(packet!=null,"member identifies after real two-second observation");
        Check(!CaelumCommunication.MayEngage(Member,Threat),"direct sight alone does not invent leader order");
        OriginalTic=packet.ObservedTic;OriginalPoint=packet.Position;
        Check(CaelumCommunication.Emit(Member,packet),"audible member report reaches leader");
        let received=CaelumVisualPerception.Evidence(Leader).GetMemory().Find(Threat);
        Check(received!=null && received.Reporter==Member && received.OriginalWitness==Member,
            "report preserves original witness and immediate reporter");
        Check(CaelumVisualPerception.Evidence(Receiver).GetMemory().Find(Threat)==null,
            "member report does not become an order to everyone");
        Check(CaelumVisualPerception.Evidence(Stranger).HasHeardNoise
            && CaelumVisualPerception.Evidence(Stranger).GetMemory().Find(Threat)==null,
            "unrelated listener hears anonymous shout without identity");
        Threat.SetOrigin((1100,-1000,0),false);Threat.CombatAgility=100;
        Check(CaelumCommunication.Emit(Leader,received),"leader emits actual audible order");
        received=CaelumVisualPerception.Evidence(Receiver).GetMemory().Find(Threat);
        Check(received!=null && received.Position==OriginalPoint && received.ObservedTic==OriginalTic
            && received.OrderObservedTic==OriginalTic && received.OriginalWitness==Member,
            "order copies original position and age despite hidden movement");
        Check(CaelumCommunication.MayEngage(Receiver,Threat),"heard order authorizes its identified target");
        Check(Receiver.bNoBlockmap,"stationed recipient reached through existing typed fallback");
        Check(!CaelumCommunication.Eligible(Leader,Threat),"opposing body is not a recipient");
        Check(CaelumCommunicationData.AlliedFactions(CaelumConstants.FACTION_UNITARIOS,CaelumConstants.FACTION_UNITARIOS)
            && !CaelumCommunicationData.AlliedFactions(CaelumConstants.FACTION_UNITARIOS,CaelumConstants.FACTION_FEDERALS)
            && !CaelumCommunicationData.AlliedFactions(-1,-1),"only confirmed same-faction relationship is currently allied");
        Check(!CaelumVisualPerception.Identify(Receiver,Threat),"order does not allow firing at unseen body");
        let goal=CaelumVisualPerception.SearchGoal(Receiver);
        Check(goal!=null && goal.Pos==OriginalPoint,"recipient investigates recorded point");
        Check(!CaelumCommunication.Emit(Leader,received),"five-second shout throttle");
        Check(CaelumCommunication.Pending(Member)==null,"member does not echo evidence already known by leader");
        let older=new("CaelumPerceptionRecord");older.Subject=Threat;older.Position=(-500,500,0);
        older.ObservedTic=OriginalTic-1;older.OriginalWitness=Member;
        CaelumCommunication.Receive(Receiver,Leader,older,true);
        Check(received.Position==OriginalPoint && received.ObservedTic==OriginalTic,"old report cannot replace newer point");
        older.ObservedTic=OriginalTic;
        CaelumCommunication.Receive(Receiver,Leader,older,true);
        Check(received.Position==OriginalPoint,"equal-age duplicate cannot change point");
        Check(!CaelumCommunication.Receive(Stranger,Leader,received,true),"generic friendly flag does not grant membership");
        Stage=2;Start=level.time;
    }

    void SecondOrder()
    {
        Second=Body((300,450,0),true);
        let memory=CaelumVisualPerception.Evidence(Leader).GetMemory();
        memory.Remember(Second,Second.Pos,level.time,Leader);
        Check(CaelumCommunication.Emit(Leader,memory.Find(Second)),"new evidence can be ordered after five seconds");
        let first=CaelumVisualPerception.Evidence(Member).GetMemory();first.ChooseFocus(Member);
        let otherMemory=CaelumVisualPerception.Evidence(Receiver).GetMemory();otherMemory.ChooseFocus(Receiver);
        Check(first.Focus==Threat && otherMemory.Focus==Second,"members choose nearest communicated point independently");
        Leader.health=0;
        Check(!CaelumCommunication.MayEngage(Member,Threat),"dead leader does not convert missing orders into permission");
        Leader.health=100;
        Leader.SetOrigin((-1800,-1000,0),false);Member.SetOrigin((1800,1000,0),false);
        let packet=first.Find(Threat);
        Check(!CaelumCommunication.Receive(Member,Leader,packet,true),"out-of-range order is not delivered");
        Leader.SetOrigin((384,768,0),false);Member.SetOrigin((1000,768,0),false);
        Check(!CaelumCommunication.Receive(Member,Leader,packet,true),"occluded order uses quarter hearing range");
        Leader.SetOrigin((0,0,0),false);Member.SetOrigin((0,200,0),false);
        Check(!CaelumCommunication.Receive(Member,Stranger,packet,true),"unauthorized sender cannot forge order");
        Stage=3;Start=level.time;
    }

    void Expired()
    {
        let memory=CaelumVisualPerception.Evidence(Receiver).GetMemory();
        Check(memory.Find(Threat)==null,"forwarding and saving do not renew original thirty seconds");
        Check(!CaelumCommunication.MayEngage(Receiver,Threat),"expired order grants no attack permission");
        let expired=new("CaelumPerceptionRecord");expired.Subject=Threat;expired.Position=OriginalPoint;
        expired.ObservedTic=OriginalTic;
        Check(!CaelumCommunication.Receive(Receiver,Leader,expired,true),"expired packet is rejected at delivery");
        Stage=0;Console.Printf("CA428 RESULT reports complete passes=%d failures=%d",Passes,Failures);
    }

    void Help()
    {
        Seed();Stage=0;
        let communication=CaelumCommunication.StateFor(Member);
        communication.RememberedAlly=Leader;communication.AllyPosition=(-1200,200,0);communication.AllyObservedTic=level.time;
        Leader.SetOrigin((-1800,1200,0),false);Member.SetOrigin((1200,200,0),false);Member.Angle=0;
        let memory=CaelumVisualPerception.Evidence(Member).GetMemory();
        memory.Remember(Threat,(1500,200,0),level.time,Member);
        Member.EnsureRecoveryRevision();Member.MaximumCombatAir=Member.MaximumCombatAnima=100;
        Member.CurrentCombatAir=Member.CurrentCombatAnima=0;Member.RecoveryPhase=1;Member.RecoveryThreat=Threat;
        vector3 before=Member.Pos;
        Check(Member.PulseResourceRecovery(),"existing resource retreat calls help integration");
        Check(Member.Pos.X<before.X && communication.HelpGoal!=null && communication.HelpGoal.Pos==communication.AllyPosition,
            "messenger moves toward remembered ally point, not hidden live position");
        Check(CaelumVisualPerception.Evidence(Leader).GetMemory().Find(Threat)==null,
            "walking messenger does not notify distant leader");
        communication.AllyObservedTic=level.time-CaelumPerceptionMemoryData.LIFETIME_SECONDS*TICRATE;
        Check(!CaelumCommunication.SeekHelp(Member) && communication.HelpGoal==null,"expired ally memory restores normal retreat");
        communication.AllyObservedTic=level.time;communication.LastShoutTic=level.time-CaelumCommunicationData.SHOUT_INTERVAL_SECONDS*TICRATE;
        Leader.SetOrigin((Member.Pos.X-300,Member.Pos.Y,0),false);
        Check(!CaelumCommunication.SeekHelp(Member) && communication.LastDeliverySucceeded,
            "warning delivered only after actual audible contact");
        let received=CaelumVisualPerception.Evidence(Leader).GetMemory().Find(Threat);
        Check(received!=null && received.ObservedTic==memory.Find(Threat).ObservedTic,
            "carried warning preserves original evidence age");
        let port=CA428RoutePort(Actor.Spawn("CA428RoutePort",(-1800,-1000,0),NO_REPLACE));
        port.RosterSealed=true;port.AttackingTarget[0]=Threat;
        Member.RecoveryPhase=0;Member.SiegeCombatant.Encounter=port;Member.SiegeCombatant.CommandLeader=Member.SiegeCombatant;
        Member.VisualEvidence=new("CaelumVisualEvidence");Member.VisualEvidence.Initialize();Member.Angle=0;
        Check(port.IndividualAttackerTarget(Member.SiegeCombatant)==null,
            "unseen legacy defender pointer is not a marching target");
        Check(CaelumPortSiege.Pulse(Member) && Member.target==Member.SiegeCombatant.NavigationTarget
            && Member.target.Pos==(CaelumPortData.GateX(0),CaelumPortData.GateY(),0),
            "army preserves authored gate route without an enemy observation");
        port.Attackers.Push(Member.SiegeCombatant);port.ElectCommands();
        let population=CaelumPopulationState.Get();bool previousDensity=population.HighDensity;population.HighDensity=true;
        let group=CaelumCommunication.CandidatesFor(Member);Member.VisualEvidence.CandidateCacheReady=false;
        Check(group!=null && group.Ready,"existing command roster supplies bounded high-density spatial cache");
        Check(CaelumVisualPerception.Candidate(Member)==null
            && Member.VisualEvidence.GetMemory().Find(Threat)==null,"shared candidates do not grant visual identity or orders");
        population.HighDensity=previousDensity;
        Console.Printf("CA428 RESULT help complete passes=%d failures=%d",Passes,Failures);
    }

    void Automatic()
    {
        let user=CaelumPlayer(players[0].mo);user.bNoClip=true;user.SetOrigin((-1500,-1500,0),false);user.bShootable=false;
        Encounter=CaelumSiegeEncounter(Actor.Spawn("CaelumSiegeEncounter",(-1600,0,0),NO_REPLACE));
        Leader=Body((0,0,0),false,true);Group(Leader);Leader.Angle=180;
        Member=Body((0,200,0),false,true);Group(Member);
        Receiver=Body((0,450,0),false,true);Group(Receiver);Receiver.Angle=180;
        Stranger=Body((0,650,0));Threat=Body((300,0,0),true);
        Start=level.time;Stage=4;Passes=Failures=0;
    }

    override void WorldTick()
    {
        if(Stage==1)
        {
            CaelumVisualPerception.Evidence(Member).Observe(Member,Threat);
            if(level.time-Start>=2*TICRATE)Reports();
        }
        else if(Stage==2 && level.time-Start>=5*TICRATE)SecondOrder();
        else if(Stage==3 && level.time-OriginalTic>=30*TICRATE)Expired();
        else if(Stage==4 && level.time-Start>=4*TICRATE)
        {
            let record=CaelumVisualPerception.Evidence(Receiver).GetMemory().Find(Threat);
            Check(record!=null && record.OrderLeader==Leader,"ordinary look/chase receives leader order automatically");
            Check(CaelumCommunication.StateFor(Member).HasShouted && CaelumCommunication.StateFor(Leader).HasShouted,
                "member report and leader reply run without diagnostic emit calls");
            Check(CaelumVisualPerception.Evidence(Stranger).GetMemory().Find(Threat)==null,
                "automatic communication preserves recipient eligibility");
            Stage=0;Console.Printf("CA428 RESULT automatic complete passes=%d failures=%d",Passes,Failures);
        }
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca428_seed")Seed();
        else if(e.Name=="ca428_help")Help();
        else if(e.Name=="ca428_auto")Automatic();
        else if(e.Name=="ca428_reload")
        {
            Check(Stage==3,"saved communication phase restored");
            let evidence=CaelumVisualPerception.Evidence(Receiver);let record=evidence.GetMemory().Find(Threat);
            Check(record!=null && record.ObservedTic==OriginalTic && record.Position==OriginalPoint
                && record.Reporter==Leader && record.OriginalWitness==Member,"saved evidence provenance retained");
            let communication=CaelumCommunication.StateFor(Leader);
            Check(communication.HasShouted && communication.LastShoutTic<level.time,"saved shout cooldown keeps original age");
        }
        else if(e.Name=="ca428_migration")
        {
            Check(Leader!=null && Leader.health==321,"legacy body preserved");
            let evidence=CaelumVisualPerception.Evidence(Leader);
            Check(evidence.Communication==null,"legacy save has no invented communications");
            let communication=CaelumCommunication.StateFor(Leader);
            Check(communication.Revision==1 && !communication.HasShouted,"lazy communication migration begins empty");
            let record=evidence.GetMemory().Find(Threat);
            Check(record!=null && record.Position==OriginalPoint && record.OrderLeader==null,
                "legacy private memory preserved without fabricated order");
            Check(CaelumCommunication.StateFor(Leader)==communication,"communication migration is idempotent");
            Console.Printf("CA428 RESULT migration complete passes=%d failures=%d",Passes,Failures);
        }
    }
}
