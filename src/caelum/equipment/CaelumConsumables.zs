// Consumibles apilables sobre el inventario nativo. PowerupGiver se ocupa de
// consumir una unidad y de crear o refrescar el efecto temporal asociado.
class CaelumConsumableItem : PowerupGiver
{
    bool InMagicBox;

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

    virtual int GetConsumableType() { return -1; }

    Name GetPowerClassName()
    {
        switch (GetConsumableType())
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

    virtual double GetUnitWeight()
    {
        int consumableType = GetConsumableType();
        if (consumableType == CaelumConstants.CONSUMABLE_FOOD_RATION
            || consumableType == CaelumConstants.CONSUMABLE_WATER_RATION)
        {
            return CaelumConstants.CONSUMABLE_RATION_WEIGHT;
        }
        return CaelumConstants.CONSUMABLE_POTION_WEIGHT;
    }

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
                if (GetConsumableType() == CaelumConstants.CONSUMABLE_WATER_RATION)
                {
                    let user = CaelumPlayer(Owner);
                    if (user != null && user.DerivedStats != null)
                        power.WaterRecoveryPerPulse = 50.0 / Max(1, user.DerivedStats.BaseMass);
                }
            }
        }
        // Sólo un uso nativo aceptado acredita la práctica; recoger, mirar o
        // intentar consumir desde la Caja no llega a este observador.
        if (used) CaelumMainM00RonnieTrial.RecordNeedsUse(CaelumPlayer(Owner), GetConsumableType());
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
        bool pickedUp = Super.TryPickup(toucher);
        if (pickedUp) { caelumPlayer.OnNativeInventoryChanged(); }
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
// Asi se respetan exactamente diez aplicaciones del 1% durante diez segundos.
class CaelumRegenerationPower : Powerup
{
    int PulseTics;
    int SeatedMealSubTics;
    double WaterRecoveryPerPulse;

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
            // La misma porción conserva sus diez pulsos, espaciados diez veces
            // más. Compensar el vencimiento nativo conserva su aporte total.
            // La fracción se guarda y continúa si vuelve a sentarse.
            SeatedMealSubTics++;
            if (SeatedMealSubTics < 10) { EffectTics++; return; }
            SeatedMealSubTics = 0;
        }
        PulseTics++;
        if (PulseTics < TICRATE) { return; }
        PulseTics -= TICRATE;
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
            caelumPlayer.ApplyConsumableRegenerationPulse(
                GetRegenerationType()
            );
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
    Default
    {
        Inventory.MaxAmount 1;
        Inventory.InterHubAmount 1;
        -INVENTORY.INVBAR
    }
    virtual double GetCapacityLiters() { return 1.0; }
    override double GetUnitWeight()
    { return CaelumConstants.SPECIAL_ITEM_DEFAULT_WEIGHT + Max(0.0, WaterLiters); }
    override bool HandlePickup(Inventory item)
    {
        if (item.GetClass() == GetClass()) return true;
        return Super.HandlePickup(item);
    }
    override bool TryPickup(in out Actor toucher)
    {
        if (toucher.FindInventory(GetClassName()) != null) return false;
        return Super.TryPickup(toucher);
    }
    override Inventory CreateCopy(Actor other)
    {
        let copy = CaelumWaterContainer(Super.CreateCopy(other));
        if (copy != null) { copy.WaterLiters = WaterLiters; copy.WasSubmerged = WasSubmerged; }
        return copy;
    }
    override Inventory CreateTossable(int amount)
    {
        let copy = CaelumWaterContainer(Super.CreateTossable(amount));
        if (copy != null) { copy.WaterLiters = WaterLiters; copy.WasSubmerged = WasSubmerged; copy.InMagicBox = InMagicBox; }
        return copy;
    }
    // La interfaz propia ejecuta Drink sin consumir la instancia Inventory.
    override bool Use(bool pickup) { return false; }
    bool Drink()
    {
        let user = CaelumPlayer(Owner);
        if (user == null || user.health <= 0 || InMagicBox || WaterLiters <= 0.000001
            || user.DerivedStats == null || user.CurrentThirst >= 100) return false;
        // Un sorbo cubre diez puntos de Sed según la masa corporal, sin equipo.
        // Si queda menos agua, sólo recupera la proporción realmente bebida.
        double bodyMass = Max(1, user.DerivedStats.BaseMass);
        double amount = Min(bodyMass / 500.0, WaterLiters);
        let power = CaelumRegenerationPower(user.GiveInventoryType("CaelumThirstRegeneration"));
        if (power == null) power = CaelumRegenerationPower(user.FindInventory("CaelumThirstRegeneration"));
        if (power == null) return false;
        power.EffectTics = CaelumConstants.CONSUMABLE_REGENERATION_SECONDS * TICRATE;
        power.PulseTics = 0;
        power.SeatedMealSubTics = 0;
        power.WaterRecoveryPerPulse = amount * 500.0 / bodyMass;
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
        double missingLiters = Max(0.0, GetCapacityLiters() - WaterLiters);
        if (missingLiters <= 0.000001) return;
        // Completa vacíos y parciales; sólo el agua faltante añade peso.
        // Nunca sobrecarga ni usa la reducción de la Caja.
        if (!user.CanAddWeightToPersonalInventory(missingLiters + 0.001)) return;
        WaterLiters = GetCapacityLiters();
        let record = user.GetPersistentCharacterState(false);
        if (record != null && record.MainM00WaterContainerGiven) record.MainM00WaterFilled = true;
        user.OnNativeInventoryChanged(); user.PersistCharacterState();
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
