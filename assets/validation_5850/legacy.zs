class CA502AdapterProof : Inventory
{
    Inventory Cloth;bool Legacy;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA502AdapterChecks : EventHandler
{
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="ca502a_legacyseed")
        {
            let proof=CA502AdapterProof(u.GiveInventoryType('CA502AdapterProof'));proof.Legacy=true;
            let cloth=Inventory(Actor.Spawn('CaelumCleaningCloth',u.Pos+(128,0,0),NO_REPLACE));
            cloth.Amount=3;CaelumContaminationStorage.Set(cloth,67);proof.Cloth=cloth;
            Console.Printf("CA502A %s old runtime records independent ground cloth",Abs(CaelumContaminationStorage.Value(cloth)-67)<.000001?"PASS":"FAIL");
        }
        else if(e.Name=="ca502a_legacyload")
        {
            let proof=CA502AdapterProof(u.FindInventory('CA502AdapterProof'));
            bool ok=proof!=null && proof.Cloth!=null && proof.Cloth.Amount==3 && Abs(CaelumContaminationStorage.Value(proof.Cloth)-67)<.000001;
            Console.Printf("CA502A %s original save rolls back in original runtime",ok?"PASS":"FAIL");
        }
        Console.Printf("CA502A RESULT legacy check complete");
    }
}
