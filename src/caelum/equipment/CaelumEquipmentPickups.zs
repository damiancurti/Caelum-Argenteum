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
    double UnitWeight;
    bool Equipped;
    bool InMagicBox;

    Default
    {
        Radius 12;
        Height 8;
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
            copy.UnitWeight = UnitWeight;
            copy.Equipped = Equipped;
            copy.InMagicBox = InMagicBox;
        }
        return copy;
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
    States
    {
    Spawn:
        ARM1 A -1;
        Stop;
    }

    override bool TryPickup(in out Actor toucher)
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(toucher);
        if (caelumPlayer == null || caelumPlayer.ArmorModel == null) { return false; }
        EquipmentKind = CaelumConstants.EQUIPMENT_KIND_ARMOR;
        ArmorSlot = Clamp(args[0], 0, CaelumConstants.ARMOR_SLOT_COUNT - 1);
        ItemType = Clamp(
            args[1], 0, CaelumConstants.ARMOR_EQUIPPABLE_TYPE_COUNT - 1
        );
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
        return TryCaelumPickup(toucher);
    }
}

// args: tipo, tier, talle (1..5), durabilidad+1.
class CaelumShieldPickup : CaelumEquipmentItem
{
    States
    {
    Spawn:
        BON2 A -1;
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

// args: tipo, tier, talle (1..5), durabilidad+1.
class CaelumWeaponPickup : CaelumEquipmentItem
{
    Default
    {
        Inventory.PickupSound "misc/w_pkup";
    }

    States
    {
    Spawn:
        WPN2 A -1;
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
        CLIP A -1;
        Stop;
    }
}

class CaelumArrowAmmo : CaelumCarbineAmmo
{
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
        SHEL A -1;
        Stop;
    }
}

class CaelumBoltAmmo : CaelumCarbineAmmo
{
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
        SHEL A -1;
        Stop;
    }
}
