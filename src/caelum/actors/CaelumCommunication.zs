// #428: cada receptor conserva su evidencia. Ninguna lista de mando transmite
// conocimiento por si sola; la entrega siempre comprueba audibilidad real.
class CaelumCommandCandidates : Object play
{
    Array<CaelumSiegeCombatant> Members;
    Array<Actor> Candidates;
    transient bool Ready;
    transient int SampleTic;

    void Refresh(CaelumCombatActor leader)
    {
        if(Ready && SampleTic==level.time)return;
        Ready=true;SampleTic=level.time;Candidates.Clear();
        double radius=CaelumVisualPerception.QueryRadius(leader);
        for(int i=0;i<Members.Size();i++)
        {
            let member=Members[i];let body=member!=null ? member.Body : null;
            if(!CaelumVisualPerception.Living(body))continue;
            radius=Max(radius,leader.Distance3D(body)+CaelumVisualPerception.QueryRadius(body)+Max(body.Speed,body.Vel.Length()));
        }
        let local=BlockThingsIterator.Create(leader,radius);
        while(local.Next())
            if(CaelumVisualPerception.Opponent(leader,local.thing))Candidates.Push(local.thing);
        let population=CaelumPopulationState.Get();
        if(population!=null)for(int i=0;i<population.UnlinkedGuards.Size();i++)
        {
            let entry=population.UnlinkedGuards[i];let body=entry!=null ? entry.Body : null;
            if(body!=null && body.bNoBlockmap && CaelumVisualPerception.Opponent(leader,body)
                && leader.Distance3D(body)<=radius)Candidates.Push(body);
        }
    }
}

class CaelumCommunicationState : Object play
{
    int Revision,LastPulseTic,LastShoutTic;
    bool HasPulsed,HasShouted,LastDeliverySucceeded;
    CaelumVisualEvidence AllyEvidence;
    CaelumCombatActor RememberedAlly;
    vector3 AllyPosition;
    int AllyObservedTic;
    CaelumSearchPoint HelpGoal;

    void ClearHelp(CaelumCombatActor body)
    {
        if(HelpGoal!=null)
        {
            if(body.target==HelpGoal)body.target=null;
            HelpGoal.Destroy();HelpGoal=null;
        }
    }
}

class CaelumCommunication : Object play
{
    static CaelumCommandCandidates CandidatesFor(CaelumCombatActor body)
    {
        let population=CaelumPopulationState.Get();
        if(population==null || !population.HighDensity)return null;
        let leader=Leader(body);if(leader==null)return null;
        let entry=leader.SiegeCombatant;
        if(entry==null || !(entry.Encounter is "CaelumPortSiege") || entry.GroupCandidates==null)return null;
        entry.GroupCandidates.Refresh(leader);return entry.GroupCandidates;
    }

    static CaelumCommunicationState StateFor(CaelumCombatActor body)
    {
        let evidence=CaelumVisualPerception.Evidence(body);
        if(evidence.Communication==null)
        {evidence.Communication=new("CaelumCommunicationState");evidence.Communication.Revision=CaelumCommunicationData.REVISION;}
        return evidence.Communication;
    }

    static CaelumCombatActor Leader(CaelumCombatActor body)
    {
        if(body==null || body.SiegeCombatant==null || CaelumRedemption.PreviouslyRaised(body))return null;
        let entry=body.SiegeCombatant;
        if(entry==null || entry.CommandLeader==null)return null;
        let command=entry.CommandLeader;
        return !command.ConfirmedDead && !command.Exited
            && command.Encounter==entry.Encounter && CaelumVisualPerception.Living(command.Body)
            ? command.Body : null;
    }

    static bool NeedsOrder(CaelumCombatActor body)
    {
        if(body==null || body.SiegeCombatant==null || CaelumRedemption.PreviouslyRaised(body))return false;
        let entry=body.SiegeCombatant;
        return entry!=null && (entry.CommandLeader!=null || entry.Encounter is "CaelumPortSiege");
    }

    static CaelumPlayer Principal(CaelumCombatActor body)
    {
        let user=CaelumRedemption.Commander(body);if(user!=null)return user;
        let summoned=CaelumSummonedZupay(body);
        if(summoned!=null && summoned.Binding!=null)return CaelumPlayer(summoned.Binding.Owner);
        let resident=CaelumAnchoredResident(body);
        if(resident!=null)
        {
            if(resident.RuloPartyMode==2)return resident.RuloPartyTraveler;
            if(resident.IsEscortPrisoner() && !resident.EscortPrisonerPort)return resident.GetEscortOwnerPlayer();
        }
        return null;
    }

    static int Faction(CaelumCombatActor body)
    {
        let resident=CaelumAnchoredResident(body);
        return resident!=null && resident.IsEscortPrisoner()
            ? CaelumFactionData.ConfirmedPrisonerFaction(resident.EscortPrisonerId) : -1;
    }

    static bool Eligible(CaelumCombatActor sender,CaelumCombatActor receiver)
    {
        if(sender==receiver || !CaelumVisualPerception.Living(sender)
            || !CaelumVisualPerception.Living(receiver))return false;
        let first=Leader(sender);let second=Leader(receiver);
        if(first!=null && first==second)return true;
        let guard=CaelumPortDefender(sender);let other=CaelumPortDefender(receiver);
        if(guard!=null && other!=null && guard.Port!=null && guard.Port==other.Port)return true;
        let principal=Principal(sender);
        if(principal!=null && principal==Principal(receiver))return true;
        return CaelumCommunicationData.AlliedFactions(Faction(sender),Faction(receiver));
    }

    static bool Awake(CaelumCombatActor body)
    {
        return CaelumVisualPerception.Living(body) && !body.bDormant
            && body.ForcedSleepTics<=0 && body.CombatLucidityPhysicalStunRemaining<=0;
    }

    static double ShoutRange()
    {return CaelumPhysicsUnits.MapUnits(CaelumNoiseData.MetersFor(CaelumNoiseData.SHOUT));}

    static void Shout(CaelumCombatActor body)
    {
        CaelumNoise.Emit(body,CaelumNoiseData.SHOUT);
        String voice=body.GetCaelumRecognitionSound();
        if(voice!="")body.A_StartSound(voice,CHAN_VOICE);
    }

    static bool MayEngage(CaelumCombatActor body,Actor subject)
    {
        if(!NeedsOrder(body))return true;
        let leader=Leader(body);if(leader==body)return true;
        if(leader==null)return false;
        let memory=CaelumVisualPerception.Evidence(body).GetMemory();let record=memory.Find(subject);
        return record!=null && record.OrderLeader==leader
            && CaelumPerceptionMemoryData.Fresh(record.OrderObservedTic);
    }

    static void ChooseOrderedFocus(CaelumCombatActor body,CaelumPerceptionMemory memory)
    {
        if(!NeedsOrder(body))return;
        memory.Focus=null;double best=1e30;
        for(int i=0;i<memory.Records.Size();i++)
        {
            let record=memory.Records[i];
            if(!CaelumVisualPerception.Opponent(body,record.Subject)
                || !CaelumPerceptionMemoryData.Fresh(record.ObservedTic)
                || !MayEngage(body,record.Subject))continue;
            double distance=(record.Position-body.Pos).Length();
            if(distance<best){best=distance;memory.Focus=record.Subject;}
        }
    }

    // Esta muestra procede de la consulta visual ya existente, no de otro censo.
    static void ObserveAlly(CaelumCombatActor observer,CaelumCombatActor candidate)
    {
        if(!Eligible(observer,candidate))return;
        let communication=StateFor(observer);
        if(communication.AllyEvidence==null){communication.AllyEvidence=new("CaelumVisualEvidence");communication.AllyEvidence.Initialize();}
        if(!communication.AllyEvidence.Observe(observer,candidate))return;
        communication.RememberedAlly=candidate;communication.AllyPosition=candidate.Pos;communication.AllyObservedTic=level.time;
    }

    static bool Receive(CaelumCombatActor receiver,CaelumCombatActor sender,
        CaelumPerceptionRecord packet,bool order)
    {
        if(packet==null || !CaelumPerceptionMemoryData.Fresh(packet.ObservedTic)
            || !CaelumVisualPerception.Living(packet.Subject) || !Eligible(sender,receiver)
            || CaelumNoise.Intensity(receiver,sender,ShoutRange())<=0)return false;
        let memory=CaelumVisualPerception.Evidence(receiver).GetMemory();
        memory.Remember(packet.Subject,packet.Position,packet.ObservedTic,packet.OriginalWitness,sender);
        let received=memory.Find(packet.Subject);
        if(order && Leader(receiver)==sender && received!=null
            && (received.OrderLeader!=sender || received.OrderObservedTic<packet.ObservedTic))
        {received.OrderLeader=sender;received.OrderObservedTic=packet.ObservedTic;}
        // Haber oido una voz no equivale a haber visto al aliado.
        ObserveAlly(receiver,sender);
        return true;
    }

    static CaelumPerceptionRecord Pending(CaelumCombatActor body)
    {
        let memory=CaelumVisualPerception.Evidence(body).GetMemory();
        let leader=Leader(body);CaelumPerceptionRecord chosen;int oldest=0;
        for(int i=0;i<memory.Records.Size();i++)
        {
            let record=memory.Records[i];
            if(!CaelumVisualPerception.Opponent(body,record.Subject)
                || (record.ReportSent && record.LastReportObservedTic>=record.ObservedTic))continue;
            if(leader!=null && leader!=body)
            {
                let known=CaelumVisualPerception.Evidence(leader).GetMemory().Find(record.Subject);
                // El autor pide informar objetivos desconocidos por el mando,
                // no una tormenta de actualizaciones de todos sus observadores.
                if(known!=null)continue;
            }
            int sent=record.ReportSent ? record.LastReportSentTic : -1;
            if(chosen==null || sent<oldest){chosen=record;oldest=sent;}
        }
        return chosen;
    }

    static bool Emit(CaelumCombatActor body,CaelumPerceptionRecord packet)
    {
        if(!Awake(body) || packet==null || !CaelumPerceptionMemoryData.Fresh(packet.ObservedTic))return false;
        let communication=StateFor(body);
        if(communication.HasShouted && level.time-communication.LastShoutTic<CaelumCommunicationData.SHOUT_INTERVAL_SECONDS*TICRATE)return false;
        communication.HasShouted=true;communication.LastShoutTic=level.time;
        packet.ReportSent=true;packet.LastReportObservedTic=packet.ObservedTic;packet.LastReportSentTic=level.time;
        let leader=Leader(body);bool order=leader==body;bool delivered=false;
        Shout(body);
        // El mensaje al mando es privado; los demas solo oyen el grito anonimo.
        if(leader!=null && !order)delivered=Receive(leader,body,packet,false);
        else
        {
            let population=CaelumPopulationState.Get();
            double maximum=population!=null ? Max(1.0,population.PerceptionMaximumInsightFactor) : 1;
            let local=BlockThingsIterator.Create(body,ShoutRange()*maximum);
            while(local.Next())
            {
                let receiver=CaelumCombatActor(local.thing);
                if(receiver!=null && Receive(receiver,body,packet,order))delivered=true;
            }
            if(population!=null)for(int i=0;i<population.UnlinkedGuards.Size();i++)
            {
                let entry=population.UnlinkedGuards[i];
                if(entry!=null && entry.Body!=null && entry.Body.bNoBlockmap
                    && Receive(entry.Body,body,packet,order))delivered=true;
            }
        }
        communication.LastDeliverySucceeded=delivered;return delivered;
    }

    static void Pulse(CaelumCombatActor body)
    {
        if(!Awake(body) || body.IsCaelumMassDiagnosticActor())return;
        let evidence=CaelumVisualPerception.Evidence(body);
        if(evidence.Memory==null && evidence.Communication==null)return;
        let communication=StateFor(body);
        if(communication.HasPulsed && communication.LastPulseTic==level.time)return;
        communication.HasPulsed=true;communication.LastPulseTic=level.time;
        if(communication.RememberedAlly!=null && communication.AllyObservedTic!=level.time)
            ObserveAlly(body,communication.RememberedAlly);
        if(communication.HasShouted && level.time-communication.LastShoutTic<CaelumCommunicationData.SHOUT_INTERVAL_SECONDS*TICRATE)return;
        let packet=Pending(body);if(packet!=null)Emit(body,packet);
    }

    static bool SeekHelp(CaelumCombatActor body)
    {
        if(!Awake(body) || body.bInConversation || CaelumTelekinesisRules.Held(body)
            || CaelumBolas.Restrained(body))return false;
        let resident=CaelumAnchoredResident(body);
        if(resident!=null && (resident.IsProtectedStoryResident()
            || (resident.IsEscortPrisoner() && !resident.EscortPrisonerPort)))return false;
        let communication=StateFor(body);Pulse(body);
        if(communication.LastDeliverySucceeded || !Eligible(body,communication.RememberedAlly)
            || !CaelumPerceptionMemoryData.Fresh(communication.AllyObservedTic))
        {communication.ClearHelp(body);return false;}
        let memory=CaelumVisualPerception.Evidence(body).GetMemory();CaelumPerceptionRecord packet;
        for(int i=0;i<memory.Records.Size();i++)
            if(CaelumVisualPerception.Opponent(body,memory.Records[i].Subject))
            {packet=memory.Records[i];break;}
        if(packet==null){communication.ClearHelp(body);return false;}
        // Si no habia receptor al gritar, transportar el mismo aviso no cambia
        // su fecha. Solo se entrega al alcanzar alcance audible y fuera del cooldown.
        if(CaelumNoise.Intensity(communication.RememberedAlly,body,ShoutRange())>0)
        {
            if(!communication.HasShouted || level.time-communication.LastShoutTic>=CaelumCommunicationData.SHOUT_INTERVAL_SECONDS*TICRATE)
            {
                communication.HasShouted=true;communication.LastShoutTic=level.time;
                Shout(body);
                communication.LastDeliverySucceeded=Receive(communication.RememberedAlly,body,packet,false);
                communication.ClearHelp(body);return false;
            }
        }
        if(communication.HelpGoal==null)
        {communication.HelpGoal=CaelumSearchPoint(Actor.Spawn("CaelumSearchPoint",communication.AllyPosition,NO_REPLACE));if(communication.HelpGoal!=null)communication.HelpGoal.SearchOwner=body;}
        else communication.HelpGoal.SetOrigin(communication.AllyPosition,false);
        if(communication.HelpGoal==null)return false;
        body.target=communication.HelpGoal;body.LastEnemy=null;body.Vel.X=0;body.Vel.Y=0;
        vector2 delta=communication.AllyPosition.XY-body.Pos.XY;
        if(delta.Length()>body.Radius)
        {
            body.Angle=VectorAngle(delta.X,delta.Y);
            if(!body.ThermalTryMove(body.Pos.XY+delta.Unit()*Min(body.Speed,delta.Length())))
                body.A_Chase(null,null,CHF_DONTLOOKALLAROUND);
            body.target=communication.HelpGoal;body.LastEnemy=null;
        }
        return true;
    }
}
