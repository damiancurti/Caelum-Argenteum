// Stock y recetas se anexan una vez; nunca rellenar mercancía vendida al migrar.
class CaelumStorageFurnitureCatalogue : Object play
{
    static bool Has(CaelumCityMerchant vendor,int kind,int variant)
    {
        for(int i=0;i<vendor.Products.Size();i++)
        {
            let p=vendor.Products[i];if(p.Kind!=kind)continue;
            if(kind==CaelumShopProduct.BOOK && p.Recipe==CaelumStorageFurnitureData.FIRST_RECIPE+variant)return true;
            if(kind==CaelumShopProduct.SIMPLE && p.NativeClass==CaelumStorageFurnitureData.ItemClass(variant))return true;
        }
        return false;
    }
    static void Ensure(CaelumCityMerchant vendor,CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || vendor.StorageFurnitureRevision>=CaelumStorageFurnitureData.REVISION)return;
        if(vendor.Category==0 || vendor.Category==CaelumShopCatalogue.LIBRARY)
        {
            bool books=vendor.Category==CaelumShopCatalogue.LIBRARY;
            for(int variant=0;variant<CaelumStorageFurnitureData.COUNT;variant++)
            {
                int kind=books?CaelumShopProduct.BOOK:CaelumShopProduct.SIMPLE;
                if(Has(vendor,kind,variant))continue;
                int recipe=CaelumStorageFurnitureData.FIRST_RECIPE+variant;
                double value=books?CaelumLibrary.BookValue(user,recipe,1):CaelumStorageFurnitureCrafting.Value(variant);
                Inventory stock=books?Inventory(vendor.SeedBook(recipe,1,value)):vendor.SeedSimple(CaelumStorageFurnitureData.ItemClass(variant),CaelumStorageFurnitureData.SHOP_STOCK);
                if(stock==null)return;
                let p=CaelumShopProduct.Add(vendor,kind,books?CaelumStorageFurnitureData.BOOK_STOCK:CaelumStorageFurnitureData.SHOP_STOCK);
                p.NativeClass=CaelumStorageFurnitureData.ItemClass(variant);p.Stock=stock;p.Recipe=recipe;p.Tier=1;p.BaseValue=value;
            }
        }
        vendor.StorageFurnitureRevision=CaelumStorageFurnitureData.REVISION;CaelumShopRestock.Sync(vendor,user,true);
    }
}
