// #386: catálogo aprobado; índices anexos, sin materiales nuevos.
class CaelumClothingData : Object
{
    const COUNT=25;
    const FIRST_RECIPE=141;
    const THERMAL_FIRST=16;
    const MIGRATION_REVISION=1;
    static clearscope String Icon(int type)
    {return String.Format("graphics/caelum/icons/clothing/ca_clothing_%02d.png",Clamp(type,0,COUNT-1));}
    static clearscope String SpriteName(int type)
    {return String.Format("WC%02d",Clamp(type,0,COUNT-1));}
    static clearscope bool IsRecipe(int recipe)
    {return recipe>=FIRST_RECIPE && recipe<FIRST_RECIPE+COUNT;}
    const F=0;
    const FW=1;
    const CS=2;
    const CE=3;
    const CW=4;
    const RS=5;
    const RE=6;
    const RW=7;
    const PS=8;
    const PE=9;
    const PW=10;
    const HF=11;
    const HC=12;
    const HR=13;
    const HW=14;
    const HP=15;
    const GF=16;
    const GC=17;
    const GW=18;
    const GP=19;
    const BF=20;
    const BC=21;
    const BR=22;
    const BS=23;
    const BP=24;
    static clearscope int Region(int type)
    {
        switch(type)
        {
            case 0: return 1;
            case 1: return 1;
            case 2: return 1;
            case 3: return 1;
            case 4: return 1;
            case 5: return 1;
            case 6: return 1;
            case 7: return 1;
            case 8: return 1;
            case 9: return 1;
            case 10: return 1;
            case 11: return 0;
            case 12: return 0;
            case 13: return 0;
            case 14: return 0;
            case 15: return 0;
            case 16: return 2;
            case 17: return 2;
            case 18: return 2;
            case 19: return 2;
            case 20: return 3;
            case 21: return 3;
            case 22: return 3;
            case 23: return 3;
            case 24: return 3;
            default: return 1;
        }
    }
    static clearscope String NameKey(int type)
    {
        switch(type)
        {
            case 0: return "CA_CLOTHING_F";
            case 1: return "CA_CLOTHING_FW";
            case 2: return "CA_CLOTHING_CS";
            case 3: return "CA_CLOTHING_CE";
            case 4: return "CA_CLOTHING_CW";
            case 5: return "CA_CLOTHING_RS";
            case 6: return "CA_CLOTHING_RE";
            case 7: return "CA_CLOTHING_RW";
            case 8: return "CA_CLOTHING_PS";
            case 9: return "CA_CLOTHING_PE";
            case 10: return "CA_CLOTHING_PW";
            case 11: return "CA_CLOTHING_HF";
            case 12: return "CA_CLOTHING_HC";
            case 13: return "CA_CLOTHING_HR";
            case 14: return "CA_CLOTHING_HW";
            case 15: return "CA_CLOTHING_HP";
            case 16: return "CA_CLOTHING_GF";
            case 17: return "CA_CLOTHING_GC";
            case 18: return "CA_CLOTHING_GW";
            case 19: return "CA_CLOTHING_GP";
            case 20: return "CA_CLOTHING_BF";
            case 21: return "CA_CLOTHING_BC";
            case 22: return "CA_CLOTHING_BR";
            case 23: return "CA_CLOTHING_BS";
            case 24: return "CA_CLOTHING_BP";
            default: return "CA_EQUIPMENT_CATEGORY_CLOTHING";
        }
    }
    static clearscope double Clo(int type)
    {
        switch(type)
        {
            case 0: return 0.75;
            case 1: return 1;
            case 2: return 0.5;
            case 3: return 0.75;
            case 4: return 1;
            case 5: return 0.5;
            case 6: return 0.75;
            case 7: return 1;
            case 8: return 0.4;
            case 9: return 0.6;
            case 10: return 0.8;
            case 11: return 0.75;
            case 12: return 0.5;
            case 13: return 0.5;
            case 14: return 1;
            case 15: return 0.4;
            case 16: return 0.5;
            case 17: return 0.5;
            case 18: return 1;
            case 19: return 0.8;
            case 20: return 1.2;
            case 21: return 1.2;
            case 22: return 1.2;
            case 23: return 0.5;
            case 24: return 0.4;
            default: return 0;
        }
    }
    static clearscope int Complexity(int type)
    {
        switch(type)
        {
            case 0: return 4;
            case 1: return 4;
            case 2: return 3;
            case 3: return 3;
            case 4: return 3;
            case 5: return 3;
            case 6: return 3;
            case 7: return 3;
            case 8: return 2;
            case 9: return 2;
            case 10: return 2;
            case 11: return 4;
            case 12: return 3;
            case 13: return 3;
            case 14: return 2;
            case 15: return 2;
            case 16: return 4;
            case 17: return 2;
            case 18: return 2;
            case 19: return 2;
            case 20: return 4;
            case 21: return 3;
            case 22: return 3;
            case 23: return 2;
            case 24: return 2;
            default: return 2;
        }
    }
    // Hasta tres insumos por prenda, ordenados W/C/S/L/R.
    static clearscope int InputIndex(int type,int input)
    {
        switch(type)
        {
            case 0: return input==0 ? 0 : input==1 ? 1 : input==2 ? 2 : -1;
            case 1: return input==0 ? 0 : input==1 ? 1 : input==2 ? 2 : -1;
            case 2: return input==0 ? 0 : input==1 ? 1 : -1;
            case 3: return input==0 ? 0 : input==1 ? 1 : -1;
            case 4: return input==0 ? 0 : input==1 ? 1 : -1;
            case 5: return input==0 ? 1 : input==1 ? 3 : -1;
            case 6: return input==0 ? 0 : input==1 ? 1 : input==2 ? 3 : -1;
            case 7: return input==0 ? 0 : input==1 ? 1 : input==2 ? 3 : -1;
            case 8: return input==0 ? 0 : input==1 ? 1 : -1;
            case 9: return input==0 ? 0 : input==1 ? 1 : -1;
            case 10: return input==0 ? 0 : input==1 ? 1 : -1;
            case 11: return input==0 ? 0 : input==1 ? 2 : -1;
            case 12: return input==0 ? 1 : -1;
            case 13: return input==0 ? 0 : input==1 ? 3 : -1;
            case 14: return input==0 ? 0 : -1;
            case 15: return input==0 ? 0 : -1;
            case 16: return input==0 ? 1 : input==1 ? 2 : -1;
            case 17: return input==0 ? 1 : -1;
            case 18: return input==0 ? 0 : -1;
            case 19: return input==0 ? 0 : -1;
            case 20: return input==0 ? 1 : input==1 ? 3 : -1;
            case 21: return input==0 ? 1 : input==1 ? 3 : -1;
            case 22: return input==0 ? 1 : input==1 ? 3 : -1;
            case 23: return input==0 ? 1 : input==1 ? 4 : -1;
            case 24: return input==0 ? 0 : input==1 ? 4 : -1;
            default: return -1;
        }
    }
    static clearscope int Material(int type,int input)
    {
        int index=InputIndex(type,input);
        return index==3 ? CaelumConstants.MATERIAL_LEATHER : index==4 ? CaelumConstants.MATERIAL_ROPE : CaelumConstants.MATERIAL_FABRIC;
    }
    static clearscope int MaterialTier(int type,int input)
    {int index=InputIndex(type,input);return index>=0 && index<3 ? index+1 : 1;}
    static clearscope int MediumGrams(int type,int input)
    {
        switch(type)
        {
            case 0: return input==0 ? 1200 : input==1 ? 500 : input==2 ? 100 : 0;
            case 1: return input==0 ? 2800 : input==1 ? 500 : input==2 ? 100 : 0;
            case 2: return input==0 ? 50 : input==1 ? 950 : 0;
            case 3: return input==0 ? 850 : input==1 ? 900 : 0;
            case 4: return input==0 ? 1900 : input==1 ? 600 : 0;
            case 5: return input==0 ? 1100 : input==1 ? 150 : 0;
            case 6: return input==0 ? 800 : input==1 ? 1000 : input==2 ? 200 : 0;
            case 7: return input==0 ? 2200 : input==1 ? 800 : input==2 ? 250 : 0;
            case 8: return input==0 ? 600 : input==1 ? 200 : 0;
            case 9: return input==0 ? 1200 : input==1 ? 200 : 0;
            case 10: return input==0 ? 1800 : input==1 ? 200 : 0;
            case 11: return input==0 ? 125 : input==1 ? 25 : 0;
            case 12: return input==0 ? 100 : 0;
            case 13: return input==0 ? 150 : input==1 ? 30 : 0;
            case 14: return input==0 ? 140 : 0;
            case 15: return input==0 ? 80 : 0;
            case 16: return input==0 ? 60 : input==1 ? 20 : 0;
            case 17: return input==0 ? 60 : 0;
            case 18: return input==0 ? 120 : 0;
            case 19: return input==0 ? 100 : 0;
            case 20: return input==0 ? 20 : input==1 ? 880 : 0;
            case 21: return input==0 ? 100 : input==1 ? 1000 : 0;
            case 22: return input==0 ? 50 : input==1 ? 1450 : 0;
            case 23: return input==0 ? 200 : input==1 ? 400 : 0;
            case 24: return input==0 ? 200 : input==1 ? 300 : 0;
            default: return 0;
        }
    }
    static clearscope int Units(int type,int size,int input)
    {return CaelumCraftingRules.GetRoundedMaterialUnits(MediumGrams(type,input)/1000.0*CaelumEquipmentRules.GetSizeWeightMultiplier(size),1.0);}
    static clearscope double Weight(int type,int size)
    {return (Units(type,size,0)+Units(type,size,1)+Units(type,size,2))/1000.0;}
    static clearscope double Value(int type,int size)
    {
        double value=0;
        for(int i=0;i<3;i++)value+=Units(type,size,i)*CaelumEconomyRules.GetMaterialUnitBaseValue(Material(type,i),MaterialTier(type,i));
        return CaelumEconomyRules.ApplyMarkup(value,CaelumEconomyRules.GetManufacturingMarkupPercent(1));
    }
    static clearscope double ValueForWeight(int type,double weight)
    {
        for(int size=0;size<CaelumConstants.EQUIPMENT_SIZE_COUNT;size++)
            if(Abs(Weight(type,size)-weight)<0.0001)return Value(type,size);
        return 0;
    }
    static clearscope double ClothBlend(int type){return Clamp((Clo(type)-0.5)/0.5,0.0,1.0);}
    static clearscope double Permeability(int type)
    {return type>=BF && type<=BR ? 0.45 : 0.90-0.15*ClothBlend(type);}
    static clearscope double Capacity(int type)
    {return type>=BF && type<=BR ? 0.346983535001855 : 0.192336119324285+(0.332367940848569-0.192336119324285)*ClothBlend(type);}
    static clearscope int Initial(int slot)
    {return slot==0 ? HC : slot==1 ? CS : slot==2 ? GC : BS;}
}
