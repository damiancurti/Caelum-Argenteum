// Registro reconstruido una vez al cargar/restaurar el hub. Altas y bajas
// posteriores son eventos de las estructuras; mapas sin carpas no consultan el blockmap.
class CaelumCampWorld : StaticEventHandler
{
    Array<CaelumDeployedTent> Tents;
    static CaelumCampWorld Get(){return CaelumCampWorld(StaticEventHandler.Find('CaelumCampWorld'));}
    void Track(CaelumDeployedTent tent){if(Tents.Find(tent)==Tents.Size())Tents.Push(tent);}
    void Forget(CaelumDeployedTent tent){int i=Tents.Find(tent);if(i<Tents.Size())Tents.Delete(i);}
    void Rebuild()
    {
        Tents.Clear();let it=ThinkerIterator.Create('CaelumDeployedTent');CaelumDeployedTent tent;
        while((tent=CaelumDeployedTent(it.Next()))!=null)if(tent.Ready)Tents.Push(tent);
    }
    override void WorldLoaded(WorldEvent e){Rebuild();}
    override void WorldUnloaded(WorldEvent e){Tents.Clear();}
    override void OnUnregister(){Tents.Clear();}
}
// #411: estructura guardable; la pieza Inventory original se conserva dentro.
class CaelumCampTentPart : CaelumVehiclePart
{
    override bool Used(Actor activator)
    {
        let tent=CaelumDeployedTent(Structure);
        return tent!=null && tent.Used(activator);
    }
}
class CaelumDeployedTent : Actor
{
    int Revision;
    bool Ready,UseLatched;
    CaelumPlayer LastUser;
    CaelumCampTent Item;
    CaelumLawfulIdentity Title;
    Array<CaelumCampTentPart> Parts;
    vector3 LocalOffset(vector3 p)
    {return (p.X*Cos(Angle)-p.Y*Sin(Angle),p.X*Sin(Angle)+p.Y*Cos(Angle),p.Z);}
    bool AddPart(vector3 offset,double radius,double height)
    {
        offset=LocalOffset(offset);
        let part=CaelumCampTentPart(Spawn('CaelumCampTentPart',Pos+offset,NO_REPLACE));
        if(part==null)return false;
        part.Structure=self;part.A_SetSize(radius,height,false);Parts.Push(part);return true;
    }
    bool Prepare()
    {
        if(Ready)return true;
        double r=CaelumPhysicsUnits.MapUnits(CaelumCampData.TENT_WIDTH_M)/2;
        double h=CaelumPhysicsUnits.MapUnits(CaelumCampData.TENT_HEIGHT_M);
        A_SetSize(r,h,false);
        // Celdas locales de techo: el mismo ACTLIKEBRIDGE de los vehiculos.
        // La carpa cuadrada se alinea a los ejes; +X local es la entrada.
        int cells=8;double cell=2*r/cells;
        for(int x=0;x<cells;x++)for(int y=0;y<cells;y++)
        {
            double across=-r+(y+0.5)*cell;
            double z=h*(1-Min(r,Abs(across)+cell/2)/r);
            if(!AddPart((-r+(x+0.5)*cell,across,z),cell/2,h/cells))return false;
        }
        for(int y=0;y<cells*2;y++)
        {
            double across=-r+(y+0.5)*cell/2;
            double tall=h*(1-Abs(across)/r);
            if(!AddPart((-r+cell/4,across,0),cell/4,tall))return false;
        }
        Revision=CaelumCampData.REVISION;Ready=true;
        let world=CaelumCampWorld.Get();if(world!=null)world.Track(self);return true;
    }
    bool Covers(Actor body)
    {
        if(!Ready || body==null)return false;
        double r=CaelumPhysicsUnits.MapUnits(CaelumCampData.TENT_WIDTH_M)/2;
        vector3 worldPoint=body.Pos-Pos;
        vector3 p=(worldPoint.X*Cos(Angle)+worldPoint.Y*Sin(Angle),
            -worldPoint.X*Sin(Angle)+worldPoint.Y*Cos(Angle),worldPoint.Z);
        double top=CaelumPhysicsUnits.MapUnits(CaelumCampData.TENT_HEIGHT_M)*(1-Abs(p.Y)/r);
        return Abs(p.X)<r && Abs(p.Y)<r && p.Z>=-CaelumPlacementGeometry.SUPPORT_TOLERANCE_MU
            && p.Z+body.Height<=top;
    }
    bool Reach(CaelumPlayer user)
    {return user!=null && user.Distance3D(self)<=user.UseRange+Radius && user.CheckSight(self,SF_IGNOREVISIBILITY);}
    override bool Used(Actor activator)
    {
        let user=CaelumPlayer(activator);
        if(!Reach(user))return false;
        if(UseLatched && LastUser==user)return true;
        UseLatched=true;LastUser=user;
        if(CaelumCampTask.WorkingOn(user,self))user.CancelCraftingTask();
        else CaelumCampTask.BeginPack(user,self);
        return true;
    }
    override void Tick()
    {
        Super.Tick();
        if(LastUser==null || LastUser.player==null || (LastUser.player.cmd.buttons&BT_USE)==0)
        {UseLatched=false;LastUser=null;}
    }
    override void OnDestroy()
    {let world=CaelumCampWorld.Get();if(world!=null)world.Forget(self);
        for(int i=0;i<Parts.Size();i++)if(Parts[i]!=null)Parts[i].Destroy();Super.OnDestroy();}
    Default {Radius 1;Height 1;+NOGRAVITY +CANNOTPUSH +DONTTHRUST +NOTARGET Tag "$CA_CAMP_TENT";}
    States {Spawn:CPTN A -1;Stop;}
}
class CaelumCampShelter : Object play
{
    static CaelumDeployedTent Find(Actor body)
    {
        let world=CaelumCampWorld.Get();
        if(body==null || world==null || world.Tents.Size()==0)return null;
        double r=CaelumPhysicsUnits.MapUnits(CaelumCampData.TENT_WIDTH_M)/2;
        let things=BlockThingsIterator.Create(body,r+body.Radius);
        while(things.Next())
        {let tent=CaelumDeployedTent(things.thing);if(tent!=null && tent.Covers(body))return tent;}
        return null;
    }
}
class CaelumCampWorkAnchor : Actor
{
    Default {Radius 1;Height 1;+NOGRAVITY +NOBLOCKMAP RenderStyle "None";}
    States {Spawn:TNT1 A -1;Stop;}
}
class CaelumCampTask : Inventory
{
    int Revision;
    bool Packing;
    String OriginMap;
    vector3 Point;
    double Facing;
    CaelumCampTent Item;
    CaelumDeployedTent Tent;
    Actor Anchor;
    static clearscope CaelumCampTask Find(CaelumPlayer user)
    {return user==null?null:CaelumCampTask(user.FindInventory('CaelumCampTask'));}
    static clearscope bool Active(CaelumPlayer user)
    {return user!=null && user.CraftingTaskActive && user.CraftingTaskKind==CaelumConstants.CRAFTING_TASK_CAMP;}
    static clearscope bool Locked(Inventory item)
    {let user=item!=null?CaelumPlayer(item.Owner):null;let task=Find(user);return Active(user) && task!=null && task.Item==item;}
    static clearscope bool WorkingOn(CaelumPlayer user,Actor tent)
    {let task=Find(user);return Active(user) && task!=null && task.Tent==tent;}
    static void Clear(CaelumPlayer user)
    {
        let task=Find(user);if(task==null)return;
        let advance=CaelumTimeAdvanceState.Get(user);
        if(task.Anchor!=null && advance!=null && advance.Active && advance.Station==task.Anchor)CaelumTimeAdvanceState.Halt(user);
        if(task.Anchor is 'CaelumCampWorkAnchor')task.Anchor.Destroy();
        task.Anchor=null;task.Tent=null;task.Item=null;
    }
    static bool Available(CaelumPlayer user)
    {
        return CaelumPlayerAuthority.CanMutate(user) && user.health>0 && user.player!=null
            && user.player.playerstate==PST_LIVE && !user.isFrozen() && !user.HasActiveConversation() && user.CombatTimeRemaining<=0
            && !user.CraftingTaskActive && !CaelumRecipeSession.Working(user) && !CaelumSleepRules.IsSleeping(user);
    }
    static CaelumCampTask Allocate(CaelumPlayer user)
    {
        user.ClearCraftingTaskData();let task=Find(user);
        if(task==null)task=CaelumCampTask(user.GiveInventoryType('CaelumCampTask'));
        if(task!=null){task.Revision=CaelumCampData.REVISION;task.OriginMap=level.MapName;}
        return task;
    }
    static bool BeginSetup(CaelumPlayer user,CaelumCampTent item)
    {
        if(!Available(user) || item==null || item.Owner!=user || item.Amount!=1 || item.InMagicBox)return false;
        double r=CaelumPhysicsUnits.MapUnits(CaelumCampData.TENT_WIDTH_M)/2;
        double h=CaelumPhysicsUnits.MapUnits(CaelumCampData.TENT_HEIGHT_M);
        // La distancia deriva de los radios nativos; no modifica el alcance Usar.
        double reach=r+user.Radius+CaelumPlacementGeometry.SUPPORT_TOLERANCE_MU;
        vector3 point=user.Pos+(Cos(user.Angle)*reach,Sin(user.Angle)*reach,0);
        if(!CaelumCampLand.Allows(user,point,r) || !CaelumPlacementGeometry.Fits(user,point,r,h))
        {CaelumNotifications.Notify(user,StringTable.Localize("CA_CAMP_SITE_FAILED",false));return false;}
        let task=Allocate(user);if(task==null)return false;
        task.Anchor=Actor.Spawn('CaelumCampWorkAnchor',point,NO_REPLACE);
        if(task.Anchor==null)return false;
        task.Point=point;task.Facing=(int((user.Angle+225)/90)%4)*90;task.Item=item;task.Packing=false;Start(user,task,CaelumCampData.SETUP_SECONDS);return true;
    }
    static bool BeginPack(CaelumPlayer user,CaelumDeployedTent tent)
    {
        if(!Available(user) || tent==null || !tent.Ready || !tent.Reach(user) || tent.Item==null
            || !CaelumLockRules.SameTitle(tent.Title,CaelumLockRules.Character(user)))return false;
        if(!user.CanAddWeightToPersonalInventory(tent.Item.GetUnitWeight()))return false;
        let task=Allocate(user);if(task==null)return false;
        task.Tent=tent;task.Item=tent.Item;task.Anchor=tent;task.Point=tent.Pos;task.Packing=true;
        Start(user,task,CaelumCampData.PACK_SECONDS);return true;
    }
    static void Start(CaelumPlayer user,CaelumCampTask task,double seconds)
    {
        user.ActiveCraftingStationActor=task.Anchor;
        user.StartPreparedCraftingTask(CaelumConstants.CRAFTING_TASK_CAMP,seconds);
        user.CraftingTaskRecipeIndex=-1;user.CraftingTaskNetworkCapabilities=0;
        user.EquipmentMenuOpen=false;user.CraftingMenuOpen=false;
        user.PersistCharacterState();
        CaelumNotifications.Notify(user,StringTable.Localize(task.Packing?"CA_CAMP_PACKING":"CA_CAMP_SETTING_UP",false));
    }
    static bool Attended(CaelumPlayer user)
    {
        let task=Find(user);
        return Active(user) && task!=null && task.Revision==CaelumCampData.REVISION
            && task.OriginMap==level.MapName && task.Anchor!=null && task.Item!=null
            && user.health>0 && user.player!=null && user.player.playerstate==PST_LIVE
            && user.CombatTimeRemaining<=0 && !user.isFrozen() && !user.HasActiveConversation()
            && !user.EquipmentMenuOpen && !user.PalomoMerchantMenuOpen
            && user.Distance3D(task.Anchor)<=CaelumConstants.CRAFTING_ACTIVE_STATION_DISTANCE
            && user.CheckSight(task.Anchor,SF_IGNOREVISIBILITY)
            && (task.Packing?task.Tent!=null && task.Item.Owner==task.Tent:
                task.Item.Owner==user && !task.Item.InMagicBox && task.Item.Amount==1);
    }
    static bool Complete(CaelumPlayer user)
    {
        if(!Attended(user))return false;
        let task=Find(user);let item=task.Item;
        if(task.Packing)
        {
            if(!user.CanAddWeightToPersonalInventory(item.GetUnitWeight())
                || !CaelumLockRules.SameTitle(task.Tent.Title,CaelumLockRules.Character(user)))return false;
            let advance=CaelumTimeAdvanceState.Get(user);
            if(advance!=null && advance.Active && advance.Station==task.Anchor)CaelumTimeAdvanceState.Halt(user);
            let tent=task.Tent;tent.RemoveInventory(item);item.AttachToOwner(user);tent.Item=null;
            task.Anchor=null;task.Tent=null;tent.Destroy();
        }
        else
        {
            double r=CaelumPhysicsUnits.MapUnits(CaelumCampData.TENT_WIDTH_M)/2;
            double h=CaelumPhysicsUnits.MapUnits(CaelumCampData.TENT_HEIGHT_M);
            if(!CaelumCampLand.Allows(user,task.Point,r) || !CaelumPlacementGeometry.Fits(user,task.Point,r,h))return false;
            let tent=CaelumDeployedTent(Actor.Spawn('CaelumDeployedTent',task.Point,NO_REPLACE));
            if(tent==null)return false;
            tent.Angle=task.Facing;
            if(!tent.Prepare()){tent.Destroy();return false;}
            tent.Title=CaelumLockRules.Character(user,true);
            user.RemoveInventory(item);item.AttachToOwner(tent);tent.Item=item;
        }
        user.OnNativeInventoryChanged();user.LastCraftingAction=CaelumConstants.CRAFTING_ACTION_PROCESSED;
        CaelumNotifications.Notify(user,StringTable.Localize(task.Packing?"CA_CAMP_PACKED":"CA_CAMP_READY",false));return true;
    }
    Default {Inventory.Amount 1;Inventory.MaxAmount 1;Inventory.InterHubAmount 1;
        +INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE +INVENTORY.KEEPDEPLETED -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
