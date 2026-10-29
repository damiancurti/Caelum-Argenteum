class CA502VesselProof : Inventory
{
    Array<CaelumConsumableItem> Items;
    CaelumDiningSetItem Set;
    CaelumPortableDiningTable Table;
    CaelumWaterContainer Nested;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA502VesselChecks : EventHandler
{
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="ca502v_legacyseed")
        {
            CaelumInventoryService.GrantMagicBoxFromPalomo(u,false);
            let proof=CA502VesselProof(u.GiveInventoryType('CA502VesselProof'));
            for(int i=0;i<3;i++)
            {
                Name kind=i==0?'CaelumBottleSmall':i==1?'CaelumMateGourd':'CaelumCampPot';
                let item=CaelumConsumableItem(Actor.Spawn(kind,u.Pos));item.AttachToOwner(u);item.InMagicBox=true;
                CaelumContaminationStorage.Set(item,37);proof.Items.Push(item);
            }
            Console.Printf("CA502V PASS original runtime seeds three generic vessel records");
        }
        else if(e.Name=="ca502v_legacyload")
        {
            let proof=CA502VesselProof(u.FindInventory('CA502VesselProof'));
            if(proof==null || proof.Items.Size()!=3){Console.Printf("CA502V FAIL original registry");return;}
            for(int i=0;i<3;i++)if(proof.Items[i]==null || proof.Items[i].Owner!=u || CaelumContaminationStorage.Value(proof.Items[i])!=37)
            {Console.Printf("CA502V FAIL original record");return;}
            Console.Printf("CA502V PASS original rollback restores native vessels and concentration");
        }
        else return;
        Console.Printf("CA502V RESULT passed=1 failed=0");
    }
}
