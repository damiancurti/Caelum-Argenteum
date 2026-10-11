// Native catalogue, recommendation, transaction and finite-budget checks.
// Synthetic profiles are confined to this development-only fixture.
class CA183Matrix : EventHandler
{
    int Age, Cases, Failures;
    void Check(bool ok, String label)
    { if (!ok) { Failures++; Console.Printf("CA183 FAIL %s", label); } }
    override void WorldTick()
    {
        let u = CaelumPlayer(players[0].mo); if (u == null || !u.CharacterCreationComplete) return;
        let r = u.GetPersistentCharacterState(true); Age++;
        if (Age == 1) { r.DemoNarrativeDelivered=2047;r.DemoNarrativePending=0;u.bInvulnerable=true; }
        if (Age != 90) return;
        for (int race=0;race<4;race++) for(int first=0;first<4;first++) for(int second=0;second<4;second++)
        {
            let p=new("CaelumCharacterProfile");p.Race=race;p.FirstClass=first;p.SecondClass=second;
            let a=new("CaelumCharacterAllocation");a.Recommend(p);
            Check(a.GetSpentLayerPoints()==4 && a.GetSpentAttributePoints()==30,"recommendation spends 4/30");
            for(int f=0;f<4;f++)Check(a.GetFinalLayerBase(p,f)<=15,"family cap");
            for(int attr=0;attr<12;attr++)Check(a.AttributeBonus[attr]>=0 && a.AttributeBonus[attr]<=a.GetMaximumIndividualBonus(p,attr),"individual cap");
            int preferred=CaelumCharacterAllocation.PreferredFamily(first);
            int necklace=CaelumOnboardingCatalogue.Necklace(first);
            Check(CaelumEquipmentRules.AmuletFamilyBonus(necklace,preferred,1)==6,"first-choice necklace main bonus");
            Cases++;
        }
        let p=new("CaelumCharacterProfile");p.Race=0;p.FirstClass=0;p.SecondClass=0;
        let allocation=new("CaelumCharacterAllocation");allocation.Recommend(p);
        Check(allocation.LayerBonus[0]==0 && allocation.LayerBonus[1]==4,"saturated Physical falls back to Technical");
        Check(CaelumEquipmentRules.MagicBoxSlots(0)==30 && CaelumEquipmentRules.MagicBoxSlots(100)==100,"new Box endpoints");
        Console.Printf("CA183 ALLOCATIONS cases=%d failures=%d",Cases,Failures);

        // Independent author table, indexed by the ten native professions.
        int weapons[10]={10,15,19,1,0,8,13,17,16,18};
        int shields[10]={2,0,0,3,1,1,1,0,3,3};
        int armors[10]={3,1,1,0,2,2,2,1,0,0};
        u.DebugAttributesAt100=true;u.ApplyCharacterProfile();
        for(int profession=0;profession<10;profession++) for(int size=0;size<5;size++)
        {
            Check(CaelumOnboardingCatalogue.Weapon(profession)==weapons[profession],"author weapon table");
            Check(CaelumOnboardingCatalogue.Shield(profession)==shields[profession],"author shield/armor table");
            Check(CaelumOnboardingCatalogue.Armor(profession)==armors[profession],"author armor table including Investigator/Priest");
            int option=CaelumOnboardingCatalogue.StarterOption(profession);
            Check(CaelumMainM00StarterRules.GetWeaponType(option)==weapons[profession],"starter option resolves actual item");
            r.MainM00StarterOption=option;
            int before[CaelumConstants.MATERIAL_TYPE_COUNT];
            for(int m=0;m<CaelumConstants.MATERIAL_TYPE_COUNT;m++)before[m]=r.MainM00MazeRepairUnits[m];
            int id=CaelumOnboarding.Grant(u,0,CaelumConstants.EQUIPMENT_KIND_WEAPON,weapons[profession],size);
            let weapon=u.FindNativeEquipmentItemById(id);
            Check(id>0 && weapon!=null,"fixed weapon grant succeeds");
            if(weapon==null)continue;
            Check(weapon.EquipmentSize==size && weapon.EssenceType==CaelumConstants.ESSENCE_FIRE,"weapon size/fire essence");
            weapon.Durability=Max(1,weapon.Durability/2);u.WeaponModel.Durability=weapon.Durability;
            int worn=weapon.Durability;
            int again=CaelumOnboarding.Grant(u,id,CaelumConstants.EQUIPMENT_KIND_WEAPON,weapons[profession],size);
            Check(id==again && worn==weapon.Durability,"gift repeat retains exact ID/wear");
            // The native repair preview is the independent transaction oracle.
            let old=u.CraftingBrowser;int efficiency=u.CraftingEfficiencyIndex;
            let cost=new("CaelumCraftingBrowser");u.CraftingBrowser=cost;u.CraftingEfficiencyIndex=2;
            Check(CaelumInventoryService.BuildEquipmentTaskMaterials(u,weapon,1,false,cost),"full repair recipe available");
            u.CraftingBrowser=old;u.CraftingEfficiencyIndex=efficiency;
            for(int i=0;i<cost.MaterialTypes.Size();i++)
                Check(r.MainM00MazeRepairUnits[cost.MaterialTypes[i]]-before[cost.MaterialTypes[i]]==3*cost.MaterialUnits[i],"exact three weapon repairs");
            for(int slot=0;slot<4;slot++)
            {
                int aid=CaelumOnboarding.Grant(u,0,CaelumConstants.EQUIPMENT_KIND_ARMOR,armors[profession],size,slot);
                let armor=u.FindNativeEquipmentItemById(aid);
                Check(armor!=null && armor.EquipmentSize==size && armor.ItemType==armors[profession] && armor.ArmorSlot==slot,"full matching armor piece");
                if(armor!=null)armor.Destroy();
            }
            // Each chest share must sum exactly, with no per-chest multiplication.
            int totals[CaelumConstants.MATERIAL_TYPE_COUNT];
            for(int m=0;m<CaelumConstants.MATERIAL_TYPE_COUNT;m++)totals[m]=0;
            for(int chest=0;chest<39;chest++)
            {
                let box=CaelumMazeChest(Actor.Spawn("CaelumMazeChest",u.Pos,NO_REPLACE));box.args[0]=chest;
                let budget=box.PreviewBudget(u);
                for(int m=0;m<CaelumConstants.MATERIAL_TYPE_COUNT;m++)totals[m]+=budget.Units[m];
                box.Destroy();
            }
            for(int m=0;m<CaelumConstants.MATERIAL_TYPE_COUNT;m++)Check(totals[m]==r.MainM00MazeRepairUnits[m],"39 chest shares preserve aggregate");
            Console.Printf("CA183 KIT profession=%d size=%d weapon=%d armor=%d repair_materials=%d",profession,size,weapons[profession],shields[profession],cost.MaterialTypes.Size());
            weapon.Equipped=false;u.WeaponModel.Equipped=false;u.ActiveWeaponItemId=0;weapon.Destroy();
        }
        Console.Printf("CA183 MATRIX_DONE recommendations=64 kits=50 failures=%d",Failures);
    }
}
