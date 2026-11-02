// Los marcadores conservan la accesibilidad de apoyos distantes; la seguridad
// compartida depende del contexto personal y de amenazas visibles cercanas.
class CaelumTimeAdvanceZone : Actor
{
    Default { Radius 224; Height 128; +NOBLOCKMAP +NOGRAVITY +NOTARGET RenderStyle "None"; }
    States { Spawn: TNT1 A -1; Stop; }
}

class CaelumTimeAdvanceState : Inventory
{
    bool Active;
    bool Pumping;
    int LastPumpTic;
    int SimulatedTics;
    int PersonalStepSerial;
    String OriginMap;
    String LastReason;
    CaelumRestState Session;
    Actor Station;

    static CaelumTimeAdvanceState Get(CaelumPlayer user, bool create = false)
    {
        if (user == null) return null;
        let advance = CaelumTimeAdvanceState(user.FindInventory("CaelumTimeAdvanceState"));
        if (advance == null && create) advance = CaelumTimeAdvanceState(user.GiveInventoryType("CaelumTimeAdvanceState"));
        return advance;
    }

    static void Halt(CaelumPlayer user)
    {
        let advance = Get(user);
        if (advance != null) { advance.Active = false; advance.Session = null; advance.Station = null; }
    }

    static int StepSerial(CaelumPlayer user)
    {let advance=Get(user);return advance!=null?advance.PersonalStepSerial:0;}

    static String BlockReason(CaelumPlayer user, bool scanWorld = true, bool skipping = false)
    {
        let counter=user!=null?CaelumKitchenCounterStation(user.ActiveCraftingStationActor):null;
        bool proofing=skipping && CaelumProofingUI.Active(user) && counter.Batch!=null && counter.Batch.Occupied
            && CaelumProofing.Reachable(user,counter);
        bool crafting=user!=null && user.CraftingTaskActive
            && ((user.CraftingMenuOpen && user.ActiveCraftingStationActor!=null) || CaelumCampCooking.Attended(user) || CaelumCampTask.Attended(user) || CaelumHygieneTask.Attended(user) || CaelumBathTask.Attended(user) || CaelumCleaningTask.Attended(user));
        crafting=crafting || proofing;
        bool reading=CaelumRecipeSession.Working(user);
        String reason=CaelumRestSafety.BlockReason(user,CaelumCleaningTask.Timeless(user),crafting || reading,scanWorld);
        if(reason.Length()!=0)return reason;
        if(!CaelumRestState.IsActive(user) && !crafting && !reading && !skipping)return "CA_FAST_ACTIVITY";
        if(crafting && !user.RefreshActiveCraftingStationSession())return "CA_FAST_ACTIVITY";
        return "";
    }

    static bool Toggle(CaelumPlayer user)
    {
        if(multiplayer)return CaelumCooperativeTime.Open(user);
        if (CaelumTimeSkipState.IsOpen(user)) return false;
        let advance=Get(user,true); if(advance==null)return false;
        if(advance.Active) { Halt(user); CaelumNotifications.Notify(user,StringTable.Localize("CA_FAST_OFF",false)); return true; }
        String reason=BlockReason(user);
        if(reason.Length()!=0) { advance.LastReason=reason; CaelumNotifications.Notify(user,StringTable.Localize(reason,false)); return false; }
        advance.Active=true;advance.Pumping=false;advance.LastPumpTic=-1;advance.SimulatedTics=0;
        advance.OriginMap=level.MapName;advance.Session=CaelumRestState.IsActive(user)?CaelumRestState.Get(user):null;
        advance.Station=advance.Session==null?CaelumTimeSkipState.TaskAnchor(user):null;advance.LastReason="";
        CaelumNotifications.Notify(user,StringTable.Localize("CA_FAST_ON",false));return true;
    }

    static void AdvancePowers(CaelumPlayer user)
    {
        Inventory item=user.Inv;
        while(item!=null)
        {
            Inventory next=item.Inv;
            let power=CaelumRegenerationPower(item);
            if(power!=null) { power.DoEffect(); power.Tick(); }
            item=next;
        }
    }

    static void Pump(CaelumPlayer user)
    {
        let advance=Get(user);
        if(advance==null || !advance.Active || advance.Pumping || advance.LastPumpTic==level.maptime) return;
        advance.LastPumpTic=level.maptime;
        String reason=advance.OriginMap!=level.MapName?"CA_REST_MOVED":BlockReason(user);
        if(reason.Length()!=0)
        { advance.LastReason=reason;Halt(user);CaelumNotifications.Notify(user,StringTable.Localize(reason,false));return; }
        let clock=CaelumWorldClock.Get(user);if(clock==null){Halt(user);return;}
        advance.Pumping=true;
        // Máximo un minuto de campaña por imagen (105 tics totales a x105).
        // Subpasos de un tic respetan exactamente umbrales y expiraciones;
        // se devuelve el control al motor entre lotes para cancelar/pausar.
        for(int i=1;i<CaelumWorldClock.TicsPerHour()/60 && advance.Active;i++)
        {
            if(advance.Session!=null && (!CaelumRestState.IsActive(user) || CaelumRestState.Get(user)!=advance.Session)) { Halt(user);break; }
            if(advance.Station!=null && (!CaelumTimeSkipState.TaskActive(user) || CaelumTimeSkipState.TaskAnchor(user)!=advance.Station)) { Halt(user);break; }
            reason=BlockReason(user,false);
            if(reason.Length()!=0) {advance.LastReason=reason;Halt(user);break;}
            // Cada lugar conserva su escala de calendario durante el avance.
            // El serial evita acreditar dos veces un paso de descanso.
            SimulatePersonalTic(user);
            advance.SimulatedTics++;
            if(!CaelumTimeSkipState.TaskActive(user) && advance.Station!=null) Halt(user);
        }
        advance.Pumping=false;
    }

    // Un paso compartido por los avances. No ejecuta IA general; sí resuelve
    // las creaciones temporales del Tarot con sus propios pasos acotados.
    static void SimulatePersonalTic(CaelumPlayer user,bool advanceWorld=true)
    {
        let advance=Get(user,true);
        advance.PersonalStepSerial=advance.PersonalStepSerial==2147483647?0:advance.PersonalStepSerial+1;
        let clock=CaelumWorldClock.Get(user);
        if(advanceWorld)clock.AdvanceOnMap(level.MapName);
        CaelumWeatherState.Sync(user,clock,CaelumCalendarState.Get(user));
        if(advanceWorld)
        {CaelumHousekeepingWork.AdvanceSkippedTic(user);CaelumCampWorld.AdvanceFires();CaelumMajorWorldEvents.AdvanceSkippedTic();}
        AdvancePowers(user);
        user.UpdateCraftingTask();
        let reading=CaelumRecipeSession.Get(user);if(reading!=null)reading.Advance();
        user.AdvancePersonalTimeTic(false);
        if(user.health<=0 || user.player.playerstate!=PST_LIVE)
        {CaelumRestSafety.Interrupt(user,"CA_REST_UNAVAILABLE");return;}
        user.HUDAbilitySuccessRemaining=Max(0.0,user.HUDAbilitySuccessRemaining-1.0/TICRATE);
        CaelumRestState.Advance(user);
        CaelumTransportTrip.Step(user);
    }

    Default
    {
        Inventory.Amount 1; Inventory.MaxAmount 1; Inventory.InterHubAmount 1;
        +INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE +INVENTORY.KEEPDEPLETED -INVENTORY.INVBAR
    }
    States { Spawn: TNT1 A -1; Stop; }
}
