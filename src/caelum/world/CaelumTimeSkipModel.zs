// La previsión sólo guarda valores; nunca presta, consume ni genera Inventory.
class CaelumSkipSupply : Object play
{
    int Kind, Count;
    double Liters;
    void Capture(CaelumConsumableItem item)
    {
        Kind=CaelumTimeSkipRules.Kind(item);
        Count=item!=null?item.Amount:0;
        let bottle=CaelumWaterContainer(item);Liters=bottle!=null?bottle.WaterLiters:0;
    }
}
class CaelumSkipTableStock : Object play
{
    int First, Capacity, Target;
}

class CaelumTimeSkipModel : CaelumJourneyModel
{
    Array<CaelumSkipSupply> Supplies;
    Array<CaelumSkipTableStock> Tables;
    bool Done, Sleeping, Limbo;
    String Reason;
    int EndDay, EndTics, SubTics, Divisor, BedFactor;
    int ProductiveTics, RequiredTics, StartDay;
    double Scale, NextThreat, FoodTrigger, WaterTrigger;
    int HealthBeforeStep;
    double AdrenalineBeforeStep;

    override void Step(bool sleeping)
    {
        // El jugador calcula rendimiento al comienzo del tic, antes de curar
        // salud y decaer adrenalina. Respetar ese orden evita adelantar umbrales.
        HealthBeforeStep=Health;AdrenalineBeforeStep=Adrenaline;Super.Step(sleeping);
    }
    override int AirHealth(){return HealthBeforeStep;}
    override double AirAdrenaline(){return AdrenalineBeforeStep;}

    void AddSupply(CaelumConsumableItem item)
    {
        let row=new("CaelumSkipSupply");row.Capture(item);Supplies.Push(row);
    }
    void CaptureSkip(CaelumPlayer user,bool alreadySleeping)
    {
        Capture(user,false);
        Scale=CaelumWorldClock.MapTimeScale(level.MapName);
        HungerLoss*=Scale;ThirstLoss*=Scale;SleepLoss*=Scale;
        Limbo=CaelumWorldCatalogue.IsLimboMap(level.MapName);Divisor=Limbo?20:1;
        let clock=CaelumWorldClock.Get(user);
        EndDay=CaelumTimeSkipState.NowDay(user);StartDay=EndDay;
        EndTics=CaelumTimeSkipState.NowTics(user);SubTics=Limbo?clock.LimboSubTics:0;
        RequiredTics=Max(0,int(Ceil(user.CraftingTaskRemainingSeconds*TICRATE-0.000001)));
        Sleeping=alreadySleeping;NextThreat=-1;
        let bed=CaelumTimeSkipRules.FindFurniture(user,true);
        BedFactor=bed!=null?bed.ComfortFactor():Bag && CaelumRestBag.HasRoom(user)?3:1;
        let it=ThinkerIterator.Create("CaelumDiningTable");CaelumDiningTable table;
        while((table=CaelumDiningTable(it.Next()))!=null)
        {
            if(!CaelumTimeSkipRules.Accessible(user,table))continue;
            let stock=new("CaelumSkipTableStock");stock.First=Supplies.Size();stock.Capacity=table.Capacity();
            stock.Target=table.ForecastDailyTarget();Tables.Push(stock);
            for(int i=0;i<table.Capacity();i++)AddSupply(table.Items[i]);
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
        {FoodEffectTics=food.EffectTics;FoodPulseTics=food.PulseTics;
            FoodPulse=food.FoodRecoveryPerPulse>0?food.FoodRecoveryPerPulse:1;}
        if(water!=null)
        {WaterEffectTics=water.EffectTics;WaterPulseTics=water.PulseTics;
            WaterPulse=water.WaterRecoveryPerPulse>0?water.WaterRecoveryPerPulse:1;}
        // Otros poderes cambian el pronóstico de curación/consumo. El salto
        // puede ejecutarlos, pero no promete una fecha de tarea sin adaptador.
        for(Inventory cursor=user.Inv;cursor!=null;cursor=cursor.Inv)
            if(Powerup(cursor)!=null && cursor!=food && cursor!=water)
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
        RefreshTriggers();
    }
    void RefreshTriggers()
    {
        FoodTrigger=-1;WaterTrigger=-1;
        for(int i=0;i<Supplies.Size();i++)
        {
            let row=Supplies[i];if(row.Count<=0 || row.Kind==0)continue;
            double dose=CaelumTimeSkipRules.Dose(row.Kind,Mass,row.Liters);if(dose<=0.000001)continue;
            if(row.Kind==1)FoodTrigger=Max(FoodTrigger,100-Min(100,dose));
            else WaterTrigger=Max(WaterTrigger,100-Min(100,dose));
        }
    }
    override void BeginServings()
    {
        if(!((FoodEffectTics<=0 && Hunger<=FoodTrigger) || (WaterEffectTics<=0 && Thirst<=WaterTrigger)))return;
        for(int i=0;i<Supplies.Size();i++)
        {
            let row=Supplies[i];if(row.Count<=0 || row.Kind==0)continue;
            bool food=row.Kind==1;
            if(food?FoodEffectTics>0:WaterEffectTics>0)continue;
            double dose=CaelumTimeSkipRules.Dose(row.Kind,Mass,row.Liters);
            if(!CaelumTimeSkipRules.NeedsServing(food?Hunger:Thirst,dose))continue;
            if(row.Kind==3)row.Liters=Max(0,row.Liters-Min(row.Liters,Mass/CaelumConstants.WATER_RECOVERY_PER_LITER_PER_PULSE));
            else row.Count--;
            if(food)
            {FoodSpent++;FoodEffectTics=CaelumConstants.CONSUMABLE_REGENERATION_SECONDS*TICRATE;
                FoodPulseTics=0;FoodPulse=dose/CaelumConstants.CONSUMABLE_REGENERATION_SECONDS;}
            else
            {WaterSpent++;WaterEffectTics=CaelumConstants.CONSUMABLE_REGENERATION_SECONDS*TICRATE;
                WaterPulseTics=0;WaterPulse=dose/CaelumConstants.CONSUMABLE_REGENERATION_SECONDS;}
        }
        RefreshTriggers();
    }
    override double Comfort(bool sleeping)
    {return Hunger<=CaelumTimeSkipRules.SleepAt() || Thirst<=CaelumTimeSkipRules.SleepAt()?1:sleeping?BedFactor:1;}
    override double SleepRecoveryScale() {return Scale;}

    void LocalDay()
    {
        // El mismo contrato de #65: completar huecos, jamás sobrescribir ni
        // acumular una entrega por cada día perdido.
        for(int i=0;i<Tables.Size();i++)
        {
            let table=Tables[i];if(table.Target<=0)continue;
            int food=0,water=0;
            for(int j=table.First;j<table.First+table.Capacity;j++)
            {let row=Supplies[j];if(row.Kind==1)food+=row.Count;else if(row.Kind==2)water+=row.Count;}
            for(int j=table.First;j<table.First+table.Capacity;j++)
            {
                let row=Supplies[j];if(row.Count>0)continue;
                if(food<table.Target){row.Kind=1;row.Count=1;food++;}
                else if(water<table.Target){row.Kind=2;row.Count=1;water++;}
            }
        }
        RefreshTriggers();
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
            Sleeping=CaelumTimeSkipRules.SleepingNext(Sleeping,Sleep);
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
