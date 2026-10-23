// Anexa sólo el producto nuevo; conserva existencias y plazos anteriores.
class CaelumMarineImports : Object play
{
    static void Ensure(CaelumCityMerchant vendor, CaelumPlayer user)
    {
        if(vendor.MarineCatalogueRevision>=CaelumMarineData.REVISION
            || !CaelumPlayerAuthority.CanMutate(user))return;
        if(vendor.Category==CaelumMarineData.IMPORT_CATEGORY)
        {
            let stock=user.CreateDetachedMaterialStack(CaelumConstants.MATERIAL_DRIED_KELP,1,CaelumMarineData.IMPORT_GRAMS);
            if(stock==null)return;
            stock.AttachToOwner(vendor);
            let product=CaelumShopProduct.Add(vendor,CaelumShopProduct.MATERIAL,CaelumMarineData.IMPORT_GRAMS);
            product.ItemType=CaelumConstants.MATERIAL_DRIED_KELP;product.ImportedMaterial=true;product.Stock=stock;
        }
        else if(vendor.Category==CaelumShopCatalogue.LIBRARY)
        {
            // Las bibliotecas nuevas ya enumeran la receta; las antiguas la anexan.
            CaelumShopProduct product=null;
            for(int i=0;i<vendor.Products.Size();i++)
                if(vendor.Products[i].Kind==CaelumShopProduct.BOOK
                    && vendor.Products[i].Recipe==CaelumMarineData.IODINE_RECIPE)
                    {product=vendor.Products[i];break;}
            if(product==null)
            {
                double value=CaelumLibrary.BookValue(user,CaelumMarineData.IODINE_RECIPE,1);
                let stock=vendor.SeedBook(CaelumMarineData.IODINE_RECIPE,1,value);
                if(stock==null)return;
                product=CaelumShopProduct.Add(vendor,CaelumShopProduct.BOOK,CaelumShopCatalogue.BOOK_STOCK);
                product.Recipe=CaelumMarineData.IODINE_RECIPE;product.Tier=1;
                product.BaseValue=value;product.Stock=stock;
            }
        }
        vendor.MarineCatalogueRevision=CaelumMarineData.REVISION;
        CaelumShopRestock.Sync(vendor,user,true);
    }
}
