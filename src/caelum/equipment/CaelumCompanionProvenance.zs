// Historial por unidades reales, conservado al dividir/copiar inventario.
class CaelumCompanionHistory : Object play
{
    int Revision;
    Array<CaelumCompanionItemRecord> Records;
    CaelumCompanionItemRecord Record(CaelumCompanionBond bond,Inventory item)
    {
        Revision=1;
        for(int i=0;i<Records.Size();i++)if(Records[i].Bond==bond)return Records[i];
        let row=new("CaelumCompanionItemRecord");row.Bond=bond;
        let previous=bond.ItemRecord(item);
        if(previous!=null)
        {
            row.Loan=previous.Loan;row.Credited=previous.Credited;row.Refused=previous.Refused;
            row.RefusedTrust=previous.RefusedTrust;row.RefusedStage=previous.RefusedStage;
        }
        Records.Push(row);return row;
    }
    CaelumCompanionHistory Copy()
    {
        let copy=new("CaelumCompanionHistory");copy.Revision=1;
        for(int i=0;i<Records.Size();i++)
        {
            let source=Records[i];let row=new("CaelumCompanionItemRecord");
            row.Bond=source.Bond;row.Loan=source.Loan;row.Credited=source.Credited;
            row.Refused=source.Refused;row.RefusedTrust=source.RefusedTrust;row.RefusedStage=source.RefusedStage;
            copy.Records.Push(row);
        }
        return copy;
    }
}
class CaelumCompanionGiftView : Object play
{
    Array<CaelumCompanionItemRecord> Records;
    Array<int> Units;
    int Total;
    bool IsLoan()
    {for(int i=0;i<Records.Size();i++)if(!Records[i].Loan)return false;return Records.Size()>0;}
    bool Refused(double trust,int stage)
    {
        for(int i=0;i<Records.Size();i++)
        {let row=Records[i];if(!row.Loan && row.Refused && row.RefusedTrust==trust && row.RefusedStage==stage)return true;}
        return false;
    }
    void Consent(bool refused,double trust,int stage)
    {
        for(int i=0;i<Records.Size();i++)
        {let row=Records[i];row.Refused=refused;row.RefusedTrust=trust;row.RefusedStage=stage;}
    }
    double Gift(bool loan,double value)
    {
        double uncredited=0;
        for(int i=0;i<Records.Size();i++)
        {
            let row=Records[i];row.Loan=loan;
            if(!loan && !row.Credited){uncredited+=Units[i];row.Credited=true;}
        }
        return Total>0 ? value*uncredited/Total : 0;
    }
}
class CaelumCompanionProvenance : Object play
{
    static CaelumFoodLots AmmoLots(CaelumCarbineAmmo item,bool reconcile=true)
    {
        if(item==null)return null;
        if(item.CompanionLots==null)
        {item.CompanionLots=new("CaelumFoodLots");item.CompanionLots.Ensure(CaelumFoodData.RATION,Max(0,item.Amount),0);}
        let lots=item.CompanionLots;
        if(reconcile)
        {
            int delta=Max(0,item.Amount)-lots.Units();
            if(delta>0)lots.Add(delta,0,0);
            else if(delta<0){double ignored;lots.Consume(-delta,ignored);}
        }
        return lots;
    }
    static void TransferAmmo(Inventory source,Inventory destination,int count,bool empty=false)
    {
        let from=CaelumCarbineAmmo(source);let to=CaelumCarbineAmmo(destination);
        if(from==null || to==null || from==to || from.CompanionLots==null)return;
        if(empty || to.CompanionLots==null)
        {
            to.CompanionLots=new("CaelumFoodLots");
            to.CompanionLots.Ensure(CaelumFoodData.RATION,empty?0:Max(0,to.Amount-count),0);
        }
        from.CompanionLots.TransferTo(to.CompanionLots,count);
    }
    static CaelumCompanionGiftView View(Inventory item,CaelumCompanionBond bond)
    {
        let result=new("CaelumCompanionGiftView");result.Total=item.Amount;
        CaelumFoodLots lots=null;
        if(item is "CaelumCarbineAmmo")lots=AmmoLots(CaelumCarbineAmmo(item));
        else if(CaelumContaminationStack.Eligible(item))
        {CaelumFoodInventory.Reconcile(item);lots=CaelumContaminationStack.Prepare(item);}
        if(lots!=null)
        {
            for(int i=0;i<lots.Lots.Size();i++)
            {
                let lot=lots.Lots[i];if(lot.CompanionHistory==null)lot.CompanionHistory=new("CaelumCompanionHistory");
                result.Records.Push(lot.CompanionHistory.Record(bond,item));result.Units.Push(lot.Units);
            }
            return result;
        }
        let equipment=CaelumEquipmentItem(item);let special=CaelumSpecialInventoryItem(item);let prepared=CaelumConsumableItem(item);
        CaelumCompanionHistory history=equipment!=null?equipment.CompanionHistory
            :special!=null?special.CompanionHistory:prepared!=null?prepared.CompanionHistory:null;
        if(history==null)
        {
            history=new("CaelumCompanionHistory");
            if(equipment!=null)equipment.CompanionHistory=history;
            else if(special!=null)special.CompanionHistory=history;
            else if(prepared!=null)prepared.CompanionHistory=history;
        }
        result.Records.Push(history.Record(bond,item));result.Units.Push(item.Amount);return result;
    }
}
