// La previsión sólo guarda valores; nunca presta, consume ni genera Inventory.
class CaelumSkipSupply : Object play
{
    int Kind, Count, WaterQuality;
    double Liters, CapacityLiters;
    bool Reserved,Hot,CleaningWater;
    CaelumFoodLots FoodLots;
    CaelumFoodClimate FoodClimate;
    void Capture(CaelumConsumableItem item)
    {
        Kind=CaelumTimeSkipRules.Kind(item);
        Count=item!=null?item.Amount:0;
        if(Kind==1)
        {
            CaelumFoodInventory.Reconcile(item);FoodLots=item.FoodLots.Copy();
            let climate=CaelumFoodClock.Get(item).Climate;FoodClimate=climate!=null?climate.Copy():null;
        }
        let bottle=CaelumWaterContainer(item);Liters=bottle!=null?bottle.WaterLiters:0;
        if (bottle != null)
        {
            Kind=3;WaterQuality=bottle.WaterQuality;Reserved=CaelumWaterBoiling.Locked(bottle);
            Hot=bottle.WaterTemperatureRevision>0 && bottle.WaterTemperatureC>CaelumWaterThermalData.DRINK_MAX_C;
            CleaningWater=bottle.Owner is 'CaelumPlayer' && !bottle.InMagicBox && Count==1 && !Reserved && bottle.IsPotable();
        }
        CapacityLiters=bottle!=null?bottle.GetCapacityLiters():0;
    }
    bool Usable() { return Count>0 && Kind!=0 && !Reserved && !Hot && (Kind!=3 || CaelumWaterQuality.IsSafe(WaterQuality)); }
}
class CaelumSkipTableStock : Object play
{
    int First, Capacity, Target;
}

class CaelumTimeSkipModel : CaelumJourneyModel
{
    const PROVISION_REVISION = 23;
    CaelumContaminationSurfaceForecast SurfaceContact;
    int ProvisionRevision;
    bool PotableImmersed, ToiletTask, ToiletPulsesPrepared;
    bool BathTask,BathDomestic;
    double BathRemaining,BathWater,BathSoap,BathWaterPerDegree;
    bool CleaningTask;
    double CleaningRemaining,CleaningSoap;
    int CleaningIndex;
    bool SleepCleaningCloth;
    double SleepCleaningSoap;
    Array<int> SleepCleaningIndices;
    Array<double> SleepCleaningAreas;
    Array<CaelumSkipSupply> Supplies;
    Array<CaelumSkipTableStock> Tables;
    bool Done, Sleeping, Limbo;
    String Reason;
    int EndDay, EndTics, SubTics, Divisor, BedFactor;
    int ProductiveTics, RequiredTics, StartDay;
    double Scale, NextThreat, FoodTrigger, WaterTrigger;
    int HealthBeforeStep;
    int ChairFactor;
    bool HasChair;
    int FoodSeatedSubTics, WaterSeatedSubTics;
    double AdrenalineBeforeStep;
    CaelumContaminationWaitWeather ContaminationWeather;

    override void Step(bool sleeping)
    {
        // El jugador calcula rendimiento al comienzo del tic, antes de curar
        // salud y decaer adrenalina. Respetar ese orden evita adelantar umbrales.
        Sleeping=sleeping;
        // Los poderes pulsan antes de terminar la tarea en el avance real.
        if(ToiletTask || BathTask || CleaningTask)
        {
            Pulses();ToiletPulsesPrepared=true;
            if(ToiletTask && !sleeping && ProductiveTics+1>=RequiredTics && FoodIllness!=null)
            {FoodIllness.ToiletDepurate();ToiletTask=false;}
        }
        if(BathTask && !sleeping && FoodIllness!=null)
        {
            if(BathDomestic)BathWater=Min(CaelumDomesticWaterData.CAPACITY_LITERS,BathWater
                +AltitudeSecondsPerTic*CaelumDomesticWaterData.REFILL_LITERS_PER_WORLD_MINUTE/60.0);
            double wanted=Min(BathRemaining,AltitudeSecondsPerTic/CaelumContaminationData.BATH_SECONDS_DEGREE);
            double dose=Min(wanted,Min(FoodIllness.Contamination,Min(BathWater/BathWaterPerDegree,
                BathSoap/CaelumContaminationRules.SoapGrams(BathWaterPerDegree))));
            BathRemaining=Max(0.0,BathRemaining-dose);FoodIllness.Contamination=Max(0.0,FoodIllness.Contamination-dose);
            BathWater=Max(0.0,BathWater-dose*BathWaterPerDegree);BathSoap=Max(0.0,BathSoap-CaelumContaminationRules.SoapGrams(dose*BathWaterPerDegree));
            SleepCleaningSoap=BathSoap;
            if(BathRemaining<0.000000001 || FoodIllness.Contamination<=0)
            {BathTask=false;RequiredTics=ProductiveTics+1;}
            else if(dose<wanted){Reason="CA_SKIP_PROVISIONS";Done=true;}
        }
        if(CleaningTask && !sleeping)
        {
            double water=0;for(int i=0;i<Supplies.Size();i++)if(Supplies[i].CleaningWater)water+=Supplies[i].Liters;
            double rate=CaelumContaminationData.EQUIPMENT_WATER_L_M2/CaelumContaminationData.EQUIPMENT_SECONDS_M2;
            double wanted=Min(CleaningRemaining,AltitudeSecondsPerTic);
            double step=Min(wanted,Min(water,CleaningSoap/CaelumContaminationData.SOAP_G_L)/rate);
            double liters=step*rate;CleaningSoap=Max(0.0,CleaningSoap-CaelumContaminationRules.SoapGrams(liters));
            for(int i=0;i<Supplies.Size() && liters>0;i++)if(Supplies[i].CleaningWater)
            {double take=Min(liters,Supplies[i].Liters);Supplies[i].Liters-=take;liters-=take;}
            if(Contamination!=null && CleaningIndex>=0)
                Contamination.Items[CleaningIndex].Concentration*=Max(0.0,1-step/CleaningRemaining);
            CleaningRemaining=Max(0.0,CleaningRemaining-step);
            if(CleaningRemaining<0.000000001){CleaningTask=false;RequiredTics=ProductiveTics+1;}
            else if(step<wanted){Reason="CA_SKIP_PROVISIONS";Done=true;}
        }
        if(ContaminationWeather!=null && Contamination!=null)
        {
            int nextTick=EndTics+int(SubTics+1>=Divisor),nextDay=EndDay;
            if(nextTick>=CaelumWorldClock.TicsPerDay()){nextTick=0;nextDay++;}
            double contactAmbient=ContaminationWeather.Sample(nextDay,nextTick);
            Contamination.Advance(FoodIllness,contactAmbient,AltitudeSecondsPerTic);
            if(SurfaceContact!=null)SurfaceContact.Advance(Contamination,FoodIllness,AltitudeSecondsPerTic,
                contactAmbient,ContaminationWeather.RainCovered || ContaminationWeather.Local==null?0:ContaminationWeather.Local.PrecipitationMmPerHour);
        }
        for(int i=0;i<Supplies.Size();i++)
        {
            let row=Supplies[i];
            if(row.FoodClimate!=null)row.FoodClimate.Advance(row.Kind==1?row.FoodLots:null,AltitudeSecondsPerTic);
        }
        HealthBeforeStep=Health;AdrenalineBeforeStep=Adrenaline;Super.Step(sleeping);
        if(Health>0)ServeSupplies();
    }
    override int AirHealth(){return HealthBeforeStep;}
    override double AirAdrenaline(){return AdrenalineBeforeStep;}

    void AddSupply(CaelumConsumableItem item)
    {
        let row=new("CaelumSkipSupply");row.Capture(item);Supplies.Push(row);
        // No prometer una fecha exacta con una provisión que se enfría durante
        // el pronóstico. La espera manual sigue integrando el agua real.
        if(row.Hot && !row.Reserved){Reason="CA_SKIP_FORECAST_EFFECT";Done=true;}
    }
    void CaptureSkip(CaelumPlayer user,bool alreadySleeping)
    {
        ProvisionRevision=PROVISION_REVISION;
        // Otro cuerpo puede moverse o cambiar de equipo durante la espera.
        if(CaelumContaminationContacts.Active(user) || CaelumHousekeepingWork.Pending() || CaelumCampWorld.Burning()){Reason="CA_SKIP_FORECAST_EFFECT";Done=true;}
        SleepCleaningCloth=CaelumCleaningSupplies.Cloth(user);SleepCleaningSoap=CaelumSoapSupply.Available(user);
        if(CaelumTimeSkipState.IsPreparingSleep(user)){Reason="CA_SKIP_FORECAST_EFFECT";Done=true;}
        Capture(user,false);
        let surfaceThermal=CaelumThermalService.CaptureForecast(user);
        if(surfaceThermal!=null && surfaceThermal.Available && CaelumCalendarState.Get(user)!=null && CaelumWorldClock.Get(user)!=null)
        {SurfaceContact=new('CaelumContaminationSurfaceForecast');SurfaceContact.Capture(user,surfaceThermal);}
        if(Contamination!=null)for(int slot=0;slot<CaelumCleaningSupplies.EQUIPPED_COUNT;slot++)
        {
            let item=CaelumCleaningSupplies.EquippedAt(user,slot);if(item==null)continue;
            for(int index=0;index<Contamination.Items.Size();index++)if(Contamination.Items[index].Item==item)
            {SleepCleaningIndices.Push(index);SleepCleaningAreas.Push(CaelumCleaningSupplies.Area(item));break;}
        }
        PotableImmersed=user.IsSubmergedInPotableWater();
        ToiletTask=CaelumHygieneTask.Active(user);
        BathTask=CaelumBathTask.Active(user);
        CleaningTask=CaelumCleaningTask.Active(user);CleaningIndex=-1;
        if(CleaningTask)
        {
            let cleaning=CaelumCleaningTask.Find(user);CleaningRemaining=cleaning.Remaining;CleaningSoap=CaelumSoapSupply.Available(user);
            if(Contamination!=null)for(int i=0;i<Contamination.Items.Size();i++)
                if(Contamination.Items[i].Item==cleaning.Target){CleaningIndex=i;break;}
            // La cola de varias piezas seguida del sueño aún no promete una fecha exacta.
            if(cleaning.SleepAfter || cleaning.WakeQueue){Reason="CA_SKIP_FORECAST_EFFECT";Done=true;}
            if(!CaelumCleaningSupplies.Cloth(user)){Reason="CA_SKIP_PROVISIONS";Done=true;}
        }
        if(BathTask)
        {
            let bath=CaelumBathTask.Find(user);BathRemaining=bath.RemainingDegrees;BathDomestic=bath.Fixture!=null;
            BathWater=CaelumBathTask.WaterAvailable(user,bath.Fixture,bath.WaterModel);BathSoap=CaelumSoapSupply.Available(user);
            BathWaterPerDegree=CaelumContaminationRules.BathWaterLiters(1,user.DerivedStats.BaseMass);
        }
        ContaminationWeather=new('CaelumContaminationWaitWeather');ContaminationWeather.Capture(user);
        if(ContaminationWeather.DynamicClimate || (Contamination!=null && Contamination.DynamicWater))
        {Reason="CA_SKIP_FORECAST_EFFECT";Done=true;}
        Scale=CaelumWorldClock.MapTimeScale(level.MapName);
        AltitudeSecondsPerTic*=Scale;
        HungerLoss*=Scale;ThirstLoss*=Scale;SleepLoss*=Scale;
        Limbo=CaelumWorldCatalogue.IsLimboMap(level.MapName);Divisor=Limbo?20:1;
        let clock=CaelumWorldClock.Get(user);
        EndDay=CaelumTimeSkipState.NowDay(user);StartDay=EndDay;
        EndTics=CaelumTimeSkipState.NowTics(user);SubTics=Limbo?clock.LimboSubTics:0;
        RequiredTics=Max(0,int(Ceil(CaelumTimeSkipState.TaskSeconds(user)*TICRATE-0.000001)));
        Sleeping=alreadySleeping;NextThreat=-1;
        let bed=CaelumTimeSkipRules.FindFurniture(user,true);
        BedFactor=bed!=null?bed.ComfortFactor():Bag && CaelumRestBag.HasRoom(user)?3:1;
        let chair=CaelumTimeSkipState.TaskActive(user)?null:CaelumTimeSkipRules.FindFurniture(user,false);
        ChairFactor=chair!=null?chair.ComfortFactor():1;HasChair=chair!=null;
        let it=ThinkerIterator.Create("CaelumDiningTable");CaelumDiningTable table;
        while((table=CaelumDiningTable(it.Next()))!=null)
        {
            if(!CaelumTimeSkipRules.Accessible(user,table))continue;
            let stock=new("CaelumSkipTableStock");stock.First=Supplies.Size();stock.Capacity=table.Capacity();
            stock.Target=table.ForecastDailyTarget();Tables.Push(stock);
            for(int i=0;i<table.Capacity();i++)
            {
                AddSupply(table.Items[i]);let row=Supplies[Supplies.Size()-1];
                if(row.FoodClimate==null)
                {
                    row.FoodClimate=new('CaelumFoodClimate');
                    row.FoodClimate.Capture(table,CaelumWorldClock.Get(user),CaelumCalendarState.Get(user),CaelumWeatherState.Get(user));
                }
            }
        }
        for(int source=0;source<2;source++)
            for(Inventory cursor=user.Inv;cursor!=null;cursor=cursor.Inv)
            {
                let item=CaelumConsumableItem(cursor);
                if(CaelumTimeSkipRules.OwnedAvailable(user,item) && item.InMagicBox==(source==1))AddSupply(item);
            }
        let food=CaelumRegenerationPower(user.FindInventory("CaelumHungerRegeneration"));
        let water=CaelumRegenerationPower(user.FindInventory("CaelumThirstRegeneration"));
        if(food!=null)
        {FoodEffectTics=food.EffectTics;FoodPulseTics=food.PulseTics;FoodSeatedSubTics=food.SeatedMealSubTics;
            FoodPulse=food.FoodRecoveryPerPulse>0?food.FoodRecoveryPerPulse:1;}
        if(water!=null)
        {WaterEffectTics=water.EffectTics;WaterPulseTics=water.PulseTics;WaterSeatedSubTics=water.SeatedMealSubTics;
            WaterPulse=water.WaterRecoveryPerPulse>0?water.WaterRecoveryPerPulse:1;}
        // Otros poderes cambian el pronóstico de curación/consumo. El salto
        // puede ejecutarlos, pero no promete una fecha de tarea sin adaptador.
        for(Inventory cursor=user.Inv;cursor!=null;cursor=cursor.Inv)
            if(Powerup(cursor)!=null && cursor!=food && cursor!=water)
            {Reason="CA_SKIP_FORECAST_EFFECT";Done=true;}
        let status=user.ElementalStatus;
        let thermal=CaelumThermalBody.Get(user);
        // La ejecución integra estos estados; el modelo de fecha todavía no.
        // No presentar como exacta una previsión que omite daño o penalizaciones.
        if((status!=null && (status.HasBurnHeat() || status.BurnRemaining>0
            || status.PoisonRemaining>0 || status.DiseaseRemaining>0 || status.CutRemaining>0
            || status.FreezeRemaining>0 || status.DazzleRemaining>0 || status.EarthPenaltyRemaining>0))
            || (thermal!=null && thermal.Exposure!=0))
        {Reason="CA_SKIP_FORECAST_EFFECT";Done=true;}
        if(user.CraftingTaskActive && !user.RefreshActiveCraftingStationSession())
        {Reason="CA_FAST_ACTIVITY";Done=true;}
        let agenda=CaelumScheduleState.Get(user);
        if(!Limbo && agenda!=null)
            for(int i=0;i<agenda.Events.Size();i++)
            {
                let entry=agenda.Events[i];double next=entry.NextStamp();
                if(entry.Kind==CaelumScheduleRules.SIEGE && entry.MapName==level.MapName && next>=0
                    && (NextThreat<0 || next<NextThreat))NextThreat=next;
            }
        LocalDay();
    }
    void RefreshTriggers()
    {
        FoodTrigger=-1;WaterTrigger=-1;
        for(int i=0;i<Supplies.Size();i++)
        {
            let row=Supplies[i];if(!row.Usable())continue;
            double dose=CaelumTimeSkipRules.Dose(row.Kind,Mass,row.Liters,row.FoodLots!=null?row.FoodLots.Kind:CaelumFoodData.RATION);if(dose<=0.000001)continue;
            if(row.Kind==1)FoodTrigger=CaelumDiningSession.REST_TARGET;
            else WaterTrigger=CaelumDiningSession.REST_TARGET;
        }
    }
    // El motor sirve después de consumir recursos y avanzar los poderes.
    // El viaje conserva su propio orden; sólo este modelo cambia de fase.
    override void BeginServings() {}
    void ServeSupplies()
    {
        double target=Sleeping || HasChair?CaelumDiningSession.REST_TARGET:CaelumDiningSession.ORDINARY_TARGET;
        if(!((FoodEffectTics<=0 && Hunger<Min(target,FoodTrigger))
            || (WaterEffectTics<=0 && Thirst<Min(target,WaterTrigger))))return;
        for(int i=0;i<Supplies.Size();i++)
        {
            let row=Supplies[i];if(!row.Usable())continue;
            bool food=row.Kind==1;
            if(food?FoodEffectTics>0:WaterEffectTics>0)continue;
            double dose=CaelumTimeSkipRules.Dose(row.Kind,Mass,row.Liters,row.FoodLots!=null?row.FoodLots.Kind:CaelumFoodData.RATION);
            if(dose<=0.000001 || (food?Hunger:Thirst)>=target)continue;
            if(row.Kind==3)row.Liters=Max(0,row.Liters-Min(row.Liters,Mass/CaelumConstants.WATER_RECOVERY_PER_LITER_PER_PULSE));
            else row.Count--;
            if(food)
            {
                double contamination;
                if(row.FoodLots!=null && row.FoodLots.Consume(1,contamination) && FoodIllness!=null)
                    FoodIllness.Contamination=Min(100.0,FoodIllness.Contamination+CaelumFoodRules.Intake(
                        contamination,CaelumFoodData.ServingGrams(row.FoodLots.Kind),Mass));
                FoodSpent++;FoodEffectTics=CaelumConstants.CONSUMABLE_REGENERATION_SECONDS*TICRATE;
                FoodPulseTics=0;FoodSeatedSubTics=0;FoodPulse=dose/CaelumConstants.CONSUMABLE_REGENERATION_SECONDS;}
            else
            {WaterSpent++;WaterEffectTics=CaelumConstants.CONSUMABLE_REGENERATION_SECONDS*TICRATE;
                WaterPulseTics=0;WaterSeatedSubTics=0;WaterPulse=dose/CaelumConstants.CONSUMABLE_REGENERATION_SECONDS;}
        }
        LocalDay();
    }
    override void Pulses()
    {
        if(ToiletPulsesPrepared){ToiletPulsesPrepared=false;return;}
        bool seated=!Sleeping && HasChair;
        if(FoodEffectTics>0)
        {
            if(seated)FoodSeatedSubTics++;
            if(!seated || FoodSeatedSubTics>=CaelumRegenerationPower.SEATED_MEAL_TIC_DIVISOR)
            {
                if(seated)FoodSeatedSubTics=0;
                FoodPulseTics++;
                if(FoodPulseTics>=TICRATE)
                {
                    FoodPulseTics-=TICRATE;
                    double gained=Min(FoodPulse,100-Hunger);
                    Hunger+=gained;Sleep=Max(0,Sleep-gained/4);
                    if(FoodIllness!=null)FoodIllness.Satiation(gained);
                }
                FoodEffectTics--;
            }
        }
        if(WaterEffectTics>0)
        {
            if(seated)WaterSeatedSubTics++;
            if(!seated || WaterSeatedSubTics>=CaelumRegenerationPower.SEATED_MEAL_TIC_DIVISOR)
            {
                if(seated)WaterSeatedSubTics=0;
                WaterPulseTics++;
                if(WaterPulseTics>=TICRATE)
                {
                    WaterPulseTics-=TICRATE;double before=Thirst;Thirst=Min(100,Thirst+WaterPulse);
                    if(FoodIllness!=null)FoodIllness.Satiation(Thirst-before);
                }
                WaterEffectTics--;
            }
        }
    }
    override void ThirstStep(double comfort)
    {
        if(!PotableImmersed){Super.ThirstStep(comfort);return;}
        double gained=Max(0.0,Min(CaelumConstants.SURVIVAL_MAXIMUM-Thirst,
            CaelumConstants.SURVIVAL_MAXIMUM*CaelumConstants.POTABLE_WATER_THIRST_RECOVERY_RATIO_PER_SECOND/TICRATE));
        Thirst+=gained;if(FoodIllness!=null)FoodIllness.Satiation(gained);
    }
    override double Comfort(bool sleeping)
    {return Hunger<=CaelumTimeSkipRules.SleepAt() || Thirst<=CaelumTimeSkipRules.SleepAt()?1:sleeping?BedFactor:HasChair?ChairFactor:1;}
    override double SleepRecoveryScale() {return Scale;}
    override double AnimaComfort(bool sleeping)
    {return sleeping || Hunger<=CaelumTimeSkipRules.SleepAt() || Thirst<=CaelumTimeSkipRules.SleepAt()?1:Max(1,ChairFactor);}

    void LocalDay()
    {
        // La mansión repone los huecos tras cada consumo, además del cambio
        // de día. Los objetos depositados y las otras ubicaciones se conservan.
        for(int i=0;i<Tables.Size();i++)
        {
            let table=Tables[i];if(table.Target<=0)continue;
            int food=0,water=0;
            for(int j=table.First;j<table.First+table.Capacity;j++)
            {
                let row=Supplies[j];
                if(row.Kind==1)food+=row.Count;
                else if(row.Kind==2)water+=row.Count;
                else if(row.Kind==3 && row.Count>0)
                {if(row.Liters<=0.000001)row.WaterQuality=CaelumWaterQuality.POTABLE;row.Liters=row.CapacityLiters;water++;}
            }
            for(int j=table.First;j<table.First+table.Capacity;j++)
            {
                let row=Supplies[j];if(row.Count>0)continue;
                if(food<table.Target)
                {row.Kind=1;row.Count=1;row.FoodLots=new('CaelumFoodLots');row.FoodLots.Ensure(CaelumFoodData.RATION,1,0);food++;}
                // Capacidad del mismo objeto usado al reponer las mesas.
                else if(water<table.Target)
                {
                    let defaults=CaelumCanteenLarge(GetDefaultByType("CaelumCanteenLarge"));
                    row.Kind=3;row.Count=1;row.WaterQuality=CaelumWaterQuality.POTABLE;row.CapacityLiters=defaults.GetCapacityLiters();
                    row.Liters=row.CapacityLiters;water++;
                }
            }
        }
        RefreshTriggers();
    }
    bool NeedsSleepCleaning()
    {
        if(CleaningTask)return true;
        if(!SleepCleaningCloth || Contamination==null)return false;
        double water=0;for(int i=0;i<Supplies.Size();i++)if(Supplies[i].CleaningWater)water+=Supplies[i].Liters;
        for(int i=0;i<SleepCleaningIndices.Size();i++)
        {
            double liters=CaelumContaminationRules.EquipmentWaterLiters(SleepCleaningAreas[i]);
            if(Contamination.Items[SleepCleaningIndices[i]].Concentration>0 && liters>0
                && water+0.000000001>=liters && SleepCleaningSoap+0.000000001>=CaelumContaminationRules.SoapGrams(liters))return true;
        }
        return false;
    }
    void RunBatch()
    {
        for(int i=0;i<CaelumTimeSkipRules.FORECAST_BATCH_TICS && !Done;i++)
        {
            if(Hunger<=CaelumTimeSkipRules.SleepAt() || Thirst<=CaelumTimeSkipRules.SleepAt() || Health<=0)
            {Reason="CA_SKIP_PROVISIONS";Done=true;break;}
            if(EndDay-StartDay>=CaelumTimeSkipRules.MAX_DAYS)
            {Reason="CA_SKIP_HORIZON";Done=true;break;}
            if(!Limbo && EndDay>CaelumCalendarRules.MAX_SERIAL)
            {Reason="CA_CALENDAR_OUT_OF_RANGE";Done=true;break;}
            if(NextThreat>=0 && CaelumScheduleRules.Stamp(EndDay,EndTics)+int(SubTics+1>=Divisor)>=NextThreat)
            {Reason="CA_EVENT_SIEGE_INTERRUPT";Done=true;break;}
            bool sleepingNext=CaelumTimeSkipRules.SleepingNext(Sleeping,Sleep);
            if(!Sleeping && sleepingNext && NeedsSleepCleaning())
            {Reason="CA_SKIP_FORECAST_EFFECT";Done=true;break;}
            Sleeping=sleepingNext;
            Step(Sleeping);
            if(Sleeping)SleepTics++;else ProductiveTics++;
            SubTics++;
            if(SubTics>=Divisor)
            {
                SubTics=0;EndTics++;
                if(EndTics>=CaelumWorldClock.TicsPerDay()){EndTics=0;EndDay++;LocalDay();}
            }
            if(ProductiveTics>=RequiredTics)
            {
                // El selector muestra minutos; redondea hacia adelante para
                // no ofrecer un destino anterior al último tic productivo.
                int minute=CaelumWorldClock.TicsPerHour()/60;
                EndTics=((EndTics+int(SubTics>0)+minute-1)/minute)*minute;
                if(EndTics>=CaelumWorldClock.TicsPerDay()){EndTics=0;EndDay++;}
                Done=true;
            }
        }
    }
}
