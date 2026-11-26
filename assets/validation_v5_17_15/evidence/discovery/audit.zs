
class CA647DynamicAudit : EventHandler
{
    int Count;
    void Report(Inventory item, String family, int type, int tier, int slot, int essence)
    {
        if(item==null){Console.Printf("CA647 AUDIT_FAIL null %s %d",family,type);return;}
        let state=item.CurState;
        TextureID texture=state.GetSpriteTexture(0,0,(0,0),item.sprite,item.frame);
        Console.Printf("CA647 ROW|%s|%s|%d|%d|%d|%d|%d|%d|%s|%s|%.6f|%.6f|%.6f|%.6f",
            family,item.GetClassName(),type,tier,slot,essence,item.sprite,item.frame,
            TexMan.GetName(texture),TexMan.GetName(item.Icon),item.Scale.X,item.Scale.Y,item.Radius,item.Height);
        Count++; item.Destroy();
    }
    void Equipment(class<CaelumEquipmentItem> kind, String family, int types, int slots)
    {
        for(int type=0;type<types;type++)for(int slot=0;slot<slots;slot++)for(int tier=1;tier<=3;tier++)
        {
            if(family=="clothing" && tier>1)continue;
            if(family=="weapon" && tier>1 && CaelumWeaponModel.IsSingleTierType(type))continue;
            int essenceCount=family=="weapon"?CaelumConstants.ESSENCE_TYPE_COUNT:1;
            for(int essence=0;essence<essenceCount;essence++)
            {
                if(family=="weapon" && !CaelumSupportImplementData.ValidEssence(type,essence))continue;
                let item=CaelumEquipmentItem(Actor.Spawn(kind,(0,0,128),NO_REPLACE));
                item.args[0]=family=="armor"?slot:type;
                item.args[1]=family=="armor"?type:tier;
                item.args[2]=family=="armor"?tier:0;
                item.args[4]=essence+1;
                item.UpdateWorldSprite();
                Report(item,family,item.PreviewItemType(),item.PreviewTier(),item.PreviewArmorSlot(),item.PreviewEssenceType());
            }
        }
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca647_audit")return;
        Count=0;
        Array<String> codes={"ARRO","B300","B301","B302","B303","B304","B305","BOLT","CAGA","CAGR","CAGT","CAHC","CALC","CALG","CAMD","CANI","CANV","CARK","CARM","CARR","CAVE","CAVT","CBIB","CBIC","CBOL","CBOO","CCAA","CCBR","CCFL","CCFR","CCOP","CCSH","CD12","CDBT","CDLS","CDLX","CDMY","CDS2","CDS6","CDSK","CDWC","CELG","CEMD","CENE","CESA","CFBH","CFER","CFIN","CFOO","CFRG","CGLB","CGOL","CJAV","CJWL","CKCB","CKCT","CKEY","CKOV","CKSV","CLIB","CLIC","CMA0","CMA1","CMA2","CMED","CMLG","CMMD","CMST","COAL","COAP","COAS","COTP","COTS","CPPT","CPTN","CPU0","CPU1","CRAM","CRFR","CRHD","CRNG","CRSP","CSAM","CSAW","CSBG","CSBK","CSBO","CSDK","CSEL","CSEW","CSF2","CSF3","CSGN","CSIL","CSSG","CW0X","CW1X","CW2X","CW3X","CW4X","CW5X","CWAT","CWBK","CWCT","CWFN","CWRD","D300","D301","D302","D303","D304","D305","D306","D307","D308","D309","D30A","D30B","D30C","D30D","D30E","FBRD","FPCH","FRBF","FRFS","HYCL","JAVL","M000","M059","M060","M067","M068","M069","M070","M081","M082","M083","M084","M085","M086","M087","M088","M092","M093","M094","M095","M096","M097","M098","M099","M100","M101","M102","M103","M104","MDBR","MIID","MIRN","MIWK","MNDG","PUFF","SLMD","TAM0","VFBR","VFLI","ZROK"};
        for(int i=0;i<codes.Size();i++)Console.Printf("CA647 SPRITE|%s|%d",codes[i],Actor.GetSpriteIndex(codes[i]));
        Array<class<Inventory> > kinds={'CA_LimboMagicImplement','CA_LimboMagicSeal','CA_LimboRonnieSword','CaelumAmuletPickup','CaelumAnimaPotion','CaelumAnimaPotionLarge','CaelumAnimaPotionMedium','CaelumArmorPickup','CaelumArrowAmmo','CaelumBasicBedItem','CaelumBasicChairItem','CaelumBoltAmmo','CaelumBookcaseItem','CaelumBottleLarge','CaelumBottleNormal','CaelumBottleSmall','CaelumBread','CaelumCampPot','CaelumCampTent','CaelumCanteenLarge','CaelumCanteenNormal','CaelumCanteenSmall','CaelumCarbineAmmo','CaelumCleaningCloth','CaelumClothingPickup','CaelumCopperCoin','CaelumCopperCoin100','CaelumCopperCoin20','CaelumCopperCoin5','CaelumCopperCoin50','CaelumCupboardItem','CaelumDeskItem','CaelumEnergyDrink','CaelumEnergyDrinkLarge','CaelumEnergyDrinkMedium','CaelumFoodRation','CaelumGoldCoin','CaelumGoldCoin100','CaelumGoldCoin20','CaelumGoldCoin5','CaelumGoldCoin50','CaelumIronIngot','CaelumJavelinAmmo','CaelumJavelinTierOneAmmo','CaelumJavelinTierThreeAmmo','CaelumJavelinTierTwoAmmo','CaelumLargeDiningSetItem','CaelumLargePaintingItem','CaelumLifePotion','CaelumLifePotionLarge','CaelumLifePotionMedium','CaelumLockItem','CaelumLuxuryBedItem','CaelumLuxuryChairItem','CaelumLuxuryDiningSetItem','CaelumM01SwordPickup','CaelumMateGold','CaelumMateGourd','CaelumMateSilver','CaelumMaterialPickup','CaelumMazeFood','CaelumMazeWater','CaelumNormalDiningSetItem','CaelumPaintingItem','CaelumProcessingManual','CaelumPuchero','CaelumRecipeBook','CaelumRoastBeef','CaelumRoastFish','CaelumSealPickup','CaelumSealedLetter','CaelumShieldPickup','CaelumShotgunAmmo','CaelumSilverCoin','CaelumSilverCoin100','CaelumSilverCoin20','CaelumSilverCoin5','CaelumSilverCoin50','CaelumSilverKey','CaelumSleepingBag','CaelumSmallDiningSetItem','CaelumStatueItem','CaelumThreeSeatSofaItem','CaelumTwoSeatSofaItem','CaelumWardrobeItem','CaelumWaterRation','CaelumWeaponPickup'};
        for(int i=0;i<kinds.Size();i++)Report(Inventory(Actor.Spawn(kinds[i],(0,0,128),NO_REPLACE)),"default",-1,-1,-1,-1);
        Equipment('CaelumArmorPickup',"armor",CaelumConstants.ARMOR_EQUIPPABLE_TYPE_COUNT,CaelumConstants.ARMOR_SLOT_COUNT);
        Equipment('CaelumShieldPickup',"shield",CaelumConstants.SHIELD_TYPE_COUNT,1);
        Equipment('CaelumAmuletPickup',"amulet",CaelumConstants.AMULET_TYPE_COUNT,1);
        Equipment('CaelumSealPickup',"seal",CaelumConstants.SEAL_TYPE_COUNT,1);
        Equipment('CaelumClothingPickup',"clothing",CaelumClothingData.COUNT,1);
        Equipment('CaelumWeaponPickup',"weapon",CaelumConstants.WEAPON_TYPE_COUNT,1);
        for(int type=0;type<CaelumConstants.MATERIAL_TYPE_COUNT;type++)for(int tier=1;tier<=3;tier++)
        {
            let item=CaelumMaterialPickup(Actor.Spawn('CaelumMaterialPickup',(0,0,128),NO_REPLACE));
            item.args[0]=type;item.args[1]=tier;item.UpdateMaterialVisuals();
            Report(item,"material",item.GetSpecialType(),item.GetSpecialTier(),-1,-1);
        }
        Console.Printf("CA647 AUDIT_COMPLETE rows=%d",Count);
    }
}
