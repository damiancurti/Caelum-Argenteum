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
        return npc==null ? 0.0 : Clamp(npc.CalculateActorType2Percent(npc.CombatAgility),0.0,100.0);
    }

    static double InsightFactor(CaelumCombatActor observer)
    { return observer==null ? 1.0 : CaelumGrowthRules.Multiplier(observer.CombatEffectiveInsight,2); }

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
            && observer.Distance2D(candidate)<=observer.Radius+candidate.Radius+0.01
            && observer.Pos.Z<candidate.Pos.Z+candidate.Height
            && candidate.Pos.Z<observer.Pos.Z+observer.Height
            && observer.CheckSight(candidate,SF_IGNOREVISIBILITY);
    }

    static bool CanSee(CaelumCombatActor observer,Actor candidate)
    {
        if(!Living(observer) || !Living(candidate) || observer==candidate || observer.bDormant
            || observer.ForcedSleepTics>0 || observer.CombatLucidityPhysicalStunRemaining>0)return false;
        if(Touching(observer,candidate))return true;
        if(Abs(observer.DeltaAngle(observer.Angle,observer.AngleTo(candidate)))>CaelumPerceptionData.VISUAL_FIELD_DEGREES/2)return false;
        if(observer.Distance3D(candidate)>Range(observer,candidate))return false;
        return observer.CheckSight(candidate);
    }

    // La relación real autoriza combatir; nunca se deduce por ropa o apariencia.
    static bool Opponent(CaelumCombatActor observer,Actor candidate)
    {
        if(!Living(candidate) || observer==candidate)return false;
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

    static Actor Candidate(CaelumCombatActor observer)
    {
        let evidence=Evidence(observer);
        if(observer.PendingTheftTarget!=null && CanSee(observer,observer.PendingTheftTarget))return observer.PendingTheftTarget;
        Actor current=evidence.Subject;
        if(Opponent(observer,current) && CanSee(observer,current))return current;
        Actor nearest;double best=1e30;
        let local=BlockThingsIterator.Create(observer,QueryRadius(observer));
        while(local.Next())
        {
            let candidate=local.thing;
            if(!Opponent(observer,candidate))continue;
            double distance=observer.Distance3D(candidate);
            if(distance>=best || !CanSee(observer,candidate))continue;
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
            if(distance>=best || !CanSee(observer,candidate))continue;
            nearest=candidate;best=distance;
        }
        return nearest;
    }

    static bool Identify(CaelumCombatActor observer,Actor candidate)
    {
        if(observer==null)return false;
        if(observer.IsCaelumMassDiagnosticActor())return candidate!=null;
        return Evidence(observer).Observe(observer,candidate);
    }

    static Actor Acquire(CaelumCombatActor observer)
    {
        let candidate=Candidate(observer);
        return Identify(observer,candidate) && Opponent(observer,candidate) ? candidate : null;
    }

    static void Look(CaelumCombatActor observer)
    {
        observer.LastEnemy=null;
        observer.target=Acquire(observer);
        if(observer.target!=null && observer.SeeState!=null)observer.SetState(observer.SeeState);
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
