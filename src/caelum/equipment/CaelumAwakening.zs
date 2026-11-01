// #442: la asociación pertenece a la pieza nativa, no a su receta ni al cursor.
class CaelumAwakening : Object play
{
    const REVISION=1;

    static clearscope bool Eligible(CaelumEquipmentItem item)
    {return item!=null && (item.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_WEAPON
        || item.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_ARMOR
        || item.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_SHIELD);}

    static void Ensure(CaelumEquipmentItem item)
    {
        if(item==null || item.AwakeningRevision>=REVISION)return;
        item.AwakeningRevision=REVISION;item.AwakeningCard=-1;
        item.AwakeningOwner=null;item.AwakeningHalfWear=0;
    }

    static clearscope int Card(CaelumEquipmentItem item)
    {
        return item!=null && item.AwakeningRevision>=REVISION
            && item.AwakeningOwner!=null && item.Owner==item.AwakeningOwner
            && item.AwakeningCard>=0 && item.AwakeningCard<CaelumConstants.TAROT_CARD_COUNT
            ? item.AwakeningCard : -1;
    }

    static clearscope double Factor(CaelumEquipmentItem item)
    {
        let image=CaelumMoonEquipment(item);
        return Card(item)>=0 || (image!=null && image.Awakened && image.Illusion!=null)
            ?CaelumAwakeningData.POWER:1;
    }

    static clearscope double ActiveFactor(CaelumEquipmentItem item,int kind,int itemType,int tier,int size,int slot=-1)
    {
        return item!=null && item.Equipped && !item.InMagicBox && item.EquipmentKind==kind
            && item.ItemType==itemType && item.Tier==tier && item.EquipmentSize==size
            && (slot<0 || item.ArmorSlot==slot)?Factor(item):1;
    }

    // La pérdida nativa es entera. Conservar la mitad pendiente evita regalar
    // desgaste al quitar/reponer una esencia, guardar o transferir la pieza.
    static int Wear(CaelumEquipmentItem item,int loss)
    {
        if(item==null || loss<=0)return Max(0,loss);
        Ensure(item);
        if(Factor(item)<=1)return loss;
        int halves=loss+item.AwakeningHalfWear;
        item.AwakeningHalfWear=halves%CaelumAwakeningData.WEAR_DIVISOR;
        return halves/CaelumAwakeningData.WEAR_DIVISOR;
    }

    static void Clear(CaelumEquipmentItem item)
    {
        Ensure(item);if(item==null)return;
        item.AwakeningCard=-1;item.AwakeningOwner=null;
    }

    static clearscope CaelumEquipmentItem Bound(CaelumPlayer user,int card)
    {
        if(user==null || card<0 || card>=CaelumConstants.TAROT_CARD_COUNT)return null;
        // Sólo el inventario del solicitante, durante una acción de interfaz.
        for(Inventory cursor=user.Inv;cursor!=null;cursor=cursor.Inv)
        {
            let item=CaelumEquipmentItem(cursor);
            if(Card(item)==card)return item;
        }
        return null;
    }

    static bool Associate(CaelumPlayer user,int itemId,int card)
    {
        if(!CaelumTarotService.ValidUser(user) || CaelumBolas.Restrained(user))return false;
        let item=user.FindNativeEquipmentItemById(itemId);
        if(!Eligible(item) || item.Owner!=user)return false;
        if(user.IsEquipmentItemCraftingLocked(itemId))return false;
        if(user.HasActiveConversation() || user.CraftingTaskActive || user.StaffCastPending
            || user.CombatChannelModeActive || user.ForcedSleepTics>0
            || CaelumRestState.IsActive(user) || CaelumTimeSkipState.IsOpen(user))return false;
        let record=user.GetPersistentCharacterState(false);
        if(record==null || card < -1 || card>=CaelumConstants.TAROT_CARD_COUNT)return false;
        if(card>=0 && (!record.HasTarotCard(card) || CaelumTarotService.IsSelected(record,card)
            || CaelumTarotService.IsActive(record,card)
            || (record.UnifiedTarotTics>0 && card==CaelumUnifiedTarot.WORLD_CARD)))
        {CaelumTarotService.Feedback(user,"CA_AWAKEN_UNAVAILABLE");return false;}
        let other=Bound(user,card);
        if(other!=null && other!=item)
        {CaelumTarotService.Feedback(user,"CA_AWAKEN_BOUND");return false;}
        Ensure(item);
        item.AwakeningCard=card;item.AwakeningOwner=card>=0?user:null;
        user.RepairActiveEquipmentItemReferences();user.ApplyCharacterProfile();
        user.RefreshEquipmentSelectionPreview();user.RefreshFormalInventorySnapshot();
        user.RefreshSocialJournalSnapshot();user.PersistCharacterState();
        CaelumTarotService.Feedback(user,card>=0?"CA_AWAKEN_DONE":"CA_AWAKEN_REMOVED");
        return true;
    }
}

// Menú propio del inventario. Cada confirmación revalida identidad y propiedad.
class CaelumAwakeningMenu : Inventory
{
    bool Opened;
    int ItemId,SelectedCard;
    int ItemKind,ItemType,ItemSlot,ItemTier,ItemSize,ItemEssence;

    static clearscope CaelumAwakeningMenu Read(CaelumPlayer user)
    {return user==null?null:CaelumAwakeningMenu(user.FindInventory('CaelumAwakeningMenu'));}

    static void Open(CaelumPlayer user)
    {
        if(!CaelumTarotService.ValidUser(user))return;
        let item=CaelumEquipmentItem(user.GetFormalInventoryEntryAt(user.FormalInventorySelectionIndex));
        if(!CaelumAwakening.Eligible(item) || item.Owner!=user)
        {CaelumTarotService.Feedback(user,"CA_AWAKEN_EQUIPMENT_ONLY");return;}
        let menuState=Read(user);
        if(menuState==null){menuState=CaelumAwakeningMenu(Actor.Spawn('CaelumAwakeningMenu'));menuState.AttachToOwner(user);}
        menuState.ItemId=user.EnsureEquipmentItemId(item);menuState.SelectedCard=CaelumAwakening.Card(item);menuState.Opened=true;
        menuState.ItemKind=item.EquipmentKind;menuState.ItemType=item.ItemType;menuState.ItemSlot=item.ArmorSlot;
        menuState.ItemTier=item.Tier;menuState.ItemSize=item.EquipmentSize;menuState.ItemEssence=item.EssenceType;
    }

    static void HandleCommand(CaelumPlayer user,int commandId)
    {
        if(!CaelumTarotService.ValidUser(user))return;
        let menuState=Read(user);if(menuState==null || !menuState.Opened)return;
        if(commandId==0){menuState.Opened=false;return;}
        if(commandId==1)
        {if(CaelumAwakening.Associate(user,menuState.ItemId,menuState.SelectedCard))menuState.Opened=false;return;}
        if(commandId!=2 && commandId!=3)return;
        let record=user.GetPersistentCharacterState(false);if(record==null)return;
        int next=menuState.SelectedCard;
        for(int tries=0;tries<=CaelumConstants.TAROT_CARD_COUNT;tries++)
        {
            next+=commandId==2?1:-1;
            if(next>=CaelumConstants.TAROT_CARD_COUNT)next=-1;
            if(next < -1)next=CaelumConstants.TAROT_CARD_COUNT-1;
            if(next==-1 || record.HasTarotCard(next)){menuState.SelectedCard=next;break;}
        }
    }

    override void Tick()
    {
        Super.Tick();if(Opened && (Owner==null || Owner.health<=0))Opened=false;
    }
    override void PreTravelled(){Opened=false;Super.PreTravelled();}
    Default {Inventory.MaxAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE}
    States {Spawn:TNT1 A -1;Stop;}
}
