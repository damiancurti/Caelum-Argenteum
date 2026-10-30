// #425: evidencia privada y guardable. Percibir no concede afiliación ni enemistad.
class CaelumVisualEvidence : Object play
{
    int Revision, LastSampleTic, LastEvidenceTic, LastDecayTic, ContinuousSightTics;
    Actor Subject, IdentifiedSubject;
    CaelumPerceptionMemory Memory;
    CaelumCommunicationState Communication;
    transient Actor CandidateCache;
    transient int CandidateCacheTic;
    transient bool CandidateCacheReady;
    int LastVisualTic;
    bool HasVisualPoint;

    CaelumPerceptionMemory GetMemory()
    {
        if(Memory==null)Memory=new("CaelumPerceptionMemory");
        Memory.Prune();return Memory;
    }
    CaelumCombatActor Witness;
    int NoiseRevision,NoiseTic,NoiseKind;
    vector3 NoisePosition;
    double NoiseIntensity;
    bool HasHeardNoise;
    vector3 ObservedPosition;
    double Suspicion;
    bool PreviousSampleVisible, VisibleNow, HasEvidence;

    void Initialize()
    {
        Revision=CaelumPerceptionData.VISUAL_REVISION;
        LastSampleTic=LastEvidenceTic=LastDecayTic=level.time;
    }

    void Decay()
    {
        int start=Max(LastDecayTic,LastEvidenceTic+int(CaelumPerceptionData.SUSPICION_GRACE_SECONDS*TICRATE));
        if(level.time>start)
            Suspicion=Max(0.0,Suspicion-(level.time-start)*CaelumPerceptionData.SUSPICION_DECAY_PER_SECOND/TICRATE);
        LastDecayTic=level.time;
    }

    bool Observe(CaelumCombatActor observer,Actor candidate)
    {
        Decay();
        bool visible=CaelumVisualPerception.CanSee(observer,candidate);
        if(visible)
        {
            bool same=Subject==candidate && PreviousSampleVisible;
            if(Subject!=candidate)IdentifiedSubject=null;
            bool contact=CaelumVisualPerception.Touching(observer,candidate);
            int required=int(TICRATE*CaelumPerceptionData.IDENTIFICATION_SECONDS);
            bool known=GetMemory().Find(candidate)!=null;
            ContinuousSightTics=contact || known ? required : same ? Min(required,ContinuousSightTics+Max(0,level.time-LastSampleTic)) : 0;
            double visual=double(ContinuousSightTics)*CaelumPerceptionData.SUSPICION_MAXIMUM/required;
            Suspicion=Max(Suspicion,visual);
            Subject=candidate;ObservedPosition=candidate.Pos;LastVisualTic=level.time;HasVisualPoint=true;
            LastEvidenceTic=level.time;HasEvidence=true;
            if(ContinuousSightTics>=required)
            {IdentifiedSubject=candidate;GetMemory().Remember(candidate,ObservedPosition,level.time,observer);}
        }
        else {IdentifiedSubject=null;ContinuousSightTics=0;}
        VisibleNow=visible;PreviousSampleVisible=visible;LastSampleTic=level.time;
        return visible && IdentifiedSubject==candidate;
    }

    void Damaged(CaelumCombatActor observer,Actor source)
    {
        Suspicion=CaelumPerceptionData.SUSPICION_MAXIMUM;
        LastEvidenceTic=LastDecayTic=level.time;HasEvidence=true;
        // El puntero del proyectil no es conocimiento. Sólo guardar un autor percibido.
        if(CaelumVisualPerception.CanSee(observer,source))
        {
            Subject=IdentifiedSubject=source;ObservedPosition=source.Pos;LastVisualTic=level.time;HasVisualPoint=true;
            GetMemory().Remember(source,ObservedPosition,level.time,observer);
            if(CaelumVisualPerception.Opponent(observer,source))GetMemory().Focus=source;
            ContinuousSightTics=int(TICRATE*CaelumPerceptionData.IDENTIFICATION_SECONDS);
            PreviousSampleVisible=VisibleNow=true;LastSampleTic=level.time;
        }
    }
}
