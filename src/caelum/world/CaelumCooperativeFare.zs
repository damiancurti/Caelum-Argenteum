// Preparar todos los pagos antes de descontar la primera moneda. Las monedas
// de cambio aún no pertenecen a nadie y se descartan si falla otro viajero.
class CaelumCooperativeFare : Object play
{
    CaelumPlayer User;
    CaelumCurrencyItem Coins[CaelumConstants.CURRENCY_TYPE_COUNT];
    CaelumCurrencyItem Created[CaelumConstants.CURRENCY_TYPE_COUNT];
    int Amounts[CaelumConstants.CURRENCY_TYPE_COUNT];
    bool InBox[CaelumConstants.CURRENCY_TYPE_COUNT];
    static bool CanPay(CaelumPlayer user,int fare)
    {
        return fare==0 || (fare>0 && user.BuildPalomoCurrencyPaymentPlan(fare)
            && user.PalomoTransactionCapacityFits(user.GetPalomoCurrencyPlanPersonalWeightDelta(),
                user.GetPalomoCurrencyPlanBoxRawWeightDelta(),user.GetPalomoCurrencyPlanBoxSlotDelta()));
    }
    static CaelumCooperativeFare Prepare(CaelumPlayer user,int fare)
    {
        if(!CanPay(user,fare))return null;
        let payment=new('CaelumCooperativeFare');payment.User=user;
        for(int i=0;i<CaelumConstants.CURRENCY_TYPE_COUNT;i++)
        {
            let coin=user.FindNativeCurrency(i);payment.Coins[i]=coin;
            payment.Amounts[i]=fare==0?(coin!=null?coin.Amount:0):user.PalomoCurrencyPlanAmount[i];
            payment.InBox[i]=fare==0?(coin!=null && coin.InMagicBox):user.PalomoCurrencyPlanInMagicBox[i];
            if(coin==null && payment.Amounts[i]>0)
            {
                payment.Created[i]=CaelumCurrencyItem(Actor.Spawn(CaelumEconomyRules.GetCurrencyClassName(i),user.Pos,NO_REPLACE));
                if(payment.Created[i]==null){payment.Cancel();return null;}
            }
        }
        return payment;
    }
    void Cancel()
    {for(int i=0;i<CaelumConstants.CURRENCY_TYPE_COUNT;i++){if(Created[i]!=null)Created[i].Destroy();Created[i]=null;}}
    void Apply()
    {
        for(int i=0;i<CaelumConstants.CURRENCY_TYPE_COUNT;i++)
        {
            let coin=Coins[i];int before=coin!=null?coin.Amount:0;
            if(Created[i]!=null){coin=Created[i];coin.AttachToOwner(User);Created[i]=null;}
            if(coin==null)continue;
            coin.Amount=Amounts[i];coin.InMagicBox=InBox[i];
            if(coin.Amount>before)CaelumNotifications.Acquired(User,coin,coin.Amount-before);
            if(coin.Amount<=0)coin.Destroy();
        }
        User.OnNativeInventoryChanged();
    }
}
