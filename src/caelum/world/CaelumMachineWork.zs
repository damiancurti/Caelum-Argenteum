// La reserva y el reloj pertenecen al trabajo nativo del personaje, no a otra cartera.
class CaelumMachineWork : Inventory
{
    enum ActionType { BUILD, REPAIR, SABOTAGE, CAPTURE };
    int Revision,Serial,WorkKind,Kind,Faction,DamageSnapshot,RepairHealth;
    bool Paused,FixSabotage,Completed;
    String OriginMap,Status;
    Actor Contact,Station;
    CaelumHostileMachine Machine;
    CaelumBreakableGate Structure;
    CaelumMachineWorkAnchor Anchor;
    vector3 Point;
    double Facing;

    static CaelumMachineWork Find(CaelumPlayer user)
    {return user==null?null:CaelumMachineWork(user.FindInventory('CaelumMachineWork'));}
    static bool Active(CaelumPlayer user)
    {return user!=null && user.CraftingTaskActive && user.CraftingTaskKind==CaelumConstants.CRAFTING_TASK_MACHINE;}
    static bool RealTime(CaelumPlayer user)
    {let work=Find(user);return Active(user) && work!=null && work.WorkKind>=SABOTAGE;}
    static void Clear(CaelumPlayer user)
    {
        let work=Find(user);if(work==null)return;
        if(work.Machine!=null && work.Machine.Worker==user)work.Machine.Worker=null;
        let barrier=CaelumBarricade(work.Structure);if(barrier!=null && barrier.Worker==user)barrier.Worker=null;
        if(work.Anchor!=null)work.Anchor.Destroy();work.Anchor=null;
        work.Contact=null;work.Station=null;work.Machine=null;work.Structure=null;work.Paused=false;work.Completed=false;
    }
    static void Interrupt(CaelumPlayer user)
    {
        let work=Find(user);if(!Active(user) || work==null)return;
        work.Paused=true;work.Status="CA_MACHINE_INTERRUPTED";CaelumTimeAdvanceState.Halt(user);
    }
    static bool Ready(CaelumPlayer user)
    {return CaelumPlayerAuthority.CanMutate(user) && user.health>0 && user.player!=null
        && user.player.playerstate==PST_LIVE && !user.isFrozen() && !CaelumSleepRules.IsSleeping(user)
        && !user.CraftingTaskActive && !CaelumRecipeSession.Working(user) && !user.HasActiveConversation();}
    static bool Holds(CaelumPlayer user,CaelumBreakableGate hull)
    {
        let work=Find(user);
        return user!=null && user.health>0 && CaelumPlayerAuthority.CanMutate(user) && Active(user)
            && work!=null && work.Structure==hull && work.OriginMap==level.MapName;
    }
    static CaelumMachineWork Allocate(CaelumPlayer user)
    {
        user.ClearCraftingTaskData();let work=Find(user);
        if(work==null)work=CaelumMachineWork(user.GiveInventoryType('CaelumMachineWork'));
        if(work!=null){work.Revision=CaelumMachineData.WORK_REVISION;work.Serial++;work.OriginMap=level.MapName;work.Status="";}
        return work;
    }
    void Remember(CaelumPlayer user)
    {
        if(Anchor!=null)return;
        Anchor=CaelumMachineWorkAnchor(Actor.Spawn('CaelumMachineWorkAnchor',user.Pos,NO_REPLACE));
        if(Anchor!=null)
        {
            Anchor.Worker=user;Anchor.Serial=Serial;Anchor.Machine=Machine;Anchor.Structure=Structure;
            Anchor.Contact=Contact;Anchor.Station=Station;
        }
    }
    static bool Reach(CaelumPlayer user,Actor contact)
    {
        if(user==null || contact==null || contact.bDestroyed)return false;
        vector3 point=(Clamp(user.Pos.X,contact.Pos.X-contact.Radius,contact.Pos.X+contact.Radius),
            Clamp(user.Pos.Y,contact.Pos.Y-contact.Radius,contact.Pos.Y+contact.Radius),
            Clamp(user.Pos.Z+user.Height/2,contact.Pos.Z,contact.Pos.Z+contact.Height));
        return ((user.Pos+(0,0,user.Height/2))-point).Length()<=user.UseRange
            && user.CheckSight(contact,SF_IGNOREVISIBILITY);
    }
    static bool BeginBuild(CaelumPlayer user,int faction,vector3 point,double facing)
    {
        if(!Ready(user) || !CaelumMachineData.IsRecipe(user.CraftingSelectionRecipe)
            || !CaelumMachineOwnership.Member(user,faction) || !CaelumMachineOwnership.Admission())return false;
        user.RefreshCraftingPreview();
        if(!user.CanStartCraftingTask() || !user.CraftingSelectedRecipeKnown)return false;
        int kind=user.CraftingSelectionRecipe-CaelumMachineData.FIRST_RECIPE;
        if(!CaelumMachineCrafting.Fits(user,kind,point))return false;
        let work=Allocate(user);if(work==null)return false;
        if(!user.ReserveCurrentCraftingPreview()){user.ClearCraftingTaskData();return false;}
        work.WorkKind=BUILD;work.Kind=kind;work.Faction=faction;work.Point=point;work.Facing=facing;
        work.Station=user.ActiveCraftingStationActor;
        user.StartPreparedCraftingTask(CaelumConstants.CRAFTING_TASK_MACHINE,user.CraftingPreviewSeconds);
        work.Remember(user);
        return true;
    }
    static bool Begin(CaelumPlayer user,Actor target,Actor contact,int operation,int faction)
    {
        if(!Ready(user) || !Reach(user,contact) || operation<REPAIR || operation>CAPTURE)return false;
        let machine=CaelumHostileMachine(target);let barrier=CaelumBarricade(target);
        if(machine!=null)machine.EnsureMachine();
        else if(barrier!=null)barrier.InitializeGate();
        CaelumBreakableGate hull=machine!=null?CaelumBreakableGate(machine.Structure):CaelumBreakableGate(barrier);
        if(hull==null || hull.Broken || hull.health<=0)return false;
        CaelumPlayer worker=machine!=null?machine.Worker:barrier.Worker;
        if(worker!=user && Holds(worker,hull))return false;
        if(operation>=SABOTAGE && (machine==null || machine.OwnerFaction>=0 || CaelumMachineOwnership.EnemyOperators(machine)))return false;
        if(operation==SABOTAGE && machine.Sabotaged)return false;
        if(operation==CAPTURE && (!CaelumMachineOwnership.Member(user,faction) || !CaelumMachineOwnership.Admission()))return false;
        int missingHealth=hull.StructuralMaximum-hull.health;
        bool disabled=machine!=null && machine.Sabotaged;
        if(operation==REPAIR && missingHealth==0 && !disabled)return false;
        let work=Allocate(user);if(work==null)return false;
        work.WorkKind=operation;work.Kind=machine!=null?machine.MachineKind():CaelumMachineData.BARRICADE;
        work.Faction=faction;work.Machine=machine;work.Structure=hull;work.Contact=contact;
        work.RepairHealth=missingHealth;work.FixSabotage=disabled;
        work.DamageSnapshot=machine!=null?machine.DamageSerial:barrier.DamageSerial;
        double seconds=operation==CAPTURE?CaelumMachineData.CAPTURE_SECONDS:CaelumMachineData.SABOTAGE_SECONDS;
        if(operation==REPAIR)
        {
            double fraction=double(missingHealth)/hull.StructuralMaximum+(disabled?CaelumMachineData.SABOTAGE_REPAIR_FRACTION:0);
            if(!user.AddCraftingTaskReservation(CaelumConstants.MATERIAL_WOOD,1,CaelumMachineData.Grams(work.Kind,0,fraction))
                || !user.AddCraftingTaskReservation(CaelumConstants.MATERIAL_IRON_INGOT,1,CaelumMachineData.Grams(work.Kind,1,fraction))
                || !user.ValidateCraftingTaskReservations()){user.ClearCraftingTaskData();return false;}
            seconds=CaelumMachineData.Seconds(work.Kind)*fraction;
        }
        if(machine!=null)machine.Worker=user;else barrier.Worker=user;
        user.ActiveCraftingStationActor=contact;user.CraftingMenuOpen=false;
        user.StartPreparedCraftingTask(CaelumConstants.CRAFTING_TASK_MACHINE,seconds);
        user.CraftingTaskRecipeIndex=-1;user.CraftingTaskNetworkCapabilities=0;user.PersistCharacterState();
        work.Remember(user);
        return true;
    }
    static bool Attended(CaelumPlayer user)
    {
        let work=Find(user);
        if(!Active(user) || work==null || work.Completed || work.Revision!=CaelumMachineData.WORK_REVISION
            || work.OriginMap!=level.MapName || work.Paused || user.health<=0 || user.isFrozen()
            || CaelumSleepRules.IsSleeping(user) || user.HasActiveConversation())return false;
        if(work.WorkKind==BUILD)
        {
            let station=CaelumCraftingStation(work.Station);
            if(station==null || !user.CraftingMenuOpen || user.CombatTimeRemaining>0
                || !station.CanReachFrom(user) || user.Distance3D(station)>CaelumConstants.CRAFTING_ACTIVE_STATION_DISTANCE)return false;
            if(level.time%TICRATE==0)
            {int token=user.BeginCraftingNetworkScan();station.CollectCraftingNetwork(user,token);}
            return CaelumMachineOwnership.Member(user,work.Faction)
                && CaelumMachineCrafting.MissingStation(work.Kind,user.CraftingNetworkCapabilities)==CaelumConstants.CRAFTING_STATION_NONE;
        }
        if(work.Structure==null || work.Structure.Broken || !Reach(user,work.Contact))return false;
        CaelumPlayer worker=work.Machine!=null?work.Machine.Worker:CaelumBarricade(work.Structure).Worker;
        if(worker!=user){Interrupt(user);return false;}
        int damage=work.Machine!=null?work.Machine.DamageSerial:CaelumBarricade(work.Structure).DamageSerial;
        if(damage!=work.DamageSnapshot){Interrupt(user);return false;}
        if(work.WorkKind>=SABOTAGE && CaelumMachineOwnership.EnemyOperators(work.Machine))return false;
        if(work.WorkKind==CAPTURE && !CaelumMachineOwnership.Member(user,work.Faction))return false;
        return true;
    }
    static void Resume(CaelumPlayer user)
    {
        let work=Find(user);if(!Active(user) || work==null)return;
        if(work.OriginMap!=level.MapName)return;
        if(work.WorkKind!=BUILD)
        {
            if(work.Structure==null || work.Structure.Broken || !Reach(user,work.Contact))return;
            let barrier=CaelumBarricade(work.Structure);
            CaelumPlayer worker=work.Machine!=null?work.Machine.Worker:barrier.Worker;
            if(worker!=user && Holds(worker,work.Structure))return;
            if(work.Machine!=null)work.Machine.Worker=user;else barrier.Worker=user;
        }
        if(work.Machine!=null)work.DamageSnapshot=work.Machine.DamageSerial;
        else if(work.Structure!=null)work.DamageSnapshot=CaelumBarricade(work.Structure).DamageSerial;
        work.Paused=false;work.Status="";
    }
    static bool CanComplete(CaelumPlayer user)
    {
        let work=Find(user);if(!Attended(user))return false;
        if(work.WorkKind==BUILD)return CaelumMachineOwnership.Admission() && CaelumMachineCrafting.Fits(user,work.Kind,work.Point);
        return work.WorkKind!=CAPTURE || CaelumMachineOwnership.Admission();
    }
    static bool Complete(CaelumPlayer user)
    {
        if(!CanComplete(user) || !user.ValidateCraftingTaskReservations())return false;
        let work=Find(user);
        if(work.WorkKind==BUILD)
        {
            Actor result=Actor.Spawn(work.Kind==CaelumMachineData.BARRICADE?'CaelumBarricade':'CaelumCannon',work.Point,NO_REPLACE);
            if(result==null)return false;
            if(!user.ConsumeCraftingTaskReservations()){result.Destroy();return false;}
            result.Angle=work.Facing;
            let barrier=CaelumBarricade(result);let cannon=CaelumCannon(result);
            if(barrier!=null){barrier.OwnerFaction=work.Faction;barrier.MachineRevision=CaelumMachineData.REVISION;barrier.InitializeGate();}
            else {cannon.InitializeCannon(true);cannon.OwnerFaction=work.Faction;cannon.UnlimitedAmmunition=true;cannon.ActivateCannon(0);}
            let port=CaelumPortSiege.Get();if(port!=null)port.ConstructedDefenses.Push(result);
            user.LastCraftingAction=CaelumConstants.CRAFTING_ACTION_CREATED;
        }
        else if(work.WorkKind==REPAIR)
        {
            if(!user.ConsumeCraftingTaskReservations())return false;
            work.Structure.health=Min(work.Structure.StructuralMaximum,work.Structure.health+work.RepairHealth);
            work.Structure.RefreshPassage();
            if(work.Machine!=null && work.FixSabotage){work.Machine.Sabotaged=false;work.Machine.Armed=true;}
            user.LastCraftingAction=CaelumConstants.CRAFTING_ACTION_REPAIRED;
        }
        else if(work.WorkKind==SABOTAGE)
        {work.Machine.Sabotaged=true;let cannon=CaelumCannon(work.Machine);if(cannon!=null)cannon.CancelShot();user.LastCraftingAction=CaelumConstants.CRAFTING_ACTION_PROCESSED;}
        else
        {
            if(!CaelumMachineOwnership.Capture(work.Machine,user,work.Faction))return false;
            user.LastCraftingAction=CaelumConstants.CRAFTING_ACTION_PROCESSED;
        }
        work.Completed=true;
        let session=CaelumMachineSession.Find(user);if(session!=null)session.Status="CA_MACHINE_DONE";
        CaelumNotifications.Notify(user,StringTable.Localize("CA_MACHINE_DONE",false));return true;
    }
    static void Advance(CaelumPlayer user)
    {
        if(!Attended(user))return;
        user.CraftingTaskRemainingSeconds=Max(0,user.CraftingTaskRemainingSeconds
            -(RealTime(user)?1.0/TICRATE:CaelumThermalRuntime.WorldTicSeconds()));
        if(user.CraftingTaskRemainingSeconds<=0 && CanComplete(user))user.CompleteCraftingTask();
    }
    override void Tick()
    {
        Super.Tick();let user=CaelumPlayer(Owner);
        if(Active(user) && OriginMap==level.MapName && Revision<CaelumMachineData.WORK_REVISION)
        {Revision=CaelumMachineData.WORK_REVISION;Remember(user);}
        if(Active(user) && OriginMap==level.MapName && Structure!=null && Structure.Broken)user.CancelCraftingTask();
    }
    Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE }
}

// El inventario viajero pierde punteros al mapa descargado. El ancla del mapa
// conserva las mismas piezas y devuelve referencias sólo al trabajo/serial dueño.
class CaelumMachineWorkAnchor : Actor
{
    CaelumPlayer Worker;
    int Serial;
    Actor Contact,Station;
    CaelumHostileMachine Machine;
    CaelumBreakableGate Structure;
    override void Tick()
    {
        let work=CaelumMachineWork.Find(Worker);
        if(work==null || !CaelumMachineWork.Active(Worker) || work.Serial!=Serial || work.OriginMap!=level.MapName)
        {Destroy();return;}
        if(work.Anchor==self)return;
        work.Anchor=self;work.Machine=Machine;work.Structure=Structure;work.Contact=Contact;work.Station=Station;
        Worker.ActiveCraftingStationActor=work.WorkKind==CaelumMachineWork.BUILD?Station:Contact;
    }
    Default { Radius 1; Height 1; +NOBLOCKMAP +NOGRAVITY +NOTARGET RenderStyle "None"; }
    States { Spawn: TNT1 A -1; Stop; }
}
