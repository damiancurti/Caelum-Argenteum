// Conversaciones nativas de la prueba de Argento. Las elecciones mutan sólo
// el Inventory persistente del personaje que habla; los tokens son una vista.
class CaelumMainM00SocialDialogue : Object play
{
    static int GetResidentId(Actor speaker)
    {
        if (CaelumRulo(speaker) != null) { return CaelumConstants.MAIN_M00_RESIDENT_RULO; }
        if (CaelumRonnie(speaker) != null) { return CaelumConstants.MAIN_M00_RESIDENT_RONNIE; }
        if (CaelumCaella(speaker) != null) { return CaelumConstants.MAIN_M00_RESIDENT_CAELLA; }
        if (CaelumArgento(speaker) != null) { return CaelumConstants.MAIN_M00_RESIDENT_ARGENTO; }
        return -1;
    }

    static int GetConversationId(int resident)
    {
        switch (resident)
        {
            case CaelumConstants.MAIN_M00_RESIDENT_ARGENTO:
                return CaelumConstants.MAIN_M00_ARGENTO_CONVERSATION_ID;
            case CaelumConstants.MAIN_M00_RESIDENT_RULO:
                return CaelumConstants.MAIN_M00_RULO_CONVERSATION_ID;
            case CaelumConstants.MAIN_M00_RESIDENT_RONNIE:
                return CaelumConstants.MAIN_M00_RONNIE_CONVERSATION_ID;
            case CaelumConstants.MAIN_M00_RESIDENT_CAELLA:
                return CaelumConstants.MAIN_M00_CAELLA_CONVERSATION_ID;
        }
        return 0;
    }

    static double GetLabia(CaelumPlayer user)
    {
        if (user == null || user.Attributes == null || user.DerivedStats == null) { return 0.0; }
        return user.DerivedStats.CalculateType2Percent(user.Attributes.Eloquence);
    }

    static int GetChance(CaelumPlayer user, int resident)
    {
        if (user == null || user.Attributes == null || user.DerivedStats == null) { return 0; }
        double attribute;
        double difficulty;
        if (resident == CaelumConstants.MAIN_M00_RESIDENT_RULO)
        {
            attribute = user.Attributes.Empathy;
            difficulty = CaelumConstants.MAIN_M00_RULO_EMOTION_DIFFICULTY;
        }
        else if (resident == CaelumConstants.MAIN_M00_RESIDENT_CAELLA)
        {
            attribute = user.Attributes.Charisma;
            difficulty = CaelumConstants.MAIN_M00_CAELLA_PERSUASION_DIFFICULTY;
        }
        else { return 0; }
        // Los residentes aún no tienen una facción asignada: reputación neutra,
        // sin reutilizar por accidente la reputación de la Gendarmería.
        double ability = user.DerivedStats.CalculateType4Percent(attribute);
        return Clamp(int(Floor(ability * 100.0 / difficulty + 0.5)), 0, 100);
    }

    static bool CanReceiveSilverKey(CaelumPlayer user)
    {
        if (user == null || level.MapName != "MAP01") return false;
        let r = user.GetPersistentCharacterState(false);
        if (r == null || !r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_ARGENTO_COMPLETE)
            || !r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_CAELLA_COMPLETE)
            || !r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RONNIE_COMPLETE)) return false;
        // Las prácticas de Rulo preceden al Toro; no exigir derrotarlo para
        // obtener la llave del propio recinto. La rama completa también vale.
        if (r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RULO_COMPLETE)) return true;
        for (int f = CaelumConstants.MAIN_M00_FLAG_COMBAT_PRIMARY_USED;
            f <= CaelumConstants.MAIN_M00_FLAG_COMBAT_CHARGED_USED; f++)
            if (!r.HasMainM00Flag(f)) return false;
        return r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RULO_STARTED)
            && r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_COMBAT_AIR_SPENT)
            && r.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_COMBAT_AIR_RECOVERED);
    }

    static bool GiveSilverKey(CaelumPlayer user)
    {
        if (!CanReceiveSilverKey(user) || user.player == null || user.health <= 0) return false;
        let keeper = CaelumArgento(user.player.ConversationNPC);
        if (keeper == null || !keeper.StoryAnchored) return false;
        if (user.FindInventory("CaelumSilverKey") == null)
        {
            let key = keeper.FindInventory("CaelumSilverKey");
            if (key == null || !user.PrepareNativeKeyPickup(CaelumWeightedKey(key))) return false;
            key.DetachFromOwner(); key.AttachToOwner(user);
        }
        user.OnNativeInventoryChanged();
        Sync(user); return true;
    }

    static void Sync(CaelumPlayer user)
    {
        if (user == null) { return; }
        CaelumPersistentCharacterState persistentState = user.GetPersistentCharacterState(true);
        if (persistentState == null) { return; }
        persistentState.EnsureMainM00SocialState();
        user.SetPalomoDialogueToken("CaelumM00SilverKeyReadyToken", CanReceiveSilverKey(user));
        user.SetPalomoDialogueToken("CaelumM00SilverKeyHeldToken", user.FindInventory("CaelumSilverKey") != null);
        persistentState.RefreshMainM00RecruitmentObjective();
        int stage = persistentState.QuestStage[CaelumConstants.QUEST_MAIN_M00_THE_FOOL];
        user.MainM00LabiaSnapshot = GetLabia(user);
        for (int i = 0; i < CaelumConstants.MAIN_M00_RESIDENT_COUNT; i++)
        {
            user.MainM00SocialChanceSnapshot[i] = persistentState.MainM00SocialResult[i]
                == CaelumConstants.MAIN_M00_SOCIAL_UNTRIED
                ? GetChance(user, i) : persistentState.MainM00SocialChance[i];
        }
        user.SetPalomoDialogueToken("CaelumM00SocialReadyToken",
            stage >= CaelumConstants.MAIN_M00_STATE_ARGENTO_ACTIVE);
        user.SetPalomoDialogueToken("CaelumM00ArgentoStartedToken",
            persistentState.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_ARGENTO_STARTED));
        user.SetPalomoDialogueToken("CaelumM00ArgentoCompleteToken",
            persistentState.HasMainM00Flag(CaelumConstants.MAIN_M00_FLAG_ARGENTO_COMPLETE));
        user.SetPalomoDialogueToken("CaelumM00AllConvincedToken",
            persistentState.CountMainM00ConvincedResidents() == CaelumConstants.MAIN_M00_RESIDENT_COUNT);
        user.SetPalomoDialogueToken("CaelumM00RuloConvincedToken", persistentState.IsMainM00ResidentConvinced(0));
        user.SetPalomoDialogueToken("CaelumM00RonnieConvincedToken", persistentState.IsMainM00ResidentConvinced(1));
        user.SetPalomoDialogueToken("CaelumM00CaellaConvincedToken", persistentState.IsMainM00ResidentConvinced(2));
        user.SetPalomoDialogueToken("CaelumM00RuloAttemptedToken",
            persistentState.MainM00SocialResult[0] != CaelumConstants.MAIN_M00_SOCIAL_UNTRIED);
        user.SetPalomoDialogueToken("CaelumM00RuloReadToken",
            persistentState.MainM00SocialResult[0] == CaelumConstants.MAIN_M00_SOCIAL_SUCCESS);
        user.SetPalomoDialogueToken("CaelumM00CaellaAttemptedToken",
            persistentState.MainM00SocialResult[2] != CaelumConstants.MAIN_M00_SOCIAL_UNTRIED);
        user.SetPalomoDialogueToken("CaelumM00CaellaPersuadedToken",
            persistentState.MainM00SocialResult[2] == CaelumConstants.MAIN_M00_SOCIAL_SUCCESS);
        user.SetPalomoDialogueToken("CaelumM00RuloAdviceToken", persistentState.MainM00SocialAdvice[0]);
        user.SetPalomoDialogueToken("CaelumM00RonnieAdviceToken", persistentState.MainM00SocialAdvice[1]);
        user.SetPalomoDialogueToken("CaelumM00CaellaAdviceToken", persistentState.MainM00SocialAdvice[2]);
        user.SetPalomoDialogueToken("CaelumM00RuloAdviceAvailableToken", persistentState.CanReceiveMainM00Advice(0));
        user.SetPalomoDialogueToken("CaelumM00RonnieAdviceAvailableToken", persistentState.CanReceiveMainM00Advice(1));
        user.SetPalomoDialogueToken("CaelumM00CaellaAdviceAvailableToken", persistentState.CanReceiveMainM00Advice(2));
        user.RefreshSocialJournalSnapshot();
    }

    static bool Open(CaelumPlayer user, CaelumAnchoredResident speaker)
    {
        if (user == null || user.player == null || user.health <= 0
            || user.CreationWizardOpen || !user.CharacterCreationComplete
            || speaker == null || !speaker.StoryAnchored || speaker.bInConversation
            || level.MapName != "MAP01") { return false; }
        int resident = GetResidentId(speaker);
        int conversation = GetConversationId(resident);
        if (conversation == 0) { return false; }
        Sync(user);
        CaelumMainM00MagicTrial.Sync(user);
        CaelumMainM00RonnieTrial.Sync(user);
        CaelumMainM00RuloTrial.Sync(user);
        if (user.StaffCastPending) { user.CancelPendingStaffCast(false); }
        user.EquipmentMenuOpen = false;
        user.CloseCraftingStationSession();
        user.SetCraftingJournalState(false);
        Level.ExecuteSpecial(CaelumConstants.GZDOOM_THING_SET_CONVERSATION_SPECIAL,
            speaker, null, false, 0, conversation);
        if (!speaker.HasConversation() || !speaker.StartConversation(user, true, true)) { return false; }
        CaelumPersistentCharacterState persistentState = user.GetPersistentCharacterState(true);
        if (persistentState.RecordMainM00ResidentMet(resident)) { user.PersistCharacterState(); }
        Sync(user);
        return true;
    }

    static bool Attempt(CaelumPlayer user, int resident)
    {
        CaelumPersistentCharacterState persistentState = user.GetPersistentCharacterState(true);
        if (persistentState == null || !persistentState.CanAttemptMainM00SocialCheck(resident)) { return false; }
        int chance = GetChance(user, resident);
        // Comprobar la clave agotada ANTES de consumir el generador aleatorio.
        int roll = chance >= 100 ? 0 : chance <= 0 ? 101
            : Random[CaelumM00Social](1, 100);
        if (!persistentState.RecordMainM00SocialCheck(resident, roll, chance)) { return false; }
        if (resident == CaelumConstants.MAIN_M00_RESIDENT_CAELLA
            && persistentState.MainM00SocialResult[resident] == CaelumConstants.MAIN_M00_SOCIAL_SUCCESS)
        {
            persistentState.ConvinceMainM00Resident(resident);
        }
        return true;
    }

    static bool Apply(CaelumPlayer user, Name actionName)
    {
        if (user == null || user.player == null || user.health <= 0
            || level.MapName != "MAP01") { return false; }
        CaelumAnchoredResident speaker = CaelumAnchoredResident(user.player.ConversationNPC);
        if (speaker == null || !speaker.StoryAnchored) { return false; }
        int resident = GetResidentId(speaker);
        CaelumPersistentCharacterState persistentState = user.GetPersistentCharacterState(true);
        if (persistentState == null) { return false; }
        persistentState.EnsureMainM00SocialState();
        user.SetPalomoDialogueToken("CaelumM00SilverKeyReadyToken", CanReceiveSilverKey(user));
        user.SetPalomoDialogueToken("CaelumM00SilverKeyHeldToken", user.FindInventory("CaelumSilverKey") != null);
        bool changed = false;
        if (resident == CaelumConstants.MAIN_M00_RESIDENT_ARGENTO)
        {
            if (actionName == 'StartArgento') { changed = persistentState.BeginMainM00Argento(); }
            else if (actionName == 'FinishArgento') { changed = persistentState.CompleteMainM00Argento(); }
            else if (actionName == 'RuloAdvice') { changed = persistentState.RecordMainM00Advice(0); }
            else if (actionName == 'RonnieAdvice') { changed = persistentState.RecordMainM00Advice(1); }
            else if (actionName == 'CaellaAdvice') { changed = persistentState.RecordMainM00Advice(2); }
        }
        else if (persistentState.IsMainM00RecruitmentActive())
        {
            if (resident == CaelumConstants.MAIN_M00_RESIDENT_RULO)
            {
                if (actionName == 'ReadRulo') { changed = Attempt(user, resident); }
                else if (actionName == 'RespectRulo'
                    && (persistentState.MainM00SocialResult[resident] == CaelumConstants.MAIN_M00_SOCIAL_SUCCESS
                        || persistentState.MainM00SocialAdvice[resident]))
                { changed = persistentState.ConvinceMainM00Resident(resident); }
            }
            else if (resident == CaelumConstants.MAIN_M00_RESIDENT_RONNIE)
            {
                if ((actionName == 'RonniePlan' && GetLabia(user) >= CaelumConstants.MAIN_M00_RONNIE_MINIMUM_LABIA)
                    || (actionName == 'RonnieAdvicePlan' && persistentState.MainM00SocialAdvice[resident]))
                { changed = persistentState.ConvinceMainM00Resident(resident); }
            }
            else if (resident == CaelumConstants.MAIN_M00_RESIDENT_CAELLA)
            {
                if (actionName == 'PersuadeCaella') { changed = Attempt(user, resident); }
                else if (actionName == 'CaellaSafety' && persistentState.MainM00SocialAdvice[resident])
                { changed = persistentState.ConvinceMainM00Resident(resident); }
            }
        }
        Sync(user);
        if (changed) { user.PersistCharacterState(); }
        return true;
    }
}

// Sólo amplía el formato del menú nativo. La opción gris también se valida en
// Apply, en ámbito play: ningún mensaje de red puede saltarse el requisito.
class CaelumMainM00ConversationMenu : CaelumPalomoConversationMenu
{
    bool IsRonnieOptionBlocked(StrifeDialogueReply reply)
    {
        CaelumPlayer user = mPlayer == null ? null : CaelumPlayer(mPlayer.mo);
        return reply != null && reply.GiveType == "CaelumM00RonniePlanAction"
            && (user == null || user.MainM00LabiaSnapshot < CaelumConstants.MAIN_M00_RONNIE_MINIMUM_LABIA);
    }

    override int FormatReplies(int activereply)
    {
        int result = Super.FormatReplies(activereply);
        int visible = 0;
        for (let reply = mCurNode.Children; reply != null; reply = reply.Next)
        {
            if (reply.ShouldSkipReply(mPlayer)) { continue; }
            if (IsRonnieOptionBlocked(reply))
            {
                for (uint line = mResponses[visible]; line < mResponses[visible + 1]; line++)
                { mResponseLines[line] = "\c[Gray]" .. mResponseLines[line]; }
            }
            visible++;
        }
        return result;
    }

    override bool MenuEvent(int mkey, bool fromcontroller)
    {
        if (mkey == MKEY_Enter)
        {
            int selected = GetReplyNum();
            let reply = mCurNode.Children;
            for (int i = 0; i < selected && reply != null; i++) { reply = reply.Next; }
            if (IsRonnieOptionBlocked(reply)) { return true; }
        }
        return Super.MenuEvent(mkey, fromcontroller);
    }

    static ui String GetArgentoGuidanceKey(CaelumPlayer user)
    {
        String key = CaelumJournalOverlay.GetQuestDetailStageKey(user, CaelumConstants.QUEST_MAIN_M00_THE_FOOL);
        // El Diario habla al jugador desde fuera; Argento habla en primera persona.
        if (key == "CA_Q_DETAIL_M01_ARGENTO") return "CA_M01_ARGENTO_NEXT_BEGIN";
        if (key == "CA_Q_DETAIL_M01_RESIDENTS") return "CA_M01_ARGENTO_NEXT_RESIDENTS";
        if (key == "CA_Q_DETAIL_M01_RETURN_ARGENTO") return "CA_M01_ARGENTO_NEXT_RETURN";
        if (key == "CA_M01_RULO_DETAIL_KEY") return "CA_M01_ARGENTO_NEXT_KEY";
        if (key == "CA_M01_RULO_DETAIL_DOOR") return "CA_M01_KEY_GIVEN";
        return key;
    }

    override void FormatSpeakerMessage()
    {
        String text = StringTable.Localize(mCurNode.Dialogue);
        CaelumPlayer user = mPlayer == null ? null : CaelumPlayer(mPlayer.mo);
        if (user != null)
        {
            if (mCurNode.UserData ~== "ronnie_ammo")
                text = StringTable.Localize(user.MainM00StarterOptionSnapshot == 15 ? "CA_M01_BOLTS_HELP"
                    : (user.MainM00StarterOptionSnapshot == 12 || user.MainM00StarterOptionSnapshot == 14)
                    ? "CA_M01_ARROWS_HELP" : "CA_M01_AMMO_GENERAL", false);
            if (mCurNode.UserData ~== "ronnie_swim_practice")
                text = StringTable.Localize(user.MainM00SwimLessonCompleteSnapshot ? "CA_M01_SWIM_DONE"
                    : user.MainM00SwimLessonSubmergedSnapshot ? "CA_M01_SWIM_RECOVER" : "CA_M01_SWIM_PRACTICE", false);
            if (mCurNode.UserData ~== "ronnie_load_practice")
                text = StringTable.Localize(user.MainM00LoadLessonCompleteSnapshot ? "CA_M01_LOAD_DONE" : "CA_M01_LOAD_PRACTICE", false);
            text.Replace("%LOADKG%", String.Format("%.3f", user.MainM00LoadWeightSnapshot));
            text.Replace("%LOADCAP%", String.Format("%.3f", user.MainM00LoadCapacitySnapshot));
            text.Replace("%LOADAIR%", String.Format("%.2f", user.MainM00LoadAirFactorSnapshot));
            if (mCurNode.UserData ~== "ronnie_air_practice")
                text = StringTable.Localize(user.MainM00AirLessonCompleteSnapshot ? "CA_M01_AIR_DONE"
                    : user.MainM00AirLessonRanSnapshot ? "CA_M01_AIR_RECOVER" : "CA_M01_AIR_PRACTICE", false);
            if (mCurNode.UserData ~== "ronnie_needs_practice")
                text = StringTable.Localize(user.MainM00NeedsFoodUsedSnapshot && user.MainM00NeedsWaterUsedSnapshot
                    ? "CA_M01_NEEDS_DONE" : "CA_M01_NEEDS_PRACTICE", false);
            if (mCurNode.UserData ~== "ronnie_repair")
                text = StringTable.Localize(user.MainM00RepairLessonCompleteSnapshot
                    ? "CA_M01_REPAIR_DONE" : "CA_M01_REPAIR_INTRO", false);
            if (user.TarotFoolOwnedSnapshot)
            {
                String reaction = "";
                if (mCurNode.UserData ~== "argento_complete") reaction = "CA_M01_FOOL_ARGENTO";
                else if (mCurNode.UserData ~== "caella_magic_done") reaction = "CA_M01_FOOL_CAELLA";
                else if (mCurNode.UserData ~== "ronnie_finished") reaction = "CA_M01_FOOL_RONNIE";
                else if (mCurNode.UserData ~== "rulo_trial_done") reaction = "CA_M01_FOOL_RULO";
                if (reaction != "") text = StringTable.Localize(reaction, false);
            }
            if (mCurNode.UserData ~== "argento_next")
            {
                text = StringTable.Localize(GetArgentoGuidanceKey(user), false);
            }
            text.Replace("%COUNT%", String.Format("%d", user.MainM00ConvincedCountSnapshot));
            text.Replace("%RULO_CHANCE%", String.Format("%d", user.MainM00SocialChanceSnapshot[0]));
            text.Replace("%CAELLA_CHANCE%", String.Format("%d", user.MainM00SocialChanceSnapshot[2]));
            text.Replace("%LABIA%", String.Format("%.2f", user.MainM00LabiaSnapshot));
            text.Replace("%MAGIC_COUNT%", String.Format("%d", user.MainM00MagicPracticeSnapshot));
            text.Replace("%RUNES%", String.Format("%d", user.MainM00RuneSequenceSnapshot));
            text.Replace("%STARTER%", CaelumMainM00StarterRules.GetName(user.MainM00StarterOptionSnapshot));
            text.Replace("%DEFENSE%", StringTable.Localize(CaelumJournalOverlay.GetRuloDefenseKey(user), false));
            for (int i = 0; i < 6; i++)
                text.Replace(String.Format("%%SUPPLY%d%%", i), String.Format("%d", user.MainM00SupplySnapshot[i]));
        }
        if (mCurNode.UserData ~== "rulo_read_success")
        {
            // La lectura pertenece al menú del interlocutor, nunca a un sprite
            // mundial ni a un mensaje emitido para todos los jugadores.
            text = "[" .. StringTable.Localize("CA_DLG_M01_RULO_EMOTION", false)
                .. "]\n\n" .. text;
        }
        if (text.Length() == 0) { text = "."; }
        mDialogueLines = displayFont.BreakLines(text, SpeechWidth);
    }
}

// Proyecciones descartables del estado persistente para las condiciones USDF.
class CaelumM00SocialReadyToken : CaelumPalomoDialogueMarker {}
class CaelumM00ArgentoStartedToken : CaelumPalomoDialogueMarker {}
class CaelumM00ArgentoCompleteToken : CaelumPalomoDialogueMarker {}
class CaelumM00AllConvincedToken : CaelumPalomoDialogueMarker {}
class CaelumM00RuloConvincedToken : CaelumPalomoDialogueMarker {}
class CaelumM00RonnieConvincedToken : CaelumPalomoDialogueMarker {}
class CaelumM00CaellaConvincedToken : CaelumPalomoDialogueMarker {}
class CaelumM00RuloAttemptedToken : CaelumPalomoDialogueMarker {}
class CaelumM00RuloReadToken : CaelumPalomoDialogueMarker {}
class CaelumM00CaellaAttemptedToken : CaelumPalomoDialogueMarker {}
class CaelumM00CaellaPersuadedToken : CaelumPalomoDialogueMarker {}
class CaelumM00RuloAdviceToken : CaelumPalomoDialogueMarker {}
class CaelumM00RonnieAdviceToken : CaelumPalomoDialogueMarker {}
class CaelumM00CaellaAdviceToken : CaelumPalomoDialogueMarker {}
class CaelumM00RuloAdviceAvailableToken : CaelumPalomoDialogueMarker {}
class CaelumM00RonnieAdviceAvailableToken : CaelumPalomoDialogueMarker {}
class CaelumM00CaellaAdviceAvailableToken : CaelumPalomoDialogueMarker {}

// Acciones de respuesta; el servidor vuelve a verificar NPC, fase y requisitos.
class CaelumM00StartArgentoAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup)
    {
        return CaelumMainM00SocialDialogue.Apply(CaelumPlayer(Owner), 'StartArgento');
    }
}

class CaelumM00FinishArgentoAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup)
    {
        return CaelumMainM00SocialDialogue.Apply(CaelumPlayer(Owner), 'FinishArgento');
    }
}

class CaelumM00RuloAdviceAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup)
    {
        return CaelumMainM00SocialDialogue.Apply(CaelumPlayer(Owner), 'RuloAdvice');
    }
}

class CaelumM00RonnieAdviceAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup)
    {
        return CaelumMainM00SocialDialogue.Apply(CaelumPlayer(Owner), 'RonnieAdvice');
    }
}

class CaelumM00CaellaAdviceAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup)
    {
        return CaelumMainM00SocialDialogue.Apply(CaelumPlayer(Owner), 'CaellaAdvice');
    }
}

class CaelumM00ReadRuloAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup)
    {
        return CaelumMainM00SocialDialogue.Apply(CaelumPlayer(Owner), 'ReadRulo');
    }
}

class CaelumM00RespectRuloAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup)
    {
        return CaelumMainM00SocialDialogue.Apply(CaelumPlayer(Owner), 'RespectRulo');
    }
}

class CaelumM00RonniePlanAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup)
    {
        return CaelumMainM00SocialDialogue.Apply(CaelumPlayer(Owner), 'RonniePlan');
    }
}

class CaelumM00RonnieAdvicePlanAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup)
    {
        return CaelumMainM00SocialDialogue.Apply(CaelumPlayer(Owner), 'RonnieAdvicePlan');
    }
}

class CaelumM00PersuadeCaellaAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup)
    {
        return CaelumMainM00SocialDialogue.Apply(CaelumPlayer(Owner), 'PersuadeCaella');
    }
}

class CaelumM00CaellaSafetyAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup)
    {
        return CaelumMainM00SocialDialogue.Apply(CaelumPlayer(Owner), 'CaellaSafety');
    }
}

class CaelumM00SilverKeyReadyToken : CaelumPalomoDialogueMarker {}
class CaelumM00SilverKeyHeldToken : CaelumPalomoDialogueMarker {}
class CaelumM00TakeSilverKeyAction : CaelumPalomoDialogueAction
{
    override bool Use(bool pickup) { return CaelumMainM00SocialDialogue.GiveSilverKey(CaelumPlayer(Owner)); }
}
