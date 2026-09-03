// Registro invisible que viaja en el inventario real de GZDoom.
// Conserva el perfil confirmado, los recursos y la propiedad del equipo entre
// mapas sin convertir los controles temporales en objetos visibles todavia.
class CaelumPersistentCharacterState : Inventory
{
    bool ProfileCommitted;
    int Race;
    int FirstClass;
    int SecondClass;
    int Sex;
    int HeightChoice;
    int LayerBonus[4];
    int AttributeBonus[12];

    bool EquipmentInitialized;
    int ArmorType[4];
    int ArmorTier[4];
    int ArmorSize[4];
    int ArmorDurability[4];
    int ArmorSelectedSlot;
    int ShieldType;
    int ShieldTier;
    int ShieldSize;
    int ShieldDurability;
    bool ShieldEquipped;
    int WeaponType;
    int WeaponTier;
    int WeaponSize;
    int WeaponDurability;
    int WeaponEssenceType;
    bool WeaponEquipped;
    bool WeaponEquipmentInitialized;
    double EquippedWeaponBaseWeight;
    int EquippedWeaponTier;
    int EquippedWeaponSize;
    bool OwnedArmor[48];
    bool OwnedShield[12];
    int OwnedArmorDurability[48];
    int OwnedShieldDurability[12];
    bool OwnershipDurabilityInitialized;
    // Los registros antiguos se conservan para migrar partidas 4.5 al talle M.
    bool SizedOwnedArmor[300];
    bool SizedOwnedShield[60];
    bool SizedOwnedWeapon[300];
    int SizedOwnedArmorDurability[300];
    int SizedOwnedShieldDurability[60];
    int SizedOwnedWeaponDurability[300];
    int SizedWeaponEssenceType[300];
    bool EquipmentSizeInitialized;
    bool WeaponWeightInitialized;
    // false significa que el objeto viaja con el personaje (inventario o
    // ranura equipada); true lo deja fuera de su carga, en la Caja Magica.
    bool SizedArmorInMagicBox[300];
    bool SizedShieldInMagicBox[60];
    bool SizedWeaponInMagicBox[300];
    bool EquipmentStorageInitialized;
    // Equipado y activo son conceptos distintos. Varias armas pueden estar
    // preparadas simultaneamente, pero WeaponType/Tier/Size identifica solo
    // la que responde al boton de familia seleccionado en este momento.
    bool SizedWeaponEquipped[300];
    bool WeaponLoadoutInitialized;
    // Impide que los registros 4.7 vuelvan a crear objetos descartados una
    // vez que la propiedad ya fue transferida al inventario nativo.
    bool NativeEquipmentMigrationComplete;
    bool WeaponEssenceInitialized;

    // Identidad formal 4.29.0bc. Estos campos viajan junto con el registro y
    // evitan que dos piezas iguales compartan selección o durabilidad.
    int NextEquipmentItemId;
    int EquippedArmorItemId[4];
    int EquippedShieldItemId;
    int ActiveWeaponItemId;
    int EquippedAmuletItemId;
    int EquippedSealItemId;

    // El recetario pertenece al perfil y viaja con el mismo Inventory entre
    // mapas y guardados. La versión distingue el catálogo 4.29.0x del libro
    // vacío que usan los personajes creados desde 4.29.0y.
    int RecipeBookVersion;
    bool KnownCraftingRecipe[129];

    // Instantánea viajera de la única tarea 4.30. Los guardados normales ya
    // serializan al jugador; esta copia adicional conserva el estado durante
    // `changemap` y otros viajes que reconstruyen el pawn.
    bool CraftingTaskActive;
    int CraftingTaskKind;
    int CraftingTaskRecipeIndex;
    int CraftingTaskTier;
    int CraftingTaskSize;
    int CraftingTaskBatchIndex;
    int CraftingTaskEfficiencyIndex;
    int CraftingTaskTargetItemId;
    int CraftingTaskNetworkCapabilities;
    int CraftingTaskReservedBoxSlots;
    bool CraftingTaskUsesDirectPlan;
    double CraftingTaskTotalSeconds;
    double CraftingTaskRemainingSeconds;
    int CraftingTaskReservedType[16];
    int CraftingTaskReservedTier[16];
    int CraftingTaskReservedUnits[16];
    int CraftingTaskOutputType[16];
    int CraftingTaskOutputTier[16];
    int CraftingTaskOutputUnits[16];

    int StoredHealth;
    double StoredAnima;
    double StoredAir;
    double StoredAdrenaline;
    double StoredLucidity;
    double StoredHunger;
    double StoredThirst;
    double StoredSleep;

    Default
    {
        Inventory.Amount 1;
        Inventory.MaxAmount 1;
        Inventory.InterHubAmount 1;
        +INVENTORY.UNDROPPABLE
        +INVENTORY.UNCLEARABLE
        +INVENTORY.KEEPDEPLETED
    }

    States
    {
    Spawn:
        TNT1 A -1;
        Stop;
    }

    void ObserveEquipmentItemId(int itemId)
    {
        if (itemId > NextEquipmentItemId)
        {
            NextEquipmentItemId = itemId;
        }
    }

    int AllocateEquipmentItemId()
    {
        NextEquipmentItemId++;
        if (NextEquipmentItemId <= 0) { NextEquipmentItemId = 1; }
        return NextEquipmentItemId;
    }

    int GetArmorOwnershipIndex(int slot, int armorType, int tier)
    {
        return Clamp(slot, 0, 3) * 12
            + Clamp(armorType, 0, 3) * 3
            + Clamp(tier, 1, 3) - 1;
    }

    int GetShieldOwnershipIndex(int shieldType, int tier)
    {
        return Clamp(shieldType, 0, 3) * 3 + Clamp(tier, 1, 3) - 1;
    }

    int GetSizedArmorOwnershipIndex(int slot, int armorType, int tier, int equipmentSize)
    {
        return (((Clamp(slot, 0, 3) * CaelumConstants.ARMOR_TYPE_COUNT
            + Clamp(armorType, 0, CaelumConstants.ARMOR_TYPE_COUNT - 1)) * 3
            + Clamp(tier, 1, 3) - 1) * CaelumConstants.EQUIPMENT_SIZE_COUNT)
            + Clamp(equipmentSize, 0, CaelumConstants.EQUIPMENT_SIZE_COUNT - 1);
    }

    int GetSizedShieldOwnershipIndex(int shieldType, int tier, int equipmentSize)
    {
        return ((Clamp(shieldType, 0, 3) * 3 + Clamp(tier, 1, 3) - 1)
            * CaelumConstants.EQUIPMENT_SIZE_COUNT)
            + Clamp(equipmentSize, 0, CaelumConstants.EQUIPMENT_SIZE_COUNT - 1);
    }

    int GetSizedWeaponOwnershipIndex(int weaponType, int tier, int equipmentSize)
    {
        return ((Clamp(weaponType, 0, CaelumConstants.WEAPON_TYPE_COUNT - 1) * 3
            + Clamp(tier, 1, 3) - 1) * CaelumConstants.EQUIPMENT_SIZE_COUNT)
            + Clamp(equipmentSize, 0, CaelumConstants.EQUIPMENT_SIZE_COUNT - 1);
    }

    // Migra registros creados antes de que cada objeto guardara su propia
    // durabilidad. Solo se ejecuta una vez; después, cero vuelve a significar
    // correctamente que ese objeto está roto.
    void EnsureOwnershipDurabilityInitialized()
    {
        if (OwnershipDurabilityInitialized) { return; }
        // Los registros 4.3 siempre representaban un escudo equipado.
        ShieldEquipped = true;
        for (int index = 0; index < 48; index++)
        {
            if (!OwnedArmor[index]) { continue; }
            int armorType = (index % 12) / 3;
            int tier = index % 3 + 1;
            int baseDurability = 20;
            if (armorType == CaelumConstants.ARMOR_TYPE_LIGHT) { baseDurability = 40; }
            else if (armorType == CaelumConstants.ARMOR_TYPE_MEDIUM) { baseDurability = 60; }
            else if (armorType == CaelumConstants.ARMOR_TYPE_HEAVY) { baseDurability = 100; }
            int multiplier = tier == 1 ? 1 : (tier == 2 ? 3 : 9);
            OwnedArmorDurability[index] = baseDurability * multiplier;
        }
        for (int shieldIndex = 0; shieldIndex < 12; shieldIndex++)
        {
            if (!OwnedShield[shieldIndex]) { continue; }
            int shieldType = shieldIndex / 3;
            int tier = shieldIndex % 3 + 1;
            int baseDurability = 100;
            if (shieldType == CaelumConstants.SHIELD_TYPE_BUCKLER) { baseDurability = 80; }
            else if (shieldType == CaelumConstants.SHIELD_TYPE_KITE) { baseDurability = 150; }
            else if (shieldType == CaelumConstants.SHIELD_TYPE_TOWER) { baseDurability = 250; }
            int multiplier = tier == 1 ? 1 : (tier == 2 ? 3 : 9);
            OwnedShieldDurability[shieldIndex] = baseDurability * multiplier;
        }
        OwnershipDurabilityInitialized = true;
    }

    // Las partidas anteriores no guardaban talle. Todo su equipo pasa a M,
    // que conserva exactamente el peso y la durabilidad documentados entonces.
    void EnsureEquipmentSizeInitialized()
    {
        EnsureOwnershipDurabilityInitialized();
        if (!EquipmentSizeInitialized)
        {
            for (int slot = 0; slot < 4; slot++)
            {
                ArmorSize[slot] = CaelumConstants.EQUIPMENT_SIZE_M;
            }
            ShieldSize = CaelumConstants.EQUIPMENT_SIZE_M;
            for (int oldArmorIndex = 0; oldArmorIndex < 48; oldArmorIndex++)
            {
                if (!OwnedArmor[oldArmorIndex]) { continue; }
                int slot = oldArmorIndex / 12;
                int armorType = (oldArmorIndex % 12) / 3;
                int tier = oldArmorIndex % 3 + 1;
                int newIndex = GetSizedArmorOwnershipIndex(
                    slot, armorType, tier, CaelumConstants.EQUIPMENT_SIZE_M
                );
                SizedOwnedArmor[newIndex] = true;
                SizedOwnedArmorDurability[newIndex] = OwnedArmorDurability[oldArmorIndex];
            }
            for (int oldShieldIndex = 0; oldShieldIndex < 12; oldShieldIndex++)
            {
                if (!OwnedShield[oldShieldIndex]) { continue; }
                int shieldType = oldShieldIndex / 3;
                int tier = oldShieldIndex % 3 + 1;
                int newIndex = GetSizedShieldOwnershipIndex(
                    shieldType, tier, CaelumConstants.EQUIPMENT_SIZE_M
                );
                SizedOwnedShield[newIndex] = true;
                SizedOwnedShieldDurability[newIndex] = OwnedShieldDurability[oldShieldIndex];
            }
            EquipmentSizeInitialized = true;
        }
        EnsureWeaponEquipmentInitialized();
        EnsureEquipmentStorageInitialized();
        EnsureWeaponLoadoutInitialized();
        EnsureWeaponEssenceInitialized();
    }

    void EnsureRecipeBookInitialized()
    {
        if (RecipeBookVersion >= CaelumConstants.CRAFTING_RECIPE_BOOK_VERSION)
        {
            return;
        }

        if (RecipeBookVersion <= 0 && ProfileCommitted)
        {
            // Un perfil anterior a 4.29.0x ya jugable conserva las 61 recetas
            // que entonces estaban abiertas. Los cuatro escudos son nuevos.
            for (int recipeIndex = 0;
                recipeIndex < CaelumConstants.CRAFTING_NETWORK_LEGACY_RECIPE_COUNT;
                recipeIndex++)
            {
                KnownCraftingRecipe[recipeIndex] = true;
            }
        }
        else if (RecipeBookVersion <= 0)
        {
            // Un estado recién creado aún no confirmado comienza sin recetas.
            for (int recipeIndex = 0;
                recipeIndex < CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT;
                recipeIndex++)
            {
                KnownCraftingRecipe[recipeIndex] = false;
            }
        }

        // La versión 2 ya contenía los cuatro escudos de 4.29.0y. Las catorce
        // recetas de procesamiento (v3) y las cincuenta de componentes (v4)
        // se anexan bloqueadas; se aprenderán con sus Arcanos Menores.
        int addedRecipeStart;
        if (RecipeBookVersion >= 3)
        {
            addedRecipeStart = CaelumConstants.CRAFTING_NETWORK_LEGACY_RECIPE_COUNT
                + CaelumConstants.CRAFTING_NETWORK_SHIELD_RECIPE_COUNT
                + CaelumConstants.CRAFTING_NETWORK_PROCESSING_RECIPE_COUNT;
        }
        else if (RecipeBookVersion >= 2)
        {
            addedRecipeStart = CaelumConstants.CRAFTING_NETWORK_LEGACY_RECIPE_COUNT
                + CaelumConstants.CRAFTING_NETWORK_SHIELD_RECIPE_COUNT;
        }
        else
        {
            addedRecipeStart = CaelumConstants.CRAFTING_NETWORK_LEGACY_RECIPE_COUNT;
        }
        for (int recipeIndex = addedRecipeStart;
            recipeIndex < CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT;
            recipeIndex++)
        {
            KnownCraftingRecipe[recipeIndex] = false;
        }
        RecipeBookVersion = CaelumConstants.CRAFTING_RECIPE_BOOK_VERSION;
    }

    bool KnowsCraftingRecipe(int recipeIndex)
    {
        EnsureRecipeBookInitialized();
        if (recipeIndex < 0
            || recipeIndex >= CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT)
        {
            return false;
        }
        return KnownCraftingRecipe[recipeIndex];
    }

    bool LearnCraftingRecipe(int recipeIndex)
    {
        EnsureRecipeBookInitialized();
        if (recipeIndex < 0
            || recipeIndex >= CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT
            || KnownCraftingRecipe[recipeIndex])
        {
            return false;
        }
        KnownCraftingRecipe[recipeIndex] = true;
        return true;
    }

    void SetAllCraftingRecipesKnown(bool known)
    {
        EnsureRecipeBookInitialized();
        for (int recipeIndex = 0;
            recipeIndex < CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT;
            recipeIndex++)
        {
            KnownCraftingRecipe[recipeIndex] = known;
        }
    }

    int CountKnownCraftingRecipes()
    {
        EnsureRecipeBookInitialized();
        int knownCount = 0;
        for (int recipeIndex = 0;
            recipeIndex < CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT;
            recipeIndex++)
        {
            if (KnownCraftingRecipe[recipeIndex]) { knownCount++; }
        }
        return knownCount;
    }

    // Las partidas 4.7.2 trataban todo objeto desequipado como contenido de la
    // Caja Magica. La migracion conserva esa ubicacion y deja fuera solamente
    // las piezas que estaban realmente equipadas.
    void EnsureEquipmentStorageInitialized()
    {
        if (EquipmentStorageInitialized) { return; }
        for (int armorIndex = 0; armorIndex < 300; armorIndex++)
        {
            SizedArmorInMagicBox[armorIndex] = SizedOwnedArmor[armorIndex];
        }
        for (int shieldIndex = 0; shieldIndex < 60; shieldIndex++)
        {
            SizedShieldInMagicBox[shieldIndex] = SizedOwnedShield[shieldIndex];
        }
        for (int weaponIndex = 0;
            weaponIndex < CaelumConstants.WEAPON_OWNERSHIP_COUNT;
            weaponIndex++)
        {
            SizedWeaponInMagicBox[weaponIndex] = SizedOwnedWeapon[weaponIndex];
        }
        if (EquipmentInitialized)
        {
            for (int slot = 0; slot < CaelumConstants.ARMOR_SLOT_COUNT; slot++)
            {
                if (ArmorType[slot] == CaelumConstants.ARMOR_TYPE_BASE_CLOTHING)
                {
                    continue;
                }
                SizedArmorInMagicBox[GetSizedArmorOwnershipIndex(
                    slot, ArmorType[slot], ArmorTier[slot], ArmorSize[slot]
                )] = false;
            }
            if (ShieldEquipped)
            {
                SizedShieldInMagicBox[GetSizedShieldOwnershipIndex(
                    ShieldType, ShieldTier, ShieldSize
                )] = false;
            }
            if (WeaponEquipped)
            {
                SizedWeaponInMagicBox[GetSizedWeaponOwnershipIndex(
                    WeaponType, WeaponTier, WeaponSize
                )] = false;
            }
        }
        EquipmentStorageInitialized = true;
    }

    // Migra las partidas con una sola arma: la antigua arma activa pasa a ser
    // la primera entrada equipada sin modificar las demás propiedades.
    void EnsureWeaponLoadoutInitialized()
    {
        if (WeaponLoadoutInitialized) { return; }
        if (WeaponEquipped)
        {
            SizedWeaponEquipped[GetSizedWeaponOwnershipIndex(
                WeaponType, WeaponTier, WeaponSize
            )] = true;
        }
        WeaponLoadoutInitialized = true;
    }

    void EnsureWeaponEssenceInitialized()
    {
        if (WeaponEssenceInitialized) { return; }
        WeaponEssenceType = CaelumConstants.ESSENCE_FIRE;
        for (int index = 0;
            index < CaelumConstants.WEAPON_OWNERSHIP_COUNT; index++)
        {
            SizedWeaponEssenceType[index] = CaelumConstants.ESSENCE_FIRE;
        }
        WeaponEssenceInitialized = true;
    }

    // Migra el peso provisional de versiones anteriores a un arma real. La
    // espada era el valor normal; 4 identifica baston y 12 identifica carabina.
    void EnsureWeaponEquipmentInitialized()
    {
        if (WeaponEquipmentInitialized) { return; }
        bool migrateExistingWeapon = EquipmentInitialized
            || WeaponWeightInitialized || ProfileCommitted;
        WeaponType = CaelumConstants.WEAPON_TYPE_SWORD;
        WeaponTier = WeaponWeightInitialized ? Clamp(EquippedWeaponTier, 1, 3) : 1;
        WeaponSize = WeaponWeightInitialized
            ? Clamp(EquippedWeaponSize, 0, CaelumConstants.EQUIPMENT_SIZE_COUNT - 1)
            : CaelumConstants.EQUIPMENT_SIZE_M;
        if (WeaponWeightInitialized && EquippedWeaponBaseWeight >= 10.0)
        {
            WeaponType = CaelumConstants.WEAPON_TYPE_CARBINE;
        }
        else if (WeaponWeightInitialized && EquippedWeaponBaseWeight <= 4.5)
        {
            WeaponType = CaelumConstants.WEAPON_TYPE_STAFF;
        }
        WeaponDurability = 100;
        if (WeaponType == CaelumConstants.WEAPON_TYPE_STAFF) { WeaponDurability = 80; }
        else if (WeaponType == CaelumConstants.WEAPON_TYPE_CARBINE) { WeaponDurability = 120; }
        int tierMultiplier = WeaponTier == 1 ? 1 : (WeaponTier == 2 ? 3 : 9);
        WeaponDurability = CaelumEquipmentRules.ScaleDurabilityForSize(
            WeaponDurability * tierMultiplier,
            WeaponSize
        );
        WeaponEquipped = migrateExistingWeapon;
        if (migrateExistingWeapon)
        {
            int weaponIndex = GetSizedWeaponOwnershipIndex(
                WeaponType, WeaponTier, WeaponSize
            );
            SizedOwnedWeapon[weaponIndex] = true;
            SizedOwnedWeaponDurability[weaponIndex] = WeaponDurability;
        }
        WeaponEquipmentInitialized = true;
    }

    void MarkCurrentEquipmentOwned()
    {
        for (int slot = 0; slot < CaelumConstants.ARMOR_SLOT_COUNT; slot++)
        {
            if (ArmorType[slot] == CaelumConstants.ARMOR_TYPE_BASE_CLOTHING)
            {
                continue;
            }
            int armorIndex = GetSizedArmorOwnershipIndex(
                slot,
                ArmorType[slot],
                ArmorTier[slot],
                ArmorSize[slot]
            );
            SizedOwnedArmor[armorIndex] = true;
            SizedOwnedArmorDurability[armorIndex] = ArmorDurability[slot];
        }
        if (ShieldEquipped)
        {
            int shieldIndex = GetSizedShieldOwnershipIndex(
                ShieldType, ShieldTier, ShieldSize
            );
            SizedOwnedShield[shieldIndex] = true;
            SizedOwnedShieldDurability[shieldIndex] = ShieldDurability;
        }
        if (WeaponEquipped)
        {
            int weaponIndex = GetSizedWeaponOwnershipIndex(
                WeaponType, WeaponTier, WeaponSize
            );
            SizedOwnedWeapon[weaponIndex] = true;
            SizedOwnedWeaponDurability[weaponIndex] = WeaponDurability;
            SizedWeaponEquipped[weaponIndex] = true;
            SizedWeaponEssenceType[weaponIndex] = Clamp(
                WeaponEssenceType,
                0,
                CaelumConstants.ESSENCE_TYPE_COUNT - 1
            );
        }
    }

    bool RegisterOwnedArmor(
        int slot,
        int armorType,
        int tier,
        int equipmentSize,
        int durability
    )
    {
        int index = GetSizedArmorOwnershipIndex(slot, armorType, tier, equipmentSize);
        bool newlyOwned = !SizedOwnedArmor[index];
        SizedOwnedArmor[index] = true;
        SizedOwnedArmorDurability[index] = Max(
            SizedOwnedArmorDurability[index],
            Max(0, durability)
        );
        return newlyOwned;
    }

    bool RegisterOwnedShield(int shieldType, int tier, int equipmentSize, int durability)
    {
        int index = GetSizedShieldOwnershipIndex(shieldType, tier, equipmentSize);
        bool newlyOwned = !SizedOwnedShield[index];
        SizedOwnedShield[index] = true;
        SizedOwnedShieldDurability[index] = Max(
            SizedOwnedShieldDurability[index],
            Max(0, durability)
        );
        return newlyOwned;
    }

    bool RegisterOwnedWeapon(int weaponType, int tier, int equipmentSize, int durability)
    {
        int index = GetSizedWeaponOwnershipIndex(weaponType, tier, equipmentSize);
        bool newlyOwned = !SizedOwnedWeapon[index];
        SizedOwnedWeapon[index] = true;
        SizedOwnedWeaponDurability[index] = Max(
            SizedOwnedWeaponDurability[index], Max(0, durability)
        );
        return newlyOwned;
    }

    bool OwnsArmor(int slot, int armorType, int tier, int equipmentSize)
    {
        return SizedOwnedArmor[
            GetSizedArmorOwnershipIndex(slot, armorType, tier, equipmentSize)
        ];
    }

    bool OwnsShield(int shieldType, int tier, int equipmentSize)
    {
        return SizedOwnedShield[
            GetSizedShieldOwnershipIndex(shieldType, tier, equipmentSize)
        ];
    }

    bool OwnsWeapon(int weaponType, int tier, int equipmentSize)
    {
        return SizedOwnedWeapon[
            GetSizedWeaponOwnershipIndex(weaponType, tier, equipmentSize)
        ];
    }

    bool IsArmorInMagicBox(int slot, int armorType, int tier, int equipmentSize)
    {
        return SizedArmorInMagicBox[
            GetSizedArmorOwnershipIndex(slot, armorType, tier, equipmentSize)
        ];
    }

    bool IsShieldInMagicBox(int shieldType, int tier, int equipmentSize)
    {
        return SizedShieldInMagicBox[
            GetSizedShieldOwnershipIndex(shieldType, tier, equipmentSize)
        ];
    }

    bool IsWeaponInMagicBox(int weaponType, int tier, int equipmentSize)
    {
        return SizedWeaponInMagicBox[
            GetSizedWeaponOwnershipIndex(weaponType, tier, equipmentSize)
        ];
    }

    bool IsWeaponEquipped(int weaponType, int tier, int equipmentSize)
    {
        return SizedWeaponEquipped[
            GetSizedWeaponOwnershipIndex(weaponType, tier, equipmentSize)
        ];
    }

    void SetWeaponEquipped(
        int weaponType, int tier, int equipmentSize, bool equipped
    )
    {
        int index = GetSizedWeaponOwnershipIndex(
            weaponType, tier, equipmentSize
        );
        SizedWeaponEquipped[index] = equipped && SizedOwnedWeapon[index];
        if (SizedWeaponEquipped[index]) { SizedWeaponInMagicBox[index] = false; }
    }

    int CountEquippedWeapons()
    {
        int total = 0;
        for (int index = 0;
            index < CaelumConstants.WEAPON_OWNERSHIP_COUNT; index++)
        {
            if (SizedOwnedWeapon[index] && SizedWeaponEquipped[index]) { total++; }
        }
        return total;
    }

    bool HasEquippedWeaponType(int weaponType)
    {
        for (int tier = 1; tier <= 3; tier++)
        {
            for (int equipmentSize = 0;
                equipmentSize < CaelumConstants.EQUIPMENT_SIZE_COUNT;
                equipmentSize++)
            {
                if (IsWeaponEquipped(weaponType, tier, equipmentSize))
                {
                    return true;
                }
            }
        }
        return false;
    }

    void SetArmorInMagicBox(
        int slot, int armorType, int tier, int equipmentSize, bool inMagicBox
    )
    {
        SizedArmorInMagicBox[
            GetSizedArmorOwnershipIndex(slot, armorType, tier, equipmentSize)
        ] = inMagicBox;
    }

    void SetShieldInMagicBox(
        int shieldType, int tier, int equipmentSize, bool inMagicBox
    )
    {
        SizedShieldInMagicBox[
            GetSizedShieldOwnershipIndex(shieldType, tier, equipmentSize)
        ] = inMagicBox;
    }

    void SetWeaponInMagicBox(
        int weaponType, int tier, int equipmentSize, bool inMagicBox
    )
    {
        int index = GetSizedWeaponOwnershipIndex(
            weaponType, tier, equipmentSize
        );
        SizedWeaponInMagicBox[index] = inMagicBox;
        if (inMagicBox) { SizedWeaponEquipped[index] = false; }
    }

    int GetOwnedArmorDurability(int slot, int armorType, int tier, int equipmentSize)
    {
        return SizedOwnedArmorDurability[
            GetSizedArmorOwnershipIndex(slot, armorType, tier, equipmentSize)
        ];
    }

    int GetOwnedShieldDurability(int shieldType, int tier, int equipmentSize)
    {
        return SizedOwnedShieldDurability[
            GetSizedShieldOwnershipIndex(shieldType, tier, equipmentSize)
        ];
    }

    int GetOwnedWeaponDurability(int weaponType, int tier, int equipmentSize)
    {
        return SizedOwnedWeaponDurability[
            GetSizedWeaponOwnershipIndex(weaponType, tier, equipmentSize)
        ];
    }

    int GetWeaponEssenceType(int weaponType, int tier, int equipmentSize)
    {
        EnsureWeaponEssenceInitialized();
        return Clamp(
            SizedWeaponEssenceType[GetSizedWeaponOwnershipIndex(
                weaponType, tier, equipmentSize
            )],
            0,
            CaelumConstants.ESSENCE_TYPE_COUNT - 1
        );
    }

    void SetWeaponEssenceType(
        int weaponType, int tier, int equipmentSize, int essenceType
    )
    {
        EnsureWeaponEssenceInitialized();
        SizedWeaponEssenceType[GetSizedWeaponOwnershipIndex(
            weaponType, tier, equipmentSize
        )] = Clamp(
            essenceType, 0, CaelumConstants.ESSENCE_TYPE_COUNT - 1
        );
    }

    void StoreOwnedArmorDurability(
        int slot,
        int armorType,
        int tier,
        int equipmentSize,
        int durability
    )
    {
        int index = GetSizedArmorOwnershipIndex(slot, armorType, tier, equipmentSize);
        if (SizedOwnedArmor[index])
        {
            SizedOwnedArmorDurability[index] = Max(0, durability);
        }
    }

    void StoreOwnedShieldDurability(
        int shieldType,
        int tier,
        int equipmentSize,
        int durability
    )
    {
        int index = GetSizedShieldOwnershipIndex(shieldType, tier, equipmentSize);
        if (SizedOwnedShield[index])
        {
            SizedOwnedShieldDurability[index] = Max(0, durability);
        }
    }

    void StoreOwnedWeaponDurability(
        int weaponType,
        int tier,
        int equipmentSize,
        int durability
    )
    {
        int index = GetSizedWeaponOwnershipIndex(weaponType, tier, equipmentSize);
        if (SizedOwnedWeapon[index])
        {
            SizedOwnedWeaponDurability[index] = Max(0, durability);
        }
    }

    void RemoveOwnedArmor(int slot, int armorType, int tier, int equipmentSize)
    {
        int index = GetSizedArmorOwnershipIndex(slot, armorType, tier, equipmentSize);
        SizedOwnedArmor[index] = false;
        SizedOwnedArmorDurability[index] = 0;
        SizedArmorInMagicBox[index] = false;
    }

    void RemoveOwnedShield(int shieldType, int tier, int equipmentSize)
    {
        int index = GetSizedShieldOwnershipIndex(shieldType, tier, equipmentSize);
        SizedOwnedShield[index] = false;
        SizedOwnedShieldDurability[index] = 0;
        SizedShieldInMagicBox[index] = false;
    }

    void RemoveOwnedWeapon(int weaponType, int tier, int equipmentSize)
    {
        int index = GetSizedWeaponOwnershipIndex(weaponType, tier, equipmentSize);
        SizedOwnedWeapon[index] = false;
        SizedOwnedWeaponDurability[index] = 0;
        SizedWeaponEssenceType[index] = CaelumConstants.ESSENCE_FIRE;
        SizedWeaponInMagicBox[index] = false;
        SizedWeaponEquipped[index] = false;
    }

    int CountOwnedArmor()
    {
        int total = 0;
        for (int i = 0; i < 300; i++) { if (SizedOwnedArmor[i]) total++; }
        return total;
    }

    int CountOwnedShields()
    {
        int total = 0;
        for (int i = 0; i < 60; i++) { if (SizedOwnedShield[i]) total++; }
        return total;
    }

    int CountOwnedWeapons()
    {
        int total = 0;
        for (int i = 0; i < CaelumConstants.WEAPON_OWNERSHIP_COUNT; i++)
        {
            if (SizedOwnedWeapon[i]) { total++; }
        }
        return total;
    }

    int CountMagicBoxItems()
    {
        int total = 0;
        for (int i = 0; i < 300; i++)
        {
            if (SizedOwnedArmor[i] && SizedArmorInMagicBox[i]) { total++; }
        }
        for (int i = 0; i < 60; i++)
        {
            if (SizedOwnedShield[i] && SizedShieldInMagicBox[i]) { total++; }
        }
        for (int i = 0; i < CaelumConstants.WEAPON_OWNERSHIP_COUNT; i++)
        {
            if (SizedOwnedWeapon[i] && SizedWeaponInMagicBox[i]) { total++; }
        }
        return total;
    }
}
