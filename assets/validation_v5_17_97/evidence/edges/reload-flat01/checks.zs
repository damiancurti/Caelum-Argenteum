class CA836FrozenPort : CaelumPortSiege { override void PostBeginPlay() {} override void Tick() {} }
class CA836VisionProbe : CaelumCombatActor
{
    Default { Health 100; Radius 16; Height 56; +SHOOTABLE +ISMONSTER +NOGRAVITY }
    override void Tick() {}
    States { Spawn: TNT1 A -1; Stop; }
}
class CA836VisionEdges : EventHandler
{
    CA836VisionProbe Observer,Subject;
    int Checks,Failures;
    bool Known(Actor subject)
    {
        let population=CaelumPopulationState.Get();if(population==null)return false;
        bool originalDense=population.HighDensity;population.HighDensity=true;
        if(Observer.SiegeCombatant==null)
        {
            Observer.SiegeCombatant=new("CaelumSiegeCombatant");
            let entry=Observer.SiegeCombatant;entry.Body=Observer;entry.CommandLeader=entry;
            entry.Encounter=CaelumSiegeEncounter(Actor.Spawn('CA836FrozenPort',(-1800,-1800,0),NO_REPLACE));
            entry.GroupCandidates=new("CaelumCommandCandidates");
        }
        let group=Observer.SiegeCombatant.GroupCandidates;
        group.Candidates.Clear();group.Candidates.Push(subject);group.Ready=true;group.SampleTic=level.time;
        let evidence=CaelumVisualPerception.Evidence(Observer);evidence.CandidateCacheReady=false;evidence.PreviousSampleVisible=false;
        Observer.bFriendly=true;
        Actor found=CaelumVisualPerception.Candidate(Observer);
        population.HighDensity=originalDense;
        return found==subject;
    }
    void Check(bool expected,String label)
    {
        bool ordinary=CaelumVisualPerception.CanSee(Observer,Subject);
        bool known=Known(Subject);Checks++;
        bool okay=ordinary==expected && known==expected;
        if(!okay)Failures++;
        Console.Printf("CA836 EDGE %s %s",okay?"PASS":"FAIL",label);
    }
    void Suite(bool restored)
    {
        if(restored)
        {
            bool okay=Observer!=null && Subject!=null && Observer.health==100 && Subject.health==100
                && Subject.Pos==(256,0,0) && Observer.CombatEffectiveInsight==0 && Subject.CombatAgility==0;
            Checks++;if(!okay)Failures++;
            Console.Printf("CA836 EDGE %s saved probes retained",okay?"PASS":"FAIL");
            if(!okay)return;
        }
        else
        {
            let user=CaelumPlayer(players[0].mo);user.player.cheats|=CF_GODMODE;user.SetOrigin((-1700,-1700,0),false);
            Observer=CA836VisionProbe(Actor.Spawn('CA836VisionProbe',(0,0,0),NO_REPLACE));
            Subject=CA836VisionProbe(Actor.Spawn('CA836VisionProbe',(256,0,0),NO_REPLACE));
        }
        Observer.CombatEffectiveInsight=0;Subject.CombatAgility=0;Observer.Angle=0;
        Observer.CurSector.SetLightLevel(255);
        Check(true,"front visible");Observer.Angle=180;Check(false,"behind");
        Observer.Angle=90;Check(true,"inclusive field edge");Observer.Angle=0;
        Subject.SetOrigin((1024,0,0),false);Check(true,"inclusive range edge");
        Subject.SetOrigin((1024.001,0,0),false);Check(false,"outside range edge");
        Observer.CombatEffectiveInsight=100;Check(true,"insight changes immediately");
        Observer.CombatEffectiveInsight=0;Subject.SetOrigin((256,0,0),false);
        Observer.CurSector.SetLightLevel(0);Check(false,"darkness changes immediately");Observer.CurSector.SetLightLevel(255);
        Subject.SetOrigin((700,0,0),false);Subject.Height=28;Check(false,"height changes immediately");Subject.Height=56;
        Subject.SetOrigin((256,0,0),false);Subject.CombatAgility=100;Check(false,"full stealth");
        Subject.SetOrigin((32,0,0),false);Observer.Angle=180;Check(true,"contact behind despite stealth");
        Subject.CombatAgility=0;Observer.Angle=0;Observer.SetOrigin((384,768,0),false);Subject.SetOrigin((704,768,0),false);
        Check(false,"solid pillar");Observer.SetOrigin((0,0,0),false);Subject.SetOrigin((256,0,0),false);
        Observer.bDormant=true;Check(false,"dormant");Observer.bDormant=false;
        Observer.ForcedSleepTics=1;Check(false,"sleeping");Observer.ForcedSleepTics=0;
        Observer.CombatLucidityPhysicalStunRemaining=1;Check(false,"stunned");Observer.CombatLucidityPhysicalStunRemaining=0;
        Observer.health=0;Check(false,"dead observer");Observer.health=100;
        Subject.health=0;Check(false,"dead subject");Subject.health=100;
        Check(true,"conditions restored");
        Subject.SetOrigin((1800,0,0),false);Check(false,"far X beyond broadphase");
        Subject.SetOrigin((0,1800,0),false);Observer.Angle=90;Check(false,"far Y beyond broadphase");
        Subject.SetOrigin((900,900,0),false);Observer.Angle=45;Check(false,"diagonal retained for exact distance");
        Subject.SetOrigin((1500,0,0),false);Subject.Height=112;Observer.Angle=0;Check(true,"tall target retained immediately");
        Subject.Height=56;Check(false,"target shrinks immediately");
        Observer.CombatEffectiveInsight=100;Check(true,"far target becomes visible after insight change");
        Observer.CombatEffectiveInsight=0;Subject.CombatAgility=100;Subject.Height=1;Subject.SetOrigin((32.005,0,0),false);Observer.Angle=180;
        Check(true,"contact margin behind with minimal height");
        Subject.SetOrigin((32.02,0,0),false);Check(false,"outside contact margin in full stealth");
        Subject.CombatAgility=0;Subject.Height=56;Subject.SetOrigin((256,0,0),false);Observer.Angle=0;

        Console.Printf("CA836 EDGE_RESULT checks=%d failures=%d result=%s",Checks,Failures,Failures==0?"PASS":"FAIL");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca836seed")Suite(false);
        if(e.Name=="ca836reload")Suite(true);
    }
}

// #425: filtros baratos antes de CheckSight; consultas espaciales, no censos por NPC.
class CA838BaselinePerception : Object play
{
    static bool Living(Actor body)
    { return body!=null && !body.bDestroyed && body.health>0 && body.bShootable; }

    static double VisibleHeight(Actor body)
    { return body==null ? 0.0 : Max(0.0,body.Height); }

    static double Stealth(Actor body)
    {
        let user=CaelumPlayer(body);
        if(user!=null)return Clamp(user.EffectiveStealthPercent,0.0,100.0);
        let npc=CaelumCombatActor(body);
        if(npc==null)return 0;
        if(!npc.VisualStealthReady || npc.VisualStealthKey!=npc.CombatAgility)
        {
            npc.VisualStealthKey=npc.CombatAgility;
            npc.VisualStealthPercent=Clamp(npc.CalculateActorType2Percent(npc.CombatAgility),0.0,100.0);
            npc.VisualStealthReady=true;
        }
        return npc.VisualStealthPercent;
    }

    static double InsightFactor(CaelumCombatActor observer)
    {
        if(observer==null)return 1;
        if(!observer.VisualInsightReady || observer.VisualInsightKey!=observer.CombatEffectiveInsight)
        {
            observer.VisualInsightKey=observer.CombatEffectiveInsight;
            observer.VisualInsightFactor=CaelumGrowthRules.Multiplier(observer.CombatEffectiveInsight,2);
            observer.VisualInsightReady=true;
        }
        return observer.VisualInsightFactor;
    }

    static double Range(CaelumCombatActor observer,Actor candidate)
    {
        if(candidate==null)return 0;
        double light=candidate.CurSector==null ? 0.0 : Clamp(double(candidate.CurSector.lightlevel),0.0,CaelumPerceptionData.NATIVE_FULL_LIGHT);
        double illumination=CaelumPerceptionData.DARK_RANGE_FACTOR
            +(1.0-CaelumPerceptionData.DARK_RANGE_FACTOR)*light/CaelumPerceptionData.NATIVE_FULL_LIGHT;
        return CaelumPhysicsUnits.MapUnits(CaelumPerceptionData.VISUAL_BASE_METERS)
            *InsightFactor(observer)*illumination
            *VisibleHeight(candidate)/CaelumPerceptionData.REFERENCE_VISIBLE_HEIGHT
            *(1.0-Stealth(candidate)/100.0);
    }

    static bool Touching(Actor observer,Actor candidate)
    {
        return observer!=null && Living(candidate) && observer!=candidate
            && observer.Distance2D(candidate)<=observer.Radius+candidate.Radius+CaelumPerceptionData.CONTACT_MARGIN
            && observer.Pos.Z<candidate.Pos.Z+candidate.Height
            && candidate.Pos.Z<observer.Pos.Z+observer.Height
            && observer.CheckSight(candidate,SF_IGNOREVISIBILITY);
    }

    // #454: Candidate ya calcula esta distancia nativa en la misma iteración.
    // Reutilizarla no conserva posiciones entre tics ni cambia los filtros.
    static bool CanSee(CaelumCombatActor observer,Actor candidate,double knownDistance=-1)
    {
        if(!Living(observer) || !Living(candidate) || observer==candidate || observer.bDormant
            || observer.ForcedSleepTics>0 || observer.CombatLucidityPhysicalStunRemaining>0)return false;
        if(Touching(observer,candidate))return true;
        if(Abs(observer.DeltaAngle(observer.Angle,observer.AngleTo(candidate)))>CaelumPerceptionData.VISUAL_FIELD_DEGREES/2)return false;
        if((knownDistance>=0 ? knownDistance : observer.Distance3D(candidate))>Range(observer,candidate))return false;
        return observer.CheckSight(candidate);
    }

    // La relación real autoriza combatir; nunca se deduce por ropa o apariencia.
    static bool Opponent(CaelumCombatActor observer,Actor candidate)
    {
        if(!Living(candidate) || observer==candidate || CaelumTarotEmperor.Blocks(observer,candidate))return false;
        let summoned=CaelumSummonedZupay(observer);
        if(summoned!=null && CaelumTarotEmperor.Commander(observer)!=null)
            return CaelumMajorTargets.Enemy(summoned.Commander(),candidate);
        let machine=CaelumTarotAutomaton(observer);
        if(machine!=null)return machine.Caster!=null && CaelumMajorTargets.Enemy(machine.Caster,candidate);
        let automaton=CaelumTarotAutomaton(candidate);
        if(automaton!=null && automaton.Caster!=null)return RelatedOpponent(observer,automaton.Caster);
        let clone=CaelumTarotClone(observer);
        if(clone!=null)return CaelumMajorTargets.Enemy(clone.Caster,candidate);
        let image=CaelumTarotClone(candidate);
        if(image!=null)return RelatedOpponent(observer,image.Caster);
        return RelatedOpponent(observer,candidate);
    }

    // La pacificación impide atacar al lanzador; no vuelve aliado a su receptor.
    static bool RelatedOpponent(CaelumCombatActor observer,Actor candidate)
    {
        if(observer==null || !Living(candidate) || observer==candidate)return false;
        let resident=CaelumAnchoredResident(observer);
        let user=CaelumPlayer(candidate);
        if(resident!=null && user!=null)
            return resident.TheftTarget==user || resident.CanBeFactionTarget(user);
        if(observer.TheftTarget==candidate)return true;
        if(observer.SiegeCombatant!=null)
            return user!=null || (candidate is "CaelumCombatActor" && candidate.bFriendly!=observer.bFriendly);
        if(user!=null)return !observer.bFriendly;
        return candidate is "CaelumCombatActor" && (observer.IsHostile(candidate)
            || (observer.bFriendly!=candidate.bFriendly && !observer.IsFriend(candidate)));
    }

    static double QueryRadius(CaelumCombatActor observer)
    {
        let population=CaelumPopulationState.Get();
        double height=population!=null ? population.PerceptionMaximumHeight : CaelumPerceptionData.REFERENCE_VISIBLE_HEIGHT;
        return CaelumPhysicsUnits.MapUnits(CaelumPerceptionData.VISUAL_BASE_METERS)
            *InsightFactor(observer)*height/CaelumPerceptionData.REFERENCE_VISIBLE_HEIGHT;
    }

    // #836: cota exterior conservadora; no concede visibilidad ni identidad.
    // Solo se usa sin grupos de portales enlazados. Los radios y el margen
    // de contacto mantienen dentro de la cota todo contacto fisico posible.
    static bool OutsideGroupReach(CaelumCombatActor observer,Actor candidate,double sightUpper)
    {
        double reach=sightUpper*Max(0.0,candidate.Height)/CaelumPerceptionData.REFERENCE_VISIBLE_HEIGHT
            +Max(0.0,observer.Radius)+Max(0.0,candidate.Radius)+CaelumPerceptionData.CONTACT_MARGIN;
        return Abs(observer.Pos.X-candidate.Pos.X)>reach || Abs(observer.Pos.Y-candidate.Pos.Y)>reach;
    }

    static Actor Candidate(CaelumCombatActor observer)
    {
        let evidence=Evidence(observer);
        if(observer.PendingTheftTarget!=null && CanSee(observer,observer.PendingTheftTarget))return observer.PendingTheftTarget;
        Actor current=evidence.PreviousSampleVisible && CaelumPerceptionMemoryData.Fresh(evidence.LastVisualTic) ? evidence.Subject : null;
        if(Opponent(observer,current) && CanSee(observer,current))return current;
        if(evidence.CandidateCacheReady && evidence.CandidateCacheTic==level.time)
            return Opponent(observer,evidence.CandidateCache) && CanSee(observer,evidence.CandidateCache) ? evidence.CandidateCache : null;
        Actor nearest;double best=1e30;
        CaelumCombatActor ally;double allyDistance=1e30;
        let group=CaelumCommunication.CandidatesFor(observer);
        if(group!=null)
        {
            double sightUpper=level.GetPortalGroupCount()==1
                ? CaelumPhysicsUnits.MapUnits(CaelumPerceptionData.VISUAL_BASE_METERS)*InsightFactor(observer) : -1;
            // La lista espacial se comparte; cada miembro conserva sus filtros
            // visuales y dos segundos propios. No constituye un aviso audible.
            for(int i=0;i<group.Candidates.Size();i++)
            {
                let candidate=group.Candidates[i];
                if(!Opponent(observer,candidate))continue;
                if(sightUpper>=0 && OutsideGroupReach(observer,candidate,sightUpper))continue;
                double distance=observer.Distance3D(candidate);
                if(distance<best && CanSee(observer,candidate,distance)){nearest=candidate;best=distance;}
            }
            for(int i=0;i<group.Members.Size();i++)
            {
                let entry=group.Members[i];let friend=entry!=null ? entry.Body : null;
                if(friend==observer || !Living(friend))continue;
                if(sightUpper>=0 && OutsideGroupReach(observer,friend,sightUpper))continue;
                double distance=observer.Distance3D(friend);
                if(distance<allyDistance && CanSee(observer,friend,distance)){ally=friend;allyDistance=distance;}
            }
            if(ally!=null)CaelumCommunication.ObserveAlly(observer,ally);
            evidence.CandidateCache=nearest;evidence.CandidateCacheTic=level.time;evidence.CandidateCacheReady=true;
            return nearest;
        }
        let local=BlockThingsIterator.Create(observer,QueryRadius(observer));
        while(local.Next())
        {
            let candidate=local.thing;
            if(!Opponent(observer,candidate))
            {
                let friend=CaelumCombatActor(candidate);
                if(friend!=null && CaelumCommunication.Eligible(observer,friend))
                {
                    double distance=observer.Distance3D(friend);
                    if(distance<allyDistance && CanSee(observer,friend,distance)){ally=friend;allyDistance=distance;}
                }
                continue;
            }
            double distance=observer.Distance3D(candidate);
            if(distance>=best || !CanSee(observer,candidate,distance))continue;
            nearest=candidate;best=distance;
        }
        // Los guardias estacionados carecen de blockmap. Reutilizar la lista
        // tipada del censo compartido; jamás iniciar otro recorrido global.
        let population=CaelumPopulationState.Get();
        if(population!=null)for(int i=0;i<population.UnlinkedGuards.Size();i++)
        {
            let entry=population.UnlinkedGuards[i];
            let candidate=entry!=null ? entry.Body : null;
            if(!Opponent(observer,candidate))continue;
            double distance=observer.Distance3D(candidate);
            if(distance>=best || !CanSee(observer,candidate,distance))continue;
            nearest=candidate;best=distance;
        }
        if(ally!=null)CaelumCommunication.ObserveAlly(observer,ally);
        evidence.CandidateCache=nearest;evidence.CandidateCacheTic=level.time;evidence.CandidateCacheReady=true;
        return nearest;
    }

    static bool Identify(CaelumCombatActor observer,Actor candidate)
    {
        if(observer==null)return false;
        if(candidate is "CaelumSearchPoint")return false;
        if(observer.IsCaelumMassDiagnosticActor())return candidate!=null;
        return Evidence(observer).Observe(observer,candidate) && CaelumCommunication.MayEngage(observer,candidate);
    }

    static Actor Acquire(CaelumCombatActor observer,Actor hint=null)
    {
        let evidence=Evidence(observer);let memory=evidence.GetMemory();
        Actor candidate=CaelumTarotEmperor.CommandCandidate(observer);
        if(candidate==null)
        {
            memory.ChooseFocus(observer);
            if(memory.HasFocus(observer))candidate=memory.Focus;
            else candidate=hint!=null && CanSee(observer,hint) ? hint : Candidate(observer);
        }
        if(Identify(observer,candidate) && Opponent(observer,candidate))
        {memory.Focus=candidate;memory.ClearGoal(observer);return candidate;}
        return null;
    }

    static void Look(CaelumCombatActor observer)
    {
        observer.LastEnemy=null;
        observer.target=Acquire(observer);
        if(observer.target==null)observer.target=SearchGoal(observer);
        if(observer.target!=null && observer.SeeState!=null)observer.SetState(observer.SeeState);
    }

    static Actor SearchGoal(CaelumCombatActor body)
    {
        // Una orden visible aún en reconocimiento no se abandona por un ruido anterior.
        if(CaelumTarotEmperor.CommandCandidate(body)!=null)return null;
        let evidence=Evidence(body);return evidence.GetMemory().Search(body,evidence);
    }

    static bool SearchPulse(CaelumCombatActor body)
    {
        Actor goal=SearchGoal(body);if(goal==null)return false;
        body.target=goal;body.LastEnemy=null;
        if(body.SeeState!=null && !body.InStateSequence(body.CurState,body.SeeState))body.SetState(body.SeeState);
        else body.ThermalChase(null,null,CHF_DONTLOOKALLAROUND);
        return true;
    }

    static CaelumVisualEvidence Evidence(CaelumCombatActor body)
    {
        if(body==null)return null;
        if(body.VisualEvidence==null)
        {
            body.VisualEvidence=new("CaelumVisualEvidence");body.VisualEvidence.Initialize();
            // El autor pidió reiniciar percepción vieja, no recursos ni destinos de ruta.
            if(body.target is "CaelumCombatActor" || body.target is "CaelumPlayer")body.target=null;
            body.LastEnemy=null;
            body.bJustHit=false;body.bJustAttacked=false;body.bInCombat=false;
            let resident=CaelumAnchoredResident(body);if(resident!=null)resident.FactionTarget=null;
        }
        return body.VisualEvidence;
    }
}

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
