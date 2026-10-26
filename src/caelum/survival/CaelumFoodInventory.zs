// #410: Amount conserva la autoridad; el libro sólo describe esas unidades.
// Todas las divisiones y fusiones pasan por la misma transferencia de lotes.
class CaelumFoodInventory : Object play
{
    static bool IsFood(Inventory item)
    {let food=CaelumConsumableItem(item);return food!=null && food.GetConsumableType()==CaelumConstants.CONSUMABLE_FOOD_RATION;}

    static double Stamp(Inventory item)
    {
        let user=CaelumPlayer(item.Owner);
        let world=CaelumThermalWorld.Get();
        let clock=user!=null?CaelumWorldClock.Get(user):world!=null?world.ReferenceClock:null;
        return CaelumThermalRuntime.Stamp(clock);
    }

    static CaelumFoodLots Prepare(Inventory item)
    {
        if(!IsFood(item))return null;
        let food=CaelumConsumableItem(item);
        if(food.FoodLots==null)food.FoodLots=new('CaelumFoodLots');
        food.FoodLots.Ensure(CaelumFoodData.RATION,Max(0,item.Amount),Stamp(item));
        return food.FoodLots;
    }

    // Altas/bajas nativas externas (regalos, reposición y migración) se resuelven
    // antes de la operación siguiente; las transferencias nunca usan este ajuste.
    static void Reconcile(Inventory item)
    {
        let clock=CaelumFoodClock.Get(CaelumConsumableItem(item));
        if(clock!=null)clock.Advance();
        let lots=Prepare(item);if(lots==null)return;
        int missing=Max(0,item.Amount)-lots.Units();
        if(missing>0)lots.Add(missing,0,Stamp(item));
        else if(missing<0){double ignored;lots.Consume(-missing,ignored);}
    }

    static bool Transfer(Inventory source,Inventory target,int count,bool emptyTarget=false)
    {
        if(!IsFood(source))return true;
        let from=Prepare(source);let to=CaelumConsumableItem(target);
        if(to==null || !IsFood(target) || source==target)return source==target;
        if(emptyTarget){to.FoodLots=new('CaelumFoodLots');to.FoodLots.Ensure(from.Kind,0,Stamp(source));}
        else Prepare(target);
        bool moved=from.TransferTo(to.FoodLots,count);
        if(moved && emptyTarget)
        {
            let sourceClock=CaelumFoodClock.Get(CaelumConsumableItem(source));
            let targetClock=CaelumFoodClock.Get(to);
            targetClock.Ready=sourceClock.Ready;targetClock.Stamp=sourceClock.Stamp;
            targetClock.Climate=sourceClock.Climate!=null?sourceClock.Climate.Copy():null;
        }
        return moved;
    }

    static void Relocate(Inventory item)
    {
        if(item==null || item.bDestroyed)return;
        let clock=CaelumFoodClock.Get(CaelumConsumableItem(item));if(clock!=null)clock.Advance();
    }

    static bool Remove(Inventory item,int count)
    {
        let lots=Prepare(item);if(lots==null)return true;
        double ignored;return lots.Consume(count,ignored);
    }

    static bool CanSell(Inventory item)
    {
        if(!IsFood(item))return true;
        Reconcile(item);let lots=Prepare(item);
        // La oferta de una pila no puede ocultar lotes posteriores más sucios.
        for(int i=0;i<lots.Lots.Size();i++)if(lots.Contamination(i)>0)return false;
        return true;
    }

    static void Ingest(CaelumConsumableItem food)
    {
        let lots=Prepare(food);if(lots==null)return;
        double contamination;
        if(lots.Consume(1,contamination))
            CaelumFoodIllness.Ingest(CaelumPlayer(food.Owner),contamination,food.GetUnitWeight()*1000);
    }
}
