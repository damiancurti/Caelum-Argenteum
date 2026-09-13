// Base de encargos opcionales. Los índices/objetivos/recompensas se definen
// aquí; el único estado mutable vive en el Inventory viajero del personaje.
class CaelumSideQuestRules : Object
{
    static bool IsTrial(int id)
    {
        return id == CaelumConstants.QUEST_TRIAL_ROUTE
            || id == CaelumConstants.QUEST_TRIAL_WAIT;
    }

    static bool IsDefined(int id) { return IsTrial(id); }
    static bool AllowsAbandon(int id) { return IsDefined(id); }

    static int Prerequisite(int id)
    {
        return id == CaelumConstants.QUEST_TRIAL_WAIT
            ? CaelumConstants.QUEST_TRIAL_ROUTE : -1;
    }

    static int ObjectiveCount(int id) { return IsDefined(id) ? 1 : 0; }
    static int ObjectiveTarget(int id, int objective)
    {
        if (!IsDefined(id) || objective != 0) return 0;
        return id == CaelumConstants.QUEST_TRIAL_WAIT ? 5 : 1;
    }

    static bool CanStart(CaelumPersistentCharacterState r, int id)
    {
        if (r == null || !IsDefined(id) || (IsTrial(id) && !r.QuestTrialEnabled)
            || r.QuestState[id] != CaelumConstants.QUEST_STATE_OFFERED) return false;
        int required = Prerequisite(id);
        return required < 0 || r.QuestState[required] == CaelumConstants.QUEST_STATE_COMPLETED;
    }

    static play bool Discover(CaelumPersistentCharacterState r, int id)
    {
        if (r == null || !IsDefined(id) || (IsTrial(id) && !r.QuestTrialEnabled)) return false;
        r.EnsureQuestStateInitialized();
        if (r.QuestState[id] != CaelumConstants.QUEST_STATE_UNDISCOVERED) return false;
        r.QuestState[id] = CaelumConstants.QUEST_STATE_OFFERED;
        return true;
    }

    static play bool Start(CaelumPlayer user, int id)
    {
        if (user == null || user.health <= 0 || user.player == null
            || user.player.playerstate != PST_LIVE) return false;
        let r = user.GetPersistentCharacterState(false);
        if (!CanStart(r, id)) return false;
        r.QuestState[id] = CaelumConstants.QUEST_STATE_ACTIVE;
        r.QuestStage[id] = 1;
        for (int i = 0; i < ObjectiveCount(id); i++)
        {
            int slot = r.GetQuestObjectiveStorageIndex(id, i);
            r.QuestObjectiveKnown[slot] = true;
            r.QuestObjectiveProgress[slot] = 0;
            r.QuestObjectiveTarget[slot] = ObjectiveTarget(id, i);
        }
        if (id == CaelumConstants.QUEST_TRIAL_ROUTE)
        {
            r.QuestTrialOrigin = user.Pos;
            r.QuestTrialMap = level.MapName;
        }
        else
        {
            r.QuestTrialWaitTics = 0;
            r.QuestTrialLastHealth = user.health;
        }
        return true;
    }

    static play bool Progress(CaelumPersistentCharacterState r, int id, int objective, int amount)
    {
        if (r == null || !IsDefined(id) || amount <= 0 || objective < 0
            || objective >= ObjectiveCount(id)
            || r.QuestState[id] != CaelumConstants.QUEST_STATE_ACTIVE) return false;
        int slot = r.GetQuestObjectiveStorageIndex(id, objective);
        int target = ObjectiveTarget(id, objective);
        if (!r.QuestObjectiveKnown[slot] || r.QuestObjectiveTarget[slot] != target) return false;
        int remaining = target - r.QuestObjectiveProgress[slot];
        if (remaining <= 0) return false;
        r.QuestObjectiveProgress[slot] += Min(amount, remaining);
        return true;
    }

    static play bool ObjectivesComplete(CaelumPersistentCharacterState r, int id)
    {
        if (r == null || !IsDefined(id) || ObjectiveCount(id) <= 0) return false;
        for (int i = 0; i < ObjectiveCount(id); i++)
        {
            int slot = r.GetQuestObjectiveStorageIndex(id, i);
            int target = ObjectiveTarget(id, i);
            if (!r.QuestObjectiveKnown[slot] || r.QuestObjectiveTarget[slot] != target
                || r.QuestObjectiveProgress[slot] < target) return false;
        }
        return true;
    }

    static play bool Complete(CaelumPersistentCharacterState r, int id)
    {
        if (r == null || !IsDefined(id)
            || r.QuestState[id] != CaelumConstants.QUEST_STATE_ACTIVE
            || !ObjectivesComplete(r, id)) return false;
        r.QuestState[id] = CaelumConstants.QUEST_STATE_COMPLETED;
        r.QuestStage[id] = 2;
        return true;
    }

    static play bool End(CaelumPersistentCharacterState r, int id, bool abandoned)
    {
        if (r == null || !IsDefined(id)
            || (abandoned && !AllowsAbandon(id))
            || r.QuestState[id] != CaelumConstants.QUEST_STATE_ACTIVE) return false;
        r.QuestState[id] = abandoned ? CaelumConstants.QUEST_STATE_ABANDONED
            : CaelumConstants.QUEST_STATE_FAILED;
        return true;
    }

    static class<Inventory> RewardType(int id)
    {
        if (id == CaelumConstants.QUEST_TRIAL_ROUTE) return 'CaelumQuestRouteReceipt';
        if (id == CaelumConstants.QUEST_TRIAL_WAIT) return 'CaelumQuestWaitReceipt';
        return null;
    }

    // Una entrega nativa por misión. Si la recepción falla, sigue pendiente.
    // Perder/retirar el objeto después no borra el registro de la entrega.
    static play bool Claim(CaelumPlayer user, int id)
    {
        if (user == null || user.health <= 0 || user.player == null
            || user.player.playerstate != PST_LIVE || !IsDefined(id)) return false;
        let r = user.GetPersistentCharacterState(false);
        if (r == null || r.QuestState[id] != CaelumConstants.QUEST_STATE_COMPLETED
            || r.QuestRewardClaimed[id]) return false;
        class<Inventory> reward = RewardType(id);
        if (reward == null || user.FindInventory(reward) != null) return false;
        let item = user.GiveInventoryType(reward);
        if (item == null || item.Owner != user) return false;
        r.QuestRewardClaimed[id] = true;
        return true;
    }

    static play bool Activate(CaelumPlayer user, int id)
    {
        if (user == null || user.health <= 0 || user.player == null
            || user.player.playerstate != PST_LIVE || !IsDefined(id)) return false;
        let r = user.GetPersistentCharacterState(false);
        if (r == null || (IsTrial(id) && !r.QuestTrialEnabled)) return false;
        bool changed = false;
        if (r.QuestState[id] == CaelumConstants.QUEST_STATE_OFFERED) changed = Start(user, id);
        else
        {
            changed = Complete(r, id);
            changed = Claim(user, id) || changed;
        }
        user.RefreshSocialJournalSnapshot();
        if (changed) user.PersistCharacterState();
        return changed;
    }

    static play void EnableTrial(CaelumPlayer user)
    {
        if (user == null) return;
        let r = user.GetPersistentCharacterState(true);
        r.EnsureQuestStateInitialized();
        r.QuestTrialEnabled = true;
        Discover(r, CaelumConstants.QUEST_TRIAL_ROUTE);
        Discover(r, CaelumConstants.QUEST_TRIAL_WAIT);
        user.RefreshSocialJournalSnapshot();
        user.PersistCharacterState();
    }

    // Sólo observa dos encargos activados explícitamente. No busca actores ni
    // crea contenido en los mapas. El reloj usa tics del juego, nunca tiempo real.
    static play void Update(CaelumPlayer user)
    {
        let r = user.GetPersistentCharacterState(false);
        if (r == null || !r.QuestTrialEnabled) return;
        bool changed = false;
        int route = CaelumConstants.QUEST_TRIAL_ROUTE;
        int wait = CaelumConstants.QUEST_TRIAL_WAIT;
        if (r.QuestState[route] == CaelumConstants.QUEST_STATE_ACTIVE
            && !ObjectivesComplete(r, route))
        {
            if (user.health <= 0 || r.QuestTrialMap != level.MapName) changed = End(r, route, false);
            else if (Abs(user.Pos.Z - r.QuestTrialOrigin.Z) < 32
                && (user.Pos.XY - r.QuestTrialOrigin.XY).Length() >= 128)
                changed = Progress(r, route, 0, 1);
        }
        if (r.QuestState[wait] == CaelumConstants.QUEST_STATE_ACTIVE
            && !ObjectivesComplete(r, wait))
        {
            if (user.health <= 0 || user.health < r.QuestTrialLastHealth)
                changed = End(r, wait, false) || changed;
            else
            {
                r.QuestTrialLastHealth = user.health;
                r.QuestTrialWaitTics++;
                int slot = r.GetQuestObjectiveStorageIndex(wait, 0);
                changed = Progress(r, wait, 0,
                    r.QuestTrialWaitTics / TICRATE - r.QuestObjectiveProgress[slot]) || changed;
            }
        }
        if (changed) user.RefreshSocialJournalSnapshot();
    }
}

// Constancias de diagnóstico, sin peso, atributos, precio ni sprite nuevo.
// Sus clases son distintas para comprobar dos recompensas independientes.
class CaelumQuestRouteReceipt : Inventory
{
    Default
    {
        Inventory.MaxAmount 1;
        Inventory.InterHubAmount 1;
        +INVENTORY.UNDROPPABLE
        -INVENTORY.INVBAR
    }
    States { Spawn: TNT1 A -1; Stop; }
}
class CaelumQuestWaitReceipt : CaelumQuestRouteReceipt {}

class CaelumDebugQuestTrial : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        let user = CaelumPlayer(Owner);
        if (user == null) return false;
        CaelumSideQuestRules.EnableTrial(user);
        return true;
    }
}

class CaelumDebugFailQuestTrial : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        let user = CaelumPlayer(Owner);
        if (user == null) return false;
        CaelumSideQuestRules.End(user.GetPersistentCharacterState(false), CaelumConstants.QUEST_TRIAL_WAIT, false);
        user.RefreshSocialJournalSnapshot();
        user.PersistCharacterState();
        return true;
    }
}
