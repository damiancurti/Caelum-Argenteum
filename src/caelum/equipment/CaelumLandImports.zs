// #405: inventario inicial y reposición de importaciones aprobadas.
// No modifica objetivos ni relojes de productos anteriores del comercio.
class CaelumLandImports : Object play
{
    static bool Accepts(int category, int material)
    {
        if(material == CaelumConstants.MATERIAL_COTTON) return category == CaelumShopCatalogue.CLOTHING;
        return category == 0 && CaelumLandResourceData.Price(material) >= 0;
    }

    static void Ensure(CaelumCityMerchant vendor, CaelumPlayer user)
    {
        if(vendor.LandImportRevision >= CaelumLandResourceData.REVISION || !CaelumPlayerAuthority.CanMutate(user)) return;
        bool changed = false;
        for(int i=0;i<CaelumLandResourceData.IMPORT_COUNT;i++)
        {
            if(i < vendor.LandImportCursor || vendor.Category != CaelumLandResourceData.ImportCategory(i)) continue;
            int material = CaelumLandResourceData.ImportMaterial(i);
            int target = CaelumLandResourceData.ImportTarget(i);
            let stock = user.CreateDetachedMaterialStack(material,1,target);
            if(stock == null) return;
            stock.AttachToOwner(vendor);
            let product = CaelumShopProduct.Add(vendor,CaelumShopProduct.MATERIAL,target);
            product.ItemType = material;
            product.ImportedMaterial = true;
            product.Stock = stock;
            // Marca por fila: repetir una migración interrumpida no vuelve a abastecerla.
            vendor.LandImportCursor = i+1;
            changed = true;
        }
        vendor.LandImportRevision = CaelumLandResourceData.REVISION;
        if(changed) CaelumShopRestock.Sync(vendor,user,true);
    }
}
