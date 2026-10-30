// #427: referencias identificadas y posiciones fotografiadas, nunca seguimiento oculto.
class CaelumPerceptionRecord : Object play
{
    Actor Subject;
    vector3 Position;
    int ObservedTic;
    CaelumCombatActor OriginalWitness,Reporter,OrderLeader;
    int OrderObservedTic,LastReportObservedTic,LastReportSentTic;
    bool ReportSent;
}

class CaelumSearchPoint : CaelumSewerEscapeTarget
{
    CaelumCombatActor SearchOwner;
    override void Tick()
    {
        if(SearchOwner==null || SearchOwner.bDestroyed || SearchOwner.health<=0){Destroy();return;}
        Super.Tick();
    }
}

class CaelumPerceptionMemory : Object play
{
    int Revision,LastPruneTic;
    bool HasPruned;
    Array<CaelumPerceptionRecord> Records;
    Actor Focus;
    CaelumSearchPoint Goal;

    void Prune()
    {
        if(Revision==0)Revision=CaelumPerceptionMemoryData.REVISION;
        if(HasPruned && LastPruneTic==level.time)return;
        HasPruned=true;LastPruneTic=level.time;
        for(int i=Records.Size()-1;i>=0;i--)
            if(Records[i]==null || !CaelumVisualPerception.Living(Records[i].Subject)
                || !CaelumPerceptionMemoryData.Fresh(Records[i].ObservedTic))Records.Delete(i);
    }

    CaelumPerceptionRecord Find(Actor subject)
    {
        Prune();
        if(!CaelumVisualPerception.Living(subject))
        {
            for(int i=Records.Size()-1;i>=0;i--)
                if(Records[i].Subject==subject)Records.Delete(i);
            return null;
        }
        for(int i=0;i<Records.Size();i++)
            if(Records[i].Subject==subject && CaelumPerceptionMemoryData.Fresh(Records[i].ObservedTic))return Records[i];
        return null;
    }

    void Remember(Actor subject,vector3 point,int observedTic,
        CaelumCombatActor originalWitness=null,CaelumCombatActor reporter=null)
    {
        if(!CaelumVisualPerception.Living(subject) || !CaelumPerceptionMemoryData.Fresh(observedTic))return;
        let record=Find(subject);
        if(record==null){record=new("CaelumPerceptionRecord");record.Subject=subject;Records.Push(record);}
        else if(record.ObservedTic>observedTic || (record.ObservedTic==observedTic && reporter!=null))return;
        record.Position=point;record.ObservedTic=observedTic;
        record.OriginalWitness=originalWitness;record.Reporter=reporter;
    }

    void ClearGoal(CaelumCombatActor body)
    {
        if(Goal!=null)
        {
            if(body.target==Goal)body.target=null;
            Goal.Destroy();Goal=null;
        }
    }

    bool HasFocus(CaelumCombatActor body)
    {
        let record=Find(Focus);
        if(record==null || !CaelumVisualPerception.Opponent(body,Focus)){Focus=null;return false;}
        return true;
    }

    void ChooseFocus(CaelumCombatActor body)
    {
        if(CaelumCommunication.NeedsOrder(body))
        {CaelumCommunication.ChooseOrderedFocus(body,self);return;}
        if(HasFocus(body))return;
        double best=1e30;
        for(int i=0;i<Records.Size();i++)
        {
            let record=Records[i];
            if(!CaelumVisualPerception.Opponent(body,record.Subject)
                || !CaelumPerceptionMemoryData.Fresh(record.ObservedTic))continue;
            double distance=(record.Position-body.Pos).Length();
            if(distance<best){best=distance;Focus=record.Subject;}
        }
    }

    Actor Search(CaelumCombatActor body,CaelumVisualEvidence evidence)
    {
        if(!CaelumVisualPerception.Living(body) || body.bInConversation || body.bDormant
            || body.ForcedSleepTics>0 || body.CombatLucidityPhysicalStunRemaining>0)return null;
        ChooseFocus(body);
        bool found=false;vector3 point;int newest=-1;
        if(HasFocus(body))
        {
            let record=Find(Focus);point=record.Position;newest=record.ObservedTic;found=true;
        }
        else
        {
            // Un aviso autorizado permite investigar sin inventar enemistad.
            for(int i=0;i<Records.Size();i++)
            {
                let record=Records[i];
                if(record.Reporter!=null && record.ObservedTic>newest)
                {point=record.Position;newest=record.ObservedTic;found=true;}
            }
            if(evidence.HasVisualPoint && CaelumVisualPerception.Living(evidence.Subject)
                && CaelumPerceptionMemoryData.Fresh(evidence.LastVisualTic) && evidence.LastVisualTic>newest)
            {point=evidence.ObservedPosition;newest=evidence.LastVisualTic;found=true;}
            if(evidence.HasHeardNoise && CaelumPerceptionMemoryData.Fresh(evidence.NoiseTic)
                && evidence.NoiseTic>newest)
            {point=evidence.NoisePosition;found=true;}
        }
        if(!found){ClearGoal(body);return null;}
        if(Goal==null){Goal=CaelumSearchPoint(Actor.Spawn("CaelumSearchPoint",point,NO_REPLACE));if(Goal!=null)Goal.SearchOwner=body;}
        else Goal.SetOrigin(point,false);
        return Goal;
    }
}
