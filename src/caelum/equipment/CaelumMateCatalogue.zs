// Migración local de catálogo, una vez al abrir: no reinicia stock ni moneda.
class CaelumMateCatalogue : Object play
{
    static bool Has(CaelumCityMerchant vendor,int kind,int identity)
    {
        for(int i=0;i<vendor.Products.Size();i++)
        {
            let product=vendor.Products[i];if(product.Kind!=kind)continue;
            if(kind==CaelumShopProduct.MATERIAL && product.ItemType==identity)return true;
            if(kind==CaelumShopProduct.BOOK && product.Recipe==identity)return true;
            if(kind==CaelumShopProduct.SIMPLE && product.NativeClass==CaelumMateData.ItemClass(identity))return true;
        }
        return false;
    }
    static void Ensure(CaelumCityMerchant vendor,CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || vendor.MateCatalogueRevision>=CaelumMateData.REVISION)return;
        if(vendor.Category==0)
        {
            if(!Has(vendor,CaelumShopProduct.MATERIAL,CaelumMateData.DRY_GOURD))
            {
            let material=user.CreateDetachedMaterialStack(CaelumMateData.DRY_GOURD,1,CaelumMateData.DRY_GOURD_STOCK);
            if(material==null)return;
            material.AttachToOwner(vendor);
            let product=CaelumShopProduct.Add(vendor,CaelumShopProduct.MATERIAL,CaelumMateData.DRY_GOURD_STOCK);
            product.ItemType=CaelumMateData.DRY_GOURD;product.ImportedMaterial=true;product.Stock=material;
            }
            for(int variant=0;variant<CaelumMateData.COUNT;variant++)
            {
                if(Has(vendor,CaelumShopProduct.SIMPLE,variant))continue;
                let stock=vendor.SeedSimple(CaelumMateData.ItemClass(variant),CaelumMateData.MATE_STOCK);
                if(stock==null)return;
                let mate=CaelumShopProduct.Add(vendor,CaelumShopProduct.SIMPLE,CaelumMateData.MATE_STOCK);
                mate.NativeClass=CaelumMateData.ItemClass(variant);mate.Stock=stock;
                mate.Recipe=CaelumMateData.FIRST_RECIPE+variant;
            }
        }
        else if(vendor.Category==CaelumShopCatalogue.LIBRARY)
        {
            for(int variant=0;variant<CaelumMateData.COUNT;variant++)
            {
                int recipe=CaelumMateData.FIRST_RECIPE+variant;
                if(Has(vendor,CaelumShopProduct.BOOK,recipe))continue;
                double value=CaelumLibrary.BookValue(user,recipe,1);
                let stock=vendor.SeedBook(recipe,1,value);if(stock==null)return;
                let book=CaelumShopProduct.Add(vendor,CaelumShopProduct.BOOK,CaelumMateData.BOOK_STOCK);
                book.Recipe=recipe;book.Tier=1;book.BaseValue=value;book.Stock=stock;
            }
        }
        vendor.MateCatalogueRevision=CaelumMateData.REVISION;CaelumShopRestock.Sync(vendor,user,true);
    }
}
