// Migración aditiva de Provisiones: conserva las existencias y vencimientos
// anteriores, y añade cada materia prima una sola vez al catálogo nativo.
class CaelumKitchenCatalogue : Object play
{
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
