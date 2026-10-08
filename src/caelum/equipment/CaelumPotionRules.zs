// Catálogo compartido: los tipos históricos son las pociones pequeñas.
// Los nuevos identificadores se agregan sin renumerar comida ni recipientes.
class CaelumPotionRules : Object
{
    static clearscope String Icon(int kind)
    {
        int family=Family(kind),size=Size(kind);
        if(size==SMALL)return family==0 ? "graphics/caelum/icons/ca_medikit.png"
            : family==1 ? "graphics/caelum/icons/ca_anima_potion.png" : "graphics/caelum/icons/ca_energy_drink.png";
        return String.Format("graphics/caelum/icons/potions/%s_%s.png",
            family==0 ? "medikit" : family==1 ? "anima" : "energy",size==MEDIUM ? "medium" : "large");
    }
    const SMALL=0;
    const MEDIUM=1;
    const LARGE=2;
    const INITIAL_DEMON_UNITS=6;
    const AUTO_USE_THRESHOLD=0.5;

    static clearscope int Family(int kind)
    {
        if(kind>=CaelumConstants.CONSUMABLE_LIFE_MEDIUM
            && kind<=CaelumConstants.CONSUMABLE_ENERGY_LARGE)
            return (kind-CaelumConstants.CONSUMABLE_LIFE_MEDIUM)%3;
        return kind;
    }

    static clearscope bool IsPotion(int kind)
    {return Family(kind)>=CaelumConstants.CONSUMABLE_LIFE_POTION
        && Family(kind)<=CaelumConstants.CONSUMABLE_ENERGY_DRINK;}

    static clearscope int Size(int kind)
    {
        if(kind>=CaelumConstants.CONSUMABLE_LIFE_LARGE
            && kind<=CaelumConstants.CONSUMABLE_ENERGY_LARGE)return LARGE;
        if(kind>=CaelumConstants.CONSUMABLE_LIFE_MEDIUM
            && kind<=CaelumConstants.CONSUMABLE_ENERGY_MEDIUM)return MEDIUM;
        return SMALL;
    }

    static clearscope int Kind(int family,int size)
    {
        if(size==LARGE)return CaelumConstants.CONSUMABLE_LIFE_LARGE+family;
        if(size==MEDIUM)return CaelumConstants.CONSUMABLE_LIFE_MEDIUM+family;
        return family;
    }

    static clearscope double TotalRatio(int size)
    {
        if(size==LARGE)return 0.50;
        if(size==MEDIUM)return 0.225;
        return CaelumConstants.CONSUMABLE_REGENERATION_PERCENT_PER_SECOND
            *CaelumConstants.CONSUMABLE_REGENERATION_SECONDS;
    }

    static clearscope Name ItemClass(int kind)
    {
        switch(kind)
        {
            case CaelumConstants.CONSUMABLE_LIFE_POTION:return 'CaelumLifePotion';
            case CaelumConstants.CONSUMABLE_ANIMA_POTION:return 'CaelumAnimaPotion';
            case CaelumConstants.CONSUMABLE_ENERGY_DRINK:return 'CaelumEnergyDrink';
            case CaelumConstants.CONSUMABLE_LIFE_MEDIUM:return 'CaelumLifePotionMedium';
            case CaelumConstants.CONSUMABLE_ANIMA_MEDIUM:return 'CaelumAnimaPotionMedium';
            case CaelumConstants.CONSUMABLE_ENERGY_MEDIUM:return 'CaelumEnergyDrinkMedium';
            case CaelumConstants.CONSUMABLE_LIFE_LARGE:return 'CaelumLifePotionLarge';
            case CaelumConstants.CONSUMABLE_ANIMA_LARGE:return 'CaelumAnimaPotionLarge';
            case CaelumConstants.CONSUMABLE_ENERGY_LARGE:return 'CaelumEnergyDrinkLarge';
        }
        return 'None';
    }
}
