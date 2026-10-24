// Fechas de campaña, nunca fecha del sistema operativo ni anclaje de prueba.
class CaelumScheduleRules : Object
{
    const SIEGE = 1;
    const ROUTINE = 2;
    const RENT = 3;
    const SHIPMENT = 4;
    const REGROWTH = 5;
    const QUEST = 6;
    const NOTICE = 7;
    const MAX_RECORDS = 2048;
    const KNOWLEDGE_REVISION = 1;

    static clearscope bool SameRegion(String eventMap,String currentMap)
    {
        if(eventMap.Length()==0 || eventMap~==currentMap)return true;
        int region=CaelumWorldCatalogue.LocationForMap(eventMap);
        return region!=CaelumWorldCatalogue.LOCATION_UNKNOWN
            && region==CaelumWorldCatalogue.LocationForMap(currentMap);
    }

    static clearscope double Stamp(int day, int tic)
    { return double(day) * CaelumWorldClock.TicsPerDay() + tic; }
    static clearscope bool ValidDate(int day, int tic)
    { return day >= 0 && day <= CaelumCalendarRules.MAX_SERIAL && tic >= 0 && tic < CaelumWorldClock.TicsPerDay(); }
    static clearscope String KindKey(int kind)
    {
        switch (kind)
        {
            case SIEGE: return "CA_EVENT_SIEGE";
            case ROUTINE: return "CA_EVENT_ROUTINE";
            case RENT: return "CA_EVENT_RENT";
            case SHIPMENT: return "CA_EVENT_SHIPMENT";
            case REGROWTH: return "CA_EVENT_REGROWTH";
            case QUEST: return "CA_EVENT_QUEST";
        }
        return "CA_EVENT_NOTICE";
    }
    static clearscope String DateText(double stamp)
    {
        if (stamp < 0) return "-";
        int day = int(Floor(stamp / CaelumWorldClock.TicsPerDay()));
        if (day > CaelumCalendarRules.MAX_SERIAL) return "-";
        int minutes = int((stamp - double(day) * CaelumWorldClock.TicsPerDay()) * 60 / CaelumWorldClock.TicsPerHour());
        return String.Format("%02d/%02d/%04d %02d:%02d", CaelumCalendarRules.DayForSerial(day),
            CaelumCalendarRules.MonthForSerial(day), CaelumCalendarRules.YearForSerial(day), minutes / 60, minutes % 60);
    }
}

// Una definición por serie, no un actor ni una copia por cada repetición.
class CaelumScheduledEvent : Object
{
    int EventId, Kind, DueDay, DueTic, RepeatMinutes, Limit, Processed;
    int Value, PaidPeriods, CargoMaterial, CargoTier, CargoUnits;
    String Key, TitleKey, Subject, MapName, OriginMap;
    bool Visible, Cancelled, Claimed, Trial;
    double CancelledAt;
    // Resultado real y conocimiento se guardan por separado. El contador viejo
    // ya se mostraba en el diario; migrarlo no borra información conocida.
    int KnowledgeRevision,KnownProcessed;
    bool DeadlineFailed;
    int PreviousQuestState,FailureOccurrence;

    void EnsureKnowledge()
    {
        if(KnowledgeRevision>=CaelumScheduleRules.KNOWLEDGE_REVISION)return;
        KnownProcessed=Processed;KnowledgeRevision=CaelumScheduleRules.KNOWLEDGE_REVISION;
    }
    clearscope int ObservedCount()
    {return KnowledgeRevision==0 ? Processed : KnownProcessed;}
    clearscope double KnownDebt()
    {return double(Max(0,ObservedCount()-PaidPeriods))*Max(0,Value);}
    clearscope double KnownNextStamp()
    {
        int known=ObservedCount();
        if(known>=2147483646 || Cancelled || (Limit>0 && known>=Limit)
            || (RepeatMinutes==0 && known>0))return -1;
        double next=OccurrenceStamp(known);
        return next<CaelumScheduleRules.Stamp(CaelumCalendarRules.MAX_SERIAL+1,0) ? next : -1;
    }
    clearscope String KnownStatusKey()
    {
        if(ObservedCount()<Processed)return "CA_EVENT_UNCONFIRMED";
        return StatusKey();
    }

    clearscope double FirstStamp() { return CaelumScheduleRules.Stamp(DueDay, DueTic); }
    clearscope double Period() { return double(RepeatMinutes) * CaelumWorldClock.TicsPerHour() / 60; }
    clearscope double OccurrenceStamp(int index)
    { return FirstStamp() + double(index) * Period(); }
    clearscope int CountAt(double now)
    {
        if (now < FirstStamp()) return 0;
        double count = RepeatMinutes > 0 ? Floor((now - FirstStamp()) / Period()) + 1 : 1;
        if (Limit > 0) count = Min(count, Limit);
        if (Cancelled) count = Min(count, Processed);
        return int(Min(2147483646.0, count));
    }
    clearscope double NextStamp()
    {
        if (Processed >= 2147483646 || Cancelled || (Limit > 0 && Processed >= Limit) || (RepeatMinutes == 0 && Processed > 0)) return -1;
        double next = OccurrenceStamp(Processed);
        return next < CaelumScheduleRules.Stamp(CaelumCalendarRules.MAX_SERIAL + 1, 0) ? next : -1;
    }
    clearscope double LastStamp() { return Processed > 0 ? OccurrenceStamp(Processed - 1) : -1; }
    clearscope int FirstIndexOnDay(int day)
    {
        double start = CaelumScheduleRules.Stamp(day, 0);
        double end = start + CaelumWorldClock.TicsPerDay();
        double index = RepeatMinutes > 0 ? Max(0.0, Ceil((start - FirstStamp()) / Period())) : 0;
        if (index > 2147483645.0 || (Limit > 0 && index >= Limit) || (Cancelled && index >= Processed)) return -1;
        double when = OccurrenceStamp(int(index));
        return when >= start && when < end ? int(index) : -1;
    }
    clearscope double Debt() { return double(Max(0, Processed - PaidPeriods)) * Max(0, Value); }
    clearscope String StatusKey()
    {
        if (Kind == CaelumScheduleRules.RENT && Debt() > 0) return "CA_EVENT_UNPAID";
        if (Kind == CaelumScheduleRules.SHIPMENT && Processed > 0) return Claimed ? "CA_EVENT_CLAIMED" : "CA_EVENT_READY";
        if (Cancelled) return "CA_EVENT_CANCELLED";
        if (NextStamp() >= 0) return Processed > 0 ? "CA_EVENT_REPEATING" : "CA_EVENT_PLANNED";
        return "CA_EVENT_RESOLVED";
    }
}

class CaelumScheduleState : Inventory
{
    Array<CaelumScheduledEvent> Events;
    int NextId, Revision, Notices;
    double NextDue;
    bool CacheValid;
    bool TrialEnabled;
    String TrialMap;
    vector3 TrialOrigin;
    int KnowledgeRevision;
    String DisclosureMap;

    static CaelumScheduleState Get(CaelumPlayer user, bool create = false)
    {
        if (user == null) return null;
        let agenda = CaelumScheduleState(user.FindInventory("CaelumScheduleState"));
        if (agenda == null && create) agenda = CaelumScheduleState(user.GiveInventoryType("CaelumScheduleState"));
        return agenda;
    }
    clearscope CaelumScheduledEvent FindId(int id)
    {
        for (int i = 0; i < Events.Size(); i++) if (Events[i].EventId == id) return Events[i];
        return null;
    }
    clearscope CaelumScheduledEvent FindKey(String keyText)
    {
        for (int i = 0; i < Events.Size(); i++) if (Events[i].Key == keyText) return Events[i];
        return null;
    }
    static double Now(CaelumPlayer user)
    {
        let clock = CaelumWorldClock.Get(user);
        let calendar = CaelumCalendarState.Get(user);
        if (clock == null || calendar == null) return -1;
        int day = calendar.DateSerial(clock);
        return day < 0 ? -1 : CaelumScheduleRules.Stamp(day, calendar.CivilDayTics(clock));
    }
    void Changed()
    { CacheValid = false; Revision = Revision == 2147483647 ? 1 : Revision + 1; }

    void EnsureKnowledge()
    {
        if(KnowledgeRevision>=CaelumScheduleRules.KNOWLEDGE_REVISION)return;
        for(int i=0;i<Events.Size();i++)Events[i].EnsureKnowledge();
        KnowledgeRevision=CaelumScheduleRules.KNOWLEDGE_REVISION;
        DisclosureMap="";
    }

    int Discover(String currentMap)
    {
        int revealed=0;
        for(int i=0;i<Events.Size();i++)
        {
            let entry=Events[i];
            if(entry.Processed<=0 || !CaelumScheduleRules.SameRegion(entry.MapName,currentMap))continue;
            if(entry.KnownProcessed==entry.Processed && entry.Visible)continue;
            entry.KnownProcessed=entry.Processed;entry.Visible=true;revealed++;
        }
        DisclosureMap=currentMap;
        return revealed;
    }

    // Sólo la presentación conserva el estado previo al vencimiento no conocido.
    // La autoridad de recompensas/plazos sigue leyendo QuestState real.
    static int KnownQuestState(CaelumPersistentCharacterState record,int quest,int actual)
    {
        if(record==null || actual!=CaelumConstants.QUEST_STATE_FAILED)return actual;
        let agenda=Get(CaelumPlayer(record.Owner));if(agenda==null)return actual;
        for(int i=0;i<agenda.Events.Size();i++)
        {
            let entry=agenda.Events[i];
            if(entry.Kind==CaelumScheduleRules.QUEST && entry.Value==quest && entry.DeadlineFailed
                && entry.ObservedCount()<entry.FailureOccurrence)return entry.PreviousQuestState;
        }
        return actual;
    }

    void PublishDiscovery(CaelumPlayer user)
    {
        int revealed=Discover(level.MapName);
        if(revealed<=0)return;
        Revision=Revision==2147483647 ? 1 : Revision+1;
        Notices=Min(2147483646-revealed,Notices)+revealed;
        user.RefreshSocialJournalSnapshot();
        if(user.health>0)CaelumNotifications.Notify(user,
            String.Format(StringTable.Localize("CA_EVENT_UPDATED",false),revealed));
    }

    static bool Earlier(CaelumScheduledEvent a,CaelumScheduledEvent b)
    {
        double first=a.NextStamp(),second=b.NextStamp();
        return first<second || (first==second && a.EventId<b.EventId);
    }

    // Merge iterativo: O(n log n), acotado por MAX_RECORDS, sin búsqueda de
    // actores ni un paso por cada repetición de una ausencia larga.
    static void SortDue(out Array<CaelumScheduledEvent> due)
    {
        Array<CaelumScheduledEvent> scratch;scratch.Resize(due.Size());
        int count=due.Size();
        for(int width=1;width<count;width*=2)
        {
            for(int start=0;start<count;start+=2*width)
            {
                int middle=Min(start+width,count),end=Min(start+2*width,count);
                int left=start,right=middle;
                for(int at=start;at<end;at++)
                    if(left<middle && (right>=end || Earlier(due[left],due[right])))scratch[at]=due[left++];
                    else scratch[at]=due[right++];
            }
            for(int i=0;i<count;i++)due[i]=scratch[i];
        }
    }

    CaelumScheduledEvent Add(String stableKey, int eventKind, String title, String targetMap,
        int scheduledDay, int scheduledTic, int repeatMins = 0, int total = 1, String subjectKey = "", bool known = true)
    {
        EnsureKnowledge();
        if (stableKey.Length() == 0 || eventKind < 1 || eventKind > CaelumScheduleRules.NOTICE
            || !CaelumScheduleRules.ValidDate(scheduledDay, scheduledTic) || repeatMins < 0
            || repeatMins > 525600 || total < 0 || (repeatMins == 0 && total != 1)) return null;
        let old = FindKey(stableKey); if (old != null) return old;
        if (Events.Size() >= CaelumScheduleRules.MAX_RECORDS || NextId == 2147483647) return null;
        let entry = new("CaelumScheduledEvent");
        entry.EventId = ++NextId; entry.Key = stableKey; entry.Kind = eventKind;
        entry.TitleKey = title; entry.MapName = targetMap; entry.Subject = subjectKey;
        entry.DueDay = scheduledDay; entry.DueTic = scheduledTic;
        entry.RepeatMinutes = repeatMins; entry.Limit = total; entry.Visible = known;
        entry.KnowledgeRevision=CaelumScheduleRules.KNOWLEDGE_REVISION;
        Events.Push(entry); Changed(); return entry;
    }
    CaelumScheduledEvent AddAfter(CaelumPlayer user, String stableKey, int eventKind, String title,
        String targetMap, int delayMinutes, int repeatMins = 0, int total = 1, String subjectKey = "")
    {
        double now = Now(user);
        if (now < 0 || delayMinutes < 0) return null;
        double due = now + double(delayMinutes) * CaelumWorldClock.TicsPerHour() / 60;
        int day = int(Floor(due / CaelumWorldClock.TicsPerDay()));
        int tic = int(due - double(day) * CaelumWorldClock.TicsPerDay());
        return Add(stableKey, eventKind, title, targetMap, day, tic, repeatMins, total, subjectKey);
    }
    bool Cancel(CaelumPlayer user, int id)
    {
        let entry = FindId(id);
        if (entry == null || entry.Cancelled || (entry.Kind == CaelumScheduleRules.SHIPMENT && !entry.Claimed)) return false;
        Sync(user);
        entry.Cancelled = true; entry.CancelledAt = Now(user); Changed(); return true;
    }
    clearscope CaelumScheduledEvent Latest(int eventKind, String subjectKey, String targetMap)
    {
        CaelumScheduledEvent result;
        for (int i = 0; i < Events.Size(); i++)
        {
            let entry = Events[i];
            if (entry.Kind != eventKind || entry.Subject != subjectKey || entry.MapName != targetMap || entry.Processed == 0) continue;
            if (result == null || entry.LastStamp() > result.LastStamp()
                || (entry.LastStamp() == result.LastStamp() && entry.EventId > result.EventId)) result = entry;
        }
        return result;
    }
    static bool SiegeActive(CaelumPlayer user, String targetMap)
    {
        let agenda = Get(user); if (agenda == null) return false;
        for (int i = 0; i < agenda.Events.Size(); i++)
        {
            let entry = agenda.Events[i];
            if (entry.Kind != CaelumScheduleRules.SIEGE || entry.MapName != targetMap || entry.Processed == 0) continue;
            let latest = agenda.Latest(entry.Kind, entry.Subject, targetMap);
            if (latest != null && latest.Value > 0) return true;
        }
        return false;
    }
    static void Sync(CaelumPlayer user)
    {
        let agenda = Get(user); if (agenda == null) return;
        agenda.EnsureKnowledge();
        double now = Now(user);
        if(now<0)return;
        if(agenda.CacheValid && (agenda.NextDue<0 || now<agenda.NextDue))
        {
            // La vuelta a una región debe revelar sus resultados aunque no
            // haya un nuevo vencimiento desde el último mapa.
            if(agenda.DisclosureMap!=level.MapName)agenda.PublishDiscovery(user);
            return;
        }
        Array<CaelumScheduledEvent> due;
        for(int i=0;i<agenda.Events.Size();i++)
        {
            let entry=agenda.Events[i];
            if(entry.CountAt(now)<=entry.Processed)continue;
            due.Push(entry);
        }
        SortDue(due);
        int updated = 0;
        for (int i = 0; i < due.Size(); i++)
        {
            let entry = due[i];
            int dueCount = entry.CountAt(now);
            if (dueCount <= entry.Processed) continue;
            // La ocurrencia se acredita una sola vez. Los adaptadores reciben
            // el estado final y el contador, sin reproducir años de IA o cobros.
            int previousCount=entry.Processed;
            entry.Processed = dueCount; updated++;
            if (entry.Kind == CaelumScheduleRules.QUEST)
            {
                let record = user.GetPersistentCharacterState(false);
                // Un objetivo ya alcanzado no falla mientras espera ser cobrado.
                if(record!=null && CaelumSideQuestRules.IsDefined(entry.Value)
                    && !CaelumSideQuestRules.ObjectivesComplete(record,entry.Value))
                {
                    int previous=record.QuestState[entry.Value];
                    if(CaelumSideQuestRules.End(record,entry.Value,false))
                    {
                        entry.PreviousQuestState=previous;entry.DeadlineFailed=true;
                        entry.FailureOccurrence=previousCount+1;
                    }
                }
            }
        }
        if (updated > 0)
        {
            agenda.Revision = agenda.Revision == 2147483647 ? 1 : agenda.Revision + 1;
            // El asedio detiene el descanso/fabricación acelerados. El viaje
            // ya confirmado se resuelve antes de presentar el estado del destino.
            let journey = CaelumJourneyState.Get(user);
            if ((journey == null || journey.Status != CaelumJourneyState.STATUS_DEPARTED)
                && SiegeActive(user, level.MapName))
            {
                CaelumTimeAdvanceState.Halt(user);
                CaelumRestState.Interrupt(user, "CA_EVENT_SIEGE_INTERRUPT");
                if (user.CraftingTaskActive) user.CloseCraftingStationSession();
            }
        }
        agenda.NextDue = -1;
        for (int i = 0; i < agenda.Events.Size(); i++)
        {
            double next = agenda.Events[i].NextStamp();
            if (next >= 0 && (agenda.NextDue < 0 || next < agenda.NextDue)) agenda.NextDue = next;
        }
        agenda.CacheValid = true;
        agenda.PublishDiscovery(user);
    }

    static bool CanTransact(CaelumPlayer user)
    {
        if (user == null || user.player == null || user.health <= 0 || !user.CharacterCreationComplete
            || user.CreationWizardOpen || user.CraftingTaskActive || user.HasActiveConversation()
            || user.PalomoMerchantMenuOpen || user.CombatTimeRemaining > 0
            || (user.player.cheats & CF_PREDICTING)) return false;
        for (int i = 0; i < MAXPLAYERS; i++) if (playeringame[i] && players[i].mo != user) return false;
        let plan = CaelumJourneyPlan.Get(user);
        return !CaelumRestState.IsActive(user) && (plan == null || !plan.Open);
    }
    // Importe y cambio usan las denominaciones existentes. Preparar todas las
    // monedas nuevas antes de quitar las viejas evita un pago parcial si falla.
    static bool Pay(CaelumPlayer user, CaelumScheduledEvent entry)
    {
        if (!CanTransact(user) || entry == null || entry.Kind != CaelumScheduleRules.RENT
            || entry.ObservedCount()!=entry.Processed
            || entry.Debt() <= 0 || entry.Debt() > 2147483646.0) return false;
        if (!user.BuildPalomoCurrencyPaymentPlan(int(entry.Debt()))) return false;
        if (!user.PalomoTransactionCapacityFits(user.GetPalomoCurrencyPlanPersonalWeightDelta(),
            user.GetPalomoCurrencyPlanBoxRawWeightDelta(), user.GetPalomoCurrencyPlanBoxSlotDelta())) return false;
        Array<CaelumCurrencyItem> created;
        for (int currency = 0; currency < CaelumConstants.CURRENCY_TYPE_COUNT; currency++)
        {
            CaelumCurrencyItem item = null;
            if (user.PalomoCurrencyPlanAmount[currency] > 0 && user.FindNativeCurrency(currency) == null)
                item = CaelumCurrencyItem(Actor.Spawn(CaelumEconomyRules.GetCurrencyClassName(currency), user.Pos, NO_REPLACE));
            created.Push(item);
            if (user.PalomoCurrencyPlanAmount[currency] > 0 && user.FindNativeCurrency(currency) == null && item == null)
            {
                for (int i = 0; i < created.Size(); i++) if (created[i] != null) created[i].Destroy();
                return false;
            }
        }
        for (int currency = 0; currency < CaelumConstants.CURRENCY_TYPE_COUNT; currency++)
        {
            let item = user.FindNativeCurrency(currency);
            int previousAmount = item == null ? 0 : item.Amount;
            if (created[currency] != null) { item = created[currency]; item.AttachToOwner(user); }
            if (item == null) continue;
            item.Amount = user.PalomoCurrencyPlanAmount[currency]; item.InMagicBox = user.PalomoCurrencyPlanInMagicBox[currency];
            // Sólo el cambio realmente recibido genera una adquisición.
            if (item.Amount > previousAmount)
                CaelumNotifications.Acquired(user, item, item.Amount - previousAmount);
            if (item.Amount <= 0) item.Destroy();
        }
        entry.PaidPeriods = entry.Processed; Get(user).Changed(); user.OnNativeInventoryChanged(); return true;
    }
    // Contrato de envío de material real: retira la carga al despacharla y la
    // conserva en el registro hasta una recogida válida en el mapa de destino.
    static CaelumScheduledEvent DispatchCargo(CaelumPlayer user, String keyText, CaelumMaterialPickup source,
        int units, String destination, int delayMinutes)
    {
        if (!CanTransact(user) || source == null || source.Owner != user || source.InMagicBox
            || source.LimboQuestUnits > 0 || units <= 0 || units > source.Amount
            || level.MapName == "MAP01" || !LevelInfo.MapExists(destination) || destination == "MAP01") return null;
        let agenda = Get(user, true);
        if (agenda.FindKey(keyText) != null) return null;
        let entry = agenda.AddAfter(user, keyText, CaelumScheduleRules.SHIPMENT, "CA_EVENT_CARGO_TITLE", destination, delayMinutes);
        if (entry == null) return null;
        entry.CargoMaterial = source.GetSpecialType(); entry.CargoTier = source.GetSpecialTier(); entry.CargoUnits = units; entry.Value = units;
        entry.OriginMap = level.MapName;
        source.Amount -= units; if (source.Amount == 0) source.Destroy();
        user.OnNativeInventoryChanged(); return entry;
    }
    static bool CollectCargo(CaelumPlayer user, CaelumScheduledEvent entry)
    {
        if (!CanTransact(user) || entry == null || entry.Kind != CaelumScheduleRules.SHIPMENT
            || entry.Processed == 0 || entry.Claimed || entry.Cancelled || entry.CargoUnits <= 0
            || level.MapName != entry.MapName) return false;
        let existing = user.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL, entry.CargoMaterial, entry.CargoTier);
        if (existing != null && existing.Amount > 2147483647 - entry.CargoUnits) return false;
        let cargo = CaelumMaterialPickup(Actor.Spawn("CaelumMaterialPickup", user.Pos, NO_REPLACE));
        if (cargo == null) return false;
        cargo.args[0] = entry.CargoMaterial; cargo.args[1] = entry.CargoTier; cargo.Amount = entry.CargoUnits;
        cargo.UpdateMaterialVisuals();
        // Touch usa la misma comprobación de capacidad y apilado que recoger.
        Actor receiver = user;
        bool accepted; [accepted, receiver] = cargo.CallTryPickup(user);
        if (!accepted) { cargo.Destroy(); return false; }
        entry.Claimed = true; entry.CargoUnits = 0; Get(user).Changed(); user.OnNativeInventoryChanged(); return true;
    }
    static bool Act(CaelumPlayer user, int id)
    {
        Sync(user); let agenda = Get(user); if (agenda == null) return false;
        let entry = agenda.FindId(id); if (entry == null || !entry.Visible) return false;
        bool success = entry.Kind == CaelumScheduleRules.RENT ? Pay(user, entry) : CollectCargo(user, entry);
        CaelumNotifications.Notify(user,StringTable.Localize(success ? "CA_EVENT_ACTION_OK" : "CA_EVENT_ACTION_FAILED", false));
        return success;
    }
    static void Report(CaelumPlayer user)
    {
        let agenda = Get(user);
        Console.Printf("[Caelum 4.35.0o] Agenda: %d registros, mapa=%s", agenda == null ? 0 : agenda.Events.Size(), level.MapName);
        if (agenda == null) return;
        for (int i = 0; i < agenda.Events.Size(); i++)
        {
            let e = agenda.Events[i];
            Console.Printf("#%d %s tipo=%d mapa=%s ocurrencias=%d próximo=%s cancelado=%d deuda=%.0f carga=%d cobrada=%d",
                e.EventId, e.Key, e.Kind, e.MapName, e.Processed, CaelumScheduleRules.DateText(e.NextStamp()), e.Cancelled, e.Debt(), e.CargoUnits, e.Claimed);
        }
    }
    Default
    {
        Inventory.MaxAmount 1; Inventory.InterHubAmount 1;
        +INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE +INVENTORY.KEEPDEPLETED -INVENTORY.INVBAR
    }
    States { Spawn: TNT1 A -1; Stop; }
}
