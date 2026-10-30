// #410: Amount conserva la autoridad; el libro sólo describe esas unidades.
// Todas las divisiones y fusiones pasan por la misma transferencia de lotes.
class CaelumFoodInventory : Object play
{
    static bool IsFood(Inventory item)
    {return Kind(item)>=0;}
    static int Kind(Inventory item)
    {
        let material=CaelumMaterialPickup(item);
        if(material!=null)return CaelumKitchenData.FoodKind(material.GetSpecialType());
        let food=CaelumConsumableItem(item);
        if(food!=null && CaelumMealData.IsMeal(food.GetConsumableType()))return CaelumMealData.FoodKind(food.GetConsumableType());
        return food!=null && food.GetConsumableType()==CaelumConstants.CONSUMABLE_FOOD_RATION?CaelumFoodData.RATION:-1;
    }
    static CaelumFoodLots GetLots(Inventory item)
    {
        let material=CaelumMaterialPickup(item);if(material!=null)return material.FoodLots;
        let food=CaelumConsumableItem(item);return food!=null?food.FoodLots:null;
    }
    static void SetLots(Inventory item,CaelumFoodLots lots)
    {
        let material=CaelumMaterialPickup(item);
        if(material!=null){material.FoodLots=lots;material.FoodSchemaRevision=CaelumKitchenData.REVISION;return;}
        let food=CaelumConsumableItem(item);if(food!=null)food.FoodLots=lots;
    }
    static bool Boxed(Inventory item)
    {
        let material=CaelumMaterialPickup(item);if(material!=null)return material.InMagicBox;
        let food=CaelumConsumableItem(item);return food!=null && food.InMagicBox;
    }

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
        let lots=GetLots(item);if(lots==null){lots=new('CaelumFoodLots');SetLots(item,lots);}
        lots.Ensure(Kind(item),Max(0,item.Amount),Stamp(item));
        return lots;
    }

    // Altas/bajas nativas externas (regalos, reposición y migración) se resuelven
    // antes de la operación siguiente; las transferencias nunca usan este ajuste.
    static void Reconcile(Inventory item)
    {
        if(item is "CaelumCarbineAmmo")CaelumCompanionProvenance.AmmoLots(CaelumCarbineAmmo(item));
        CaelumContaminationStack.Reconcile(item);
        let clock=CaelumFoodClock.Get(item);
        if(clock!=null)clock.Advance();
        let lots=Prepare(item);if(lots==null)return;
        int missing=Max(0,item.Amount)-lots.Units();
        if(missing>0)lots.Add(missing,0,Stamp(item));
        else if(missing<0){double ignored;lots.Consume(-missing,ignored);}
    }

    static bool Transfer(Inventory source,Inventory target,int count,bool emptyTarget=false)
    {
        CaelumCompanionProvenance.TransferAmmo(source,target,count,emptyTarget);
        if(!CaelumContaminationStack.Transfer(source,target,count,emptyTarget))return false;
        if(!IsFood(source))return true;
        let from=Prepare(source);
        if(target==null || Kind(target)!=Kind(source) || source==target)return source==target;
        if(emptyTarget){let empty=new('CaelumFoodLots');empty.Ensure(from.Kind,0,Stamp(source));SetLots(target,empty);}
        else Prepare(target);
        bool moved=from.TransferTo(GetLots(target),count);
        if(moved){CaelumContaminationStack.Clock(source).ResetBoundary();CaelumContaminationStack.Clock(target).ResetBoundary();}
        if(moved && emptyTarget)
        {
            let sourceClock=CaelumFoodClock.Get(source);
            let targetClock=CaelumFoodClock.Get(target);
            targetClock.Ready=sourceClock.Ready;targetClock.Stamp=sourceClock.Stamp;
            targetClock.Climate=sourceClock.Climate!=null?sourceClock.Climate.Copy():null;
        }
        return moved;
    }

    static void Relocate(Inventory item)
    {
        if(item==null || item.bDestroyed)return;
        CaelumContaminationStack.Relocate(item);
        let clock=CaelumFoodClock.Get(item);if(clock!=null)clock.Advance();
    }

    static bool Remove(Inventory item,int count)
    {
        CaelumContaminationStack.Remove(item,count);
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
    // El consumo de materia prima usa gramos completos; el uso nativo de una
    // unidad no puede descontar otro gramo después de estos cien.
    static bool EatRaw(CaelumPlayer user,CaelumMaterialPickup ingredient)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || ingredient==null
            || ingredient.Owner!=user || ingredient.InMagicBox
            || !CaelumKitchenData.Edible(ingredient.GetSpecialType()) || user.DerivedStats==null)return false;
        int grams=CaelumKitchenData.PORTION_GRAMS;
        if(ingredient.Amount-user.GetReservedCraftingMaterialUnits(ingredient.GetSpecialType(),ingredient.GetSpecialTier())<grams)return false;
        Reconcile(ingredient);let lots=Prepare(ingredient);
        if(lots==null || lots.Units()<grams)return false;
        let power=CaelumHungerRegeneration(user.FindInventory('CaelumHungerRegeneration'));
        if(power==null)power=CaelumHungerRegeneration(user.GiveInventoryType('CaelumHungerRegeneration'));
        if(power==null)return false;
        double contamination;if(!lots.Consume(grams,contamination))return false;
        power.EffectTics=CaelumConstants.CONSUMABLE_REGENERATION_SECONDS*TICRATE;
        power.PulseTics=0;power.SeatedMealSubTics=0;
        power.FoodRecoveryPerPulse=CaelumFoodRules.Hunger(Kind(ingredient),grams,user.DerivedStats.BaseMass)
            /CaelumConstants.CONSUMABLE_REGENERATION_SECONDS;
        ingredient.Amount-=grams;
        CaelumFoodIllness.Ingest(user,contamination,grams);
        if(ingredient.Amount==0)ingredient.Destroy();
        user.OnNativeInventoryChanged();user.LastEquipmentAction=CaelumConstants.EQUIPMENT_ACTION_USED;
        return true;
    }
}
