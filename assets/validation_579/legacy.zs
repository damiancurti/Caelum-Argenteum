// Compatible with 5.7.8: preserve the original save for independent rollback.
class CA409Legacy : StaticEventHandler
{
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[e.Player].mo);if(user==null)return;
        if(e.Name=="ca409_oldseed")
        {
            let water=CaelumWaterContainer(user.GiveInventoryType("CaelumCanteenNormal"));
            if(water==null)water=CaelumWaterContainer(user.FindInventory("CaelumCanteenNormal"));
            water.WaterLiters=1.25;water.WaterQuality=7;water.WaterQualityRevision=1;water.InMagicBox=true;
            user.MagicBoxOwned=true;user.GetPersistentCharacterState(true).MagicBoxOwned=true;
            user.OnNativeInventoryChanged();user.PersistCharacterState();
            Console.Printf("CA409 RESULT legacy seed");
        }
        else if(e.Name=="ca409_oldcheck")
        {
            let water=CaelumWaterContainer(user.FindInventory("CaelumCanteenNormal"));
            bool ok=water!=null && water.WaterLiters==1.25 && water.WaterQuality==7 && water.InMagicBox;
            Console.Printf("CA409 %s original volume quality and Box placement",ok?"PASS":"FAIL");
            // CURRENT_CHECK
            Console.Printf("CA409 RESULT legacy failed=%d",ok?0:1);
        }
    }
}
