class CaelumJourneyFoodStack : Object play
{
    Inventory Item;
    CaelumFoodLots Lots;
    bool Boxed;
    CaelumFoodClimate Climate;
}
// Copia aislada de las provisiones. Un viaje rechazado no envejece ni consume
// el inventario; al confirmar se instalan copias sin volver a cobrar la dosis.
class CaelumJourneyFood : Object play
{
    Array<CaelumJourneyFoodStack> Stacks;
    void Capture(Actor user)
    {
        Stacks.Clear();
        for(Inventory cursor=user.Inv;cursor!=null;cursor=cursor.Inv)
        {
            CaptureItem(cursor,cursor.Owner!=user || CaelumFoodInventory.Boxed(cursor));
            let set=CaelumDiningSetItem(cursor);
            if(set!=null && set.Table!=null && set.Table.Packed())
                for(int i=0;i<set.Table.Capacity();i++)CaptureItem(set.Table.Items[i],true);
        }
    }
    void Refresh(Actor user)
    {
        for(int i=Stacks.Size()-1;i>=0;i--)
        {
            let row=Stacks[i];
            if(row.Item==null || row.Item.bDestroyed || CaelumContaminationStack.Carrier(row.Item)!=user)
            {Stacks.Delete(i);continue;}
            row.Lots=CaelumFoodInventory.Prepare(row.Item).Copy();
        }
        for(Inventory item=user.Inv;item!=null;item=item.Inv)CaptureItem(item,CaelumFoodInventory.Boxed(item));
    }
    CaelumJourneyFoodStack Find(Inventory item)
    {for(int i=0;i<Stacks.Size();i++)if(Stacks[i].Item==item)return Stacks[i];return null;}
    void CaptureItem(Inventory food,bool inaccessible)
    {
        if(!CaelumFoodInventory.IsFood(food) || Find(food)!=null)return;
        CaelumFoodInventory.Reconcile(food);let row=new('CaelumJourneyFoodStack');
        row.Item=food;row.Boxed=inaccessible;row.Lots=CaelumFoodInventory.GetLots(food).Copy();
        let climate=CaelumFoodClock.Get(food).Climate;row.Climate=climate!=null?climate.Copy():null;Stacks.Push(row);
    }
    void AdvanceClimate(double seconds)
    {for(int i=0;i<Stacks.Size();i++)if(Stacks[i].Climate!=null)Stacks[i].Climate.Advance(Stacks[i].Lots,seconds);}
    void Advance(double seconds,double celsius,double humidity)
    {for(int i=0;i<Stacks.Size();i++)Stacks[i].Lots.Advance(seconds,celsius,humidity);}
    int OldestServing()
    {
        int selected=-1;double oldest=0;
        for(int i=0;i<Stacks.Size();i++)
        {
            let row=Stacks[i];if(row.Boxed || !CaelumFoodData.Prepared(row.Lots.Kind) || row.Lots.Lots.Size()==0)continue;
            double created=row.Lots.Lots[0].CreatedStamp;
            if(selected<0 || created<oldest){selected=i;oldest=created;}
        }
        return selected;
    }
    int NextKind(){int selected=OldestServing();return selected>=0?Stacks[selected].Lots.Kind:-1;}
    double Consume()
    {
        int selected=OldestServing();if(selected<0)return 0;
        double contamination;Stacks[selected].Lots.Consume(1,contamination);return contamination;
    }
    void Commit(Actor user)
    {
        for(int i=0;i<Stacks.Size();i++)
        {
            let row=Stacks[i];let food=row.Item;
            if(food==null || food.bDestroyed || CaelumContaminationStack.Carrier(food)!=user)continue;
            CaelumFoodInventory.SetLots(food,row.Lots.Copy());food.Amount=row.Lots.Units();
            if(food.Amount==0){food.Destroy();continue;}
            let clock=CaelumFoodClock.Get(food);if(row.Climate!=null)clock.Climate=row.Climate.Copy();clock.Ready=false;clock.Advance();
            CaelumContaminationStack.Clock(food).ResetBoundary();
        }
    }
}
