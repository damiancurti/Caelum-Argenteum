// #502: datos aprobados, separados de los intervalos históricos de Química.
class CaelumHygieneData : Object
{
    const REVISION=1;
    const FAT=105;
    const SODA=106;
    const SOAP=107;
    const SOAP_RECIPE=203;
    const CLOTH_RECIPE=204;
    const CLOTH_KEY=13;
    const RECIPE_COUNT=2;
    const CLOTH_GRAMS=100;
    const CLOTH_KG=0.1;
    const CLOTH_STOCK=20;
    const SOAP_STOCK=3000;
    const BOOK_STOCK=10;
    static clearscope bool IsMaterial(int id){return id>=FAT && id<=SOAP;}
    static clearscope bool IsChemistryRecipe(int id){return id==SOAP_RECIPE;}
    static clearscope String MaterialKey(int id)
    {return id==FAT?"CA_HYGIENE_FAT":id==SODA?"CA_HYGIENE_SODA":"CA_HYGIENE_SOAP";}
    static clearscope String MaterialIcon(int id)
    {return id==FAT?"graphics/caelum/icons/hygiene/fat.png":id==SODA?"graphics/caelum/icons/hygiene/soda.png":"graphics/caelum/icons/hygiene/soap.png";}
    static clearscope double UnitWeight(int id){return 0.001;}
    static clearscope double Price(int id){return id==FAT?0.04:id==SODA?0.05:-1;}
    static clearscope int ImportStock(int id){return id==FAT?10000:id==SODA?1000:0;}
    static clearscope int RecipeForMaterial(int id){return id==SOAP?SOAP_RECIPE:-1;}
    static clearscope String RecipeKey(int id){return "CA_HYGIENE_MAKE_SOAP";}
    static clearscope bool IsFermentation(int id){return false;}
    static clearscope bool UsesDexterity(int id){return false;}
    static clearscope int OutputMaterial(int id){return SOAP;}
    static clearscope int OutputConsumable(int id){return -1;}
    static clearscope int OutputUnits(int id){return 1000;}
    static clearscope double WaterLiters(int id){return 0.3;}
    static clearscope double WorkingLiters(int id){return 0;}
    static clearscope double Seconds(int id){return 7200;}
    static clearscope int InputMaterial(int id,int slot)
    {return slot==0?FAT:slot==1?SODA:slot==2?CaelumConstants.MATERIAL_COAL:-1;}
    static clearscope int InputUnits(int id,int slot)
    {return slot==0?1000:slot==1?135:slot==2?2058:0;}
}
