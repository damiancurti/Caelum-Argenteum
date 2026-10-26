class CA411FireLegacy : EventHandler
{
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="ca411f_old_seed")
        {
            let pot=CaelumCampPot(Actor.Spawn('CaelumCampPot',u.Pos,NO_REPLACE));pot.AttachToOwner(u);
            pot.WaterLiters=13;pot.WaterQuality=5;pot.WaterTemperatureC=23;pot.WaterTemperatureRevision=1;pot.StampTemperature(u);
            Console.Printf("CA411F PASS original runtime stores existing pot");
        }
        else if(e.Name=="ca411f_old_check")
        {
            let pot=CaelumCampPot(u.FindInventory('CaelumCampPot'));
            Console.Printf("CA411F %s existing pot quantity and quality migrate or roll back",pot!=null && Abs(pot.WaterLiters-13)<0.00001 && pot.WaterQuality==5?"PASS":"FAIL");
        }
        else return;
        Console.Printf("CA411F LEGACY");
    }
}
