// Sala de autor: objetos reales; las teclas de ayuda usan operaciones nativas.
class CA889EquipmentAuthor : CA857WardrobeProbe
{
    Actor ReviewCamera;
    CA259Session ReviewEquipment;
    CaelumEquipmentItem ReviewShield;
    bool Prepared;
    int View, WeaponChoice;
    void Prepare()
    {
        if(Prepared)return;
        Setup();if(User==null)return;
        ReviewShield=User.FindNativeEquipmentItemById(User.EquippedShieldItemId);
        if(!User.DebugAttributesAt100)User.ToggleDebugAttributes100();
        User.ApplyCharacterProfile();
        User.HealDebugHealth();
        User.GrantMagicBoxFromPalomo(false);
        int size=CaelumEquipmentRules.GetDefaultSizeForCharacterTier(User.CharacterProfile.GetSizeTier());
        for(int type=0;type<CaelumClothingData.COUNT;type++)
        {
            let item=CaelumClothing.Create(User,type,size);
            item.AttachToOwner(User);User.EnsureEquipmentItemId(item);Garments.Push(item);
        }
        for(int region=0;region<CaelumConstants.ARMOR_SLOT_COUNT;region++)Cycle(region);
        // Las dimensiones de la cámara y el cofre proceden de las pruebas #857.
        let chest=CaelumStashChest(Actor.Spawn('CaelumStashChest',User.Pos+(0,64,0),NO_REPLACE));
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
        Check(CaelumClothing.Equipped(User,region)==next,"author cycle follows the native equipped object");
        User.EquipmentMenuOpen=false;User.PersistCharacterState();Refresh();
        Console.Printf("CA889 EQUIPMENT CYCLE region=%d item=%d",region,next!=null?next.ItemId:0);
    }
    void EquipWeapon()
    {
        User=CaelumDomingoPilotPlayer(players[0].mo);if(User==null)return;
        WeaponChoice=(WeaponChoice+1)%3;
        if(ReviewEquipment==null)ReviewEquipment=new('CA259Session');
        let equipment=ReviewEquipment;
        equipment.Choice=WeaponChoice==0?4:WeaponChoice==1?5:0;equipment.Tier=1;equipment.Equip(User);
        if(WeaponChoice==0 && ReviewShield!=null && ReviewShield.Owner==User && !ReviewShield.InMagicBox)
        {
            Select(ReviewShield);User.EquipSelectedNativeEquipment();
            Check(ReviewShield.Equipped,"return to sword restores the room's owned buckler");
        }
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
        if(ReviewCamera!=null)CA857Camera(ReviewCamera).Subject=User;
        if(e.Name=='ca889_region')Cycle(e.Args[0]);
        if(e.Name=='ca889_view')
        {
            View=(View+1)%5;
            if(ReviewCamera!=null)CA857Camera(ReviewCamera).Side=View;
            if(View==4 || ReviewCamera==null)players[0].camera=User;
            else players[0].camera=ReviewCamera;
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
        {
            Console.Printf("CA889 EQUIPMENT STATE box=%d garments=%d health=%d attributes100=%d",User.MagicBoxOwned,Garments.Size(),User.health,User.DebugAttributesAt100);
            Console.Printf("CA889 EQUIPMENT VISUAL weapon=%d shield=%d body=%s",User.WeaponModel.WeaponType,User.ShieldModel.Equipped,User.PilotBody!=null?User.PilotBody.GetClassName():'None');
            let body=CaelumWardrobePilotBody(User.PilotBody);
            if(body!=null)Console.Printf("CA889 SNAPSHOT frozen=%d head=%d body=%d hand=%d foot=%d",body.FrozenDeath,body.HeadKind,body.BodyKind,body.HandKind,body.FootKind);
            for(int region=0;region<CaelumConstants.ARMOR_SLOT_COUNT;region++)
            {
                let item=CaelumClothing.Equipped(User,region);
                Console.Printf("CA889 OWNED region=%d id=%d kind=%d",region,item!=null?item.ItemId:0,item!=null?item.ItemType:-1);
            }
        }
    }
}
