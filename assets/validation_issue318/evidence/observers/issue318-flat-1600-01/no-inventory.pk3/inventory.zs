// Author-requested ablation only. Never included in the normal game package.
class CA318FlatInventory : EventHandler
{
    int Start,WindowAt,End;
    bool Active,Removed;
    Array<CaelumMandinga> Bodies;
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca318_begin")return;
        Active=true;Start=level.time;
        WindowAt=Start+CVar.GetCVar("ca318_warmup").GetInt();
        End=WindowAt+CVar.GetCVar("ca318_window").GetInt();
    }
    void Verify(String label)
    {
        int items=0,uninitialized=0;
        for(int i=0;i<Bodies.Size();i++)if(Bodies[i]!=null)
        {
            if(Bodies[i].DemonSupplyRevision<CaelumDemonService.SUPPLY_REVISION)uninitialized++;
            for(Inventory item=Bodies[i].Inv;item!=null;item=item.Inv)items++;
        }
        Console.Printf("CA318 INVENTORY %s bodies=%d items=%d uninitialized_supply=%d",label,Bodies.Size(),items,uninitialized);
        if(items!=0 || uninitialized!=0)Console.Printf("CA318 FAIL Mandinga inventory unexpectedly present or uninitialized");
    }
    override void WorldTick()
    {
        if(!Active)return;
        if(!Removed && level.time>=Start+1)
        {
            double begin=MSTimeF();int objects=0,units=0;
            let it=ThinkerIterator.Create("CaelumMandinga");CaelumMandinga body;
            while((body=CaelumMandinga(it.Next()))!=null)Bodies.Push(body);
            for(int i=0;i<Bodies.Size();i++)
            {
                Inventory item=Bodies[i].Inv;
                while(item!=null)
                {
                    Inventory next=item.Inv;objects++;units+=item.Amount;
                    item.Destroy();item=next;
                }
            }
            Removed=true;
            Console.Printf("CA318 INVENTORY_REMOVED tic=%d bodies=%d objects=%d units=%d ms=%.3f",level.time,Bodies.Size(),objects,units,MSTimeF()-begin);
            if(Bodies.Size()!=CA318FlatData.MANDINGAS || objects!=Bodies.Size()*3)
                Console.Printf("CA318 FAIL Unexpected initial inventory count");
            Verify("after_removal");
        }
        if(level.time==WindowAt)Verify("window");
        if(level.time==End)Verify("end");
    }
}
