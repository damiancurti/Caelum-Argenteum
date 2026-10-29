// Generado desde chemistry_recipes.json; los valores requieren aprobación del autor.
class CaelumChemistryData : Object
{
    const REVISION=1;
    const FIRST_MATERIAL=92;
    const MATERIAL_COUNT=12;
    const FIRST_RECIPE=176;
    const RECIPE_COUNT=22;
    static clearscope bool IsRecipe(int id)
    {return CaelumHygieneData.IsChemistryRecipe(id) || (id>=FIRST_RECIPE && id<FIRST_RECIPE+RECIPE_COUNT);}
    static clearscope bool IsMaterial(int id)
    {return CaelumHygieneData.IsMaterial(id) || (id>=FIRST_MATERIAL && id<FIRST_MATERIAL+MATERIAL_COUNT);}
    static clearscope String MaterialKey(int id)
    {
        if(CaelumHygieneData.IsMaterial(id))return CaelumHygieneData.MaterialKey(id);
        switch(id)
        {
            case 92: return "CA_MATERIAL_SALTPETER";
            case 93: return "CA_MATERIAL_SULFUR";
            case 94: return "CA_MATERIAL_CHARCOAL";
            case 95: return "CA_MATERIAL_MOLASSES";
            case 96: return "CA_MATERIAL_FERMENTED_INTERMEDIATE";
            case 97: return "CA_MATERIAL_ALCOHOL";
            case 98: return "CA_MATERIAL_YEAST";
            case 99: return "CA_MATERIAL_SUGAR";
            case 100: return "CA_MATERIAL_GUNPOWDER";
            case 101: return "CA_MATERIAL_PREPARED_REAGENTS";
            case 102: return "CA_MATERIAL_SEALED_CARBINE_PARTS";
            case 103: return "CA_MATERIAL_SEALED_SHOTGUN_PARTS";
            default: return "";
        }
    }
    static clearscope String MaterialIcon(int id)
    {
        if(CaelumHygieneData.IsMaterial(id))return CaelumHygieneData.MaterialIcon(id);
        switch(id)
        {
            case 92: return "graphics/caelum/icons/materials/ca_material_saltpeter.png";
            case 93: return "graphics/caelum/icons/materials/ca_material_sulfur.png";
            case 94: return "graphics/caelum/icons/materials/ca_material_charcoal.png";
            case 95: return "graphics/caelum/icons/materials/ca_material_molasses.png";
            case 96: return "graphics/caelum/icons/materials/ca_material_fermented_intermediate.png";
            case 97: return "graphics/caelum/icons/materials/ca_material_alcohol.png";
            case 98: return "graphics/caelum/icons/materials/ca_material_yeast.png";
            case 99: return "graphics/caelum/icons/materials/ca_material_sugar.png";
            case 100: return "graphics/caelum/icons/materials/ca_material_gunpowder.png";
            case 101: return "graphics/caelum/icons/materials/ca_material_prepared_reagents.png";
            case 102: return "graphics/caelum/icons/materials/ca_material_sealed_carbine_parts.png";
            case 103: return "graphics/caelum/icons/materials/ca_material_sealed_shotgun_parts.png";
            default: return "";
        }
    }
    static clearscope double UnitWeight(int id)
    {
        if(CaelumHygieneData.IsMaterial(id))return CaelumHygieneData.UnitWeight(id);
        switch(id)
        {
            case 92: return 0.001;
            case 93: return 0.001;
            case 94: return 0.001;
            case 95: return 0.001;
            case 96: return 0.001;
            case 97: return 0.001;
            case 98: return 0.001;
            case 99: return 0.001;
            case 100: return 0.01;
            case 101: return 0.01;
            case 102: return 0.39;
            case 103: return 0.44;
            default: return CaelumConstants.MATERIAL_UNIT_WEIGHT;
        }
    }
    static clearscope String RecipeKey(int id)
    {
        if(CaelumHygieneData.IsChemistryRecipe(id))return CaelumHygieneData.RecipeKey(id);
        switch(id)
        {
            case 176: return "CA_CHEMISTRY_FERMENTATION";
            case 177: return "CA_CHEMISTRY_CHARCOAL";
            case 178: return "CA_CHEMISTRY_MOLASSES";
            case 179: return "CA_CHEMISTRY_ALCOHOL";
            case 180: return "CA_CHEMISTRY_GUNPOWDER_CHARGE";
            case 181: return "CA_CHEMISTRY_CARBINE_KITS";
            case 182: return "CA_CHEMISTRY_SHOTGUN_KITS";
            case 183: return "CA_CHEMISTRY_MEDIKIT_SMALL";
            case 184: return "CA_CHEMISTRY_MEDIKIT_MEDIUM";
            case 185: return "CA_CHEMISTRY_MEDIKIT_LARGE";
            case 186: return "CA_CHEMISTRY_ENERGY_HONEY_SMALL";
            case 187: return "CA_CHEMISTRY_ENERGY_HONEY_MEDIUM";
            case 188: return "CA_CHEMISTRY_ENERGY_HONEY_LARGE";
            case 189: return "CA_CHEMISTRY_ENERGY_SUGAR_SMALL";
            case 190: return "CA_CHEMISTRY_ENERGY_SUGAR_MEDIUM";
            case 191: return "CA_CHEMISTRY_ENERGY_SUGAR_LARGE";
            case 192: return "CA_CHEMISTRY_ANIMA_IRUPE_SMALL";
            case 193: return "CA_CHEMISTRY_ANIMA_IRUPE_MEDIUM";
            case 194: return "CA_CHEMISTRY_ANIMA_IRUPE_LARGE";
            case 195: return "CA_CHEMISTRY_ANIMA_LIRIO_SMALL";
            case 196: return "CA_CHEMISTRY_ANIMA_LIRIO_MEDIUM";
            case 197: return "CA_CHEMISTRY_ANIMA_LIRIO_LARGE";
            default: return "";
        }
    }
    static clearscope double Price(int id)
    {
        if(CaelumHygieneData.IsMaterial(id))return CaelumHygieneData.Price(id);
        switch(id)
        {
            case 92: return 5;
            case 93: return 5;
            case 98: return 0.05;
            case 99: return 0.02;
            case 101: return 20;
            case 102: return CaelumChemistryEconomy.LegacySealedSetValue(CaelumConstants.AMMUNITION_CARBINE);
            case 103: return CaelumChemistryEconomy.LegacySealedSetValue(CaelumConstants.AMMUNITION_SHOTGUN);
            default: return -1;
        }
    }
    static clearscope int ImportStock(int id)
    {
        if(CaelumHygieneData.IsMaterial(id))return CaelumHygieneData.ImportStock(id);
        switch(id)
        {
            case 92: return 1000;
            case 93: return 1000;
            case 98: return 100;
            case 99: return 1000;
            case 101: return CaelumCityData.AMMUNITION_STOCK;
            case 102: return CaelumCityData.AMMUNITION_STOCK;
            case 103: return CaelumCityData.AMMUNITION_STOCK;
            default: return 0;
        }
    }
    static clearscope bool IsFermentation(int id)
    {
        if(CaelumHygieneData.IsChemistryRecipe(id))return CaelumHygieneData.IsFermentation(id);
        switch(id)
        {
            case 176: return true;
            case 177: return false;
            case 178: return false;
            case 179: return false;
            case 180: return false;
            case 181: return false;
            case 182: return false;
            case 183: return false;
            case 184: return false;
            case 185: return false;
            case 186: return false;
            case 187: return false;
            case 188: return false;
            case 189: return false;
            case 190: return false;
            case 191: return false;
            case 192: return false;
            case 193: return false;
            case 194: return false;
            case 195: return false;
            case 196: return false;
            case 197: return false;
            default: return false;
        }
    }
    static clearscope bool UsesDexterity(int id)
    {
        if(CaelumHygieneData.IsChemistryRecipe(id))return CaelumHygieneData.UsesDexterity(id);
        switch(id)
        {
            case 176: return false;
            case 177: return false;
            case 178: return false;
            case 179: return false;
            case 180: return true;
            case 181: return true;
            case 182: return true;
            case 183: return true;
            case 184: return true;
            case 185: return true;
            case 186: return true;
            case 187: return true;
            case 188: return true;
            case 189: return true;
            case 190: return true;
            case 191: return true;
            case 192: return true;
            case 193: return true;
            case 194: return true;
            case 195: return true;
            case 196: return true;
            case 197: return true;
            default: return false;
        }
    }
    static clearscope int RecipeForMaterial(int id)
    {
        if(CaelumHygieneData.IsMaterial(id))return CaelumHygieneData.RecipeForMaterial(id);
        switch(id)
        {
            case 96: return 176;
            case 94: return 177;
            case 95: return 178;
            case 97: return 179;
            case 100: return 180;
            case 79: return 181;
            case 80: return 182;
            default: return -1;
        }
    }
    static clearscope int OutputMaterial(int id)
    {
        if(CaelumHygieneData.IsChemistryRecipe(id))return CaelumHygieneData.OutputMaterial(id);
        switch(id)
        {
            case 176: return 96;
            case 177: return 94;
            case 178: return 95;
            case 179: return 97;
            case 180: return 100;
            case 181: return 79;
            case 182: return 80;
            case 183: return -1;
            case 184: return -1;
            case 185: return -1;
            case 186: return -1;
            case 187: return -1;
            case 188: return -1;
            case 189: return -1;
            case 190: return -1;
            case 191: return -1;
            case 192: return -1;
            case 193: return -1;
            case 194: return -1;
            case 195: return -1;
            case 196: return -1;
            case 197: return -1;
            default: return -1;
        }
    }
    static clearscope int OutputConsumable(int id)
    {
        if(CaelumHygieneData.IsChemistryRecipe(id))return CaelumHygieneData.OutputConsumable(id);
        switch(id)
        {
            case 176: return -1;
            case 177: return -1;
            case 178: return -1;
            case 179: return -1;
            case 180: return -1;
            case 181: return -1;
            case 182: return -1;
            case 183: return 0;
            case 184: return 11;
            case 185: return 14;
            case 186: return 2;
            case 187: return 13;
            case 188: return 16;
            case 189: return 2;
            case 190: return 13;
            case 191: return 16;
            case 192: return 1;
            case 193: return 12;
            case 194: return 15;
            case 195: return 1;
            case 196: return 12;
            case 197: return 15;
            default: return -1;
        }
    }
    static clearscope int OutputUnits(int id)
    {
        if(CaelumHygieneData.IsChemistryRecipe(id))return CaelumHygieneData.OutputUnits(id);
        switch(id)
        {
            case 176: return 1000;
            case 177: return 250;
            case 178: return 100;
            case 179: return 100;
            case 180: return 1;
            case 181: return 10;
            case 182: return 10;
            case 183: return 1;
            case 184: return 1;
            case 185: return 1;
            case 186: return 1;
            case 187: return 1;
            case 188: return 1;
            case 189: return 1;
            case 190: return 1;
            case 191: return 1;
            case 192: return 1;
            case 193: return 1;
            case 194: return 1;
            case 195: return 1;
            case 196: return 1;
            case 197: return 1;
            default: return 0;
        }
    }
    static clearscope double WaterLiters(int id)
    {
        if(CaelumHygieneData.IsChemistryRecipe(id))return CaelumHygieneData.WaterLiters(id);
        switch(id)
        {
            case 176: return 0.8;
            case 177: return 0;
            case 178: return 0;
            case 179: return 0;
            case 180: return 0;
            case 181: return 0;
            case 182: return 0;
            case 183: return 0;
            case 184: return 0;
            case 185: return 0;
            case 186: return 0.2;
            case 187: return 0.2;
            case 188: return 0.2;
            case 189: return 0.2;
            case 190: return 0.2;
            case 191: return 0.2;
            case 192: return 0.2;
            case 193: return 0.2;
            case 194: return 0.2;
            case 195: return 0.2;
            case 196: return 0.2;
            case 197: return 0.2;
            default: return 0;
        }
    }
    static clearscope double WorkingLiters(int id)
    {
        if(CaelumHygieneData.IsChemistryRecipe(id))return CaelumHygieneData.WorkingLiters(id);
        switch(id)
        {
            case 176: return 1.0;
            case 177: return 0;
            case 178: return 0;
            case 179: return 0;
            case 180: return 0;
            case 181: return 0;
            case 182: return 0;
            case 183: return 0;
            case 184: return 0;
            case 185: return 0;
            case 186: return 0;
            case 187: return 0;
            case 188: return 0;
            case 189: return 0;
            case 190: return 0;
            case 191: return 0;
            case 192: return 0;
            case 193: return 0;
            case 194: return 0;
            case 195: return 0;
            case 196: return 0;
            case 197: return 0;
            default: return 0;
        }
    }
    static clearscope double Seconds(int id)
    {
        if(CaelumHygieneData.IsChemistryRecipe(id))return CaelumHygieneData.Seconds(id);
        switch(id)
        {
            case 176: return 259200;
            case 177: return 86400;
            case 178: return 1200;
            case 179: return 1800;
            case 180: return 600;
            case 181: return 600;
            case 182: return 600;
            case 183: return 600;
            case 184: return 600;
            case 185: return 600;
            case 186: return 600;
            case 187: return 600;
            case 188: return 600;
            case 189: return 600;
            case 190: return 600;
            case 191: return 600;
            case 192: return 600;
            case 193: return 600;
            case 194: return 600;
            case 195: return 600;
            case 196: return 600;
            case 197: return 600;
            default: return 0;
        }
    }
    static clearscope int InputMaterial(int id,int slot)
    {
        if(CaelumHygieneData.IsChemistryRecipe(id))return CaelumHygieneData.InputMaterial(id,slot);
        if(id==176 && slot==0)return 95;
        if(id==176 && slot==1)return 98;
        if(id==177 && slot==0)return 42;
        if(id==178 && slot==0)return 85;
        if(id==178 && slot==1)return 61;
        if(id==179 && slot==0)return 96;
        if(id==179 && slot==1)return 61;
        if(id==180 && slot==0)return 101;
        if(id==181 && slot==0)return 100;
        if(id==181 && slot==1)return 102;
        if(id==182 && slot==0)return 100;
        if(id==182 && slot==1)return 103;
        if(id==183 && slot==0)return 72;
        if(id==183 && slot==1)return 97;
        if(id==183 && slot==2)return 82;
        if(id==184 && slot==0)return 72;
        if(id==184 && slot==1)return 97;
        if(id==184 && slot==2)return 82;
        if(id==185 && slot==0)return 72;
        if(id==185 && slot==1)return 97;
        if(id==185 && slot==2)return 82;
        if(id==186 && slot==0)return 81;
        if(id==186 && slot==1)return 86;
        if(id==187 && slot==0)return 81;
        if(id==187 && slot==1)return 86;
        if(id==188 && slot==0)return 81;
        if(id==188 && slot==1)return 86;
        if(id==189 && slot==0)return 81;
        if(id==189 && slot==1)return 99;
        if(id==190 && slot==0)return 81;
        if(id==190 && slot==1)return 99;
        if(id==191 && slot==0)return 81;
        if(id==191 && slot==1)return 99;
        if(id==192 && slot==0)return 83;
        if(id==193 && slot==0)return 83;
        if(id==194 && slot==0)return 83;
        if(id==195 && slot==0)return 84;
        if(id==196 && slot==0)return 84;
        if(id==197 && slot==0)return 84;
        return -1;
    }
    static clearscope int InputUnits(int id,int slot)
    {
        if(CaelumHygieneData.IsChemistryRecipe(id))return CaelumHygieneData.InputUnits(id,slot);
        if(id==176 && slot==0)return 250;
        if(id==176 && slot==1)return 5;
        if(id==177 && slot==0)return 1000;
        if(id==178 && slot==0)return 1000;
        if(id==178 && slot==1)return 172;
        if(id==179 && slot==0)return 1000;
        if(id==179 && slot==1)return 258;
        if(id==180 && slot==0)return 1;
        if(id==181 && slot==0)return 1;
        if(id==181 && slot==1)return 1;
        if(id==182 && slot==0)return 1;
        if(id==182 && slot==1)return 1;
        if(id==183 && slot==0)return 5;
        if(id==183 && slot==1)return 10;
        if(id==183 && slot==2)return 2;
        if(id==184 && slot==0)return 12;
        if(id==184 && slot==1)return 23;
        if(id==184 && slot==2)return 5;
        if(id==185 && slot==0)return 25;
        if(id==185 && slot==1)return 50;
        if(id==185 && slot==2)return 10;
        if(id==186 && slot==0)return 10;
        if(id==186 && slot==1)return 20;
        if(id==187 && slot==0)return 23;
        if(id==187 && slot==1)return 20;
        if(id==188 && slot==0)return 50;
        if(id==188 && slot==1)return 20;
        if(id==189 && slot==0)return 10;
        if(id==189 && slot==1)return 20;
        if(id==190 && slot==0)return 23;
        if(id==190 && slot==1)return 20;
        if(id==191 && slot==0)return 50;
        if(id==191 && slot==1)return 20;
        if(id==192 && slot==0)return 2;
        if(id==193 && slot==0)return 5;
        if(id==194 && slot==0)return 10;
        if(id==195 && slot==0)return 2;
        if(id==196 && slot==0)return 5;
        if(id==197 && slot==0)return 10;
        return 0;
    }
}
