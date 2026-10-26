class CA502HProof : Inventory
{
    double Water,Stamp,Capacity,Contamination,Remaining;
    CaelumDomesticWaterState Reserve;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA502HChecks : EventHandler
{
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca502h_old_seed')
        {
            let proof=CA502HProof(u.GiveInventoryType('CA502HProof'));
            let illness=CaelumFoodIllness.Get(u);illness.Contamination=33.5;illness.ToiletCapacity=4.25;
            let water=CaelumDomesticWater.Get(0);water.Liters=73.25;
            proof.Reserve=water;proof.Water=water.Liters;proof.Stamp=water.Stamp;proof.Capacity=illness.ToiletCapacity;
            Console.Printf("CA502H PASS original runtime seeds existing water and illness");
        }
        else if(e.Name=='ca502h_old_verify')
        {
            let proof=CA502HProof(u.FindInventory('CA502HProof'));
            if(proof==null || CaelumFoodIllness.Get(u).ToiletCapacity!=4.25 || CaelumDomesticWater.Get(0)!=proof.Reserve)
                Console.Printf("CA502H FAIL original rollback");
            else Console.Printf("CA502H PASS original rollback preserves original credit and reserve");
        }
        else return;
        Console.Printf("CA502H RESULT original-runtime check executed");
    }
}
