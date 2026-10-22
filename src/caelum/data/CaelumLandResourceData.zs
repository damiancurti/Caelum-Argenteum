// Generado desde resource_catalog.json y land_resources.json (#405).
class CaelumLandResourceData : Object
{
    const REVISION=1;
    const FIRST_MATERIAL=81;
    const LAST_MATERIAL=86;
    const PROFILE_COUNT=7;
    const PLACEMENT_COUNT=11;
    const IMPORT_COUNT=4;
    const HARDNESS=2.5;
    const ABUNDANCE=1.0;
    const HONEY_PER_USE=50;
    const IMPORT_RECOVERY_PER_DAY=0.001;
    static clearscope int Material(int index)
    {
        switch(index)
        {
            case 0: return 81;
            case 1: return 82;
            case 2: return 83;
            case 3: return 84;
            case 4: return 85;
            case 5: return 72;
            case 6: return 86;
            default: return -1;
        }
    }
    static clearscope double Capacity(int index)
    {
        switch(index)
        {
            case 0: return 250;
            case 1: return 50;
            case 2: return 10;
            case 3: return 10;
            case 4: return 5000;
            case 5: return 250;
            case 6: return 500;
            default: return 0;
        }
    }
    static clearscope bool IsHive(int index)
    {
        switch(index)
        {
            case 6: return true;
            default: return false;
        }
    }
    static clearscope double Price(int index)
    {
        switch(index)
        {
            case 81: return 0.02;
            case 82: return 0.1;
            case 83: return 0.5;
            case 84: return 0.5;
            case 85: return 0.01;
            case 86: return 0.02;
            default: return -1;
        }
    }
    static clearscope String MaterialKey(int index)
    {
        switch(index)
        {
            case 81: return "CA_MATERIAL_YERBA_MATE";
            case 82: return "CA_MATERIAL_MARCELA";
            case 83: return "CA_MATERIAL_IRUPE_FLOWER";
            case 84: return "CA_MATERIAL_CYPELLA_FLOWER";
            case 85: return "CA_MATERIAL_SUGARCANE";
            case 86: return "CA_MATERIAL_HONEY";
            default: return "";
        }
    }
    static clearscope String MaterialIcon(int index)
    {
        switch(index)
        {
            case 81: return "graphics/caelum/icons/materials/ca_material_plant_fiber.png";
            case 82: return "graphics/caelum/icons/materials/ca_material_plant_fiber.png";
            case 83: return "graphics/caelum/icons/materials/ca_material_plant_fiber.png";
            case 84: return "graphics/caelum/icons/materials/ca_material_plant_fiber.png";
            case 85: return "graphics/caelum/icons/materials/ca_material_wood.png";
            case 86: return "graphics/caelum/icons/materials/ca_material_plant_fiber.png";
            default: return "";
        }
    }
    static clearscope String MaterialSprite(int index)
    {
        switch(index)
        {
            case 81: return "M081";
            case 82: return "M082";
            case 83: return "M083";
            case 84: return "M084";
            case 85: return "M085";
            case 86: return "M086";
            default: return "";
        }
    }
    static clearscope int ImportMaterial(int index)
    {
        switch(index)
        {
            case 0: return 81;
            case 1: return 83;
            case 2: return 85;
            case 3: return 72;
            default: return -1;
        }
    }
    static clearscope int ImportTarget(int index)
    {
        switch(index)
        {
            case 0: return 1000;
            case 1: return 20;
            case 2: return 10000;
            case 3: return 1000;
            default: return 0;
        }
    }
    static clearscope int ImportCategory(int index)
    {
        switch(index)
        {
            case 0: return 0;
            case 1: return 0;
            case 2: return 0;
            case 3: return 7;
            default: return -1;
        }
    }
    static clearscope String Map(int index)
    {
        switch(index)
        {
            case 0: return "MAP03";
            case 1: return "MAP03";
            case 2: return "MAP03";
            case 3: return "MAP03";
            case 4: return "MAP03";
            case 5: return "MAP03";
            case 6: return "MAP03";
            case 7: return "MAP01";
            case 8: return "MAP01";
            case 9: return "MAP01";
            case 10: return "MAP01";
            default: return "";
        }
    }
    static clearscope int PlacementId(int index)
    {
        switch(index)
        {
            case 0: return 1;
            case 1: return 2;
            case 2: return 3;
            case 3: return 4;
            case 4: return 5;
            case 5: return 6;
            case 6: return 7;
            case 7: return 8;
            case 8: return 9;
            case 9: return 10;
            case 10: return 11;
            default: return 0;
        }
    }
    static clearscope Vector3 Position(int index)
    {
        switch(index)
        {
            case 0: return (-30272,320,0);
            case 1: return (-30144,448,0);
            case 2: return (-30336,1216,0);
            case 3: return (-30144,2112,0);
            case 4: return (-30080,1280,0);
            case 5: return (-30080,1920,0);
            case 6: return (-30464,1536,0);
            case 7: return (-1856,832,0);
            case 8: return (-1664,864,0);
            case 9: return (-2016,1024,0);
            case 10: return (-1792,1056,0);
            default: return (0,0,0);
        }
    }
    static clearscope Name PlacementClass(int index)
    {
        switch(index)
        {
            case 0: return 'CaelumSourceMarcela';
            case 1: return 'CaelumSourceMarcela';
            case 2: return 'CaelumSourceMarcela';
            case 3: return 'CaelumSourceMarcela';
            case 4: return 'CaelumSourceCypellaFlower';
            case 5: return 'CaelumSourceCypellaFlower';
            case 6: return 'CaelumSourceHoney';
            case 7: return 'CaelumSourceMarcelaDecoration';
            case 8: return 'CaelumSourceMarcelaDecoration';
            case 9: return 'CaelumSourceCypellaFlowerDecoration';
            case 10: return 'CaelumSourceHoneyDecoration';
            default: return 'None';
        }
    }
}
