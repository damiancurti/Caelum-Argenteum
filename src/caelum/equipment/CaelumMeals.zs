// Platos terminados: una unidad nativa es una porción completa de 100 g.
class CaelumBread : CaelumConsumableItem
{
    Default {Tag "$CA_MEAL_BREAD";Inventory.Icon "graphics/caelum/icons/meals/bread.png";Powerup.Type "CaelumHungerRegeneration";}
    override int GetConsumableType(){return CaelumMealData.BREAD;}
    States {Spawn: FBRD A -1;Stop;}
}
class CaelumRoastBeef : CaelumConsumableItem
{
    Default {Tag "$CA_MEAL_ROAST_BEEF";Inventory.Icon "graphics/caelum/icons/meals/roast_beef.png";Powerup.Type "CaelumHungerRegeneration";}
    override int GetConsumableType(){return CaelumMealData.ROAST_BEEF;}
    States {Spawn: FRBF A -1;Stop;}
}
class CaelumRoastFish : CaelumConsumableItem
{
    Default {Tag "$CA_MEAL_ROAST_FISH";Inventory.Icon "graphics/caelum/icons/meals/roast_fish.png";Powerup.Type "CaelumHungerRegeneration";}
    override int GetConsumableType(){return CaelumMealData.ROAST_FISH;}
    States {Spawn: FRFS A -1;Stop;}
}
class CaelumPuchero : CaelumConsumableItem
{
    Default {Tag "$CA_MEAL_PUCHERO";Inventory.Icon "graphics/caelum/icons/meals/puchero.png";Powerup.Type "CaelumHungerRegeneration";}
    override int GetConsumableType(){return CaelumMealData.PUCHERO;}
    States {Spawn: FPCH A -1;Stop;}
}
