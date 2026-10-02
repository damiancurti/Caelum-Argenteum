// The same support classes are loaded before and after migration.
class Issue63Legacy : Object play
{
    static void Check(bool ok, String message) { Console.Printf("QA63 %s %s", ok ? "PASS" : "FAIL", message); }
    static CaelumPalomo Palomo() { let it=ThinkerIterator.Create("CaelumPalomo"); return CaelumPalomo(it.Next()); }
    static CaelumRonnie Ronnie() { let it=ThinkerIterator.Create("CaelumRonnie"); return CaelumRonnie(it.Next()); }
    static void Setup(CaelumPlayer u)
    {
        u.CharacterCreationComplete=true;u.CreationWizardOpen=false;u.bInvulnerable=true;
        let r=u.GetPersistentCharacterState(true);r.EnsureQuestStateInitialized();
        r.DemoNarrativeDelivered=2047;r.DemoNarrativePending=0;
        r.QuestState[0]=CaelumConstants.QUEST_STATE_ACTIVE;
        r.QuestStage[0]=CaelumConstants.MAIN_M00_STATE_MET_PALOMO;
        r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD);
        u.ApplyCharacterProfile();
    }
    static CaelumEquipmentItem Item(CaelumPlayer u, String cls, int kind, int type, int slot, bool boxed, bool temp)
    {
        let item=CaelumEquipmentItem(Actor.Spawn(cls,u.Pos,NO_REPLACE));
        item.EquipmentKind=kind;item.ItemType=type;item.ArmorSlot=slot;item.Tier=1;
        item.EquipmentSize=CaelumConstants.EQUIPMENT_SIZE_M;item.Durability=37;
        item.WeaponDurabilityRevision=CaelumAttackRules.DURABILITY_REVISION;
        item.UnitWeight=1;item.InMagicBox=boxed;item.Equipped=false;item.PickupDataInitialized=true;
        item.AcquisitionResolved=true;item.ItemFlags=temp?CaelumConstants.CA_ITEMFLAG_LIMBO_TEMP:0;
        item.AttachToOwner(u);u.EnsureEquipmentItemId(item);return item;
    }
    static void Dump(CaelumPlayer u, String label)
    {
        let r=u.GetPersistentCharacterState(true);
        Console.Printf("QA63 STATE %s stage=%d started=%d option=%d size=%d armor=%d seal=%d first=%d",label,r.QuestStage[0],r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RONNIE_STARTED),r.MainM00StarterOption,r.MainM00StarterSize,r.MainM00ArmorType,r.MainM00SealChoice,r.MainM00StarterWeaponId);
        for(Inventory c=u.Inv;c!=null;c=c.Inv)
        {
            let e=CaelumEquipmentItem(c);if(e!=null) Console.Printf("QA63 ITEM %s id=%d kind=%d type=%d size=%d durability=%d boxed=%d equipped=%d flags=%d",label,e.ItemId,e.EquipmentKind,e.ItemType,e.EquipmentSize,e.Durability,e.InMagicBox,e.Equipped,e.ItemFlags);
        }
    }
}
class Issue63Pre : CaelumSocialDebugAction
{
    override bool Use(bool pickup) { let u=CaelumPlayer(Owner);Issue63Legacy.Setup(u);Issue63Legacy.Dump(u,"pre");return true; }
}
class Issue63Post : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        let u=CaelumPlayer(Owner);let r=u.GetPersistentCharacterState(true);
        r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_PALOMO_MET);
        r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_CAELLA_COMPLETE);
        r.QuestStage[0]=CaelumConstants.MAIN_M00_STATE_CAELLA_COMPLETE;
        u.player.ConversationNPC=Issue63Legacy.Ronnie();
        Issue63Legacy.Check(CaelumMainM00RonnieTrial.Choose(u,4),"legacy native weapon choice");
        Issue63Legacy.Check(CaelumMainM00SupplyRules.ChooseArmor(u,1),"legacy native armor choice");
        let it=ThinkerIterator.Create("CaelumCaella");u.player.ConversationNPC=Actor(it.Next());
        Issue63Legacy.Check(CaelumMainM00SealCrafting.Choose(u,false,2),"legacy native seal choice");
        r.MainM00SupplyIssued[CaelumConstants.MATERIAL_WOOD]=111;
        r.MainM00SupplyIssued[CaelumConstants.MATERIAL_LEATHER]=222;
        let a=Issue63Legacy.Item(u,"CaelumArmorPickup",CaelumConstants.EQUIPMENT_KIND_ARMOR,1,0,false,true);
        let e=Issue63Legacy.Item(u,"CaelumSealPickup",CaelumConstants.EQUIPMENT_KIND_SEAL,2,-1,true,true);
        u.player.ConversationNPC=null;u.PersistCharacterState();Issue63Legacy.Dump(u,"post");return true;
    }
}
class Issue63Completed : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        let u=CaelumPlayer(Owner);let r=u.GetPersistentCharacterState(true);
        let first=Issue63Legacy.Item(u,"CaelumWeaponPickup",CaelumConstants.EQUIPMENT_KIND_WEAPON,CaelumConstants.WEAPON_TYPE_SWORD,-1,false,false);
        u.CraftingSelectionRecipe=CaelumMainM00StarterRules.GetRecipe(r.MainM00StarterOption);u.CraftingSelectionTier=1;
        CaelumMainM00RonnieTrial.RecordCraft(u,first);u.player.ConversationNPC=Issue63Legacy.Ronnie();
        Issue63Legacy.Check(CaelumMainM00RonnieTrial.Finish(u),"legacy completed tutorial has crafted weapon and returned loan");
        r.QuestStage[0]=CaelumConstants.MAIN_M00_STATE_COMPLETE;
        r.QuestState[0]=CaelumConstants.QUEST_STATE_COMPLETED;
        r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RONNIE_COMPLETE);
        r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_COMPLETE);
        u.PersistCharacterState();Issue63Legacy.Dump(u,"complete");return true;
    }
}
