// El registro viajero conserva también barriles de mapas que se reconstruyen.
// Todos los usuarios del mismo barril comparten el MISMO objeto, no copias.
class CaelumFermentationRecord : Object play
{
    String MapName;
    Vector3 Position;
    CaelumFermentationBatch Batch;
}

class CaelumFermentationService : Object play
{
    static double Now(CaelumPlayer user)
    {
        let world = CaelumThermalWorld.Get();
        let clock = world != null ? world.ReferenceClock : null;
        if (clock == null) clock = CaelumWorldClock.Get(user);
        return clock == null ? -1 : CaelumThermalRuntime.Stamp(clock);
    }

    static CaelumFermentationRecord Record(CaelumPersistentCharacterState persistent,
        CaelumFermentationStation barrel)
    {
        if (persistent == null) return null;
        for (int i = 0; i < persistent.FermentationBatches.Size(); i++)
        {
            let entry = persistent.FermentationBatches[i];
            if (entry.MapName == level.MapName && entry.Position == barrel.Pos) return entry;
        }
        return null;
    }

    static CaelumFermentationBatch Bind(CaelumPlayer user, CaelumFermentationStation barrel)
    {
        if (!CaelumPlayerAuthority.CanMutate(user) || barrel == null) return null;
        let persistent = user.GetPersistentCharacterState(true);
        if (persistent == null) return null;
        let own = Record(persistent, barrel);
        if (barrel.Batch == null && own != null) barrel.Batch = own.Batch;
        if (barrel.Batch == null)
        {
            // Consulta por interacción, acotada a jugadores y sus registros de
            // barriles fijos. Nunca recorre la población de actores del mapa.
            for (int p = 0; p < MAXPLAYERS; p++)
            {
                if (!playeringame[p]) continue;
                let other = CaelumPlayer(players[p].mo);
                let entry = other != null ? Record(other.GetPersistentCharacterState(false), barrel) : null;
                if (entry != null) { barrel.Batch = entry.Batch; break; }
            }
        }
        if (barrel.Batch == null) barrel.Batch = new("CaelumFermentationBatch");
        if (own == null)
        {
            own = new("CaelumFermentationRecord");
            own.MapName = level.MapName; own.Position = barrel.Pos;
            persistent.FermentationBatches.Push(own);
        }
        own.Batch = barrel.Batch;
        return barrel.Batch;
    }

    static bool Reachable(CaelumPlayer user, CaelumFermentationStation barrel)
    {
        return CaelumPlayerAuthority.CanMutate(user) && barrel != null
            && user.player != null && user.player.playerstate == PST_LIVE && user.health > 0
            && !user.isFrozen() && user.CombatTimeRemaining <= 0
            && barrel.CanReachFrom(user)
            && user.Distance3D(barrel) <= CaelumConstants.CRAFTING_ACTIVE_STATION_DISTANCE;
    }

    static double AvailableWater(CaelumPlayer user)
    {
        double liters = 0;
        for (Inventory item = user.Inv; item != null; item = item.Inv)
        {
            let water = CaelumWaterContainer(item);
            if (water != null && !water.InMagicBox && water.Amount == 1
                && water.IsPotable() && !CaelumWaterBoiling.Locked(water)) liters += Max(0, water.WaterLiters);
        }
        return liters;
    }

    static void ConsumeWater(CaelumPlayer user, double liters)
    {
        for (Inventory item = user.Inv; item != null && liters > 0; item = item.Inv)
        {
            let water = CaelumWaterContainer(item);
            if (water == null || water.InMagicBox || water.Amount != 1
                || !water.IsPotable() || CaelumWaterBoiling.Locked(water)) continue;
            double taken = Min(Max(0, water.WaterLiters), liters);
            water.WaterLiters -= taken; liters -= taken;
        }
    }

    static bool Begin(CaelumPlayer user, CaelumFermentationStation barrel, int liters)
    {
        int recipe = CaelumChemistryData.FIRST_RECIPE;
        if (!Reachable(user, barrel) || user.CraftingTaskActive || liters <= 0
            || liters > CaelumFermentationData.WORKING_CAPACITY_LITERS
            || !user.DirectCraftingRecipeKnown(recipe, 1)) return false;
        barrel.CollectCraftingNetwork(user, user.BeginCraftingNetworkScan());
        if (CaelumCraftingRules.GetMissingFermentationStation(user.CraftingNetworkCapabilities)
            != CaelumConstants.CRAFTING_STATION_NONE) return false;
        let batch = Bind(user, barrel);
        double now = Now(user);
        if (batch == null || batch.Occupied || now < 0) return false;
        double water = CaelumChemistryData.WaterLiters(recipe) * liters;
        if (AvailableWater(user) + 0.0000001 < water) return false;
        for (int slot = 0; CaelumChemistryData.InputMaterial(recipe, slot) >= 0; slot++)
            if (user.CountCraftingMaterial(CaelumChemistryData.InputMaterial(recipe, slot), 1)
                < CaelumChemistryData.InputUnits(recipe, slot) * liters) return false;
        if (!batch.Begin(recipe, CaelumChemistryData.OutputMaterial(recipe), 1,
            CaelumChemistryData.OutputUnits(recipe) * liters, liters,
            CaelumChemistryData.Seconds(recipe), now)) return false;
        // Preflight completo antes de la mutación autoritativa síncrona.
        for (int slot = 0; CaelumChemistryData.InputMaterial(recipe, slot) >= 0; slot++)
            user.ConsumeCraftingMaterial(CaelumChemistryData.InputMaterial(recipe, slot), 1,
                CaelumChemistryData.InputUnits(recipe, slot) * liters);
        ConsumeWater(user, water);
        user.OnNativeInventoryChanged(); user.PersistCharacterState();
        return true;
    }

    static bool Withdraw(CaelumPlayer user, CaelumFermentationStation barrel, int units)
    {
        if (!Reachable(user, barrel)) return false;
        let batch = Bind(user, barrel);
        double now = Now(user);
        if (batch == null || !batch.Ready(now) || units <= 0 || units > batch.RemainingUnits) return false;
        let existing = user.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,
            batch.OutputMaterial, batch.OutputTier);
        if (existing != null && existing.Amount > 2147483647 - units) return false;
        double mass = CaelumMaterialRules.UnitWeight(batch.OutputMaterial) * units;
        bool boxed = existing != null && existing.InMagicBox;
        user.RefreshCarriedInventorySummary();
        if (boxed && !user.MagicBoxOwned) return false;
        if (!user.CanApplyInventoryWeightTransition(boxed ? 0 : mass, boxed ? mass : 0)) return false;
        CaelumMaterialPickup detached;
        if (existing == null)
        {
            detached = user.CreateDetachedMaterialStack(batch.OutputMaterial, batch.OutputTier, units);
            if (detached == null) return false;
        }
        // Descontar exactamente una vez después de preflight y antes del aviso.
        int recipe = batch.Recipe;
        if (!batch.Withdraw(units, now))
        { if (detached != null) detached.Destroy(); return false; }
        user.AddRecoveredMaterial(existing, detached, units, boxed);
        CaelumRecipeLearning.Practice(user, recipe, 1, units);
        user.OnNativeInventoryChanged(); user.PersistCharacterState();
        return true;
    }

    static bool Discard(CaelumPlayer user, CaelumFermentationStation barrel)
    {
        if (!Reachable(user, barrel)) return false;
        let batch = Bind(user, barrel);
        if (batch == null || !batch.Occupied) return false;
        batch.Clear(); user.PersistCharacterState();
        return true;
    }
}
