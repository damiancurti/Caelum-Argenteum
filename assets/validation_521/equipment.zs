// Isolated transactions cover ranged preparation, optional outputs and guards.
class CA177Equipment : EventHandler
{
    int Age, BolasId, StarterId;
    static void Check(bool ok,String label){Console.Printf("CA177 %s %s",ok?"PASS":"FAIL",label);}
    static CaelumEquipmentItem Item(CaelumPlayer u,int type,int size)
    {
        let item=CaelumEquipmentItem(Actor.Spawn("CaelumWeaponPickup",u.Pos,NO_REPLACE));
        item.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;item.ItemType=type;
        item.Tier=1;item.EquipmentSize=size;item.EssenceType=0;
        item.SizePolicy=CaelumEquipmentRules.FIXED_SIZE;
        item.Durability=u.WeaponModel.GetMaximumDurabilityFor(type,1,size);
        item.UnitWeight=u.WeaponModel.GetWeightFor(type,1,size);
        item.WeaponDurabilityRevision=CaelumAttackRules.DURABILITY_REVISION;
        item.PickupDataInitialized=true;item.AcquisitionResolved=true;
        item.AttachToOwner(u);u.EnsureEquipmentItemId(item);return item;
    }
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);if(u==null || !u.CharacterCreationComplete)return;
        Age++;let r=u.GetPersistentCharacterState(true);
        if(Age==100)
        {
            r.DemoNarrativeDelivered=2047;r.DemoNarrativePending=0;
            r.EnsureQuestStateInitialized();r.QuestState[0]=CaelumConstants.QUEST_STATE_ACTIVE;
            r.QuestStage[0]=CaelumConstants.MAIN_M00_STATE_WEAPON_READY;
            r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_ARGENTO_COMPLETE);
            r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_CAELLA_COMPLETE);
            r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RONNIE_STARTED);
            r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RONNIE_COMPLETE);
            CaelumMainM00RonnieTrial.EnsurePickaxe(u);
            int size=CaelumEquipmentRules.ResolveAcquisitionSize(u,CaelumEquipmentRules.CHARACTER_DEFAULT,2);
            let gun=Item(u,CaelumConstants.WEAPON_TYPE_SHOTGUN,size);
            gun.Equipped=true;u.ActivateExactEquippedWeapon(gun);
            r.MainM00StarterWeaponId=gun.ItemId;StarterId=gun.ItemId;
            let npc=Actor(ThinkerIterator.Create("CaelumRulo").Next());
            u.SetOrigin(npc.Pos+(0,-64,0),false);u.player.ConversationNPC=npc;npc.bInConversation=true;
            Check(CaelumMainM00RuloTrial.Begin(u),"ranged starter begins Rulo");
            BolasId=r.MainM00BolasId;
            Check(u.ActiveWeaponItemId==BolasId,"new bolas remain active after ranged preparation");
            Check(r.MainM00AmmoLoanRemaining==24 && r.MainM00AmmoLoanType==CaelumConstants.AMMUNITION_SHOTGUN,"ranged starter still receives its existing practice cartridges");
            npc.bInConversation=false;u.player.ConversationNPC=null;
        }
        if(Age==140)
        {
            Console.Printf("CA177 ACTIVE item=%d bolas=%d type=%d ready=%s",u.ActiveWeaponItemId,BolasId,u.WeaponModel.WeaponType,u.player.ReadyWeapon==null?"null":String.Format("%s",u.player.ReadyWeapon.GetClassName()));
            Check(u.ActiveWeaponItemId==BolasId && u.player.ReadyWeapon!=null,"new bolas persist through native weapon raise and periodic gift update");
            int size=CaelumEquipmentRules.ResolveAcquisitionSize(u,CaelumEquipmentRules.CHARACTER_DEFAULT,2);
            u.CraftingSelectionRecipe=4;u.CraftingSelectionTier=1;
            let extra=Item(u,CaelumConstants.WEAPON_TYPE_SWORD,size);
            CaelumMainM00RonnieTrial.RecordCraft(u,extra);
            Check(u.ActiveWeaponItemId==extra.ItemId && r.MainM00StarterWeaponId==StarterId,"additional personal tutorial weapon equips without replacing starter identity");
            int selected=u.ActiveWeaponItemId;
            u.GrantMagicBoxFromPalomo(false);
            let boxed=Item(u,CaelumConstants.WEAPON_TYPE_DAGGER,size);boxed.InMagicBox=true;
            CaelumMainM00RonnieTrial.RecordCraft(u,boxed);
            Check(boxed.InMagicBox && !boxed.Equipped && u.ActiveWeaponItemId==selected,"boxed output is not silently withdrawn or selected");
            let wrong=Item(u,CaelumConstants.WEAPON_TYPE_DAGGER,CaelumConstants.EQUIPMENT_SIZE_XL);
            Check(!CaelumEquipmentRules.IsSizeCompatible(wrong.EquipmentSize,u.CharacterProfile.GetSizeTier()),"fixture incompatible size is meaningful");
            CaelumMainM00RonnieTrial.RecordCraft(u,wrong);
            Check(!wrong.Equipped && u.ActiveWeaponItemId==selected,"incompatible output preserves active weapon");
            extra.Durability-=31;u.WeaponModel.Durability=extra.Durability;
            CaelumMainM00Gifts.EnsureTool(u,true);
            Check(u.ActiveWeaponItemId==selected && extra.Durability==u.WeaponModel.Durability,"gift retry preserves manually selected instance and wear");
        }
        if(Age==170)Console.Printf("CA177 EQUIPMENT_DONE");
    }
}
