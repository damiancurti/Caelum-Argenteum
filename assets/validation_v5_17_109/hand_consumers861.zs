// Isolated ownership and presentation consumers; no production rule changes.
class CA861ConsumerProbe : CA861HandProbe
{
    int OriginalEditSerial;
    CaelumEquipmentItem MakeGlove(int kind)
    {
        int size=CaelumEquipmentRules.GetDefaultSizeForCharacterTier(User.CharacterProfile.GetSizeTier());
        let item=CaelumClothing.Create(User,kind,size);item.AttachToOwner(User);User.EnsureEquipmentItemId(item);
        Select(item);User.EquipSelectedNativeEquipment();return item;
    }
    void Consumers()
    {
        let first=CaelumClothing.Equipped(User,CaelumConstants.ARMOR_SLOT_HANDS);
        let second=MakeGlove(CaelumClothingData.GW);
        Check(first!=null && !first.Equipped && second.Equipped && CaelumAppearanceHands.HandLayer(User,true)==second,"native replacement binds the new owned glove");
        Select(second);CaelumInventoryService.DropSelectedNativeInventoryItem(User);
        Check(second==null || second.bDestroyed || second.Owner!=User,"native drop releases the actual worn object");
        Check(!CaelumAppearanceHands.HasGloves(User),"native drop removes glove presentation");
        Select(first);User.EquipSelectedNativeEquipment();
        Check(CaelumAppearanceHands.HandLayer(User,true)==first,"retained owned glove can be equipped after drop");

        // A same-ID replacement requires the existing native inventory event.
        int identity=first.ItemId,kind=first.ItemType;
        User.RemoveInventory(first);first.Destroy();
        let replacement=CaelumClothing.Create(User,kind,CaelumEquipmentRules.GetDefaultSizeForCharacterTier(User.CharacterProfile.GetSizeTier()));
        replacement.ItemId=identity;replacement.Equipped=true;replacement.AttachToOwner(User);
        User.OnNativeInventoryChanged();
        Check(CaelumAppearanceHands.HandLayer(User,true)==replacement,"inventory event rebinds a replacement object with the same saved ID");
        let record=User.GetPersistentCharacterState(false);
        let chest=CaelumStashChest(Actor.Spawn('CaelumStashChest',User.Pos+(64,0,0),NO_REPLACE));chest.EnsureStorage();
        User.RemoveInventory(record);record.AttachToOwner(chest);
        Check(!CaelumAppearanceHands.HasGloves(User),"cached foreign persistent record cannot supply a hand ID");
        chest.RemoveInventory(record);record.AttachToOwner(User);User.OnNativeInventoryChanged();
        Check(CaelumAppearanceHands.HandLayer(User,true)==replacement,"restored owned record resolves its actual glove");

        let armor=CaelumEquipmentItem(Actor.Spawn('CaelumArmorPickup',User.Pos,NO_REPLACE));
        armor.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_ARMOR;armor.ItemType=CaelumConstants.ARMOR_TYPE_LIGHT;
        armor.ArmorSlot=CaelumConstants.ARMOR_SLOT_HANDS;armor.Tier=1;armor.EquipmentSize=replacement.EquipmentSize;
        armor.Durability=User.ArmorModel.GetMaximumDurabilityFor(armor.ItemType,armor.Tier,armor.EquipmentSize);
        armor.UnitWeight=User.ArmorModel.GetWeightFor(armor.ArmorSlot,armor.ItemType,armor.Tier,armor.EquipmentSize);
        armor.PickupDataInitialized=true;armor.AcquisitionResolved=true;armor.AttachToOwner(User);User.EnsureEquipmentItemId(armor);
        Select(armor);User.EquipSelectedNativeEquipment();
        Check(CaelumAppearanceHands.HandLayer(User,false)==armor && CaelumAppearanceHands.HandLayer(User,true)==replacement,"actual armor and clothing coexist as separate owned layers");
        armor.Durability=0;User.ArmorModel.Durability[CaelumConstants.ARMOR_SLOT_HANDS]=0;
        Check(CaelumAppearanceHands.HasGloves(User),"broken but worn outer armor remains visible over clothing");
        Select(armor);User.UnequipSelectedNativeEquipment();
        Check(CaelumAppearanceHands.HandLayer(User,false)==null && CaelumAppearanceHands.HandLayer(User,true)==replacement,"removing outer armor retains actual clothing gloves");
        User.EquipmentMenuOpen=false;

        Check(CaelumTarotMoon.Start(User,TICRATE),"native Moon initialization creates local fixture clones");
        let binding=CaelumTarotMoon.View(User);
        for(int i=0;i<2;i++)Check(binding!=null && binding.Bodies[i]!=null && binding.Bodies[i].Gloves,"both native Moon clones snapshot the clothing glove selection");
        Select(replacement);User.UnequipSelectedNativeEquipment();
        Check(!CaelumAppearanceHands.HasGloves(User),"caster becomes bare through native unequip");
        for(int i=0;i<2;i++)Check(binding!=null && binding.Bodies[i]!=null && binding.Bodies[i].Gloves,"existing clone retains its original private glove snapshot");
        if(binding!=null)binding.End();
        Check(CaelumTarotMoon.Start(User,TICRATE),"bare native Moon initialization succeeds");binding=CaelumTarotMoon.View(User);
        for(int i=0;i<2;i++)Check(binding!=null && binding.Bodies[i]!=null && !binding.Bodies[i].Gloves,"new clone snapshots actual bare hands");
        if(binding!=null)binding.End();
        Select(replacement);User.EquipSelectedNativeEquipment();User.EquipmentMenuOpen=false;
        CaelumAppearance.Apply(User);OriginalEditSerial=User.CharacterProfile.AppearanceEditSerial;
    }
    override void InterfaceProcess(ConsoleEvent e)
    {
        if(e.Name=='ca861openui')Menu.SetMenu('CaelumAppearanceMenu');
        if(e.Name=='ca861inspectui')
        {
            let menu=CaelumAppearanceMenu(Menu.GetCurrentMenu());
            bool okay=menu!=null && menu.Preview!=null && menu.Preview.Gloved==(e.Args[0]!=0)
                && menu.EditSubject==players[consoleplayer].mo && menu.Preview.Sex==SEX861;
            EventHandler.SendNetworkEvent('ca861previewresult',okay?1:0,e.Args[0]);
        }
        if(e.Name=='ca861closeui' && Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        Super.NetworkProcess(e);
        if(e.Name=='ca861consumers')Consumers();
        if(e.Name=='ca861open')EventHandler.SendInterfaceEvent(0,'ca861openui');
        if(e.Name=='ca861inspect')EventHandler.SendInterfaceEvent(0,'ca861inspectui',e.Args[0]);
        if(e.Name=='ca861previewresult')Check(e.Args[0]!=0,"actual appearance menu preview matches worn glove and sex");
        if(e.Name=='ca861bare')
        {
            let glove=CaelumClothing.Equipped(User,CaelumConstants.ARMOR_SLOT_HANDS);Select(glove);User.UnequipSelectedNativeEquipment();
            User.EquipmentMenuOpen=false;CaelumAppearance.Apply(User);
        }
        if(e.Name=='ca861close')
        {
            EventHandler.SendInterfaceEvent(0,'ca861closeui');
            Check(User.CharacterProfile.AppearanceEditSerial==OriginalEditSerial,"preview inspection does not commit appearance changes");
        }
    }
}
