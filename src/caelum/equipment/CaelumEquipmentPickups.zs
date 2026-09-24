// Registro de sprites propios usados dinámicamente por pickups y proyectiles.
// GZDoom sólo genera SpriteID para gráficos declarados en algún bloque States.
class CaelumWorldSpriteRegistry : Actor
{
    States
    {
    Spawn:
        CSWD A 1;
        CSTF A 1;
        CCAR A 1;
        CDAG A 1;
        CHAT A 1;
        CMAC A 1;
        CJAV A 1;
        CAXE A 1;
        CFLA A 1;
        CSPR A 1;
        CGRS A 1;
        CWAX A 1;
        CHAL A 1;
        CGAU A 1;
        CBOW A 1;
        CLBW A 1;
        CCBW A 1;
        CBEL A 1;
        CBOO A 1;
        CSTA A 1;
        CSHM A 1;
        CBUC A 1;
        CSHK A 1;
        CSHT A 1;
        CAMA A 1;
        CALI A 1;
        CAMD A 1;
        CAHV A 1;
        CHMG A 1;
        CHMD A 1;
        CHEH A 1;
        CHLT A 1;
        CGMM A 1;
        CGMD A 1;
        CGHV A 1;
        CGLT A 1;
        CBOM A 1;
        CBMD A 1;
        CBHV A 1;
        CBLT A 1;
        CCAA A 1;
        CARR A 1;
        CBOL A 1;
        CKEY A 1;
        CAMU A 1;
        CMED A 1;
        CANI A 1;
        CENE A 1;
        CFOO A 1;
        CWAT A 1;
        XFIR A 1;
        XLIT A 1;
        XWAT A 1;
        XICE A 1;
        XRAY A 1;
        XERT A 1;
        XVSN A 1;
        XAIR A 1;
        XQUI A 1;
        CSEL A 1;
        CTAR A 1;
        M000 A 1;
        M001 A 1;
        M002 A 1;
        M003 A 1;
        M004 A 1;
        M005 A 1;
        M006 A 1;
        M007 A 1;
        M008 A 1;
        M009 A 1;
        M010 A 1;
        M011 A 1;
        M012 A 1;
        M013 A 1;
        M014 A 1;
        M015 A 1;
        M016 A 1;
        M017 A 1;
        M018 A 1;
        M019 A 1;
        M020 A 1;
        M021 A 1;
        M022 A 1;
        M023 A 1;
        M024 A 1;
        M025 A 1;
        M026 A 1;
        M027 A 1;
        M028 A 1;
        M029 A 1;
        M030 A 1;
        M031 A 1;
        M032 A 1;
        M033 A 1;
        M034 A 1;
        M035 A 1;
        M036 A 1;
        M037 A 1;
        M038 A 1;
        M039 A 1;
        M040 A 1;
        M041 A 1;
        M042 A 1;
        Stop;
    }
}

// Objetos reales del inventario nativo. Cada pieza conserva su configuración,
// durabilidad y estados de equipado/Caja Mágica dentro de la propia instancia.
class CaelumEquipmentItem : Inventory
{
    // Identidad estable de esta pieza concreta. Dos objetos con la misma
    // receta, tier y talle siguen siendo instancias distintas para reparar,
    // soltar, equipar y guardar. El contador vive en el estado persistente
    // del personaje; cero queda reservado para objetos todavía no adquiridos.
    int ItemId;
    int ItemFlags;

    bool IsLimboTemporary() { return (ItemFlags & CaelumConstants.CA_ITEMFLAG_LIMBO_TEMP) != 0; }
    bool IsLimboFirstWeapon()
    {
        return level.MapName == "MAP01" && (ItemFlags & CaelumConstants.CA_ITEMFLAG_LIMBO_PRESERVABLE) != 0;
    }
    int EquipmentKind;
    int ItemType;
    int ArmorSlot;
    int Tier;
    int EquipmentSize;
    int Durability;
    int EssenceType;
    double UnitWeight;
    bool Equipped;
    bool InMagicBox;
    bool PickupDataInitialized;
    int SizePolicy;
    int SizePolicyRevision;
    bool AcquisitionResolved;
    // Editor/DECORATE: CaelumEquipmentItem.SizePolicy 1 = CHARACTER_DEFAULT,
    // 2 = FIXED_SIZE. Los args de talle conservan 0=M y 1..5=XS..XL.
    property SizePolicy: SizePolicy;

    override String PickupMessage() { return ""; }

    bool HasAcquiredIdentity()
    {
        // Los cofres son dueños nativos de su contenido, pero no receptores.
        if (!AcquisitionResolved && Owner!=null && !(Owner is "CaelumPlayer")) return false;
        // Un intento antiguo fallido podía reservar ItemId antes de comprobar
        // la carga. El ID solo no prueba adquisición de contenido sin recoger.
        return AcquisitionResolved || Owner is "CaelumPlayer"
            || (bDROPPED && (PickupDataInitialized || ItemId > 0));
    }

    int PreviewEquipmentKind()
    {
        if (PickupDataInitialized || HasAcquiredIdentity()) return EquipmentKind;
        if (self is "CaelumArmorPickup") return CaelumConstants.EQUIPMENT_KIND_ARMOR;
        if (self is "CaelumShieldPickup") return CaelumConstants.EQUIPMENT_KIND_SHIELD;
        if (self is "CaelumWeaponPickup") return CaelumConstants.EQUIPMENT_KIND_WEAPON;
        if (self is "CaelumAmuletPickup") return CaelumConstants.EQUIPMENT_KIND_AMULET;
        return CaelumConstants.EQUIPMENT_KIND_SEAL;
    }

    int PreviewItemType()
    {
        if (PickupDataInitialized || HasAcquiredIdentity()) return ItemType;
        int kind=PreviewEquipmentKind();
        if (kind==CaelumConstants.EQUIPMENT_KIND_ARMOR) return args[1];
        int count=kind==CaelumConstants.EQUIPMENT_KIND_WEAPON ? CaelumConstants.WEAPON_TYPE_COUNT
            : kind==CaelumConstants.EQUIPMENT_KIND_SHIELD ? CaelumConstants.SHIELD_TYPE_COUNT
            : kind==CaelumConstants.EQUIPMENT_KIND_AMULET ? CaelumConstants.AMULET_TYPE_COUNT
            : CaelumConstants.SEAL_TYPE_COUNT;
        return Clamp(args[0],0,count-1);
    }

    int PreviewArmorSlot()
    {
        if (PickupDataInitialized || HasAcquiredIdentity()) return ArmorSlot;
        return PreviewEquipmentKind() == CaelumConstants.EQUIPMENT_KIND_ARMOR
            ? Clamp(args[0], 0, CaelumConstants.ARMOR_SLOT_COUNT - 1) : -1;
    }

    int PreviewTier()
    {
        if (HasAcquiredIdentity()) return Tier;
        if (level.MapName == "MAP02") return 1;
        return PickupDataInitialized ? Tier
            : Clamp(args[PreviewEquipmentKind() == CaelumConstants.EQUIPMENT_KIND_ARMOR ? 2 : 1], 1, 3);
    }

    int PreviewEssenceType()
    {
        if (PickupDataInitialized || HasAcquiredIdentity()) return EssenceType;
        if (PreviewEquipmentKind() == CaelumConstants.EQUIPMENT_KIND_SEAL) return PreviewItemType();
        return args[4] > 0 ? Clamp(args[4] - 1, 0, CaelumConstants.ESSENCE_TYPE_COUNT - 1)
            : CaelumConstants.ESSENCE_FIRE;
    }

    bool HasEquipmentSize()
    {
        int kind = PreviewEquipmentKind();
        return kind == CaelumConstants.EQUIPMENT_KIND_ARMOR
            || kind == CaelumConstants.EQUIPMENT_KIND_SHIELD
            || kind == CaelumConstants.EQUIPMENT_KIND_WEAPON;
    }

    int PreviewEquipmentSize(CaelumPlayer user)
    {
        if (HasAcquiredIdentity()) return EquipmentSize;
        if (!HasEquipmentSize()) return PickupDataInitialized ? EquipmentSize : CaelumConstants.EQUIPMENT_SIZE_M;
        int encoded = args[PreviewEquipmentKind() == CaelumConstants.EQUIPMENT_KIND_ARMOR ? 3 : 2];
        int fixedSize = PickupDataInitialized ? EquipmentSize
            : encoded <= 0 ? CaelumConstants.EQUIPMENT_SIZE_M
            : Clamp(encoded - 1, 0, CaelumConstants.EQUIPMENT_SIZE_COUNT - 1);
        int policy = SizePolicy == CaelumEquipmentRules.FIXED_SIZE
            ? CaelumEquipmentRules.FIXED_SIZE : CaelumEquipmentRules.CHARACTER_DEFAULT;
        return CaelumEquipmentRules.ResolveAcquisitionSize(user, policy, fixedSize);
    }

    double PreviewUnitWeight(CaelumPlayer user)
    {
        if (HasAcquiredIdentity() || user==null) return UnitWeight;
        int kind=PreviewEquipmentKind(), type=PreviewItemType(), tier=PreviewTier();
        int size=PreviewEquipmentSize(user);
        if (kind==CaelumConstants.EQUIPMENT_KIND_ARMOR && user.ArmorModel!=null)
            return user.ArmorModel.GetWeightFor(PreviewArmorSlot(),type,tier,size);
        if (kind==CaelumConstants.EQUIPMENT_KIND_SHIELD && user.ShieldModel!=null)
            return user.ShieldModel.GetWeightFor(type,tier,size);
        if (kind==CaelumConstants.EQUIPMENT_KIND_WEAPON && user.WeaponModel!=null)
            return user.WeaponModel.GetWeightFor(type,tier,size);
        return double(tier);
    }

    int PreviewMaximumDurability(CaelumPlayer user)
    {
        if (user==null) return 0;
        int kind=PreviewEquipmentKind(), type=PreviewItemType(), tier=PreviewTier();
        int size=PreviewEquipmentSize(user);
        if (kind==CaelumConstants.EQUIPMENT_KIND_ARMOR && user.ArmorModel!=null)
            return user.ArmorModel.GetMaximumDurabilityFor(type,tier,size);
        if (kind==CaelumConstants.EQUIPMENT_KIND_SHIELD && user.ShieldModel!=null)
            return user.ShieldModel.GetMaximumDurabilityFor(type,tier,size);
        if (kind==CaelumConstants.EQUIPMENT_KIND_WEAPON && user.WeaponModel!=null)
            return user.WeaponModel.GetMaximumDurabilityFor(type,tier,size);
        return 0;
    }

    int PreviewDurability(CaelumPlayer user)
    {
        if (HasAcquiredIdentity()) return Durability;
        int maximum=PreviewMaximumDurability(user);
        int encoded=args[PreviewEquipmentKind()==CaelumConstants.EQUIPMENT_KIND_ARMOR ? 4 : 3];
        return encoded>0 ? Min(maximum,encoded-1) : maximum;
    }

    double PreviewBaseValue(CaelumPlayer user)
    {
        if ((ItemFlags & CaelumConstants.CA_ITEMFLAG_LIMBO_TEMP)!=0
            || (level.MapName=="MAP01" && (ItemFlags & CaelumConstants.CA_ITEMFLAG_LIMBO_PRESERVABLE)!=0)) return 0;
        return CaelumEconomyRules.GetEquipmentBaseValueFor(PreviewEquipmentKind(),PreviewItemType(),
            PreviewArmorSlot(),PreviewTier(),PreviewEssenceType(),PreviewUnitWeight(user));
    }

    bool TryEquipmentPickup(in out Actor toucher)
    {
        let user = CaelumPlayer(toucher);
        if (user == null) return false;
        if (HasAcquiredIdentity()) return TryCaelumPickup(toucher);
        if (HasEquipmentSize() && (user.CharacterProfile == null || user.ArmorModel == null
            || user.ShieldModel == null || user.WeaponModel == null)) return false;

        // Vista transaccional: ningún fallo reserva talle, tier, vida ni peso.
        int oldKind=EquipmentKind, oldType=ItemType, oldSlot=ArmorSlot, oldTier=Tier;
        int oldSize=EquipmentSize, oldDurability=Durability, oldEssence=EssenceType;
        double oldWeight=UnitWeight;
        bool oldInitialized=PickupDataInitialized;
        int incomingKind=PreviewEquipmentKind(), incomingType=PreviewItemType();
        int incomingSlot=PreviewArmorSlot(), incomingTier=PreviewTier();
        int incomingSize=PreviewEquipmentSize(user), incomingEssence=PreviewEssenceType();
        double incomingWeight=PreviewUnitWeight(user);
        int incomingDurability=PreviewDurability(user);
        EquipmentKind=incomingKind; ItemType=incomingType; ArmorSlot=incomingSlot;
        Tier=incomingTier; EquipmentSize=incomingSize; EssenceType=incomingEssence;
        UnitWeight=incomingWeight; Durability=incomingDurability;
        PickupDataInitialized=true;
        if (TryCaelumPickup(toucher)) return true;
        EquipmentKind=oldKind; ItemType=oldType; ArmorSlot=oldSlot; Tier=oldTier;
        EquipmentSize=oldSize; Durability=oldDurability; EssenceType=oldEssence;
        UnitWeight=oldWeight; PickupDataInitialized=oldInitialized;
        return false;
    }

    Default
    {
        CaelumEquipmentItem.SizePolicy 1;
        Radius 12;
        Height 8;
        // Escala visual del pickup en el mundo. Inventory.Icon no se altera.
        Scale 0.25;
        Inventory.Amount 1;
        Inventory.MaxAmount 1;
        Inventory.InterHubAmount 1;
        Inventory.PickupSound "caelum/items/pickup";
        // El equipo se administra desde la interfaz propia. Excluirlo de la
        // barra nativa evita que su icono reemplace la cara del HUD clásico.
        -INVENTORY.INVBAR
    }

    bool Matches(
        int requestedKind,
        int requestedItemType,
        int requestedArmorSlot,
        int requestedTier,
        int requestedEquipmentSize
    )
    {
        return EquipmentKind == requestedKind
            && ItemType == requestedItemType
            && (requestedKind != CaelumConstants.EQUIPMENT_KIND_ARMOR
                || ArmorSlot == requestedArmorSlot)
            && Tier == requestedTier
            && EquipmentSize == requestedEquipmentSize;
    }

    bool MatchesMagicWeapon(
        int requestedWeaponType,
        int requestedEssenceType,
        int requestedTier,
        int requestedEquipmentSize
    )
    {
        return EquipmentKind == CaelumConstants.EQUIPMENT_KIND_WEAPON
            && ItemType == requestedWeaponType
            && EssenceType == requestedEssenceType
            && Tier == requestedTier
            && EquipmentSize == requestedEquipmentSize;
    }

    double GetCarriedWeight()
    {
        // El peso reducido compartido de la Caja Mágica pertenece al resumen
        // agregado del jugador, no a una pieza individual.
        return InMagicBox ? 0.0 : Max(0.0, UnitWeight) * Amount;
    }

    // Las piezas no son apilables. Devolver false permite que el motor añada
    // otra instancia aun cuando su clase ZScript sea la misma.
    override bool HandlePickup(Inventory item)
    {
        if (CaelumEquipmentItem(item) != null) { return false; }
        return Super.HandlePickup(item);
    }

    override Inventory CreateCopy(Actor other)
    {
        CaelumEquipmentItem copy = CaelumEquipmentItem(Super.CreateCopy(other));
        if (copy != null && copy != self)
        {
            copy.EquipmentKind = EquipmentKind;
            copy.ItemId = ItemId;
            copy.ItemFlags = ItemFlags;
            copy.ItemType = ItemType;
            copy.ArmorSlot = ArmorSlot;
            copy.Tier = Tier;
            copy.EquipmentSize = EquipmentSize;
            copy.Durability = Durability;
            copy.EssenceType = EssenceType;
            copy.UnitWeight = UnitWeight;
            copy.Equipped = Equipped;
            copy.InMagicBox = InMagicBox;
            copy.PickupDataInitialized = PickupDataInitialized;
            copy.SizePolicy = SizePolicy;
            copy.SizePolicyRevision = SizePolicyRevision;
            copy.AcquisitionResolved = HasAcquiredIdentity();
        }
        return copy;
    }

    override Inventory CreateTossable(int tossAmount)
    {
        if (IsLimboTemporary() || IsLimboFirstWeapon()) return null;
        CaelumEquipmentItem copy = CaelumEquipmentItem(
            Super.CreateTossable(tossAmount)
        );
        if (copy != null && copy != self)
        {
            copy.ItemId = ItemId;
            copy.ItemFlags = ItemFlags;
            copy.EquipmentKind = EquipmentKind;
            copy.ItemType = ItemType;
            copy.ArmorSlot = ArmorSlot;
            copy.Tier = Tier;
            copy.EquipmentSize = EquipmentSize;
            copy.Durability = Durability;
            copy.EssenceType = EssenceType;
            copy.UnitWeight = UnitWeight;
            copy.Equipped = false;
            copy.InMagicBox = false;
            copy.PickupDataInitialized = PickupDataInitialized;
            copy.SizePolicy = SizePolicy;
            copy.SizePolicyRevision = SizePolicyRevision;
            copy.AcquisitionResolved = HasAcquiredIdentity();
        }
        return copy;
    }

    // Actualiza el sprite visible solo cuando la instancia está en el mundo.
    // El inventario conserva Inventory.Icon por separado.
    virtual void UpdateWorldSprite() {}

    override void Tick()
    {
        Super.Tick();
        if (Owner == null) { UpdateWorldSprite(); }
    }

    protected bool TryCaelumPickup(in out Actor toucher)
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(toucher);
        if (caelumPlayer == null) return false;
        int oldId=ItemId, oldRevision=SizePolicyRevision;
        bool oldResolved=AcquisitionResolved, oldEquipped=Equipped, oldBox=InMagicBox;
        bool oldPickupNew=caelumPlayer.LastEquipmentPickupWasNew;
        bool oldPickupBox=caelumPlayer.LastEquipmentPickupWentToMagicBox;
        if (!caelumPlayer.PrepareNativeEquipmentPickup(self))
        {
            ItemId=oldId; Equipped=oldEquipped; InMagicBox=oldBox;
            return false;
        }
        AcquisitionResolved=true;
        SizePolicyRevision=CaelumEquipmentRules.SIZE_POLICY_REVISION;
        // Super.TryPickup puede adjuntar una copia y destruir el actor del
        // mundo. Conservamos la identidad antes de entregarlo para que el
        // jugador pueda activar la configuración del arma recién recogida.
        int pickedItemId = ItemId;
        int pickedKind = EquipmentKind;
        int pickedType = ItemType;
        int pickedTier = Tier;
        int pickedSize = EquipmentSize;
        int pickedEssence = EssenceType;
        bool pickedIntoMagicBox = InMagicBox;

        bool pickedUp = Super.TryPickup(toucher);
        if (pickedUp)
        {
            caelumPlayer.OnNativeEquipmentPickedUp(
                pickedItemId,
                pickedKind,
                pickedType,
                pickedTier,
                pickedSize,
                pickedEssence,
                pickedIntoMagicBox
            );
            CaelumNotifications.Acquired(caelumPlayer,
                caelumPlayer.FindNativeEquipmentItemById(pickedItemId), 1);
        }
        else
        {
            ItemId=oldId; Equipped=oldEquipped; InMagicBox=oldBox;
            AcquisitionResolved=oldResolved; SizePolicyRevision=oldRevision;
            caelumPlayer.LastEquipmentPickupWasNew=oldPickupNew;
            caelumPlayer.LastEquipmentPickupWentToMagicBox=oldPickupBox;
        }
        return pickedUp;
    }
}

// args: ranura, tipo, tier, talle (1..5), durabilidad+1.
class CaelumArmorPickup : CaelumEquipmentItem
{
    override void UpdateWorldSprite()
    {
        // Una armadura recién creada todavía vive de args[]. Una copia que
        // vuelve al mundo desde el inventario conserva sus campos persistentes.
        // No usamos EquipmentKind como centinela porque ARMOR vale 0 y ese
        // mismo valor es también el inicial de un int sin configurar.
        int slot = PreviewArmorSlot();
        int armorType = PreviewItemType();
        String visual = "CALI";
        if (armorType == CaelumConstants.ARMOR_TYPE_LIGHT)
        {
            if (slot == CaelumConstants.ARMOR_SLOT_HEAD) visual = "CHLT";
            else if (slot == CaelumConstants.ARMOR_SLOT_HANDS) visual = "CGLT";
            else if (slot == CaelumConstants.ARMOR_SLOT_FEET) visual = "CBLT";
            else visual = "CALI";
        }
        else if (armorType == CaelumConstants.ARMOR_TYPE_MAGIC)
        {
            if (slot == CaelumConstants.ARMOR_SLOT_HEAD) visual = "CHMG";
            else if (slot == CaelumConstants.ARMOR_SLOT_HANDS) visual = "CGMM";
            else if (slot == CaelumConstants.ARMOR_SLOT_FEET) visual = "CBOM";
            else visual = "CAMA";
        }
        else if (armorType == CaelumConstants.ARMOR_TYPE_MEDIUM)
        {
            if (slot == CaelumConstants.ARMOR_SLOT_HEAD) visual = "CHMD";
            else if (slot == CaelumConstants.ARMOR_SLOT_HANDS) visual = "CGMD";
            else if (slot == CaelumConstants.ARMOR_SLOT_FEET) visual = "CBMD";
            else visual = "CAMD";
        }
        else if (armorType == CaelumConstants.ARMOR_TYPE_HEAVY)
        {
            if (slot == CaelumConstants.ARMOR_SLOT_HEAD) visual = "CHEH";
            else if (slot == CaelumConstants.ARMOR_SLOT_HANDS) visual = "CGHV";
            else if (slot == CaelumConstants.ARMOR_SLOT_FEET) visual = "CBHV";
            else visual = "CAHV";
        }
        sprite = GetSpriteIndex(visual);
        frame = 0;
    }

    States
    {
    Spawn:
        CALI A -1;
        Stop;
    }

    override bool TryPickup(in out Actor toucher)
    {
        return TryEquipmentPickup(toucher);
    }
}

// args: tipo, tier, talle (1..5), durabilidad+1.
class CaelumShieldPickup : CaelumEquipmentItem
{
    override void UpdateWorldSprite()
    {
        int shieldType = EquipmentKind == CaelumConstants.EQUIPMENT_KIND_SHIELD
            ? ItemType : Clamp(args[0], 0, CaelumConstants.SHIELD_TYPE_COUNT - 1);
        String visual = "CSHM";
        if (shieldType == CaelumConstants.SHIELD_TYPE_BUCKLER) visual = "CBUC";
        else if (shieldType == CaelumConstants.SHIELD_TYPE_KITE) visual = "CSHK";
        else if (shieldType == CaelumConstants.SHIELD_TYPE_TOWER) visual = "CSHT";
        sprite = GetSpriteIndex(visual);
        frame = 0;
    }

    States
    {
    Spawn:
        CSHM A -1;
        Stop;
    }

    override bool TryPickup(in out Actor toucher)
    {
        return TryEquipmentPickup(toucher);
    }
}

// args: tipo, tier, talle (1..5), durabilidad+1, esencia+1.
class CaelumWeaponPickup : CaelumEquipmentItem
{
    override void UpdateWorldSprite()
    {
        int weaponType = EquipmentKind == CaelumConstants.EQUIPMENT_KIND_WEAPON
            ? ItemType : Clamp(args[0], 0, CaelumConstants.WEAPON_TYPE_COUNT - 1);
        String visual = "CSWD";
        switch (weaponType)
        {
            case CaelumConstants.WEAPON_TYPE_SWORD: visual = "CSWD"; break;
            case CaelumConstants.WEAPON_TYPE_STAFF: visual = "CSTF"; break;
            case CaelumConstants.WEAPON_TYPE_CARBINE: visual = "CCAR"; break;
            case CaelumConstants.WEAPON_TYPE_DAGGER: visual = "CDAG"; break;
            case CaelumConstants.WEAPON_TYPE_HATCHET: visual = "CHAT"; break;
            case CaelumConstants.WEAPON_TYPE_MACHETE: visual = "CMAC"; break;
            case CaelumConstants.WEAPON_TYPE_JAVELIN: visual = "CJAV"; break;
            case CaelumConstants.WEAPON_TYPE_AXE: visual = "CAXE"; break;
            case CaelumConstants.WEAPON_TYPE_FLAIL: visual = "CFLA"; break;
            case CaelumConstants.WEAPON_TYPE_SPEAR: visual = "CSPR"; break;
            case CaelumConstants.WEAPON_TYPE_GREATSWORD: visual = "CGRS"; break;
            case CaelumConstants.WEAPON_TYPE_WAR_AXE: visual = "CWAX"; break;
            case CaelumConstants.WEAPON_TYPE_HALBERD: visual = "CHAL"; break;
            case CaelumConstants.WEAPON_TYPE_GIANT_GAUNTLETS: visual = "CGAU"; break;
            case CaelumConstants.WEAPON_TYPE_STANDARD_BOW: visual = "CBOW"; break;
            case CaelumConstants.WEAPON_TYPE_LONGBOW: visual = "CLBW"; break;
            case CaelumConstants.WEAPON_TYPE_CROSSBOW: visual = "CCBW"; break;
            case CaelumConstants.WEAPON_TYPE_BELL: visual = "CBEL"; break;
            case CaelumConstants.WEAPON_TYPE_BOOK: visual = "CBOO"; break;
            default: visual = "CSTA"; break;
        }
        sprite = GetSpriteIndex(visual);
        frame = 0;
    }

    Default
    {
        Inventory.PickupSound "caelum/items/weapon_pickup";
    }

    States
    {
    Spawn:
        CSWD A -1;
        Stop;
    }

    override bool TryPickup(in out Actor toucher)
    {
        return TryEquipmentPickup(toucher);
    }
}


class CaelumAmuletPickup : CaelumEquipmentItem
{
    Default
    {
        Tag "$CA_EQUIPMENT_CATEGORY_AMULET";
        Inventory.PickupMessage "$CA_PICKUP_AMULET";
        // El arte nuevo ocupa casi todo el lienzo 128x128; compensamos sólo
        // el actor de mundo. Inventory.Icon mantiene resolución completa.
        Scale 0.275;
    }
    String GetJewelryIconPath()
    {
        int t = PreviewItemType();
        int tier = PreviewTier();
        return CaelumIconResolver.ResolveTierPath(
            CaelumIconResolver.GetAmuletBasePath(t), tier
        );
    }
    String GetJewelrySpriteName()
    {
        int t = PreviewItemType();
        if (t == CaelumConstants.AMULET_SAPPHIRE) return "AMSA";
        if (t == CaelumConstants.AMULET_EMERALD) return "AMEM";
        if (t == CaelumConstants.AMULET_TOPAZ) return "AMTO";
        return "AMRB";
    }
    override void UpdateWorldSprite()
    {
        Icon = TexMan.CheckForTexture(GetJewelryIconPath(), TexMan.Type_MiscPatch);
        sprite = GetSpriteIndex(GetJewelrySpriteName()); frame = 0;
    }
    override void Tick() { Super.Tick(); Icon = TexMan.CheckForTexture(GetJewelryIconPath(), TexMan.Type_MiscPatch); }
    States
    {
    Spawn:
        AMRB A -1;
        Stop;
    VisualRegistry:
        AMSA A 0;
        AMEM A 0;
        AMTO A 0;
        Stop;
    }
    override bool TryPickup(in out Actor toucher)
    {
        return TryEquipmentPickup(toucher);
    }
}

class CaelumSealPickup : CaelumEquipmentItem
{
    Default
    {
        Tag "$CA_EQUIPMENT_CATEGORY_SEAL";
        Inventory.PickupMessage "$CA_PICKUP_SEAL";
        Scale 0.275;
        // El inventario/equipamiento propio ya gestiona los Sellos. Evita que
        // el último recogido reemplace la cara en la barra nativa de GZDoom.
        -INVENTORY.INVBAR
    }
    String GetJewelryIconPath()
    {
        int t = PreviewItemType();
        int tier = PreviewTier();
        return CaelumIconResolver.ResolveTierPath(
            CaelumIconResolver.GetSealBasePath(t), tier
        );
    }
    String GetJewelrySpriteName()
    {
        int t = PreviewItemType();
        if (t == CaelumConstants.SEAL_WATER) return "SLWA";
        if (t == CaelumConstants.SEAL_EARTH) return "SLEA";
        if (t == CaelumConstants.SEAL_AIR) return "SLAI";
        if (t == CaelumConstants.SEAL_QUINTESSENCE) return "SLQU";
        return "SLFI";
    }
    override void UpdateWorldSprite()
    {
        Icon = TexMan.CheckForTexture(GetJewelryIconPath(), TexMan.Type_MiscPatch);
        sprite = GetSpriteIndex(GetJewelrySpriteName()); frame = 0;
    }
    override void Tick() { Super.Tick(); Icon = TexMan.CheckForTexture(GetJewelryIconPath(), TexMan.Type_MiscPatch); }
    States
    {
    Spawn:
        SLFI A -1;
        Stop;
    VisualRegistry:
        SLWA A 0;
        SLEA A 0;
        SLAI A 0;
        SLQU A 0;
        Stop;
    }
    override bool TryPickup(in out Actor toucher)
    {
        return TryEquipmentPickup(toucher);
    }
}

// Toda la pila ocupa un único slot de Caja Mágica. Cada bala conserva su peso
// de 0,003; dentro, la pila participa del cálculo agregado reducido.
class CaelumCarbineAmmo : Ammo
{
    bool InMagicBox;
    override String PickupMessage() { return ""; }

    Default
    {
        Inventory.Icon "graphics/caelum/icons/ca_carbine_ammo.png";
        Inventory.Amount 20;
        Scale 0.10;
        Inventory.MaxAmount 2147483647;
        Inventory.InterHubAmount 2147483647;
        Inventory.PickupSound "caelum/items/pickup";
        Ammo.BackpackAmount 20;
        Ammo.BackpackMaxAmount 2147483647;
        +INVENTORY.INVBAR
    }

    virtual int GetAmmoType()
    {
        return CaelumConstants.AMMUNITION_CARBINE;
    }

    virtual double GetUnitWeight()
    {
        return CaelumConstants.CARBINE_AMMO_UNIT_WEIGHT;
    }

    double GetCarriedWeight()
    {
        // El peso reducido compartido de la Caja Mágica pertenece al resumen
        // agregado del jugador, no a esta pila individual.
        return InMagicBox ? 0.0 : Amount * GetUnitWeight();
    }

    override void Tick()
    {
        Super.Tick();
        if (Owner != null) { return; }
        String visual = "CCAA";
        int ammoType = GetAmmoType();
        if(ammoType==CaelumConstants.AMMUNITION_CARBINE)Scale=(0.10,0.10);
        if (ammoType == CaelumConstants.AMMUNITION_ARROW) visual = "CARR";
        else if (ammoType == CaelumConstants.AMMUNITION_BOLT) visual = "CBOL";
        else if (ammoType >= CaelumConstants.AMMUNITION_JAVELIN_TIER_ONE)
            visual = "CJAV";
        sprite = GetSpriteIndex(visual);
        frame = 0;
    }

    override bool HandlePickup(Inventory item)
    {
        CaelumCarbineAmmo incoming = CaelumCarbineAmmo(item);
        if (incoming != null)
        {
            CaelumPlayer caelumPlayer = CaelumPlayer(Owner);
            if (caelumPlayer != null
                && !caelumPlayer.PrepareNativeAmmoStackPickup(
                    self, incoming.Amount
                ))
            {
                return true;
            }
        }
        return Super.HandlePickup(item);
    }

    override bool TryPickup(in out Actor toucher)
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(toucher);
        if (caelumPlayer == null
            || !caelumPlayer.PrepareNativeAmmoPickup(self))
        {
            return false;
        }
        Name itemClass=GetClassName();
        let previousStack=caelumPlayer.FindInventory(itemClass);
        int previous=previousStack==null ? 0 : previousStack.Amount;
        bool pickedUp = Super.TryPickup(toucher);
        if (pickedUp)
        {
            caelumPlayer.OnNativeInventoryChanged();
            let received=caelumPlayer.FindInventory(itemClass);
            CaelumNotifications.Acquired(caelumPlayer,received,
                received==null ? 0 : received.Amount-previous);
        }
        return pickedUp;
    }

    override Inventory CreateCopy(Actor other)
    {
        CaelumCarbineAmmo copy = CaelumCarbineAmmo(Super.CreateCopy(other));
        if (copy != null && copy != self) { copy.InMagicBox = InMagicBox; }
        return copy;
    }

    States
    {
    Spawn:
        CCAA A -1;
        Stop;
    }
}

class CaelumArrowAmmo : Ammo
{
    override String PickupMessage() { return ""; }

    override bool TryPickup(in out Actor toucher)
    {
        let user=CaelumPlayer(toucher);
        if (user==null) return false;
        Name itemClass=GetClassName();
        let previousStack=user.FindInventory(itemClass);
        int previous=previousStack==null ? 0 : previousStack.Amount;
        bool received=Super.TryPickup(toucher);
        if (received)
        {
            let acquired=user.FindInventory(itemClass);
            CaelumNotifications.Acquired(user,acquired,acquired==null ? 0 : acquired.Amount-previous);
        }
        return received;
    }

    Default
    {
        Inventory.Icon "graphics/caelum/icons/ca_arrow_ammo.png";
        Inventory.Amount 20;
        Scale 0.10;
        Inventory.MaxAmount 2147483647;
        Inventory.InterHubAmount 2147483647;
        Inventory.PickupSound "caelum/items/pickup";
        Ammo.BackpackAmount 20;
        Ammo.BackpackMaxAmount 2147483647;
        +INVENTORY.INVBAR
    }
    States { Spawn: CARR A -1; Stop; }
}

class CaelumBoltAmmo : Ammo
{
    override String PickupMessage() { return ""; }

    override bool TryPickup(in out Actor toucher)
    {
        let user=CaelumPlayer(toucher);
        if (user==null) return false;
        Name itemClass=GetClassName();
        let previousStack=user.FindInventory(itemClass);
        int previous=previousStack==null ? 0 : previousStack.Amount;
        bool received=Super.TryPickup(toucher);
        if (received)
        {
            let acquired=user.FindInventory(itemClass);
            CaelumNotifications.Acquired(user,acquired,acquired==null ? 0 : acquired.Amount-previous);
        }
        return received;
    }

    Default
    {
        Inventory.Icon "graphics/caelum/icons/ca_bolt_ammo.png";
        Inventory.Amount 20;
        Scale 0.10;
        Inventory.MaxAmount 2147483647;
        Inventory.InterHubAmount 2147483647;
        Inventory.PickupSound "caelum/items/pickup";
        Ammo.BackpackAmount 20;
        Ammo.BackpackMaxAmount 2147483647;
        +INVENTORY.INVBAR
    }
    States { Spawn: CBOL A -1; Stop; }
}

// Las jabalinas arrojables usan pilas nativas separadas por tier.
// Para estas pilas evitamos depender de la ruta genérica de Ammo al recoger:
// el actor del mundo entrega explícitamente sus unidades a la pila del jugador
// y sólo se destruye después de verificar que la transferencia fue exitosa.
class CaelumJavelinAmmo : CaelumCarbineAmmo
{
    override bool TryPickup(in out Actor toucher)
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(toucher);
        if (caelumPlayer == null) { return false; }

        int incomingAmount = Max(1, Amount);
        if (!caelumPlayer.AcquireJavelinAmmunition(
            GetAmmoType(), incomingAmount
        ))
        {
            return false;
        }

        // La transferencia ya creó/aumentó la pila nativa; este actor sólo
        // representa las unidades que estaban físicamente en el suelo.
        A_StartSound("caelum/items/pickup", CHAN_ITEM);
        Destroy();
        return true;
    }
}

class CaelumJavelinTierOneAmmo : CaelumJavelinAmmo
{
    Default
    {
        Inventory.Icon "graphics/caelum/icons/ca_javelin.png";
        // Cada proyectil recuperado crea exactamente una unidad recogible.
        Inventory.Amount 1;
    }
    override int GetAmmoType()
    {
        return CaelumConstants.AMMUNITION_JAVELIN_TIER_ONE;
    }

    override double GetUnitWeight()
    {
        return CaelumConstants.JAVELIN_TIER_ONE_AMMO_UNIT_WEIGHT;
    }

    States
    {
    Spawn:
        CJAV A -1;
        Stop;
    }
}

class CaelumJavelinTierTwoAmmo : CaelumJavelinAmmo
{
    Default
    {
        Inventory.Icon "graphics/caelum/icons/ca_javelin_t2.png";
        // Cada proyectil recuperado crea exactamente una unidad recogible.
        Inventory.Amount 1;
    }
    override int GetAmmoType()
    {
        return CaelumConstants.AMMUNITION_JAVELIN_TIER_TWO;
    }

    override double GetUnitWeight()
    {
        return CaelumConstants.JAVELIN_TIER_TWO_AMMO_UNIT_WEIGHT;
    }

    States
    {
    Spawn:
        CJAV A -1;
        Stop;
    }
}

class CaelumJavelinTierThreeAmmo : CaelumJavelinAmmo
{
    Default
    {
        Inventory.Icon "graphics/caelum/icons/ca_javelin_t3.png";
        // Cada proyectil recuperado crea exactamente una unidad recogible.
        Inventory.Amount 1;
    }
    override int GetAmmoType()
    {
        return CaelumConstants.AMMUNITION_JAVELIN_TIER_THREE;
    }

    override double GetUnitWeight()
    {
        return CaelumConstants.JAVELIN_TIER_THREE_AMMO_UNIT_WEIGHT;
    }

    States
    {
    Spawn:
        CJAV A -1;
        Stop;
    }
}
