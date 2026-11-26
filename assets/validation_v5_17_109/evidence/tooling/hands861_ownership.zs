    void Expect(bool wanted,String label)
    {
        int health=User.health,weapon=User.ActiveWeaponItemId,shield=User.EquippedShieldItemId;
        double anima=User.CurrentAnima,air=User.CurrentAir,height=User.Height,radius=User.Radius;
        Check(CaelumAppearanceHands.HasGloves(User)==wanted,label);
        Check(User.health==health && User.CurrentAnima==anima && User.CurrentAir==air
            && User.Height==height && User.Radius==radius && User.ActiveWeaponItemId==weapon
            && User.EquippedShieldItemId==shield,"hand selection preserves native owner state");
    }
    void Profiles(bool gloved)
    {
        let old=new('CaelumCharacterProfile');old.CopyFrom(User.CharacterProfile);
        int races[]={CaelumConstants.RACE_HUMAN,CaelumConstants.RACE_GOBLIN,CaelumConstants.RACE_CAELITH,CaelumConstants.RACE_BEAST_MAN};
        for(int r=0;r<4;r++)for(int form=0;form<(r==3?4:1);form++)for(int sex=0;sex<2;sex++)for(int tone=0;tone<3;tone++)
        {
            User.CharacterProfile.Race=races[r];User.CharacterProfile.BeastForm=form;
            User.CharacterProfile.Sex=sex;User.CharacterProfile.SkinTone=tone;
            int family=r<2?0:r==2?1:2+form;
            int expected=gloved?(sex==1?36:-1):sex*18+family*3+tone;
            Check(CaelumAppearanceHands.Variant(User)==expected,"all42 existing profile choices keep the expected bare/shared glove variant");
        }
        User.CharacterProfile.CopyFrom(old);
    }
    void Ownership()
    {
        Profiles(false);
        int size=CaelumEquipmentRules.GetDefaultSizeForCharacterTier(User.CharacterProfile.GetSizeTier());
        int types[]={CaelumClothingData.GF,CaelumClothingData.GC,CaelumClothingData.GW,CaelumClothingData.GP};
        User.GrantMagicBoxFromPalomo(false);
        let chest=CaelumStashChest(Actor.Spawn('CaelumStashChest',User.Pos+(64,0,0),NO_REPLACE));chest.EnsureStorage();
        for(int k=0;k<4;k++)
        {
            let item=CaelumClothing.Create(User,types[k],size);item.AttachToOwner(User);User.EnsureEquipmentItemId(item);
            int identity=item.ItemId,durability=item.Durability;double weight=item.UnitWeight;
            Select(item);User.EquipSelectedNativeEquipment();Expect(true,"native clothing equip supplies gloves");Profiles(true);
            Check(User.AppearanceHandLayers[1]==item,"cached selection references the actual owned glove");
            item.Durability=0;Expect(true,"broken but worn clothing gloves remain visible");item.Durability=durability;
            item.Equipped=false;Expect(false,"every-use guard rejects unequipped cached object");item.Equipped=true;
            item.InMagicBox=true;Expect(false,"every-use guard rejects boxed cached object");item.InMagicBox=false;
            item.ItemId=identity+1;Expect(false,"every-use guard rejects changed object identity");item.ItemId=identity;
            item.ArmorSlot=CaelumConstants.ARMOR_SLOT_BODY;Expect(false,"every-use guard rejects wrong region");item.ArmorSlot=CaelumConstants.ARMOR_SLOT_HANDS;
            item.ItemType=CaelumClothingData.F;Expect(false,"body garment cannot impersonate a hand glove");item.ItemType=types[k];
            item.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_ARMOR;Expect(false,"wrong kind cannot impersonate clothing");item.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_CLOTHING;
            User.RemoveInventory(item);item.AttachToOwner(chest);Expect(false,"foreign owner is rejected without an inventory event");
            chest.RemoveInventory(item);item.AttachToOwner(User);User.OnNativeInventoryChanged();Expect(true,"native event restores the same-ID owned object");
            Select(item);User.UnequipSelectedNativeEquipment();User.ToggleSelectedMagicBoxNative();
            Check(item.InMagicBox && !item.Equipped,"native Box operation completed");Expect(false,"native boxed item supplies no gloves");
            User.ToggleSelectedMagicBoxNative();Select(item);User.EquipSelectedNativeEquipment();Expect(true,"native Box retrieval and re-equip restores gloves");
            CaelumContainerSession.Open(User,chest);
            Check(!CaelumInventoryService.TransferContainerItem(User,chest,item,1,true),"native chest rejects a worn glove");
            Select(item);User.UnequipSelectedNativeEquipment();User.EquipmentMenuOpen=false;CaelumContainerSession.Open(User,chest);
            Check(CaelumInventoryService.TransferContainerItem(User,chest,item,1,true),"native chest accepts unequipped glove");Expect(false,"stored glove supplies no hand layer");
            Check(CaelumInventoryService.TransferContainerItem(User,chest,item,1,false),"native chest returns the same glove");
            CaelumContainerSession.Get(User).Close();Select(item);User.EquipSelectedNativeEquipment();Expect(true,"retrieved glove rebinds");
            Check(item.ItemId==identity && item.UnitWeight==weight && item.Durability==durability,"native transfers preserve glove identity and data");
            let record=User.GetPersistentCharacterState(false);int before=record.EquippedClothingItemId[CaelumConstants.ARMOR_SLOT_HANDS];
            record.EquippedClothingItemId[CaelumConstants.ARMOR_SLOT_HANDS]=0;Expect(false,"ID change is observed without an inventory event");
            record.EquippedClothingItemId[CaelumConstants.ARMOR_SLOT_HANDS]=before;Expect(true,"restored ID resolves its real object");
            CaelumAppearance.Apply(User);Check(User.AppearanceHasGloves,"shared world/preview glove flag follows actual clothing");
            item.Destroy();Expect(false,"destroyed cached object is rejected");User.OnNativeInventoryChanged();
        }
        Profiles(false);User.EquipmentMenuOpen=false;User.PersistCharacterState();
    }
