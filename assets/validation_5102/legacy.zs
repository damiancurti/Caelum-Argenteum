class CA427Probe : CaelumCombatActor
{
    Default { Health 100; Radius 16; Height 56; Speed 4; +SHOOTABLE +ISMONSTER }
    override void Tick() { }
    States { Spawn: TNT1 A -1; Stop; See: TNT1 A -1; Stop; }
}
class CA427Checks : EventHandler
{
    int Checks,Failures,Stage,Start,ObservationTic;
    CA427Probe Observer,Subject;
    Actor SearchGoal;
    vector3 OriginalPoint,BeforeSearch;
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca427_legacy_seed")
        {
            let user=CaelumPlayer(players[e.Player].mo);user.player.cheats|=CF_GODMODE;
            user.SetOrigin((-1700,-1700,0),false);
            Observer=CA427Probe(Actor.Spawn("CA427Probe",(0,0,0)));
            Subject=CA427Probe(Actor.Spawn("CA427Probe",(-256,0,0)));
            Observer.VisualEvidence=new("CaelumVisualEvidence");Observer.VisualEvidence.Initialize();
            CaelumNoise.Emit(Subject,CaelumNoiseData.FIREARM);OriginalPoint=Subject.Pos;
            Observer.health=321;Stage=6;
            Console.Printf("CA427 PASS genuine 5.10.1 hearing state prepared");
            Console.Printf("CA427 RESULT legacy prepared");
        }
        if(e.Name=="ca427_rollback")
        {
            Console.Printf("CA427 %s original hearing state loads under original package",
                Observer!=null && Observer.health==321 && Observer.VisualEvidence.HasHeardNoise
                && Observer.VisualEvidence.NoisePosition==OriginalPoint?"PASS":"FAIL");
            Console.Printf("CA427 RESULT rollback");
        }
    }
}
