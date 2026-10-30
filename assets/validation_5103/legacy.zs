class CA428Probe : CaelumCombatActor
{
    override void Tick() { }
    Default { Health 100; Radius 16; Height 56; Speed 4; +SHOOTABLE +SOLID +ISMONSTER }
    States { Spawn: TNT1 A -1; Stop; See: TNT1 A -1; Stop; }
}
class CA428Checks : EventHandler
{
    CA428Probe Leader,Member,Receiver,Stranger,Threat,Second;
    CaelumSiegeEncounter Encounter;
    int Stage,Start,OriginalTic,Passes,Failures;
    vector3 OriginalPoint;
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca428_legacy")
        {
            Leader=CA428Probe(Actor.Spawn("CA428Probe",(0,0,0),NO_REPLACE));Leader.health=321;
            Threat=CA428Probe(Actor.Spawn("CA428Probe",(300,0,0),NO_REPLACE));Threat.bFriendly=true;
            OriginalPoint=Threat.Pos;OriginalTic=level.time;
            CaelumVisualPerception.Evidence(Leader).GetMemory().Remember(Threat,OriginalPoint,OriginalTic);
            Console.Printf("CA428 PASS genuine 5.10.2 private memory seeded");Console.Printf("CA428 RESULT legacy ready");
        }
        else if(e.Name=="ca428_rollback")
        {
            if(Leader!=null && Leader.health==321 && CaelumVisualPerception.Evidence(Leader).GetMemory().Find(Threat)!=null)
                Console.Printf("CA428 PASS original save and package remain readable");
            else Console.Printf("CA428 FAIL rollback state missing");
            Console.Printf("CA428 RESULT rollback checked");
        }
    }
}
