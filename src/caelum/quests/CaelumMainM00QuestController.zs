// Controlador reconstruible de MAP01. No guarda progreso propio: consulta el
// Inventory viajero de cada personaje y sólo ejecuta presentaciones pendientes.
class CaelumMainM00QuestController : EventHandler
{
    Line Passage;
    CaelumM00ElementRune Runes[4];
    bool WorldPrepared;
    bool PassageOpen;
    bool PassageSealed;
    bool GroundFloorStockRetired;
    bool RonnieWorldPrepared;
    CaelumMainM00SupplyChest RonnieSupplyChest;

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
        RonnieSupplyChest = CaelumMainM00SupplyChest(Actor.Spawn("CaelumMainM00SupplyChest",
            (1780.0, 640.0, -384.0), NO_REPLACE));
        if (RonnieSupplyChest != null) RonnieSupplyChest.Angle = 270;
        Actor.Spawn("CaelumFiberBush", (1250.0, 820.0, -384.0), NO_REPLACE);
        Actor.Spawn("CaelumFiberBush", (1440.0, 1080.0, -384.0), NO_REPLACE);
        Actor.Spawn("CaelumFiberBush", (1670.0, 700.0, -384.0), NO_REPLACE);
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
        if (opened && !PassageOpen)
        {
            Passage.flags &= ~(Line.ML_3DMIDTEX | Line.ML_3DMIDTEX_IMPASS);
            for (int sideIndex = 0; sideIndex < 2; sideIndex++)
                Passage.sidedef[sideIndex].SetTexture(Side.mid, TexMan.CheckForTexture("-", TexMan.Type_Wall));
            PassageOpen = true;
        }
        else if (started && !opened && !PassageSealed)
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
            Runes[slot].Alpha = opened ? 0.0 : Runes[slot].Lit ? 1.0 : 0.45;
        }
    }

    override void WorldTick()
    {
        RetireGroundFloorStock();
        PrepareRonnieWorld();
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
            CaelumMainM00MagicTrial.Update(caelumPlayer);
            CaelumMainM00RonnieTrial.Update(caelumPlayer);
            if (level.MapName != "MAP01") continue;
            let record = caelumPlayer.GetPersistentCharacterState(false);
            if (record == null) continue;
            started = started || record.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_CAELLA_STARTED);
            opened = opened || record.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_SECRET_PASSAGE_OPEN);
            sequence = Max(sequence, record.MainM00RuneSequenceIndex);
        }
        if (level.MapName == "MAP01") PresentMagicTrial(started, opened, sequence);
    }
}
