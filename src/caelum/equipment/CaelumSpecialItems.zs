// Materiales y objetos clave usan Inventory nativo. La categoria se conserva
// en la clase y la ubicacion en la instancia, igual que el resto del sistema.
class CaelumSpecialInventoryItem : Inventory
{
    bool InMagicBox;

    Default
    {
        Radius 12;
        Height 8;
        // Sólo reduce el sprite del actor en el suelo; el icono de inventario conserva su tamaño.
        Scale 0.25;
        Inventory.Amount 1;
        Inventory.MaxAmount 1;
        Inventory.InterHubAmount 1;
        Inventory.PickupSound "caelum/items/pickup";
        // Materiales y objetos clave se gestionan desde la interfaz propia.
        // La barra nativa reserva su selección para consumibles y munición.
        -INVENTORY.INVBAR
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
        Inventory.Icon "graphics/caelum/icons/materials/ca_material_blade.png";
        Inventory.PickupMessage "$CA_PICKUP_MATERIAL_GENERIC";
        Inventory.MaxAmount 2147483647;
        Inventory.InterHubAmount 2147483647;
    }

    override int GetSpecialCategory()
    {
        return CaelumConstants.EQUIPMENT_KIND_MATERIAL;
    }

    override double GetUnitWeight()
    {
        return CaelumConstants.MATERIAL_UNIT_WEIGHT;
    }

    override int GetSpecialType()
    {
        return Clamp(args[0], 0, CaelumConstants.MATERIAL_TYPE_COUNT - 1);
    }

    override int GetSpecialTier()
    {
        return CaelumMaterialRules.ResolveTier(GetSpecialType(), args[1]);
    }

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        // MAP01 usa arg2 únicamente para las pilas masivas de prueba. Los
        // pickups creados por código siguen asignando Amount directamente.
        if (Owner == null && args[2] > 0)
        {
            Amount = Clamp(args[2], 1, 2147483647);
        }
    }

    // Cada material conserva una sola clase nativa y resuelve su arte desde
    // args[0]. Esto evita crear una subclase por componente de crafteo.
    static String GetMaterialIconPathForType(int materialType)
    {
        switch (materialType)
        {
            case CaelumConstants.MATERIAL_IRON_INGOT: return "graphics/caelum/icons/materials/ca_material_iron_ingot.png";
            case CaelumConstants.MATERIAL_BLADE: return "graphics/caelum/icons/materials/ca_material_blade.png";
            case CaelumConstants.MATERIAL_SMALL_BLADE: return "graphics/caelum/icons/materials/ca_material_small_blade.png";
            case CaelumConstants.MATERIAL_CURVED_BLADE: return "graphics/caelum/icons/materials/ca_material_curved_blade.png";
            case CaelumConstants.MATERIAL_LONG_BLADE: return "graphics/caelum/icons/materials/ca_material_long_blade.png";
            case CaelumConstants.MATERIAL_BROAD_BLADE: return "graphics/caelum/icons/materials/ca_material_broad_blade.png";
            case CaelumConstants.MATERIAL_SHAFT: return "graphics/caelum/icons/materials/ca_material_shaft.png";
            case CaelumConstants.MATERIAL_FRAME: return "graphics/caelum/icons/materials/ca_material_frame.png";
            case CaelumConstants.MATERIAL_LONG_FRAME: return "graphics/caelum/icons/materials/ca_material_long_frame.png";
            case CaelumConstants.MATERIAL_WEAPON_HEAD: return "graphics/caelum/icons/materials/ca_material_weapon_head.png";
            case CaelumConstants.MATERIAL_ROUND_HEAD: return "graphics/caelum/icons/materials/ca_material_round_head.png";
            case CaelumConstants.MATERIAL_PLATE: return "graphics/caelum/icons/materials/ca_material_plate.png";
            case CaelumConstants.MATERIAL_ROUND_PLATE: return "graphics/caelum/icons/materials/ca_material_round_plate.png";
            case CaelumConstants.MATERIAL_KITE_PLATE: return "graphics/caelum/icons/materials/ca_material_kite_plate.png";
            case CaelumConstants.MATERIAL_TOWER_PLATE: return "graphics/caelum/icons/materials/ca_material_tower_plate.png";
            case CaelumConstants.MATERIAL_MAGIC_PLATE: return "graphics/caelum/icons/materials/ca_material_magic_plate.png";
            case CaelumConstants.MATERIAL_LARGE_PLATE: return "graphics/caelum/icons/materials/ca_material_large_plate.png";
            case CaelumConstants.MATERIAL_CHAINMAIL: return "graphics/caelum/icons/materials/ca_material_chainmail.png";
            case CaelumConstants.MATERIAL_FABRIC: return "graphics/caelum/icons/materials/ca_material_fabric.png";
            case CaelumConstants.MATERIAL_LEATHER: return "graphics/caelum/icons/materials/ca_material_leather.png";
            case CaelumConstants.MATERIAL_FIRE_ESSENCE: return "graphics/caelum/icons/materials/ca_material_fire_essence.png";
            case CaelumConstants.MATERIAL_WATER_ESSENCE: return "graphics/caelum/icons/materials/ca_material_water_essence.png";
            case CaelumConstants.MATERIAL_EARTH_ESSENCE: return "graphics/caelum/icons/materials/ca_material_earth_essence.png";
            case CaelumConstants.MATERIAL_WIND_ESSENCE: return "graphics/caelum/icons/materials/ca_material_wind_essence.png";
            case CaelumConstants.MATERIAL_QUINTESSENCE: return "graphics/caelum/icons/materials/ca_material_quintessence.png";
            case CaelumConstants.MATERIAL_HILT: return "graphics/caelum/icons/materials/ca_material_hilt.png";
            case CaelumConstants.MATERIAL_LONG_HILT: return "graphics/caelum/icons/materials/ca_material_long_hilt.png";
            case CaelumConstants.MATERIAL_POINT: return "graphics/caelum/icons/materials/ca_material_point.png";
            case CaelumConstants.MATERIAL_HANDLE: return "graphics/caelum/icons/materials/ca_material_handle.png";
            case CaelumConstants.MATERIAL_LONG_HANDLE: return "graphics/caelum/icons/materials/ca_material_long_handle.png";
            case CaelumConstants.MATERIAL_BOWSTRING: return "graphics/caelum/icons/materials/ca_material_bowstring.png";
            case CaelumConstants.MATERIAL_REINFORCED_BOWSTRING: return "graphics/caelum/icons/materials/ca_material_reinforced_bowstring.png";
            case CaelumConstants.MATERIAL_STRAP: return "graphics/caelum/icons/materials/ca_material_strap.png";
            case CaelumConstants.MATERIAL_REINFORCED_STRAP: return "graphics/caelum/icons/materials/ca_material_reinforced_strap.png";
            case CaelumConstants.MATERIAL_BARREL: return "graphics/caelum/icons/materials/ca_material_barrel.png";
            case CaelumConstants.MATERIAL_MECHANISM: return "graphics/caelum/icons/materials/ca_material_mechanism.png";
            // El objeto base de un arma de esencia usa el mismo arte del arma.
            case CaelumConstants.MATERIAL_STAFF_BASE: return "graphics/caelum/icons/ca_staff.png";
            case CaelumConstants.MATERIAL_BELL_BASE: return "graphics/caelum/icons/ca_bell.png";
            case CaelumConstants.MATERIAL_BOOK_BASE: return "graphics/caelum/icons/ca_book.png";
            case CaelumConstants.MATERIAL_STATUETTE_BASE: return "graphics/caelum/icons/ca_statuette.png";
            case CaelumConstants.MATERIAL_SMALL_WEAPON_HEAD: return "graphics/caelum/icons/materials/ca_material_small_weapon_head.png";
            case CaelumConstants.MATERIAL_CHAIN: return "graphics/caelum/icons/materials/ca_material_chain.png";
            case CaelumConstants.MATERIAL_SILVER_CHAIN: return "graphics/caelum/icons/materials/ca_material_silver_chain.png";
            case CaelumConstants.MATERIAL_SEAL_BASE: return "graphics/caelum/icons/materials/ca_material_seal_base.png";
            case CaelumConstants.MATERIAL_RUBY_PENDANT: return "graphics/caelum/icons/materials/ca_material_ruby_pendant.png";
            case CaelumConstants.MATERIAL_SAPPHIRE_PENDANT: return "graphics/caelum/icons/materials/ca_material_sapphire_pendant.png";
            case CaelumConstants.MATERIAL_EMERALD_PENDANT: return "graphics/caelum/icons/materials/ca_material_emerald_pendant.png";
            case CaelumConstants.MATERIAL_TOPAZ_PENDANT: return "graphics/caelum/icons/materials/ca_material_topaz_pendant.png";
            case CaelumConstants.MATERIAL_RUBY_GEM: return "graphics/caelum/icons/materials/ca_material_ruby_gem.png";
            case CaelumConstants.MATERIAL_SAPPHIRE_GEM: return "graphics/caelum/icons/materials/ca_material_sapphire_gem.png";
            case CaelumConstants.MATERIAL_EMERALD_GEM: return "graphics/caelum/icons/materials/ca_material_emerald_gem.png";
            case CaelumConstants.MATERIAL_TOPAZ_GEM: return "graphics/caelum/icons/materials/ca_material_topaz_gem.png";
            case CaelumConstants.MATERIAL_OPAL_BROOCH: return "graphics/caelum/icons/materials/ca_material_opal_brooch.png";
            case CaelumConstants.MATERIAL_RAW_RUBY: return "graphics/caelum/icons/materials/ca_material_raw_ruby.png";
            case CaelumConstants.MATERIAL_RAW_SAPPHIRE: return "graphics/caelum/icons/materials/ca_material_raw_sapphire.png";
            case CaelumConstants.MATERIAL_RAW_EMERALD: return "graphics/caelum/icons/materials/ca_material_raw_emerald.png";
            case CaelumConstants.MATERIAL_RAW_TOPAZ: return "graphics/caelum/icons/materials/ca_material_raw_topaz.png";
            case CaelumConstants.MATERIAL_RAW_OPAL: return "graphics/caelum/icons/materials/ca_material_raw_opal.png";
            case CaelumConstants.MATERIAL_COPPER_INGOT: return "graphics/caelum/icons/materials/ca_material_copper_ingot.png";
            case CaelumConstants.MATERIAL_TIN_INGOT: return "graphics/caelum/icons/materials/ca_material_tin_ingot.png";
            case CaelumConstants.MATERIAL_COAL: return "graphics/caelum/icons/materials/ca_material_coal.png";
            case CaelumConstants.MATERIAL_RAW_COPPER: return "graphics/caelum/icons/materials/ca_material_raw_copper.png";
            case CaelumConstants.MATERIAL_RAW_TIN: return "graphics/caelum/icons/materials/ca_material_raw_tin.png";
            case CaelumConstants.MATERIAL_RAW_IRON: return "graphics/caelum/icons/materials/ca_material_raw_iron.png";
            case CaelumConstants.MATERIAL_RAW_SILVER: return "graphics/caelum/icons/materials/ca_material_raw_silver.png";
            case CaelumConstants.MATERIAL_RAW_GOLD: return "graphics/caelum/icons/materials/ca_material_raw_gold.png";
            case CaelumConstants.MATERIAL_BRONZE_INGOT: return "graphics/caelum/icons/materials/ca_material_bronze_ingot.png";
            case CaelumConstants.MATERIAL_STEEL_INGOT: return "graphics/caelum/icons/materials/ca_material_steel_ingot.png";
            case CaelumConstants.MATERIAL_SILVER_INGOT: return "graphics/caelum/icons/materials/ca_material_silver_ingot.png";
            case CaelumConstants.MATERIAL_GOLD_INGOT: return "graphics/caelum/icons/materials/ca_material_gold_ingot.png";
            case CaelumConstants.MATERIAL_WOOL: return "graphics/caelum/icons/materials/ca_material_wool.png";
            case CaelumConstants.MATERIAL_COTTON: return "graphics/caelum/icons/materials/ca_material_cotton.png";
            case CaelumConstants.MATERIAL_RAW_SILK: return "graphics/caelum/icons/materials/ca_material_raw_silk.png";
            case CaelumConstants.MATERIAL_PLANT_FIBER: return "graphics/caelum/icons/materials/ca_material_plant_fiber.png";
            case CaelumConstants.MATERIAL_ROPE: return "graphics/caelum/icons/materials/ca_material_rope.png";
            case CaelumConstants.MATERIAL_COW_HIDE: return "graphics/caelum/icons/materials/ca_material_cow_hide.png";
            case CaelumConstants.MATERIAL_PREDATOR_HIDE: return "graphics/caelum/icons/materials/ca_material_predator_hide.png";
            case CaelumConstants.MATERIAL_MONSTER_HIDE: return "graphics/caelum/icons/materials/ca_material_monster_hide.png";
            default: return "graphics/caelum/icons/materials/ca_material_wood.png";
        }
    }

    String GetMaterialIconPath()
    {
        return GetMaterialIconPathForType(GetSpecialType());
    }

    String GetMaterialSpriteName()
    {
        switch (GetSpecialType())
        {
            case CaelumConstants.MATERIAL_STAFF_BASE: return "CSTF";
            case CaelumConstants.MATERIAL_BELL_BASE: return "CBEL";
            case CaelumConstants.MATERIAL_BOOK_BASE: return "CBOO";
            case CaelumConstants.MATERIAL_STATUETTE_BASE: return "CSTA";
            default: return String.Format("M%03d", GetSpecialType());
        }
    }

    void UpdateMaterialVisuals()
    {
        Icon = TexMan.CheckForTexture(GetMaterialIconPath(), TexMan.Type_MiscPatch);
        if (Owner == null)
        {
            // Todos los alias usan ahora los maestros 128x128 canónicos.
            // La escala única preserva aproximadamente el tamaño anterior.
            Scale.X = 0.25;
            Scale.Y = 0.25;
            sprite = GetSpriteIndex(GetMaterialSpriteName());
            frame = 0;
        }
    }

    override void Tick()
    {
        Super.Tick();
        UpdateMaterialVisuals();
    }

    override bool TryPickup(in out Actor toucher)
    {
        UpdateMaterialVisuals();
        return Super.TryPickup(toucher);
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

    States
    {
    Spawn:
        M001 A -1;
        Stop;

    // Catálogo no ejecutado: fuerza a GZDoom a registrar los nombres de
    // sprite que luego seleccionamos dinámicamente con GetSpriteIndex().
    VisualRegistry:
        M043 A 0;
        M044 A 0;
        M045 A 0;
        M046 A 0;
        M047 A 0;
        M048 A 0;
        M049 A 0;
        M050 A 0;
        M051 A 0;
        M052 A 0;
        M053 A 0;
        M054 A 0;
        M055 A 0;
        M056 A 0;
        M057 A 0;
        M058 A 0;
        M059 A 0;
        M060 A 0;
        M061 A 0;
        M062 A 0;
        M063 A 0;
        M064 A 0;
        M065 A 0;
        M066 A 0;
        M067 A 0;
        M068 A 0;
        M069 A 0;
        M070 A 0;
        M071 A 0;
        M072 A 0;
        M073 A 0;
        M074 A 0;
        M075 A 0;
        M076 A 0;
        M077 A 0;
        M078 A 0;
        Stop;
    }
}

// Las familias determinan si el tier representa metal, madera, esencia,
// cuero o tejido. Los componentes secundarios son genericos y usan tier 1.
class CaelumMaterialRules : Object
{
    static int GetFamily(int materialType)
    {
        if (materialType == CaelumConstants.MATERIAL_IRON_INGOT
            || (materialType >= CaelumConstants.MATERIAL_COPPER_INGOT
                && materialType <= CaelumConstants.MATERIAL_TIN_INGOT)
            || (materialType >= CaelumConstants.MATERIAL_BRONZE_INGOT
                && materialType <= CaelumConstants.MATERIAL_GOLD_INGOT)
            || (materialType >= CaelumConstants.MATERIAL_BLADE
                && materialType <= CaelumConstants.MATERIAL_BROAD_BLADE)
            || (materialType >= CaelumConstants.MATERIAL_WEAPON_HEAD
                && materialType <= CaelumConstants.MATERIAL_CHAINMAIL)
            || materialType == CaelumConstants.MATERIAL_POINT
            || materialType == CaelumConstants.MATERIAL_BARREL
            || materialType == CaelumConstants.MATERIAL_MECHANISM
            || materialType == CaelumConstants.MATERIAL_BELL_BASE
            || materialType == CaelumConstants.MATERIAL_SMALL_WEAPON_HEAD
            || materialType == CaelumConstants.MATERIAL_CHAIN
            || materialType == CaelumConstants.MATERIAL_SEAL_BASE)
        {
            return CaelumConstants.MATERIAL_FAMILY_METAL;
        }
        if ((materialType >= CaelumConstants.MATERIAL_SHAFT
                && materialType <= CaelumConstants.MATERIAL_LONG_FRAME)
            || materialType == CaelumConstants.MATERIAL_HILT
            || materialType == CaelumConstants.MATERIAL_LONG_HILT
            || materialType == CaelumConstants.MATERIAL_HANDLE
            || materialType == CaelumConstants.MATERIAL_LONG_HANDLE
            || materialType == CaelumConstants.MATERIAL_STAFF_BASE
            || materialType == CaelumConstants.MATERIAL_STATUETTE_BASE
            || materialType == CaelumConstants.MATERIAL_WOOD)
        {
            return CaelumConstants.MATERIAL_FAMILY_WOOD;
        }
        if (materialType >= CaelumConstants.MATERIAL_FIRE_ESSENCE
            && materialType <= CaelumConstants.MATERIAL_QUINTESSENCE)
        {
            return CaelumConstants.MATERIAL_FAMILY_ESSENCE;
        }
        if (materialType == CaelumConstants.MATERIAL_LEATHER
            || materialType == CaelumConstants.MATERIAL_STRAP
            || materialType == CaelumConstants.MATERIAL_REINFORCED_STRAP)
        {
            return CaelumConstants.MATERIAL_FAMILY_LEATHER;
        }
        if (materialType == CaelumConstants.MATERIAL_FABRIC
            || materialType == CaelumConstants.MATERIAL_BOWSTRING
            || materialType == CaelumConstants.MATERIAL_REINFORCED_BOWSTRING
            || materialType == CaelumConstants.MATERIAL_BOOK_BASE)
        {
            return CaelumConstants.MATERIAL_FAMILY_FABRIC;
        }
        if (materialType >= CaelumConstants.MATERIAL_RUBY_PENDANT
            && materialType <= CaelumConstants.MATERIAL_RAW_OPAL)
        {
            return CaelumConstants.MATERIAL_FAMILY_GEM;
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
        Inventory.Icon "graphics/caelum/icons/materials/ca_material_iron_ingot.png";
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

    override double GetUnitWeight()
    {
        // Compatibilidad: aunque esté oculto, sigue siendo un material.
        return CaelumConstants.MATERIAL_UNIT_WEIGHT;
    }

    States { Spawn: M000 A -1; Stop; }
}

// Los objetos clave comunes son unicos y pueden guardarse en la Caja Magica.
// Las futuras piezas de puzzle consumibles pueden derivar de PuzzleItem.
class CaelumSealedLetter : CaelumSpecialInventoryItem
{
    Default
    {
        Tag "$CA_KEY_ITEM_SEALED_LETTER";
        Inventory.Icon "graphics/caelum/icons/ca_sealed_letter.png";
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

    States { Spawn: CSEL A -1; Stop; }
}

// El manual del tutorial conserva el conocimiento en el perfil, no en el
// mapa. Recogerlo una vez abre las catorce transformaciones básicas.
class CaelumProcessingManual : CaelumSpecialInventoryItem
{
    Default
    {
        Tag "$CA_KEY_ITEM_PROCESSING_MANUAL";
        Inventory.Icon "graphics/caelum/icons/ca_book.png";
        Inventory.PickupMessage "$CA_PICKUP_KEY_ITEM_PROCESSING_MANUAL";
    }

    override int GetSpecialCategory()
    {
        return CaelumConstants.EQUIPMENT_KIND_KEY_ITEM;
    }

    override int GetSpecialType()
    {
        return CaelumConstants.KEY_ITEM_PROCESSING_MANUAL;
    }

    override bool TryPickup(in out Actor toucher)
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(toucher);
        bool pickedUp = Super.TryPickup(toucher);
        if (pickedUp && caelumPlayer != null)
        {
            caelumPlayer.LearnAllProcessingRecipes();
        }
        return pickedUp;
    }

    States { Spawn: CBOO A -1; Stop; }
}

// Key conserva la comprobacion nativa de puertas y acciones LOCKDEFS. Por esa
// razon estas instancias no entran en la Caja Magica: el motor solo comprueba
// posesion y no conoce la ubicacion interna definida por Caelum.
class CaelumWeightedKey : Key
{
    Default { Inventory.Icon "graphics/caelum/icons/ca_key.png"; }
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
        Inventory.Icon "graphics/caelum/icons/ca_key.png";
        Inventory.PickupMessage "$CA_PICKUP_KEY_SILVER";
        // Sólo el actor de mundo se reduce; el icono conserva resolución.
        Scale 0.125;
    }

    override int GetKeyType()
    {
        return CaelumConstants.KEY_SILVER;
    }

    States { Spawn: CKEY A -1; Stop; }
}
