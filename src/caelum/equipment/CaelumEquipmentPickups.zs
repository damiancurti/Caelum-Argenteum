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

    Default
    {
        Radius 12;
        Height 8;
        // Escala visual del pickup en el mundo. Inventory.Icon no se altera.
        Scale 0.5;
        Inventory.Amount 1;
        Inventory.MaxAmount 1;
        Inventory.InterHubAmount 1;
        Inventory.PickupSound "misc/i_pkup";
        +INVENTORY.INVBAR
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

    double GetCarriedWeight()
    {
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
        if (caelumPlayer == null
            || !caelumPlayer.PrepareNativeEquipmentPickup(self))
        {
            return false;
        }
        bool pickedUp = Super.TryPickup(toucher);
        if (pickedUp) { caelumPlayer.OnNativeInventoryChanged(); }
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
        int slot = PickupDataInitialized
            ? ArmorSlot : Clamp(args[0], 0, CaelumConstants.ARMOR_SLOT_COUNT - 1);
        int armorType = PickupDataInitialized ? ItemType : args[1];
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
        CaelumPlayer caelumPlayer = CaelumPlayer(toucher);
        if (caelumPlayer == null || caelumPlayer.ArmorModel == null) { return false; }
        if (!PickupDataInitialized)
        {
            // Inicializa una sola vez los datos provenientes del actor del mundo.
            // Al volver a soltar una pieza, CreateCopy conserva estos valores y
            // evita reconstruirla desde args[] vacíos.
            EquipmentKind = CaelumConstants.EQUIPMENT_KIND_ARMOR;
            ArmorSlot = Clamp(args[0], 0, CaelumConstants.ARMOR_SLOT_COUNT - 1);
            ItemType = args[1];
            Tier = Clamp(args[2], 1, 3);
            EquipmentSize = args[3] <= 0
                ? CaelumConstants.EQUIPMENT_SIZE_M
                : Clamp(args[3] - 1, 0, CaelumConstants.EQUIPMENT_SIZE_COUNT - 1);
            Durability = args[4] > 0 ? args[4] - 1
                : caelumPlayer.ArmorModel.GetMaximumDurabilityFor(
                    ItemType, Tier, EquipmentSize
                );
            UnitWeight = caelumPlayer.ArmorModel.GetWeightFor(
                ArmorSlot, ItemType, Tier, EquipmentSize
            );
            Equipped = false;
            PickupDataInitialized = true;
        }
        return TryCaelumPickup(toucher);
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
        CaelumPlayer caelumPlayer = CaelumPlayer(toucher);
        if (caelumPlayer == null || caelumPlayer.ShieldModel == null) { return false; }
        EquipmentKind = CaelumConstants.EQUIPMENT_KIND_SHIELD;
        ArmorSlot = -1;
        ItemType = Clamp(args[0], 0, CaelumConstants.SHIELD_TYPE_COUNT - 1);
        Tier = Clamp(args[1], 1, 3);
        EquipmentSize = args[2] <= 0
            ? CaelumConstants.EQUIPMENT_SIZE_M
            : Clamp(args[2] - 1, 0, CaelumConstants.EQUIPMENT_SIZE_COUNT - 1);
        Durability = args[3] > 0 ? args[3] - 1
            : caelumPlayer.ShieldModel.GetMaximumDurabilityFor(
                ItemType, Tier, EquipmentSize
            );
        UnitWeight = caelumPlayer.ShieldModel.GetWeightFor(
            ItemType, Tier, EquipmentSize
        );
        Equipped = false;
        return TryCaelumPickup(toucher);
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
        Inventory.PickupSound "misc/w_pkup";
    }

    States
    {
    Spawn:
        CSWD A -1;
        Stop;
    }

    override bool TryPickup(in out Actor toucher)
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(toucher);
        if (caelumPlayer == null || caelumPlayer.WeaponModel == null) { return false; }
        EquipmentKind = CaelumConstants.EQUIPMENT_KIND_WEAPON;
        ArmorSlot = -1;
        ItemType = Clamp(args[0], 0, CaelumConstants.WEAPON_TYPE_COUNT - 1);
        Tier = Clamp(args[1], 1, 3);
        EquipmentSize = args[2] <= 0
            ? CaelumConstants.EQUIPMENT_SIZE_M
            : Clamp(args[2] - 1, 0, CaelumConstants.EQUIPMENT_SIZE_COUNT - 1);
        Durability = args[3] > 0 ? args[3] - 1
            : caelumPlayer.WeaponModel.GetMaximumDurabilityFor(
                ItemType, Tier, EquipmentSize
            );
        EssenceType = args[4] > 0
            ? Clamp(args[4] - 1, 0, CaelumConstants.ESSENCE_TYPE_COUNT - 1)
            : CaelumConstants.ESSENCE_FIRE;
        UnitWeight = caelumPlayer.WeaponModel.GetWeightFor(
            ItemType, Tier, EquipmentSize
        );
        Equipped = false;
        return TryCaelumPickup(toucher);
    }
}

// Toda la pila ocupa un único slot de Caja Mágica. Fuera de ella cada bala
// pesa 0,003; dentro, la pila completa pesa cero sin importar Amount.
class CaelumCarbineAmmo : Ammo
{
    bool InMagicBox;

    Default
    {
        Inventory.Icon "graphics/caelum/icons/ca_carbine_ammo.png";
        Scale 0.5;
        Inventory.MaxAmount 2147483647;
        Inventory.InterHubAmount 2147483647;
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
        return InMagicBox ? 0.0 : Amount * GetUnitWeight();
    }

    override void Tick()
    {
        Super.Tick();
        if (Owner != null) { return; }
        String visual = "CCAA";
        int ammoType = GetAmmoType();
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
        bool pickedUp = Super.TryPickup(toucher);
        if (pickedUp) { caelumPlayer.OnNativeInventoryChanged(); }
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

class CaelumArrowAmmo : CaelumCarbineAmmo
{
    Default { Inventory.Icon "graphics/caelum/icons/ca_arrow_ammo.png"; }
    override int GetAmmoType()
    {
        return CaelumConstants.AMMUNITION_ARROW;
    }

    override double GetUnitWeight()
    {
        return CaelumConstants.ARROW_AMMO_UNIT_WEIGHT;
    }

    States
    {
    Spawn:
        CARR A -1;
        Stop;
    }
}

class CaelumBoltAmmo : CaelumCarbineAmmo
{
    Default { Inventory.Icon "graphics/caelum/icons/ca_bolt_ammo.png"; }
    override int GetAmmoType()
    {
        return CaelumConstants.AMMUNITION_BOLT;
    }

    override double GetUnitWeight()
    {
        return CaelumConstants.BOLT_AMMO_UNIT_WEIGHT;
    }

    States
    {
    Spawn:
        CBOL A -1;
        Stop;
    }
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
        A_StartSound("misc/w_pkup", CHAN_ITEM);
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
        Inventory.Icon "graphics/caelum/icons/ca_javelin.png";
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
        Inventory.Icon "graphics/caelum/icons/ca_javelin.png";
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
