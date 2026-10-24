// Consumibles apilables sobre el inventario nativo. PowerupGiver se ocupa de
// consumir una unidad y de crear o refrescar el efecto temporal asociado.
class CaelumConsumableItem : PowerupGiver
{
    bool InMagicBox;

    override bool HandlePickup(Inventory item)
    {
        bool result=Super.HandlePickup(item);
        CaelumActorMaintenance.InventoryChanged(Owner);
        return result;
    }
    override Inventory CreateTossable(int amount)
    {
        let previousOwner=Owner;
        let result=Super.CreateTossable(amount);
        CaelumActorMaintenance.InventoryChanged(previousOwner);
        return result;
    }


    Default
    {
        Radius 12;
        Height 8;
        // Sólo reduce el sprite del actor en el suelo; el icono de inventario conserva su tamaño.
        Scale 0.25;
        Inventory.Amount 1;
        Inventory.MaxAmount 2147483647;
        Inventory.InterHubAmount 2147483647;
        Inventory.PickupSound "caelum/items/pickup";
        +INVENTORY.INVBAR
    }

    override String PickupMessage() { return ""; }

    virtual int GetConsumableType() { return -1; }

    Name GetPowerClassName()
    {
        switch (CaelumPotionRules.Family(GetConsumableType()))
        {
            case CaelumConstants.CONSUMABLE_ANIMA_POTION:
                return 'CaelumAnimaRegeneration';
            case CaelumConstants.CONSUMABLE_ENERGY_DRINK:
                return 'CaelumEnergyRegeneration';
            case CaelumConstants.CONSUMABLE_FOOD_RATION:
                return 'CaelumHungerRegeneration';
            case CaelumConstants.CONSUMABLE_WATER_RATION:
                return 'CaelumThirstRegeneration';
            default:
                return 'CaelumLifeRegeneration';
        }
    }

    static clearscope double UnitWeightForType(int consumableType)
    {
        if(consumableType==CaelumCampData.POT_CONSUMABLE)return CaelumCampData.POT_KG;
        if(CaelumMateData.IsConsumable(consumableType))return CaelumMateData.EmptyMass(consumableType-CaelumMateData.FIRST_CONSUMABLE);
        if (consumableType == CaelumConstants.CONSUMABLE_WATER_RATION)
            return CaelumConstants.WATER_RATION_LITERS;
        if (consumableType == CaelumConstants.CONSUMABLE_FOOD_RATION)
        {
            return CaelumConstants.CONSUMABLE_RATION_WEIGHT;
        }
        return CaelumConstants.CONSUMABLE_POTION_WEIGHT;
    }

    virtual double GetUnitWeight() { return UnitWeightForType(GetConsumableType()); }

    double GetCarriedWeight()
    {
        // La contribución compartida del contenido de la Caja Mágica se suma
        // en CaelumPlayer; aquí sólo se informa la carga personal directa.
        return InMagicBox ? 0.0 : Amount * GetUnitWeight();
    }

    override bool Use(bool pickup)
    {
        // El contenido de la Caja Magica no puede usarse hasta recuperarlo.
        if (InMagicBox) { return false; }
        // Permitir el refresco nativo también antes del parpadeo del efecto.
        // Se limita al uso, sin alterar la recogida ni los objetos de guardados.
        bool previousAlwaysPickup = bAlwaysPickup;
        bAlwaysPickup = true;
        bool used = Super.Use(pickup);
        bAlwaysPickup = previousAlwaysPickup;
        if (used && Owner != null)
        {
            CaelumRegenerationPower power = CaelumRegenerationPower(
                Owner.FindInventory(GetPowerClassName())
            );
            if (power != null)
            {
                // Super crea o reutiliza el Powerup; Caelum fija la semantica
                // de refresco para impedir duraciones o intensidades aditivas.
                power.EffectTics =
                    CaelumConstants.CONSUMABLE_REGENERATION_SECONDS * TICRATE;
                power.PulseTics = 0;
                power.SeatedMealSubTics = 0;
                if(CaelumPotionRules.IsPotion(GetConsumableType()))
                {
                    power.PotionTotalRatio=CaelumPotionRules.TotalRatio(CaelumPotionRules.Size(GetConsumableType()));
                    power.PotionHealingFraction=0;
                    power.PotionPulsesGiven=0;
                }
                if (GetConsumableType() == CaelumConstants.CONSUMABLE_FOOD_RATION)
                {
                    let user = CaelumPlayer(Owner);
                    if (user != null && user.DerivedStats != null)
                        power.FoodRecoveryPerPulse = CaelumConstants.SURVIVAL_MAXIMUM
                            * CaelumConstants.CONSUMABLE_REGENERATION_PERCENT_PER_SECOND
                            * CaelumConstants.RATION_REFERENCE_MASS / Max(1, user.DerivedStats.BaseMass);
                }
                if (GetConsumableType() == CaelumConstants.CONSUMABLE_WATER_RATION)
                {
                    let user = CaelumPlayer(Owner);
                    if (user != null && user.DerivedStats != null)
                        power.WaterRecoveryPerPulse = CaelumConstants.WATER_RATION_LITERS
                            * CaelumConstants.WATER_RECOVERY_PER_LITER_PER_PULSE / Max(1, user.DerivedStats.BaseMass);
                }
            }
        }
        // Sólo un uso nativo aceptado acredita la práctica; recoger, mirar o
        // intentar consumir desde la Caja no llega a este observador.
        if (used) CaelumMainM00RonnieTrial.RecordNeedsUse(CaelumPlayer(Owner), GetConsumableType());
        CaelumActorMaintenance.InventoryChanged(Owner);
        return used;
    }

    override bool TryPickup(in out Actor toucher)
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(toucher);
        if (caelumPlayer == null
            || !caelumPlayer.PrepareNativeConsumablePickup(self))
        {
            return false;
        }
        int before = CaelumNotifications.OwnedQuantity(caelumPlayer, self);
        String received = CaelumNotifications.Describe(caelumPlayer, self, 0);
        bool pickedUp = Super.TryPickup(toucher);
        if (pickedUp)
        {
            int gained = CaelumNotifications.OwnedQuantity(caelumPlayer, self) - before;
            CaelumNotifications.AcquiredDescription(caelumPlayer, received, gained);
            caelumPlayer.OnNativeInventoryChanged();
        }
        return pickedUp;
    }

    override Inventory CreateCopy(Actor other)
    {
        CaelumConsumableItem copy = CaelumConsumableItem(Super.CreateCopy(other));
        if (copy != null && copy != self) { copy.InMagicBox = InMagicBox; }
        return copy;
    }
}

// Un pulso se aplica cada TICRATE, no como una fraccion truncada cada tic.
// Diez pulsos por porción; comida y agua fijan su dosis al comenzar a usarlas.
class CaelumRegenerationPower : Powerup
{
    const SEATED_MEAL_TIC_DIVISOR = 3;
    int PulseTics;
    int SeatedMealSubTics;
    double WaterRecoveryPerPulse;
    // Cero en guardados anteriores: conserva sus pulsos históricos de 1 punto.
    double FoodRecoveryPerPulse;
    // Cero preserva los efectos históricos cargados; las dosis nuevas fijan
    // su recuperación total y conservan la fracción de Salud entre pulsos.
    double PotionTotalRatio;
    double PotionHealingFraction;
    int PotionPulsesGiven;

    Default
    {
        Powerup.Duration -10;
        +INVENTORY.HUBPOWER
    }

    virtual int GetRegenerationType() { return -1; }

    override void DoEffect()
    {
        Super.DoEffect();
        let user = CaelumPlayer(Owner);
        int kind = GetRegenerationType();
        if ((kind == CaelumConstants.CONSUMABLE_FOOD_RATION
                || kind == CaelumConstants.CONSUMABLE_WATER_RATION)
            && CaelumRestState.IsSeated(user))
        {
            // La misma porción conserva sus diez pulsos, espaciados tres veces
            // más. Compensar el vencimiento nativo conserva su aporte total.
            // La fracción se guarda y continúa si vuelve a sentarse.
            SeatedMealSubTics++;
            if (SeatedMealSubTics < SEATED_MEAL_TIC_DIVISOR) { EffectTics++; return; }
            SeatedMealSubTics = 0;
        }
        PulseTics++;
        if (PulseTics < TICRATE) { return; }
        PulseTics -= TICRATE;
        if(PotionTotalRatio>0 && CaelumPotionRules.IsPotion(kind))
        {
            ApplyPotionPulse(kind,PotionTotalRatio/CaelumConstants.CONSUMABLE_REGENERATION_SECONDS);
            PotionPulsesGiven++;
            return;
        }
        CaelumPlayer caelumPlayer = CaelumPlayer(Owner);
        if (caelumPlayer != null)
        {
            if (GetRegenerationType() == CaelumConstants.CONSUMABLE_WATER_RATION)
            {
                double recovery = WaterRecoveryPerPulse > 0 ? WaterRecoveryPerPulse : 1.0;
                caelumPlayer.CurrentThirst = Min(100.0, caelumPlayer.CurrentThirst + recovery);
                if(caelumPlayer.CurrentThirst>=100)CaelumDiningSession.Sated(caelumPlayer,true);
                caelumPlayer.UpdateSurvivalStates();
                return;
            }
            caelumPlayer.ApplyConsumableRegenerationPulse(GetRegenerationType(),
                FoodRecoveryPerPulse > 0 ? FoodRecoveryPerPulse : 1.0);
        }
    }

    override void EndEffect()
    {
        // Powerup caduca antes del último DoEffect del dueño. Completar ese
        // pulso al vencer evita perder un décimo, sin adelantar la dosis ni
        // regalar pulsos al morir, cancelar o refrescar una poción.
        if(EffectTics==0 && PotionTotalRatio>0
            && PotionPulsesGiven==CaelumConstants.CONSUMABLE_REGENERATION_SECONDS-1)
        {
            ApplyPotionPulse(GetRegenerationType(),PotionTotalRatio/CaelumConstants.CONSUMABLE_REGENERATION_SECONDS);
            PotionPulsesGiven++;
        }
        Super.EndEffect();
    }

    void ApplyPotionPulse(int family,double ratio)
    {
        if(Owner==null || Owner.health<=0)return;
        let user=CaelumPlayer(Owner);
        let npc=CaelumCombatActor(Owner);
        if(user==null && npc==null)return;
        if(user!=null && (user.DerivedStats==null || !CaelumPlayerAuthority.CanMutate(user)))return;
        if(family==CaelumConstants.CONSUMABLE_LIFE_POTION)
        {
            int maximum=user!=null ? user.CaelumMaximumHealth : npc.CombatMaximumHealth;
            PotionHealingFraction+=maximum*ratio;
            int healing=int(PotionHealingFraction);
            PotionHealingFraction-=healing;
            Owner.health=Min(maximum,Owner.health+healing);
            if(user!=null){user.player.health=user.health;user.UpdateHealthStateEffects();}
            else npc.UpdateCombatHealthEffects();
        }
        else if(family==CaelumConstants.CONSUMABLE_ANIMA_POTION)
        {
            if(user!=null)user.CurrentAnima=Min(user.DerivedStats.MaximumAnima,
                user.CurrentAnima+user.DerivedStats.MaximumAnima*ratio);
            else npc.CurrentCombatAnima=Min(npc.MaximumCombatAnima,
                npc.CurrentCombatAnima+npc.MaximumCombatAnima*ratio);
        }
        else if(family==CaelumConstants.CONSUMABLE_ENERGY_DRINK)
        {
            if(user!=null)
            {
                user.CurrentAir=Min(user.DerivedStats.MaximumAir,user.CurrentAir+user.DerivedStats.MaximumAir*ratio);
                user.CurrentSleep=Min(CaelumConstants.SURVIVAL_MAXIMUM,
                    user.CurrentSleep+CaelumConstants.SURVIVAL_MAXIMUM*ratio);
                user.UpdateAirStateEffects();user.UpdateSurvivalStates();
            }
            else npc.CurrentCombatAir=Min(npc.MaximumCombatAir,npc.CurrentCombatAir+npc.MaximumCombatAir*ratio);
        }
    }
}

class CaelumLifeRegeneration : CaelumRegenerationPower
{
    override int GetRegenerationType()
    {
        return CaelumConstants.CONSUMABLE_LIFE_POTION;
    }
}

class CaelumAnimaRegeneration : CaelumRegenerationPower
{
    override int GetRegenerationType()
    {
        return CaelumConstants.CONSUMABLE_ANIMA_POTION;
    }
}

class CaelumEnergyRegeneration : CaelumRegenerationPower
{
    override int GetRegenerationType()
    {
        return CaelumConstants.CONSUMABLE_ENERGY_DRINK;
    }
}

class CaelumHungerRegeneration : CaelumRegenerationPower
{
    override int GetRegenerationType()
    {
        return CaelumConstants.CONSUMABLE_FOOD_RATION;
    }
}

class CaelumThirstRegeneration : CaelumRegenerationPower
{
    override int GetRegenerationType()
    {
        return CaelumConstants.CONSUMABLE_WATER_RATION;
    }
}

class CaelumLifePotion : CaelumConsumableItem
{
    Default
    {
        Tag "$CA_CONSUMABLE_LIFE_POTION";
        Inventory.Icon "graphics/caelum/icons/ca_medikit.png";
        Inventory.PickupMessage "$CA_PICKUP_LIFE_POTION";
        Powerup.Type "CaelumLifeRegeneration";
    }
    override int GetConsumableType()
    {
        return CaelumConstants.CONSUMABLE_LIFE_POTION;
    }
    States { Spawn: CMED A -1; Stop; }
}

class CaelumAnimaPotion : CaelumConsumableItem
{
    Default
    {
        Tag "$CA_CONSUMABLE_ANIMA_POTION";
        Inventory.Icon "graphics/caelum/icons/ca_anima_potion.png";
        Inventory.PickupMessage "$CA_PICKUP_ANIMA_POTION";
        Powerup.Type "CaelumAnimaRegeneration";
    }
    override int GetConsumableType()
    {
        return CaelumConstants.CONSUMABLE_ANIMA_POTION;
    }
    States { Spawn: CANI A -1 Bright; Stop; }
}

class CaelumEnergyDrink : CaelumConsumableItem
{
    Default
    {
        Tag "$CA_CONSUMABLE_ENERGY_DRINK";
        Inventory.Icon "graphics/caelum/icons/ca_energy_drink.png";
        Inventory.PickupMessage "$CA_PICKUP_ENERGY_DRINK";
        Powerup.Type "CaelumEnergyRegeneration";
    }
    override int GetConsumableType()
    {
        return CaelumConstants.CONSUMABLE_ENERGY_DRINK;
    }
    States { Spawn: CENE A -1 Bright; Stop; }
}

class CaelumLifePotionMedium : CaelumLifePotion
{
    Default { Tag "$CA_CONSUMABLE_LIFE_MEDIUM"; Inventory.Icon "graphics/caelum/icons/potions/medikit_medium.png"; }
    override int GetConsumableType(){return CaelumConstants.CONSUMABLE_LIFE_MEDIUM;}
    States { Spawn: CMMD A -1; Stop; }
}
class CaelumAnimaPotionMedium : CaelumAnimaPotion
{
    Default { Tag "$CA_CONSUMABLE_ANIMA_MEDIUM"; Inventory.Icon "graphics/caelum/icons/potions/anima_medium.png"; }
    override int GetConsumableType(){return CaelumConstants.CONSUMABLE_ANIMA_MEDIUM;}
    States { Spawn: CAMD A -1 Bright; Stop; }
}
class CaelumEnergyDrinkMedium : CaelumEnergyDrink
{
    Default { Tag "$CA_CONSUMABLE_ENERGY_MEDIUM"; Inventory.Icon "graphics/caelum/icons/potions/energy_medium.png"; }
    override int GetConsumableType(){return CaelumConstants.CONSUMABLE_ENERGY_MEDIUM;}
    States { Spawn: CEMD A -1 Bright; Stop; }
}
class CaelumLifePotionLarge : CaelumLifePotion
{
    Default { Tag "$CA_CONSUMABLE_LIFE_LARGE"; Inventory.Icon "graphics/caelum/icons/potions/medikit_large.png"; }
    override int GetConsumableType(){return CaelumConstants.CONSUMABLE_LIFE_LARGE;}
    States { Spawn: CMLG A -1; Stop; }
}
class CaelumAnimaPotionLarge : CaelumAnimaPotion
{
    Default { Tag "$CA_CONSUMABLE_ANIMA_LARGE"; Inventory.Icon "graphics/caelum/icons/potions/anima_large.png"; }
    override int GetConsumableType(){return CaelumConstants.CONSUMABLE_ANIMA_LARGE;}
    States { Spawn: CALG A -1 Bright; Stop; }
}
class CaelumEnergyDrinkLarge : CaelumEnergyDrink
{
    Default { Tag "$CA_CONSUMABLE_ENERGY_LARGE"; Inventory.Icon "graphics/caelum/icons/potions/energy_large.png"; }
    override int GetConsumableType(){return CaelumConstants.CONSUMABLE_ENERGY_LARGE;}
    States { Spawn: CELG A -1 Bright; Stop; }
}

class CaelumFoodRation : CaelumConsumableItem
{
    Default
    {
        Tag "$CA_CONSUMABLE_FOOD_RATION";
        Inventory.Icon "graphics/caelum/icons/ca_food_ration.png";
        Inventory.PickupMessage "$CA_PICKUP_FOOD_RATION";
        Powerup.Type "CaelumHungerRegeneration";
    }
    override int GetConsumableType()
    {
        return CaelumConstants.CONSUMABLE_FOOD_RATION;
    }
    States { Spawn: CFOO A -1; Stop; }
}

class CaelumWaterRation : CaelumConsumableItem
{
    Default
    {
        Tag "$CA_CONSUMABLE_WATER_RATION";
        Inventory.Icon "graphics/caelum/icons/ca_water_ration.png";
        Inventory.PickupMessage "$CA_PICKUP_WATER_RATION";
        Powerup.Type "CaelumThirstRegeneration";
    }
    override int GetConsumableType()
    {
        return CaelumConstants.CONSUMABLE_WATER_RATION;
    }
    States { Spawn: CWAT A -1; Stop; }
}

// Recipiente reutilizable individual. La pila no mezcla contenidos distintos.
// Se conserva la tara genérica existente de objeto especial: 0,10 kg.
class CaelumWaterContainer : CaelumConsumableItem
{
    double WaterLiters;
    bool WasSubmerged;
    int WaterQuality;
    int WaterQualityRevision;
    int WaterTemperatureRevision;
    double WaterTemperatureC;
    double CoolingSeconds;
    bool TemperatureClockReady;
    double TemperatureStamp;
    transient CaelumWeatherSample CoolingEnvironment;

    void EnsureWaterTemperature(CaelumPlayer user)
    {
        if(WaterTemperatureRevision>=CaelumWaterThermalData.REVISION)return;
        let thermal=CaelumThermalBody.Get(user);
        if(thermal==null || !thermal.Available)return;
        WaterTemperatureC=thermal.AmbientAirC;
        WaterTemperatureRevision=CaelumWaterThermalData.REVISION;
        StampTemperature(user);
    }
    void StampTemperature(CaelumPlayer user)
    {
        let clock=CaelumWorldClock.Get(user);
        if(clock==null)return;
        TemperatureStamp=CaelumThermalRuntime.Stamp(clock);TemperatureClockReady=true;
    }
    clearscope bool IsDrinkable()
    {return IsPotable() && !CaelumWaterBoiling.Locked(self)
        && (WaterTemperatureRevision==0 || WaterTemperatureC<=CaelumWaterThermalData.DRINK_MAX_C);}
    clearscope bool IsLeather()
    {return self is 'CaelumCanteenSmall' || self is 'CaelumCanteenNormal' || self is 'CaelumCanteenLarge';}
    virtual clearscope double CoolWater(double ambient,double wind,double seconds)
    {return CaelumWaterThermalData.Cool(WaterTemperatureC,ambient,wind,seconds,WaterLiters,GetCapacityLiters(),IsLeather());}
    virtual clearscope bool IndependentContainers(){return false;}
    void AdvanceTemperature(CaelumPlayer user,double seconds)
    {
        EnsureWaterTemperature(user);
        let clock=CaelumWorldClock.Get(user);
        if(clock!=null)
        {
            double now=CaelumThermalRuntime.Stamp(clock);
            if(TemperatureClockReady)seconds=Max(0,now-TemperatureStamp);
            TemperatureStamp=now;TemperatureClockReady=true;
        }
        if(WaterLiters<=0 || WaterTemperatureRevision==0 || CaelumWaterBoiling.Locked(self))return;
        CoolingSeconds+=seconds;
        if(CoolingSeconds<1)return;
        let thermal=CaelumThermalBody.Get(user);
        if(thermal!=null && thermal.Available)
            WaterTemperatureC=CoolWater(thermal.AmbientAirC,thermal.AmbientWindKmh/3.6,CoolingSeconds);
        CoolingSeconds=0;
    }
    override void Tick()
    {
        Super.Tick();
        if(Owner is 'CaelumPlayer' || level.maptime%TICRATE!=0)return;
        let world=CaelumThermalWorld.Get();
        if(world==null || world.ReferenceClock==null || world.ReferenceWeather==null)return;
        let weather=world.ReferenceWeather;
        if(weather.Outside==null || !weather.Outside.Available)return;
        Actor body=Owner;if(body==null)body=self;
        int shelter=CaelumWeatherRules.OPEN;
        if(weather.Profile==CaelumWeatherRules.PROFILE_LIMBO)shelter=CaelumWeatherRules.LIMBO;
        else if(CaelumThermalShelter.Roof(body))shelter=weather.Profile>=2 && weather.Profile<=4
            ?CaelumWeatherRules.UNDERGROUND:CaelumThermalShelter.WindBlocked(body)?CaelumWeatherRules.INDOOR:CaelumWeatherRules.CANOPY;
        if(CoolingEnvironment==null)CoolingEnvironment=new('CaelumWeatherSample');
        CoolingEnvironment.ApplyShelter(weather.Outside,shelter,weather.Profile);
        double now=CaelumThermalRuntime.Stamp(world.ReferenceClock);
        if(WaterTemperatureRevision==0)
        {WaterTemperatureC=CoolingEnvironment.AirTemperatureC;WaterTemperatureRevision=CaelumWaterThermalData.REVISION;}
        else if(TemperatureClockReady && WaterLiters>0)
            WaterTemperatureC=CoolWater(CoolingEnvironment.AirTemperatureC,CoolingEnvironment.WindSpeedKmh/3.6,Max(0,now-TemperatureStamp));
        TemperatureStamp=now;TemperatureClockReady=true;
    }

    // Los guardados anteriores sólo podían contener agua potable. Cero conserva
    // esa identidad; migrar no rellena, vacía ni modifica una calidad existente.
    void EnsureWaterQuality()
    { if (WaterQualityRevision < CaelumWaterQuality.REVISION) WaterQualityRevision = CaelumWaterQuality.REVISION; }
    clearscope bool IsPotable() { return CaelumWaterQuality.IsSafe(WaterQuality); }
    clearscope String WaterLabel()
    { return WaterLiters <= 0.000001 ? StringTable.Localize("CA_WATER_EMPTY", false) : CaelumWaterQuality.Label(WaterQuality); }
    bool AddWater(double liters, int quality, double sourceC=0, bool sourceKnown=false)
    {
        if (CaelumWaterBoiling.Locked(self) || liters <= 0 || !CaelumWaterQuality.Valid(quality)
            || WaterLiters < 0 || WaterLiters + liters > GetCapacityLiters() + 0.000001
            || (WaterLiters > 0.000001 && !CaelumWaterQuality.Valid(WaterQuality))) return false;
        EnsureWaterQuality();
        let user=CaelumPlayer(Owner);EnsureWaterTemperature(user);
        let thermal=CaelumThermalBody.Get(user);
        if(!sourceKnown && thermal!=null && thermal.Available){sourceC=thermal.AmbientAirC;sourceKnown=true;}
        if(sourceKnown)
        {
            WaterTemperatureC=CaelumWaterThermalData.Mix(WaterLiters,WaterTemperatureC,liters,sourceC);
            WaterTemperatureRevision=CaelumWaterThermalData.REVISION;
        }
        WaterQuality = WaterLiters > 0.000001 ? WaterQuality | quality : quality;
        WaterLiters += liters;
        return true;
    }
    bool FillFromSource(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user) || Owner != user || InMagicBox || user.health <= 0) return false;
        let reservoir=CaelumConnectedWaterMap.Get();
        if(reservoir!=null)reservoir.Sync(CaelumWorldClock.Get(user));
        int reservoirIndex=reservoir!=null ? reservoir.Index(CaelumWaterQuality.Model(user)) : -1;
        int quality = CaelumWaterQuality.Source(user);
        double missing = GetCapacityLiters() - WaterLiters;
        if(reservoirIndex>=0)missing=Min(missing,reservoir.Available(reservoirIndex));
        if (missing <= 0.000001 || !CaelumWaterQuality.Valid(quality)
            || !user.CanAddWeightToPersonalInventory(missing + 0.001)) return false;
        let thermal=CaelumThermalBody.Get(user);
        bool sourceKnown=thermal!=null && thermal.Available;
        double sourceC=sourceKnown?thermal.WaterC:0;
        if (!AddWater(missing, quality,sourceC,sourceKnown)) return false;
        if(reservoirIndex>=0)reservoir.Withdraw(reservoirIndex,missing);
        let record = user.GetPersistentCharacterState(false);
        if (IsPotable() && record != null && record.MainM00WaterContainerGiven) record.MainM00WaterFilled = true;
        user.OnNativeInventoryChanged(); user.PersistCharacterState();
        return true;
    }
    bool EmptyWater(CaelumPlayer user)
    {
        if (!CaelumPlayerAuthority.CanMutate(user) || Owner != user || InMagicBox || WaterLiters <= 0 || CaelumWaterBoiling.Locked(self)) return false;
        EnsureWaterQuality(); WaterLiters = 0; WaterQuality = CaelumWaterQuality.POTABLE;
        user.OnNativeInventoryChanged(); user.PersistCharacterState();
        return true;
    }
    Default
    {
        Inventory.MaxAmount 1;
        Inventory.InterHubAmount 1;
        -INVENTORY.INVBAR
    }
    virtual clearscope double GetCapacityLiters() { return 1.0; }
    override double GetUnitWeight()
    { return CaelumConstants.SPECIAL_ITEM_DEFAULT_WEIGHT + Max(0.0, WaterLiters); }
    override bool HandlePickup(Inventory item)
    {
        if (item.GetClass() == GetClass()) return !IndependentContainers();
        return Super.HandlePickup(item);
    }
    override bool TryPickup(in out Actor toucher)
    {
        if (!IndependentContainers() && toucher.FindInventory(GetClassName()) != null) return false;
        return Super.TryPickup(toucher);
    }
    override Inventory CreateCopy(Actor other)
    {
        let copy = CaelumWaterContainer(Super.CreateCopy(other));
        if (copy != null) { copy.WaterLiters = WaterLiters; copy.WasSubmerged = WasSubmerged; copy.WaterQuality = WaterQuality; copy.WaterQualityRevision = WaterQualityRevision; copy.WaterTemperatureC=WaterTemperatureC; copy.WaterTemperatureRevision=WaterTemperatureRevision; copy.CoolingSeconds=CoolingSeconds; copy.TemperatureClockReady=TemperatureClockReady; copy.TemperatureStamp=TemperatureStamp; }
        CaelumOnboarding.TransferUtilityIdentity(self, copy);
        return copy;
    }
    override Inventory CreateTossable(int amount)
    {
        if(CaelumWaterBoiling.Locked(self))return null;
        let copy = CaelumWaterContainer(Super.CreateTossable(amount));
        if (copy != null) { copy.WaterLiters = WaterLiters; copy.WasSubmerged = WasSubmerged; copy.InMagicBox = InMagicBox; copy.WaterQuality = WaterQuality; copy.WaterQualityRevision = WaterQualityRevision; copy.WaterTemperatureC=WaterTemperatureC; copy.WaterTemperatureRevision=WaterTemperatureRevision; copy.CoolingSeconds=CoolingSeconds; copy.TemperatureClockReady=TemperatureClockReady; copy.TemperatureStamp=TemperatureStamp; }
        CaelumOnboarding.TransferUtilityIdentity(self, copy);
        return copy;
    }
    // La interfaz propia ejecuta Drink sin consumir la instancia Inventory.
    override bool Use(bool pickup) { return false; }
    bool Drink()
    {
        let user = CaelumPlayer(Owner);
        if (user == null || user.health <= 0 || InMagicBox || !IsDrinkable() || WaterLiters <= 0.000001
            || user.DerivedStats == null || user.CurrentThirst >= 100) return false;
        // Un sorbo cubre diez puntos de Sed según la masa corporal, sin equipo.
        // Si queda menos agua, sólo recupera la proporción realmente bebida.
        EnsureWaterQuality();
        double bodyMass = Max(1, user.DerivedStats.BaseMass);
        double amount = Min(bodyMass / CaelumConstants.WATER_RECOVERY_PER_LITER_PER_PULSE, WaterLiters);
        let power = CaelumRegenerationPower(user.GiveInventoryType("CaelumThirstRegeneration"));
        if (power == null) power = CaelumRegenerationPower(user.FindInventory("CaelumThirstRegeneration"));
        if (power == null) return false;
        power.EffectTics = CaelumConstants.CONSUMABLE_REGENERATION_SECONDS * TICRATE;
        power.PulseTics = 0;
        power.SeatedMealSubTics = 0;
        power.WaterRecoveryPerPulse = amount * CaelumConstants.WATER_RECOVERY_PER_LITER_PER_PULSE / bodyMass;
        WaterLiters = Max(0.0, WaterLiters - amount);
        if (WaterLiters < 0.000001) WaterLiters = 0;
        CaelumMainM00RonnieTrial.RecordNeedsUse(user, CaelumConstants.CONSUMABLE_WATER_RATION);
        let record = user.GetPersistentCharacterState(false);
        if (record != null && record.MainM00WaterContainerGiven) record.MainM00WaterDrank = true;
        user.OnNativeInventoryChanged(); user.PersistCharacterState();
        return true;
    }
    void ObserveImmersion(CaelumPlayer user)
    {
        bool submerged = user.IsSubmergedInPotableWater();
        bool entered = submerged && !WasSubmerged;
        WasSubmerged = submerged;
        if (!entered || InMagicBox) return;
        FillFromSource(user);
    }
}

class CaelumBottleSmall : CaelumWaterContainer
{
    Default { Tag "$CA_WATER_BOTTLE_SMALL"; Inventory.Icon "graphics/caelum/icons/water/bottle_small.png"; }
    override int GetConsumableType() { return 5; }
    override double GetCapacityLiters() { return 1.0; }
    States { Spawn: CW0X A -1; Stop; }
}

class CaelumBottleNormal : CaelumWaterContainer
{
    Default { Tag "$CA_WATER_BOTTLE_NORMAL"; Inventory.Icon "graphics/caelum/icons/water/bottle_normal.png"; }
    override int GetConsumableType() { return 6; }
    override double GetCapacityLiters() { return 2.5; }
    States { Spawn: CW1X A -1; Stop; }
}

class CaelumBottleLarge : CaelumWaterContainer
{
    Default { Tag "$CA_WATER_BOTTLE_LARGE"; Inventory.Icon "graphics/caelum/icons/water/bottle_large.png"; }
    override int GetConsumableType() { return 7; }
    override double GetCapacityLiters() { return 5.0; }
    States { Spawn: CW2X A -1; Stop; }
}

class CaelumCanteenSmall : CaelumWaterContainer
{
    Default { Tag "$CA_WATER_CANTEEN_SMALL"; Inventory.Icon "graphics/caelum/icons/water/canteen_small.png"; }
    override int GetConsumableType() { return 8; }
    override double GetCapacityLiters() { return 1.0; }
    States { Spawn: CW3X A -1; Stop; }
}

class CaelumCanteenNormal : CaelumWaterContainer
{
    Default { Tag "$CA_WATER_CANTEEN_NORMAL"; Inventory.Icon "graphics/caelum/icons/water/canteen_normal.png"; }
    override int GetConsumableType() { return 9; }
    override double GetCapacityLiters() { return 2.5; }
    States { Spawn: CW4X A -1; Stop; }
}

class CaelumCanteenLarge : CaelumWaterContainer
{
    Default { Tag "$CA_WATER_CANTEEN_LARGE"; Inventory.Icon "graphics/caelum/icons/water/canteen_large.png"; }
    override int GetConsumableType() { return 10; }
    override double GetCapacityLiters() { return 5.0; }
    States { Spawn: CW5X A -1; Stop; }
}
