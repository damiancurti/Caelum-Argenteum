// El gramo abierto conserva su fracción útil en el personaje, sin cobrarla otra vez.
class CaelumSoapSupply : Inventory
{
    int Revision;
    double RemainderG;
    static clearscope CaelumSoapSupply Find(CaelumPlayer user)
    {return user==null?null:CaelumSoapSupply(user.FindInventory('CaelumSoapSupply'));}
    static clearscope double Credit(CaelumPlayer user)
    {let stock=Find(user);return stock==null?0:stock.RemainderG;}
    static double Available(CaelumPlayer user)
    {return user==null?0:Credit(user)+user.CountCraftingMaterial(CaelumHygieneData.SOAP,1);}
    static bool Spend(CaelumPlayer user,double grams)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || grams<0 || grams>Available(user)+0.000000001)return false;
        if(grams==0)return true;
        let stock=Find(user);if(stock==null)stock=CaelumSoapSupply(user.GiveInventoryType('CaelumSoapSupply'));
        if(stock==null)return false;
        int whole=int(Ceil(Max(0.0,grams-stock.RemainderG)-0.000000001));
        if(whole>0 && !user.ConsumeCraftingMaterial(CaelumHygieneData.SOAP,1,whole))return false;
        stock.Revision=1;stock.RemainderG=Max(0.0,stock.RemainderG+whole-grams);
        return true;
    }
    Default {Inventory.Amount 1;Inventory.MaxAmount 1;Inventory.InterHubAmount 1;
        +INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE +INVENTORY.KEEPDEPLETED -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
