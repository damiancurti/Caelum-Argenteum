// Fixture only: compare fresh ally evidence, then restore the original object.
class CA851LocalParity : Object play
{
    static bool Same(CaelumCombatActor body)
    {
        let evidence=CaelumVisualPerception.Evidence(body);
        let saved=evidence.Communication;
        evidence.Communication=null;evidence.CandidateCacheReady=false;evidence.PreviousSampleVisible=false;
        Actor original=CA851BaselinePerception.Candidate(body);
        let before=evidence.Communication;
        evidence.Communication=null;evidence.CandidateCacheReady=false;evidence.PreviousSampleVisible=false;
        Actor current=CaelumVisualPerception.Candidate(body);
        let after=evidence.Communication;
        bool same=original==current;
        if(before==null || after==null)same=same && before==after;
        else
        {
            same=same && before.RememberedAlly==after.RememberedAlly
                && before.AllyPosition==after.AllyPosition && before.AllyObservedTic==after.AllyObservedTic;
            let first=before.AllyEvidence;let second=after.AllyEvidence;
            if(first==null || second==null)same=same && first==second;
            else same=same && first.Subject==second.Subject && first.IdentifiedSubject==second.IdentifiedSubject
                && first.ObservedPosition==second.ObservedPosition && first.VisibleNow==second.VisibleNow
                && first.PreviousSampleVisible==second.PreviousSampleVisible
                && first.ContinuousSightTics==second.ContinuousSightTics && first.LastVisualTic==second.LastVisualTic;
        }
        evidence.Communication=saved;return same;
    }
}
