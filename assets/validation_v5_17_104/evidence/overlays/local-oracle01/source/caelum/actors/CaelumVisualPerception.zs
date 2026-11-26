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
            // #838: estas rutas solo leen relaciones. Residentes y delegados
            // conservan el orden anterior, incluido el mantenimiento de esquemas.
            bool readOnlyRelation=!(observer is "CaelumAnchoredResident")
                && !(observer is "CaelumSummonedZupay")
                && !(observer is "CaelumTarotAutomaton") && !(observer is "CaelumTarotClone");
            // La lista espacial se comparte; cada miembro conserva sus filtros
            // visuales y dos segundos propios. No constituye un aviso audible.
            for(int i=0;i<group.Candidates.Size();i++)
            {
                let candidate=group.Candidates[i];
                if(candidate==null)continue;
                if(readOnlyRelation && sightUpper>=0 && OutsideGroupReach(observer,candidate,sightUpper))continue;
                if(!Opponent(observer,candidate))continue;
                if(!readOnlyRelation && sightUpper>=0 && OutsideGroupReach(observer,candidate,sightUpper))continue;
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
        // #851: la cota compartida también descarta vecinos locales invisibles.
        // Las relaciones con migración conservan su consulta antes del descarte.
        let localPopulation=CaelumPopulationState.Get();
        double localSightUpper=localPopulation!=null && localPopulation.HighDensity && level.GetPortalGroupCount()==1
            ? CaelumPhysicsUnits.MapUnits(CaelumPerceptionData.VISUAL_BASE_METERS)*InsightFactor(observer) : -1;
        bool readOnlyLocalRelation=!(observer is "CaelumAnchoredResident")
            && !(observer is "CaelumSummonedZupay")
            && !(observer is "CaelumTarotAutomaton") && !(observer is "CaelumTarotClone");
        CA851LocalOracle oracle=null;
        if(level.time>=3599 && level.time<4299 && (level.time-3599)%17==0)
        {oracle=CA851LocalOracle(StaticEventHandler.Find('CA851LocalOracle'));if(oracle!=null)oracle.Queries++;}
        let local=BlockThingsIterator.Create(observer,QueryRadius(observer));
        while(local.Next())
        {
            let candidate=local.thing;
            if(oracle!=null)oracle.Candidates++;
            if(readOnlyLocalRelation && localSightUpper>=0 && candidate!=null && OutsideGroupReach(observer,candidate,localSightUpper)){if(oracle!=null){oracle.PreRejected++;oracle.Check(observer,candidate);}continue;}
            bool opponent=Opponent(observer,candidate);
            if(!readOnlyLocalRelation && localSightUpper>=0 && candidate!=null && OutsideGroupReach(observer,candidate,localSightUpper)){if(oracle!=null){oracle.PostRejected++;oracle.Check(observer,candidate);}continue;}
            if(!opponent)
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

class CA851LocalOracle : StaticEventHandler
{
    int Queries,Candidates,PreRejected,PostRejected,UnexpectedVisible,UnexpectedContact;
    bool Printed;
    void Check(CaelumCombatActor observer,Actor candidate)
    {
        if(CaelumVisualPerception.CanSee(observer,candidate))UnexpectedVisible++;
        if(CaelumVisualPerception.Touching(observer,candidate))UnexpectedContact++;
    }
    override void WorldTick()
    {
        if(Printed || level.time!=4350)return;Printed=true;
        bool okay=Queries>0 && Candidates>0 && PreRejected+PostRejected>0 && UnexpectedVisible==0 && UnexpectedContact==0;
        Console.Printf("CA851 LOCAL_ORACLE queries=%d candidates=%d pre=%d post=%d visible=%d contact=%d result=%s",Queries,Candidates,PreRejected,PostRejected,UnexpectedVisible,UnexpectedContact,okay?"PASS":"FAIL");
    }
}
