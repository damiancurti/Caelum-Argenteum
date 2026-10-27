// Migración aditiva de Provisiones: conserva las existencias y vencimientos
// anteriores, y añade cada materia prima una sola vez al catálogo nativo.
class CaelumKitchenCatalogue : Object play
{
    // Una revisión independiente incorpora sólo las cuatro recetas nuevas;
    // no repone libros vendidos ni reinicia los cursores de otras categorías.
    static void EnsureRecipes(CaelumCityMerchant vendor,CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || vendor.KitchenRecipesRevision>=CaelumCookingData.REVISION)return;
        if(vendor.Category==CaelumShopCatalogue.LIBRARY)
            for(int recipe=CaelumMealData.FIRST_RECIPE;recipe<CaelumMealData.FIRST_RECIPE+CaelumMealData.COUNT;recipe++)
            {
                CaelumShopProduct product;
                for(int i=0;i<vendor.Products.Size();i++)
                    if(vendor.Products[i].Kind==CaelumShopProduct.BOOK && vendor.Products[i].Recipe==recipe && vendor.Products[i].Tier==1)
                    {product=vendor.Products[i];break;}
                if(product!=null && product.Stock!=null)continue;
                double value=CaelumLibrary.BookValue(user,recipe,1);
                let book=vendor.SeedBook(recipe,1,value);if(book==null)return;
                if(product==null)product=CaelumShopProduct.Add(vendor,CaelumShopProduct.BOOK,CaelumShopCatalogue.BOOK_STOCK);
                product.Recipe=recipe;product.Tier=1;product.BaseValue=value;product.Stock=book;
            }
        vendor.KitchenRecipesRevision=CaelumCookingData.REVISION;
        CaelumShopRestock.Sync(vendor,user,true);
    }
    static void Ensure(CaelumCityMerchant vendor,CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user)
            || vendor.KitchenCatalogueRevision>=CaelumKitchenData.REVISION)return;
        if(vendor.Category==0)
        {
            for(int id=CaelumKitchenData.FLOUR;id<=CaelumKitchenData.SALT;id++)
            {
                bool found=false;
                for(int i=0;i<vendor.Products.Size();i++)
                    if(vendor.Products[i].Kind==CaelumShopProduct.MATERIAL
                        && vendor.Products[i].ItemType==id){found=true;break;}
                if(found)continue;
                let stock=user.CreateDetachedMaterialStack(id,1,CaelumKitchenData.Stock(id));
                if(stock==null)return;
                stock.AttachToOwner(vendor);
                let product=CaelumShopProduct.Add(vendor,CaelumShopProduct.MATERIAL,CaelumKitchenData.Stock(id));
                product.ItemType=id;product.Stock=stock;product.ImportedMaterial=true;
                CaelumFoodInventory.Relocate(stock);
            }
        }
        vendor.KitchenCatalogueRevision=CaelumKitchenData.REVISION;
        CaelumShopRestock.Sync(vendor,user,true);
    }
}
