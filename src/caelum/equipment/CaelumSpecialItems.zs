// Materiales y objetos clave usan Inventory nativo. La categoria se conserva
// en la clase y la ubicacion en la instancia, igual que el resto del sistema.
class CaelumSpecialInventoryItem : Inventory
{
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

    virtual int GetSpecialCategory() { return -1; }
    virtual int GetSpecialType() { return -1; }
    virtual int GetSpecialTier() { return 0; }
    virtual double GetUnitWeight()
    {
        return CaelumConstants.SPECIAL_ITEM_DEFAULT_WEIGHT;
    }

    double GetCarriedWeight()
    {
        return InMagicBox ? 0.0 : Amount * GetUnitWeight();
    }

    override bool TryPickup(in out Actor toucher)
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(toucher);
        if (caelumPlayer == null
            || !caelumPlayer.PrepareNativeSpecialPickup(self))
        {
            return false;
        }
        bool pickedUp = Super.TryPickup(toucher);
        if (pickedUp) { caelumPlayer.OnNativeInventoryChanged(); }
        return pickedUp;
    }

    override Inventory CreateCopy(Actor other)
    {
        CaelumSpecialInventoryItem copy = CaelumSpecialInventoryItem(
            Super.CreateCopy(other)
        );
        if (copy != null && copy != self)
        {
            copy.InMagicBox = InMagicBox;
            copy.args[0] = args[0];
            copy.args[1] = args[1];
        }
        return copy;
    }

    override Inventory CreateTossable(int tossAmount)
    {
        CaelumSpecialInventoryItem copy = CaelumSpecialInventoryItem(
            Super.CreateTossable(tossAmount)
        );
        if (copy != null && copy != self)
        {
            copy.InMagicBox = InMagicBox;
            copy.args[0] = args[0];
            copy.args[1] = args[1];
        }
        return copy;
    }
}

// El catalogo comparte una unica clase nativa, pero cada instancia conserva
// su tipo y tier en args. HandlePickup solo combina pilas identicas.
class CaelumMaterialPickup : CaelumSpecialInventoryItem
{
    Default
    {
        Tag "$CA_MATERIAL_GENERIC";
        Inventory.Icon "CELPA0";
        Inventory.PickupMessage "$CA_PICKUP_MATERIAL_GENERIC";
        Inventory.MaxAmount 2147483647;
        Inventory.InterHubAmount 2147483647;
    }

    override int GetSpecialCategory()
    {
        return CaelumConstants.EQUIPMENT_KIND_MATERIAL;
    }

    override int GetSpecialType()
    {
        return Clamp(args[0], 1, CaelumConstants.MATERIAL_TYPE_COUNT - 1);
    }

    override int GetSpecialTier()
    {
        return CaelumMaterialRules.ResolveTier(GetSpecialType(), args[1]);
    }

    override bool HandlePickup(Inventory incoming)
    {
        CaelumMaterialPickup material = CaelumMaterialPickup(incoming);
        if (material == null
            || material.GetSpecialType() != GetSpecialType()
            || material.GetSpecialTier() != GetSpecialTier())
        {
            return false;
        }
        if (Amount < MaxAmount
            || (sv_unlimited_pickup && !incoming.ShouldStay()))
        {
            if (Amount > 0 && Amount + incoming.Amount < 0)
            {
                Amount = 2147483647;
            }
            else
            {
                Amount += incoming.Amount;
            }
            if (Amount > MaxAmount && !sv_unlimited_pickup)
            {
                Amount = MaxAmount;
            }
            incoming.bPickupGood = true;
        }
        return true;
    }

    States { Spawn: CELP A -1; Stop; }
}

// Las familias determinan si el tier representa metal, madera, esencia,
// cuero o tejido. Los componentes secundarios son genericos y usan tier 1.
class CaelumMaterialRules : Object
{
    static int GetFamily(int materialType)
    {
        if (materialType == CaelumConstants.MATERIAL_IRON_INGOT
            || (materialType >= CaelumConstants.MATERIAL_BLADE
                && materialType <= CaelumConstants.MATERIAL_BROAD_BLADE)
            || (materialType >= CaelumConstants.MATERIAL_WEAPON_HEAD
                && materialType <= CaelumConstants.MATERIAL_CHAINMAIL)
            || materialType == CaelumConstants.MATERIAL_BARREL)
        {
            return CaelumConstants.MATERIAL_FAMILY_METAL;
        }
        if (materialType >= CaelumConstants.MATERIAL_SHAFT
            && materialType <= CaelumConstants.MATERIAL_LONG_FRAME)
        {
            return CaelumConstants.MATERIAL_FAMILY_WOOD;
        }
        if (materialType >= CaelumConstants.MATERIAL_FIRE_ESSENCE
            && materialType <= CaelumConstants.MATERIAL_QUINTESSENCE)
        {
            return CaelumConstants.MATERIAL_FAMILY_ESSENCE;
        }
        if (materialType == CaelumConstants.MATERIAL_LEATHER)
        {
            return CaelumConstants.MATERIAL_FAMILY_LEATHER;
        }
        if (materialType == CaelumConstants.MATERIAL_FABRIC)
        {
            return CaelumConstants.MATERIAL_FAMILY_FABRIC;
        }
        return CaelumConstants.MATERIAL_FAMILY_NONE;
    }

    static bool HasTier(int materialType)
    {
        return GetFamily(materialType) != CaelumConstants.MATERIAL_FAMILY_NONE;
    }

    static int ResolveTier(int materialType, int requestedTier)
    {
        return HasTier(materialType) ? Clamp(requestedTier, 1, 3) : 1;
    }
}

// Primera entrada de prueba del catalogo. MaxAmount mantiene una unica pila
// aunque contenga cualquier cantidad de unidades.
class CaelumIronIngot : CaelumSpecialInventoryItem
{
    Default
    {
        Tag "$CA_MATERIAL_IRON_INGOT";
        Inventory.Icon "CELPA0";
        Inventory.PickupMessage "$CA_PICKUP_MATERIAL_IRON_INGOT";
        Inventory.MaxAmount 2147483647;
        Inventory.InterHubAmount 2147483647;
    }

    override int GetSpecialCategory()
    {
        return CaelumConstants.EQUIPMENT_KIND_MATERIAL;
    }

    override int GetSpecialType()
    {
        return CaelumConstants.MATERIAL_IRON_INGOT;
    }

    override int GetSpecialTier() { return 2; }

    States { Spawn: CELP A -1; Stop; }
}

// Los objetos clave comunes son unicos y pueden guardarse en la Caja Magica.
// Las futuras piezas de puzzle consumibles pueden derivar de PuzzleItem.
class CaelumSealedLetter : CaelumSpecialInventoryItem
{
    Default
    {
        Tag "$CA_KEY_ITEM_SEALED_LETTER";
        Inventory.Icon "BPAKA0";
        Inventory.PickupMessage "$CA_PICKUP_KEY_ITEM_SEALED_LETTER";
    }

    override int GetSpecialCategory()
    {
        return CaelumConstants.EQUIPMENT_KIND_KEY_ITEM;
    }

    override int GetSpecialType()
    {
        return CaelumConstants.KEY_ITEM_SEALED_LETTER;
    }

    States { Spawn: BPAK A -1; Stop; }
}

// Key conserva la comprobacion nativa de puertas y acciones LOCKDEFS. Por esa
// razon estas instancias no entran en la Caja Magica: el motor solo comprueba
// posesion y no conoce la ubicacion interna definida por Caelum.
class CaelumWeightedKey : Key
{
    virtual int GetKeyType() { return -1; }

    double GetCarriedWeight()
    {
        return CaelumConstants.SPECIAL_ITEM_DEFAULT_WEIGHT;
    }

    override bool TryPickup(in out Actor toucher)
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(toucher);
        if (caelumPlayer == null
            || !caelumPlayer.PrepareNativeKeyPickup(self))
        {
            return false;
        }
        bool pickedUp = Super.TryPickup(toucher);
        if (pickedUp) { caelumPlayer.OnNativeInventoryChanged(); }
        return pickedUp;
    }
}

class CaelumSilverKey : CaelumWeightedKey
{
    Default
    {
        Tag "$CA_KEY_SILVER";
        Inventory.Icon "RKEYA0";
        Inventory.PickupMessage "$CA_PICKUP_KEY_SILVER";
    }

    override int GetKeyType()
    {
        return CaelumConstants.KEY_SILVER;
    }

    States { Spawn: RKEY A -1; Stop; }
}
