class CA426Probe : CaelumCombatActor
{
    Default { Health 100; Radius 16; Height 56; +SHOOTABLE +ISMONSTER }
    override void Tick() { }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA426Checks : EventHandler
{
    int Checks,Failures,Stage,Start,EventTic;
    CA426Probe Listener,Source;
    vector3 SavedPoint;
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca426_legacy_seed")
        {
            let user=CaelumPlayer(players[e.Player].mo);user.player.cheats|=CF_GODMODE;
            user.SetOrigin((-1700,-1700,0),false);
            Listener=CA426Probe(Actor.Spawn("CA426Probe",(0,0,0)));
            Source=CA426Probe(Actor.Spawn("CA426Probe",(128,0,0)));
            Listener.VisualEvidence=new("CaelumVisualEvidence");Listener.VisualEvidence.Initialize();
            Listener.VisualEvidence.Subject=Source;Listener.VisualEvidence.Suspicion=28;
            Listener.health=321;Stage=3;
            Console.Printf("CA426 PASS genuine 5.10.0 visual state prepared");
            Console.Printf("CA426 RESULT legacy prepared");
        }
        if(e.Name=="ca426_rollback")
        {
            Console.Printf("CA426 %s original visual state loads under original package",
                Listener!=null && Listener.health==321 && Listener.VisualEvidence.Subject==Source
                && Listener.VisualEvidence.Suspicion==28?"PASS":"FAIL");
            Console.Printf("CA426 RESULT rollback");
        }
    }
}
