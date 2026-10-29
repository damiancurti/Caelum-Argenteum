// #411: la comida recibe sólo el tiempo útil realmente quemado por su fogata.
// La reserva de comida es la misma de #410; la leña pertenece a la fogata.
class CaelumCampCooking : Object play
{
    const REVISION=1;
    static clearscope bool Active(CaelumPlayer user)
    {let task=CaelumCookingTaskState.FindCooking(user);return CaelumCookingCrafting.Active(user) && task!=null && task.Camp;}
    static clearscope bool Owns(CaelumPlayer user,CaelumCampFire fire)
    {let task=CaelumCookingTaskState.FindCooking(user);return Active(user) && task.Fire==fire;}
    static bool PotReady(CaelumCampFire fire,int recipe)
    {
        if(CaelumCookingData.Meal(recipe)!=CaelumMealData.PUCHERO)return true;
        return fire!=null && fire.Pot!=null && fire.Pot.Owner==fire && fire.Pot.WaterLiters<=0;
    }
    static bool Begin(CaelumPlayer user,CaelumCampFire fire,int recipe)
    {
        if(!CaelumCampTask.Available(user) || fire==null || !fire.CanManage(user) || fire.Busy!=null
            || !CaelumMealData.IsRecipe(recipe) || CaelumCookingData.Meal(recipe)==CaelumMealData.BREAD
            || !user.DirectCraftingRecipeKnown(recipe,1) || !PotReady(fire,recipe))return false;
        fire.Advance();if(fire.Fuel==null || !fire.Fuel.Lit || fire.Fuel.FuelGrams<=0)return false;
        let task=CaelumCookingCrafting.Reserve(user,recipe,fire);if(task==null)return false;
        fire.Busy=user;user.ActiveCraftingStationActor=fire;
        user.CraftingSelectionRecipe=recipe;user.CraftingSelectionTier=1;
        user.CraftingNetworkCapabilities=0;user.CraftingMenuOpen=false;user.EquipmentMenuOpen=false;
        user.StartPreparedCraftingTask(CaelumConstants.CRAFTING_TASK_COOKING,CaelumCookingData.Seconds(recipe));
        user.CraftingTaskNetworkCapabilities=0;user.PersistCharacterState();return true;
    }
    static bool Attended(CaelumPlayer user,bool needHeat=true)
    {
        let task=CaelumCookingTaskState.FindCooking(user);
        if(!Active(user) || task.CampRevision!=REVISION || task.OriginMap!=level.MapName || task.Fire==null
            || task.Fire.bDestroyed || task.Fire.Busy!=user || !task.Fire.CanManage(user)
            || user.health<=0 || user.player==null || user.player.playerstate!=PST_LIVE || user.isFrozen()
            || user.CombatTimeRemaining>0 || user.HasActiveConversation() || user.EquipmentMenuOpen
            || user.PalomoMerchantMenuOpen || !PotReady(task.Fire,task.Recipe))return false;
        return !needHeat || task.IgnitionSeconds>0 || task.HeatSeconds>0 || (task.Fire.Fuel!=null && task.Fire.Fuel.Lit);
    }
    static bool ReceivesHeat(CaelumPlayer user)
    {
        return Attended(user,false) && !CaelumSleepRules.IsSleeping(user) && !CaelumTimeSkipState.PausesWork(user)
            && !(CaelumTimeSkipState.IsActive(user) && CaelumScheduleState.SiegeActive(user,level.MapName));
    }
    static bool HoldsHeat(CaelumCampFire fire)
    {return fire!=null && fire.Busy!=null && Owns(fire.Busy,fire);}
    static void CreditHeat(CaelumCampFire fire,double burning)
    {
        if(!HoldsHeat(fire) || !ReceivesHeat(fire.Busy))return;
        let task=CaelumCookingTaskState.FindCooking(fire.Busy);
        if(task.IgnitionSeconds<=0)task.HeatSeconds=Min(fire.Busy.CraftingTaskRemainingSeconds,task.HeatSeconds+burning);
    }
    static bool Relight(CaelumPlayer user,CaelumCampFire fire)
    {
        if(!Owns(user,fire) || !Attended(user,false) || fire.Fuel==null)return false;
        fire.Advance();if(fire.Fuel.Lit)return true;
        if(fire.Fuel.FuelGrams<=0)return false;
        let task=CaelumCookingTaskState.FindCooking(user);
        if(task.IgnitionSeconds<=0)task.IgnitionSeconds=CaelumCampData.IGNITE_SECONDS;
        user.PersistCharacterState();return true;
    }
    static void Advance(CaelumPlayer user)
    {
        let task=CaelumCookingTaskState.FindCooking(user);if(!Active(user) || !ReceivesHeat(user))return;
        task.Fire.Advance();
        if(task.IgnitionSeconds>0)
        {
            task.IgnitionSeconds=Max(0,task.IgnitionSeconds-CaelumThermalRuntime.WorldTicSeconds());
            if(task.IgnitionSeconds<0.0000001)
            {task.IgnitionSeconds=0;if(task.Fire.Fuel.FuelGrams>0){task.Fire.Fuel.Lit=true;task.Fire.RefreshVisual();}}
            return;
        }
        user.CraftingTaskRemainingSeconds=Max(0,user.CraftingTaskRemainingSeconds-task.HeatSeconds);task.HeatSeconds=0;
        if(user.CraftingTaskRemainingSeconds<0.0000001)
        {user.CraftingTaskRemainingSeconds=0;user.CompleteCraftingTask();}
    }
    static void Clear(CaelumPlayer user,CaelumCookingTaskState task)
    {
        if(task.Fire!=null && task.Fire.Busy==user)
        {task.Fire.Advance();task.Fire.Busy=null;}
        let advance=CaelumTimeAdvanceState.Get(user);
        if(task.Camp && advance!=null && advance.Active && advance.Station==task.Fire)CaelumTimeAdvanceState.Halt(user);
        task.Camp=false;task.Fire=null;task.OriginMap="";task.HeatSeconds=0;task.IgnitionSeconds=0;
    }
}
