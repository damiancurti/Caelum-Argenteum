    void Ownership()
    {
        let item=CaelumClothing.Equipped(User,CaelumConstants.ARMOR_SLOT_BODY);
        int identity=item.ItemId;double weight=item.UnitWeight;int durability=item.Durability;
        User.GrantMagicBoxFromPalomo(false);
        Check(User.MagicBoxOwned,"private fixture owns native Magic Box");
        Select(item);User.UnequipSelectedNativeEquipment();
        User.ToggleSelectedMagicBoxNative();let body=Refresh();
        Check(item.InMagicBox && !item.Equipped && body!=null && body.BodyKind==-1,"boxed garment is not rendered as worn");
        User.ToggleSelectedMagicBoxNative();Select(item);User.EquipSelectedNativeEquipment();body=Refresh();
        Check(!item.InMagicBox && item.Equipped && body!=null && body.BodyKind==0,"native retrieval and reequip restores appearance");
        let chest=CaelumStashChest(Actor.Spawn('CaelumStashChest',User.Pos+(64,0,0),NO_REPLACE));
        chest.EnsureStorage();CaelumContainerSession.Open(User,chest);
        Check(!CaelumInventoryService.TransferContainerItem(User,chest,item,1,true),"native transfer refuses a worn garment");
        Select(item);User.UnequipSelectedNativeEquipment();User.EquipmentMenuOpen=false;
        CaelumContainerSession.Open(User,chest);
        bool moved=CaelumInventoryService.TransferContainerItem(User,chest,item,1,true);body=Refresh();
        Check(moved && item.Owner==chest && body!=null && body.BodyKind==-1,"native chest deposit removes owner presentation");
        bool retrieved=CaelumInventoryService.TransferContainerItem(User,chest,item,1,false);
        Check(retrieved && item.Owner==User && item.ItemId==identity,"native chest retrieval retains item identity");
        CaelumContainerSession.Get(User).Close();Select(item);User.EquipSelectedNativeEquipment();body=Refresh();
        Check(body!=null && body.BodyKind==0 && body.CachedPieces[CaelumConstants.ARMOR_SLOT_BODY]==item,"retrieved actual item rebinds");
        // Diagnostic bypass: test stale cached ownership independently of events.
        User.RemoveInventory(item);item.AttachToOwner(chest);body=Refresh();
        Check(body!=null && body.BodyKind==-1,"owner guard rejects stale cached reference without event");
        chest.RemoveInventory(item);item.AttachToOwner(User);User.OnNativeInventoryChanged();body=Refresh();
        Check(body!=null && body.BodyKind==0 && item.Equipped,"native change event restores same-ID binding");
        Check(item.ItemId==identity && item.UnitWeight==weight && item.Durability==durability,"ownership roundtrip preserves actual item data");
        User.EquipmentMenuOpen=false;
    }
