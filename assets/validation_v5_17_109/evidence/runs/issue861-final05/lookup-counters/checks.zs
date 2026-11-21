// Escenario aislado: equipa objetos reales; no forma parte del PK3 del juego.
class CA259Session : EventHandler
{
    CaelumEquipmentItem TestItem;
    int Choice,Tier,LucidityChoice;
    bool Pinned,Manual;
    double FixedLucidity;
    override void UiTick()
    { if(!Pinned && Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close(); }
    int Kind()
    {
        static const int kinds[]={1,18,19,17,0,2,14,15,16};
        return kinds[Clamp(Choice,0,8)];
    }
    void Equip(CaelumPlayer user)
    {
        if(TestItem!=null && TestItem.Owner==user)
        {
            user.EquipmentSelectionItemId=TestItem.ItemId;
            user.RefreshEquipmentSelectionPreview();user.UnequipSelectedNativeEquipment();
            TestItem.Destroy();TestItem=null;
        }
        let model=new("CaelumWeaponModel");model.InitializeDefaults();
        TestItem=CaelumEquipmentItem(Actor.Spawn("CaelumWeaponPickup",user.Pos,NO_REPLACE));
        TestItem.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;TestItem.ItemType=Kind();
        TestItem.Tier=Tier;TestItem.EquipmentSize=CaelumEquipmentRules.GetDefaultSizeForCharacterTier(user.CharacterProfile.GetSizeTier());
        TestItem.EssenceType=CaelumConstants.ESSENCE_FIRE;
        TestItem.Durability=model.GetMaximumDurabilityFor(Kind(),Tier,TestItem.EquipmentSize);
        TestItem.UnitWeight=model.GetWeightFor(Kind(),Tier,TestItem.EquipmentSize);
        TestItem.PickupDataInitialized=true;TestItem.AcquisitionResolved=true;
        TestItem.WeaponDurabilityRevision=CaelumAttackRules.DURABILITY_REVISION;
        TestItem.AttachToOwner(user);user.EnsureEquipmentItemId(TestItem);
        user.EquipmentSelectionKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;
        user.EquipmentSelectionItemId=TestItem.ItemId;
        user.EquipmentSelectionWeaponType=Kind();user.EquipmentSelectionTier=Tier;
        user.EquipmentSelectionSize=TestItem.EquipmentSize;
        user.EquipmentSelectionWeaponEssenceType=CaelumConstants.ESSENCE_FIRE;
        user.RefreshEquipmentSelectionPreview();user.EquipSelectedNativeEquipment();
        Console.Printf("CA259 EQUIP action=%d compatible=%d id=%d selected=%d itemtier=%d modeltier=%d equipped=%d",
            user.LastEquipmentAction,user.EquipmentSelectionSizeCompatible,TestItem.ItemId,user.EquipmentSelectionItemId,
            TestItem.Tier,user.WeaponModel.Tier,TestItem.Equipped);
        user.SelectNativeWeaponConfiguration(Kind(),CaelumConstants.ESSENCE_FIRE,Tier);
        if(!TestItem.Equipped || user.WeaponModel.Tier!=Tier || user.WeaponModel.WeaponType!=Kind())
            Console.Printf("CA259 FAIL native equipment selection");
        user.EquipmentMenuOpen=false;
    }
    void Show(CaelumPlayer user)
    {
        static const String names[]={"CA_WEAPON_TYPE_STAFF","CA_WEAPON_TYPE_BOOK","CA_WEAPON_TYPE_STATUETTE",
            "CA_WEAPON_TYPE_BELL","CA_WEAPON_TYPE_SWORD","CA_WEAPON_TYPE_CARBINE","CA_WEAPON_TYPE_SHOTGUN",
            "CA_WEAPON_TYPE_LONGBOW","CA_WEAPON_TYPE_CROSSBOW"};
        String text=String.Format("#259 | %s T%d | Lucidez %.1f%% | F6 Lucidez / F7 tier / F8 arma",
            StringTable.Localize(names[Choice],false),Tier,FixedLucidity);
        CaelumNotifications.Notify(user,text);Console.Printf("CA259 SESSION %s",text);
    }
    override void WorldTick()
    {
        let user=CaelumPlayer(players[0].mo);
        if(!Pinned || user==null)return;
        user.CurrentLucidity=FixedLucidity;user.UpdateLucidityState();
        if(Manual)
        {
            // Recursos y stun fijos sólo para comparar trayectorias sin esperas.
            user.CurrentAir=100000;user.CurrentAnima=100000;user.LucidityPhysicalStunRemaining=0;
            user.SetRangedMagazineCount(Kind(),user.GetRangedMagazineCapacity(Kind()));
        }
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let user=CaelumPlayer(players[e.Player].mo);if(user==null)return;
        if(e.Name=="c259_seed" || e.Name=="c259_manual")
        {
            user.CreationWizardOpen=false;user.CharacterCreationComplete=true;user.ApplyCharacterProfile();
            user.Attributes.Dexterity=0;user.Attributes.Insight=0;user.Attributes.Strength=100;
            user.DerivedStats.Recalculate(user.Attributes,user.CharacterProfile);
            user.player.ConversationNPC=null;user.player.ConversationPC=null;
            user.CurrentAir=100000;user.CurrentAnima=100000;
            Manual=e.Name=="c259_manual";Pinned=true;Choice=0;Tier=Manual?1:3;
            FixedLucidity=Manual?100:9.999;user.CurrentLucidity=FixedLucidity;
            Equip(user);user.UpdateLucidityState();user.PersistCharacterState();
            if(Manual)
            {
                user.bInvulnerable=true;
                let dummy=Actor.Spawn("CaelumTrainingDummy",user.Pos+(256,0,0),NO_REPLACE);
                if(dummy!=null){dummy.bInvulnerable=true;dummy.health=1000000;user.Angle=user.AngleTo(dummy);}
                Show(user);
            }
            Console.Printf("CA259 DONE failures=%d seeded-tier=%d item-tier=%d equipped=%d",
                user.WeaponModel.Tier==Tier && TestItem.Equipped?0:1,user.WeaponModel.Tier,TestItem.Tier,TestItem.Equipped);
        }
        if(e.Name=="c259_verify" || e.Name=="c259_verify_old")
        {
            bool legacy=e.Name=="c259_verify_old";
            bool ok=TestItem!=null && TestItem.Owner==user && TestItem.Tier==3 && TestItem.Equipped
                && user.WeaponModel.Tier==3 && user.WeaponModel.WeaponType==CaelumConstants.WEAPON_TYPE_STAFF
                && Abs(user.CurrentLucidity-FixedLucidity)<=CaelumConstants.MAXIMUM_LUCIDITY/CaelumConstants.LUCIDITY_FULL_RECOVERY_SECONDS/TICRATE+0.00001
                && Abs(user.LucidityAccuracyMultiplier-(legacy?0.5:1.0))<0.00001
                && Abs(user.WeaponModel.GetMaximumSpreadFor(CaelumConstants.WEAPON_TYPE_STAFF)-(legacy?20:30))<0.00001;
            Console.Printf("CA259 %s save inventory-tier=%d model-tier=%d lucidity=%.4f multiplier=%.2f spread=%.1f",
                ok?"PASS":"FAIL",TestItem!=null?TestItem.Tier:-1,user.WeaponModel.Tier,user.CurrentLucidity,
                user.LucidityAccuracyMultiplier,user.WeaponModel.GetMaximumSpreadFor(CaelumConstants.WEAPON_TYPE_STAFF));
            Console.Printf("CA259 DONE failures=%d",ok?0:1);
        }
        if(!Manual)return;
        if(e.Name=="c259_lucidity")
        {
            static const double values[]={100,50,49.9,10,9.9};
            LucidityChoice=(LucidityChoice+1)%5;FixedLucidity=values[LucidityChoice];Show(user);
        }
        if(e.Name=="c259_tier"){Tier=Tier%3+1;Equip(user);Show(user);}
        if(e.Name=="c259_weapon"){Choice=(Choice+1)%9;Equip(user);Show(user);}
    }
}

class CA857WardrobeProbe : EventHandler
{
    CaelumDomingoPilotPlayer User;
    int Checks,Failures;
    void Check(bool okay,String label)
    {Checks++;if(!okay)Failures++;Console.Printf("CA836 EDGE %s hands861: %s",okay?"PASS":"FAIL",label);}
    void Select(CaelumEquipmentItem item)
    {User.EquipmentSelectionKind=item.EquipmentKind;User.EquipmentSelectionItemId=item.ItemId;User.RefreshEquipmentSelectionPreview();}
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
    }

    void Probe()
    {
        Setup();if(User==null)return;
        int size=CaelumEquipmentRules.GetDefaultSizeForCharacterTier(User.CharacterProfile.GetSizeTier());
        int kinds[]={CaelumClothingData.GF,CaelumClothingData.GC,CaelumClothingData.GW,CaelumClothingData.GP};
        for(int i=0;i<4;i++)
        {
            let glove=CaelumClothing.Create(User,kinds[i],size);glove.AttachToOwner(User);User.EnsureEquipmentItemId(glove);
            Select(glove);User.EquipSelectedNativeEquipment();
            Check(CaelumClothing.Equipped(User,CaelumConstants.ARMOR_SLOT_HANDS)==glove,"native clothing glove is actually equipped");
            Check(CaelumAppearanceHands.HasGloves(User),"actual clothing glove selects shared glove presentation");
            User.CharacterProfile.Sex=CaelumConstants.SEX_MALE;
            Check(CaelumAppearanceHands.Variant(User)==-1,"male clothing glove selects accepted shared glove variant");
            User.CharacterProfile.Sex=CaelumConstants.SEX_FEMALE;
            Check(CaelumAppearanceHands.Variant(User)==36,"female clothing glove selects accepted distinct glove variant");
            User.CharacterProfile.Sex=CaelumConstants.SEX_MALE;
            Select(glove);User.UnequipSelectedNativeEquipment();
            Check(!CaelumAppearanceHands.HasGloves(User),"native clothing removal remains bare");
        }
        let armor=CaelumEquipmentItem(Actor.Spawn('CaelumArmorPickup',User.Pos,NO_REPLACE));
        armor.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_ARMOR;armor.ItemType=CaelumConstants.ARMOR_TYPE_LIGHT;
        armor.ArmorSlot=CaelumConstants.ARMOR_SLOT_HANDS;armor.Tier=1;armor.EquipmentSize=size;
        armor.Durability=User.ArmorModel.GetMaximumDurabilityFor(armor.ItemType,armor.Tier,size);
        armor.UnitWeight=User.ArmorModel.GetWeightFor(armor.ArmorSlot,armor.ItemType,armor.Tier,size);
        armor.PickupDataInitialized=true;armor.AcquisitionResolved=true;armor.AttachToOwner(User);User.EnsureEquipmentItemId(armor);
        Select(armor);User.EquipSelectedNativeEquipment();
        Check(armor.Equipped && CaelumAppearanceHands.HasGloves(User),"actual hand armor selects accepted glove art");
        Check(CaelumAppearanceHands.Variant(User)==-1,"male armor keeps accepted original glove resources");
        User.CharacterProfile.Sex=CaelumConstants.SEX_FEMALE;
        Check(CaelumAppearanceHands.Variant(User)==36,"female armor selects accepted distinct glove variant");
        User.CharacterProfile.Sex=CaelumConstants.SEX_MALE;
        Select(armor);User.UnequipSelectedNativeEquipment();
        Check(!CaelumAppearanceHands.HasGloves(User),"native armor removal returns to bare hands");
        User.EquipmentMenuOpen=false;User.PersistCharacterState();
    }
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

    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!='ca857check')return;Probe();Warm();
        Console.Printf("CA836 EDGE_RESULT checks=%d failures=%d result=%s",Checks,Failures,Failures==0?"PASS":"FAIL");
    }
}
