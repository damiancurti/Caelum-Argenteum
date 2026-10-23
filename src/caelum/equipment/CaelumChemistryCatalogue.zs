// Migración aditiva al abrir la tienda: no repone ni reinicia productos previos.
class CaelumChemistryCatalogue : Object play
{
    static void Ensure(CaelumCityMerchant vendor,CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user)
            || vendor.ChemistryCatalogueRevision>=CaelumChemistryData.REVISION)return;
        if(vendor.Category==0)
        {
            for(int material=CaelumChemistryData.FIRST_MATERIAL;
                material<CaelumChemistryData.FIRST_MATERIAL+CaelumChemistryData.MATERIAL_COUNT;material++)
            {
                int amount=CaelumChemistryData.ImportStock(material);
                if(amount<=0)continue;
                bool found=false;
                for(int p=0;p<vendor.Products.Size();p++)
                    if(vendor.Products[p].Kind==CaelumShopProduct.MATERIAL
                        && vendor.Products[p].ItemType==material){found=true;break;}
                if(found)continue;
                let stock=user.CreateDetachedMaterialStack(material,1,amount);
                if(stock==null)return;
                stock.AttachToOwner(vendor);
                let product=CaelumShopProduct.Add(vendor,CaelumShopProduct.MATERIAL,amount);
                product.ItemType=material;product.ImportedMaterial=true;product.Stock=stock;
            }
        }
        else if(vendor.Category==CaelumShopCatalogue.LIBRARY)
        {
            for(int recipe=CaelumChemistryData.FIRST_RECIPE;
                recipe<CaelumChemistryData.FIRST_RECIPE+CaelumChemistryData.RECIPE_COUNT;recipe++)
            {
                bool found=false;
                for(int p=0;p<vendor.Products.Size();p++)
                    if(vendor.Products[p].Kind==CaelumShopProduct.BOOK
                        && vendor.Products[p].Recipe==recipe){found=true;break;}
                if(found)continue;
                double value=CaelumLibrary.BookValue(user,recipe,1);
                let stock=vendor.SeedBook(recipe,1,value);
                if(stock==null)return;
                let product=CaelumShopProduct.Add(vendor,CaelumShopProduct.BOOK,CaelumShopCatalogue.BOOK_STOCK);
                product.Recipe=recipe;product.Tier=1;product.BaseValue=value;product.Stock=stock;
            }
        }
        for(int i=0;i<vendor.Products.Size();i++)
        {
            let product=vendor.Products[i];int recipe=product.FindRecipe();
            bool changed=recipe!=product.Recipe || CaelumChemistryData.IsRecipe(recipe)
                || recipe==CaelumConstants.CRAFTING_CARBINE_CARTRIDGE_RECIPE
                || recipe==CaelumConstants.CRAFTING_SHOTGUN_CARTRIDGE_RECIPE;
            if(!changed)continue;
            // La nueva cadena empieza ahora, conservando existencias y moneda.
            product.Recipe=recipe;product.UnitTics=0;product.NextDue=-1;
        }
        vendor.ChemistryCatalogueRevision=CaelumChemistryData.REVISION;
        CaelumShopRestock.Sync(vendor,user,true);
    }
}
