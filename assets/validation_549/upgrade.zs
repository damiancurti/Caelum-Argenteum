class CA239Upgrade : StaticEventHandler
{
    int Age;
    override void WorldTick()
    {
        if(++Age!=20)return;let user=CaelumPlayer(players[0].mo);
        bool ok=user!=null && !CaelumHuntersInstinct.Active(user);
        Console.Printf("CA239 %s old save gains no Hunter effect",ok?"PASS":"FAIL");
        Console.Printf("CA239 DONE failures=%d UPGRADE_ONLY",ok?0:1);
    }
}
