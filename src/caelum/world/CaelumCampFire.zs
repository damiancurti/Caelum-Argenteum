// #411: combustible exacto. El sobrante de gramo se conserva con su masa;
// no se redondea hacia arriba para fabricar leña al apagar repetidamente.
class CaelumCampFuelCredit : Inventory
{
    int Revision;
    double Grams;
    static CaelumCampFuelCredit Get(CaelumPlayer user,bool create=false)
    {
        if(!CaelumPlayerAuthority.CanMutate(user))return null;
        let credit=CaelumCampFuelCredit(user.FindInventory('CaelumCampFuelCredit'));
        if(credit==null && create)credit=CaelumCampFuelCredit(user.GiveInventoryType('CaelumCampFuelCredit'));
        if(credit!=null && create)credit.Revision=1;
        return credit;
    }
    static clearscope double Weight(CaelumPlayer user)
    {let c=user==null?null:CaelumCampFuelCredit(user.FindInventory('CaelumCampFuelCredit'));return c==null?0:Max(0.0,c.Grams)*CaelumConstants.MATERIAL_UNIT_WEIGHT;}
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE}
    States {Spawn:TNT1 A -1;Stop;}
}

class CaelumCampFire : CaelumThermalFireSource
{
    int Revision;
    CaelumCampFireState Fuel;
    CaelumCampPot Pot;
    CaelumLawfulIdentity Title;
    CaelumPlayer Busy;
    bool UseLatched;
    CaelumPlayer LastUser;
    transient bool ClockReady;
    double Stamp;
    void Prepare()
    {
        if(Fuel==null)Fuel=new('CaelumCampFireState');Fuel.Ensure();Revision=1;
        double radius=CaelumPhysicsUnits.MapUnits(CaelumCampData.FIRE_DIAMETER_M)/2;
        A_SetSize(radius,CaelumPhysicsUnits.MapUnits(CaelumCampData.FIRE_HEIGHT_M+(Pot!=null?CaelumCampData.PotDepth()+CaelumCampData.POT_WALL_M:0)),false);
        args[1]=int(Ceil(radius));args[2]=int(Ceil(CaelumPhysicsUnits.MapUnits(CaelumCampData.FIRE_HEIGHT_M)));
        let world=CaelumCampWorld.Get();if(world!=null && world.Fires.Find(self)==world.Fires.Size())world.Fires.Push(self);
        let thermal=CaelumThermalWorld.Get();if(thermal!=null)thermal.RegisterFire(self);
    }
    override double Watts(){return Fuel!=null && Fuel.Lit?CaelumCampData.FIRE_WATTS:0;}
    bool Reach(CaelumPlayer user)
    {return user!=null && !bDestroyed && user.Distance3D(self)<=user.UseRange+Radius && user.CheckSight(self,SF_IGNOREVISIBILITY);}
    bool CanManage(CaelumPlayer user)
    {return CaelumPlayerAuthority.CanMutate(user) && Reach(user) && CaelumLockRules.SameTitle(Title,CaelumLockRules.Character(user)) && (Busy==null || Busy==user);}
    void Advance()
    {
        let world=CaelumThermalWorld.Get();if(world==null || world.ReferenceClock==null)return;
        double now=CaelumThermalRuntime.Stamp(world.ReferenceClock);
        double elapsed=ClockReady?Max(0.0,now-Stamp):0;Stamp=now;ClockReady=true;
        if(Fuel==null)return;
        double burning=Fuel.Advance(elapsed);
        AdvancePot(burning,elapsed-burning);RefreshVisual();
    }
    void AdvancePot(double burning,double cooling)
    {
        if(Pot==null || Pot.Owner!=self || Pot.WaterLiters<=0)return;
        let world=CaelumThermalWorld.Get();let weather=world==null?null:world.ReferenceWeather;
        if(weather==null || weather.Outside==null || !weather.Outside.Available)return;
        int shelter=weather.Profile==CaelumWeatherRules.PROFILE_LIMBO?CaelumWeatherRules.LIMBO:
            CaelumThermalShelter.Roof(self)?(weather.Profile>=2 && weather.Profile<=4?CaelumWeatherRules.UNDERGROUND:
                CaelumThermalShelter.WindBlocked(self)?CaelumWeatherRules.INDOOR:CaelumWeatherRules.CANOPY):CaelumWeatherRules.OPEN;
        let environment=world.LocalSample(weather,shelter);
        if(Pot.WaterTemperatureRevision==0)
        {Pot.WaterTemperatureC=environment.AirTemperatureC;Pot.WaterTemperatureRevision=CaelumWaterThermalData.REVISION;}
        if(burning>0)
        {
            double toBoil=CaelumCampPhysics.HeatCapacity(Pot.WaterLiters)*Max(0.0,CaelumWaterThermalData.BOILING_C-Pot.WaterTemperatureC)/CaelumCampData.USEFUL_WATTS;
            double heating=Min(burning,toBoil);
            Pot.WaterTemperatureC=Min(CaelumWaterThermalData.BOILING_C,Pot.WaterTemperatureC+heating*CaelumCampData.USEFUL_WATTS/CaelumCampPhysics.HeatCapacity(Pot.WaterLiters));
            double boiling=Max(0.0,burning-heating);
            if(boiling>0)
            {
                Pot.CampBoilSeconds+=boiling;
                Pot.WaterLiters=Max(0.0,Pot.WaterLiters-boiling*CaelumCampData.USEFUL_WATTS/CaelumWaterThermalData.VAPORIZATION_J_KG);
                if(Pot.CampBoilSeconds>=CaelumWaterThermalData.BOIL_SECONDS)
                    Pot.WaterQuality=Pot.WaterQuality&~CaelumWaterQuality.BIOLOGICAL;
            }
        }
        if(cooling>0)Pot.WaterTemperatureC=Pot.CoolWater(environment.AirTemperatureC,environment.WindSpeedKmh/3.6,cooling);
        if(Pot.WaterTemperatureC<CaelumWaterThermalData.BOILING_C)Pot.CampBoilSeconds=0;
        Pot.TemperatureStamp=Stamp;Pot.TemperatureClockReady=true;Pot.CoolingSeconds=0;
    }
    bool MountPot(CaelumPlayer user,CaelumCampPot item)
    {
        if(!CanManage(user) || Busy!=null || Pot!=null || item==null || item.Owner!=user || item.InMagicBox
            || item.Amount!=1 || CaelumWaterBoiling.Locked(item))return false;
        if(!CaelumPlacementGeometry.Fits(user,Pos,Radius,CaelumPhysicsUnits.MapUnits(CaelumCampData.FIRE_HEIGHT_M+CaelumCampData.PotDepth()+CaelumCampData.POT_WALL_M),self))return false;
        Advance();item.AdvanceTemperature(user,0);user.RemoveInventory(item);item.AttachToOwner(self);Pot=item;
        Pot.CampBoilSeconds=0;Pot.TemperatureStamp=Stamp;Pot.TemperatureClockReady=true;
        Prepare();RefreshVisual();user.OnNativeInventoryChanged();return true;
    }
    bool TakePot(CaelumPlayer user)
    {
        if(!CanManage(user) || Busy!=null || Pot==null)return false;
        Advance();if(!user.CanAddWeightToPersonalInventory(Pot.GetUnitWeight()))return false;
        let item=Pot;RemoveInventory(item);item.AttachToOwner(user);Pot=null;item.StampTemperature(user);
        Prepare();RefreshVisual();user.OnNativeInventoryChanged();return true;
    }
    void RefreshVisual()
    {
        State destination=Fuel!=null && Fuel.Lit?(Pot!=null?FindState('BurningPot'):FindState('Burning')):
            (Pot!=null?FindState('ColdPot'):SpawnState);
        if(!InStateSequence(CurState,destination))SetState(destination);
    }
    bool LoadWood(CaelumPlayer user,int requested)
    {
        if(!CanManage(user) || Busy!=null || requested<=0)return false;
        Advance();double room=Max(0.0,CaelumCampData.FIRE_CAPACITY_G-Fuel.FuelGrams);
        let credit=CaelumCampFuelCredit.Get(user);double fraction=credit==null?0:Min(room,credit.Grams);
        int whole=Min(requested,Min(int(Floor(room-fraction)),user.CountCraftingMaterial(CaelumConstants.MATERIAL_WOOD,1)));
        if(whole<=0 && fraction<=0)return false;
        if(whole>0 && !user.ConsumeCraftingMaterial(CaelumConstants.MATERIAL_WOOD,1,whole))return false;
        if(credit!=null)credit.Grams-=fraction;Fuel.FuelGrams+=whole+fraction;user.OnNativeInventoryChanged();return true;
    }
    bool RecoverWood(CaelumPlayer user)
    {
        if(!CanManage(user) || Fuel.Lit)return false;
        double amount=Fuel.FuelGrams;if(amount<=0)return true;
        let credit=CaelumCampFuelCredit.Get(user);
        double prior=credit==null?0:credit.Grams;
        int whole=int(Floor(amount+prior));
        let wood=CaelumMaterialPickup(user.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,CaelumConstants.MATERIAL_WOOD,1));
        bool boxed=wood!=null && wood.InMagicBox;
        if(boxed?!user.CanAddRawWeightToMagicBox(whole*CaelumConstants.MATERIAL_UNIT_WEIGHT)
            :!user.CanAddWeightToPersonalInventory(amount*CaelumConstants.MATERIAL_UNIT_WEIGHT))return false;
        credit=CaelumCampFuelCredit.Get(user,true);if(credit==null)return false;
        // El catálogo guarda una pila por material: no crear una segunda que
        // los consumidores de recetas no puedan encontrar.
        if(whole>0 && wood==null)
        {wood=CaelumMaterialPickup(Actor.Spawn('CaelumMaterialPickup',user.Pos,NO_REPLACE));if(wood==null)return false;wood.Amount=0;}
        credit.Grams=amount+credit.Grams-whole;Fuel.FuelGrams=0;
        if(wood!=null){wood.args[0]=CaelumConstants.MATERIAL_WOOD;wood.args[1]=1;wood.Amount+=whole;if(wood.Owner==null){wood.InMagicBox=false;wood.AttachToOwner(user);}wood.UpdateMaterialVisuals();}
        user.OnNativeInventoryChanged();return true;
    }
    void Extinguish(){Advance();if(Fuel!=null)Fuel.LeaveMap();RefreshVisual();}
    override bool Used(Actor activator)
    {
        let user=CaelumPlayer(activator);if(!CanManage(user))return false;
        if(UseLatched && LastUser==user)return true;UseLatched=true;LastUser=user;
        let task=CaelumCampTask.Find(user);
        if(CaelumCampTask.Active(user) && task!=null && task.Fire==self)user.CancelCraftingTask();
        else CaelumCampFireSession.Show(user,self);
        return true;
    }
    override void Tick()
    {
        Super.Tick();if(Revision==0)Prepare();
        if(level.maptime%TICRATE==0)Advance();
        if(LastUser==null || LastUser.player==null || (LastUser.player.cmd.buttons&BT_USE)==0){UseLatched=false;LastUser=null;}
    }
    override void OnDestroy()
    {
        let world=CaelumCampWorld.Get();if(world!=null){int i=world.Fires.Find(self);if(i<world.Fires.Size())world.Fires.Delete(i);}
        Super.OnDestroy();
    }
    Default { -NOBLOCKMAP -NOCLIP -INVISIBLE +CANNOTPUSH +DONTTHRUST +NOTARGET Tag "$CA_CAMP_FIRE"; }
    States {Spawn:CPTN A -1;Stop;Burning:CPTN BCDE 4;Loop;ColdPot:CPTN F -1;Stop;BurningPot:CPTN GHIJ 4;Loop;}
}

class CaelumCampFireWork : Object play
{
    enum EFireAction {CREATE_FIRE=1,LIGHT_FIRE,REMOVE_FIRE};
    static bool Fits(CaelumPlayer user,vector3 point)
    {
        double radius=CaelumPhysicsUnits.MapUnits(CaelumCampData.FIRE_DIAMETER_M)/2;
        return CaelumCampLand.Allows(user,point,radius)
            && CaelumPlacementGeometry.Fits(user,point,radius,CaelumPhysicsUnits.MapUnits(CaelumCampData.FIRE_HEIGHT_M));
    }
    static bool Begin(CaelumPlayer user,CaelumCampFire fire,int workKind,int grams=0)
    {
        if(!CaelumCampTask.Available(user) || workKind<CREATE_FIRE || workKind>REMOVE_FIRE)return false;
        vector3 point=user.Pos;
        if(workKind==CREATE_FIRE)
        {
            double offset=user.Radius+CaelumPhysicsUnits.MapUnits(CaelumCampData.FIRE_DIAMETER_M)/2+CaelumPlacementGeometry.SUPPORT_TOLERANCE_MU;
            point+= (Cos(user.Angle)*offset,Sin(user.Angle)*offset,0);
            if(grams<=0 || grams>CaelumCampData.FIRE_CAPACITY_G || user.CountCraftingMaterial(CaelumConstants.MATERIAL_WOOD,1)<grams || !Fits(user,point))return false;
        }
        else if(fire==null || !fire.CanManage(user) || fire.Busy!=null || fire.Fuel.Lit
            || (workKind==LIGHT_FIRE && fire.Fuel.FuelGrams<=0) || (workKind==REMOVE_FIRE && fire.Pot!=null))return false;
        let task=CaelumCampTask.Allocate(user);if(task==null)return false;
        task.FireAction=workKind;task.Fire=fire;task.Point=point;task.Item=null;
        if(workKind==CREATE_FIRE)
        {
            task.Anchor=Actor.Spawn('CaelumCampWorkAnchor',point,NO_REPLACE);if(task.Anchor==null)return false;
            if(!user.AddCraftingTaskReservation(CaelumConstants.MATERIAL_WOOD,1,grams)){CaelumCampTask.Clear(user);return false;}
            task.FireGrams=grams;
        }
        else {task.Anchor=fire;fire.Busy=user;}
        CaelumCampTask.Start(user,task,workKind==REMOVE_FIRE?CaelumCampData.DISMANTLE_SECONDS:CaelumCampData.IGNITE_SECONDS);return true;
    }
    static bool Attended(CaelumPlayer user,CaelumCampTask task)
    {
        if(task.Revision!=CaelumCampData.REVISION || task.OriginMap!=level.MapName || task.Anchor==null
            || user.health<=0 || user.player==null || user.player.playerstate!=PST_LIVE || user.isFrozen()
            || user.CombatTimeRemaining>0 || user.HasActiveConversation() || user.EquipmentMenuOpen
            || user.PalomoMerchantMenuOpen || user.Distance3D(task.Anchor)>CaelumConstants.CRAFTING_ACTIVE_STATION_DISTANCE
            || !user.CheckSight(task.Anchor,SF_IGNOREVISIBILITY))return false;
        if(task.FireAction==CREATE_FIRE)return user.ValidateCraftingTaskReservations();
        return task.Fire!=null && task.Fire.CanManage(user) && task.Fire.Busy==user && !task.Fire.Fuel.Lit
            && (task.FireAction!=REMOVE_FIRE || task.Fire.Pot==null);
    }
    static bool Complete(CaelumPlayer user,CaelumCampTask task)
    {
        if(!Attended(user,task))return false;
        if(task.FireAction==CREATE_FIRE)
        {
            if(!Fits(user,task.Point))return false;
            let fire=CaelumCampFire(Actor.Spawn('CaelumCampFire',task.Point,NO_REPLACE));if(fire==null)return false;
            fire.Prepare();
            if(!user.ConsumeCraftingTaskReservations()){fire.Destroy();return false;}
            fire.Title=CaelumLockRules.Character(user,true);fire.Fuel.FuelGrams=task.FireGrams;fire.Advance();fire.Fuel.Lit=true;fire.RefreshVisual();
        }
        else if(task.FireAction==LIGHT_FIRE){task.Fire.Advance();task.Fire.Fuel.Lit=true;task.Fire.RefreshVisual();}
        else {if(!task.Fire.RecoverWood(user))return false;task.Fire.Busy=null;task.Fire.Destroy();task.Anchor=null;task.Fire=null;}
        user.OnNativeInventoryChanged();user.LastCraftingAction=CaelumConstants.CRAFTING_ACTION_PROCESSED;return true;
    }
}
