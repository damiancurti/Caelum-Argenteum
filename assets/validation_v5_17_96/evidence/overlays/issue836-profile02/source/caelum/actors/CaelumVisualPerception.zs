// #425: filtros baratos antes de CheckSight; consultas espaciales, no censos por NPC.
class CaelumVisualPerception : Object play
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

    static double ProfileBody836Range(CaelumCombatActor observer,Actor candidate)
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

    static bool ProfileBody836Touching(Actor observer,Actor candidate)
    {
        return observer!=null && Living(candidate) && observer!=candidate
            && observer.Distance2D(candidate)<=observer.Radius+candidate.Radius+0.01
            && observer.Pos.Z<candidate.Pos.Z+candidate.Height
            && candidate.Pos.Z<observer.Pos.Z+observer.Height
            && observer.CheckSight(candidate,SF_IGNOREVISIBILITY);
    }

    // #454: Candidate ya calcula esta distancia nativa en la misma iteración.
    // Reutilizarla no conserva posiciones entre tics ni cambia los filtros.
    static bool ProfileBody836CanSee(CaelumCombatActor observer,Actor candidate,double knownDistance=-1)
    {
        if(!Living(observer) || !Living(candidate) || observer==candidate || observer.bDormant
            || observer.ForcedSleepTics>0 || observer.CombatLucidityPhysicalStunRemaining>0)return false;
        if(Touching(observer,candidate))return true;
        if(Abs(observer.DeltaAngle(observer.Angle,observer.AngleTo(candidate)))>CaelumPerceptionData.VISUAL_FIELD_DEGREES/2)return false;
        if((knownDistance>=0 ? knownDistance : observer.Distance3D(candidate))>Range(observer,candidate))return false;
        return observer.CheckSight(candidate);
    }

    // La relación real autoriza combatir; nunca se deduce por ropa o apariencia.
    static bool ProfileBody836Opponent(CaelumCombatActor observer,Actor candidate)
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

    static Actor ProfileBody836Candidate(CaelumCombatActor observer)
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
            // La lista espacial se comparte; cada miembro conserva sus filtros
            // visuales y dos segundos propios. No constituye un aviso audible.
            for(int i=0;i<group.Candidates.Size();i++)
            {
                let candidate=group.Candidates[i];
                if(!Opponent(observer,candidate))continue;
                double distance=observer.Distance3D(candidate);
                if(distance<best && CanSee(observer,candidate,distance)){nearest=candidate;best=distance;}
            }
            for(int i=0;i<group.Members.Size();i++)
            {
                let entry=group.Members[i];let friend=entry!=null ? entry.Body : null;
                if(friend==observer || !Living(friend))continue;
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

    static Actor ProfileBody836Acquire(CaelumCombatActor observer,Actor hint=null)
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

    static Actor Candidate(CaelumCombatActor observer)
    {
        CA836MethodCosts perf=null;
        if(level.time%37==0){perf=CA836MethodCosts(EventHandler.Find('CA836MethodCosts'));if(perf!=null && !perf.Running)perf=null;}
        double start=perf!=null?MSTimeF():0;
        Actor value=ProfileBody836Candidate(observer);
        if(perf!=null){double elapsed=MSTimeF()-start;perf.CandidateMS+=elapsed;perf.CandidateCalls++;perf.CandidateMax=Max(perf.CandidateMax,elapsed);}
        return value;
    }

    static Actor Acquire(CaelumCombatActor observer,Actor hint=null)
    {
        CA836MethodCosts perf=null;
        if(level.time%37==0){perf=CA836MethodCosts(EventHandler.Find('CA836MethodCosts'));if(perf!=null && !perf.Running)perf=null;}
        double start=perf!=null?MSTimeF():0;
        Actor value=ProfileBody836Acquire(observer,hint);
        if(perf!=null){double elapsed=MSTimeF()-start;perf.AcquireMS+=elapsed;perf.AcquireCalls++;perf.AcquireMax=Max(perf.AcquireMax,elapsed);}
        return value;
    }

    static bool CanSee(CaelumCombatActor observer,Actor candidate,double knownDistance=-1)
    {
        CA836MethodCosts perf=null;
        if(level.time%37==0){perf=CA836MethodCosts(EventHandler.Find('CA836MethodCosts'));if(perf!=null && !perf.Running)perf=null;}
        double start=perf!=null?MSTimeF():0;
        bool value=ProfileBody836CanSee(observer,candidate,knownDistance);
        if(perf!=null){double elapsed=MSTimeF()-start;perf.CanSeeMS+=elapsed;perf.CanSeeCalls++;perf.CanSeeMax=Max(perf.CanSeeMax,elapsed);}
        return value;
    }

    static bool Touching(Actor observer,Actor candidate)
    {
        CA836MethodCosts perf=null;
        if(level.time%37==0){perf=CA836MethodCosts(EventHandler.Find('CA836MethodCosts'));if(perf!=null && !perf.Running)perf=null;}
        double start=perf!=null?MSTimeF():0;
        bool value=ProfileBody836Touching(observer,candidate);
        if(perf!=null){double elapsed=MSTimeF()-start;perf.TouchingMS+=elapsed;perf.TouchingCalls++;perf.TouchingMax=Max(perf.TouchingMax,elapsed);}
        return value;
    }

    static double Range(CaelumCombatActor observer,Actor candidate)
    {
        CA836MethodCosts perf=null;
        if(level.time%37==0){perf=CA836MethodCosts(EventHandler.Find('CA836MethodCosts'));if(perf!=null && !perf.Running)perf=null;}
        double start=perf!=null?MSTimeF():0;
        double value=ProfileBody836Range(observer,candidate);
        if(perf!=null){double elapsed=MSTimeF()-start;perf.RangeMS+=elapsed;perf.RangeCalls++;perf.RangeMax=Max(perf.RangeMax,elapsed);}
        return value;
    }

    static bool Opponent(CaelumCombatActor observer,Actor candidate)
    {
        CA836MethodCosts perf=null;
        if(level.time%37==0){perf=CA836MethodCosts(EventHandler.Find('CA836MethodCosts'));if(perf!=null && !perf.Running)perf=null;}
        double start=perf!=null?MSTimeF():0;
        bool value=ProfileBody836Opponent(observer,candidate);
        if(perf!=null){double elapsed=MSTimeF()-start;perf.OpponentMS+=elapsed;perf.OpponentCalls++;perf.OpponentMax=Max(perf.OpponentMax,elapsed);}
        return value;
    }
}

class CA836MethodCosts : EventHandler
{
    double CandidateMS,CandidateMax;int CandidateCalls;
    double AcquireMS,AcquireMax;int AcquireCalls;
    double CanSeeMS,CanSeeMax;int CanSeeCalls;
    double TouchingMS,TouchingMax;int TouchingCalls;
    double RangeMS,RangeMax;int RangeCalls;
    double OpponentMS,OpponentMax;int OpponentCalls;
    double ChaseMS,ChaseMax;int ChaseCalls;
    double ContactMS,ContactMax;int ContactCalls;
    double ObjectExposureMS,ObjectExposureMax;int ObjectExposureCalls;
    double ThermalMS,ThermalMax;int ThermalCalls;
    double CommunicationMS,CommunicationMax;int CommunicationCalls;
    int Age;bool Running;
    override void WorldTick()
    {
        Age++;Running=Age>=3600 && Age<4300;
        if(Age!=4300)return;
        Console.Printf("CA836 METHOD Candidate ms=%.6f calls=%d max=%.6f",CandidateMS,CandidateCalls,CandidateMax);
        Console.Printf("CA836 METHOD Acquire ms=%.6f calls=%d max=%.6f",AcquireMS,AcquireCalls,AcquireMax);
        Console.Printf("CA836 METHOD CanSee ms=%.6f calls=%d max=%.6f",CanSeeMS,CanSeeCalls,CanSeeMax);
        Console.Printf("CA836 METHOD Touching ms=%.6f calls=%d max=%.6f",TouchingMS,TouchingCalls,TouchingMax);
        Console.Printf("CA836 METHOD Range ms=%.6f calls=%d max=%.6f",RangeMS,RangeCalls,RangeMax);
        Console.Printf("CA836 METHOD Opponent ms=%.6f calls=%d max=%.6f",OpponentMS,OpponentCalls,OpponentMax);
        Console.Printf("CA836 METHOD Chase ms=%.6f calls=%d max=%.6f",ChaseMS,ChaseCalls,ChaseMax);
        Console.Printf("CA836 METHOD Contact ms=%.6f calls=%d max=%.6f",ContactMS,ContactCalls,ContactMax);
        Console.Printf("CA836 METHOD ObjectExposure ms=%.6f calls=%d max=%.6f",ObjectExposureMS,ObjectExposureCalls,ObjectExposureMax);
        Console.Printf("CA836 METHOD Thermal ms=%.6f calls=%d max=%.6f",ThermalMS,ThermalCalls,ThermalMax);
        Console.Printf("CA836 METHOD Communication ms=%.6f calls=%d max=%.6f",CommunicationMS,CommunicationCalls,CommunicationMax);
        Console.Printf("CA836 PROFILE_COMPLETE interval=37 window=700");
    }
}
