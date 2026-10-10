class CA163Compile : EventHandler
{
    override void WorldTick()
    {
        if(level.time==1)CaelumPlayer(players[0].mo).InitializeDirectMapCharacter();
        if(level.time==20)Console.Printf("CA163 PASS engine compile and world startup");
    }
}
