// Política confirmada en #64. Los límites de lote/horizonte son técnicos;
// las tasas y dosis se resuelven siempre desde las reglas existentes.
class CaelumTimeSkipRules : Object play
{
    const WAKE_AT = 100.0;
    const BATCH_TICS = 8192;
    const FORECAST_BATCH_TICS = 262144;
    const MAX_DAYS = CaelumJourneyRules.MAX_WALK_HOURS / 24;

    static double SleepAt()
    { return CaelumConstants.SURVIVAL_MAXIMUM * CaelumConstants.SURVIVAL_CRITICAL_THRESHOLD; }

    static bool SleepingNext(bool sleeping, double value)
    { return sleeping ? value < WAKE_AT : value <= SleepAt(); }

    static int Kind(CaelumConsumableItem item)
    {
        if (item==null) return 0;
        let water = CaelumWaterContainer(item);
        if (water != null) return water.IsDrinkable() ? 3 : 0;
        if (item.GetConsumableType()==CaelumConstants.CONSUMABLE_FOOD_RATION) return 1;
        if (item.GetConsumableType()==CaelumConstants.CONSUMABLE_WATER_RATION) return 2;
        return 0;
    }

    static double Dose(int kind, double mass, double liters=0)
    {
        mass=Max(1,mass);
        if (kind==1) return CaelumConstants.SURVIVAL_MAXIMUM
            * CaelumConstants.CONSUMABLE_REGENERATION_PERCENT_PER_SECOND
            * CaelumConstants.RATION_REFERENCE_MASS / mass
            * CaelumConstants.CONSUMABLE_REGENERATION_SECONDS;
        double volume=kind==2 ? CaelumConstants.WATER_RATION_LITERS
            : Min(liters,mass/CaelumConstants.WATER_RECOVERY_PER_LITER_PER_PULSE);
        return volume*CaelumConstants.WATER_RECOVERY_PER_LITER_PER_PULSE/mass
            * CaelumConstants.CONSUMABLE_REGENERATION_SECONDS;
    }

    static bool Accessible(CaelumPlayer user, Actor item)
    {
        if (user==null || item==null || CaelumRestSafety.EnemyNear(user,item)) return false;
        let furniture=CaelumRestFurniture(item);
        if(furniture!=null && (furniture.Occupant==user || furniture.CanReach(user)))return true;
        if (level.MapName=="MAP01") return true;
        if(CaelumCityWorld.Peaceful())
        {
            int house=CaelumCityData.HouseAt(user.Pos);
            if(house>=0 && house==CaelumCityData.HouseAt(item.Pos))return true;
        }
        let it=ThinkerIterator.Create("CaelumTimeAdvanceZone"); CaelumTimeAdvanceZone zone;
        while ((zone=CaelumTimeAdvanceZone(it.Next()))!=null)
            if (user.Distance2D(zone)<=zone.Radius && Abs(user.Pos.Z-zone.Pos.Z)<=16
                && item.Distance2D(zone)<=zone.Radius && Abs(item.Pos.Z-zone.Pos.Z)<=16
                && user.CheckSight(zone,SF_IGNOREVISIBILITY)) return true;
        return false;
    }

    static CaelumRestFurniture FindFurniture(CaelumPlayer user,bool sleeping)
    {
        let it=ThinkerIterator.Create("CaelumRestFurniture"); CaelumRestFurniture item, best;
        while ((item=CaelumRestFurniture(it.Next()))!=null)
        {
            let mat=CaelumRestBag(item);
            if(mat!=null && (mat.Bag==null || !mat.Bag.AvailableTo(user)))continue;
            if (Accessible(user,item) && (item.Occupant==null || item.Occupant==user)
                && (item.RestMode()==CaelumRestRules.MODE_SLEEP)==sleeping
                && (best==null || item.ComfortFactor()>best.ComfortFactor())) best=item;
        }
        return best;
    }

    static bool OwnedAvailable(CaelumPlayer user,CaelumConsumableItem item)
    { return item!=null && item.Owner==user && item.Amount>0 && (!item.InMagicBox || user.MagicBoxOwned); }

    static String BlockReason(CaelumPlayer user,bool scan=true)
    {
        String reason=CaelumTimeAdvanceState.BlockReason(user,scan,true);
        if(reason.Length()!=0)return reason;
        if(CaelumTimeSkipState.NowDay(user)<0)return "CA_CALENDAR_OUT_OF_RANGE";
        return "";
    }
}

// Sesión serializable. El salto nunca acredita de antemano su previsión.
// Cada tic consume inventarios reales, y cancelar conserva sólo lo ya pasado.
class CaelumTimeSkipState : Inventory
{
    bool Open, Active, Sleeping, Pumping, Completed;
    bool HadTask, TaskDone, UseTaskDefault, ConfirmPending, BagSupport;
    int TargetDay, TargetTics, Field, LastPumpTic, ElapsedTics, WorkTics, SleepTics;
    int LastHealth;
    int SupplyDay;
    double FoodTrigger, WaterTrigger;
    String OriginMap, LastReason;
    vector3 OriginPosition;
    CaelumRestFurniture AnchorFurniture, Furniture, Bed, Chair;
    Actor Station;
    CaelumTimeSkipModel Forecast;

    static CaelumTimeSkipState Get(CaelumPlayer user,bool create=false)
    {
        if(user==null)return null;
        let skip=CaelumTimeSkipState(user.FindInventory("CaelumTimeSkipState"));
        if(skip==null && create)skip=CaelumTimeSkipState(user.GiveInventoryType("CaelumTimeSkipState"));
        return skip;
    }
    static bool IsOpen(CaelumPlayer user) {let s=Get(user);return s!=null && s.Open;}
    // Fabricacion y lectura comparten el avance personal y su prevision.
    static bool TaskActive(CaelumPlayer user)
    {return user!=null && (user.CraftingTaskActive || CaelumRecipeSession.Working(user));}
    static Actor TaskAnchor(CaelumPlayer user)
    {let camp=CaelumCampTask.Find(user);if(CaelumCampTask.Active(user) && camp!=null)return camp.Anchor;
        let reading=CaelumRecipeSession.Get(user);return user.CraftingTaskActive?user.ActiveCraftingStationActor:reading!=null?reading.Anchor:null;}
    static double TaskSeconds(CaelumPlayer user)
    {
        let reading=CaelumRecipeSession.Get(user);
        if(user.CraftingTaskActive)return user.CraftingTaskRemainingSeconds
            /(user.CraftingTaskKind==CaelumConstants.CRAFTING_TASK_BOIL || user.CraftingTaskKind==CaelumConstants.CRAFTING_TASK_CHEMISTRY || user.CraftingTaskKind==CaelumConstants.CRAFTING_TASK_CAMP || user.CraftingTaskKind==CaelumConstants.CRAFTING_TASK_HYGIENE || user.CraftingTaskKind==CaelumConstants.CRAFTING_TASK_BATH?CaelumThermalRuntime.WorldTicSeconds()*TICRATE:1);
        return reading!=null?reading.RemainingSeconds:0;
    }
    static bool IsActive(CaelumPlayer user) {let s=Get(user);return s!=null && s.Active;}
    static bool IsSleeping(CaelumPlayer user) {let s=Get(user);return s!=null && s.Active && s.Sleeping;}
    static bool UsesFurniture(CaelumPlayer user,CaelumRestFurniture item)
    {let s=Get(user);return s!=null && s.Active && s.Furniture==item && s.OriginMap==level.MapName;}
    static bool IsSeated(CaelumPlayer user)
    {let s=Get(user);return s!=null && s.Active && !s.Sleeping && s.Furniture!=null && s.Furniture.SupportsRest(user);}
    static int ResourceFactor(CaelumPlayer user)
    {
        let s=Get(user);
        if(s==null || !s.Active || user.CurrentHunger<=CaelumTimeSkipRules.SleepAt()
            || user.CurrentThirst<=CaelumTimeSkipRules.SleepAt())return 1;
        if(s.Furniture!=null && s.Furniture.SupportsRest(user))return s.Furniture.ComfortFactor();
        let bag=CaelumSleepingBag(user.FindInventory("CaelumSleepingBag"));
        return s.Sleeping && s.BagSupport && bag!=null && bag.AvailableTo(user)?3:1;
    }
    static int NowDay(CaelumPlayer user)
    {
        let clock=CaelumWorldClock.Get(user);
        if(clock==null)return -1;
        let calendar=CaelumCalendarState.Get(user);
        return CaelumWorldCatalogue.IsLimboMap(level.MapName)?clock.LocalDays():calendar!=null?calendar.DateSerial(clock):-1;
    }
    static int NowTics(CaelumPlayer user)
    {
        let clock=CaelumWorldClock.Get(user);
        if(clock==null)return -1;
        let calendar=CaelumCalendarState.Get(user);
        return CaelumWorldCatalogue.IsLimboMap(level.MapName)?clock.LocalTics():calendar!=null?calendar.CivilDayTics(clock):-1;
    }
    static clearscope String Stamp(int day,int tics,bool limbo)
    {
        if(limbo)return CaelumWorldClock.FormatStamp(day,tics);
        return String.Format("%02d/%02d/%04d %02d:%02d",CaelumCalendarRules.DayForSerial(day),
            CaelumCalendarRules.MonthForSerial(day),CaelumCalendarRules.YearForSerial(day),
            tics/CaelumWorldClock.TicsPerHour(),(tics%CaelumWorldClock.TicsPerHour())*60/CaelumWorldClock.TicsPerHour());
    }
    void ReleaseFurniture(CaelumPlayer user)
    { if(Furniture!=null && Furniture.Occupant==user)Furniture.Occupant=null;Furniture=null; }

    void ObserveSupply(CaelumPlayer user,CaelumConsumableItem item)
    {
        if(item==null || item.Amount<=0)return;
        int kind=CaelumTimeSkipRules.Kind(item);if(kind==0)return;
        let bottle=CaelumWaterContainer(item);
        double dose=CaelumTimeSkipRules.Dose(kind,user.DerivedStats.BaseMass,bottle!=null?bottle.WaterLiters:0);
        if(dose<=0.000001)return;
        if(kind==1)FoodTrigger=Max(FoodTrigger,100-Min(100,dose));
        else WaterTrigger=Max(WaterTrigger,100-Min(100,dose));
    }
    void RefreshSupports(CaelumPlayer user)
    {
        Bed=CaelumTimeSkipRules.FindFurniture(user,true);
        Chair=CaelumTimeSkipRules.FindFurniture(user,false);
        let bag=CaelumSleepingBag(user.FindInventory("CaelumSleepingBag"));
        BagSupport=Bed==null && bag!=null && bag.AvailableTo(user) && CaelumRestBag.HasRoom(user);
        FoodTrigger=100;WaterTrigger=100;
    }

    static bool OpenMenu(CaelumPlayer user)
    {
        if(IsOpen(user))return false;
        if(CaelumExhaustion.Locked(user)){CaelumExhaustion.NotifyLocked(user);return false;}
        String reason=CaelumTimeSkipRules.BlockReason(user);
        if(reason.Length()!=0){CaelumNotifications.Notify(user,StringTable.Localize(reason,false));return false;}
        let s=Get(user,true);let rest=CaelumRestState.Get(user);
        s.Sleeping=CaelumRestState.IsSleeping(user);
        s.AnchorFurniture=rest!=null && CaelumRestState.IsActive(user)?rest.Furniture:null;
        if(rest!=null)rest.Finish(user,CaelumRestRules.STATUS_CANCELLED,"");
        CaelumTimeAdvanceState.Halt(user);
        s.Open=true;s.Active=false;s.Completed=false;s.OriginMap=level.MapName;s.OriginPosition=user.Pos;
        s.HadTask=TaskActive(user);s.TaskDone=false;s.Station=TaskAnchor(user);
        // El soporte desplegado desaparece al cerrar el descanso; conservar
        // la decisión desde la bolsa real, sin depender de ese actor temporal.
        s.RefreshSupports(user);
        s.LastReason="";s.Field=0;s.UseTaskDefault=s.HadTask;
        s.TargetDay=NowDay(user);s.TargetTics=NowTics(user);
        s.TargetTics-=s.TargetTics%(CaelumWorldClock.TicsPerHour()/60);
        s.Shift(user,60);s.UseTaskDefault=s.HadTask;s.Recalculate(user);
        return true;
    }

    void Recalculate(CaelumPlayer user)
    {
        Forecast=null;
        if(!TaskActive(user))return;
        Forecast=new("CaelumTimeSkipModel");Forecast.CaptureSkip(user,Sleeping);
    }
    void Shift(CaelumPlayer user,int minutes)
    {
        int day=TargetDay,tics=TargetTics+minutes*(CaelumWorldClock.TicsPerHour()/60);
        while(tics<0){day--;tics+=CaelumWorldClock.TicsPerDay();}
        while(tics>=CaelumWorldClock.TicsPerDay()){day++;tics-=CaelumWorldClock.TicsPerDay();}
        int now=NowDay(user);
        if(day<now || day-now>CaelumTimeSkipRules.MAX_DAYS
            || (!CaelumWorldCatalogue.IsLimboMap(level.MapName) && day>CaelumCalendarRules.MAX_SERIAL))return;
        TargetDay=day;TargetTics=tics;UseTaskDefault=false;
    }
    static void SelectField(CaelumPlayer user,int field)
    {
        let s=Get(user);if(s==null || field<0 || field>2)return;
        int direction=(field-s.Field+3)%3;
        if(direction!=0)Edit(user,direction==1?1:-1,0);
    }
    static void Edit(CaelumPlayer user,int field,int delta)
    {
        let s=Get(user);if(s==null || !s.Open || s.Active || s.ConfirmPending)return;
        field=Clamp(field,-1,1);delta=Clamp(delta,-1,1);
        if(field!=0){s.Field=(s.Field+field+3)%3;return;}
        s.Shift(user,delta*(s.Field==0?1440:s.Field==1?60:1));
    }
    static bool Start(CaelumPlayer user,bool checkedForecast=false)
    {
        let s=Get(user);if(s==null || !s.Open || s.Active || s.ConfirmPending)return false;
        String reason=CaelumTimeSkipRules.BlockReason(user);
        if(reason.Length()==0 && s.UseTaskDefault && s.Forecast!=null
            && (!s.Forecast.Done || s.Forecast.Reason.Length()!=0))reason="CA_SKIP_NO_FORECAST";
        if(reason.Length()==0 && s.UseTaskDefault && TaskActive(user) && !checkedForecast)
        {
            // Confirmar vuelve a observar las provisiones y la tarea reales.
            // La previsión se procesa por lotes y sigue siendo cancelable.
            s.Recalculate(user);s.ConfirmPending=true;s.LastReason="CA_SKIP_CALCULATING";return true;
        }
        int days=s.TargetDay-NowDay(user);
        if(reason.Length()==0 && (days<0 || days>CaelumTimeSkipRules.MAX_DAYS
            || (days==0 && s.TargetTics<=NowTics(user))))reason="CA_SKIP_FUTURE";
        if(reason.Length()!=0){s.LastReason=reason;return false;}
        s.Active=true;s.Completed=false;s.LastReason="";s.Pumping=false;s.LastPumpTic=-1;
        s.ElapsedTics=0;s.WorkTics=0;s.SleepTics=0;s.LastHealth=user.health;
        s.HadTask=TaskActive(user);s.TaskDone=false;s.Station=TaskAnchor(user);
        s.RefreshSupports(user);
        PrepareStep(user);return s.Active;
    }
    static void FinishSkip(CaelumPlayer user,String reason="CA_SKIP_CANCELLED",bool close=false)
    {
        let s=Get(user);if(s==null)return;
        s.Active=false;s.ConfirmPending=false;s.ReleaseFurniture(user);s.LastReason=reason;s.Completed=true;
        if(close){s.Open=false;s.Forecast=null;s.AnchorFurniture=null;}
        user.PersistCharacterState();
    }
    static void RecordWork(CaelumPlayer user)
    {let s=Get(user);if(s!=null && s.Active)s.WorkTics++;}
    static void PrepareStep(CaelumPlayer user)
    {
        let s=Get(user);if(s==null || !s.Active)return;
        s.Sleeping=CaelumTimeSkipRules.SleepingNext(s.Sleeping,user.CurrentSleep);
        String reason=CaelumTimeSkipRules.BlockReason(user,false);
        if(s.OriginMap!=level.MapName || (user.Pos-s.OriginPosition).Length()>4)reason="CA_REST_MOVED";
        if(user.health<s.LastHealth)reason="CA_REST_DAMAGE";
        if(s.HadTask && !s.TaskDone && (!TaskActive(user)
            || TaskAnchor(user)!=s.Station))reason="CA_SKIP_TASK_CHANGED";
        if(reason.Length()!=0){FinishSkip(user,reason);return;}
        let support=s.Sleeping?s.Bed:TaskActive(user)?null:s.Chair;
        if(support!=null && support.Occupant!=null && support.Occupant!=user)support=null;
        if(s.Furniture!=support)
        {s.ReleaseFurniture(user);s.Furniture=support;if(support!=null)support.Occupant=user;}
    }
    static void AfterStep(CaelumPlayer user)
    {
        let s=Get(user);if(s==null || !s.Active)return;
        s.ElapsedTics++;if(s.Sleeping)s.SleepTics++;
        if(user.health<=0 || user.player.playerstate!=PST_LIVE)
        {FinishSkip(user,"CA_REST_UNAVAILABLE");return;}
        if(user.health<s.LastHealth){FinishSkip(user,"CA_REST_DAMAGE");return;}
        s.LastHealth=user.health;
        if(CaelumScheduleState.SiegeActive(user,level.MapName)){FinishSkip(user,"CA_EVENT_SIEGE_INTERRUPT");return;}
        if(s.HadTask && !TaskActive(user))s.TaskDone=true;
        int day=NowDay(user),tics=NowTics(user);
        if(day>s.TargetDay || (day==s.TargetDay && tics>=s.TargetTics))FinishSkip(user,"CA_SKIP_COMPLETE");
    }
    static void Pump(CaelumPlayer user)
    {
        let s=Get(user);if(s==null || !s.Open || s.Pumping || s.LastPumpTic==level.maptime)return;
        s.LastPumpTic=level.maptime;
        if(s.OriginMap!=level.MapName)
        {FinishSkip(user,"CA_REST_MOVED",true);return;}
        if(!s.Active)
        {
            if(s.Forecast!=null && s.Forecast.ProvisionRevision<CaelumTimeSkipModel.PROVISION_REVISION)
                s.Recalculate(user);
            if(s.Forecast!=null)
            {
                bool calculating=!s.Forecast.Done;
                if(calculating)s.Forecast.RunBatch();
                if(s.Forecast.Done && (calculating || s.ConfirmPending)
                    && s.UseTaskDefault && s.Forecast.Reason.Length()==0)
                {
                    s.TargetDay=s.Forecast.EndDay;s.TargetTics=s.Forecast.EndTics;
                    if(s.ConfirmPending)
                    {
                        // El tiempo normal dedicado al cálculo no se resta del
                        // intervalo previsto: redondear hacia adelante evita
                        // ofrecer un destino anterior al último tic de trabajo.
                        let clock=CaelumWorldClock.Get(user);
                        int fraction=CaelumWorldCatalogue.IsLimboMap(level.MapName)?clock.LimboSubTics:0;
                        int minute=CaelumWorldClock.TicsPerHour()/60;
                        s.TargetDay=NowDay(user);
                        s.TargetTics=NowTics(user)+int(Ceil(double(s.Forecast.ElapsedTics+fraction)/s.Forecast.Divisor));
                        s.TargetTics=((s.TargetTics+minute-1)/minute)*minute;
                        s.TargetDay+=s.TargetTics/CaelumWorldClock.TicsPerDay();s.TargetTics%=CaelumWorldClock.TicsPerDay();
                    }
                }
                if(s.Forecast.Done && s.ConfirmPending)
                {
                    s.ConfirmPending=false;
                    if(s.Forecast.Reason.Length()!=0)s.LastReason=s.Forecast.Reason;
                    else Start(user,true);
                }
            }
            return;
        }
        // El mundo nativo puede cambiar entre lotes. Validar allí la red de
        // oficio una vez; los subpasos no mueven estaciones ni geometría.
        if(user.CraftingTaskActive)user.CraftingSessionValidationTics=0;
        String reason=CaelumTimeSkipRules.BlockReason(user);
        if(reason.Length()!=0){FinishSkip(user,reason);return;}
        s.RefreshSupports(user);
        s.Pumping=true;
        for(int i=0;i<CaelumTimeSkipRules.BATCH_TICS && s.Active;i++)
        {
            PrepareStep(user);if(!s.Active)break;
            CaelumTimeAdvanceState.SimulatePersonalTic(user);
            AfterStep(user);
        }
        s.Pumping=false;
    }
    Default
    {
        Inventory.Amount 1; Inventory.MaxAmount 1; Inventory.InterHubAmount 1;
        +INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE +INVENTORY.KEEPDEPLETED -INVENTORY.INVBAR
    }
    States { Spawn: TNT1 A -1; Stop; }
}
