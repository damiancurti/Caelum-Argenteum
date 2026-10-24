// #502: calibraciones aprobadas; concentración compartida de 0 a 100.
class CaelumContaminationData : Object
{
    const STATE_REVISION = 1;
    const SEVERE_THRESHOLD = 90.0;
    const SEVERE_DAMAGE_FACTOR = 2.0;
    const CONTACT_DEGREES_M2_SECOND = 0.1;
    const CONTACT_RATIO_FLOOR = 1.0;
    const IMPACT_CONTACT_SECONDS = 10.0;
    const FOOT_CONTACT_M2 = 0.04;
    const BODY_CONTACT_M2 = 0.10;
    const IMPACT_CONTACT_M2 = 0.01;
    const EQUIPMENT_WATER_L_M2 = 1.0;
    const SOAP_G_L = 5.0;
    const BATH_WATER_L_DEGREE = 0.5;
    const NATURAL_REFERENCE = 5.0;
    const URBAN_REFERENCE = 15.0;
    const INDUSTRIAL_REFERENCE = 40.0;
    const SEWER_REFERENCE = 60.0;
    const ENV_UNKNOWN = 0;
    const ENV_NATURAL = 1;
    const ENV_URBAN = 2;
    const ENV_INDUSTRIAL = 3;
    const ENV_SEWER = 4;

    static clearscope double Reference(int category)
    {
        switch(category)
        {
            case ENV_NATURAL:return NATURAL_REFERENCE;
            case ENV_URBAN:return URBAN_REFERENCE;
            case ENV_INDUSTRIAL:return INDUSTRIAL_REFERENCE;
            case ENV_SEWER:return SEWER_REFERENCE;
        }
        return -1;
    }
    static clearscope int MapClass(String map)
    {
        int location=CaelumWorldCatalogue.LocationForMap(map);
        if(location==CaelumWorldCatalogue.LOCATION_MANSION || location==CaelumWorldCatalogue.LOCATION_PORT)return ENV_URBAN;
        if(location==CaelumWorldCatalogue.LOCATION_SEWERS)return ENV_SEWER;
        if(location==CaelumWorldCatalogue.LOCATION_COAST)return ENV_NATURAL;
        return ENV_UNKNOWN;
    }
    // Muestreo humano 16x16 del sistema térmico, aprobado como referencia M.
    static clearscope double GarmentCoverage(int slot)
    {
        switch(slot)
        {
            case CaelumConstants.ARMOR_SLOT_HEAD:return 0.1875;
            case CaelumConstants.ARMOR_SLOT_BODY:return 0.375;
            case CaelumConstants.ARMOR_SLOT_HANDS:return 0.09375;
            case CaelumConstants.ARMOR_SLOT_FEET:return 0.34375;
        }
        return 0;
    }

    static clearscope double ShieldAreaM(int kind)
    {
        switch(kind)
        {
            case CaelumConstants.SHIELD_TYPE_MAGIC:return 0.32;
            case CaelumConstants.SHIELD_TYPE_BUCKLER:return 0.25;
            case CaelumConstants.SHIELD_TYPE_KITE:return 0.54;
            case CaelumConstants.SHIELD_TYPE_TOWER:return 1.44;
        }
        return 0;
    }

    // Superficie exterior M aprobada; el tier no altera estas referencias.
    static clearscope double WeaponAreaM(int kind)
    {
        switch(kind)
        {
            case CaelumConstants.WEAPON_TYPE_DAGGER:return 0.04;
            case CaelumConstants.WEAPON_TYPE_HATCHET:return 0.10;
            case CaelumConstants.WEAPON_TYPE_MACHETE:return 0.12;
            case CaelumConstants.WEAPON_TYPE_SWORD:return 0.16;
            case CaelumConstants.WEAPON_TYPE_AXE:
            case CaelumConstants.WEAPON_TYPE_FLAIL:
            case CaelumConstants.WEAPON_TYPE_JAVELIN:return 0.18;
            case CaelumConstants.WEAPON_TYPE_GREATSWORD:return 0.24;
            case CaelumConstants.WEAPON_TYPE_SPEAR:
            case CaelumConstants.WEAPON_TYPE_CARBINE:
            case CaelumConstants.WEAPON_TYPE_SHOTGUN:
            case CaelumConstants.WEAPON_TYPE_SUPPORT_STATUETTE:
            case CaelumConstants.WEAPON_TYPE_EFFIGY:return 0.25;
            case CaelumConstants.WEAPON_TYPE_WAR_AXE:return 0.28;
            case CaelumConstants.WEAPON_TYPE_HALBERD:return 0.35;
            case CaelumConstants.WEAPON_TYPE_GIANT_GAUNTLETS:return 0.50;
            case CaelumConstants.WEAPON_TYPE_LONGBOW:
            case CaelumConstants.WEAPON_TYPE_PICKAXE:
            case CaelumConstants.WEAPON_TYPE_SCEPTER:
            case CaelumConstants.WEAPON_TYPE_BELL:
            case CaelumConstants.WEAPON_TYPE_SUPPORT_BOOK:
            case CaelumConstants.WEAPON_TYPE_CENSER:return 0.20;
            case CaelumConstants.WEAPON_TYPE_CROSSBOW:
            case CaelumConstants.WEAPON_TYPE_STAFF:
            case CaelumConstants.WEAPON_TYPE_UTILITY_STAFF:return 0.30;
            case CaelumConstants.WEAPON_TYPE_BOLAS:return 0.08;
            case CaelumConstants.WEAPON_TYPE_ORB:return 0.15;
        }
        return 0;
    }
}
