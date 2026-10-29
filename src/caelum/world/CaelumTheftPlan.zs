// Un plan sólo nace al marcar explícitamente al ladrón. Ningún habitante
// adquiere este comportamiento por su facción, aspecto o inventario.
class CaelumTheftReceipt : Object play
{
    Inventory Item;
    CaelumStashChest Source;
    CaelumLawfulIdentity Victim;
    String SourceMap;
    double When;
    int Units;
    bool Known;
}

class CaelumTheftPlan : Object play
{
    int Revision,Attempts;
    CaelumCombatActor Body;
    CaelumTheftWorld World;
    String SourceMap;
    bool Away;
    double Stamp,NextDue,Remaining;
    Array<CaelumStashChest> Accessible;
    Array<CaelumTheftReceipt> Receipts;

    void Begin(CaelumCombatActor body,String map,double now,out Array<CaelumStashChest> reachable)
    {
        if(Away || body==null || body.health<=0 || now<0)return;
        if(Revision==0){Revision=CaelumTheftData.REVISION;Remaining=CaelumTheftData.WORLD_SECONDS_PER_ATTEMPT;}
        if(Revision!=CaelumTheftData.REVISION)return;
        self.Body=body;SourceMap=map;Stamp=now;NextDue=now+Remaining;Away=true;
        Accessible.Clear();
        for(int i=0;i<reachable.Size();i++)
            if(reachable[i]!=null && Accessible.Find(reachable[i])==Accessible.Size())Accessible.Push(reachable[i]);
    }
    // El llamador avanza primero combate/fisiología hasta esta fecha. No
    // resolver el combate de todo el día y luego robar en un pasado inventado.
    bool Due(double now)
    {return Away && Revision==CaelumTheftData.REVISION && now>=NextDue;}
    bool Step(double now)
    {
        if(!Due(now))return false;
        double at=NextDue;NextDue+=CaelumTheftData.WORLD_SECONDS_PER_ATTEMPT;Stamp=at;Attempts++;
        if(Body==null || Body.bDestroyed || Body.health<=0)return true;
        let absence=Body.ContaminationAbsence;
        if(absence!=null && absence.Away && absence.Life<=0)return true;
        let item=CaelumTheftTransfer.Select(Body,Accessible);
        if(item==null)return true;
        let chest=CaelumStashChest(item.Owner);
        if(World!=null)World.BeforeTransfer(item,at);
        if(!CaelumTheftTransfer.Move(Body,chest,item,World!=null))return true;
        if(World!=null)World.AfterTransfer(Body,item);
        let receipt=new('CaelumTheftReceipt');receipt.Item=item;receipt.Source=chest;
        receipt.Victim=chest.LawfulOwner;receipt.SourceMap=SourceMap;receipt.When=at;receipt.Units=item.Amount;
        Receipts.Push(receipt);return true;
    }
    bool Finish(double now)
    {
        if(!Away || now<Stamp || Due(now))return false;
        Remaining=NextDue-now;Stamp=now;Away=false;Accessible.Clear();return true;
    }
    int Discover(CaelumPlayer user,String map)
    {
        if(user==null)return 0;
        let identity=CaelumLockRules.Character(user);int found=0;
        for(int i=0;i<Receipts.Size();i++)
        {
            let receipt=Receipts[i];
            if(receipt.Known || !CaelumScheduleRules.SameRegion(receipt.SourceMap,map)
                || !CaelumLockRules.SameTitle(receipt.Victim,identity))continue;
            receipt.Known=true;found++;
        }
        return found;
    }
}
