// #472: el recipiente, su carga y su temperatura conservan una única identidad.
class CaelumMatePhysics : Object
{
    static clearscope double Cool(int variant,double temperature,double ambient,double wind,double seconds,double liters)
    {
        if(seconds<=0)return temperature;
        double r=CaelumMateData.Radius(variant),pi=CaelumWaterThermalData.PI;
        double film=CaelumThermalRules.AirConvection(wind)+CaelumThermalData.REFERENCE_RADIATION;
        double resistance=CaelumMateData.Wall(variant)/CaelumMateData.Conductivity(variant)
            +CaelumMateData.CoatingWall(variant)/CaelumMateData.CoatingConductivity(variant)+1/film;
        double conductance=2*pi*r*r/resistance+pi*r*r*film;
        double capacity=Max(0,liters)*CaelumWaterThermalData.WATER_CP+CaelumMateData.BodyHeatCapacity(variant);
        return ambient+(temperature-ambient)*Exp(-conductance*seconds/capacity);
    }
    static clearscope double Mix(int variant,double liters,double temperature,double added,double source)
    {
        double held=Max(0,liters)*CaelumWaterThermalData.WATER_CP+CaelumMateData.BodyHeatCapacity(variant);
        double incoming=Max(0,added)*CaelumWaterThermalData.WATER_CP;
        return (held*temperature+incoming*source)/(held+incoming);
    }
}

class CaelumMateItem : CaelumConsumableItem
{
    int MateRevision,UsesRemaining;
    bool YerbaLoaded,TemperatureReady;
    double WaterLiters,TemperatureC,TemperatureStamp;
    virtual clearscope int Variant(){return 0;}
    override int GetConsumableType(){return CaelumMateData.FIRST_CONSUMABLE+Variant();}
    override double GetUnitWeight()
    {return CaelumMateData.EmptyMass(Variant())+Max(0,WaterLiters)
        +(YerbaLoaded?CaelumMateData.YerbaGrams(Variant())*CaelumConstants.MATERIAL_UNIT_WEIGHT:0);}
    void SyncTemperature(CaelumPlayer user)
    {
        let clock=CaelumWorldClock.Get(user);let world=CaelumThermalWorld.Get();
        if(clock==null && world!=null)clock=world.ReferenceClock;
        if(clock==null)return;
        let thermal=CaelumThermalBody.Get(user);
        double ambient,wind;
        if(thermal!=null && thermal.Available){ambient=thermal.AmbientAirC;wind=thermal.AmbientWindKmh/3.6;}
        else if(world!=null && world.ReferenceWeather!=null && world.ReferenceWeather.Outside!=null && world.ReferenceWeather.Outside.Available)
        {ambient=world.ReferenceWeather.Outside.AirTemperatureC;wind=world.ReferenceWeather.Outside.WindSpeedKmh/3.6;}
        else return;
        double now=CaelumThermalRuntime.Stamp(clock);
        if(TemperatureReady)TemperatureC=CaelumMatePhysics.Cool(Variant(),TemperatureC,ambient,wind,Max(0,now-TemperatureStamp),WaterLiters);
        else {TemperatureC=ambient;TemperatureReady=true;}
        TemperatureStamp=now;MateRevision=CaelumMateData.REVISION;
    }
    bool Accessible(CaelumPlayer user)
    {return CaelumPlayerAuthority.CanMutate(user) && Owner==user && Amount==1 && !InMagicBox
        && user.health>0 && !user.isFrozen();}
    bool LoadYerba(CaelumPlayer user)
    {
        if(!Accessible(user) || YerbaLoaded || WaterLiters>0)return false;
        int grams=CaelumMateData.YerbaGrams(Variant());
        let source=user.FindNativeSpecialItem(CaelumConstants.EQUIPMENT_KIND_MATERIAL,CaelumConstants.MATERIAL_YERBA_MATE,1);
        if(source==null || source.Amount-user.GetReservedCraftingMaterialUnits(CaelumConstants.MATERIAL_YERBA_MATE,1)<grams)return false;
        if(source.InMagicBox && !user.CanApplyInventoryWeightTransition(grams*CaelumConstants.MATERIAL_UNIT_WEIGHT,-grams*CaelumConstants.MATERIAL_UNIT_WEIGHT))return false;
        SyncTemperature(user);source.Amount-=grams;YerbaLoaded=true;UsesRemaining=CaelumMateData.HOT_USES;
        user.OnNativeInventoryChanged();user.PersistCharacterState();return true;
    }
    bool DiscardYerba(CaelumPlayer user)
    {
        if(!Accessible(user) || !YerbaLoaded)return false;
        SyncTemperature(user);YerbaLoaded=false;UsesRemaining=0;
        user.OnNativeInventoryChanged();user.PersistCharacterState();return true;
    }
    bool Pour(CaelumPlayer user,CaelumWaterContainer source)
    {
        if(!Accessible(user) || !YerbaLoaded || source==null || source.Owner!=user || source.Amount!=1
            || source.InMagicBox || !source.IsPotable() || CaelumWaterBoiling.Locked(source))return false;
        double take=Min(source.WaterLiters,CaelumMateData.WaterCapacity(Variant())-WaterLiters);
        if(take<=0.0000001)return false;
        source.AdvanceTemperature(user,0);SyncTemperature(user);
        if(!TemperatureReady || source.WaterTemperatureRevision<=0)return false;
        TemperatureC=CaelumMatePhysics.Mix(Variant(),WaterLiters,TemperatureC,take,source.WaterTemperatureC);
        WaterLiters+=take;source.WaterLiters=Max(0,source.WaterLiters-take);
        user.OnNativeInventoryChanged();user.PersistCharacterState();return true;
    }
    bool EmptyWater(CaelumPlayer user)
    {
        if(!Accessible(user) || WaterLiters<=0)return false;
        SyncTemperature(user);WaterLiters=0;user.OnNativeInventoryChanged();user.PersistCharacterState();return true;
    }
    override bool HandlePickup(Inventory item)
    {if(item.GetClass()==GetClass())return true;return Super.HandlePickup(item);}
    override bool TryPickup(in out Actor toucher)
    {if(toucher.FindInventory(GetClassName())!=null)return false;return Super.TryPickup(toucher);}
    void CopyContents(CaelumMateItem copy)
    {
        if(copy==null || copy==self)return;
        copy.MateRevision=MateRevision;copy.UsesRemaining=UsesRemaining;copy.YerbaLoaded=YerbaLoaded;
        copy.TemperatureReady=TemperatureReady;copy.WaterLiters=WaterLiters;copy.TemperatureC=TemperatureC;
        copy.TemperatureStamp=TemperatureStamp;copy.InMagicBox=InMagicBox;
    }
    override Inventory CreateCopy(Actor other)
    {SyncTemperature(CaelumPlayer(Owner));let copy=CaelumMateItem(Super.CreateCopy(other));CopyContents(copy);return copy;}
    override Inventory CreateTossable(int amount)
    {SyncTemperature(CaelumPlayer(Owner));let copy=CaelumMateItem(Super.CreateTossable(amount));CopyContents(copy);return copy;}
    clearscope bool CanDrink(CaelumPlayer user)
    {
        return user!=null && Owner==user && Amount==1 && !InMagicBox && YerbaLoaded
            && WaterLiters>0.0000001 && TemperatureReady && TemperatureC<=CaelumMateData.HOT_MAX_C
            && user.DerivedStats!=null && (user.CurrentThirst<CaelumConstants.SURVIVAL_MAXIMUM
                || (UsesRemaining>0 && TemperatureC>=CaelumMateData.HOT_MIN_C));
    }
    bool Drink(CaelumPlayer user)
    {
        if(!Accessible(user))return false;
        SyncTemperature(user);if(!CanDrink(user))return false;
        let recovery=CaelumMateRecovery(user.FindInventory('CaelumMateRecovery'));
        if(recovery==null)recovery=CaelumMateRecovery(user.GiveInventoryType('CaelumMateRecovery'));
        if(recovery==null)return false;
        double hydration=WaterLiters*CaelumConstants.WATER_RECOVERY_PER_LITER_PER_PULSE
            /Max(1,user.DerivedStats.BaseMass)*CaelumConstants.CONSUMABLE_REGENERATION_SECONDS;
        bool hot=UsesRemaining>0 && TemperatureC>=CaelumMateData.HOT_MIN_C;
        recovery.AddDose(hydration,hot?hydration/CaelumConstants.SURVIVAL_MAXIMUM*CaelumMateData.RESOURCE_RATIO:0);
        if(hot)UsesRemaining--;
        WaterLiters=0;user.OnNativeInventoryChanged();user.PersistCharacterState();return true;
    }
    override bool Use(bool pickup){return false;}
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;}
}

// Diez pulsos por cebado, en un anillo acotado: otra dosis no borra ni retrasa la anterior.
class CaelumMateRecovery : Powerup
{
    const QUEUE_SIZE=CaelumConstants.CONSUMABLE_REGENERATION_SECONDS*TICRATE+1;
    double PendingHydration[QUEUE_SIZE];
    double PendingResources[QUEUE_SIZE];
    double HealingFraction;
    int Cursor;
    void AddDose(double hydration,double ratio)
    {
        for(int pulse=1;pulse<=CaelumConstants.CONSUMABLE_REGENERATION_SECONDS;pulse++)
        {
            int slot=(Cursor+pulse*TICRATE)%QUEUE_SIZE;
            PendingHydration[slot]+=hydration/CaelumConstants.CONSUMABLE_REGENERATION_SECONDS;
            PendingResources[slot]+=ratio/CaelumConstants.CONSUMABLE_REGENERATION_SECONDS;
        }
        EffectTics=QUEUE_SIZE;
    }
    override void DoEffect()
    {
        Super.DoEffect();Cursor=(Cursor+1)%QUEUE_SIZE;
        double hydration=PendingHydration[Cursor],ratio=PendingResources[Cursor];PendingHydration[Cursor]=0;PendingResources[Cursor]=0;
        let user=CaelumPlayer(Owner);
        if(user==null || !CaelumPlayerAuthority.CanMutate(user) || user.health<=0 || user.DerivedStats==null)return;
        if(hydration<=0 && ratio<=0)return;
        double thirstBefore=user.CurrentThirst;
        user.CurrentThirst=Min(CaelumConstants.SURVIVAL_MAXIMUM,user.CurrentThirst+hydration);
        CaelumFoodIllness.Satiate(user,user.CurrentThirst-thirstBefore);
        if(ratio>0)
        {
            HealingFraction+=user.CaelumMaximumHealth*ratio;
            int healing=int(HealingFraction+0.00000001);HealingFraction=Max(0,HealingFraction-healing);
            CaelumTarotLovers.Heal(user,healing);user.player.health=user.health;
            if(user.health>=user.CaelumMaximumHealth)HealingFraction=0;
            if(user.CaelumMaximumHealth>0)CaelumContaminationStorage.Treatment(user,ratio);
            user.CurrentAnima=Min(user.DerivedStats.MaximumAnima,user.CurrentAnima+user.DerivedStats.MaximumAnima*ratio);
            user.CurrentAir=Min(user.DerivedStats.MaximumAir,user.CurrentAir+user.DerivedStats.MaximumAir*ratio);
            user.UpdateHealthStateEffects();user.UpdateAirStateEffects();
        }
        user.UpdateSurvivalStates();
    }
    Default {Powerup.Duration -10;+INVENTORY.HUBPOWER +INVENTORY.PERSISTENTPOWER}
}
class CaelumMateGourd : CaelumMateItem
{
    override int Variant(){return 0;}
    Default {Tag "$CA_MATE_GOURD";Inventory.Icon "graphics/caelum/icons/mate/gourd.png";}
    States {Spawn: CMA0 A -1;Stop;}
}
class CaelumMateSilver : CaelumMateItem
{
    override int Variant(){return 1;}
    Default {Tag "$CA_MATE_SILVER";Inventory.Icon "graphics/caelum/icons/mate/silver.png";}
    States {Spawn: CMA1 A -1;Stop;}
}
class CaelumMateGold : CaelumMateItem
{
    override int Variant(){return 2;}
    Default {Tag "$CA_MATE_GOLD";Inventory.Icon "graphics/caelum/icons/mate/gold.png";}
    States {Spawn: CMA2 A -1;Stop;}
}
