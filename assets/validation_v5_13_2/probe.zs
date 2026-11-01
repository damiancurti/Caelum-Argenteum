class CA442Ledger : Inventory
{
    int Phase,WeaponId,ArmorId,ShieldId,At;
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}

class CA442Probe : StaticEventHandler
{
    bool Entered,Reloaded;
    ui bool Saved,Opened,Chosen,Confirmed;
    ui int Frames;
    void Check(bool ok,String detail){Console.Printf("CA442 %s %s",ok?"PASS":"FAIL",detail);}

    override void RenderOverlay(RenderEvent e)
    {
        if(consoleplayer!=0)return;
        let user=CaelumPlayer(players[0].mo);
        let ledger=user!=null?CA442Ledger(user.FindInventory('CA442Ledger')):null;
        if(ledger==null)return;
        if(ledger.Phase==5 && !Saved)
        {Saved=true;SavegameManager.GetManager().DoSave(0,"CA442 awakened equipment and half wear");}
        if(ledger.Phase!=1)return;
        let overlay=CaelumJournalOverlay(EventHandler.Find('CaelumJournalOverlay'));
        if(overlay==null)return;
        if(!Opened)
        {
            Opened=true;overlay.SetJournalOpen(true);
            let page=CVar.GetCVar("ca_journal_page",players[0]);if(page!=null)page.SetInt(0);
            EventHandler.SendNetworkEvent("ca_awaken_open");
        }
        let awakening=CaelumAwakeningMenu.Read(user);
        if(awakening==null || !awakening.Opened)return;
        let nativeMenu=CaelumLiveMenu(Menu.GetCurrentMenu());
        if(nativeMenu==null || nativeMenu.Context!=CaelumLiveMenu.CTX_AWAKENING)return;
        Frames++;
        if(Frames==20 && !Chosen){Chosen=true;nativeMenu.Stroke(InputEvent.Key_RightArrow);}
        if(Frames==360 && !Confirmed){Confirmed=true;nativeMenu.Stroke(InputEvent.Key_Enter);}
    }

    CaelumEquipmentItem Make(CaelumPlayer user,int kind,int type,int slot=-1)
    {
        Class<Actor> pickup=kind==CaelumConstants.EQUIPMENT_KIND_WEAPON?'CaelumWeaponPickup'
            :kind==CaelumConstants.EQUIPMENT_KIND_ARMOR?'CaelumArmorPickup':'CaelumShieldPickup';
        let item=CaelumEquipmentItem(Actor.Spawn(pickup));
        item.EquipmentKind=kind;item.ItemType=type;item.ArmorSlot=slot;item.Tier=1;
        item.EquipmentSize=CaelumConstants.EQUIPMENT_SIZE_M;item.Durability=100;
        item.UnitWeight=1;item.WeaponDurabilityRevision=CaelumAttackRules.DURABILITY_REVISION;item.PickupDataInitialized=true;item.AcquisitionResolved=true;
        item.SupportMigrationRevision=CaelumSupportImplementData.MIGRATION_REVISION;
        item.AttachToOwner(user);user.EnsureEquipmentItemId(item);return item;
    }

    override void WorldTick()
    {
        if(level.time<105)return;
        for(int i=0;i<2;i++)if(!CaelumWorldClockTicker.Ready(CaelumPlayer(players[i].mo)))return;
        let user=CaelumPlayer(players[0].mo);let other=CaelumPlayer(players[1].mo);
        let record=user.GetPersistentCharacterState(false);
        let ledger=CA442Ledger(user.FindInventory('CA442Ledger'));
        if(!Entered){Reloaded=ledger!=null;Entered=true;}
        if(Reloaded && ledger!=null && ledger.Phase==5)
        {
            let weapon=user.FindNativeEquipmentItemById(ledger.WeaponId);
            Check(CaelumAwakening.Card(weapon)==1,"load restores item association and owner identity");
            Check(weapon.AwakeningHalfWear==1,"load preserves fractional wear debt");
            Check(CaelumAwakening.Wear(weapon,1)==1 && weapon.AwakeningHalfWear==0,"second half becomes one durability loss");
            Check(CaelumAwakening.Bound(user,1)==weapon,"load finds exact bound item");
            Check(record.HasTarotCard(1),"load preserves essence ownership");
            user.RemoveInventory(weapon);weapon.AttachToOwner(other);
            Check(CaelumAwakening.Card(weapon)<0 && CaelumAwakening.Bound(user,1)==null,"transfer clears association immediately");
            Check(record.HasTarotCard(1) && !other.GetPersistentCharacterState(false).HasTarotCard(1),"transfer does not transfer essence");
            Check(!CaelumAwakening.Associate(user,ledger.WeaponId,1),"former owner cannot mutate transferred piece");
            ledger.Phase=6;Console.Printf("CA442 RESULT reload");return;
        }
        if(ledger==null)
        {
            user.GiveInventoryType('CA442Ledger');ledger=CA442Ledger(user.FindInventory('CA442Ledger'));
            user.SetOrigin((-128,0,0),false);other.SetOrigin((-128,-64,0),false);
            user.CurrentHunger=100;user.CurrentThirst=100;user.CurrentSleep=100;
            record.TarotEffectTics=0;record.TarotCooldownTics=0;
            for(int i=0;i<78;i++){record.TarotOwned[i]=false;record.TarotSelected[i]=false;record.TarotActive[i]=false;}
            record.TarotOwned[1]=true;record.TarotOwned[22]=true;record.TarotOwned[23]=true;
            other.GetPersistentCharacterState(false).TarotOwned[1]=false;
            let weapon=Make(user,CaelumConstants.EQUIPMENT_KIND_WEAPON,CaelumConstants.WEAPON_TYPE_SWORD);
            let armor=Make(user,CaelumConstants.EQUIPMENT_KIND_ARMOR,CaelumConstants.ARMOR_TYPE_HEAVY,1);
            let shield=Make(user,CaelumConstants.EQUIPMENT_KIND_SHIELD,CaelumConstants.SHIELD_TYPE_BUCKLER);
            ledger.WeaponId=weapon.ItemId;ledger.ArmorId=armor.ItemId;ledger.ShieldId=shield.ItemId;
            weapon.ContaminationState=new('CaelumContaminationState');
            Check(weapon.AwakeningRevision==1 && CaelumAwakening.Card(weapon)<0,"new item starts unbound");
            weapon.AwakeningRevision=0;weapon.AwakeningCard=0;CaelumAwakening.Ensure(weapon);
            Check(CaelumAwakening.Card(weapon)<0,"legacy zero does not bind Fool");
            Check(!CaelumAwakening.Associate(other,weapon.ItemId,1),"foreign owner rejected");
            Check(!CaelumAwakening.Associate(user,weapon.ItemId,77),"unacquired essence rejected");
            record.TarotSelected[1]=true;
            Check(!CaelumAwakening.Associate(user,weapon.ItemId,1),"equipped essence rejected");record.TarotSelected[1]=false;
            record.TarotActive[1]=true;record.TarotEffectTics=35;
            Check(!CaelumAwakening.Associate(user,weapon.ItemId,1),"active essence rejected");record.TarotEffectTics=0;record.TarotActive[1]=false;
            user.RefreshFormalInventorySnapshot();
            for(int i=0;i<user.FormalInventoryEntryCount;i++)if(user.GetFormalInventoryEntryAt(i)==weapon)user.FormalInventorySelectionIndex=i;
            ledger.Phase=1;ledger.At=level.time;
        }
        if(ledger.Phase==1 && level.time-ledger.At>100)
        {
            let weapon=user.FindNativeEquipmentItemById(ledger.WeaponId);
            if(CaelumAwakening.Card(weapon)!=1)return;
            Check(true,"rendered inventory menu and native confirmation bind chosen essence");
            Check(weapon.Durability==100 && weapon.ContaminationState!=null,"association preserves wear and contamination identity");
            Check(CaelumAwakening.Associate(user,weapon.ItemId,1),"repeated confirmation is idempotent");
            Check(!CaelumAwakening.Associate(user,ledger.ArmorId,1),"one essence cannot bind two items");
            Check(CaelumAwakening.Associate(user,ledger.ArmorId,22),"armor accepts acquired Minor");
            Check(!CaelumTarotService.Select(user,22),"bound essence cannot be equipped");
            Check(CaelumAwakening.Associate(user,ledger.ShieldId,23),"shield accepts separate essence");
            let armor=user.FindNativeEquipmentItemById(ledger.ArmorId);
            let shield=user.FindNativeEquipmentItemById(ledger.ShieldId);
            weapon.Equipped=true;user.ActiveWeaponItemId=weapon.ItemId;
            user.WeaponModel.WeaponType=weapon.ItemType;user.WeaponModel.Tier=1;user.WeaponModel.Size=weapon.EquipmentSize;
            user.WeaponModel.Durability=weapon.Durability;user.WeaponModel.Equipped=true;
            armor.Equipped=true;user.EquippedArmorItemId[1]=armor.ItemId;
            user.ArmorModel.ArmorType[1]=armor.ItemType;user.ArmorModel.Tier[1]=1;user.ArmorModel.Size[1]=armor.EquipmentSize;user.ArmorModel.Durability[1]=armor.Durability;
            shield.Equipped=true;user.EquippedShieldItemId=shield.ItemId;user.ShieldModel.Equipped=true;
            user.ShieldModel.ShieldType=shield.ItemType;user.ShieldModel.Tier=1;user.ShieldModel.Size=shield.EquipmentSize;user.ShieldModel.Durability=shield.Durability;
            user.RepairActiveEquipmentItemReferences();
            Check(abs(user.WeaponModel.GetDamage()/user.WeaponModel.GetDamageFor(weapon.ItemType,1)-1.25)<0.00001,"weapon model applies 25 percent damage");
            Check(abs(user.ArmorModel.GetDefense(1)-43.75)<0.00001,"armor defense increases without rounding");
            Check(abs(user.ShieldModel.GetDefense(0)-62.5)<0.00001,"shield defense preserves half point");
            user.LastShieldDurabilityLoss=2;user.CommitRealShieldDurability();
            Check(user.ShieldModel.Durability==99,"native shield wear is halved");
            user.LastIncomingArmorSlot=1;user.LastArmorDurabilityLoss=2;user.CommitRealArmorDurability();
            Check(user.ArmorModel.Durability[1]==99,"native armor wear is halved");
            user.SyncActiveModelsToNativeInventory();
            shield.Equipped=false;user.ShieldModel.Equipped=false;
            let tossed=CaelumEquipmentItem(shield.CreateTossable(1));
            Check(tossed!=null && CaelumAwakening.Card(tossed)<0 && CaelumAwakening.Bound(user,23)==null,"native toss clears both association and occupancy");
            Check(tossed!=null && tossed.Durability==99 && record.HasTarotCard(23),"toss preserves equipment wear and personal essence");
            Check(CaelumAwakening.Wear(weapon,1)==0 && weapon.AwakeningHalfWear==1,"first wear half retained");
            Check(CaelumAwakening.Associate(user,weapon.ItemId,-1) && weapon.AwakeningHalfWear==1,"removal preserves wear debt");
            Check(user.WeaponModel.GetDamage()==user.WeaponModel.GetDamageFor(weapon.ItemType,1),"removal restores damage immediately");
            Check(CaelumAwakening.Associate(user,weapon.ItemId,1),"reassociation preserves identity");
            Check(CaelumAwakening.Wear(weapon,1)==1 && weapon.AwakeningHalfWear==0,"reassociation cannot evade fractional wear");
            user.ApplyFixedWeaponDurabilityLoss(2,weapon.ItemType,1,weapon.EquipmentSize);
            Check(weapon.Durability==99,"fixed native wear is halved");
            user.ApplyWeaponDurabilityFromSuccessfulDamage(4000,weapon.ItemType,1,weapon.EquipmentSize);
            Check(weapon.Durability==97,"damage native wear is halved");
            weapon.InMagicBox=true;
            Check(CaelumAwakening.Card(weapon)==1,"internal Box storage retains association");weapon.InMagicBox=false;
            Check(CaelumAwakening.Wear(weapon,1)==0,"save retains next half wear");
            user.PersistCharacterState();ledger.Phase=5;Console.Printf("CA442 RESULT capture");
        }
    }
}
