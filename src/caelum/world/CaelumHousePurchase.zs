// Pago doméstico atómico: misma denominación/cambio que el comercio personal,
// pero únicamente con las monedas del cofre, nunca con las del jugador.
class CaelumHousePayment : Object play
{
    Array<CaelumCurrencyItem> Coins,Prepared;
    int Amounts[CaelumConstants.CURRENCY_TYPE_COUNT];
    double WeightDelta;
    int SlotDelta;
    bool Plan(CaelumStashChest chest,int price)
    {
        if(chest==null || price<0)return false;
        Coins.Clear();Prepared.Clear();WeightDelta=0;SlotDelta=0;
        for(int i=0;i<CaelumConstants.CURRENCY_TYPE_COUNT;i++)Amounts[i]=0;
        for(Inventory item=chest.Inv;item!=null;item=item.Inv)
        {
            let coin=CaelumCurrencyItem(item);if(coin==null || coin.Amount<=0)continue;
            int kind=coin.GetCurrencyType();if(kind<0 || kind>=CaelumConstants.CURRENCY_TYPE_COUNT)return false;
            if(Amounts[kind]>2147483647-coin.Amount)return false;
            Amounts[kind]+=coin.Amount;Coins.Push(coin);
            WeightDelta-=coin.Amount*CaelumConstants.CURRENCY_UNIT_WEIGHT;SlotDelta--;
        }
        int remaining=price,change=0;
        for(int i=CaelumConstants.CURRENCY_TYPE_COUNT-1;i>=0 && remaining>0;i--)
        {
            int face=CaelumEconomyRules.GetCurrencyFaceValue(i),take=Min(Amounts[i],remaining/face);
            Amounts[i]-=take;remaining-=take*face;
        }
        if(remaining>0)for(int i=0;i<CaelumConstants.CURRENCY_TYPE_COUNT;i++)
        {
            int face=CaelumEconomyRules.GetCurrencyFaceValue(i);
            if(Amounts[i]<=0 || face<=remaining)continue;
            Amounts[i]--;change=face-remaining;remaining=0;break;
        }
        if(remaining>0)return false;
        for(int i=CaelumConstants.CURRENCY_TYPE_COUNT-1;i>=0;i--)
        {
            int face=CaelumEconomyRules.GetCurrencyFaceValue(i);
            Amounts[i]+=change/face;change%=face;
            if(Amounts[i]>0){SlotDelta++;WeightDelta+=Amounts[i]*CaelumConstants.CURRENCY_UNIT_WEIGHT;}
        }
        return change==0;
    }
    bool Prepare(CaelumStashChest chest)
    {
        // Reservar objetos antes de tocar dinero, mercancía o existencias.
        for(int i=0;i<CaelumConstants.CURRENCY_TYPE_COUNT;i++)
        {
            CaelumCurrencyItem first=null;
            for(int c=0;c<Coins.Size();c++)if(Coins[c].GetCurrencyType()==i){first=Coins[c];break;}
            if(first!=null || Amounts[i]<=0)continue;
            let coin=CaelumCurrencyItem(Actor.Spawn(CaelumEconomyRules.GetCurrencyClassName(i),chest.Pos,NO_REPLACE));
            if(coin==null){Discard();return false;}Prepared.Push(coin);
        }
        return true;
    }
    void Discard(){for(int i=0;i<Prepared.Size();i++)if(Prepared[i]!=null)Prepared[i].Destroy();Prepared.Clear();}
    void Commit(CaelumStashChest chest)
    {
        for(int i=0;i<Prepared.Size();i++){Prepared[i].AttachToOwner(chest);Coins.Push(Prepared[i]);}
        Prepared.Clear();
        for(int c=0;c<Coins.Size();c++)
        {
            let coin=Coins[c];int kind=coin.GetCurrencyType();coin.Amount=Amounts[kind];Amounts[kind]=0;
            if(coin.Amount<=0)coin.Destroy();
        }
    }
}

class CaelumHousePurchase : Object play
{
    static int Supply(Inventory item)
    {
        if(item is 'CaelumCleaningCloth')return 1;
        let mat=CaelumMaterialPickup(item);
        return mat!=null && mat.GetSpecialType()==CaelumHygieneData.SOAP && mat.GetSpecialTier()==1?2:0;
    }
    static Inventory Find(Actor owner,int kind)
    {
        if(owner==null)return null;
        for(Inventory item=owner.Inv;item!=null;item=item.Inv)if(item.Amount>0 && Supply(item)==kind)return item;
        return null;
    }
    static int Count(Actor owner,int kind)
    {
        if(owner==null)return 0;
        int total=0;for(Inventory item=owner.Inv;item!=null;item=item.Inv)
            if(item.Amount>0 && Supply(item)==kind)total+=item.Amount;
        return total;
    }
    static bool OwnChest(CaelumStashChest chest,int house)
    {
        if(chest==null || chest.bDestroyed || chest.Cargo!=null || chest.LawfulOwner==null)return false;
        if(house<0 || house>=CaelumCityData.HOUSE_COUNT || house==CaelumPropertyData.CENTRAL_HOUSE)return false;
        String title=chest.LawfulOwner.Token;
        return title==("house:"..CaelumHouseHubData.MapName(house))
            || (house==CaelumPropertyData.RELOCATION_HOUSE
                && title==("house:"..CaelumHouseHubData.MapName(CaelumPropertyData.CENTRAL_HOUSE)));
    }
    static bool Buy(CaelumPlayer user,CaelumStashChest chest,int house,CaelumCityMerchant vendor,Inventory stock,int quantity)
    {return BuyAt(user,chest,house,vendor,stock,quantity,CaelumScheduleState.Now(user));}
    static bool BuyAt(CaelumPlayer user,CaelumStashChest chest,int house,CaelumCityMerchant vendor,Inventory stock,int quantity,double at)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || !OwnChest(chest,house) || vendor==null
            || vendor.bDestroyed || vendor.Category!=0 || stock==null || stock.Owner!=vendor
            || quantity<=0 || quantity>stock.Amount || Supply(stock)==0 || at<0 || at<vendor.RestockLastSeen)return false;
        int price=CaelumEconomyRules.GetPriceChargedByMerchant(CaelumEconomyRules.GetInventoryUnitBaseValue(stock),quantity);
        if(price<=0 || vendor.WalletCopper>2147483647-price)return false;
        let payment=new('CaelumHousePayment');if(!payment.Plan(chest,price))return false;
        let receiving=Find(chest,Supply(stock));
        if(receiving!=null && receiving.Amount>2147483647-quantity)return false;
        double weight=CaelumContainerRules.Weight(user,stock)*quantity/stock.Amount;
        if(chest.StorageSlots()+payment.SlotDelta+(receiving==null?1:0)>CaelumContainerRules.Slots(chest.StorageTier)
            || chest.StorageWeight(user)+payment.WeightDelta+weight>CaelumContainerRules.Capacity(chest.StorageTier))return false;
        Inventory split=null;
        if(receiving==null)
        {
            split=Inventory(Actor.Spawn(stock.GetClass(),chest.Pos,NO_REPLACE));if(split==null)return false;
            if(stock is 'CaelumMaterialPickup')for(int i=0;i<5;i++)split.args[i]=stock.args[i];
        }
        if(!payment.Prepare(chest)){if(split!=null)split.Destroy();return false;}
        payment.Commit(chest);
        if(receiving!=null)receiving.Amount+=quantity;
        else{split.Amount=quantity;split.AttachToOwner(chest);}
        stock.Amount-=quantity;if(stock.Amount==0)stock.Destroy();
        vendor.WalletCopper+=price;CaelumShopRestock.SyncAt(vendor,user,at,true);return true;
    }
    static void Replenish(CaelumPlayer user,CaelumStashChest chest,int house)
    {ReplenishAt(user,chest,house,CaelumScheduleState.Now(user));}
    static void ReplenishAt(CaelumPlayer user,CaelumStashChest chest,int house,double at)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || !OwnChest(chest,house) || at<0)return;
        let market=CaelumDomesticMarket.Get();if(market==null)return;
        // El orden persistente es el de los comercios, sin escaneos de actores.
        for(int i=0;i<market.Vendors.Size();i++)
        {
            let vendor=market.Vendors[i].Body;if(vendor==null || vendor.bDestroyed || at<vendor.RestockLastSeen)continue;
            vendor.EnsureStockAt(user,at);
            for(int kind=1;kind<=2;kind++)
            {
                int target=kind==1?CaelumHousekeepingData.CLOTH_TARGET:CaelumHousekeepingData.SOAP_TARGET_GRAMS;
                int wanted=int(Floor(Max(0.0,target-Count(chest,kind)-(kind==2?chest.DomesticSoapRemainderG:0))));
                let stock=Find(vendor,kind);
                if(wanted<=0 || stock==null)continue;
                wanted=Min(wanted,stock.Amount);
                // Comprar la mayor cantidad realmente pagable; el redondeo es
                // por lote como en la interfaz, no por cada gramo de jabón.
                int lo=0,hi=wanted;
                while(lo<hi)
                {
                    int mid=(lo+hi+1)/2;
                    int price=CaelumEconomyRules.GetPriceChargedByMerchant(CaelumEconomyRules.GetInventoryUnitBaseValue(stock),mid);
                    let plan=new('CaelumHousePayment');if(plan.Plan(chest,price))lo=mid;else hi=mid-1;
                }
                if(lo>0)BuyAt(user,chest,house,vendor,stock,lo,at);
            }
            if(Count(chest,1)>=CaelumHousekeepingData.CLOTH_TARGET && Count(chest,2)>=CaelumHousekeepingData.SOAP_TARGET_GRAMS)return;
        }
    }
}
