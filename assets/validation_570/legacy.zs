// Fixture compatible con el código anterior y posterior a #408.
class CA408Legacy : StaticEventHandler
{
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="ca408_legacy_save")
        {
            u.bInvulnerable=true;u.DebugAttributesAt100=true;u.ApplyCharacterProfile();u.CreationWizardOpen=false;
            let b=CaelumWaterContainer(u.FindInventory('CaelumCanteenNormal'));
            if(b==null){b=CaelumWaterContainer(Actor.Spawn('CaelumCanteenNormal',u.Pos,NO_REPLACE));b.AttachToOwner(u);}
            b.WaterLiters=1.25;u.CurrentThirst=100;u.OnNativeInventoryChanged();u.PersistCharacterState();
            Console.Printf("CA408 LEGACY amount=%.2f",b.WaterLiters);
        }
        else if(e.Name=="ca408_legacy_verify")
        {
            let b=CaelumWaterContainer(u.FindInventory('CaelumCanteenNormal'));
            bool ok=b!=null && b.WaterLiters==1.25;
            Console.Printf("CA408 %s original legacy volume retained",ok?"PASS":"FAIL");
            Console.Printf("CA408 LEGACY failed=%d",ok?0:1);
        }
    }
}
