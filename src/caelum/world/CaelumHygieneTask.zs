// #502: la sesión usa el reloj de tareas; sólo el final cobra y depura.
class CaelumHygieneTask : Inventory
{
    int Revision;
    String OriginMap;
    CaelumDomesticToilet Fixture;

    static clearscope CaelumHygieneTask Find(CaelumPlayer user)
    {return user==null?null:CaelumHygieneTask(user.FindInventory('CaelumHygieneTask'));}
    static clearscope bool Active(CaelumPlayer user)
    {return user!=null && user.CraftingTaskActive && user.CraftingTaskKind==CaelumConstants.CRAFTING_TASK_HYGIENE;}
    static void Clear(CaelumPlayer user)
    {
        let task=Find(user);if(task==null)return;
        let advance=CaelumTimeAdvanceState.Get(user);
        if(advance!=null && advance.Active && advance.Station==task.Fixture)CaelumTimeAdvanceState.Halt(user);
        if(user.ActiveCraftingStationActor==task.Fixture)user.ActiveCraftingStationActor=null;
        task.Fixture=null;
    }
    static void Cancel(CaelumPlayer user)
    {
        if(!Active(user))return;
        user.CancelCraftingTask();
        CaelumNotifications.Notify(user,StringTable.Localize("CA_HYGIENE_CANCELLED",false));
    }
    static bool Attended(CaelumPlayer user)
    {
        let task=Find(user);
        return Active(user) && task!=null && task.Revision==CaelumMetabolismData.SESSION_REVISION
            && task.OriginMap==level.MapName && task.Fixture!=null && task.Fixture.CanReach(user)
            && user.player!=null && user.player.playerstate==PST_LIVE
            && user.CombatTimeRemaining<=0 && !user.HasActiveConversation()
            && !CaelumSleepRules.IsSleeping(user) && !user.PalomoMerchantMenuOpen;
    }
    static bool Begin(CaelumPlayer user,CaelumDomesticToilet fixture)
    {
        if(Active(user)){Cancel(user);return true;}
        if(!CaelumCampTask.Available(user) || fixture==null || !fixture.CanReach(user)
            || !CaelumUseGeometry.AimedAt(user,fixture))return false;
        let illness=CaelumFoodIllness.Get(user);
        if(illness==null || illness.ToiletAmount()<=0)
        {CaelumNotifications.Notify(user,StringTable.Localize("CA_TOILET_NO_CAPACITY",false));return false;}
        let reserve=CaelumDomesticWater.Get(fixture.House);
        if(reserve==null || reserve.Liters<CaelumMetabolismData.TOILET_WATER_LITERS)
        {CaelumNotifications.Notify(user,StringTable.Localize("CA_TOILET_NO_WATER",false));return false;}
        user.ClearCraftingTaskData();
        let task=Find(user);if(task==null)task=CaelumHygieneTask(user.GiveInventoryType('CaelumHygieneTask'));
        if(task==null)return false;
        task.Revision=CaelumMetabolismData.SESSION_REVISION;task.OriginMap=level.MapName;task.Fixture=fixture;
        user.ActiveCraftingStationActor=fixture;
        user.StartPreparedCraftingTask(CaelumConstants.CRAFTING_TASK_HYGIENE,CaelumMetabolismData.TOILET_WORLD_SECONDS);
        user.CraftingTaskRecipeIndex=-1;user.CraftingTaskNetworkCapabilities=0;
        user.EquipmentMenuOpen=false;user.CraftingMenuOpen=false;
        user.PersistCharacterState();
        CaelumNotifications.Notify(user,StringTable.Localize("CA_TOILET_STARTED",false));return true;
    }
    static bool Complete(CaelumPlayer user)
    {
        if(!Attended(user) || user.CraftingTaskRemainingSeconds>0)return false;
        let task=Find(user);let illness=CaelumFoodIllness.Get(user);
        let reserve=CaelumDomesticWater.Get(task.Fixture.House);
        // Revalidar después de cualquier consumo compartido o curación.
        if(illness==null || illness.ToiletAmount()<=0 || reserve==null
            || !reserve.Spend(CaelumMetabolismData.TOILET_WATER_LITERS))
        {CaelumNotifications.Notify(user,StringTable.Localize("CA_TOILET_UNAVAILABLE",false));return false;}
        double removed=illness.ToiletDepurate();
        user.LastCraftingAction=CaelumConstants.CRAFTING_ACTION_PROCESSED;
        CaelumNotifications.Notify(user,String.Format(StringTable.Localize("CA_TOILET_DONE",false),removed));
        return true;
    }
    Default {Inventory.Amount 1;Inventory.MaxAmount 1;Inventory.InterHubAmount 1;
        +INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE +INVENTORY.KEEPDEPLETED -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
