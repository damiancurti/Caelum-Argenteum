// Native equipment operations; only fixture setup creates owned catalogue items.
class CA857WardrobeProbe : EventHandler
{
    CaelumDomingoPilotPlayer User;
    Array<CaelumEquipmentItem> Garments;
    int Checks,Failures;
    void Check(bool okay,String label)
    {Checks++;if(!okay)Failures++;Console.Printf("CA836 EDGE %s wardrobe: %s",okay?"PASS":"FAIL",label);}
    void Select(CaelumEquipmentItem item)
    {
        User.EquipmentSelectionKind=item.EquipmentKind;User.EquipmentSelectionItemId=item.ItemId;
        User.RefreshEquipmentSelectionPreview();
    }
    CaelumWardrobePilotBody Refresh()
    {
        int health=User.health,weapon=User.ActiveWeaponItemId,shield=User.EquippedShieldItemId;
        double anima=User.CurrentAnima,air=User.CurrentAir,height=User.Height,radius=User.Radius;
        User.UpdatePilotVisual();
        Check(User.health==health && User.CurrentAnima==anima && User.CurrentAir==air
            && User.Height==height && User.Radius==radius && User.ActiveWeaponItemId==weapon
            && User.EquippedShieldItemId==shield,"visual refresh preserves owner resources, collision and equipment IDs");
        return CaelumWardrobePilotBody(User.PilotBody);
    }
    int Kind(CaelumWardrobePilotBody body,int region)
    {
        if(body==null)return -999;
        if(region==CaelumConstants.ARMOR_SLOT_HEAD)return body.HeadKind;
        if(region==CaelumConstants.ARMOR_SLOT_BODY)return body.BodyKind;
        if(region==CaelumConstants.ARMOR_SLOT_HANDS)return body.HandKind;
        return body.FootKind;
    }
    void Setup()
    {
        User=CaelumDomingoPilotPlayer(players[0].mo);
        Check(User!=null,"existing opt-in native player");if(User==null)return;
        User.CharacterCreationComplete=true;User.CreationWizardOpen=false;
        User.CharacterProfile.Race=CaelumConstants.RACE_HUMAN;User.CharacterProfile.Sex=CaelumConstants.SEX_MALE;
        User.ApplyCharacterProfile();User.bInvulnerable=true;
        let session=new('CA259Session');session.Choice=4;session.Tier=1;session.Equip(User);
        let shield=CaelumEquipmentItem(Actor.Spawn('CaelumShieldPickup',User.Pos,NO_REPLACE));
        shield.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_SHIELD;shield.ItemType=CaelumConstants.SHIELD_TYPE_BUCKLER;shield.Tier=1;
        shield.EquipmentSize=User.WeaponModel.Size;
        shield.Durability=User.ShieldModel.GetMaximumDurabilityFor(shield.ItemType,shield.Tier,shield.EquipmentSize);
        shield.UnitWeight=User.ShieldModel.GetWeightFor(shield.ItemType,shield.Tier,shield.EquipmentSize);
        shield.PickupDataInitialized=true;shield.AcquisitionResolved=true;shield.AttachToOwner(User);User.EnsureEquipmentItemId(shield);
        Select(shield);User.EquipSelectedNativeEquipment();
        Check(shield.Equipped && User.ShieldModel.Equipped,"native sword/shield fixture equipped");
        for(int slot=0;slot<CaelumConstants.ARMOR_SLOT_COUNT;slot++)
        {
            let armor=User.FindNativeEquipmentItemById(User.EquippedArmorItemId[slot]);
            if(armor!=null){Select(armor);User.UnequipSelectedNativeEquipment();}
            Check(User.ArmorModel.ArmorType[slot]==CaelumConstants.ARMOR_TYPE_BASE_CLOTHING,"unsupported armor removed through native equipment operation");
        }
        User.EquipmentMenuOpen=false;User.PersistCharacterState();User.GetPersistentCharacterState(true).ProfileCommitted=true;
        Check(CaelumWardrobeVisual.Enabled(),"explicit candidate activation");
        let body=Refresh();Check(body!=null && !body.bInvisible,"actual owned candidate selected");
    }
    void Catalogue()
    {
        int ordinals[4];
        int size=CaelumEquipmentRules.GetDefaultSizeForCharacterTier(User.CharacterProfile.GetSizeTier());
        for(int type=0;type<CaelumClothingData.COUNT;type++)
        {
            int region=CaelumClothingData.Region(type),expected=ordinals[region]++;
            let previous=CaelumClothing.Equipped(User,region);
            let item=CaelumClothing.Create(User,type,size);item.AttachToOwner(User);User.EnsureEquipmentItemId(item);Garments.Push(item);
            int identity=item.ItemId;double weight=item.UnitWeight;int durability=item.Durability;
            Select(item);User.EquipSelectedNativeEquipment();
            Console.Printf("CA857 EQUIPMENT type=%d region=%d expected=%d id=%d action=%d",type,region,expected,identity,User.LastEquipmentAction);
            Check(item.Equipped && CaelumClothing.Equipped(User,region)==item,"native equipped identity is authoritative");
            Check(previous==null || !previous.Equipped,"replacement unequips the previous item");
            let body=Refresh();
            Check(Kind(body,region)==expected,"actual equipped catalogue entry selects its model");
            Check(item.Owner==User && item.ItemId==identity && item.UnitWeight==weight && item.Durability==durability,"visual selection preserves the owned object and its data");
            Check(body!=null && body.CachedPieces[region]==item && body.CacheReady,"bounded cache references the actual owned item");
            Select(item);User.UnequipSelectedNativeEquipment();body=Refresh();
            Check(!item.Equipped && CaelumClothing.Equipped(User,region)==null && Kind(body,region)==-1,"native unequip removes the visible garment");
            Select(item);User.EquipSelectedNativeEquipment();body=Refresh();
            Check(item.Equipped && item.ItemId==identity && Kind(body,region)==expected,"reequip restores the same identity and appearance");
        }
        Check(Garments.Size()==CaelumClothingData.COUNT,"all25 actual catalogue items exercised");
        let dropped=CaelumClothing.Equipped(User,CaelumConstants.ARMOR_SLOT_BODY);
        Select(dropped);CaelumInventoryService.DropSelectedNativeInventoryItem(User);
        let body=Refresh();
        Check(CaelumClothing.Equipped(User,CaelumConstants.ARMOR_SLOT_BODY)==null && Kind(body,CaelumConstants.ARMOR_SLOT_BODY)==-1,"native drop removes stale worn presentation");
        Check(dropped==null || dropped.bDestroyed || dropped.Owner!=User,"dropped object is no longer owned");
        Select(Garments[0]);User.EquipSelectedNativeEquipment();body=Refresh();
        Check(body!=null && body.BodyKind==0 && Garments[0].Equipped,"another retained garment can be equipped after drop");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!='ca857check')return;
        Setup();if(User==null)return;Catalogue();
        Console.Printf("CA836 EDGE_RESULT checks=%d failures=%d result=%s",Checks,Failures,Failures==0?"PASS":"FAIL");
    }
}
