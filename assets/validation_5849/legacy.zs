class CA502PhysicalProof : Inventory
{
    CaelumMaterialPickup Material; CaelumConsumableItem Food; bool Legacy;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA502PhysicalChecks : EventHandler
{
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="ca502p_legacyseed")
        {
            CaelumInventoryService.GrantMagicBoxFromPalomo(u,false);
            let p=CA502PhysicalProof(u.GiveInventoryType('CA502PhysicalProof'));p.Legacy=true;
            p.Material=CaelumMaterialPickup(Actor.Spawn('CaelumMaterialPickup',u.Pos+(128,128,0)));
            p.Material.args[0]=92;p.Material.args[1]=1;p.Material.Amount=75;p.Material.AttachToOwner(u);p.Material.InMagicBox=true;
            CaelumContaminationStorage.Set(p.Material,67);
            p.Food=CaelumConsumableItem(Actor.Spawn('CaelumBread',u.Pos+(128,128,0)));
            p.Food.Amount=3;
            CaelumFoodInventory.Reconcile(p.Food);p.Food.FoodLots.Lots[0].BaseContamination=39;
            CaelumContaminationStorage.Set(p.Food,37);
            bool valid=CaelumContaminationStorage.Value(p.Material)==67 && CaelumContaminationStorage.Value(p.Food)==37;
            Console.Printf("CA502P %s original48 independently owned records seeded",valid?"PASS":"FAIL");
            if(!valid){Console.Printf("CA502P RESULT passed=0 failed=1");return;}
        }
        else if(e.Name=="ca502p_legacyload")
        {
            let p=CA502PhysicalProof(u.FindInventory('CA502PhysicalProof'));
            bool ok=p!=null && p.Material!=null && p.Food!=null && p.Material.Amount==75 && p.Food.Amount==3
                && p.Food.FoodLots.Contamination(0)>=39 && CaelumContaminationStorage.Value(p.Material)==67;
            Console.Printf("CA502P %s original48 rollback keeps source save",ok?"PASS":"FAIL");
            if(!ok){Console.Printf("CA502P RESULT passed=0 failed=1");return;}
        }
        else return;
        Console.Printf("CA502P RESULT passed=1 failed=0");
    }
}
