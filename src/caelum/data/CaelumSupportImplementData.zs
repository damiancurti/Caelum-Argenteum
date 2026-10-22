// #479: contrato aprobado; estos roles no son IDs de objetos ni slots nativos.
class CaelumSupportImplementData : Object
{
    const BOOK=0;
    const CENSER=1;
    const STATUETTE=2;
    const EFFIGY=3;
    const ROLE_COUNT=4;
    const BASE_PERCENT_PER_SECOND=1.0;
    const BASE_SECONDS=1.0;
    const AREA_ANIMA=70.0;
    const SINGLE_ANIMA=100.0;
    const TIER_TWO_COST=1.6;
    const TIER_THREE_COST=2.5;
    const FIRST_RECIPE=169;
    const FIRST_COMPONENT_RECIPE=173;
    const COMPONENT_COUNT=3;
    const MIGRATION_REVISION=1;
    const SHOP_CATEGORY=5;

    static Name Selector(int weaponType,int tier)
    {
        String implementName;
        switch(RoleForWeapon(weaponType))
        {
            case BOOK:implementName="SupportBook";break;
            case CENSER:implementName="Censer";break;
            case STATUETTE:implementName="SupportStatuette";break;
            case EFFIGY:implementName="Effigy";break;
            default:return '';
        }
        return Name(String.Format("Caelum%sT%dWeapon",implementName,Clamp(tier,1,3)));
    }
    static clearscope int RoleForWeapon(int type)
    {return type>=CaelumConstants.WEAPON_TYPE_SUPPORT_BOOK && type<=CaelumConstants.WEAPON_TYPE_EFFIGY
        ? type-CaelumConstants.WEAPON_TYPE_SUPPORT_BOOK : -1;}
    static clearscope bool IsSupport(int type){return RoleForWeapon(type)>=0;}
    static clearscope bool IsOffensiveMagic(int type)
    {return type==CaelumConstants.WEAPON_TYPE_STAFF || type==CaelumConstants.WEAPON_TYPE_BELL
        || type==CaelumConstants.WEAPON_TYPE_SCEPTER || type==CaelumConstants.WEAPON_TYPE_ORB;}
    static clearscope bool ValidEssence(int type,int essence)
    {return IsSupport(type)?essence==CaelumConstants.ESSENCE_QUINTESSENCE
        : !IsOffensiveMagic(type) || (essence>=CaelumConstants.ESSENCE_FIRE && essence<CaelumConstants.ESSENCE_QUINTESSENCE);}
    static clearscope bool IsRecipe(int recipe){return recipe>=FIRST_RECIPE && recipe<FIRST_RECIPE+ROLE_COUNT;}
    static clearscope bool IsComponentRecipe(int recipe)
    {return recipe>=FIRST_COMPONENT_RECIPE && recipe<FIRST_COMPONENT_RECIPE+COMPONENT_COUNT;}
    static clearscope bool IsComponent(int material)
    {return material>=CaelumConstants.MATERIAL_CENSER_BASE && material<=CaelumConstants.MATERIAL_ORB_BASE;}
    static clearscope bool RetiredRecipe(int recipe)
    {
        int first=CaelumConstants.CRAFTING_NETWORK_PHYSICAL_RECIPE_COUNT+CaelumConstants.CRAFTING_NETWORK_ARMOR_RECIPE_COUNT;
        return recipe>=first && recipe<first+CaelumConstants.CRAFTING_NETWORK_ESSENCE_RECIPE_COUNT
            && (recipe-first)%CaelumConstants.ESSENCE_TYPE_COUNT==CaelumConstants.ESSENCE_QUINTESSENCE;
    }
    static clearscope double Weight(int type)
    {
        int role=RoleForWeapon(type);
        if(role==BOOK)return CaelumConstants.WEAPON_BOOK_TIER_ONE_WEIGHT;
        if(role==CENSER)return CaelumConstants.WEAPON_BELL_TIER_ONE_WEIGHT;
        return CaelumConstants.WEAPON_STATUETTE_TIER_ONE_WEIGHT;
    }
    static clearscope int BaseMaterial(int type)
    {
        if(type==CaelumConstants.WEAPON_TYPE_SCEPTER)return CaelumConstants.MATERIAL_SCEPTER_BASE;
        if(type==CaelumConstants.WEAPON_TYPE_ORB)return CaelumConstants.MATERIAL_ORB_BASE;
        int role=RoleForWeapon(type);
        if(role==BOOK)return CaelumConstants.MATERIAL_BOOK_BASE;
        if(role==CENSER)return CaelumConstants.MATERIAL_CENSER_BASE;
        return CaelumConstants.MATERIAL_STATUETTE_BASE;
    }
    static clearscope String WeaponKey(int type)
    {
        if(type==CaelumConstants.WEAPON_TYPE_SCEPTER)return "CA_WEAPON_TYPE_SCEPTER";
        if(type==CaelumConstants.WEAPON_TYPE_ORB)return "CA_WEAPON_TYPE_ORB";
        int role=RoleForWeapon(type);
        if(role==BOOK)return "CA_WEAPON_TYPE_BOOK";
        if(role==CENSER)return "CA_WEAPON_TYPE_CENSER";
        if(role==STATUETTE)return "CA_WEAPON_TYPE_STATUETTE";
        return "CA_WEAPON_TYPE_EFFIGY";
    }

    static clearscope bool ValidRole(int role){return role>=BOOK && role<ROLE_COUNT;}
    static clearscope bool Beneficial(int role){return role==CENSER || role==STATUETTE;}
    static clearscope bool Area(int role){return role==BOOK || role==CENSER;}
    static clearscope bool SecondaryModifiers(int role){return role==STATUETTE || role==EFFIGY;}
    static clearscope int Essence(){return CaelumConstants.ESSENCE_QUINTESSENCE;}
    static clearscope double BaseRadius(){return CaelumConstants.ESSENCE_EXPLOSION_BASE_RADIUS;}
    static clearscope int PreparationTics(){return CaelumAttackRules.BASE_TICS;}

    static clearscope double Power(double attribute)
    {return CaelumGrowthRules.Multiplier(attribute,2);}

    static clearscope double Rate(double attribute)
    {return BASE_PERCENT_PER_SECOND*Power(attribute);}

    static clearscope double Duration(double attribute)
    {return BASE_SECONDS*Power(attribute);}

    static clearscope double BaseAnimaCost(int role,int tier)
    {
        if(!ValidRole(role) || tier<1 || tier>3)return 0;
        return (Area(role)?AREA_ANIMA:SINGLE_ANIMA)
            *(tier==3?TIER_THREE_COST:tier==2?TIER_TWO_COST:1.0);
    }
}
