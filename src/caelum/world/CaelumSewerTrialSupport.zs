// Medios explícitos para probar las guardas de viaje. Las estaciones usan
// recetas, reservas y modelos existentes; no fabrican ni activan un sello.
class CaelumSewerTrialSupport : Object play
{
    const ROOM_GROUP = 43414;
    const PREPARE_SEAL = 1;
    const PREPARE_CRAFT = 2;
    const BATCH_INDEX = 1;
    const EFFICIENCY_INDEX = 2;

    static bool IsTrialMap()
    {
        int location = CaelumWorldCatalogue.LocationForMap(level.MapName);
        return location >= 3 && location <= 5;
    }

    static vector3 BenchPosition()
    {
        return level.MapName == "MAP02" ? (-320,64,0) : (-80,384,0);
    }

    static CaelumCraftingStation FindStation(int type)
    {
        let it = ThinkerIterator.Create("CaelumCraftingStation");
        CaelumCraftingStation station;
        while ((station = CaelumCraftingStation(it.Next())) != null)
            if (station.CraftingRoomGroup == ROOM_GROUP
                && station.GetCraftingStationType() == type) return station;
        return null;
    }

    static void PlaceStation(class<CaelumCraftingStation> kind, int type, vector3 position)
    {
        let station=FindStation(type);
        if(station==null)station=CaelumCraftingStation(Actor.Spawn(kind, position, NO_REPLACE));
        if (station == null) return;
        station.SetOrigin(position,false);station.Vel=(0,0,0);station.EnsureDimensions();
        station.CraftingRoomGroup = ROOM_GROUP;
        station.Angle = 0;
        // args[0]=0 conserva la inmovilidad nativa de la infraestructura.
    }

    static void PrepareWorld()
    {
        if (!IsTrialMap()) return;
        vector3 position = BenchPosition();
        PlaceStation("CaelumWorkbenchStation", CaelumConstants.CRAFTING_STATION_WORKBENCH, position);
        PlaceStation("CaelumSawmillStation", CaelumConstants.CRAFTING_STATION_SAWMILL, position + (level.MapName=="MAP02"?(0,112,0):(-112,0,0)));
        // El catálogo actual requiere forja para los componentes de armas
        // cuerpo a cuerpo, incluso los mangos. Se respeta esa regla vigente.
        PlaceStation("CaelumForgeStation", CaelumConstants.CRAFTING_STATION_FORGE, position + (level.MapName=="MAP02"?(0,224,0):(-112,-112,0)));
    }

    static int Recipe()
    {
        return CaelumCraftingRules.FindComponentRecipeForOutput(CaelumConstants.MATERIAL_HANDLE);
    }

    static void FocusRecipe(CaelumPlayer user, CaelumCraftingStation station)
    {
        if (!IsTrialMap() || station.CraftingRoomGroup != ROOM_GROUP
            || !user.CraftingMenuOpen || user.CraftingTaskActive
            || !user.IsCraftingRecipeKnown(Recipe())) return;
        user.CraftingRecipeFilter = CaelumConstants.CRAFTING_RECIPE_FILTER_COMPONENT;
        user.CraftingSelectionRecipe = Recipe();
        user.CraftingSelectionTier = 1;
        // Lote x10 y eficiencia 100% ya existentes: dan tiempo para cerrar
        // Oficios y comprobar el bloqueo antes de que termine la fabricación.
        user.CraftingProcessingBatchIndex = BATCH_INDEX;
        user.CraftingEfficiencyIndex = EFFICIENCY_INDEX;
        user.RefreshCraftingPreview();
    }

    static void Feedback(CaelumPlayer user, String key)
    {
        user.A_Print(StringTable.Localize(key, false));
    }

    static bool PrepareSeal(CaelumPlayer user)
    {
        CaelumEquipmentItem seal;
        for (Inventory cursor = user.Inv; cursor != null; cursor = cursor.Inv)
        {
            let item = CaelumEquipmentItem(cursor);
            if (item != null && item.EquipmentKind == CaelumConstants.EQUIPMENT_KIND_SEAL
                && item.ItemType == CaelumConstants.SEAL_QUINTESSENCE && item.Tier == 1)
            {
                seal = item;
                if (!item.InMagicBox) break;
            }
        }
        user.RefreshCarriedInventorySummary();
        if (seal == null)
        {
            double weight = CaelumCraftingRules.GetJewelryWeight(1);
            if (!user.CanAddWeightToPersonalInventory(weight)) return false;
            seal = CaelumEquipmentItem(Actor.Spawn("CaelumSealPickup", user.Pos, NO_REPLACE));
            if (seal == null) return false;
            seal.EquipmentKind = CaelumConstants.EQUIPMENT_KIND_SEAL;
            seal.ItemType = CaelumConstants.SEAL_QUINTESSENCE;
            seal.EssenceType = seal.ItemType;
            seal.ArmorSlot = -1; seal.Tier = 1;
            seal.EquipmentSize = CaelumConstants.EQUIPMENT_SIZE_M;
            seal.UnitWeight = weight;
            seal.PickupDataInitialized = true;
            seal.AttachToOwner(user);
            user.EnsureEquipmentItemId(seal);
            CaelumNotifications.Acquired(user, seal, 1);
        }
        user.ApplyFormalInventorySelection(seal);
        user.EquipSelectedNativeEquipment();
        if (!seal.Equipped || seal.InMagicBox) return false;
        // Únicamente esta opción de diagnóstico rellena adrenalina y quita
        // la espera. No inicia combate ni cambia el máximo o consumo del sello.
        user.AddAdrenaline(user.DerivedStats.MaximumAdrenaline);
        user.CombatChannelCooldownRemaining = 0.0;
        user.PersistCharacterState();
        return true;
    }

    static bool PrepareCraft(CaelumPlayer user)
    {
        int type = CaelumConstants.MATERIAL_WOOD;
        int tier = CaelumMaterialRules.ResolveTier(type, 1);
        let existing = user.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL, type, tier);
        // Completar un lote de prueba, sin sumar otro si ya lo posee.
        int needed = Max(0, CaelumCraftingRules.GetComponentInputUnits(BATCH_INDEX)
            - (existing == null ? 0 : existing.Amount));
        if (needed > 0)
        {
            user.RefreshCarriedInventorySummary();
            double weight = needed * CaelumConstants.MATERIAL_UNIT_WEIGHT;
            bool inBox = existing != null && existing.InMagicBox;
            if (inBox ? !user.CanAddRawWeightToMagicBox(weight)
                : !user.CanAddWeightToPersonalInventory(weight)) return false;
            CaelumMaterialPickup material;
            if (existing == null)
            {
                material = user.CreateDetachedMaterialStack(type, tier, needed);
                if (material == null) return false;
                material.UpdateMaterialVisuals();
            }
            user.AddRecoveredMaterial(existing, material, needed, inBox);
        }
        user.LearnCraftingRecipe(Recipe());
        user.ApplyCharacterProfile();
        user.PersistCharacterState();
        user.RefreshFormalInventorySnapshot();
        return true;
    }

    static bool Prepare(CaelumPlayer user, int kind)
    {
        if (!IsTrialMap() || (kind != PREPARE_SEAL && kind != PREPARE_CRAFT)
            || !CaelumTravelService.CanDepart(user, CaelumCaravanTrial.FirstRoute())) return false;
        PrepareWorld();
        bool ready = kind == PREPARE_SEAL ? PrepareSeal(user) : PrepareCraft(user);
        Feedback(user, !ready ? "CA_SEWER_SUPPORT_FULL"
            : kind == PREPARE_SEAL ? "CA_SEWER_SUPPORT_SEAL_READY" : "CA_SEWER_SUPPORT_CRAFT_READY");
        return ready;
    }
}
