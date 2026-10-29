// Se anexa al abrir el comercio, sin reponer objetos comprados en una migracion.
class CaelumCampCatalogue : Object play
{
    static bool Has(CaelumCityMerchant vendor,int kind,int variant)
    {
        for(int i=0;i<vendor.Products.Size();i++)
        {
            let product=vendor.Products[i];if(product.Kind!=kind)continue;
            if(kind==CaelumShopProduct.BOOK && product.Recipe==CaelumCampData.FIRST_RECIPE+variant)return true;
            if(kind==CaelumShopProduct.SIMPLE && product.NativeClass==CaelumCampData.ItemClass(variant))return true;
        }
        return false;
    }
    static void Ensure(CaelumCityMerchant vendor,CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || vendor.CampCatalogueRevision>=CaelumCampData.REVISION)return;
        if(vendor.Category==0 || vendor.Category==CaelumShopCatalogue.LIBRARY)
        {
            bool books=vendor.Category==CaelumShopCatalogue.LIBRARY;
            for(int variant=0;variant<CaelumCampData.COUNT;variant++)
            {
                int kind=books?CaelumShopProduct.BOOK:CaelumShopProduct.SIMPLE;
                if(Has(vendor,kind,variant))continue;
                int recipe=CaelumCampData.FIRST_RECIPE+variant;
                double value=books?CaelumLibrary.BookValue(user,recipe,1):CaelumCampCrafting.Value(variant);
                Inventory stock=books?Inventory(vendor.SeedBook(recipe,1,value)):
                    vendor.SeedSimple(CaelumCampData.ItemClass(variant),CaelumCampData.SHOP_STOCK);
                if(stock==null)return;
                let product=CaelumShopProduct.Add(vendor,kind,books?CaelumCampData.BOOK_STOCK:CaelumCampData.SHOP_STOCK);
                product.NativeClass=CaelumCampData.ItemClass(variant);product.Stock=stock;
                product.Recipe=recipe;product.Tier=1;product.BaseValue=value;
            }
        }
        vendor.CampCatalogueRevision=CaelumCampData.REVISION;CaelumShopRestock.Sync(vendor,user,true);
    }
}
