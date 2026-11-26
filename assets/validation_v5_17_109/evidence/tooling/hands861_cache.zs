    void WarmCase(bool expected,int stateReads,int itemReads,String label)
    {
        int beforeState=User.CA861StateReads,beforeItem=User.CA861ItemReads;
        CaelumAppearanceHands.Invalidate(User);
        Check(CaelumAppearanceHands.HasGloves(User)==expected,"cold selector returns actual hand layers");
        Check(User.CA861StateReads-beforeState==stateReads && User.CA861ItemReads-beforeItem==itemReads,"cold lookup count matches only needed layers");
        beforeState=User.CA861StateReads;beforeItem=User.CA861ItemReads;
        int mismatches=0;double start=MSTimeF();
        for(int i=0;i<1000;i++)if(CaelumAppearanceHands.HasGloves(User)!=expected)mismatches++;
        double elapsed=MSTimeF()-start;
        Check(mismatches==0,"all1000 warm results retain actual selection");
        Check(User.CA861StateReads==beforeState && User.CA861ItemReads==beforeItem,"warm queries perform zero native inventory lookups");
        Console.Printf("CA861 WARM case=%s calls=1000 state_reads=%d item_reads=%d elapsed_ms=%.6f",label,User.CA861StateReads-beforeState,User.CA861ItemReads-beforeItem,elapsed);
    }
    void Warm()
    {
        WarmCase(false,1,0,"bare");
        int size=CaelumEquipmentRules.GetDefaultSizeForCharacterTier(User.CharacterProfile.GetSizeTier());
        let glove=CaelumClothing.Create(User,CaelumClothingData.GP,size);glove.AttachToOwner(User);User.EnsureEquipmentItemId(glove);
        Select(glove);User.EquipSelectedNativeEquipment();WarmCase(true,1,1,"clothing");
        let armor=CaelumEquipmentItem(Actor.Spawn('CaelumArmorPickup',User.Pos,NO_REPLACE));
        armor.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_ARMOR;armor.ItemType=CaelumConstants.ARMOR_TYPE_LIGHT;
        armor.ArmorSlot=CaelumConstants.ARMOR_SLOT_HANDS;armor.Tier=1;armor.EquipmentSize=size;
        armor.Durability=User.ArmorModel.GetMaximumDurabilityFor(armor.ItemType,armor.Tier,size);
        armor.UnitWeight=User.ArmorModel.GetWeightFor(armor.ArmorSlot,armor.ItemType,armor.Tier,size);
        armor.PickupDataInitialized=true;armor.AcquisitionResolved=true;armor.AttachToOwner(User);User.EnsureEquipmentItemId(armor);
        Select(armor);User.EquipSelectedNativeEquipment();WarmCase(true,0,1,"armor_over_clothing");
        Select(glove);User.UnequipSelectedNativeEquipment();WarmCase(true,0,1,"armor_only");
        Select(armor);User.UnequipSelectedNativeEquipment();WarmCase(false,1,0,"bare_after_events");
        Select(glove);User.EquipSelectedNativeEquipment();
        Check(CaelumAppearanceHands.HandLayer(User,true)==glove,"real clothing reference restored after armor removal");
        User.EquipmentMenuOpen=false;
    }
