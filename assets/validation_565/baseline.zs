// Contrato común de 5.5.8a y 5.6.5: conserva el actor y su inventario nativo.
class CA382BaselineCheckpoint : Inventory
{
    CaelumStashChest Chest;
    Inventory Content;
    Default { Inventory.MaxAmount 1; Inventory.InterHubAmount 1; +INVENTORY.UNDROPPABLE }
}
class CA382BaselineChecks : StaticEventHandler
{
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;
        if(e.Name=="ca382_baseline_save")
        {
            u.bInvulnerable=true;u.DebugAttributesAt100=true;u.ApplyCharacterProfile();u.CreationWizardOpen=false;
            let mark=CA382BaselineCheckpoint(Actor.Spawn("CA382BaselineCheckpoint",u.Pos,NO_REPLACE));mark.AttachToOwner(u);
            mark.Chest=CaelumStashChest(Actor.Spawn("CaelumStashChest",u.Pos+(64,0,0),NO_REPLACE));
            mark.Content=Inventory(Actor.Spawn("CaelumGoldCoin",u.Pos,NO_REPLACE));mark.Content.Amount=7;mark.Content.AttachToOwner(mark.Chest);
        }
        if(e.Name=="ca382_baseline_save" || e.Name=="ca382_baseline_verify")
        {
            let mark=CA382BaselineCheckpoint(u.FindInventory("CA382BaselineCheckpoint"));
            bool ok=mark!=null && mark.Chest!=null && mark.Content!=null;
            if(ok)ok=mark.Content.Owner==mark.Chest && mark.Content.Amount==7 && mark.Chest.GetChestLockNumber()==0;
            Console.Printf("CA382 %s original baseline native chest/content preserved",ok?"PASS":"FAIL");
        }
    }
}
