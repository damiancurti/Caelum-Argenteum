// El recipiente comparte un único lote entre usuarios autorizados. Conserva
// su ambiente, no el del viajero que regresa; no simula actores descargados.
class CaelumProofingBatch : Object play
{
    int Revision,Generation;
    bool Occupied;
    double StartedAt,LastStamp;
    CaelumFoodLots Lots;
    CaelumFoodClimate Climate;
    clearscope bool Ready(double now)
    {return Occupied && Revision==CaelumCookingData.REVISION && now>=StartedAt+CaelumMealData.PROOF_SECONDS;}
    clearscope double SecondsLeft(double now)
    {return Occupied?Max(0,StartedAt+CaelumMealData.PROOF_SECONDS-now):0;}
    void Advance(double now)
    {
        if(!Occupied || now<=LastStamp)return;
        if(Climate!=null)Climate.Advance(Lots,now-LastStamp);
        LastStamp=now;
    }
}
class CaelumProofingRecord : Object play
{
    String MapName;
    Vector3 Position;
    CaelumProofingBatch Batch;
}
class CaelumProofing : Object play
{
    static CaelumProofingRecord Record(CaelumPersistentCharacterState persistent,CaelumKitchenCounterStation counter)
    {
        if(persistent==null)return null;
        for(int i=0;i<persistent.ProofingBatches.Size();i++)
            if(persistent.ProofingBatches[i].MapName==level.MapName && persistent.ProofingBatches[i].Position==counter.Pos)
                return persistent.ProofingBatches[i];
        return null;
    }
    static CaelumProofingBatch Bind(CaelumPlayer user,CaelumKitchenCounterStation counter)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || counter==null)return null;
        let persistent=user.GetPersistentCharacterState(true);if(persistent==null)return null;
        let own=Record(persistent,counter);
        if(counter.Batch==null && own!=null)counter.Batch=own.Batch;
        if(counter.Batch==null)
            for(int p=0;p<MAXPLAYERS;p++)
            {
                if(!playeringame[p])continue;
                let other=CaelumPlayer(players[p].mo);
                let record=other!=null?Record(other.GetPersistentCharacterState(false),counter):null;
                if(record!=null){counter.Batch=record.Batch;break;}
            }
        if(counter.Batch==null)counter.Batch=new('CaelumProofingBatch');
        if(own==null)
        {
            own=new('CaelumProofingRecord');own.MapName=level.MapName;own.Position=counter.Pos;
            persistent.ProofingBatches.Push(own);
        }
        own.Batch=counter.Batch;
        counter.MenuNow=CaelumFermentationService.Now(user);
        counter.Batch.Advance(counter.MenuNow);
        return counter.Batch;
    }
    static bool Reachable(CaelumPlayer user,CaelumKitchenCounterStation counter)
    {
        return CaelumPlayerAuthority.CanMutate(user) && counter!=null && user.player!=null
            && user.player.playerstate==PST_LIVE && user.health>0 && !user.isFrozen()
            && user.CombatTimeRemaining<=0 && counter.CanReachFrom(user)
            && user.Distance3D(counter)<=CaelumConstants.CRAFTING_ACTIVE_STATION_DISTANCE;
    }
    static bool Begin(CaelumPlayer user,CaelumKitchenCounterStation counter)
    {
        if(!Reachable(user,counter) || user.CraftingTaskActive
            || !user.DirectCraftingRecipeKnown(CaelumMealData.FIRST_RECIPE,1))return false;
        let batch=Bind(user,counter);
        double now=counter.MenuNow,water=CaelumMealData.WaterLiters(CaelumMealData.BREAD);
        if(batch==null || batch.Occupied || now<0 || CaelumFermentationService.AvailableWater(user)+0.0000001<water)return false;
        double foodGrams=0,contamination=0;
        for(int slot=0;slot<3;slot++)
        {
            int id=CaelumMealData.InputMaterial(CaelumMealData.BREAD,slot);
            int grams=CaelumMealData.InputGrams(CaelumMealData.BREAD,slot);
            if(user.CountCraftingMaterial(id,1)<grams)return false;
            foodGrams+=grams;
            let input=Inventory(user.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,id,1));
            if(CaelumFoodInventory.IsFood(input))
            {
                CaelumFoodInventory.Reconcile(input);
                let copy=CaelumFoodInventory.GetLots(input).CopyOldest(grams);
                if(copy==null)return false;
                double part;if(!copy.Consume(grams,part))return false;
                contamination+=part*grams;
            }
        }
        let climate=new('CaelumFoodClimate');
        if(!climate.Capture(counter,CaelumWorldClock.Get(user),CaelumCalendarState.Get(user),CaelumWeatherState.Get(user)))return false;
        let lots=new('CaelumFoodLots');lots.Ensure(CaelumFoodData.DOUGH,0,now);
        if(!lots.Add(CaelumCookingData.DOUGH_GRAMS,contamination/foodGrams,now))return false;
        for(int slot=0;slot<3;slot++)user.ConsumeCraftingMaterial(CaelumMealData.InputMaterial(CaelumMealData.BREAD,slot),1,
            CaelumMealData.InputGrams(CaelumMealData.BREAD,slot));
        CaelumFermentationService.ConsumeWater(user,water);
        batch.Revision=CaelumCookingData.REVISION;batch.Generation++;batch.Occupied=true;
        batch.StartedAt=now;batch.LastStamp=now;batch.Lots=lots;batch.Climate=climate;
        user.OnNativeInventoryChanged();user.PersistCharacterState();return true;
    }
    static bool Withdraw(CaelumPlayer user,CaelumKitchenCounterStation counter)
    {
        if(!Reachable(user,counter) || user.CraftingTaskActive)return false;
        let batch=Bind(user,counter);
        if(batch==null || !batch.Ready(counter.MenuNow) || batch.Lots==null
            || batch.Lots.Units()!=CaelumCookingData.DOUGH_GRAMS)return false;
        let existing=user.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,CaelumCookingData.DOUGH,1);
        int units=CaelumCookingData.DOUGH_GRAMS;
        if(existing!=null && existing.Amount>2147483647-units)return false;
        bool boxed=existing!=null && existing.InMagicBox;
        double mass=units*CaelumMaterialRules.UnitWeight(CaelumCookingData.DOUGH);
        user.RefreshCarriedInventorySummary();
        if((boxed && !user.MagicBoxOwned) || !user.CanApplyInventoryWeightTransition(boxed?0:mass,boxed?mass:0))return false;
        CaelumMaterialPickup detached;
        if(existing==null)
        {
            detached=user.CreateDetachedMaterialStack(CaelumCookingData.DOUGH,1,units);
            if(detached==null)return false;
            detached.Amount=0;CaelumFoodInventory.SetLots(detached,null);
        }
        else CaelumFoodInventory.Reconcile(existing);
        Inventory output=existing;
        if(output==null)output=detached;
        let target=CaelumFoodInventory.Prepare(output);
        if(!batch.Lots.TransferTo(target,units)){if(detached!=null)detached.Destroy();return false;}
        output.Amount+=units;
        if(detached!=null)detached.AttachToOwner(user);
        batch.Occupied=false;batch.Generation++;batch.Lots=null;batch.Climate=null;
        CaelumFoodInventory.Relocate(output);CaelumNotifications.Acquired(user,output,units);
        user.OnNativeInventoryChanged();user.PersistCharacterState();return true;
    }
    static void Act(CaelumPlayer user,int generation)
    {
        let counter=user!=null?CaelumKitchenCounterStation(user.ActiveCraftingStationActor):null;
        if(user==null || !user.CraftingMenuOpen || counter==null || !Reachable(user,counter))return;
        let batch=Bind(user,counter);if(batch==null || generation!=batch.Generation)return;
        bool ok=batch.Occupied?Withdraw(user,counter):Begin(user,counter);
        user.LastCraftingAction=ok?CaelumConstants.CRAFTING_ACTION_PROCESSED:CaelumConstants.CRAFTING_ACTION_FAILED_MATERIALS;
    }
}
