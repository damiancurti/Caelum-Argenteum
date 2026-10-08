class CA133Factories : EventHandler
{
    int Checks,Failures;
    int Missing(int recipe,int capabilities)
    {
        int kind=CaelumCraftingRules.GetUnifiedRecipeKind(recipe);
        if(kind==CaelumConstants.CRAFTING_RECIPE_KIND_PHYSICAL_WEAPON)
            return CaelumCraftingRules.GetMissingNetworkStation(capabilities,1,CaelumCraftingRules.GetStationRecipeWeapon(CaelumConstants.CRAFTING_STATION_WORKBENCH,CaelumCraftingRules.GetUnifiedPhysicalRecipeIndex(recipe)));
        if(kind==CaelumConstants.CRAFTING_RECIPE_KIND_ARMOR)return CaelumCraftingRules.GetMissingArmorStation(capabilities,1,CaelumCraftingRules.GetUnifiedArmorType(recipe));
        if(kind==CaelumConstants.CRAFTING_RECIPE_KIND_SHIELD)return CaelumCraftingRules.GetMissingShieldStation(capabilities,1);
        if(kind==CaelumConstants.CRAFTING_RECIPE_KIND_ESSENCE_WEAPON)return CaelumCraftingRules.GetMissingEssenceStation(capabilities,1);
        if(kind==CaelumConstants.CRAFTING_RECIPE_KIND_AMULET || kind==CaelumConstants.CRAFTING_RECIPE_KIND_SEAL)return CaelumCraftingRules.GetMissingJewelryStation(capabilities,1);
        if(kind==CaelumConstants.CRAFTING_RECIPE_KIND_PROCESSING)return CaelumCraftingRules.GetMissingProcessingStation(capabilities,recipe);
        if(kind==CaelumConstants.CRAFTING_RECIPE_KIND_COMPONENT)return CaelumCraftingRules.GetMissingComponentStation(capabilities,1,CaelumCraftingRules.GetComponentOutputMaterial(recipe));
        return CaelumCraftingRules.GetMissingNetworkStation(capabilities,1,CaelumConstants.CATALOGUE_WEAPON_STANDARD_BOW);
    }
    override void WorldTick()
    {
        if(level.time!=75)return;
        let user=CaelumPlayer(players[0].mo);Array<CaelumCraftingStation> stations;Array<int> capabilities;
        let it=ThinkerIterator.Create("CaelumCraftingStation");CaelumCraftingStation station;
        while((station=CaelumCraftingStation(it.Next()))!=null)
        {
            if(station.GetCraftingStationType()!=CaelumConstants.CRAFTING_STATION_WORKBENCH)continue;
            int token=user.BeginCraftingNetworkScan();station.CollectCraftingNetwork(user,token);
            stations.Push(station);capabilities.Push(user.CraftingNetworkCapabilities);
        }
        bool geometry=true;
        for(int i=0;i<stations.Size();i++)if(!stations[i].TestMobjLocation())geometry=false;
        Checks++;if(!geometry)Failures++;
        Console.Printf("CA133 %s native workbench collision clear",geometry ? "PASS" : "FAIL");
        for(int recipe=0;recipe<CaelumConstants.CRAFTING_NETWORK_PLAYABLE_RECIPE_COUNT;recipe++)
        {
            int found=-1;
            for(int i=0;i<capabilities.Size();i++)if(Missing(recipe,capabilities[i])==CaelumConstants.CRAFTING_STATION_NONE){found=i;break;}
            Checks++;if(found<0)Failures++;
            vector3 position=found<0 ? (0,0,0) : stations[found].Pos;
            Console.Printf("CA133 RECIPE id=%d kind=%d covered=%d station=%.0f,%.0f capabilities=%d name=%s",recipe,CaelumCraftingRules.GetUnifiedRecipeKind(recipe),found>=0,position.X,position.Y,found<0 ? 0 : capabilities[found],CaelumCraftingBrowser.RecipeName(recipe,1));
            if(found<0)Console.Printf("CA133 FAIL uncovered authoritative recipe %d",recipe);
        }
        Console.Printf("CA133 COMPLETE checks=%d failures=%d",Checks,Failures);
    }
}
