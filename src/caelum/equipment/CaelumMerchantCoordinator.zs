// #377: coordinación de comercio; cada sesión conserva su propietario.
// Inventario, dinero y transferencias se confirman en el servicio compartido.
class CaelumMerchantCoordinator : Object play
{
    static int GetPalomoMerchantQuantityForIndex(CaelumPlayer user, int quantityIndex)
    {
        switch (Clamp(quantityIndex, 0,
            CaelumConstants.PALOMO_MERCHANT_QUANTITY_OPTION_COUNT - 1))
        {
            case 1: return 5;
            case 2: return 20;
            case 3: return 50;
            case 4: return 100;
            default: return 1;
        }
    }

    static int GetPalomoMerchantConsumableType(CaelumPlayer user, int merchantItem)
    {
        if (merchantItem == CaelumConstants.PALOMO_MERCHANT_ITEM_FOOD)
        { return CaelumConstants.CONSUMABLE_FOOD_RATION; }
        if (merchantItem == CaelumConstants.PALOMO_MERCHANT_ITEM_WATER)
        { return CaelumConstants.CONSUMABLE_WATER_RATION; }
        return -1;
    }

    static int GetPalomoMerchantMaterialType(CaelumPlayer user, int merchantItem)
    {
        switch (merchantItem)
        {
            case CaelumConstants.PALOMO_MERCHANT_ITEM_WOOD:
                return CaelumConstants.MATERIAL_WOOD;
            case CaelumConstants.PALOMO_MERCHANT_ITEM_RAW_COPPER:
                return CaelumConstants.MATERIAL_RAW_COPPER;
            case CaelumConstants.PALOMO_MERCHANT_ITEM_RAW_TIN:
                return CaelumConstants.MATERIAL_RAW_TIN;
            default: return -1;
        }
    }

    static bool HasPalomoMerchantReputationDiscount(CaelumPlayer user)
    {
        return user.ActivePalomoMerchantDiscountCondition != null
            && CaelumFactionCondition.Check(user, user.ActivePalomoMerchantDiscountCondition)
                == CaelumFactionCondition.ALLOWED;
    }

    static void RefreshPalomoMerchantSnapshot(CaelumPlayer user)
    {
        if(user.CityTrade!=null){user.CityTrade.Refresh(user);return;}
        user.PalomoMerchantSelection = Clamp(user.PalomoMerchantSelection, 0,
            CaelumConstants.PALOMO_MERCHANT_ITEM_COUNT - 1);
        user.PalomoMerchantMode = Clamp(user.PalomoMerchantMode,
            CaelumConstants.PALOMO_MERCHANT_MODE_BUY,
            CaelumConstants.PALOMO_MERCHANT_MODE_SELL);
        user.PalomoMerchantQuantityIndex = Clamp(user.PalomoMerchantQuantityIndex, 0,
            CaelumConstants.PALOMO_MERCHANT_QUANTITY_OPTION_COUNT - 1);
        CaelumPersistentCharacterState persistentState =
            user.GetPersistentCharacterState(true);
        if (persistentState == null) { return; }
        persistentState.EnsurePalomoMerchantInitialized();
        persistentState.EnsurePalomoDiscountInitialized();
        user.PalomoMerchantDiscountGranted =
            persistentState.PalomoDiscountGranted;
        // Esta rebaja es de la sesión: nunca se guarda como rebaja negociada.
        user.PalomoMerchantReputationDiscount = user.HasPalomoMerchantReputationDiscount();
        for (int merchantItem = 0;
            merchantItem < CaelumConstants.PALOMO_MERCHANT_ITEM_COUNT; merchantItem++)
        {
            user.PalomoMerchantStock[merchantItem] = Max(0,
                persistentState.PalomoMerchantStock[merchantItem]);
            user.PalomoMerchantPlayerOwned[merchantItem] =
                user.CountPalomoMerchantProduct(merchantItem, false);
        }
        user.PalomoMerchantWalletCopper = Max(0,
            persistentState.PalomoMerchantWalletCopper);
        user.PalomoMerchantVisibleItemCount = 0;
        bool currentSelectionVisible = false;
        for (int merchantItem = 0;
            merchantItem < CaelumConstants.PALOMO_MERCHANT_ITEM_COUNT;
            merchantItem++)
        {
            bool visible = user.PalomoMerchantMode
                    == CaelumConstants.PALOMO_MERCHANT_MODE_BUY
                || (user.PalomoMerchantPlayerOwned[merchantItem] > 0
                    && user.PalomoMerchantWalletCopper
                        >= CaelumEconomyRules.GetPalomoMerchantLotPrice(
                            merchantItem, 1,
                            CaelumConstants.PALOMO_MERCHANT_MODE_SELL,
                            user.PalomoMerchantDiscountGranted || user.PalomoMerchantReputationDiscount
                        ));
            if (!visible) { continue; }

            user.PalomoMerchantVisibleItems[user.PalomoMerchantVisibleItemCount] =
                merchantItem;
            user.PalomoMerchantVisibleItemCount++;
            if (merchantItem == user.PalomoMerchantSelection)
            {
                currentSelectionVisible = true;
            }
        }
        for (int visibleIndex = user.PalomoMerchantVisibleItemCount;
            visibleIndex < CaelumConstants.PALOMO_MERCHANT_ITEM_COUNT;
            visibleIndex++)
        {
            user.PalomoMerchantVisibleItems[visibleIndex] = -1;
        }
        if (!currentSelectionVisible && user.PalomoMerchantVisibleItemCount > 0)
        {
            user.PalomoMerchantSelection = user.PalomoMerchantVisibleItems[0];
        }
        user.PalomoMerchantSelectedQuantity =
            user.GetPalomoMerchantQuantityForIndex(user.PalomoMerchantQuantityIndex);
        user.PalomoMerchantSelectedLotPrice = user.PalomoMerchantVisibleItemCount > 0
            ? CaelumEconomyRules.GetPalomoMerchantLotPrice(
                user.PalomoMerchantSelection, user.PalomoMerchantSelectedQuantity,
                user.PalomoMerchantMode, user.PalomoMerchantDiscountGranted || user.PalomoMerchantReputationDiscount)
            : 0;
        user.RefreshCarriedInventorySummary();
    }

    static bool IsActivePalomoMerchantSessionValid(CaelumPlayer user)
    {
        if (!user.PalomoMerchantMenuOpen || user.ActivePalomoMerchant == null
            || user.ActivePalomoMerchant.health <= 0 || user.health <= 0) { return false; }
        return user.Distance3D(user.ActivePalomoMerchant)
            <= CaelumConstants.PALOMO_MERCHANT_SESSION_DISTANCE
            && CaelumFactionCondition.Check(user, user.ActivePalomoMerchantRequirement)
                == CaelumFactionCondition.ALLOWED;
    }

    static void OpenPalomoMerchant(CaelumPlayer user, Actor merchant, CaelumFactionCondition requirement = null, CaelumFactionCondition discount = null, String titleKey = "CA_PALOMO_MERCHANT_TITLE")
    {
        user.SyncPalomoDialogueTokens();
        if (user.CreationWizardOpen || merchant == null) { return; }
        CaelumPoiKnowledge.RecordUse(user,merchant,CaelumPoiData.MERCHANT);
        if (!user.MagicBoxOwned) { return; }
        if (!CaelumFactionCondition.Require(user, requirement)) return;
        if (user.StaffCastPending) { user.CancelPendingStaffCast(false); }
        user.EquipmentMenuOpen = false;
        user.CloseCraftingStationSession();
        user.SetCraftingJournalState(false);
        // Cambiar de vendedor retira la proyección anterior, no su stock.
        user.ClosePalomoMerchant();
        user.ActivePalomoMerchant = merchant;
        user.ActivePalomoMerchantRequirement = requirement;
        user.ActivePalomoMerchantDiscountCondition = discount;
        user.PalomoMerchantTitleKey = titleKey;
        user.PalomoMerchantMenuOpen = true;
        user.PalomoMerchantSessionValidationTics = 0;
        user.PalomoMerchantSelection = Clamp(user.PalomoMerchantSelection, 0,
            CaelumConstants.PALOMO_MERCHANT_ITEM_COUNT - 1);
        user.PalomoMerchantMode = Clamp(user.PalomoMerchantMode,
            CaelumConstants.PALOMO_MERCHANT_MODE_BUY,
            CaelumConstants.PALOMO_MERCHANT_MODE_SELL);
        user.LastPalomoMerchantAction = CaelumConstants.PALOMO_MERCHANT_ACTION_NONE;
        user.RefreshPalomoMerchantSnapshot();
    }

    static void ClosePalomoMerchant(CaelumPlayer user)
    {
        user.CityTrade=null;
        user.PalomoMerchantMenuOpen = false;
        user.ActivePalomoMerchant = null;
        user.ActivePalomoMerchantRequirement = null;
        user.ActivePalomoMerchantDiscountCondition = null;
        user.PalomoMerchantReputationDiscount = false;
        user.PalomoMerchantTitleKey = "";
        user.PalomoMerchantSessionValidationTics = 0;
        if (user.FolkloreInteractionUseLatched)
        {
            user.FolkloreInteractionReleaseGuardTics =
                CaelumConstants.PALOMO_INTERACTION_REARM_GUARD_TICS;
        }
    }

    static void UpdatePalomoMerchantSession(CaelumPlayer user)
    {
        if (!user.PalomoMerchantMenuOpen) { return; }
        user.PalomoMerchantSessionValidationTics++;
        if (user.PalomoMerchantSessionValidationTics < 4) { return; }
        user.PalomoMerchantSessionValidationTics = 0;
        if (!user.IsActivePalomoMerchantSessionValid())
        {
            CaelumFactionCondition.Require(user, user.ActivePalomoMerchantRequirement);
            user.LastPalomoMerchantAction =
                CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_SESSION;
            user.ClosePalomoMerchant();
        }
        else if (user.PalomoMerchantReputationDiscount != user.HasPalomoMerchantReputationDiscount())
        {
            user.RefreshPalomoMerchantSnapshot();
            user.LastPalomoMerchantAction = CaelumConstants.PALOMO_MERCHANT_ACTION_PRICE_CHANGED;
        }
    }

    static void CyclePalomoMerchantSelection(CaelumPlayer user, int direction)
    {
        if (!user.IsActivePalomoMerchantSessionValid()) { return; }
        if(user.CityTrade!=null){user.CityTrade.Cycle(user,direction);return;}
        user.RefreshPalomoMerchantSnapshot();
        if (user.PalomoMerchantVisibleItemCount <= 0) { return; }
        int currentVisibleIndex = 0;
        for (int visibleIndex = 0;
            visibleIndex < user.PalomoMerchantVisibleItemCount; visibleIndex++)
        {
            if (user.PalomoMerchantVisibleItems[visibleIndex]
                == user.PalomoMerchantSelection)
            {
                currentVisibleIndex = visibleIndex;
                break;
            }
        }
        currentVisibleIndex = (currentVisibleIndex
            + (direction < 0 ? user.PalomoMerchantVisibleItemCount - 1 : 1))
            % user.PalomoMerchantVisibleItemCount;
        user.PalomoMerchantSelection =
            user.PalomoMerchantVisibleItems[currentVisibleIndex];
        user.LastPalomoMerchantAction = CaelumConstants.PALOMO_MERCHANT_ACTION_NONE;
        user.RefreshPalomoMerchantSnapshot();
    }

    static void TogglePalomoMerchantMode(CaelumPlayer user)
    {
        if (!user.IsActivePalomoMerchantSessionValid()) { return; }
        user.PalomoMerchantMode = user.PalomoMerchantMode
            == CaelumConstants.PALOMO_MERCHANT_MODE_BUY
            ? CaelumConstants.PALOMO_MERCHANT_MODE_SELL
            : CaelumConstants.PALOMO_MERCHANT_MODE_BUY;
        user.LastPalomoMerchantAction = CaelumConstants.PALOMO_MERCHANT_ACTION_NONE;
        user.RefreshPalomoMerchantSnapshot();
    }

    static void CyclePalomoMerchantQuantity(CaelumPlayer user, int direction)
    {
        if (!user.IsActivePalomoMerchantSessionValid()) { return; }
        if(user.CityTrade!=null && user.CityTrade.Vendor.Category==CaelumShopCatalogue.LIBRARY && !user.CityTrade.Selling)
        {
            user.CityTrade.CategoryFilter=(user.CityTrade.CategoryFilter+(direction<0 ? CaelumConstants.CRAFTING_RECIPE_FILTER_COUNT-1 : 1))
                %CaelumConstants.CRAFTING_RECIPE_FILTER_COUNT;
            user.CityTrade.Selection=0;user.LastPalomoMerchantAction=CaelumConstants.PALOMO_MERCHANT_ACTION_NONE;
            user.CityTrade.Refresh(user);return;
        }
        user.PalomoMerchantQuantityIndex = (user.PalomoMerchantQuantityIndex
            + (direction < 0
                ? CaelumConstants.PALOMO_MERCHANT_QUANTITY_OPTION_COUNT - 1
                : 1))
            % CaelumConstants.PALOMO_MERCHANT_QUANTITY_OPTION_COUNT;
        user.LastPalomoMerchantAction = CaelumConstants.PALOMO_MERCHANT_ACTION_NONE;
        user.RefreshPalomoMerchantSnapshot();
    }

    static void ExecutePalomoMerchantTransaction(CaelumPlayer user)
    {
        if(user.CityTrade!=null){user.CityTrade.Execute(user);return;}
        if (!user.IsActivePalomoMerchantSessionValid())
        {
            CaelumFactionCondition.Require(user, user.ActivePalomoMerchantRequirement);
            user.LastPalomoMerchantAction =
                CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_SESSION;
            user.ClosePalomoMerchant();
            return;
        }
        int quotedPrice = user.PalomoMerchantSelectedLotPrice;
        int quotedItem = user.PalomoMerchantSelection;
        int quotedMode = user.PalomoMerchantMode;
        int quotedQuantity = user.PalomoMerchantSelectedQuantity;
        user.RefreshCarriedInventorySummary();
        user.RefreshPalomoMerchantSnapshot();
        if (quotedPrice != user.PalomoMerchantSelectedLotPrice
            || quotedItem != user.PalomoMerchantSelection
            || quotedMode != user.PalomoMerchantMode
            || quotedQuantity != user.PalomoMerchantSelectedQuantity)
        {
            user.LastPalomoMerchantAction = CaelumConstants.PALOMO_MERCHANT_ACTION_PRICE_CHANGED;
            return;
        }
        CaelumPersistentCharacterState persistentState =
            user.GetPersistentCharacterState(true);
        if (persistentState == null) { return; }
        persistentState.EnsurePalomoMerchantInitialized();
        persistentState.EnsurePalomoDiscountInitialized();
        user.PalomoMerchantDiscountGranted =
            persistentState.PalomoDiscountGranted;
        int merchantItem = user.PalomoMerchantSelection;
        int quantity = user.PalomoMerchantSelectedQuantity;
        int price = user.PalomoMerchantSelectedLotPrice;
        if (user.PalomoMerchantVisibleItemCount <= 0)
        {
            user.LastPalomoMerchantAction =
                CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_PLAYER_STOCK;
            return;
        }
        if (user.PalomoMerchantMode == CaelumConstants.PALOMO_MERCHANT_MODE_BUY)
        {
            if (persistentState.PalomoMerchantStock[merchantItem] < quantity)
            {
                user.LastPalomoMerchantAction =
                    CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_STOCK;
                return;
            }
            if (user.GetOwnedMoneyCopperValue() + 0.0001 < price)
            {
                user.LastPalomoMerchantAction =
                    CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_PLAYER_MONEY;
                return;
            }
            if (!user.PreparePalomoPurchaseCapacity(merchantItem, quantity, price))
            {
                user.LastPalomoMerchantAction =
                    CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_CAPACITY;
                return;
            }
            if (!CaelumInventoryService.CommitPalomoProductAndCurrency(user, merchantItem, quantity, false))
            {
                user.LastPalomoMerchantAction =
                    CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_SESSION;
                return;
            }
            persistentState.PalomoMerchantStock[merchantItem] -= quantity;
            if (persistentState.PalomoMerchantWalletCopper > 2147483647 - price)
            { persistentState.PalomoMerchantWalletCopper = 2147483647; }
            else { persistentState.PalomoMerchantWalletCopper += price; }
            user.LastPalomoMerchantAction = CaelumConstants.PALOMO_MERCHANT_ACTION_BOUGHT;
        }
        else
        {
            int available = user.CountPalomoMerchantProduct(merchantItem, false);
            if (available < quantity)
            {
                int physical = user.CountPalomoMerchantProduct(merchantItem, true);
                user.LastPalomoMerchantAction = physical >= quantity
                    ? CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_RESERVED
                    : CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_PLAYER_STOCK;
                return;
            }
            if (persistentState.PalomoMerchantWalletCopper < price)
            {
                user.LastPalomoMerchantAction =
                    CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_MERCHANT_MONEY;
                return;
            }
            if (!user.PreparePalomoSaleCapacity(merchantItem, quantity, price))
            {
                user.LastPalomoMerchantAction =
                    CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_CAPACITY;
                return;
            }
            if (!CaelumInventoryService.CommitPalomoProductAndCurrency(user, merchantItem, quantity, true))
            {
                user.LastPalomoMerchantAction =
                    CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_SESSION;
                return;
            }
            if (persistentState.PalomoMerchantStock[merchantItem]
                > 2147483647 - quantity)
            { persistentState.PalomoMerchantStock[merchantItem] = 2147483647; }
            else { persistentState.PalomoMerchantStock[merchantItem] += quantity; }
            persistentState.PalomoMerchantWalletCopper -= price;
            user.LastPalomoMerchantAction = CaelumConstants.PALOMO_MERCHANT_ACTION_SOLD;
        }
        user.ApplyCharacterProfile();
        user.RefreshCarriedInventorySummary();
        user.RefreshFormalInventorySnapshot();
        user.RefreshPalomoMerchantSnapshot();
        user.PersistCharacterState();
        user.A_StartSound("caelum/ui/menu_select", CHAN_6, CHANF_LOCAL | CHANF_UI);
    }

    static void OpenCityTrade(CaelumPlayer user,CaelumCityMerchant vendor)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || vendor==null || user.CreationWizardOpen || !user.MagicBoxOwned)return;
        if(user.StaffCastPending)user.CancelPendingStaffCast(false);
        user.EquipmentMenuOpen=false;user.CloseCraftingStationSession();user.SetCraftingJournalState(false);
        user.ClosePalomoMerchant();
        vendor.EnsureStock(user);
        let session=new("CaelumCityTradeSession");session.Vendor=vendor;user.CityTrade=session;
        user.ActivePalomoMerchant=vendor;user.PalomoMerchantTitleKey=String.Format("CA_CITY_SHOP_%d",vendor.Category);
        user.PalomoMerchantMenuOpen=true;user.PalomoMerchantSelection=0;
        user.PalomoMerchantMode=CaelumConstants.PALOMO_MERCHANT_MODE_BUY;
        user.PalomoMerchantDiscountGranted=false;user.PalomoMerchantReputationDiscount=false;
        user.LastPalomoMerchantAction=CaelumConstants.PALOMO_MERCHANT_ACTION_NONE;
        session.Refresh(user);
    }

    static void RefreshCityTrade(CaelumCityTradeSession session,CaelumPlayer user)
    {
        if(!IsCurrentCityTrade(session,user))return;
        session.Selling=user.PalomoMerchantMode==CaelumConstants.PALOMO_MERCHANT_MODE_SELL;
        Inventory selected=session.Selection<session.Rows.Size() ? session.Rows[session.Selection] : null;
        session.Rows.Clear();session.Names.Clear();session.Quantities.Clear();session.Prices.Clear();
        Actor owner=session.Selling ? Actor(user) : Actor(session.Vendor);
        for(Inventory item=owner.Inv;item!=null;item=item.Inv)
        {
            if(item.Amount<=0 || !session.Vendor.Accepts(item) || (session.Selling && !CaelumCityTradeSession.Sellable(user,item)))continue;
            let offer=CaelumRecipeOffer(item);
            if(offer!=null && !CaelumLibrary.MatchesCategory(offer.Recipe,session.CategoryFilter))continue;
            double value=CaelumCityTradeSession.Value(item);
            if(value<=0)continue;
            int price=session.Selling ? CaelumEconomyRules.GetPricePaidByMerchant(value) : CaelumEconomyRules.GetPriceChargedByMerchant(value);
            String label=offer!=null ? CaelumLibrary.NameFor(offer) : CaelumNotifications.Describe(user,item,0);
            if(CaelumCityTradeSession.Companion(item)!=null)label=String.Format(StringTable.Localize("CA_MERCHANT_LOCK_PAIR",false),label);
            session.Rows.Push(item);session.Names.Push(label);session.Quantities.Push(item.Amount);session.Prices.Push(price);
            if(item==selected)session.Selection=session.Rows.Size()-1;
        }
        session.Selection=Clamp(session.Selection,0,Max(0,session.Rows.Size()-1));
        user.PalomoMerchantVisibleItemCount=session.Rows.Size();
        user.PalomoMerchantWalletCopper=session.Vendor.WalletCopper;
        int quantity=user.GetPalomoMerchantQuantityForIndex(user.PalomoMerchantQuantityIndex);
        if(session.Rows.Size()>0 && CaelumCityTradeSession.Single(session.Rows[session.Selection]))quantity=1;
        user.PalomoMerchantSelectedQuantity=quantity;
        user.PalomoMerchantSelectedLotPrice=0;
        if(session.Rows.Size()>0)
        {
            double value=CaelumCityTradeSession.Value(session.Rows[session.Selection]);
            user.PalomoMerchantSelectedLotPrice=session.Selling ? CaelumEconomyRules.GetPricePaidByMerchant(value,quantity)
                : CaelumEconomyRules.GetPriceChargedByMerchant(value,quantity);
        }
        user.RefreshCarriedInventorySummary();
    }

    static void CycleCityTrade(CaelumCityTradeSession session,CaelumPlayer user,int direction)
    {
        if(!IsCurrentCityTrade(session,user))return;
        session.Refresh(user);if(session.Rows.Size()==0)return;
        session.Selection=(session.Selection+(direction<0 ? session.Rows.Size()-1 : 1))%session.Rows.Size();
        user.LastPalomoMerchantAction=CaelumConstants.PALOMO_MERCHANT_ACTION_NONE;session.Refresh(user);
    }

    static bool CapacityCityTrade(CaelumCityTradeSession session,CaelumPlayer user,Inventory item,int quantity,int price,Inventory receiving)
    {
        if(!IsCurrentCityTrade(session,user) || item==null)return false;
        double unit=user.GetFormalInventoryEntryWeight(item)/Max(1,item.Amount);
        let companion=CaelumCityTradeSession.Companion(item);
        if(companion!=null)unit+=companion.GetUnitWeight();
        bool oldBox=CaelumCityTradeSession.Boxed(session.Selling ? item : receiving);
        for(int moneyRoute=0;moneyRoute<2;moneyRoute++)
        {
            if(!(session.Selling ? user.BuildPalomoCurrencyCreditPlan(price) : user.BuildPalomoCurrencyPaymentPlan(price)))return false;
            if(moneyRoute==1){if(!user.MagicBoxOwned)continue;user.RoutePalomoCurrencyGainsToMagicBox();}
            bool canBox=item is "CaelumEquipmentItem" || item is "CaelumConsumableItem" || item is "CaelumCarbineAmmo" || item is "CaelumSpecialInventoryItem";
            for(int productRoute=0;productRoute<(session.Selling || !canBox ? 1 : 2);productRoute++)
            {
                bool box=oldBox || productRoute==1;
                if(box && !user.MagicBoxOwned)continue;
                double personal=user.GetPalomoCurrencyPlanPersonalWeightDelta(),raw=user.GetPalomoCurrencyPlanBoxRawWeightDelta();
                int slots=user.GetPalomoCurrencyPlanBoxSlotDelta();
                double weight=quantity*unit;
                if(session.Selling)
                {
                    if(oldBox){raw-=weight;if(quantity==item.Amount)slots--;}
                    else personal-=weight;
                }
                else if(box)
                {
                    raw+=weight;
                    if(!oldBox)
                    {
                        slots+=companion==null?1:2;
                        if(receiving!=null){double moved=receiving.Amount*unit;personal-=moved;raw+=moved;}
                    }
                }
                else personal+=weight;
                if(user.PalomoTransactionCapacityFits(personal,raw,slots))
                {user.PalomoIncomingItemInMagicBox=box;return true;}
            }
        }
        return false;
    }

    static void ExecuteCityTrade(CaelumCityTradeSession session,CaelumPlayer user)
    {
        if(!IsCurrentCityTrade(session,user) || !user.IsActivePalomoMerchantSessionValid())return;
        if(session.Selection<0 || session.Selection>=session.Rows.Size())return;
        Inventory item=session.Rows[session.Selection];int quote=user.PalomoMerchantSelectedLotPrice;
        session.Refresh(user);
        if(session.Selection>=session.Rows.Size() || session.Rows[session.Selection]!=item || quote!=user.PalomoMerchantSelectedLotPrice)
        {user.LastPalomoMerchantAction=CaelumConstants.PALOMO_MERCHANT_ACTION_PRICE_CHANGED;return;}
        int quantity=user.PalomoMerchantSelectedQuantity,price=user.PalomoMerchantSelectedLotPrice;
        if(item==null || item.Amount<quantity)
        {user.LastPalomoMerchantAction=CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_STOCK;return;}
        let offer=CaelumRecipeOffer(item);CaelumLibraryPurchase library=null;
        if(offer!=null)
        {
            if(session.Selling)return;
            library=new("CaelumLibraryPurchase");library.Build(user,offer);
            if(library.ExtraPages==0)
            {user.LastPalomoMerchantAction=CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_DUPLICATE;return;}
        }
        if((session.Selling && session.Vendor.WalletCopper<price) || (!session.Selling && user.GetOwnedMoneyCopperValue()<price))
        {user.LastPalomoMerchantAction=session.Selling ? CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_MERCHANT_MONEY
            : CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_PLAYER_MONEY;return;}
        if(!session.Selling && session.Vendor.WalletCopper>2147483647-price)return;
        let companion=CaelumCityTradeSession.Companion(item);let lock=CaelumLockItem(item);
        if(lock!=null && lock.MerchantPairedSale && companion==null)
        {user.LastPalomoMerchantAction=CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_STOCK;return;}
        Actor receiver=session.Selling ? Actor(session.Vendor) : Actor(user);
        Inventory receiving=CaelumCityTradeSession.Stack(receiver,item);
        if(receiving!=null && receiving.Amount>receiving.MaxAmount-quantity)
        {user.LastPalomoMerchantAction=CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_CAPACITY;return;}
        if(!(library!=null ? library.Capacity(user,price) : session.Capacity(user,item,quantity,price,receiving)))
        {user.LastPalomoMerchantAction=CaelumConstants.PALOMO_MERCHANT_ACTION_FAILED_CAPACITY;return;}
        if(library!=null)receiving=CaelumInventoryService.CommitLibraryPurchase(user,session,offer,library,price);
        else receiving=CaelumInventoryService.CommitCityMerchantTransfer(user,session,item,quantity,price,receiving,companion);
        if(receiving==null)return;
        if(!session.Selling)
        {
            if(library!=null)CaelumNotifications.Notify(user,String.Format(StringTable.Localize("CA_RECIPE_RECEIVED",false),
                CaelumCraftingBrowser.RecipeName(offer.Recipe,offer.Tier),offer.Tier));
            else CaelumNotifications.Acquired(user,receiving,quantity);
            if(companion!=null)CaelumNotifications.Acquired(user,companion,1);
        }
        user.LastPalomoMerchantAction=session.Selling ? CaelumConstants.PALOMO_MERCHANT_ACTION_SOLD : CaelumConstants.PALOMO_MERCHANT_ACTION_BOUGHT;
        user.OnNativeInventoryChanged();user.ApplyCharacterProfile();user.RefreshFormalInventorySnapshot();
        session.Refresh(user);user.PersistCharacterState();
        user.A_StartSound("caelum/ui/menu_select",CHAN_6,CHANF_LOCAL|CHANF_UI);
    }

    static bool IsCurrentCityTrade(CaelumCityTradeSession session,CaelumPlayer user)
    {
        return CaelumPlayerAuthority.CanMutate(user) && session!=null
            && session.Vendor!=null && user.CityTrade==session
            && user.ActivePalomoMerchant==session.Vendor;
    }

}
