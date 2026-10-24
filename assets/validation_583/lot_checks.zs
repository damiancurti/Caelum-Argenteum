// Diagnóstico del libro; no sustituye la futura conexión con objetos de comida.
class CA410LotCarrier : Inventory
{
    CaelumFoodLots SourceLots,StoredLots;
    Default { Inventory.MaxAmount 1; Inventory.InterHubAmount 1; +INVENTORY.UNDROPPABLE }
}

class CA410LotChecks : EventHandler
{
    int Passed,Failed;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA410 %s %s",ok?"PASS":"FAIL",label);}
    bool Near(double a,double b){return Abs(a-b)<0.000001;}
    CaelumFoodLots Fresh(int kind,int units=0,double stamp=0)
    {let result=new('CaelumFoodLots');result.Ensure(kind,units,stamp);return result;}
    void Ledger()
    {
        bool identities=true;
        for(int kind=0;kind<CaelumFoodData.KIND_COUNT;kind++)
        {let identity=Fresh(kind,1);identities=identities && identity.Kind==kind;}
        Check(identities,"all food catalogue identities initialize distinctly");
        let source=Fresh(CaelumFoodData.RAW_FISH,100,10);
        source.Advance(10800,20,50);
        Check(source.Units()==100 && Near(source.OldestContamination(),50),"calendar interval ages original batch");
        source.Add(100,0,20);
        Check(source.Lots.Size()==2 && Near(source.Contamination(0),50)
            && source.Contamination(1)==0,"fresh additions do not rejuvenate old food");
        source.Add(50,25,5);
        Check(source.Lots[0].CreatedStamp==5 && source.OldestContamination()==25,"age order follows creation rather than contamination");
        double dose;
        Check(source.Consume(75,dose) && Near(dose,100.0/3.0) && source.Units()==175,
            "portion across lots takes oldest first with mass-weighted dose");
        Check(source.Lots.Size()==2 && source.Lots[0].Units==75 && source.Lots[1].Units==100,
            "partial consumption preserves remaining batch identities");
        let storage=Fresh(CaelumFoodData.RAW_FISH,50,30);
        storage.Advance(2160,20,50);
        Check(source.TransferTo(storage,100) && source.Units()==75 && storage.Units()==150,
            "partial transfer conserves total units");
        Check(storage.Lots.Size()==3 && storage.Lots[0].CreatedStamp==10
            && storage.Lots[0].Units==75 && Near(storage.Contamination(0),50)
            && Near(storage.Contamination(1),0) && Near(storage.Contamination(2),10),
            "transfer preserves each age and contamination despite different exposure histories");
        storage.Advance(2160,20,50);
        Check(Near(storage.Contamination(0),60) && Near(storage.Contamination(1),10)
            && Near(storage.Contamination(2),20) && source.OldestContamination()==0,
            "destination ages independently without aliasing source objects");
        Check(!source.TransferTo(source,1) && source.Units()==75,"self transfer rejects without mutation");
        Check(!source.TransferTo(storage,76) && source.Units()==75 && storage.Units()==150,
            "overdraw is atomic");
        let other=Fresh(CaelumFoodData.BREAD);
        Check(!source.TransferTo(other,1) && source.Units()==75 && other.Units()==0,
            "different foods cannot merge");
        let copied=storage.CopyOldest(100);
        Check(copied!=null && copied.Units()==100 && copied.Lots.Size()==2 && storage.Units()==150,
            "reservation snapshot preserves source until commit");
        copied.Advance(2160,20,50);
        Check(Near(copied.Contamination(0),70) && Near(storage.Contamination(0),60),
            "copied state has independent ownership");
        Check(copied.TransferTo(source,100) && copied.Units()==0 && source.Units()==175,
            "return of aged reservation retains quantity");
        Check(source.Lots.Size()==3 && source.Lots[0].CreatedStamp==10 && Near(source.Contamination(0),70),
            "returned reservation retains accumulated deterioration");
        int count=source.Units();double before=source.OldestContamination();
        Check(source.Ensure(CaelumFoodData.RAW_FISH,999,999) && source.Units()==count
            && source.OldestContamination()==before,"idempotent initialization cannot reset food or quantities");
        Check(!source.Ensure(CaelumFoodData.BREAD,999,999) && source.Kind==CaelumFoodData.RAW_FISH,
            "schema cannot silently change food identity");
        let frozen=Fresh(CaelumFoodData.RAW_BEEF,100);
        frozen.Add(50,65,1);frozen.Advance(999999,-18,100);frozen.Advance(999999,60,100);
        Check(frozen.Contamination(0)==0 && frozen.Contamination(1)==65,
            "freezing and hot holding preserve every lot without purifying");
        frozen.Advance(999999,20,50);
        Check(frozen.Contamination(0)==100 && frozen.Contamination(1)==100,"every lot saturates independently");
        let full=Fresh(CaelumFoodData.RAW_FISH,2147483647);
        Check(!full.Add(1,0,1) && !source.TransferTo(full,1) && full.Units()==2147483647,
            "native integer capacity never wraps");
        Check(!source.Consume(0,dose) && !source.Consume(-1,dose) && source.Units()==count,
            "invalid portions cannot create food");
        let combined=Fresh(CaelumFoodData.BREAD,100,5);
        combined.Add(200,0,5);combined.Add(50,20,5);
        Check(combined.Lots.Size()==2 && combined.Lots[0].Units==300,
            "only identical-time identical-state fragments coalesce");
        let large=Fresh(CaelumFoodData.FLOUR);
        for(int i=0;i<2048;i++)large.Add(1,i%101,i);
        large.Advance(3600,30,100);
        Check(large.Consume(2047,dose) && large.Units()==1 && large.Lots.Size()==1
            && large.Lots[0].CreatedStamp==2047,"large mixed removal compacts once and retains final lot");
        Check(large.Consume(1,dose) && large.Units()==0 && large.Lots.Size()==0,
            "complete depletion leaves no stale lot");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Player<0 || e.Player>=MAXPLAYERS)return;
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca410_lots')Ledger();
        else if(e.Name=='ca410_lotseed')
        {
            let carrier=CA410LotCarrier(u.GiveInventoryType('CA410LotCarrier'));
            carrier.SourceLots=Fresh(CaelumFoodData.RAW_FISH,100,10);
            carrier.SourceLots.Advance(10800,20,50);carrier.SourceLots.Add(200,0,20);
            carrier.StoredLots=Fresh(CaelumFoodData.RAW_FISH);
            Check(carrier.SourceLots.TransferTo(carrier.StoredLots,125),"saved food metadata seed");
        }
        else if(e.Name=='ca410_lotload')
        {
            let carrier=CA410LotCarrier(u.FindInventory('CA410LotCarrier'));
            Check(carrier!=null && carrier.SourceLots!=null && carrier.StoredLots!=null,
                "native save or travel restores ledger ownership");
            if(carrier!=null && carrier.SourceLots!=null && carrier.StoredLots!=null)
            {
                Check(carrier.SourceLots.Revision==1 && carrier.SourceLots.Units()==175
                    && carrier.StoredLots.Units()==125,"saved lot schema and quantities survive");
                Check(carrier.StoredLots.Lots.Size()==2 && carrier.StoredLots.Lots[0].CreatedStamp==10
                    && Near(carrier.StoredLots.Contamination(0),50) && carrier.StoredLots.Contamination(1)==0,
                    "save and travel retain distinct food ages and contamination");
            }
        }
        else return;
        Console.Printf("CA410 RESULT passed=%d failed=%d",Passed,Failed);
    }
}
