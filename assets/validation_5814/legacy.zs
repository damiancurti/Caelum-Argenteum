class CA410FoodLegacy : EventHandler
{
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="ca410f_old_seed")
        {
            u.CurrentHunger=100;u.CurrentThirst=100;u.bInvulnerable=true;
            u.MagicBoxOwned=true;let record=u.GetPersistentCharacterState(true);
            record.MagicBoxOwned=true;record.MagicBoxOwnershipVersion=1;
            let old=u.FindInventory('CaelumFoodRation');if(old!=null)old.Destroy();
            let food=CaelumConsumableItem(Actor.Spawn('CaelumFoodRation',u.Pos,NO_REPLACE));
            food.Amount=7;food.InMagicBox=true;food.AttachToOwner(u);
            Console.Printf("CA410F PASS original runtime stores seven boxed rations");
        }
        else if(e.Name=="ca410f_old_check")
        {
            let food=CaelumConsumableItem(u.FindInventory('CaelumFoodRation'));
            Console.Printf("CA410F %s original quantity and Box location retained",food!=null && food.Amount==7 && food.InMagicBox?"PASS":"FAIL");
            // UPGRADE_CHECK
        }
        else return;
        Console.Printf("CA410F LEGACY");
    }
}
