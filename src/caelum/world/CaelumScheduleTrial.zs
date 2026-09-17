// Adaptadores optativos. Los mapas fijan precios, plazos y sujetos; la agenda
// sólo administra los vencimientos. Ningún contrato canónico se crea aquí.
class CaelumScheduleContracts : Object
{
    static play CaelumScheduledEvent Rent(CaelumPlayer user, String keyText, String title,
        String propertyMap, int firstMinutes, int intervalMinutes, int copperCost, int periods = 0)
    {
        if (copperCost <= 0 || intervalMinutes <= 0) return null;
        let agenda = CaelumScheduleState.Get(user, true);
        if (agenda == null || agenda.FindKey(keyText) != null) return null;
        let entry = agenda.AddAfter(user, keyText, CaelumScheduleRules.RENT, title,
            propertyMap, firstMinutes, intervalMinutes, periods, keyText);
        if (entry != null) entry.Value = copperCost;
        return entry;
    }
    static play bool RentCurrent(CaelumPlayer user, String keyText)
    {
        CaelumScheduleState.Sync(user);
        let agenda = CaelumScheduleState.Get(user);
        let entry = agenda == null ? null : agenda.FindKey(keyText);
        return entry != null && entry.Kind == CaelumScheduleRules.RENT && !entry.Cancelled && entry.Debt() == 0;
    }
    static play CaelumScheduledEvent QuestDeadline(CaelumPlayer user, String keyText, String title,
        int questId, int minutes)
    {
        if (user == null || !CaelumSideQuestRules.IsDefined(questId)) return null;
        let record = user.GetPersistentCharacterState(false);
        if (record == null || record.QuestState[questId] != CaelumConstants.QUEST_STATE_ACTIVE) return null;
        let agenda = CaelumScheduleState.Get(user, true);
        if (agenda == null || agenda.FindKey(keyText) != null) return null;
        let entry = agenda.AddAfter(user, keyText, CaelumScheduleRules.QUEST, title, level.MapName, minutes);
        if (entry != null) entry.Value = questId;
        return entry;
    }
}

// Actor aparte: no altera a Ronnie ni las conversaciones de la mansión.
// Al volver de otro mapa consulta la última fase vencida, no repite toda la IA.
class CaelumScheduledWorker : CaelumRonnie
{
    String ScheduleSubject;
    vector3 WorkSpot, RestSpot;
    int SchedulePhase;
    override void PostBeginPlay()
    {
        Super.PostBeginPlay(); StoryAnchored = true; bFriendly = true;
        bInvulnerable = true; bCountKill = false; SchedulePhase = -1;
        WorkSpot = Pos; RestSpot = Pos;
    }
    override void Tick()
    {
        if (level.time % TICRATE == 0)
        {
            for (int i = 0; i < MAXPLAYERS; i++)
            {
                if (!playeringame[i]) continue;
                let user = CaelumPlayer(players[i].mo);
                let agenda = CaelumScheduleState.Get(user);
                let entry = agenda == null ? null : agenda.Latest(CaelumScheduleRules.ROUTINE, ScheduleSubject, level.MapName);
                if (entry != null && entry.Value != SchedulePhase)
                {
                    SchedulePhase = entry.Value;
                    StoryHome = SchedulePhase == 0 ? WorkSpot : RestSpot;
                    StoryReturningHome = true;
                }
                break;
            }
        }
        Super.Tick();
    }
    override bool Used(Actor activator)
    {
        let user = CaelumPlayer(activator);
        if (user == null || !CaelumUseGeometry.AimedAt(user, self)) return false;
        user.A_Print(StringTable.Localize(SchedulePhase == 1 ? "CA_EVENT_WORKER_REST" : "CA_EVENT_WORKER_WORK", false));
        return true;
    }
    Default { Tag "$CA_EVENT_WORKER_NAME"; -COUNTKILL +FRIENDLY +INVULNERABLE }
}

class CaelumScheduleTrial : Object
{
    static play bool Enable(CaelumPlayer user)
    {
        if (!CaelumScheduleState.CanTransact(user) || level.MapName == "MAP01") return false;
        let agenda = CaelumScheduleState.Get(user, true);
        if (agenda == null || agenda.TrialEnabled || agenda.Events.Size() > CaelumScheduleRules.MAX_RECORDS - 5
            || agenda.NextId > 2147483647 - 5 || CaelumScheduleState.Now(user) < 0
            || CaelumScheduleState.Now(user) + 32.0 * CaelumWorldClock.TicsPerHour() / 60
                >= CaelumScheduleRules.Stamp(CaelumCalendarRules.MAX_SERIAL + 1, 0)) return false;
        // Elegir dos posiciones libres antes de crear fechas o un actor.
        CaelumScheduledWorker worker;
        vector3 restPosition;
        for (int attempt = 0; attempt < 8; attempt++)
        {
            double heading = user.Angle + attempt * 45;
            vector3 workPosition = user.Pos + (Cos(heading) * 128, Sin(heading) * 128, 0);
            worker = CaelumScheduledWorker(Actor.Spawn("CaelumScheduledWorker", workPosition, NO_REPLACE));
            if (worker == null) continue;
            if (!worker.TestMobjLocation()) { worker.Destroy(); worker = null; continue; }
            restPosition = workPosition + (Cos(heading + 90) * 96, Sin(heading + 90) * 96, 0);
            worker.SetOrigin(restPosition, false);
            bool room = worker.TestMobjLocation(); worker.SetOrigin(workPosition, false);
            if (room && user.CheckSight(worker)) break;
            worker.Destroy(); worker = null;
        }
        if (worker == null) { user.A_Print(StringTable.Localize("CA_EVENT_TRIAL_ROOM", false)); return false; }
        worker.ScheduleSubject = "trial_worker"; worker.WorkSpot = worker.Pos; worker.RestSpot = restPosition;
        agenda.TrialEnabled = true; agenda.TrialMap = level.MapName; agenda.TrialOrigin = worker.Pos;
        let entry = agenda.AddAfter(user, "trial_work", CaelumScheduleRules.ROUTINE, "CA_EVENT_TRIAL_WORK", level.MapName, 1, 1440, 0, "trial_worker");
        if (entry != null) { entry.Value = 0; entry.Trial = true; }
        entry = agenda.AddAfter(user, "trial_rest", CaelumScheduleRules.ROUTINE, "CA_EVENT_TRIAL_REST", level.MapName, 6, 1440, 0, "trial_worker");
        if (entry != null) { entry.Value = 1; entry.Trial = true; }
        entry = agenda.AddAfter(user, "trial_siege_start", CaelumScheduleRules.SIEGE, "CA_EVENT_TRIAL_SIEGE_START", level.MapName, 4, 0, 1, "trial_siege");
        if (entry != null) { entry.Value = 1; entry.Trial = true; }
        entry = agenda.AddAfter(user, "trial_siege_end", CaelumScheduleRules.SIEGE, "CA_EVENT_TRIAL_SIEGE_END", level.MapName, 10, 0, 1, "trial_siege");
        if (entry != null) { entry.Value = 0; entry.Trial = true; }
        entry = CaelumScheduleContracts.Rent(user, "trial_rent", "CA_EVENT_TRIAL_RENT", level.MapName, 8, 12, 1, 3);
        if (entry != null) entry.Trial = true;
        CaelumScheduleState.Sync(user);
        user.A_Print(StringTable.Localize("CA_EVENT_TRIAL_ENABLED", false));
        return true;
    }
    static play bool Cargo(CaelumPlayer user)
    {
        if (user == null) return false;
        let source = CaelumMaterialPickup(user.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL, CaelumConstants.MATERIAL_WOOD, 1));
        let agenda = CaelumScheduleState.Get(user, true);
        String destination = level.MapName == "MAP06" ? "MAP07" : "MAP06";
        let entry = CaelumScheduleState.DispatchCargo(user, String.Format("trial_cargo_%d", agenda.NextId + 1), source, 100, destination, 30);
        if (entry == null) { user.A_Print(StringTable.Localize("CA_EVENT_CARGO_FAILED", false)); return false; }
        entry.Trial = true;
        user.A_Print(String.Format(StringTable.Localize("CA_EVENT_CARGO_SENT", false), destination)); return true;
    }
}
