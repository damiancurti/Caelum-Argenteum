// Actual unboxed gift capacity across all race/class/sex/height combinations.
class CA183Capacity : EventHandler
{
    int Age, Cases, Failures;
    void Check(bool ok,String label){if(!ok){Failures++;Console.Printf("CA183 FAIL %s",label);}}
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);if(u==null || !u.CharacterCreationComplete)return;Age++;
        let r=u.GetPersistentCharacterState(true);
        if(Age==1){r.DemoNarrativeDelivered=2047;r.DemoNarrativePending=0;u.bInvulnerable=true;}
        if(Age!=90)return;
        u.DebugAttributesAt100=false;
        for(int race=0;race<4;race++)for(int first=0;first<4;first++)for(int second=0;second<4;second++)for(int sex=0;sex<2;sex++)for(int height=0;height<3;height++)
        {
            for(Inventory item=u.Inv;item!=null;){let next=item.Inv;if(item is "CaelumEquipmentItem" || item is "CaelumTarotDeck" || item is "Ammo")item.Destroy();item=next;}
            u.ActiveWeaponItemId=0;u.WeaponModel.Equipped=false;
            r.MainM00StarterChosen=false;r.MainM00StarterWeaponId=0;r.MainM00ShieldId=0;r.MainM00NecklaceRevision=0;r.MainM00NecklaceItemId=0;
            r.MainM00PickaxeRevision=0;r.MainM00PickaxeId=0;r.MainM00UtilityStaffId=0;r.MainM00BolasId=0;r.MainM00StarterAmmoIssued=0;
            for(int s=0;s<4;s++)r.MainM00ArmorIds[s]=0;
            for(int m=0;m<CaelumConstants.MATERIAL_TYPE_COUNT;m++)r.MainM00MazeRepairUnits[m]=0;
            u.CharacterProfile.Race=race;u.CharacterProfile.FirstClass=first;u.CharacterProfile.SecondClass=second;u.CharacterProfile.Sex=sex;u.CharacterProfile.HeightChoice=height;
            u.CharacterAllocation.Recommend(u.CharacterProfile);u.ApplyCharacterProfile();
            r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_ARGENTO_STARTED);r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_CAELLA_STARTED);r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RONNIE_STARTED);
            r.MainM00Flag[CaelumConstants.MAIN_M00_FLAG_RULO_STARTED]=false;
            CaelumOnboarding.Update(u);CaelumTarotDeckRules.Grant(u);CaelumMainM00Gifts.EnsureTool(u,false);CaelumMainM00Necklace.EnsureGranted(u);CaelumMainM00RonnieTrial.EnsurePickaxe(u);
            u.RefreshCarriedInventorySummary();
            String label=String.Format("profile %d/%d/%d/%d/%d",race,first,second,sex,height);
            Check(r.MainM00StarterWeaponId>0 && r.MainM00ShieldId>0 && r.MainM00NecklaceItemId>0 && r.MainM00PickaxeId>0 && r.MainM00UtilityStaffId>0,label.." first resident gifts");
            Check(u.CanAddWeightToPersonalInventory(3.1),label.." exact crafting supply fits before Box");
            r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RULO_STARTED);CaelumMainM00Gifts.EnsureTool(u,true);CaelumOnboarding.Update(u);
            Check(r.MainM00BolasId>0,label.." bolas grant");for(int s=0;s<4;s++)Check(r.MainM00ArmorIds[s]>0,label.." armor grant");
            // Independent full-repair sum for the actual delivered initial items.
            int expected[CaelumConstants.MATERIAL_TYPE_COUNT];for(int m=0;m<CaelumConstants.MATERIAL_TYPE_COUNT;m++)expected[m]=0;
            let old=u.CraftingBrowser;int efficiency=u.CraftingEfficiencyIndex;u.CraftingEfficiencyIndex=2;
            for(Inventory item=u.Inv;item!=null;item=item.Inv)
            {
                let piece=CaelumEquipmentItem(item);if(piece==null)continue;
                int count=piece.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_ARMOR?1:piece.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_WEAPON?(piece.ItemId==r.MainM00StarterWeaponId?3:5):0;
                if(count==0)continue;
                let preview=new("CaelumCraftingBrowser");u.CraftingBrowser=preview;
                Check(CaelumInventoryService.BuildEquipmentTaskMaterials(u,piece,1,false,preview,piece.ItemType==CaelumConstants.WEAPON_TYPE_BOLAS) && preview.MaterialTypes.Size()>0,label.." actual recipe oracle (bolas replacement)");
                for(int n=0;n<preview.MaterialTypes.Size();n++)expected[preview.MaterialTypes[n]]+=count*preview.MaterialUnits[n];
            }
            u.CraftingBrowser=old;u.CraftingEfficiencyIndex=efficiency;
            for(int m=0;m<CaelumConstants.MATERIAL_TYPE_COUNT;m++)Check(expected[m]==r.MainM00MazeRepairUnits[m],label.." 1 armor/3 weapon/5 each tool budget");
            Cases++;
        }
        Console.Printf("CA183 CAPACITY_DONE cases=%d failures=%d",Cases,Failures);
    }
}
