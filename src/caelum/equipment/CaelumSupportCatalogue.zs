// #479: migración local al abrir una tienda; preserva stock y relojes de otros productos.
class CaelumSupportCatalogue : Object play
{
    static bool Retired(CaelumShopProduct product)
    {
        return (product.Kind==CaelumShopProduct.BOOK && CaelumSupportImplementData.RetiredRecipe(product.Recipe))
            || (product.Kind==CaelumShopProduct.EQUIPMENT && product.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_WEAPON
                && !CaelumSupportImplementData.ValidEssence(product.ItemType,product.Essence));
    }
    static bool Contains(CaelumCityMerchant vendor,int kind,int recipe,int tier,int type,int size)
    {
        for(int i=0;i<vendor.Products.Size();i++)
        {
            let p=vendor.Products[i];
            if(p.Kind!=kind || p.Tier!=tier)continue;
            if(kind==CaelumShopProduct.BOOK && p.Recipe==recipe)return true;
            if(kind==CaelumShopProduct.EQUIPMENT && p.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_WEAPON
                && p.ItemType==type && p.Size==size && p.Essence==CaelumConstants.ESSENCE_QUINTESSENCE)return true;
        }
        return false;
    }
    static void Ensure(CaelumCityMerchant vendor,CaelumPlayer user)
    {
        if(vendor.SupportCatalogueRevision>=CaelumSupportImplementData.MIGRATION_REVISION
            || !CaelumPlayerAuthority.CanMutate(user))return;
        for(int i=vendor.Products.Size()-1;i>=0;i--)
            if(Retired(vendor.Products[i]))
            {
                let product=vendor.Products[i];product.FindStock(vendor);
                if(product.Stock!=null)product.Stock.Destroy();
                vendor.Products.Delete(i);
            }
        if(vendor.Category==CaelumSupportImplementData.SHOP_CATEGORY)
            for(int role=0;role<CaelumSupportImplementData.ROLE_COUNT;role++)
                for(int size=0;size<CaelumConstants.EQUIPMENT_SIZE_COUNT;size++)
                {
                    int type=CaelumConstants.WEAPON_TYPE_SUPPORT_BOOK+role;
                    if(Contains(vendor,CaelumShopProduct.EQUIPMENT,-1,CaelumCityData.SHOP_TIER,type,size))continue;
                    let stock=vendor.SeedEquipment(user,CaelumConstants.EQUIPMENT_KIND_WEAPON,type,0,size,CaelumConstants.ESSENCE_QUINTESSENCE);
                    if(stock==null)return;
                    let p=CaelumShopProduct.Add(vendor,CaelumShopProduct.EQUIPMENT,CaelumCityData.EQUIPMENT_STOCK);
                    p.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;p.ItemType=type;p.Size=size;
                    p.Essence=CaelumConstants.ESSENCE_QUINTESSENCE;p.Tier=CaelumCityData.SHOP_TIER;
                    p.Stock=stock;p.Recipe=p.FindRecipe();
                }
        if(vendor.Category==CaelumShopCatalogue.LIBRARY)
            for(int recipe=CaelumSupportImplementData.FIRST_RECIPE;
                recipe<CaelumSupportImplementData.FIRST_COMPONENT_RECIPE+CaelumSupportImplementData.COMPONENT_COUNT;recipe++)
                for(int tier=1;tier<=CaelumRecipeLearning.TIERS;tier++)
                {
                    if(CaelumRecipeLearning.Tier(recipe,tier)!=tier || Contains(vendor,CaelumShopProduct.BOOK,recipe,tier,0,0))continue;
                    double value=CaelumLibrary.BookValue(user,recipe,tier);if(value<=0)continue;
                    let stock=vendor.SeedBook(recipe,tier,value);if(stock==null)return;
                    let p=CaelumShopProduct.Add(vendor,CaelumShopProduct.BOOK,CaelumShopCatalogue.BOOK_STOCK);
                    p.Recipe=recipe;p.Tier=tier;p.BaseValue=value;p.Stock=stock;
                }
        vendor.SupportCatalogueRevision=CaelumSupportImplementData.MIGRATION_REVISION;
        CaelumShopRestock.Sync(vendor,user,true);
    }
}
