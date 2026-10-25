// El trapo es una utilidad reutilizable; no se consume al limpiar.
class CaelumCleaningCloth : CaelumSpecialInventoryItem
{
    Default { Tag "$CA_HYGIENE_CLOTH"; Inventory.Icon "graphics/caelum/icons/hygiene/cloth.png"; Inventory.MaxAmount 2147483647; Inventory.InterHubAmount 2147483647; }
    override int GetSpecialCategory(){return CaelumConstants.EQUIPMENT_KIND_KEY_ITEM;}
    override int GetSpecialType(){return CaelumHygieneData.CLOTH_KEY;}
    override double GetUnitWeight(){return CaelumHygieneData.CLOTH_KG;}
    States { Spawn: HYCL A -1; Stop; }
}
class CaelumHygieneCrafting : Object
{
    static double ClothValue()
    {return CaelumEconomyRules.FinishManufacturedObjectValue(CaelumHygieneData.CLOTH_GRAMS
        *CaelumEconomyRules.GetMaterialUnitBaseValue(CaelumConstants.MATERIAL_FABRIC,2),CaelumHygieneData.CLOTH_KG,1);}
    static play void Preview(CaelumPlayer user)
    {
        user.CraftingSelectionTier=1;user.CraftingFinalWeight=CaelumHygieneData.CLOTH_KG;
        user.CraftingBasicMaterialType=CaelumConstants.MATERIAL_FABRIC;user.CraftingBasicMaterialTier=2;
        user.CraftingTierMaterialType=-1;user.CraftingTierMaterialTier=1;
        user.CraftingBasicRequired=CaelumHygieneData.CLOTH_GRAMS;
        user.CraftingTierRequired=0;user.CraftingSilverRequired=0;user.CraftingGoldRequired=0;
        user.CraftingMissingStationType=CaelumCraftingRules.NetworkHasStation(user.CraftingNetworkCapabilities,
            CaelumConstants.CRAFTING_STATION_WORKBENCH)?CaelumConstants.CRAFTING_STATION_NONE:CaelumConstants.CRAFTING_STATION_WORKBENCH;
    }
}
// Migración aditiva: no reinicia existencias ni vencimientos de otros catálogos.
class CaelumHygieneCatalogue : Object play
{
    static bool Has(CaelumCityMerchant vendor,int kind,int id)
    {
        for(int i=0;i<vendor.Products.Size();i++)
        {
            let p=vendor.Products[i];if(p.Kind!=kind)continue;
            if(kind==CaelumShopProduct.BOOK && p.Recipe==id)return true;
            if(kind==CaelumShopProduct.MATERIAL && p.ItemType==id && p.Tier==1)return true;
            if(kind==CaelumShopProduct.SIMPLE && p.NativeClass=='CaelumCleaningCloth')return true;
        }
        return false;
    }
    static void Ensure(CaelumCityMerchant vendor,CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || vendor.HygieneCatalogueRevision>=CaelumHygieneData.REVISION)return;
        if(vendor.Category==0)
        {
            for(int id=CaelumHygieneData.FAT;id<=CaelumHygieneData.SOAP;id++)
            {
                if(Has(vendor,CaelumShopProduct.MATERIAL,id))continue;
                int target=id==CaelumHygieneData.SOAP?CaelumHygieneData.SOAP_STOCK:CaelumHygieneData.ImportStock(id);
                let stock=user.CreateDetachedMaterialStack(id,1,target);if(stock==null)return;
                stock.AttachToOwner(vendor);
                let p=CaelumShopProduct.Add(vendor,CaelumShopProduct.MATERIAL,target);
                p.ItemType=id;p.Stock=stock;p.ImportedMaterial=id!=CaelumHygieneData.SOAP;
                p.Recipe=CaelumHygieneData.RecipeForMaterial(id);p.BaseValue=CaelumEconomyRules.GetMaterialUnitBaseValue(id,1);
            }
            if(!Has(vendor,CaelumShopProduct.SIMPLE,0))
            {
                let stock=vendor.SeedSimple('CaelumCleaningCloth',CaelumHygieneData.CLOTH_STOCK);if(stock==null)return;
                let p=CaelumShopProduct.Add(vendor,CaelumShopProduct.SIMPLE,CaelumHygieneData.CLOTH_STOCK);
                p.NativeClass='CaelumCleaningCloth';p.Stock=stock;p.Recipe=CaelumHygieneData.CLOTH_RECIPE;
                p.BaseValue=CaelumHygieneCrafting.ClothValue();
            }
        }
        if(vendor.Category==CaelumShopCatalogue.LIBRARY)
            for(int recipe=CaelumHygieneData.SOAP_RECIPE;recipe<=CaelumHygieneData.CLOTH_RECIPE;recipe++)
            {
                if(Has(vendor,CaelumShopProduct.BOOK,recipe))continue;
                double value=CaelumLibrary.BookValue(user,recipe,1);
                let stock=vendor.SeedBook(recipe,1,value);if(stock==null)return;
                let p=CaelumShopProduct.Add(vendor,CaelumShopProduct.BOOK,CaelumHygieneData.BOOK_STOCK);
                p.Recipe=recipe;p.Stock=stock;p.BaseValue=value;
            }
        vendor.HygieneCatalogueRevision=CaelumHygieneData.REVISION;CaelumShopRestock.Sync(vendor,user,true);
    }
}
