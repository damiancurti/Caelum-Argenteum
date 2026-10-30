class CA430GiftChecks : EventHandler
{
    CaelumCompanionBond Bond;
    CaelumCompanionSession Session;
    Inventory SavedGift;
    int Passes,Failures;
    void Check(bool ok,String label)
    {if(ok){Passes++;Console.Printf("CA430 PASS %s",label);}else{Failures++;Console.Printf("CA430 FAIL %s",label);}}
    void StackCase(class<Inventory> type,String label)
    {
        let user=CaelumPlayer(players[0].mo);
        let item=Inventory(Actor.Spawn(type,user.Pos,NO_REPLACE));item.Amount=20;item.AttachToOwner(user);
        double value=CaelumEconomyRules.GetInventoryStackBaseValue(item),before=Bond.Trust;
        Session.PlayerItems=true;
        Check(Session.Transfer(item,false) && Abs(Bond.Trust-before-value/1000)<0.00000001,
            String.Format("%s initial gift credits its real value",label));
        Session.PlayerItems=false;Check(Session.Transfer(item,false),String.Format("%s returns after native consent",label));
        let split=item.CreateTossable(7);
        Check(split!=null && split.Amount==7 && item.Amount==13,String.Format("%s native split conserves units",label));
        if(split==null)return;
        split.AttachToOwner(user);Session.PlayerItems=true;before=Bond.Trust;
        Check(Session.Transfer(split,false) && Bond.Trust==before,String.Format("%s split regift cannot farm trust",label));
        let fresh=Inventory(Actor.Spawn(type,user.Pos,NO_REPLACE));fresh.Amount=5;
        double freshValue=CaelumEconomyRules.GetInventoryStackBaseValue(fresh);
        int oldAmount=item.Amount;Actor toucher=user;bool picked=fresh.CallTryPickup(toucher);
        Check(picked && item.Amount==oldAmount+5,String.Format("%s native pickup merges fresh units",label));
        Check(Session.Transfer(item,false) && Abs(Bond.Trust-before-freshValue/1000)<0.00000001,
            String.Format("%s mixed gift credits only previously ungifted units",label));
        SavedGift=item;
        // A split loan and a rejected request must retain their independent state.
        let loan=Inventory(Actor.Spawn(type,user.Pos,NO_REPLACE));loan.Amount=20;loan.AttachToOwner(user);
        CaelumCompanionProvenance.View(loan,Bond).Gift(true,0);
        let part=loan.CreateTossable(5);
        Check(part!=null && CaelumCompanionProvenance.View(part,Bond).IsLoan(),String.Format("%s split retains lender",label));
        if(part!=null)
        {
            CaelumCompanionProvenance.View(part,Bond).Gift(false,0);
            Check(CaelumCompanionProvenance.View(loan,Bond).IsLoan(),String.Format("%s gifting a fragment does not alter the remaining loan",label));
            CaelumCompanionProvenance.View(part,Bond).Consent(true,7,3);
            part.AttachToOwner(user);let refused=part.CreateTossable(2);
            Check(refused!=null && CaelumCompanionProvenance.View(refused,Bond).Refused(7,3),
                String.Format("%s split retains the saved refusal",label));
        }
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[0].mo);
        if(e.Name=='ca430_gifts')
        {
            Bond=CaelumCompanionParty.Get(user).Find(8);Bond.Body.SetOrigin(user.Pos+(80,0,0),false);
            CaelumCompanionSession.Show(user,Bond.Body);Session=CaelumCompanionSession(user.FindInventory("CaelumCompanionSession"));
            double charisma=user.Attributes.Charisma;user.Attributes.Charisma=1000;
            StackCase(CaelumEconomyRules.GetCurrencyClassName(0),"coins");
            StackCase("CaelumMaterialPickup","materials");
            StackCase("CaelumCarbineAmmo","carbine ammunition");
            StackCase("CaelumArrowAmmo","arrows");
            StackCase("CaelumFoodRation","food");
            StackCase("CaelumLifePotion","medicine");
            let item=Bond.Loadout.MakeItem("CaelumArmorPickup",CaelumConstants.EQUIPMENT_KIND_ARMOR,0,1,2,100,1,null);
            item.ArmorSlot=0;CaelumCompanionProvenance.View(item,Bond).Gift(false,10);
            CaelumCompanionProvenance.View(item,Bond).Consent(true,7,3);
            let copy=item.CreateTossable(1);
            Check(copy!=null && CaelumCompanionProvenance.View(copy,Bond).Gift(false,10)==0,
                "native equipment drop preserves the credited identity");
            Check(copy!=null && CaelumCompanionProvenance.View(copy,Bond).Refused(7,3),
                "native equipment drop preserves the saved refusal");
            user.Attributes.Charisma=charisma;Session.Open=false;
            Console.Printf("CA430 RESULT gifts passes=%d failures=%d",Passes,Failures);
        }
        if(e.Name=='ca430_giftreload')
        {
            Check(SavedGift!=null && SavedGift.Owner==Bond.Body,"save retains the gifted native stack");
            Check(CaelumCompanionProvenance.View(SavedGift,Bond).Gift(false,100)==0,"save retains per-unit gift credit");
            Console.Printf("CA430 RESULT gift reload failures=%d",Failures);
        }
    }
}
