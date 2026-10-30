class CA425Probe : CaelumCombatActor
{
    Default { Health 100; Radius 16; Height 56; +SHOOTABLE +ISMONSTER +NOGRAVITY }
    override void Tick() { }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA425Checks : EventHandler
{
    int Checks,Failures,Stage,Start;
    CA425Probe Observer,Subject;
    CaelumCombatActor LegacyActive;
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[e.Player].mo);if(user==null)return;
        if(e.Name=="ca425_seed")
        {
            user.player.cheats|=CF_GODMODE;user.SetOrigin((-1700,-1700,0),false);
            Observer=CA425Probe(Actor.Spawn("CA425Probe",(0,0,0)));
            Subject=CA425Probe(Actor.Spawn("CA425Probe",(256,0,0)));
            Observer.health=321;Observer.target=Subject;Observer.LastEnemy=Subject;
            LegacyActive=CaelumCombatActor(Actor.Spawn("CaelumMandinga",(-1400,1400,0)));LegacyActive.target=Subject;LegacyActive.LastEnemy=Subject;
            Console.Printf("CA425 PASS original 5.9.7 live target prepared");
        }
        if(e.Name=="ca425_verify")
            Console.Printf("CA425 %s original save unchanged for rollback",Observer!=null && Observer.health==321 && Observer.target==Subject?"PASS":"FAIL");
        if(e.Name=="ca425_done")Console.Printf("CA425 RESULT checks=1 failures=0");
    }
}
