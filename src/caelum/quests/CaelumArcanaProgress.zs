// #33: la disponibilidad no entrega cartas. El Inventory viajero conserva
// progreso; la aparición y el diálogo comparten la captura original de El loco.
class CaelumArcanaProgress : Object play
{
    const REVISION = 1;

    static bool PortRewardsComplete(CaelumPersistentCharacterState record)
    {
        if (record == null) return false;
        for (int i = 0; i < CaelumConstants.PRISONER_COUNT; i++)
            if (record.GetPrisonerRescueState(i) == CaelumConstants.PRISONER_STATE_EXTRACTED
                && !record.IsPrisonerRewardClaimed(i)) return false;
        return true;
    }

    static void EnsureRevision(CaelumPersistentCharacterState record)
    {
        if (record == null || record.ArcanaStateRevision >= REVISION) return;
        // No se deduce victoria de la ausencia de un actor. La carta ya obtenida
        // sí prueba progreso anterior, que nunca se revoca ni vuelve a premiar.
        if (record.HasTarotCard(CaelumConstants.TAROT_CUPS_ACE)) record.SewerZupayDefeated = true;
        record.ArcanaStateRevision = REVISION;
    }

    // Reversión de campos añadidos, para una copia de recuperación. Nunca toca
    // colección, misión del prólogo, recompensas ni datos anteriores a #33.
    static void RestoreLegacyProgress(CaelumPersistentCharacterState record)
    {
        if (record == null) return;
        record.ArcanaStateRevision = 0;
        record.SewerZupayDefeated = false;
        for (int i = 0; i < CaelumConstants.TAROT_CARD_COUNT; i++)
        { record.ArcanaAvailable[i] = false; record.ArcanaRevealed[i] = false; }
    }

    static void ConfirmSewerDefeat()
    {
        if (level.MapName != "MAP02") return;
        let controller = CaelumMainM00QuestController(EventHandler.Find("CaelumMainM00QuestController"));
        if (controller != null) controller.SewerBossDefeated = true;
        for (int i = 0; i < MAXPLAYERS; i++)
        {
            if (!playeringame[i]) continue;
            let user = CaelumPlayer(players[i].mo);
            if (user == null) continue;
            let record = user.GetPersistentCharacterState(false);
            if (record != null)
            {
                CaelumDemoNarrative.EnsureRevision(record);
                record.SewerZupayDefeated = true;
            }
        }
    }

    static bool CanCapture(CaelumPersistentCharacterState record, int card)
    {
        if (record == null || record.HasTarotCard(card)) return false;
        if (card == CaelumConstants.TAROT_CUPS_ACE)
            return level.MapName == "MAP02" && record.SewerZupayDefeated;
        if (card == CaelumConstants.TAROT_WANDS_KNIGHT)
            return level.MapName == "MAP06" && record.ArcanaAvailable[card]
                && CaelumDemoNarrative.PortCardReady(record);
        return false;
    }

    static void UpdateEssence(CaelumM00FoolEssence essence)
    {
        // Un As guardado antes de #33 podía conservar FLOATBOB.
        essence.bFloatBob = false;
        bool available = false, revealed = false;
        for (int i = 0; i < MAXPLAYERS; i++)
        {
            if (!playeringame[i]) continue;
            let user = CaelumPlayer(players[i].mo);
            if (!essence.IsAvailable(user)) continue;
            available = true;
            revealed = revealed || essence.IsRevealedFor(user.GetPersistentCharacterState(false));
        }
        essence.bInvisible = !available;
        essence.bSolid = available;
        if (essence.CaptureUser == null) essence.SetRevealed(revealed);
    }

    static void WorldTick()
    {
        let controller = CaelumMainM00QuestController(EventHandler.Find("CaelumMainM00QuestController"));
        if (level.MapName == "MAP02")
        {
            // Cubre cadáveres de partidas anteriores sin confundir un borrado
            // o un actor ausente con una derrota confirmada.
            let it = ActorIterator.Create(43799, "CaelumZupayColossus");
            Actor boss;
            while ((boss = it.Next()) != null)
                if (boss.health <= 0) ConfirmSewerDefeat();
        }
        bool knightNeeded = false;
        for (int i = 0; i < MAXPLAYERS; i++)
        {
            if (!playeringame[i]) continue;
            let user = CaelumPlayer(players[i].mo);
            if (user == null || user.player == null || (user.player.cheats & CF_PREDICTING)) continue;
            let record = user.GetPersistentCharacterState(false);
            if (record == null) continue;
            EnsureRevision(record);
            if (level.MapName == "MAP02" && controller != null && controller.SewerBossDefeated)
                record.SewerZupayDefeated = true;
            if (level.MapName == "MAP06" && user.CharacterCreationComplete
                && !user.CreationWizardOpen && record.ProfileCommitted && CaelumDemoNarrative.PortCardReady(record))
                record.ArcanaAvailable[CaelumConstants.TAROT_WANDS_KNIGHT] = true;
            knightNeeded = knightNeeded || CanCapture(record, CaelumConstants.TAROT_WANDS_KNIGHT);
        }
        if (knightNeeded && ThinkerIterator.Create("CaelumWandsKnightEssence").Next() == null)
            Actor.Spawn("CaelumWandsKnightEssence", CaelumArcanaPlacement.PortSpot(), NO_REPLACE);
    }
}
