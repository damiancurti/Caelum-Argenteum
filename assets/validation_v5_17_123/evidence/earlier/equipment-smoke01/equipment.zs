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

class CA857Camera : Actor
{
    Actor Subject;int Side;
    override void Tick()
    {
        Super.Tick();if(Subject==null)return;
        double yaw=Subject.Angle+Side*90;
        SetOrigin(Subject.Pos+(Cos(yaw)*110,Sin(yaw)*110,Subject.Height*.55),false);
        Angle=AngleTo(Subject);Pitch=0;
    }
    Default { +NOBLOCKMAP +NOINTERACTION +NOGRAVITY }
}

// Sala de autor: objetos reales; las teclas de ayuda usan operaciones nativas.
class CA889EquipmentAuthor : CA857WardrobeProbe
{
    Actor ReviewCamera;
    bool Prepared;
    int View, WeaponChoice;
    void Prepare()
    {
        if(Prepared)return;
        Setup();if(User==null)return;
        User.GrantMagicBoxFromPalomo(false);
        int size=CaelumEquipmentRules.GetDefaultSizeForCharacterTier(User.CharacterProfile.GetSizeTier());
        for(int type=0;type<CaelumClothingData.COUNT;type++)
        {
            let item=CaelumClothing.Create(User,type,size);
            item.AttachToOwner(User);User.EnsureEquipmentItemId(item);Garments.Push(item);
        }
        for(int region=0;region<CaelumConstants.ARMOR_SLOT_COUNT;region++)Cycle(region);
        // Las dimensiones de la cámara y el cofre proceden de las pruebas #857.
        let chest=CaelumStashChest(Actor.Spawn('CaelumStashChest',User.Pos+(64,0,0),NO_REPLACE));
        chest.EnsureStorage();
        for(int slot=0;slot<CaelumConstants.ARMOR_SLOT_COUNT;slot++)
        {
            let armor=CaelumEquipmentItem(Actor.Spawn('CaelumArmorPickup',User.Pos,NO_REPLACE));
            armor.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_ARMOR;
            armor.ItemType=CaelumConstants.ARMOR_TYPE_LIGHT;armor.ArmorSlot=slot;armor.Tier=1;
            armor.EquipmentSize=size;
            armor.Durability=User.ArmorModel.GetMaximumDurabilityFor(armor.ItemType,armor.Tier,size);
            armor.UnitWeight=User.ArmorModel.GetWeightFor(slot,armor.ItemType,armor.Tier,size);
            armor.PickupDataInitialized=true;armor.AcquisitionResolved=true;
            armor.AttachToOwner(User);User.EnsureEquipmentItemId(armor);
        }
        User.EquipmentMenuOpen=false;User.PersistCharacterState();Prepared=true;
        ReviewCamera=Actor.Spawn('CA857Camera',User.Pos+(110,0,User.Height*.55),NO_REPLACE);
        ReviewCamera.CameraFOV=55;CA857Camera(ReviewCamera).Subject=User;
        players[0].camera=ReviewCamera;View=0;
        Console.Printf("CA889 EQUIPMENT READY garments=%d box=%d",Garments.Size(),User.MagicBoxOwned);
    }
    void Cycle(int region)
    {
        User=CaelumDomingoPilotPlayer(players[0].mo);if(User==null)return;
        let current=CaelumClothing.Equipped(User,region);
        int start=-1;
        for(int i=0;i<Garments.Size();i++)if(Garments[i]==current)start=i;
        CaelumEquipmentItem next=null;
        for(int i=start+1;i<Garments.Size();i++)
        {
            let item=Garments[i];
            if(item!=null && !item.bDestroyed && item.Owner==User && !item.InMagicBox
                && CaelumClothingData.Region(item.ItemType)==region){next=item;break;}
        }
        if(next!=null){Select(next);User.EquipSelectedNativeEquipment();}
        else if(current!=null){Select(current);User.UnequipSelectedNativeEquipment();}
        User.EquipmentMenuOpen=false;User.PersistCharacterState();Refresh();
        Console.Printf("CA889 EQUIPMENT CYCLE region=%d item=%d",region,next!=null?next.ItemId:0);
    }
    void EquipWeapon()
    {
        User=CaelumDomingoPilotPlayer(players[0].mo);if(User==null)return;
        WeaponChoice=(WeaponChoice+1)%3;
        let equipment=new('CA259Session');
        equipment.Choice=WeaponChoice==0?4:WeaponChoice==1?5:0;equipment.Tier=1;equipment.Equip(User);
        if(WeaponChoice==1)
        {
            int kind=CaelumConstants.WEAPON_TYPE_CARBINE;
            let ammo=User.FindNativeAmmunition(CaelumRangedRules.AmmoType(kind));
            if(ammo==null)ammo=Inventory(User.GiveInventoryType(CaelumInventoryService.GetAmmunitionClassName(User,CaelumRangedRules.AmmoType(kind))));
            if(ammo!=null)ammo.Amount=Max(ammo.Amount,CaelumRangedRules.MagazineCapacity(kind));
            User.SetRangedMagazineCount(kind,0);
        }
        User.EquipmentMenuOpen=false;User.PersistCharacterState();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        User=CaelumDomingoPilotPlayer(players[0].mo);
        if(e.Name=='ca889_setup')Prepare();
        if(User==null)return;
        if(e.Name=='ca889_region')Cycle(e.Args[0]);
        if(e.Name=='ca889_view')
        {
            View=(View+1)%5;
            if(ReviewCamera!=null)CA857Camera(ReviewCamera).Side=View;
            players[0].camera=View==4 || ReviewCamera==null?User:ReviewCamera;
        }
        if(e.Name=='ca889_weapon')EquipWeapon();
        if(e.Name=='ca889_sex')
        {
            User.CharacterProfile.Sex=1-User.CharacterProfile.Sex;
            User.ApplyCharacterProfile();User.PersistCharacterState();User.UpdatePilotVisual();
        }
        if(e.Name=='ca889_moon')
        {
            bool started=CaelumTarotMoon.Start(User,CaelumConstants.TAROT_EFFECT_SECONDS*TICRATE);
            Console.Printf("CA889 DIAGNOSTIC MOON started=%d",started);
        }
        if(e.Name=='ca889_death')
        {
            User.bInvulnerable=false;
            User.DamageMobj(ReviewCamera,ReviewCamera,10000000,'CaelumPhysicalTest',DMG_FORCED,0);
        }
        if(e.Name=='ca889_state')
            Console.Printf("CA889 EQUIPMENT STATE box=%d garments=%d health=%d",User.MagicBoxOwned,Garments.Size(),User.health);
    }
}
