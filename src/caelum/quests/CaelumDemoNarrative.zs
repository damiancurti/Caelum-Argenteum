// #34: cola persistente por personaje. USDF mantiene la pausa nativa existente.
class CaelumDemoNarrative : Object play
{
    const REVISION = 1;
    const EVENT_COUNT = 11;
    const CONVERSATION_BASE = 43480;
    const SEWER_DEFEATED = 4;
    const PORT_START = 9;
    const PORT_COMPLETE = 10;

    static bool IsPalomo(CaelumPlayer user)
    {
        return CaelumMainM00RonnieTrial.CanInteract(user)
            && user.player.ConversationNPC is "CaelumPalomo"
            && user.HasActiveConversation();
    }

    static int ObservedEvents(CaelumPersistentCharacterState record)
    {
        int mask = 0;
        for (int i = 0; i < CaelumConstants.PRISONER_COUNT; i++)
        {
            if (record.GetPrisonerRescueState(i) != CaelumConstants.PRISONER_STATE_CAPTIVE)
                mask |= 1 << i;
            if (record.IsPrisonerRewardClaimed(i)) mask |= 1 << (5 + i);
        }
        if (record.SewerZupayDefeated) mask |= 1 << SEWER_DEFEATED;
        if (record.PortSiegeNarrativeStarted) mask |= 1 << PORT_START;
        if (record.PortSiegeNarrativeComplete) mask |= 1 << PORT_COMPLETE;
        return mask;
    }

    static void EnsureRevision(CaelumPersistentCharacterState record)
    {
        if (record == null || record.DemoNarrativeRevision >= REVISION) return;
        CaelumArcanaProgress.EnsureRevision(record);
        // No recitar liberaciones ni pagos anteriores a la incorporación del guion.
        // No deducir heridas de salud actual: un guardado antiguo no las registraba.
        record.DemoNarrativeDelivered |= ObservedEvents(record);
        record.DemoNarrativeRevision = REVISION;
    }

    static void RestoreLegacyProgress(CaelumPersistentCharacterState record)
    {
        if (record == null) return;
        record.DemoNarrativeRevision = 0;
        record.DemoNarrativePending = 0;
        record.DemoNarrativeDelivered = 0;
        record.PalomoSleepLessonStarted = false;
        record.PalomoSleepLessonComplete = false;
        record.PortSiegeNarrativeStarted = false;
        record.PortSiegeNarrativeComplete = false;
        int quest = CaelumConstants.QUEST_PORT_SIEGE;
        record.QuestState[quest] = CaelumConstants.QUEST_STATE_UNDISCOVERED;
        record.QuestStage[quest] = 0;
        for (int objective = 0; objective < 2; objective++)
        {
            int slot = record.GetQuestObjectiveStorageIndex(quest, objective);
            record.QuestObjectiveKnown[slot] = false;
            record.QuestObjectiveProgress[slot] = 0;
            record.QuestObjectiveTarget[slot] = 0;
        }
        for (int i = 0; i < 4; i++) record.BullEncounterSeverity[i] = 0;
    }

    static void Sync(CaelumPlayer user)
    {
        let record = user.GetPersistentCharacterState(false);
        if (record == null) return;
        for (int i = 0; i < 4; i++) user.BullNarrativeSeveritySnapshot[i] = record.BullEncounterSeverity[i];
        user.PalomoSleepLessonStartedSnapshot = record.PalomoSleepLessonStarted;
        user.PalomoSleepLessonCompleteSnapshot = record.PalomoSleepLessonComplete;
    }

    static CaelumSiegeEncounter PortEncounter()
    {
        if (level.MapName != "MAP06") return null;
        let it = ThinkerIterator.Create("CaelumSiegeEncounter");
        CaelumSiegeEncounter encounter;
        while ((encounter = CaelumSiegeEncounter(it.Next())) != null)
            if (encounter.RosterSealed && encounter.Machines.Size() == 12 && encounter.Boss != null)
                return encounter;
        return null;
    }

    static bool PortCardReady(CaelumPersistentCharacterState record)
    {
        if (record == null) return false;
        // #16 exige victoria real; una carta antigua poseída nunca se revoca.
        let encounter = PortEncounter();
        if (encounter != null) return encounter.Victory;
        if (record.PortSiegeNarrativeStarted) return record.PortSiegeNarrativeComplete;
        return !CaelumPortData.IsCurrent() && CaelumArcanaProgress.PortRewardsComplete(record);
    }

    static void Update(CaelumPlayer user)
    {
        if (user == null || user.player == null || !user.CharacterCreationComplete
            || user.CreationWizardOpen || (user.player.cheats & CF_PREDICTING)) return;
        let record = user.GetPersistentCharacterState(false);
        if (record == null) return;
        EnsureRevision(record);
        CaelumSiegeIntelligence.ObservePayment(user);
        let encounter = PortEncounter();
        if (encounter != null)
        {
            record.PortSiegeNarrativeStarted = true;
            if (encounter.Victory) record.PortSiegeNarrativeComplete = true;
            int quest = CaelumConstants.QUEST_PORT_SIEGE;
            record.QuestState[quest] = record.PortSiegeNarrativeComplete
                ? CaelumConstants.QUEST_STATE_COMPLETED : CaelumConstants.QUEST_STATE_ACTIVE;
            record.QuestStage[quest] = record.PortSiegeNarrativeComplete ? 2 : 1;
            for (int objective = 0; objective < 2; objective++)
            {
                int slot = record.GetQuestObjectiveStorageIndex(quest, objective);
                record.QuestObjectiveKnown[slot] = true;
                record.QuestObjectiveTarget[slot] = objective == 0 ? 12 : 1;
                record.QuestObjectiveProgress[slot] = objective == 0 ? encounter.NeutralizedCount
                    : encounter.BossDefeated() ? 1 : 0;
            }
            user.RefreshSocialJournalSnapshot();
        }
        record.DemoNarrativePending |= ObservedEvents(record) & ~record.DemoNarrativeDelivered;
        let rest = CaelumRestState.Get(user);
        if (record.PalomoSleepLessonStarted && !record.PalomoSleepLessonComplete
            && level.MapName == "MAP01" && rest != null
            && rest.Status == CaelumRestRules.STATUS_ACTIVE && rest.Mode == CaelumRestRules.MODE_SLEEP
            && rest.Furniture is "CaelumRestBed" && rest.Furniture.SupportsRest(user))
            record.PalomoSleepLessonComplete = true;
        Sync(user);

        if (user.DemoVoiceSpeaker != null)
        {
            if (user.DemoVoiceMap != level.MapName)
                user.DemoVoiceSpeaker = null; // El evento pendiente viaja y se reabre.
            else
            {
                if (user.DemoVoiceSpeaker.bInConversation) return;
                int bit = 1 << user.DemoVoiceSpeaker.EventId;
                record.DemoNarrativeDelivered |= bit;
                record.DemoNarrativePending &= ~bit;
                user.DemoVoiceSpeaker.Destroy();
                user.DemoVoiceSpeaker = null;
                return; // Separar cierres y aperturas; nunca consumir dos diálogos juntos.
            }
        }
        if (record.DemoNarrativePending == 0 || user.health <= 0 || user.HasActiveConversation()
            || user.EquipmentMenuOpen || user.CraftingMenuOpen || user.PalomoMerchantMenuOpen
            || user.CraftingTaskActive || CaelumRestState.IsActive(user)) return;
        int eventId = 0;
        while (eventId < EVENT_COUNT && (record.DemoNarrativePending & (1 << eventId)) == 0) eventId++;
        if (eventId >= EVENT_COUNT) return;
        let voice = CaelumDemoVoiceSpeaker(Actor.Spawn("CaelumDemoVoiceSpeaker", user.Pos, NO_REPLACE));
        if (voice == null) return;
        voice.EventId = eventId;
        Level.ExecuteSpecial(CaelumConstants.GZDOOM_THING_SET_CONVERSATION_SPECIAL,
            voice, null, false, 0, CONVERSATION_BASE + eventId);
        if (!voice.HasConversation() || !voice.StartConversation(user, false, false))
        { voice.Destroy(); return; }
        user.DemoVoiceSpeaker = voice;
        user.DemoVoiceMap = level.MapName;
    }

    static void WorldTick()
    {
        for (int i = 0; i < MAXPLAYERS; i++)
            if (playeringame[i]) Update(CaelumPlayer(players[i].mo));
    }
}

class CaelumDemoVoiceSpeaker : Actor
{
    int EventId;
    Default { Radius 1; Height 1; +NOBLOCKMAP +NOGRAVITY +INVISIBLE }
    States { Spawn: TNT1 A -1; Stop; }
}

class CaelumPalomoSleepLessonAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup)
    {
        let user = CaelumPlayer(Owner);
        if (!CaelumDemoNarrative.IsPalomo(user)) return false;
        let record = user.GetPersistentCharacterState(false);
        if (record == null || !record.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_PALOMO_MET)) return false;
        record.PalomoSleepLessonStarted = true;
        CaelumDemoNarrative.Sync(user);
        return true;
    }
}
