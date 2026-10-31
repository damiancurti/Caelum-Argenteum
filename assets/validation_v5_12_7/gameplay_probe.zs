// Peticiones de UI reales: comercio concurrente y reservas personales de Química.
class CA435SessionProbe : StaticEventHandler
{
    int Phase,Ready[MAXPLAYERS],Wallet[MAXPLAYERS],Fuel[MAXPLAYERS],Coal[MAXPLAYERS];
    int ShopWallet,Count;
    CaelumCityMerchant Vendor;
    CaelumWaterContainer Water[MAXPLAYERS];
    double Liters[MAXPLAYERS];
    ui int SentPhase;
    void Check(bool value,String text){Console.Printf("CA435SESSION %s %s",value?"PASS":"FAIL",text);}
    override void UiTick()
    {
        if(Phase<=0 || Phase>=5 || SentPhase==Phase)return;
        SentPhase=Phase;
        if(Phase==1)
        {
            EventHandler.SendNetworkEvent("ca_palomo_merchant_transact");
            EventHandler.SendNetworkEvent("ca_palomo_merchant_transact");
        }
        else if(Phase==2)
        {
            EventHandler.SendNetworkEvent("ca_inventory_boil");
            EventHandler.SendNetworkEvent("ca_inventory_boil");
        }
        else if(Phase==3 && consoleplayer==0)EventHandler.SendNetworkEvent("ca_crafting_cancel_task");
        EventHandler.SendNetworkEvent("ca435_gameplay_ready",Phase);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca435_gameplay_ready" && e.Player>=0 && e.Player<MAXPLAYERS
            && e.Args[0]==Phase)Ready[e.Player]=Phase;
    }
    override void WorldTick()
    {
        if(Phase==5 || level.time<105)return;
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
        {let user=CaelumPlayer(players[i].mo);if(!CaelumWorldClockTicker.Ready(user) || user.SessionIdentityPending)return;}
        if(Phase==0)
        {
            Count=0;for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])Count++;
            Vendor=CaelumCityMerchant(Actor.Spawn('CaelumCityMerchant',(0,96,0),NO_REPLACE));
            Vendor.Category=0;Vendor.EnsureStock(CaelumPlayer(players[0].mo));
            // Un único producto diagnóstico; no se modifica un comercio de campaña.
            for(Inventory item=Vendor.Inv;item!=null;){let next=item.Inv;item.Destroy();item=next;}
            Vendor.Products.Clear();Vendor.RestockNextDue=-1;Vendor.WalletCopper=1000;
            let product=Inventory(Actor.Spawn('CaelumFoodRation',Vendor.Pos,NO_REPLACE));
            product.Amount=1;product.AttachToOwner(Vendor);ShopWallet=Vendor.WalletCopper;
            bool privateSessions=true;
            for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
            {
                let user=CaelumPlayer(players[i].mo);double angle=i*360.0/Count;
                user.SetOrigin((64*cos(angle),64*sin(angle),0),false);user.Vel=(0,0,0);
                CaelumInventoryService.GrantMagicBoxFromPalomo(user,false);user.GiveInventory('CaelumCopperCoin',10000+i);
                Wallet[i]=user.GetOwnedMoneyCopperValue();user.CombatTimeRemaining=0;
                if(user.player.ConversationNPC!=null)user.player.ConversationNPC.bInConversation=false;
                user.player.ConversationNPC=null;user.player.ConversationPC=null;
                CaelumCityTradeSession.Open(user,Vendor);
                Console.Printf("CA435SESSION DEBUG trade slot=%d box=%d rows=%d open=%d wallet=%d",i,user.MagicBoxOwned,user.CityTrade==null?-1:int(user.CityTrade.Rows.Size()),user.PalomoMerchantMenuOpen,Wallet[i]);
                privateSessions=privateSessions && user.CityTrade!=null && user.CityTrade.Rows.Size()==1;
            }
            Check(product.Owner==Vendor && product.Amount==1,"shared shop has one real sale unit");
            Check(privateSessions,"each native player has its own trade projection");
            Phase=1;return;
        }
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i] && Ready[i]!=Phase)return;
        if(Phase==1)
        {
            int owned=0,spent=0;bool losers=true,closed=true;
            for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
            {
                let user=CaelumPlayer(players[i].mo);let food=user.FindInventory('CaelumFoodRation');
                int units=food!=null?food.Amount:0;owned+=units;
                int paid=Wallet[i]-user.GetOwnedMoneyCopperValue();spent+=paid;
                losers=losers && (units>0?paid>0:paid==0);
                user.ClosePalomoMerchant();int money=user.GetOwnedMoneyCopperValue();
                user.ExecutePalomoMerchantTransaction();closed=closed && money==user.GetOwnedMoneyCopperValue();
            }
            Check(owned==1 && Vendor.FindInventory('CaelumFoodRation')==null,"simultaneous and repeated purchases transfer one unit only");
            Check(spent>0 && spent==Vendor.WalletCopper-ShopWallet,"buyer payment equals the merchant receipt exactly once");
            Check(losers,"unsuccessful buyers retain their own money");
            Check(closed,"closed trade requests cannot spend currency");
            Actor.Spawn('CaelumWorkbenchStation',(-24,0,0),NO_REPLACE);
            Actor.Spawn('CaelumAlchemyStation',(24,0,0),NO_REPLACE);
            for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
            {
                let user=CaelumPlayer(players[i].mo);
                let fuelStack=CaelumMaterialPickup(Actor.Spawn('CaelumMaterialPickup',user.Pos,NO_REPLACE));
                fuelStack.args[0]=CaelumConstants.MATERIAL_COAL;fuelStack.args[1]=1;fuelStack.Amount=200+i;fuelStack.AttachToOwner(user);
                Water[i]=CaelumWaterContainer(user.GiveInventoryType('CaelumCanteenLarge'));
                Water[i].WaterLiters=.2+i*.05;Water[i].WaterQuality=CaelumWaterQuality.BIOLOGICAL;
                Water[i].WaterQualityRevision=1;Water[i].WaterTemperatureC=20;Water[i].WaterTemperatureRevision=1;
                Water[i].StampTemperature(user);Liters[i]=Water[i].WaterLiters;
                Coal[i]=user.CountCraftingMaterial(CaelumConstants.MATERIAL_COAL,1);
                user.OnNativeInventoryChanged();user.RefreshFormalInventorySnapshot();
                for(int n=0;n<user.FormalInventoryEntryCount;n++)if(user.GetFormalInventoryEntryAt(n)==Water[i])user.FormalInventorySelectionIndex=n;
            }
            Phase=2;return;
        }
        if(Phase==2)
        {
            bool owners=true,reserved=true;
            for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])
            {
                let user=CaelumPlayer(players[i].mo);let brew=CaelumWaterBoilingState.Find(user);
                owners=owners && user.CraftingTaskActive && brew!=null && brew.Container==Water[i] && Water[i].Owner==user;
                Fuel[i]=brew!=null?brew.FuelUnits:0;
                Console.Printf("CA435SESSION DEBUG fuel slot=%d before=%d now=%d reservation=%d",i,Coal[i],user.CountCraftingMaterial(CaelumConstants.MATERIAL_COAL,1),Fuel[i]);
                reserved=reserved && Fuel[i]>0 && Coal[i]==user.CountRawCraftingMaterial(CaelumConstants.MATERIAL_COAL,1)
                    && user.CountCraftingMaterial(CaelumConstants.MATERIAL_COAL,1)==Coal[i]-Fuel[i];
            }
            Check(owners,"simultaneous chemistry tasks retain each sender's actual container");
            Check(reserved,"duplicate starts do not consume or duplicate fuel reservations");
            Check(!CaelumWaterBoiling.Begin(CaelumPlayer(players[0].mo),Water[1]),"another player's vessel cannot be processed");
            Phase=3;return;
        }
        if(Phase==3)
        {
            let first=CaelumPlayer(players[0].mo);
            Check(!first.CraftingTaskActive && Abs(Water[0].WaterLiters-Liters[0])<.000001
                && first.CountCraftingMaterial(CaelumConstants.MATERIAL_COAL,1)==Coal[0],"one sender cancels without consuming its resources");
            bool completed=true,once=true;
            for(int i=1;i<MAXPLAYERS;i++)if(playeringame[i])
            {
                let user=CaelumPlayer(players[i].mo);
                // Punto final diagnóstico; no simula ni adelanta el reloj compartido.
                user.CompleteCraftingTask();int remaining=user.CountCraftingMaterial(CaelumConstants.MATERIAL_COAL,1);
                completed=completed && !user.CraftingTaskActive && remaining==Coal[i]-Fuel[i]
                    && Water[i].WaterQuality==0 && Abs(Water[i].WaterLiters-CaelumWaterThermalData.Output(Liters[i]))<.000001;
                user.CompleteCraftingTask();once=once && remaining==user.CountCraftingMaterial(CaelumConstants.MATERIAL_COAL,1);
            }
            Check(completed,"other owners complete once with their own fuel and output");
            Check(once,"repeated completion does not spend fuel twice");
            Phase=5;Console.Printf("CA435SESSION RESULT gameplay peer=%d players=%d",consoleplayer,Count);
        }
    }
}
