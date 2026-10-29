class CA411PLegacyRecord : Inventory
{
    CaelumChestCargo Cargo;
    Inventory Contents;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE}
}
class CA411PLegacy : EventHandler
{
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!='ca411p_legacy' || e.Player<0 || e.Player>=MAXPLAYERS)return;
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        u.CreationWizardOpen=false;u.bInvulnerable=true;u.DerivedStats.CarryCapacity=1000;
        let record=CA411PLegacyRecord(u.FindInventory('CA411PLegacyRecord'));
        // MODE
        bool ok=record!=null && record.Cargo!=null && record.Cargo.Owner==u
            && record.Cargo.Chest!=null && record.Cargo.Chest.Cargo==record.Cargo
            && record.Contents!=null && record.Contents.Owner==record.Cargo.Chest && record.Contents.Amount==3;
        // VERIFY
        Console.Printf("CA411P %s original carried-chest save and contents",ok?"PASS":"FAIL");
        Console.Printf("CA411P LEGACY result=%s",ok?"PASS":"FAIL");
    }
}
