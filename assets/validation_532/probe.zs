// Fixture aislada: las llamadas directas no representan entrada del autor.
class CA257Probe : StaticEventHandler
{
    int Failures;
    CaelumRestFurniture Support;
    CaelumDiningTable Table;
    void Check(bool ok,String label)
    {Console.Printf("CA257 %s %s",ok?"PASS":"FAIL",label);if(!ok)Failures++;}
    void ClearEffects(CaelumPlayer u)
    {
        let f=u.FindInventory("CaelumHungerRegeneration");if(f!=null)f.Destroy();
        let w=u.FindInventory("CaelumThirstRegeneration");if(w!=null)w.Destroy();
    }
    void Reset(CaelumPlayer u)
    {
        ClearEffects(u);
        let rest=CaelumRestState.Get(u,true);
        rest.Status=0;rest.Furniture=null;rest.UsesFurniture=false;rest.DiningTable=null;
        rest.ProvisionRevision=1;rest.AutoEating=true;rest.AutoDrinking=true;
        u.ForcedSleepTics=0;
        let skip=CaelumTimeSkipState.Get(u);if(skip!=null)skip.Active=false;
        if(Support!=null){Support.Destroy();Support=null;}
        if(Table!=null){Table.Destroy();Table=null;}
        Inventory cursor=u.Inv;
        while(cursor!=null)
        {
            Inventory next=cursor.Inv;
            if(CaelumTimeSkipRules.Kind(CaelumConsumableItem(cursor))!=0)cursor.Destroy();
            cursor=next;
        }
        u.CurrentHunger=u.CurrentThirst=u.CurrentSleep=100;
        u.CurrentAnima=u.DerivedStats.MaximumAnima;u.CurrentAir=u.DerivedStats.MaximumAir;
        u.health=u.CaelumMaximumHealth;u.player.health=u.health;
        u.SurvivalDamageAccumulator=0;u.NaturalHealthRegenerationAccumulator=0;
        CaelumDiningSession.Invalidate(u);
    }
    CaelumConsumableItem Food(CaelumPlayer u,int amount=5,bool boxed=false)
    {
        let item=CaelumConsumableItem(Actor.Spawn("CaelumFoodRation"));
        item.Amount=amount;item.InMagicBox=boxed;item.AttachToOwner(u);
        CaelumDiningSession.Invalidate(u);return item;
    }
    CaelumWaterContainer Water(CaelumPlayer u,double liters=1,bool boxed=false)
    {
        let item=CaelumWaterContainer(Actor.Spawn("CaelumCanteenLarge"));
        item.WaterLiters=liters;item.InMagicBox=boxed;item.AttachToOwner(u);
        CaelumDiningSession.Invalidate(u);return item;
    }
    void Posture(CaelumPlayer u,int mode)
    {
        let rest=CaelumRestState.Get(u,true);
        rest.OriginMap=level.MapName;rest.OriginPosition=u.Pos;
        rest.Status=CaelumRestRules.STATUS_ACTIVE;rest.AutoEating=true;rest.AutoDrinking=true;
        rest.Mode=mode==1?CaelumRestRules.MODE_WAIT:CaelumRestRules.MODE_SLEEP;
        rest.UsesFurniture=mode<=3;rest.Furniture=null;
        if(mode<=3)
        {
            class<CaelumRestFurniture> kind=mode==1?"CaelumRestChair":mode==2?"CaelumRestBed":"CaelumRestBag";
            Support=CaelumRestFurniture(Actor.Spawn(kind,u.Pos));Support.bSolid=false;
            Support.Occupant=u;rest.Furniture=Support;
            let mat=CaelumRestBag(Support);
            if(mat!=null)mat.Bag=CaelumSleepingBag(u.GiveInventoryType("CaelumSleepingBag"));
        }
        if(mode==5){rest.Status=0;u.ForcedSleepTics=100;}
        CaelumDiningSession.Invalidate(u);
    }
    void Thresholds(CaelumPlayer u)
    {
        Reset(u);let food=Food(u);let bottle=Water(u);
        u.CurrentHunger=u.CurrentThirst=50;CaelumDiningSession.Advance(u);
        Check(food.Amount==5 && bottle.WaterLiters==1,"exact-50-no-serving");
        u.CurrentHunger=49.9;CaelumDiningSession.Advance(u);
        Check(food.Amount==4 && bottle.WaterLiters==1,"food-independent-49.9");
        u.CurrentThirst=49.9;CaelumDiningSession.Advance(u);
        double sip=u.DerivedStats.BaseMass/CaelumConstants.WATER_RECOVERY_PER_LITER_PER_PULSE;
        Check(food.Amount==4 && Abs(bottle.WaterLiters-(1-sip))<0.000001,"water-independent-native-sip");
        for(int n=0;n<100;n++)CaelumDiningSession.Advance(u);
        Check(food.Amount==4 && Abs(bottle.WaterLiters-(1-sip))<0.000001,"in-flight-no-duplicate");
        for(int n=0;n<CaelumConstants.CONSUMABLE_REGENERATION_SECONDS*TICRATE;n++)CaelumTimeAdvanceState.AdvancePowers(u);
        Check(u.CurrentHunger>50 && u.CurrentThirst>50,"native-pulses-overshoot-50");
        CaelumDiningSession.Advance(u);
        Check(food.Amount==4,"recovery-stops-next-portion");
        for(int n=0;n<3;n++)
        {
            ClearEffects(u);u.CurrentHunger=u.CurrentThirst=49.9;
            CaelumDiningSession.Advance(u);
            Check(food.Amount==3-n,"threshold-rearms-without-manual-input");
        }
        Reset(u);food=Food(u);bottle=Water(u);
        u.CurrentHunger=u.CurrentThirst=49.9;CaelumDiningSession.Advance(u);
        Check(food.Amount==4 && bottle.WaterLiters<1,"both-channels-start");
    }
    void Postures(CaelumPlayer u)
    {
        for(int mode=1;mode<=5;mode++)
        {
            Reset(u);let food=Food(u);let bottle=Water(u);Posture(u,mode);
            u.CurrentHunger=u.CurrentThirst=80;CaelumDiningSession.Advance(u);
            Check(food.Amount==4 && bottle.WaterLiters<1,String.Format("posture-%d-auto-above-50",mode));
            ClearEffects(u);u.CurrentHunger=u.CurrentThirst=100;CaelumDiningSession.Advance(u);
            Check(food.Amount==4,String.Format("posture-%d-full-no-serving",mode));
            u.CurrentHunger=u.CurrentThirst=49.9;CaelumDiningSession.Advance(u);
            Check(food.Amount==3,String.Format("posture-%d-below-50",mode));
        }
        Reset(u);let food=Food(u,20);let bottle=Water(u);Posture(u,1);
        u.CurrentHunger=u.CurrentThirst=80;
        CaelumDiningSession.Toggle(u,false);CaelumDiningSession.Toggle(u,true);CaelumDiningSession.Advance(u);
        Check(food.Amount==20 && bottle.WaterLiters==1,"pause-rest-target");
        u.CurrentHunger=u.CurrentThirst=49.9;CaelumDiningSession.Advance(u);
        Check(food.Amount==19 && bottle.WaterLiters<1,"pause-cannot-disable-below-50");
        let power=CaelumRegenerationPower(u.FindInventory("CaelumHungerRegeneration"));
        int duration=power.EffectTics;
        for(int i=0;i<8;i++){CaelumDiningSession.Toggle(u,false);CaelumDiningSession.Advance(u);}
        Check(food.Amount==19 && power.EffectTics==duration,"repeated-toggle-keeps-in-flight-effect");
        CaelumDiningSession.Toggle(u,false);CaelumDiningSession.Toggle(u,true);
        u.CurrentHunger=u.CurrentThirst=80;
        for(int i=0;i<5000;i++){CaelumTimeAdvanceState.AdvancePowers(u);CaelumDiningSession.Advance(u);}
        Check(u.CurrentHunger==100 && u.CurrentThirst==100,"chair-fills-both-to-100");
        int remaining=food.Amount;for(int i=0;i<100;i++)CaelumDiningSession.Advance(u);
        Check(food.Amount==remaining,"100-no-extra-portion");
        ClearEffects(u);u.CurrentHunger=80;CaelumDiningSession.Advance(u);
        power=CaelumRegenerationPower(u.FindInventory("CaelumHungerRegeneration"));duration=power.EffectTics;
        let rest=CaelumRestState.Get(u);rest.Status=0;CaelumDiningSession.Advance(u);
        Check(food.Amount==remaining-1 && power.EffectTics==duration,"leaving-rest-preserves-current-portion");
    }
    void Sources(CaelumPlayer u)
    {
        Reset(u);CaelumInventoryService.GrantMagicBoxFromPalomo(u,false);
        let boxed=Food(u,3,true);let carried=Food(u,1);let water=Water(u,0.001,true);
        u.CurrentHunger=u.CurrentThirst=49;CaelumDiningSession.Advance(u);
        Check(carried.Amount==0 && boxed.Amount==3,"carried-before-owned-box");
        let effect=CaelumRegenerationPower(u.FindInventory("CaelumThirstRegeneration"));
        Check(water.Owner==u && water.InMagicBox && water.WaterLiters==0
            && Abs(effect.WaterRecoveryPerPulse-0.001*400/u.DerivedStats.BaseMass)<0.000001,"partial-final-volume-and-container-identity");
        ClearEffects(u);CaelumDiningSession.Advance(u);
        Check(boxed.Amount==2 && boxed.InMagicBox,"owned-box-fallback-retains-location");
        Reset(u);u.GetPersistentCharacterState(true).MagicBoxOwned=false;
        u.MagicBoxOwned=false;boxed=Food(u,3,true);water=Water(u,0);
        u.CurrentHunger=u.CurrentThirst=49;CaelumDiningSession.Advance(u);
        let rest=CaelumRestState.Get(u);
        Check(boxed.Amount==3 && rest.ProvisionBlocked==3,"unowned-box-empty-water-block-both-channels");
        for(int i=0;i<100;i++)CaelumDiningSession.Advance(u);
        Check(rest.ProvisionBlocked==3,"unavailable-channels-stay-cached");
        carried=Food(u,2);CaelumDiningSession.Advance(u);
        Check(carried.Amount==1 && rest.ProvisionBlocked==2,"supply-change-retries-independent-channel");
        Reset(u);carried=Food(u);water=Water(u);Posture(u,1);
        Table=CaelumDiningTable(Actor.Spawn("CaelumDiningTableSmall",u.Pos+(48,0,0)));
        let plate=Food(u,3);u.RemoveInventory(plate);plate.AttachToOwner(Table);Table.Items[0]=plate;
        u.CurrentHunger=80;CaelumDiningSession.Advance(u);
        Check(Table.CanDine(u) && plate.Amount==2 && plate.Owner==Table && carried.Amount==5,"eligible-table-first-single-unit");
        ClearEffects(u);u.CurrentHunger=80;Table.SetOrigin(u.Pos+(10000,0,0),false);CaelumDiningSession.Invalidate(u);
        CaelumDiningSession.Advance(u);
        Check(plate.Amount==2 && carried.Amount==4,"inaccessible-table-not-consumed");
    }
    void Forecasts(CaelumPlayer u)
    {
        for(int mode=0;mode<3;mode++)
        {
            Reset(u);let food=Food(u,20);let water=Water(u,5);
            if(mode>0)Posture(u,mode);
            let rest=CaelumRestState.Get(u);rest.Status=0;
            let skip=CaelumTimeSkipState.Get(u,true);skip.Active=true;skip.OriginMap=level.MapName;
            skip.Sleeping=mode==2;skip.Furniture=Support;skip.BagSupport=false;
            u.CurrentHunger=u.CurrentThirst=mode==0?49.9:80;u.CurrentSleep=70;
            let model=new("CaelumTimeSkipModel");model.CaptureSkip(u,mode==2);
            // Se aísla cada apoyo real de la disponibilidad del mapa de prueba.
            model.HasChair=mode==1;model.ChairFactor=mode==1?Support.ComfortFactor():1;
            model.BedFactor=mode==2?Support.ComfortFactor():1;
            for(int n=0;n<1200;n++)
            {model.Step(mode==2);CaelumTimeAdvanceState.SimulatePersonalTic(u);}
            Console.Printf("CA257 MODEL mode=%d food=%d/%d water=%.8f/%.8f hunger=%.8f/%.8f thirst=%.8f/%.8f sleep=%.8f/%.8f",
                mode,model.FoodSpent,20-food.Amount,model.Supplies[0].Liters,water.WaterLiters,
                model.Hunger,u.CurrentHunger,model.Thirst,u.CurrentThirst,model.Sleep,u.CurrentSleep);
            let f=CaelumRegenerationPower(u.FindInventory("CaelumHungerRegeneration"));
            let w=CaelumRegenerationPower(u.FindInventory("CaelumThirstRegeneration"));
            Check(model.FoodSpent==20-food.Amount && Abs(model.Supplies[0].Liters-water.WaterLiters)<0.000001
                && model.FoodEffectTics==(f!=null?f.EffectTics:0) && model.WaterEffectTics==(w!=null?w.EffectTics:0),
                String.Format("forecast-live-supply-cadence-1200-tics-mode-%d",mode));
            Check(model.ProvisionRevision==2,String.Format("forecast-revision-2-mode-%d",mode));
        }
        Reset(u);
    }
    void Digestion(CaelumPlayer u)
    {
        for(int mode=0;mode<3;mode++)
        {
            Reset(u);let food=Food(u,20);let water=Water(u,5);
            if(mode>0)Posture(u,mode);
            u.CurrentHunger=u.CurrentThirst=mode==0?49.9:80;
            let model=new("CaelumTimeSkipModel");model.CaptureSkip(u,mode==2);
            model.HasChair=mode==1;
            // Aísla digestión/umbrales del coste térmico previo a #257.
            for(int n=0;n<1200;n++)
            {
                model.Pulses();model.ServeSupplies();
                CaelumTimeAdvanceState.AdvancePowers(u);CaelumDiningSession.Advance(u);
            }
            Check(model.FoodSpent==20-food.Amount && Abs(model.Hunger-u.CurrentHunger)<0.000001
                && Abs(model.Thirst-u.CurrentThirst)<0.000001 && Abs(model.Sleep-u.CurrentSleep)<0.000001,
                String.Format("forecast-native-digestion-and-sleep-cost-mode-%d",mode));
        }
        Reset(u);
    }
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name=="c257_close")while(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="c257_setup")
        {
            if(u.player.ConversationNPC!=null)u.player.ConversationNPC.bInConversation=false;
            u.player.ConversationNPC=null;u.player.ConversationPC=null;
            u.CreationWizardOpen=false;u.CharacterCreationComplete=true;u.ApplyCharacterProfile();
            let r=u.GetPersistentCharacterState(true);r.ProfileCommitted=true;
            r.DemoNarrativeDelivered=2047;r.DemoNarrativePending=0;u.RecordMainM00UnknownVoiceHeard();
            u.PersistCharacterState();
        }
        if(e.Name=="c257_checks")
        {Thresholds(u);Postures(u);Sources(u);Reset(u);Console.Printf("CA257 DONE failures=%d",Failures);}
        if(e.Name=="c257_forecasts")
        {Forecasts(u);Digestion(u);Console.Printf("CA257 DONE failures=%d",Failures);}
        if(e.Name=="c257_migrated" || e.Name=="c257_paused")
        {
            let rest=CaelumRestState.Get(u);
            bool enabled=e.Name=="c257_migrated";
            Check(rest!=null && rest.ProvisionRevision==1 && rest.AutoEating==enabled && rest.AutoDrinking==enabled,
                enabled?"legacy-rest-migrates-to-automatic-once":"saved-pause-persists");
            let food=CaelumConsumableItem(u.FindInventory("CaelumFoodRation"));
            let water=CaelumWaterContainer(u.FindInventory("CaelumCanteenLarge"));
            Check(food!=null && food.Amount==2 && food.InMagicBox && water!=null && water.Owner==u && water.InMagicBox,
                "load-preserves-real-inventory-and-location");
            let f=CaelumRegenerationPower(u.FindInventory("CaelumHungerRegeneration"));
            Check(f!=null && f.EffectTics>0 && f.EffectTics<350,"load-continues-existing-effect-without-refresh");
            CaelumDiningSession.Migrate(rest);
            Check(rest.AutoEating==enabled && rest.AutoDrinking==enabled,"migration-idempotent");
            Console.Printf("CA257 DONE failures=%d",Failures);
        }
        if(e.Name=="c257_mansion")
        {
            let table=CaelumDiningTable.Nearby(u);
            Check(table!=null,"authored-table-reachable");
            int served=0;
            if(table!=null)
                for(int i=0;i<table.ForecastDailyTarget()+5;i++)
                {
                    ClearEffects(u);u.CurrentHunger=u.CurrentThirst=80;
                    if(CaelumDiningSession.Serve(u,false) && CaelumDiningSession.Serve(u,true))served++;
                }
            int food=0,water=0;
            if(table!=null)
                for(int i=0;i<table.Capacity();i++)
                {
                    let item=table.Items[i];int kind=CaelumTimeSkipRules.Kind(item);
                    if(kind==1)food+=item.Amount;else if(kind>=2)water+=item.Amount;
                }
            Check(table!=null && served==table.ForecastDailyTarget()+5 && food==table.ForecastDailyTarget()
                && water==table.ForecastDailyTarget(),"map01-native-refill-beyond-daily-quota");
            Check(CaelumTimeSkipState.OpenMenu(u),"authorized-time-skip-opens");
            let skip=CaelumTimeSkipState.Get(u);
            skip.TargetDay=CaelumTimeSkipState.NowDay(u);
            skip.TargetTics=CaelumTimeSkipState.NowTics(u)+CaelumWorldClock.TicsPerHour()/60;
            if(skip.TargetTics>=CaelumWorldClock.TicsPerDay()){skip.TargetTics-=CaelumWorldClock.TicsPerDay();skip.TargetDay++;}
            Check(CaelumTimeSkipState.Start(u),"authorized-time-skip-starts");
        }
        if(e.Name=="c257_skip_done")
        {
            let skip=CaelumTimeSkipState.Get(u);
            Check(skip!=null && skip.Completed && !skip.Active && skip.ElapsedTics>0,"native-time-skip-completes");
            Console.Printf("CA257 DONE failures=%d",Failures);
        }
        if(e.Name=="c257_hub_check")
        {
            let rest=CaelumRestState.Get(u);
            let food=CaelumConsumableItem(u.FindInventory("CaelumFoodRation"));
            let water=CaelumWaterContainer(u.FindInventory("CaelumCanteenLarge"));
            Check(rest!=null && rest.ProvisionRevision==1 && rest.ProvisionMap==level.MapName,"hub-updates-cache-map-without-resetting-revision");
            Check(food!=null && food.Amount==3 && food.InMagicBox && water!=null && water.InMagicBox
                && water.WaterLiters==1 && u.CurrentHunger<80 && u.CurrentHunger>50,"hub-preserves-reserves-and-resources");
            Console.Printf("CA257 DONE failures=%d",Failures);
        }
    }
}
