class CA502StackProof : Inventory
{
    CaelumMaterialPickup Item;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA502StackChecks : EventHandler
{
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="ca502s_legacyseed")
        {
            let proof=CA502StackProof(u.GiveInventoryType('CA502StackProof'));
            let item=CaelumMaterialPickup(Actor.Spawn('CaelumMaterialPickup',u.Pos));
            item.args[0]=20;item.args[1]=1;item.Amount=100;item.AttachToOwner(u);item.InMagicBox=true;
            CaelumContaminationStorage.Set(item,37);proof.Item=item;
            Console.Printf("CA502S PASS original runtime seeds generic contamination");
        }
        else if(e.Name=="ca502s_legacyload")
        {
            let proof=CA502StackProof(u.FindInventory('CA502StackProof'));
            if(proof==null || proof.Item==null || proof.Item.Amount!=100 || CaelumContaminationStorage.Value(proof.Item)!=37)
            {Console.Printf("CA502S FAIL original rollback");return;}
            Console.Printf("CA502S PASS original runtime restores original saved units and concentration");
        }
        else return;
        Console.Printf("CA502S RESULT passed=1 failed=0");
    }
}
