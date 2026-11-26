class CA838ResidentProbe : CaelumAnchoredResident
{
    Default { Health 100; Radius 16; Height 56; +SHOOTABLE +ISMONSTER +NOGRAVITY }
    override void PostBeginPlay() {} override void Tick() {}
    States { Spawn: TNT1 A -1; Stop; }
}
class CA838SummonedProbe : CaelumSummonedZupay
{
    Default { Health 100; Radius 16; Height 56; +SHOOTABLE +ISMONSTER +NOGRAVITY }
    override void PostBeginPlay() {} override void Tick() {}
    States { Spawn: TNT1 A -1; Stop; }
}
class CA838AutomatonProbe : CaelumTarotAutomaton
{
    Default { Health 100; Radius 16; Height 56; +SHOOTABLE +ISMONSTER +NOGRAVITY }
    override void PostBeginPlay() {} override void Tick() {}
    States { Spawn: TNT1 A -1; Stop; }
}
class CA838CloneProbe : CaelumTarotClone
{
    Default { Health 100; Radius 16; Height 56; +SHOOTABLE +ISMONSTER +NOGRAVITY }
    override void PostBeginPlay() {} override void Tick() {}
    States { Spawn: TNT1 A -1; Stop; }
}
class CA838RelationEdges : EventHandler
{
    int Checks,Failures;
    void Assert(bool okay,String label)
    {
        Checks++;if(!okay)Failures++;
        Console.Printf("CA836 EDGE %s relation: %s",okay?"PASS":"FAIL",label);
    }
    CaelumCombatActor Fresh(class<Actor> kind)
    {
        let body=CaelumCombatActor(Actor.Spawn(kind,(0,0,0),NO_REPLACE));
        body.CombatEffectiveInsight=0;body.CombatAgility=0;body.Angle=0;body.bFriendly=true;
        body.bDormant=false;body.bShootable=true;body.health=100;body.Height=56;
        body.ForcedSleepTics=0;body.CombatLucidityPhysicalStunRemaining=0;
        body.SiegeCombatant=new('CaelumSiegeCombatant');let entry=body.SiegeCombatant;
        entry.Body=body;entry.CommandLeader=entry;
        entry.Encounter=CaelumSiegeEncounter(Actor.Spawn('CA836FrozenPort',(-1800,-1800,0),NO_REPLACE));
        entry.GroupCandidates=new('CaelumCommandCandidates');
        return body;
    }
    void ClearCache(CaelumCombatActor body)
    {
        let evidence=CaelumVisualPerception.Evidence(body);
        evidence.PreviousSampleVisible=false;evidence.CandidateCacheReady=false;
    }
    void Fill(CaelumCombatActor body,Actor first,Actor second)
    {
        let group=body.SiegeCombatant.GroupCandidates;
        group.Candidates.Clear();group.Candidates.Push(first);group.Candidates.Push(second);
        group.Ready=true;group.SampleTic=level.time;ClearCache(body);
    }
    void Same(CaelumCombatActor body,Actor first,Actor second,Actor expected,String label)
    {
        Fill(body,first,second);
        Assert(CaelumCommunication.CandidatesFor(body)==body.SiegeCombatant.GroupCandidates,String.Format("%s uses shared query",label));
        Actor original=CA838BaselinePerception.Candidate(body);ClearCache(body);
        Actor current=CaelumVisualPerception.Candidate(body);
        Assert(original==expected && current==expected,label);
    }
    void Retire(CaelumCombatActor body)
    {body.SiegeCombatant.Encounter.Destroy();body.Destroy();}
    void Suite()
    {
        let population=CaelumPopulationState.Get();bool dense=population.HighDensity;population.HighDensity=true;
        let user=CaelumPlayer(players[0].mo);user.SetOrigin((1800,0,0),false);
        let body=Fresh('CA836VisionProbe');
        let near=Fresh('CA836VisionProbe');near.SetOrigin((256,0,0),false);near.bFriendly=false;
        let far=Fresh('CA836VisionProbe');far.SetOrigin((1800,0,0),false);far.bFriendly=false;
        Same(body,null,far,null,"null and remote candidate");
        Same(body,far,near,near,"remote before visible opponent");
        Same(body,near,far,near,"visible before remote opponent");
        far.SetOrigin((256,0,0),false);Same(body,far,near,far,"equal distance keeps first");
        Same(body,near,far,near,"equal distance reversed");
        near.health=0;Same(body,near,far,far,"dead entry before living");near.health=100;
        near.bFriendly=true;far.SetOrigin((1800,0,0),false);
        Same(body,near,far,null,"friendly entry rejected");
        near.bFriendly=false;
        user.SetOrigin((256,0,0),false);Same(body,user,null,user,"player relation remains exact");
        body.TheftTarget=user;Same(body,user,null,user,"theft target remains visible");body.TheftTarget=null;
        let emperor=CaelumTarotEmperorBody.Get(body);int slot=user.PlayerNumber();
        emperor.Sources[slot]=user;emperor.Remaining[slot]=1;
        Same(body,user,null,null,"Emperor blocks player");emperor.Remaining[slot]=0;
        user.SetOrigin((1800,0,0),false);
        Array<class<Actor> > kinds;
        kinds.Push('CA838ResidentProbe');kinds.Push('CA838SummonedProbe');kinds.Push('CA838AutomatonProbe');kinds.Push('CA838CloneProbe');
        for(int i=0;i<kinds.Size();i++)
        {
            let special=Fresh(kinds[i]);
            Same(special,far,null,null,String.Format("fallback %d remote",i));
            Actor expected=i<2?near:null;
            Same(special,near,far,expected,String.Format("fallback %d nearby",i));
            Retire(special);
        }
        let resident=CA838ResidentProbe(Fresh('CA838ResidentProbe'));
        resident.EscortPrisonerPort=true;resident.EscortPrisonerId=CaelumConstants.PRISONER_UNITARIO;
        let record=user.GetPersistentCharacterState(true);
        Assert(record!=null && CaelumPlayerAuthority.CanMutate(user),"resident migration prerequisite");
        record.LandMaterialSchemaRevision=0;Fill(resident,user,null);
        Actor ignored=CaelumVisualPerception.Candidate(resident);
        Assert(ignored==null && record.LandMaterialSchemaRevision==CaelumLandResourceData.REVISION,"remote resident preserves material migration");
        // A delegated target lookup may consult the candidate resident as observer.
        let machine=CA838AutomatonProbe(Fresh('CA838AutomatonProbe'));machine.Caster=user;
        resident.SetOrigin((1800,0,0),false);record.LandMaterialSchemaRevision=0;Fill(machine,resident,null);
        ignored=CaelumVisualPerception.Candidate(machine);
        Assert(ignored==null && record.LandMaterialSchemaRevision==CaelumLandResourceData.REVISION,"remote automaton delegation preserves migration");
        Retire(machine);Retire(resident);Retire(body);Retire(near);Retire(far);
        user.SetOrigin((-1700,-1700,0),false);population.HighDensity=dense;
        Console.Printf("CA836 EDGE_RESULT relation_checks=%d failures=%d result=%s",Checks,Failures,Failures==0?"PASS":"FAIL");
    }
    override void NetworkProcess(ConsoleEvent e)
    {if(e.Name=='ca836seed' || e.Name=='ca836reload')Suite();}
}
