// #444: el depósito conserva los objetos nativos; las fichas sólo registran custodia.
class CaelumTrucazoVault : Actor
{
    Default {Radius 1;Height 1;+NOGRAVITY +NOBLOCKMAP +NOSECTOR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CaelumTrucazoClaimEntry : Object
{
    Inventory Item;
    bool Ready,WasBoxed;
    String Label;
}
class CaelumTrucazoClaims : Inventory
{
    int Revision,Serial;
    double Copper;
    CaelumTrucazoVault Vault;
    CaelumCardDuel Reservation;
    Array<CaelumTrucazoClaimEntry> Entries;
    Array<int> TravelTIDs;
    String Status;
    static clearscope CaelumTrucazoClaims Read(CaelumPlayer user)
    {return user==null?null:CaelumTrucazoClaims(user.FindInventory('CaelumTrucazoClaims'));}
    static CaelumTrucazoClaims Get(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user))return null;
        let claims=Read(user);if(claims==null)claims=CaelumTrucazoClaims(user.GiveInventoryType('CaelumTrucazoClaims'));
        if(claims!=null)claims.Revision=CaelumTrucazoData.WAGER_REVISION;
        user.GetPersistentCharacterState(true).EnsureTrucazo();return claims;
    }
    bool EnsureVault()
    {if(Vault==null)Vault=CaelumTrucazoVault(Actor.Spawn('CaelumTrucazoVault',Owner.Pos,NO_REPLACE));return Vault!=null;}
    clearscope int Pending() const
    {int n=0;for(int i=0;i<int(Entries.Size());i++)if(Entries[i].Ready)n++;return n;}
    bool ClaimItem(CaelumPlayer user,int index)
    {
        if(index<0 || index>=int(Entries.Size()))return false;
        let entry=Entries[index];let item=entry.Item;
        if(!entry.Ready || item==null || item.Owner!=Vault || !CaelumContainerRules.Allowed(user,item,false))return false;
        user.RefreshCarriedInventorySummary();double weight=CaelumContainerRules.Weight(user,item);
        bool fits=false,boxed=false;
        for(int route=0;route<2;route++)
        {
            boxed=entry.WasBoxed?route==0:route==1;
            if(boxed && (!user.MagicBoxOwned || !CaelumContainerRules.CanBox(item) || !CaelumTarotStar.CanBox(user,item,item.Amount)))continue;
            if(user.PalomoTransactionCapacityFits(boxed?0:weight,boxed?weight:0,boxed?1:0)){fits=true;break;}
        }
        if(!fits)return false;
        // Adjuntar la instancia completa evita perder tamaño, desgaste, llaves o lotes.
        Vault.RemoveInventory(item);CaelumContainerRules.SetBoxed(item,boxed);item.AttachToOwner(user);
        let equipment=CaelumEquipmentItem(item);if(equipment!=null)user.EnsureEquipmentItemId(equipment);
        CaelumFoodInventory.Relocate(item);entry.Item=null;Entries.Delete(index);
        user.OnNativeInventoryChanged();user.RefreshFormalInventorySnapshot();return true;
    }
    bool ClaimMoney(CaelumPlayer user)
    {
        if(Copper<1)return false;
        int amount=int(Min(double(CaelumTrucazoData.MAX_COPPER_OPERATION),Copper));
        if(!CaelumTrucazoWagers.PrepareMoney(user,amount,false))return false;
        Array<CaelumCurrencyItem> prepared;
        if(!CaelumInventoryService.PrepareMerchantCurrencyObjects(user,prepared))return false;
        CaelumInventoryService.AttachMerchantCurrencyObjects(user,prepared);
        if(!user.ApplyPalomoCurrencyPlan())return false;
        Copper-=amount;user.OnNativeInventoryChanged();return true;
    }
    bool Claim(CaelumPlayer user,int expectedSerial)
    {
        if(Owner!=user || expectedSerial!=Serial || !CaelumPlayerAuthority.CanMutate(user) || user.health<=0)return false;
        bool changed=ClaimMoney(user);
        for(int i=int(Entries.Size())-1;i>=0;i--)if(ClaimItem(user,i))changed=true;
        Status=Copper>=1 || Pending()>0?"CA_TC3_CAPACITY":"CA_TC3_CLAIMED";Serial++;return changed;
    }
    override void PreTravelled()
    {
        Super.PreTravelled();if(Vault==null)return;TravelTIDs.Clear();
        Vault.bNoInteraction=false;Vault.A_ChangeLinkFlags(1,1);
        Vault.UnlinkFromWorld();Vault.ChangeStatNum(STAT_TRAVELLING);
        for(Inventory item=Vault.Inv;item!=null;item=item.Inv)
        {item.PreTravelled();CaelumStudyUse.ClearContacts(item);TravelTIDs.Push(item.TID);item.ChangeTid(0);item.UnlinkFromWorld();item.ChangeStatNum(STAT_TRAVELLING);}
    }
    override void Travelled()
    {
        Super.Travelled();if(Vault==null || Owner==null)return;
        Vault.ChangeStatNum(STAT_DEFAULT);Vault.SetOrigin(Owner.Pos,false);Vault.LinkToWorld();Vault.FindFloorCeiling();
        int n=0;for(Inventory item=Vault.Inv;item!=null;item=item.Inv)
        {item.SetOrigin(Owner.Pos,false);item.FindFloorCeiling();item.ChangeStatNum(STAT_INVENTORY);item.LinkToWorld();if(n<int(TravelTIDs.Size()))item.ChangeTid(TravelTIDs[n++]);item.Travelled();}
        TravelTIDs.Clear();
    }
    override void Tick()
    {
        Super.Tick();let user=CaelumPlayer(Owner);
        // El depósito sólo sigue al cuerpo real; nunca a predicción ni a una plaza desconectada.
        if(CaelumPlayerAuthority.CanRead(user) && playeringame[user.PlayerNumber()]
            && !(user.player.cheats&CF_PREDICTING) && Vault!=null && Vault.Pos!=user.Pos)Vault.SetOrigin(user.Pos,false);
    }
    override Inventory CreateTossable(int amount){return null;}
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE -INVENTORY.INVBAR}
}
class CaelumTrucazoWagerView : Inventory
{
    Array<Inventory> Rows;
    Array<String> Labels;
    Array<int> Amounts;
    Array<bool> Splittable;
    double Money;
    String Status;
    static clearscope CaelumTrucazoWagerView Read(CaelumPlayer user)
    {return user==null?null:CaelumTrucazoWagerView(user.FindInventory('CaelumTrucazoWagerView'));}
    static CaelumTrucazoWagerView Refresh(CaelumPlayer user)
    {
        let view=Read(user);if(view==null)view=CaelumTrucazoWagerView(user.GiveInventoryType('CaelumTrucazoWagerView'));
        if(view==null)return null;
        view.Rows.Clear();view.Labels.Clear();view.Amounts.Clear();view.Splittable.Clear();view.Money=user.GetOwnedMoneyCopperValue();
        // Sólo el inventario propio, bajo solicitud; nunca una búsqueda global por tic.
        for(Inventory item=user.Inv;item!=null;item=item.Inv)if(CaelumTrucazoWagers.Eligible(user,item))
        {view.Rows.Push(item);view.Labels.Push(CaelumNotifications.Describe(user,item,0));view.Amounts.Push(item.Amount);view.Splittable.Push(CaelumContainerRules.Stackable(item));}
        return view;
    }
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE -INVENTORY.INVBAR}
}
class CaelumTrucazoOffer : Object
{
    Inventory Item,Prepared;
    int Seat,Quantity,Recipient,OriginalAmount;
    bool WasBoxed;
    String Label;
    CaelumTrucazoClaimEntry Claim;
}
class CaelumTrucazoMoneyPlan : Object {Array<CaelumCurrencyItem> Prepared;}
class CaelumTrucazoWagers : Object play
{
    enum Request { REFRESH, SET_COINS, REMOVE_ITEM, CYCLE_RECIPIENT, ADD_ITEM }
    int Revision;
    CaelumCardDuel Duel;
    Array<int> Coins;
    Array<CaelumTrucazoOffer> Offers;
    bool Reserved,Settled;
    static CaelumTrucazoWagers Create(CaelumCardDuel duel)
    {let w=new('CaelumTrucazoWagers');w.Revision=CaelumTrucazoData.WAGER_REVISION;w.Duel=duel;for(int i=0;i<duel.Count();i++)w.Coins.Push(0);return w;}
    static bool Eligible(CaelumPlayer user,Inventory item)
    {
        if(item==null || item.Owner!=user || item.Amount<=0 || item is 'CaelumCurrencyItem'
            || item is 'CaelumMagicBox' || item is 'CaelumTarotDeck' || item is 'CaelumHuntEssence'
            || item is 'CaelumChestCargo' || item is 'CaelumSunCargo' || item is 'CaelumWeightedKey')return false;
        int kind=user.GetFormalInventoryEntryKind(item);
        if(kind<0 || (kind==CaelumConstants.EQUIPMENT_KIND_KEY_ITEM && !(item is 'CaelumLockItem')))return false;
        let special=CaelumSpecialInventoryItem(item);if(special!=null && (special.LimboSupplyUnits>0 || special.LimboQuotaReserved))return false;
        return CaelumCityTradeSession.Sellable(user,item);
    }
    static bool PrepareMoney(CaelumPlayer user,int copper,bool paying)
    {
        user.RefreshCarriedInventorySummary();
        for(int route=0;route<2;route++)
        {
            if(!(paying?user.BuildPalomoCurrencyPaymentPlan(copper):user.BuildPalomoCurrencyCreditPlan(copper)))return false;
            if(route==1){if(!user.MagicBoxOwned)continue;user.RoutePalomoCurrencyGainsToMagicBox();}
            if(user.PalomoTransactionCapacityFits(user.GetPalomoCurrencyPlanPersonalWeightDelta(),user.GetPalomoCurrencyPlanBoxRawWeightDelta(),user.GetPalomoCurrencyPlanBoxSlotDelta()))return true;
        }
        return false;
    }
    bool Edit(int seat,int operation,int argument,int quantity)
    {
        if(Reserved || seat<0 || seat>=Duel.Count())return false;
        let user=Duel.Member(seat);let view=CaelumTrucazoWagerView.Read(user);
        if(operation==REFRESH)return CaelumTrucazoWagerView.Refresh(user)!=null;
        if(operation==SET_COINS)
        {if(argument<0 || argument>user.GetOwnedMoneyCopperValue())return false;Coins[seat]=argument;return true;}
        if(operation==ADD_ITEM)
        {
            if(view==null || argument<0 || argument>=int(view.Rows.Size()))return false;
            let item=view.Rows[argument];if(!Eligible(user,item) || quantity<=0 || quantity>item.Amount || (quantity!=item.Amount && !CaelumContainerRules.Stackable(item)))return false;
            for(int i=0;i<int(Offers.Size());i++)if(Offers[i].Item==item)return false;
            let offer=new('CaelumTrucazoOffer');offer.Item=item;offer.Seat=seat;offer.Quantity=quantity;offer.OriginalAmount=item.Amount;
            offer.WasBoxed=CaelumContainerRules.Boxed(item);offer.Label=CaelumNotifications.Describe(user,item,quantity);
            int prior=0;for(int i=0;i<int(Offers.Size());i++)if(Offers[i].Seat%2==seat%2)prior++;
            offer.Recipient=(1-seat%2)+2*(prior%(Duel.Count()/2));Offers.Push(offer);return true;
        }
        if(argument<0 || argument>=int(Offers.Size()))return false;
        if(operation==REMOVE_ITEM && Offers[argument].Seat==seat){Offers.Delete(argument);return true;}
        if(operation==CYCLE_RECIPIENT){Offers[argument].Recipient=(Offers[argument].Recipient+2)%Duel.Count();return true;}
        return false;
    }
    bool Reserve()
    {
        if(Reserved)return true;
        Array<CaelumTrucazoMoneyPlan> plans;Array<CaelumTrucazoClaims> claims;
        bool valid=true;
        for(int s=0;s<Duel.Count();s++)
        {
            let user=Duel.Member(s);let claim=CaelumTrucazoClaims.Get(user);claims.Push(claim);
            let plan=new('CaelumTrucazoMoneyPlan');plans.Push(plan);
            if(claim==null || (claim.Reservation!=null && claim.Reservation!=Duel) || !claim.EnsureVault() || !PrepareMoney(user,Coins[s],true)
                || !CaelumInventoryService.PrepareMerchantCurrencyObjects(user,plan.Prepared)){valid=false;break;}
        }
        if(valid)for(int i=0;i<int(Offers.Size());i++)
        {
            let offer=Offers[i];let user=Duel.Member(offer.Seat);
            if(!Eligible(user,offer.Item) || offer.Item.Amount!=offer.OriginalAmount || offer.Recipient%2==offer.Seat%2
                || offer.Quantity<=0 || offer.Quantity>offer.Item.Amount){valid=false;break;}
            if(offer.Quantity<offer.Item.Amount)
            {
                offer.Prepared=Inventory(Actor.Spawn(offer.Item.GetClass(),user.Pos,NO_REPLACE));
                if(offer.Prepared==null){valid=false;break;}
                for(int a=0;a<5;a++)offer.Prepared.args[a]=offer.Item.args[a];offer.Prepared.Amount=offer.Quantity;
            }
        }
        if(!valid)
        {
            for(int p=0;p<int(plans.Size());p++)for(int c=0;c<int(plans[p].Prepared.Size());c++)if(plans[p].Prepared[c]!=null && !plans[p].Prepared[c].bDestroyed)plans[p].Prepared[c].Destroy();
            for(int i=0;i<int(Offers.Size());i++)if(Offers[i].Prepared!=null){Offers[i].Prepared.Destroy();Offers[i].Prepared=null;}
            return false;
        }
        // Todos los objetos faltantes están preasignados antes de debitar al primer jugador.
        for(int s=0;s<Duel.Count();s++)
        {let user=Duel.Member(s);CaelumInventoryService.AttachMerchantCurrencyObjects(user,plans[s].Prepared);user.ApplyPalomoCurrencyPlan();claims[s].Reservation=Duel;}
        for(int i=0;i<int(Offers.Size());i++)
        {
            let offer=Offers[i];let source=offer.Item;let item=offer.Prepared!=null?offer.Prepared:source;
            CaelumFoodInventory.Reconcile(source);
            if(item!=source){CaelumFoodInventory.Transfer(source,item,offer.Quantity,true);source.Amount-=offer.Quantity;}
            else source.Owner.RemoveInventory(source);
            let claim=claims[offer.Seat];CaelumContainerRules.SetBoxed(item,false);item.AttachToOwner(claim.Vault);CaelumFoodInventory.Relocate(item);
            let entry=new('CaelumTrucazoClaimEntry');entry.Item=item;entry.WasBoxed=offer.WasBoxed;entry.Label=offer.Label;
            claim.Entries.Push(entry);offer.Claim=entry;offer.Prepared=null;
        }
        Reserved=true;for(int s=0;s<Duel.Count();s++)Duel.Member(s).OnNativeInventoryChanged();return true;
    }
    void Settle()
    {
        if(!Reserved || Settled || Duel.Advanced==null || !Duel.Advanced.Finished() || !Duel.Connected())return;
        int winner=Duel.Advanced.Winner,size=Duel.Count()/2;double lost=0;
        for(int s=0;s<Duel.Count();s++)if(s%2!=winner)lost+=Coins[s];
        double share=floor(lost/size);int remainder=int(lost-share*size);
        for(int i=0;i<Duel.Count();i++)
        {
            int s=(Duel.Advanced.Mano+i)%Duel.Count();if(s%2!=winner)continue;
            let user=Duel.Member(s);let claim=CaelumTrucazoClaims.Read(user);
            claim.Copper+=Coins[s]+share+(remainder>0?1:0);if(remainder>0)remainder--;
            let record=user.GetPersistentCharacterState(true);record.EnsureTrucazo();record.TrucazoReputation=Min(CaelumTrucazoData.REPUTATION_MAX,record.TrucazoReputation+CaelumTrucazoData.REPUTATION_WIN);
        }
        for(int i=0;i<int(Offers.Size());i++)
        {
            let offer=Offers[i];int receiver=offer.Seat%2==winner?offer.Seat:offer.Recipient;
            let from=CaelumTrucazoClaims.Read(Duel.Member(offer.Seat));let to=CaelumTrucazoClaims.Read(Duel.Member(receiver));let entry=offer.Claim;
            if(from!=to)
            {
                from.Vault.RemoveInventory(entry.Item);entry.Item.AttachToOwner(to.Vault);
                for(int j=0;j<int(from.Entries.Size());j++)if(from.Entries[j]==entry){from.Entries.Delete(j);break;}
                to.Entries.Push(entry);
            }
            entry.Ready=true;
        }
        Settled=true;
        for(int s=0;s<Duel.Count();s++)
        {let user=Duel.Member(s);let claim=CaelumTrucazoClaims.Read(user);claim.Reservation=null;claim.Claim(user,claim.Serial);user.PersistCharacterState();}
    }
}
