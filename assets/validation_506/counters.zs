// Cuenta trabajo compartido en copias aisladas; no se usa para medir FPS.
class CA128Counters : StaticEventHandler
{
    int Queries, Lists, CandidateVisits;
    static CA128Counters Get() { return CA128Counters(StaticEventHandler.Find("CA128Counters")); }
    override void WorldTick()
    {
        Console.Printf("CA128 WORK tic=%d queries=%d lists=%d visits=%d",level.time-1,Queries,Lists,CandidateVisits);
        Queries=0;Lists=0;CandidateVisits=0;
    }
}
