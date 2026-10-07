// Cuenta trabajo compartido en copias aisladas; no se usa para medir FPS.
class CA128Counters : StaticEventHandler
{
    int Queries, Lists, CandidateVisits, CannonQueries, CannonSightCalls;
    static CA128Counters Get() { return CA128Counters(StaticEventHandler.Find("CA128Counters")); }
    static bool CannonSight(Actor from,Actor candidate)
    {
        Get().CannonSightCalls++;
        return from.CheckSight(candidate);
    }
    override void WorldTick()
    {
        Console.Printf("CA128 WORK tic=%d queries=%d lists=%d visits=%d cannonQueries=%d cannonSight=%d",level.time-1,Queries,Lists,CandidateVisits,CannonQueries,CannonSightCalls);
        Queries=0;Lists=0;CandidateVisits=0;CannonQueries=0;CannonSightCalls=0;
    }
}
