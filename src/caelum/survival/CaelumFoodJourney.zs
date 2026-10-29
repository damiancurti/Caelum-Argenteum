class CaelumJourneyFoodStack : Object play
{
    Inventory Item;
    CaelumFoodLots Lots;
    bool Boxed;
}
// Copia aislada de las provisiones. Un viaje rechazado no envejece ni consume
// el inventario; al confirmar se instalan copias sin volver a cobrar la dosis.
class CaelumJourneyFood : Object play
{
    Array<CaelumJourneyFoodStack> Stacks;
    void Capture(CaelumPlayer user)
    {
        Stacks.Clear();
        for(Inventory cursor=user.Inv;cursor!=null;cursor=cursor.Inv)
        {
            if(!CaelumFoodInventory.IsFood(cursor))continue;
            CaelumFoodInventory.Reconcile(cursor);
            let food=cursor;let row=new('CaelumJourneyFoodStack');
            row.Item=food;row.Boxed=CaelumFoodInventory.Boxed(food);row.Lots=CaelumFoodInventory.GetLots(food).Copy();Stacks.Push(row);
        }
    }
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
    void Commit(CaelumPlayer user)
    {
        for(int i=0;i<Stacks.Size();i++)
        {
            let row=Stacks[i];let food=row.Item;
            if(food==null || food.bDestroyed || food.Owner!=user)continue;
            CaelumFoodInventory.SetLots(food,row.Lots.Copy());food.Amount=row.Lots.Units();
            if(food.Amount==0){food.Destroy();continue;}
            let clock=CaelumFoodClock.Get(food);clock.Ready=false;clock.Advance();
        }
    }
}
