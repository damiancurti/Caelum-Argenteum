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
        return InMagicBox ? 0.0 : Amount * GetUnitWeight();
    }

    override bool Use(bool pickup)
    {
        // El contenido de la Caja Magica no puede usarse hasta recuperarlo.
        if (InMagicBox) { return false; }
        bool used = Super.Use(pickup);
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
            }
        }
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

    Default
    {
        Powerup.Duration -10;
        +INVENTORY.HUBPOWER
    }

    virtual int GetRegenerationType() { return -1; }

    override void DoEffect()
    {
        Super.DoEffect();
        PulseTics++;
        if (PulseTics < TICRATE) { return; }
        PulseTics -= TICRATE;
        CaelumPlayer caelumPlayer = CaelumPlayer(Owner);
        if (caelumPlayer != null)
        {
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
