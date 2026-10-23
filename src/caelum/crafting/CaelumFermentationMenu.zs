// La selección pertenece al jugador; el lote y su generación pertenecen al barril.
class CaelumFermentationMenu : Object play
{
    int Liters, Units, DiscardGeneration;
    double Now;
    bool ConfirmDiscard;
    String Status;

    static CaelumFermentationMenu Get(CaelumPlayer user)
    {
        if(user.FermentationMenu==null)
        {
            user.FermentationMenu=new("CaelumFermentationMenu");
            user.FermentationMenu.Liters=1;user.FermentationMenu.Units=1;
        }
        user.FermentationMenu.Now=CaelumFermentationService.Now(user);
        return user.FermentationMenu;
    }

    static clearscope bool Active(CaelumPlayer user)
    {return user.CraftingMenuOpen && user.FermentationMenu!=null
        && CaelumFermentationStation(user.ActiveCraftingStationActor)!=null;}

    static void Act(CaelumPlayer user, int command, int amount, int generation)
    {
        if(!Active(user))return;
        let barrel=CaelumFermentationStation(user.ActiveCraftingStationActor);
        if(!CaelumFermentationService.Reachable(user,barrel))return;
        let batch=CaelumFermentationService.Bind(user,barrel);
        if(batch==null || batch.Generation!=generation)return;
        let menu=Get(user);
        if(command==3)
        {
            if(batch.Occupied)menu.Units=amount>0?Max(1,batch.RemainingUnits):1;
            else menu.Liters=amount>0?CaelumFermentationData.WORKING_CAPACITY_LITERS:1;
            menu.ConfirmDiscard=false;menu.Status="";return;
        }
        if(command==0)
        {
            // El cliente propone un delta, nunca cantidades ni estados finales.
            int delta=Clamp(amount,-100,100);
            if(batch.Occupied)menu.Units=Clamp(menu.Units+delta,1,Max(1,batch.RemainingUnits));
            else menu.Liters=Clamp(menu.Liters+delta,1,CaelumFermentationData.WORKING_CAPACITY_LITERS);
            menu.ConfirmDiscard=false;menu.Status="";return;
        }
        if(command==1)
        {
            bool ok=batch.Occupied
                ? CaelumFermentationService.Withdraw(user,barrel,menu.Units)
                : CaelumFermentationService.Begin(user,barrel,menu.Liters);
            menu.Status=ok?"CA_FERMENT_ACTION_OK":"CA_FERMENT_ACTION_REJECTED";
            menu.ConfirmDiscard=false;
            menu.Units=Clamp(menu.Units,1,Max(1,batch.RemainingUnits));
        }
        else if(command==2 && batch.Occupied)
        {
            if(menu.ConfirmDiscard && menu.DiscardGeneration==batch.Generation)
            {
                bool ok=CaelumFermentationService.Discard(user,barrel);
                menu.Status=ok?"CA_FERMENT_DISCARDED":"CA_FERMENT_ACTION_REJECTED";
                menu.ConfirmDiscard=false;
            }
            else {menu.ConfirmDiscard=true;menu.DiscardGeneration=batch.Generation;}
        }
    }
}
