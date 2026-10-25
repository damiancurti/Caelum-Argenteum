class CA410BLegacy : EventHandler
{
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca410b_old_seed')
        {
            let bottle=CaelumWaterContainer(u.GiveInventoryType('CaelumBottleNormal'));
            bottle.InMagicBox=false;bottle.WaterLiters=0.75;bottle.WaterQuality=3;
            Console.Printf("CA410B RESULT old house and bottle seeded");
        }
        else if(e.Name=='ca410b_old_verify')
        {
            let bottle=CaelumWaterContainer(u.FindInventory('CaelumBottleNormal'));
            if(bottle==null || bottle.WaterLiters!=0.75 || bottle.WaterQuality!=3)Console.Printf("CA410B FAIL old bottle rollback");
            else Console.Printf("CA410B PASS old bottle rollback");
            Console.Printf("CA410B RESULT legacy rollback checked");
        }
    }
}
