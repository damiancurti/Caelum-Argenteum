// Pulsacion nativa de Use ante cada vendedor. Caja y monedas son recursos de
// fixture; precios, stock y transferencia pertenecen al comercio existente.
class CA454ShopUseCity : CaelumPortSiege
{
    override void Tick()
    {
        if(SetupRevision>0 || !CaelumCityWorld.Prepare())return;
        CaelumHouseResidents.Get(true).PrepareCity(self);SetupRevision=3;
    }
}
class CA454ShopUseProbe : EventHandler
{
    bool Bought;
    int Opened,Failures,UseTics;
    override void WorldTick()
    {if(players[0].mo!=null && (players[0].cmd.buttons&BT_USE)!=0)UseTics++;}
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca454_shop_aim" && e.Name!="ca454_shop_check" && e.Name!="ca454_shop_report")return;
        let user=CaelumPlayer(players[0].mo);
        if(e.Name=="ca454_shop_report")
        {
            user.ClosePalomoMerchant();
            Console.Printf("CA454 SHOP COMPLETE %s opened=%d bought=%d failures=%d",Opened==64 && Bought && Failures==0?"PASS":"FAIL",Opened,Bought,Failures);return;
        }
        let vendor=CaelumCityMerchant.Find(e.Args[0]);
        if(vendor==null){Failures++;Console.Printf("CA454 SHOP FAIL missing id=%d",e.Args[0]);return;}
        if(e.Name=="ca454_shop_aim")
        {
            user.ClosePalomoMerchant();user.GetPersistentCharacterState(true).MagicBoxOwned=true;
            user.MagicBoxOwned=true;user.bInvulnerable=true;
            UseTics=0;
            user.FolkloreInteractionUseLatched=false;
            double angle=CaelumBarracasData.ShopAngle(vendor.ShopIdentity);
            user.SetOrigin(vendor.Pos+(Cos(angle),Sin(angle),0)*64,false);user.FindFloorCeiling();
            user.Angle=angle+180;user.Pitch=0;user.Vel=(0,0,0);user.ClearInterpolation();
            if(!user.TestMobjLocation())
            {Failures++;Console.Printf("CA454 SHOP FAIL standing space id=%d",e.Args[0]);}
            return;
        }
        bool open=user.IsActivePalomoMerchantSessionValid() && user.CityTrade!=null && user.CityTrade.Vendor==vendor;
        if(!open)
        {
            Failures++;Console.Printf("CA454 SHOP FAIL native Use id=%d",e.Args[0]);
            if(e.Args[0]<2)Console.Printf("CA454 SHOP DIAG use_tics=%d box=%d wizard=%d latched=%d aimed=%d menu=%d session=%d distance=%.3f",UseTics,user.MagicBoxOwned,user.CreationWizardOpen,user.FolkloreInteractionUseLatched,CaelumUseGeometry.AimedAt(user,vendor),user.PalomoMerchantMenuOpen,user.CityTrade!=null,user.Distance3D(vendor));
            return;
        }
        Opened++;Console.Printf("CA454 SHOP OPEN PASS id=%d category=%d rows=%d",e.Args[0],vendor.Category,user.CityTrade.Rows.Size());
        if(!Bought && vendor.Category==0)
        {
            user.GiveInventoryType('CaelumGoldCoin100');
            let session=user.CityTrade;
            for(int i=0;i<session.Rows.Size();i++)
            {
                let item=session.Rows[i];
                if(!(item is 'CaelumConsumableItem') || item.Amount<=1)continue;
                session.Selection=i;user.PalomoMerchantQuantityIndex=0;session.Refresh(user);
                int price=user.PalomoMerchantSelectedLotPrice,stock=item.Amount,wallet=vendor.WalletCopper;
                double funds=user.GetOwnedMoneyCopperValue();
                if(price<=0 || price>funds)continue;
                session.Execute(user);
                Bought=user.LastPalomoMerchantAction==CaelumConstants.PALOMO_MERCHANT_ACTION_BOUGHT
                    && item.Amount==stock-1 && vendor.WalletCopper==wallet+price
                    && Abs(user.GetOwnedMoneyCopperValue()-(funds-price))<0.001;
                if(!Bought)Failures++;
                Console.Printf("CA454 SHOP PURCHASE %s id=%d price=%d stock_before=%d stock_after=%d wallet_delta=%d",Bought?"PASS":"FAIL",vendor.ShopIdentity,price,stock,item.Amount,vendor.WalletCopper-wallet);
                break;
            }
        }
    }
}
