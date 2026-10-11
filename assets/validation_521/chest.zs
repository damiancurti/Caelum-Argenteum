class CA177Chest : EventHandler
{
    int Age;
    int Issued[CaelumConstants.MATERIAL_TYPE_COUNT];
    static void Check(bool ok,String label){Console.Printf("CA177 %s %s",ok?"PASS":"FAIL",label);}
    static CaelumMainM00SupplyChest Open(CaelumPlayer u)
    {
        CA177Route.EndTalk(u);
        let chest=CaelumMainM00SupplyChest(CA177Route.Find("CaelumMainM00SupplyChest"));
        u.SetOrigin(chest.Pos+(0,-80,0),false);u.Vel=(0,0,0);u.Angle=90;
        u.Pitch=atan2(u.ViewHeight-chest.Height/2,80);
        chest.UseLatched=false;chest.Used(u);return chest;
    }
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);if(u==null || !u.CharacterCreationComplete)return;
        let r=u.GetPersistentCharacterState(true);Age++;
        if(Age==1){r.DemoNarrativeDelivered=2047;r.DemoNarrativePending=0;r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD);}
        if(Age==100)
        {
            r.DemoNarrativeDelivered=2047;r.DemoNarrativePending=0;
            r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_PALOMO_MET);
            r.QuestStage[0]=CaelumConstants.MAIN_M00_STATE_ARGENTO_ACTIVE;
            let chest=Open(u);let p=CaelumChestPreviewState.Get(u);
            Check(p!=null && p.TutorialChest==chest && p.Count==0 && !u.HasActiveConversation(),"unconfirmed chest uses empty loot preview instead of conversation");
            p.Close();CA177Route.Palomo(u);
            Check(CaelumMainM00Loadout.Choose(u,0,12),"Palomo confirms the actual shotgun recipe");
            chest=Open(u);p=CaelumChestPreviewState.Get(u);
            Check(p.Count>0 && !CaelumMainM00RonnieTrial.IsStarted(u),"confirmed weapon materials appear before Ronnie starts");
            let needs=new("CaelumMainM00StarterMaterials");needs.Build(12,r.MainM00StarterSize,2);
            bool matches=true;
            for(int i=0;i<CaelumConstants.MATERIAL_TYPE_COUNT;i++)matches=matches && CaelumMainM00SupplyRules.Remaining(u,i)==needs.Units[i];
            Check(matches,"all shotgun raw materials match the existing 100-percent recipe graph");
            chest.Collect(u);p.Refresh();
            Check(p.Count==0,"collect transfers the whole fitting plan and empties the chest");
            for(int i=0;i<CaelumConstants.MATERIAL_TYPE_COUNT;i++)Issued[i]=r.MainM00SupplyIssued[i];
            chest.Collect(u);CaelumMainM00SupplyRules.UpdateLimits(u);
            bool same=true;for(int i=0;i<CaelumConstants.MATERIAL_TYPE_COUNT;i++)same=same && Issued[i]==r.MainM00SupplyIssued[i];
            Check(same,"repeated collection and plan refresh cannot refill spent stock");
            p.Close();CA177Route.Palomo(u);
            Check(CaelumMainM00Loadout.Choose(u,1,0),"optional armor confirmation succeeds after collection");
            chest=Open(u);p=CaelumChestPreviewState.Get(u);same=true;
            for(int i=0;i<CaelumConstants.MATERIAL_TYPE_COUNT;i++)same=same && Issued[i]==r.MainM00SupplyIssued[i];
            Check(p.Count>0 && same,"later armor adds its own stock without resetting past withdrawals");
            p.Close();
            u.RefreshCarriedInventorySummary();double capacity=u.DerivedStats.CarryCapacity;
            u.DerivedStats.CarryCapacity=u.DerivedStats.CarriedWeight;
            chest.Collect(u);
            same=true;for(int i=0;i<CaelumConstants.MATERIAL_TYPE_COUNT;i++)same=same && Issued[i]==r.MainM00SupplyIssued[i];
            Check(same,"full carrying capacity leaves all remaining stock inside");
            u.DerivedStats.CarryCapacity=capacity;u.ApplyCharacterProfile();
            u.Pitch=180;chest.Collect(u);
            same=true;for(int i=0;i<CaelumConstants.MATERIAL_TYPE_COUNT;i++)same=same && Issued[i]==r.MainM00SupplyIssued[i];
            Check(same,"collect revalidates aim instead of trusting an old preview");
            // The optional shield may be confirmed before a weapon on a large profile.
            p.Close();CA177Route.Palomo(u);r.MainM00StarterChosen=false;
            u.CharacterProfile.Race=CaelumConstants.RACE_BEAST_MAN;
            u.CharacterProfile.HeightChoice=CaelumConstants.HEIGHT_TALL;u.ApplyCharacterProfile();
            Check(CaelumMainM00Loadout.Choose(u,3,3),"optional shield can precede the weapon");
            let expected=new("CaelumMainM00StarterMaterials");expected.Efficiency=2;
            expected.AddArmor(r.MainM00ArmorType,r.MainM00ArmorSize);
            expected.AddShield(3,CaelumEquipmentRules.GetDefaultSizeForCharacterTier(u.CharacterProfile.GetSizeTier()));
            same=true;for(int i=0;i<CaelumConstants.MATERIAL_TYPE_COUNT;i++)same=same && r.MainM00SupplyLimit[i]==expected.Units[i];
            Check(same,"shield-first material plan uses the character size before a weapon exists");
        }
        if(Age==140){Open(u);Console.Printf("CA177 CHEST_DONE");}
    }
}
