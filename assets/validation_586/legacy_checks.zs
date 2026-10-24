// Prueba de partida original: referencias reales para detectar recreaciones.
class CA411Proof : Inventory
{
    CaelumStashChest OriginalChest;
    CaelumPortDefender OriginalBody;
    CaelumLockIdentity OriginalPair;
    Inventory OriginalGold;
    int OriginalHealth;
    bool RestoredFromHub;
    Default {Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA411Legacy : EventHandler
{
    int Passed,Failed;
    void Check(bool ok,String label){if(ok)Passed++;else Failed++;Console.Printf("CA411 %s %s",ok?"PASS":"FAIL",label);}
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[e.Player].mo);if(user==null)return;
        let roster=CaelumHouseResidents.Get(true);
        let proof=CA411Proof(user.FindInventory("CA411Proof"));
        if(e.Name=="ca411_legacy_seed")
        {
            proof=CA411Proof(user.GiveInventoryType("CA411Proof"));
            let iterator=ThinkerIterator.Create("CaelumStashChest");CaelumStashChest chest;
            while((chest=CaelumStashChest(iterator.Next()))!=null)
                if(chest.LawfulOwner!=null && chest.LawfulOwner.Token=="house:CAH069"){proof.OriginalChest=chest;break;}
            Check(proof.OriginalChest!=null,"original owned chest exists");
            if(proof.OriginalChest!=null)
            {
                let chest=proof.OriginalChest;chest.ChangeTid(26411);
                proof.OriginalPair=chest.InstalledPadlock.PairIdentity;
                proof.OriginalGold=chest.FindInventory(CaelumEconomyRules.GetCurrencyClassName(CaelumConstants.CURRENCY_GOLD));
                proof.OriginalGold.Amount=7;proof.OriginalGold.ChangeTid(26412);
            }
            proof.OriginalBody=roster.Residents[69].Body;
            proof.OriginalBody.CombatTimeRemaining=1000;
            proof.OriginalBody.health=Max(1,proof.OriginalBody.CombatMaximumHealth/2);proof.OriginalHealth=proof.OriginalBody.health;
            Check(proof.OriginalBody!=null && roster.Residents.Size()==600,"original resident and census exist");
        }
        else if(e.Name=="ca411_legacy_verify")
        {
            if(proof!=null && proof.OriginalChest==null && level.MapName=="CAH070")
            {
                let found=ActorIterator.Create(26411,"CaelumStashChest");
                proof.OriginalChest=CaelumStashChest(found.Next());
                Check(proof.OriginalChest!=null && found.Next()==null,"one original chest restored by native hub identity");
                if(proof.OriginalChest!=null)
                    proof.OriginalGold=proof.OriginalChest.FindInventory(CaelumEconomyRules.GetCurrencyClassName(CaelumConstants.CURRENCY_GOLD));
                proof.RestoredFromHub=true;
            }
            Check(proof!=null && proof.OriginalChest!=null && proof.OriginalBody!=null,"original actors available for verification");
            if(proof!=null && proof.OriginalChest!=null && proof.OriginalBody!=null)
            {
                Check(proof.OriginalBody==roster.Residents[69].Body,"resident body was not recreated");
                Check(proof.OriginalBody.health>=proof.OriginalHealth && proof.OriginalBody.health<proof.OriginalBody.CombatMaximumHealth,"resident injury retained with normal regeneration");
                Check(proof.OriginalGold!=null && proof.OriginalGold.Owner==proof.OriginalChest && proof.OriginalGold.Amount==7,proof.RestoredFromHub?"hub-restored content retains owner and quantity":"same content actor retains owner and quantity");
                Check(proof.OriginalChest.InstalledPadlock!=null && CaelumLockRules.SamePair(proof.OriginalChest.InstalledPadlock.PairIdentity,proof.OriginalPair),"original lock identity retained");
                bool key=false;
                for(Inventory item=proof.OriginalBody.Inv;item!=null;item=item.Inv)
                {let lock=CaelumLockItem(item);if(lock!=null && CaelumLockRules.SamePair(lock.PairIdentity,proof.OriginalPair))key=true;}
                Check(key,"resident retains matching key");
                Check(proof.OriginalChest.TID==26411 && proof.OriginalGold.TID==26412,"native actor identities retained");
                VERIFY_MIGRATION
            }
        }
        else if(e.Name=="ca411_return")
        {
            VERIFY_RETURN
        }
        else return;
        Console.Printf("CA411 RESULT legacy passes=%d failures=%d",Passed,Failed);
    }
}
