// Generado desde assets/generators/marine_resources.json (#407).
class CaelumMarineData : Object
{
    const REVISION = 1;
    const FIRST_MATERIAL = 87;
    const LAST_MATERIAL = 88;
    const IODINE_RECIPE = 168;
    const INPUT_GRAMS = 100;
    const OUTPUT_GRAMS = 1;
    const WORK_SECONDS = 60;
    const IMPORT_CATEGORY = 0;
    const IMPORT_GRAMS = 1000;
    const IMPORT_RECOVERY_PER_DAY = 0.001;
    static double Price(int material)
    {
        switch(material)
        {
            case 87: return 0.05;
            case 88: return 10;
        }
        return -1;
    }
    static String MaterialKey(int material)
    {
        switch(material)
        {
            case 87: return "CA_MATERIAL_DRIED_KELP";
            case 88: return "CA_MATERIAL_IODINE";
        }
        return "";
    }
    static clearscope String MaterialIcon(int material)
    {
        switch(material)
        {
            case 87: return "graphics/caelum/icons/materials/ca_material_plant_fiber.png";
            case 88: return "graphics/caelum/icons/materials/ca_material_iodine.png";
        }
        return "";
    }
}
