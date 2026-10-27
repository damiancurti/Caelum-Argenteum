// Stock y recetas se anexan una vez; nunca rellenar mercancía vendida al migrar.
class CaelumRestFurnitureCatalogue : Object play
{
    static bool Has(CaelumCityMerchant vendor,int kind,int variant)
    {
        for(int i=0;i<vendor.Products.Size();i++)
        {
            let p=vendor.Products[i];if(p.Kind!=kind)continue;
            if(kind==CaelumShopProduct.BOOK && p.Recipe==CaelumRestFurnitureData.FIRST_RECIPE+variant)return true;
            if(kind==CaelumShopProduct.SIMPLE && p.NativeClass==CaelumRestFurnitureData.ItemClass(variant))return true;
        }
        return false;
    }
    static void Ensure(CaelumCityMerchant vendor,CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || vendor.RestFurnitureRevision>=CaelumRestFurnitureData.REVISION)return;
        if(vendor.Category==0 || vendor.Category==CaelumShopCatalogue.LIBRARY)
        {
            bool books=vendor.Category==CaelumShopCatalogue.LIBRARY;
            for(int variant=0;variant<CaelumRestFurnitureData.COUNT;variant++)
            {
                int kind=books?CaelumShopProduct.BOOK:CaelumShopProduct.SIMPLE;
                if(Has(vendor,kind,variant))continue;
                int recipe=CaelumRestFurnitureData.FIRST_RECIPE+variant;
                double value=books?CaelumLibrary.BookValue(user,recipe,1):CaelumRestFurnitureCrafting.Value(variant);
                Inventory stock=books?Inventory(vendor.SeedBook(recipe,1,value)):vendor.SeedSimple(CaelumRestFurnitureData.ItemClass(variant),CaelumRestFurnitureData.SHOP_STOCK);
                if(stock==null)return;
                let p=CaelumShopProduct.Add(vendor,kind,books?CaelumRestFurnitureData.BOOK_STOCK:CaelumRestFurnitureData.SHOP_STOCK);
                p.NativeClass=CaelumRestFurnitureData.ItemClass(variant);p.Stock=stock;p.Recipe=recipe;p.Tier=1;p.BaseValue=value;
            }
        }
        vendor.RestFurnitureRevision=CaelumRestFurnitureData.REVISION;CaelumShopRestock.Sync(vendor,user,true);
    }
}
