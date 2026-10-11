// Baseline-compatible seed and identity audit, loaded on both sides of migration.
class CA164Audit : Inventory
{
    int Mode,QuestStage,Count,HealthBefore;
    int Ids[32],Kinds[32],Types[32],Sizes[32],Wear[32];
    bool Boxed[32];
    CaelumTarotDeck Deck;
    CaelumMagicBox Box;
    void Capture(CaelumPlayer u,int mode)
    {
        self.Mode=mode;QuestStage=u.GetPersistentCharacterState(true).QuestStage[0];HealthBefore=u.health;
        Count=0;Deck=CaelumTarotDeck(u.FindInventory("CaelumTarotDeck"));Box=CaelumMagicBox.EnsureOwned(u);
        for(Inventory c=u.Inv;c!=null && Count<32;c=c.Inv)
        {
            let e=CaelumEquipmentItem(c);if(e==null)continue;
            Ids[Count]=e.ItemId;Kinds[Count]=e.EquipmentKind;Types[Count]=e.ItemType;
            Sizes[Count]=e.EquipmentSize;Wear[Count]=e.Durability;Boxed[Count]=e.InMagicBox;Count++;
        }
    }
    Default {Inventory.MaxAmount 1; Inventory.InterHubAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE}
    States {Spawn: TNT1 A -1; Stop;}
}
class CA164Legacy : EventHandler
{
    bool Done;
    static CaelumEquipmentItem Item(CaelumPlayer u,String cls,int kind,int type)
    {
        let e=CaelumEquipmentItem(Actor.Spawn(cls,u.Pos,NO_REPLACE));
        e.EquipmentKind=kind;e.ItemType=type;e.Tier=1;e.ArmorSlot=-1;e.EquipmentSize=3;
        e.Durability=37;e.WeaponDurabilityRevision=CaelumAttackRules.DURABILITY_REVISION;
        e.UnitWeight=1;e.ItemFlags=CaelumConstants.CA_ITEMFLAG_LIMBO_TEMP;
        e.PickupDataInitialized=true;e.AcquisitionResolved=true;e.AttachToOwner(u);u.EnsureEquipmentItemId(e);return e;
    }
    override void WorldTick()
    {
        if(Done || level.time<100)return;
        let u=CaelumPlayer(players[0].mo);if(u==null || !u.CharacterCreationComplete)return;Done=true;
        int mode=CVar.FindCVar('ca164_stage').GetInt();let r=u.GetPersistentCharacterState(true);
        r.EnsureQuestStateInitialized();r.DemoNarrativeDelivered=2047;r.DemoNarrativePending=0;
        r.QuestState[0]=CaelumConstants.QUEST_STATE_ACTIVE;r.QuestStage[0]=CaelumConstants.MAIN_M00_STATE_ARGENTO_ACTIVE;
        r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_PALOMO_MET);
        if(mode>0)
        {
            CaelumTarotDeckRules.Grant(u,false);r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_ARGENTO_STARTED);
            r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_ARGENTO_COMPLETE);
            r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_CAELLA_STARTED);
            r.QuestStage[0]=CaelumConstants.MAIN_M00_STATE_CAELLA_ACTIVE;
            if(mode==1)
            {
                Item(u,"CA_LimboMagicImplement",CaelumConstants.EQUIPMENT_KIND_WEAPON,CaelumConstants.WEAPON_TYPE_STAFF);
                Item(u,"CA_LimboMagicSeal",CaelumConstants.EQUIPMENT_KIND_SEAL,0);
                r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_MAGIC_PRIMARY_USED);
            }
        }
        if(mode>=2)
        {
            r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_CAELLA_COMPLETE);
            r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RONNIE_STARTED);
            r.MainM00StarterChosen=true;r.MainM00StarterOption=4;r.MainM00StarterSize=3;
            r.MainM00ArmorChosen=true;r.MainM00ArmorType=1;r.MainM00ArmorSize=3;
            r.MainM00SupplyIssued[CaelumConstants.MATERIAL_WOOD]=111;
            r.MainM00SupplyIssued[CaelumConstants.MATERIAL_LEATHER]=222;
            r.QuestStage[0]=CaelumConstants.MAIN_M00_STATE_RONNIE_ACTIVE;
            CaelumMainM00Loadout.TeachPlan(u);CaelumMainM00RonnieTrial.EnsurePickaxe(u);
            r.MainM00SupplyIssued[CaelumConstants.MATERIAL_WOOD]=111;
            r.MainM00SupplyIssued[CaelumConstants.MATERIAL_LEATHER]=222;
            if(mode==2){let sword=Item(u,"CA_LimboRonnieSword",CaelumConstants.EQUIPMENT_KIND_WEAPON,CaelumConstants.WEAPON_TYPE_SWORD);r.MainM00RonnieSwordId=sword.ItemId;}
        }
        if(mode>=3)
        {
            r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RONNIE_COMPLETE);
            r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RULO_STARTED);
            r.QuestStage[0]=CaelumConstants.MAIN_M00_STATE_RULO_ACTIVE;
        }
        if(mode==4)
        {
            r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RULO_COMPLETE);
            r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_BULL_DEFEATED);
            r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_MAGIC_BOX_GRANTED);
            r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_COMPLETE);
            u.GrantMagicBoxFromPalomo(false);r.QuestStage[0]=CaelumConstants.MAIN_M00_STATE_COMPLETE;
            r.QuestState[0]=CaelumConstants.QUEST_STATE_COMPLETED;
        }
        u.bInvulnerable=true;u.health=Max(2,u.health/2);u.player.health=u.health;
        let audit=CA164Audit(u.GiveInventoryType("CA164Audit"));audit.Capture(u,mode);u.PersistCharacterState();
        Console.Printf("CA164 BASELINE mode=%d stage=%d items=%d health=%d",mode,audit.QuestStage,audit.Count,audit.HealthBefore);
    }
}
