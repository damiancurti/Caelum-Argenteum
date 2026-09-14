// Controlador reconstruible de MAP01. No guarda progreso propio: consulta el
// Inventory viajero de cada personaje y sólo ejecuta presentaciones pendientes.
class CaelumMainM00QuestController : EventHandler
{
    bool RuloWorldPrepared;
    Line Passage;
    CaelumM00ElementRune Runes[4];
    bool WorldPrepared;
    bool PassageOpen;
    bool PassageSealed;
    bool GroundFloorStockRetired;
    bool RonnieWorldPrepared;
    CaelumMainM00SupplyChest RonnieSupplyChest;
    bool MansionLayoutPrepared;
    bool PassageTextureRestored;
    bool CornerLayoutPrepared;
    bool NaturalSuppliesPrepared;
    bool BullRoomPrepared;
    CaelumM00Bull TrialBull;
    bool ProcessingManualRetired;
    CaelumM00FoolEssence FoolEssence;
    bool ReturnDoorPrepared;
    CaelumM00ReturnDoor ReturnDoor;
    bool ChannelInfrastructureRecovered;
    bool SewerNetworkPrepared;

    void RecoverChannelInfrastructure()
    {
        if (ChannelInfrastructureRecovered || level.MapName != "MAP01") return;
        ChannelInfrastructureRecovered = true;
        // Reubicar las mismas instancias: no recrear tareas, reservas o stock.
        PlaceRoomStations(1, (-432, 512, 136), 1);
        PlaceRoomStations(2, (1176, 512, 136), 1);
        PlaceRoomStations(3, (1176, -512, 136), -1);
        PlaceRoomStations(4, (-432, -512, 136), -1);
        PlaceRoomStations(5, (-336, 0, 264), 1);
        let stations = ThinkerIterator.Create("CaelumCraftingStation");
        CaelumCraftingStation station;
        while ((station = CaelumCraftingStation(stations.Next())) != null)
        {
            if (station.GetRequiredPhysicalPower() > 0) continue;
            station.Vel = (0, 0, 0);
            station.bNoGravity = GetDefaultByType(station.GetClass()).bNoGravity;
        }
        let plants = ThinkerIterator.Create("CaelumTreeEnvironmentProp");
        CaelumTreeEnvironmentProp plant;
        while ((plant = CaelumTreeEnvironmentProp(plants.Next())) != null)
        {
            // SpawnPoint de los nodos del jardín conserva su origen incluso
            // después de cargar un guardado donde el sello los desplazó.
            plant.SetOrigin(plant.SpawnPoint, false);
            plant.Vel = (0, 0, 0);
            plant.bNoGravity = GetDefaultByType(plant.GetClass()).bNoGravity;
        }
        for (int i = 0; i < MAXPLAYERS; i++)
            if (playeringame[i] && players[i].mo is "CaelumPlayer")
                CaelumPlayer(players[i].mo).RefreshActiveCraftingStationSession();
    }

    void PresentReturnDoor(bool ready)
    {
        if (!ReturnDoorPrepared)
        {
            // Retira también el Exit provisional serializado en saves 0u.
            for (int i = 0; i < level.lines.Size(); i++)
            {
                let line = level.lines[i];
                if (line.v1.p == (-2464.0, -64.0) && line.v2.p == (-2464.0, 64.0))
                {
                    line.special = 0;
                    line.sidedef[0].SetTexture(Side.mid,
                        TexMan.CheckForTexture("CMDR03", TexMan.Type_Wall));
                    break;
                }
            }
            ReturnDoorPrepared = true;
        }
        if (!ready) return;
        if (ReturnDoor == null)
        {
            let it = ThinkerIterator.Create("CaelumM00ReturnDoor");
            ReturnDoor = CaelumM00ReturnDoor(it.Next());
            if (ReturnDoor == null)
                ReturnDoor = CaelumM00ReturnDoor(Actor.Spawn("CaelumM00ReturnDoor", (-2438,0,0), NO_REPLACE));
            if (ReturnDoor != null) ReturnDoor.StoryPlaced = true;
        }
    }

    void PresentFool(bool needed, bool revealed)
    {
        if (!needed)
        {
            if (FoolEssence != null) FoolEssence.Destroy();
            FoolEssence = null;
            return;
        }
        if (FoolEssence == null)
        {
            let iterator = ThinkerIterator.Create("CaelumM00FoolEssence");
            CaelumM00FoolEssence found;
            while ((found = CaelumM00FoolEssence(iterator.Next())) != null)
                if (found.StoryPlaced) { FoolEssence = found; break; }
            if (FoolEssence == null)
            {
                FoolEssence = CaelumM00FoolEssence(Actor.Spawn("CaelumM00FoolEssence",
                    CaelumMainM00FoolCapture.GetSpot(), NO_REPLACE));
                if (FoolEssence != null) FoolEssence.StoryPlaced = true;
            }
        }
        if (FoolEssence != null && FoolEssence.CaptureUser == null)
            FoolEssence.SetRevealed(revealed);
    }

    // Se reutilizan las estaciones de las dos filas exteriores: así las
    // referencias de tareas guardadas siguen apuntando al mismo actor.
    CaelumCraftingStation PlaceStation(Class<CaelumCraftingStation> kind,
        Vector3 origin, int group, double facing)
    {
        CaelumCraftingStation station = null;
        let iterator = ThinkerIterator.Create("CaelumCraftingStation");
        CaelumCraftingStation candidate;
        while ((candidate = CaelumCraftingStation(iterator.Next())) != null)
        {
            if (candidate.GetClass() == kind && (candidate.CraftingRoomGroup == group
                || candidate.CraftingRoomGroup == 0
                    && candidate.Pos.X >= -500 && candidate.Pos.X <= 500
                    && candidate.Pos.Y >= 780 && candidate.Pos.Y <= 1060
                    && Abs(candidate.Pos.Z) < 1))
            { station = candidate; break; }
        }
        if (station == null) station = CaelumCraftingStation(Actor.Spawn(kind, origin, NO_REPLACE));
        if (station != null)
        {
            station.SetOrigin(origin, false);
            station.Angle = facing;
            station.Vel = (0, 0, 0);
            station.CraftingRoomGroup = group;
            station.bCanPass = true;
        }
        return station;
    }

    void PlaceRoomStations(int group, Vector3 origin, int yDirection)
    {
        // Componentes y procesamiento cuentan: una armadura pesada también
        // necesita correas y tejido. Sin mesa maestra en las cuatro habitaciones.
        Class<CaelumCraftingStation> kinds[12];
        kinds[0] = "CaelumWorkbenchStation";
        kinds[1] = "CaelumForgeStation";
        kinds[2] = "CaelumAnvilStation";
        kinds[3] = "CaelumArmorWorkshopStation";
        kinds[4] = "CaelumSewingMachineStation";
        int count = 5;
        if (group == 2)
        {
            kinds[5] = "CaelumRangedWorkshopStation";
            kinds[6] = "CaelumSawmillStation";
            count = 7;
        }
        if (group == 4 || group == 5)
        {
            kinds[5] = "CaelumEssenceAltarStation";
            kinds[6] = "CaelumGlobeStation";
            kinds[7] = "CaelumJewelerBenchStation";
            kinds[8] = "CaelumFineToolsBenchStation";
            count = 9;
        }
        if (group == 5)
        {
            kinds[9] = "CaelumRangedWorkshopStation";
            kinds[10] = "CaelumSawmillStation";
            kinds[11] = "CaelumMasterBenchStation";
            count = 12;
        }
        int across = count > 7 ? 5 : 3;
        int xDirection = group == 2 || group == 3 ? -1 : 1;
        for (int i = 0; i < count; i++)
        {
            Vector3 position;
            double facing;
            if (group == 5)
            { position = (-336, -308 + i * 56, 264); facing = 0; }
            else
            {
                // Dos paredes contiguas, lejos del umbral central.
                position = origin + (i < across ? i * 56 * xDirection : 0,
                    i < across ? 0 : -(i - across + 1) * 56 * yDirection, 0);
                facing = i < across ? (yDirection > 0 ? 270 : 90)
                    : (xDirection > 0 ? 0 : 180);
            }
            PlaceStation(kinds[i], position, group, facing);
        }
    }

    void PlantGardenNode(Class<CaelumTreeEnvironmentProp> kind, Vector3 origin, double remaining)
    {
        let plant = CaelumTreeEnvironmentProp(Actor.Spawn(kind, origin, NO_REPLACE));
        if (plant == null) return;
        plant.EnsureResourceState();
        plant.ResourceRemainingUnits = plant.GetResourceCapacityUnits() * Clamp(remaining, 0.0, 1.0);
    }

    void PrepareMansionLayout()
    {
        if (MansionLayoutPrepared || level.MapName != "MAP01") return;
        MansionLayoutPrepared = true;
        // Primero la red completa: las doce estaciones originales mantienen
        // su identidad. Las seis de prueba también se trasladan a dormitorios.
        PlaceRoomStations(5, (240, 224, 264), 1);
        PlaceRoomStations(1, (-318, 230, 136), 1);   // Rulo.
        PlaceRoomStations(2, (900, 230, 136), 1);    // Ronnie.
        PlaceRoomStations(3, (900, -230, 136), -1);  // Argento.
        PlaceRoomStations(4, (-318, -230, 136), -1); // Caella.
        // Trasladar cualquier estación de prueba que no consumió la red anterior.
        let stations = ThinkerIterator.Create("CaelumCraftingStation");
        CaelumCraftingStation extra;
        int spare = 0;
        while ((extra = CaelumCraftingStation(stations.Next())) != null)
            if (extra.CraftingRoomGroup == 0 && extra.Pos.X >= -500 && extra.Pos.X <= 500
                && extra.Pos.Y >= 780 && extra.Pos.Y <= 1060 && Abs(extra.Pos.Z) < 1)
            {
                extra.SetOrigin((320 + spare * 56, 144, 264), false);
                extra.CraftingRoomGroup = 5;
                spare++;
            }
        // No se cancelan las tareas ni se consumen reservas al cambiar el lugar.
        for (int i = 0; i < MAXPLAYERS; i++)
        {
            if (!playeringame[i]) continue;
            let user = CaelumPlayer(players[i].mo);
            if (user != null && user.ActiveCraftingStationActor != null)
                user.RefreshActiveCraftingStationSession();
        }

        double bushCapacity = 0, bushRemaining = 0;
        double treeCapacity = 0, treeRemaining = 0;
        let plants = ThinkerIterator.Create("CaelumTreeEnvironmentProp");
        CaelumTreeEnvironmentProp old;
        while ((old = CaelumTreeEnvironmentProp(plants.Next())) != null)
        {
            if (old.Pos.Z >= -100) continue;
            old.EnsureResourceState();
            if (old is "CaelumFiberBush")
            {
                // GZDoom omite propiedades iguales al Default en el guardado.
                // Al cargar 0l con el Default nuevo, Mass ya puede ser 10 aunque
                // su reserva siga expresada contra los 100 kg originales.
                double legacyCapacity = (old.args[4] > 0 ? double(old.args[4]) : 100.0)
                    / CaelumConstants.MATERIAL_UNIT_WEIGHT;
                bushCapacity += legacyCapacity;
                bushRemaining += Clamp(old.ResourceRemainingUnits, 0.0, legacyCapacity);
            }
            else
            { treeCapacity += old.GetResourceCapacityUnits(); treeRemaining += old.ResourceRemainingUnits; }
            old.Destroy();
        }
        // Conservar la proporción agotada de guardados anteriores, sin rellenar
        // por cargar. La masa ya no representa un volumen de follaje macizo.
        double fiberFraction = bushCapacity > 0 ? bushRemaining / bushCapacity : 1;
        double woodFraction = treeCapacity > 0 ? treeRemaining / treeCapacity : 1;
        PlantGardenNode("CaelumTreeCoastCeiboYoung", (-780, -270, 0), woodFraction);
        PlantGardenNode("CaelumTreeCoastCeiboYoung", (-780, 270, 0), woodFraction);
        PlantGardenNode("CaelumTreeCoastCeiboYoung2", (-1260, -430, 0), woodFraction);
        PlantGardenNode("CaelumTreeCoastCeiboYoung3", (-1260, 430, 0), woodFraction);
        for (int side = -1; side <= 1; side += 2)
            for (int i = 0; i < 10; i++)
                PlantGardenNode("CaelumFiberBush", (-720.0 - double(i % 5) * 125.0,
                    double(side) * (160.0 + double(i / 5) * 160.0), 0), fiberFraction);
    }

    void PrepareCornerLayout()
    {
        if (CornerLayoutPrepared || level.MapName != "MAP01") return;
        CornerLayoutPrepared = true;
        PlaceRoomStations(1, (-432, 512, 136), 1);
        PlaceRoomStations(2, (1176, 512, 136), 1);
        PlaceRoomStations(3, (1176, -512, 136), -1);
        PlaceRoomStations(4, (-432, -512, 136), -1);
        PlaceRoomStations(5, (-336, 0, 264), 1);
        for (int i = 0; i < MAXPLAYERS; i++)
            if (playeringame[i] && players[i].mo is "CaelumPlayer")
                CaelumPlayer(players[i].mo).RefreshActiveCraftingStationSession();
    }

    void PrepareNaturalSupplies()
    {
        if (NaturalSuppliesPrepared || level.MapName != "MAP01") return;
        NaturalSuppliesPrepared = true;
        // Reutilizar el cajón serializado: ahora sólo administra cuero.
        let old = ThinkerIterator.Create("CaelumMainM00SupplyChest");
        RonnieSupplyChest = CaelumMainM00SupplyChest(old.Next());
        if (RonnieSupplyChest == null)
            RonnieSupplyChest = CaelumMainM00SupplyChest(Actor.Spawn("CaelumMainM00SupplyChest", (1780,640,-384), NO_REPLACE));
        if (RonnieSupplyChest != null) RonnieSupplyChest.Angle = 270;
        Class<CaelumMineralVeinEnvironmentProp> kinds[5];
        kinds[0] = "CaelumVeinRuby"; kinds[1] = "CaelumVeinSapphire";
        kinds[2] = "CaelumVeinEmerald"; kinds[3] = "CaelumVeinTopaz";
        kinds[4] = "CaelumVeinOpal";
        for (int i = 0; i < 5; i++)
            Actor.Spawn(kinds[i], (i == 4 ? 1760 : 1080 + i * 180, 1210, -384), NO_REPLACE);
    }

    void PrepareBullRoom()
    {
        if (BullRoomPrepared || level.MapName != "MAP01") return;
        BullRoomPrepared = true;
        TrialBull = CaelumM00Bull(Actor.Spawn("CaelumM00Bull", (-2180,0,0), NO_REPLACE));
        let it = ThinkerIterator.Create("CaelumArgento"); let keeper = Actor(it.Next());
        if (keeper != null && keeper.FindInventory("CaelumSilverKey") == null)
        {
            // TryPickup de las llaves exige jugador: el custodio recibe la
            // instancia directamente, sin simular una recogida del mundo.
            let key = Inventory(Actor.Spawn("CaelumSilverKey", keeper.Pos, NO_REPLACE));
            if (key != null) key.AttachToOwner(keeper);
        }
    }

    void PrepareRonnieWorld()
    {
        if (RonnieWorldPrepared || level.MapName != "MAP01") return;
        RonnieWorldPrepared = true;
        // Sustituye la antigua espada de suelo por el préstamo de Ronnie.
        // Las que ya están en inventario se adoptan por identidad al elegir.
        let iterator = ThinkerIterator.Create("CaelumM01SwordPickup");
        CaelumM01SwordPickup sword;
        while ((sword = CaelumM01SwordPickup(iterator.Next())) != null)
            if (sword.Owner == null) sword.Destroy();
        // 0n: gemas en vetas; el cajón conserva cuero para los guanteletes.
    }

    // Retira una sola vez el antiguo surtido de las seis primeras salas.
    // Mantener el WAD permite continuar guardados: GZDoom valida su checksum.
    // El marcador nuevo también migra guardados 0j; no vacía el inventario ni
    // los objetos que el jugador haya soltado, ni afecta puertas o estaciones.
    void RetireGroundFloorStock()
    {
        if (GroundFloorStockRetired || level.MapName != "MAP01") return;
        GroundFloorStockRetired = true;
        let iterator = ThinkerIterator.Create("Inventory");
        Inventory item;
        while ((item = Inventory(iterator.Next())) != null)
        {
            if (item.Owner != null || item.bDropped) continue;
            Vector3 origin = item.SpawnPoint;
            if (origin.X <= -569 || origin.X >= 1305
                || Abs(origin.Y) <= 96 || Abs(origin.Y) >= 640
                || Abs(origin.Z) > 0.01) continue;
            Name kind = item.GetClassName();
            if (kind == 'CaelumWeaponPickup' || kind == 'CaelumArmorPickup'
                || kind == 'CaelumShieldPickup' || kind == 'CaelumAmuletPickup'
                || kind == 'CaelumSealPickup' || kind == 'CaelumMaterialPickup'
                || kind == 'CaelumCarbineAmmo' || kind == 'CaelumArrowAmmo'
                || kind == 'CaelumBoltAmmo' || kind == 'CaelumLifePotion'
                || kind == 'CaelumAnimaPotion' || kind == 'CaelumEnergyDrink'
                || kind == 'CaelumFoodRation' || kind == 'CaelumWaterRation'
                || kind == 'CaelumSilverKey' || kind == 'CaelumSealedLetter')
                item.Destroy();
        }
    }

    void RetireLegacyProcessingManual()
    {
        if (ProcessingManualRetired || level.MapName != "MAP01") return;
        ProcessingManualRetired = true;
        // Quita el ejemplar de los antiguos talleres exteriores, también al
        // cargar 0n. No altera el WAD, el inventario ni las recetas aprendidas.
        let iterator = ThinkerIterator.Create("CaelumProcessingManual");
        CaelumProcessingManual manual;
        while ((manual = CaelumProcessingManual(iterator.Next())) != null)
        {
            if (manual.Owner != null || manual.bDropped) continue;
            Vector3 origin = manual.SpawnPoint;
            if (origin.X == -364 && origin.Y == 800 && Abs(origin.Z) < 0.01)
                manual.Destroy();
        }
    }

    void PrepareWorld()
    {
        if (WorldPrepared) return;
        WorldPrepared = true;
        // Identificar la abertura aceptada por sus extremos, sin índices de
        // sidedef ni cambios del WAD que invaliden una partida anterior.
        for (int i = 0; i < level.lines.Size(); i++)
        {
            let candidate = level.lines[i];
            if (candidate.v1.p == (1842.0, -383.0)
                && candidate.v2.p == (1842.0, -287.0))
            { Passage = candidate; break; }
        }
        let iterator = ThinkerIterator.Create("CaelumM00ElementRune");
        CaelumM00ElementRune rune;
        while ((rune = CaelumM00ElementRune(iterator.Next())) != null)
            if (rune.SequenceSlot >= 0 && rune.SequenceSlot < 4) Runes[rune.SequenceSlot] = rune;
    }

    void PresentMagicTrial(bool started, bool opened, int sequence)
    {
        PrepareWorld();
        if (Passage == null) return;
        if (!PassageTextureRestored)
        {
            // CMIN01 es la cara original del WAD. Recupera también guardados
            // 0l donde ya se había borrado la textura del pasadizo completado.
            for (int sideIndex = 0; sideIndex < 2; sideIndex++)
                Passage.sidedef[sideIndex].SetTexture(Side.mid,
                    TexMan.CheckForTexture("CMIN01", TexMan.Type_Wall));
            PassageTextureRestored = true;
        }
        if (opened && !PassageOpen)
        {
            Passage.flags &= ~(Line.ML_3DMIDTEX | Line.ML_3DMIDTEX_IMPASS);
            PassageOpen = true;
        }
        else if (!opened && !PassageSealed)
        {
            // Colisión limitada a la altura de la textura, igual que el resto
            // de la fachada. No levanta una barrera hasta el cielo/upstairs.
            Passage.flags |= Line.ML_3DMIDTEX;
            PassageSealed = true;
        }
        if (!started) return;
        for (int slot = 0; slot < 4; slot++)
        {
            if (Runes[slot] == null)
            {
                // Orden visual distinto de la solución: Agua, Fuego, Tierra, Aire.
                int position = slot == 0 ? 2 : slot == 1 ? 3 : slot == 2 ? 1 : 0;
                Runes[slot] = CaelumM00ElementRune(Actor.Spawn("CaelumM00ElementRune",
                    (1826.0, -370.0 + position * 24.0, 38.0), NO_REPLACE));
                if (Runes[slot] == null) continue;
                Runes[slot].Configure(CaelumPersistentCharacterState.GetMainM00RuneElement(slot), slot);
            }
            Runes[slot].bSolid = !opened;
            Runes[slot].Lit = sequence > slot;
            Runes[slot].Alpha = Runes[slot].Lit ? 1.0 : 0.45;
        }
    }

    override void WorldTick()
    {
        if (!SewerNetworkPrepared)
        {
            CaelumSewerTravel.PrepareWorld();
            SewerNetworkPrepared = true;
        }
        RetireGroundFloorStock();
        RetireLegacyProcessingManual();
        PrepareRonnieWorld();
        PrepareMansionLayout();
        PrepareCornerLayout();
        PrepareNaturalSupplies();
        PrepareBullRoom();
        RecoverChannelInfrastructure();
        bool foolNeeded = false;
        bool foolRevealed = false;
        bool returnReady = false;
        bool started = false;
        bool opened = false;
        int sequence = 0;
        for (int playerIndex = 0; playerIndex < MAXPLAYERS; playerIndex++)
        {
            if (!playeringame[playerIndex]) { continue; }
            CaelumPlayer caelumPlayer = CaelumPlayer(players[playerIndex].mo);
            if (caelumPlayer == null || caelumPlayer.player == null
                || (caelumPlayer.player.cheats & CF_PREDICTING))
            {
                continue;
            }
            caelumPlayer.UpdateMainM00Prologue();
            CaelumWorldProgress.Update(caelumPlayer);
            CaelumSideQuestRules.Update(caelumPlayer);
            CaelumMainM00MagicTrial.Update(caelumPlayer);
            CaelumMainM00RonnieTrial.Update(caelumPlayer);
            CaelumMainM00RuloTrial.Update(caelumPlayer);
            CaelumMainM00FoolCapture.Sync(caelumPlayer);
            CaelumMainM00Return.Update(caelumPlayer);
            if (level.MapName != "MAP01") continue;
            let record = caelumPlayer.GetPersistentCharacterState(false);
            if (record == null) continue;
            foolNeeded = foolNeeded || record.CanCaptureMainM00Fool();
            foolRevealed = foolRevealed || record.MainM00FoolRevealed;
            returnReady = returnReady || record.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_EXIT_READY);
            started = started || record.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_CAELLA_STARTED);
            opened = opened || record.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_SECRET_PASSAGE_OPEN);
            sequence = Max(sequence, record.MainM00RuneSequenceIndex);
        }
        if (level.MapName == "MAP01")
        {
            PresentMagicTrial(started, opened, sequence);
            PresentFool(foolNeeded, foolRevealed);
            PresentReturnDoor(returnReady);
        }
    }
}

class CaelumM00Bull : CaelumBull
{
    bool TrialReleased;
    CaelumPlayer TrialFighter;
    int TrialGraceTicks;

    void ResetAttempt(CaelumPlayer user)
    {
        StopBullCharge();
        SetOrigin((-2180,0,0), false); Vel = (0,0,0); Angle = 0;
        health = CombatMaximumHealth;
        CurrentCombatAir = MaximumCombatAir; CurrentCombatAnima = MaximumCombatAnima;
        CurrentCombatLucidity = CaelumConstants.MAXIMUM_LUCIDITY;
        CombatLucidityPhysicalStunRemaining = 0;
        ElementalStatus = new("CaelumElementalStatus");
        Target = user; TrialFighter = user; TrialReleased = true;
        TrialGraceTicks = 2 * TICRATE; bShootable = false;
        SetStateLabel("TrialIdle");
    }

    bool LeatherDropped;
    int LeatherBudgetUnits;

    // Se conserva LeatherBudgetUnits al leer 0p; ya no decide el rendimiento.
    bool RuloPartyPrepared;

    int GetLeatherYieldUnits()
    {
        // Modelo explícito: piel fresca = 6 % de la masa. Curtido acabado:
        // 255 / 1100 del peso fresco (balance UNIDO), redondeado a 0,1 kg.
        // Para 900 kg: 54 kg de piel fresca -> 12,5 kg de cuero utilizable.
        return int(Floor(Mass * 0.06 * (255.0 / 1100.0) * 10.0 + 0.5)) * 100;
    }

    bool IsTrialOpponent(Actor candidate)
    {
        if (candidate == null || candidate.health <= 0 || !CaelumMainM00RuloTrial.InArena(candidate)) return false;
        if (candidate == TrialFighter) return true;
        let ally = CaelumAnchoredResident(candidate);
        return ally != null && ally.RuloPartyBull == self && ally.IsRuloPartyFighting();
    }

    Actor FindTrialOpponent()
    {
        Actor closest = TrialFighter;
        double distance = closest != null ? Distance2D(closest) : 999999.0;
        let it = ThinkerIterator.Create("CaelumAnchoredResident"); CaelumAnchoredResident ally;
        while ((ally = CaelumAnchoredResident(it.Next())) != null)
            if (IsTrialOpponent(ally) && Distance2D(ally) < distance)
            { closest = ally; distance = Distance2D(ally); }
        return closest;
    }

    override void Tick()
    {
        if (health > 0)
        {
            if (!TrialReleased) { Vel = (0,0,0); Target = null; bShootable = false; return; }
            if (TrialGraceTicks > 0)
            {
                TrialGraceTicks--; Vel = (0,0,0); bShootable = false;
                if (TrialGraceTicks == 0) SetStateLabel("See");
                return;
            }
            bShootable = true;
            if (!IsTrialOpponent(Target)) Target = FindTrialOpponent();
            if (!CaelumMainM00RuloTrial.InArena(self))
            { StopBullCharge(); SetOrigin((-2180,0,0), false); }
        }
        Super.Tick();
        if (health > 0 || LeatherDropped) return;
        LeatherDropped = true;
        CaelumMainM00RuloTrial.SetArenaDoors(false, true);
        // La masa y la merma gobiernan el botín, nunca el talle del viajero.
        // Pilas de 2,5 kg para no exigir cargar todo de una vez.
        LeatherBudgetUnits = GetLeatherYieldUnits();
        let recipient = CaelumPlayer(TrialFighter);
        bool limited = CaelumMainM00SupplyRules.IsLimited(recipient);
        int remaining = limited ? Min(LeatherBudgetUnits,
            CaelumMainM00SupplyRules.Remaining(recipient, CaelumConstants.MATERIAL_LEATHER)) : LeatherBudgetUnits;
        int i = 0;
        while (remaining > 0)
        {
            int amount = Min(2500, remaining);
            double direction = (i % 12) * 30.0;
            double radius = 4;
            let leather = CaelumMaterialPickup(Spawn("CaelumMaterialPickup",
                Pos + (Cos(direction)*radius,Sin(direction)*radius,8), NO_REPLACE));
            if (leather != null)
            {
                leather.args[0] = CaelumConstants.MATERIAL_LEATHER;
                leather.args[1] = 1; leather.Amount = amount;
                leather.LimboQuestUnits = amount; leather.bDropped = true;
                if (limited)
                {
                    leather.LimboQuotaReserved = true;
                    leather.LimboQuotaPlayer = recipient.PlayerNumber();
                    CaelumMainM00SupplyRules.Issue(recipient, CaelumConstants.MATERIAL_LEATHER, amount);
                }
            }
            remaining -= amount; i++;
        }
        for (int n = 0; n < MAXPLAYERS; n++)
            if (playeringame[n] && players[n].mo is "CaelumPlayer")
            {
                let user = CaelumPlayer(players[n].mo);
                user.GetPersistentCharacterState(true).SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_BULL_DEFEATED);
                CaelumMainM00RuloTrial.Sync(user);
                CaelumMainM00MagicTrial.Feedback(user, "CA_M01_RULO_BULL_WON");
            }
    }

    // Anticipación más legible del ejemplar tutorial; la cornada conserva
    // su daño, anatomía y consumo nativos. El cadáver se disipa una sola vez.
    States
    {
    Melee:
        BULL F 18 A_FaceTarget;
        BULL G 5 A_CaelumBeginBullCharge;
        BULL G 0 A_CaelumProfiledMeleeAttack(CaelumConstants.BULL_GORE_BASE_DAMAGE);
        BULL G 0 A_CaelumEndBullCharge;
        Goto See;
    Death:
        BULL I 0 A_CaelumEndBullCharge;
        BULL I 5 A_Scream;
        BULL JKLM 5;
        BULL N 35 A_NoBlocking;
    Dissipate:
        BULL N 4 A_FadeOut(0.1);
        Loop;
    TrialIdle:
        BULL A -1;
        Stop;
    }
}
