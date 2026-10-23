        if(e.Name=='ca471_station')
        {
            Setup(u);Stock(u,Kit(0),100);Stock(u,Kit(1),100);Ranged.Destroy();
            Ranged=CaelumCraftingStation(Actor.Spawn('CaelumRangedWorkshopStation',u.Pos+(0,48,0),NO_REPLACE));Open(u);
            for(int n=0;n<2;n++)
            {
                Select(u,n,2);u.BeginSelectedCraftingTask();
                Check(!u.CraftingTaskActive && u.CraftingMissingStationType==CaelumConstants.CRAFTING_STATION_ALCHEMY,
                    "new cartridge rejects ranged-only network");
                Check(u.CountRawCraftingMaterial(Kit(n),1)==100,"rejected station preserves kits");
            }
            let alchemy=Actor.Spawn('CaelumAlchemyStation',u.Pos+(-48,0,0),NO_REPLACE);Open(u);Select(u,0,2);u.BeginSelectedCraftingTask();
            Check(u.CraftingTaskActive && !u.CraftingTaskLegacyRanged,"new mixed-network task is not grandfathered");
            alchemy.Destroy();
            for(int tick=0;tick<=TICRATE;tick++)u.UpdateCraftingTask();
            double remaining=u.CraftingTaskRemainingSeconds;u.UpdateCraftingTask();
            Check(u.CraftingTaskActive && !u.CraftingTaskProgressing && u.CraftingTaskRemainingSeconds==remaining,"removed alchemy pauses after normal network refresh");
            u.CancelCraftingTask();Check(!u.CraftingTaskLegacyRanged && u.CountRawCraftingMaterial(Kit(0),1)==100,"cancel clears compatibility without spending");
            Ranged.Destroy();Ranged=CaelumCraftingStation(Actor.Spawn('CaelumAlchemyStation',u.Pos+(0,48,0),NO_REPLACE));Open(u);
            for(int recipe=CaelumConstants.CRAFTING_ARROW_RECIPE;recipe<=CaelumConstants.CRAFTING_BOLT_RECIPE;recipe++)
            {u.CraftingSelectionRecipe=recipe;u.RefreshCraftingPreview();Check(u.CraftingMissingStationType==CaelumConstants.CRAFTING_STATION_RANGED_WORKSHOP,"arrows and bolts still require ranged");}
            Bench.Destroy();u.CraftingNetworkCapabilities=CaelumCraftingRules.GetStationCapabilityBit(CaelumConstants.CRAFTING_STATION_ALCHEMY);Select(u,0,2);
            Check(u.CraftingMissingStationType==CaelumConstants.CRAFTING_STATION_WORKBENCH,"alchemy alone requires workbench");Result();
        }
        if(e.Name=='ca471_upgrade' || e.Name=='ca471_resume')
        {
            Verify(u);u.EnsureCartridgeStationTask();
            Check(u.CartridgeStationRevision==1 && u.CraftingTaskLegacyRanged,"old ranged cartridge task is grandfathered");
            u.EnsureCartridgeStationTask();u.PersistCharacterState();
            Check(u.GetPersistentCharacterState(true).CraftingTaskLegacyRanged,"migration is idempotent and stored for travel");
            if(e.Name=='ca471_resume')
            {
                RecoverStations(u);Open(u);double remaining=u.CraftingTaskRemainingSeconds;u.UpdateCraftingTask();
                Check(u.CraftingTaskProgressing && u.CraftingTaskRemainingSeconds<remaining,"old task resumes without alchemy");
                int ammo=Count(u,1),kits=u.CountRawCraftingMaterial(Kit(1),1);
                int slot=CaelumRecipeLearning.Slot(Recipe(1),1),practice=u.GetPersistentCharacterState(true).RecipePractice[slot];
                u.CraftingTaskRemainingSeconds=0;u.CompleteCraftingTask();
                Check(Count(u,1)==ammo+10 && u.CountRawCraftingMaterial(Kit(1),1)==kits-10,"old reserved task completes exactly once at ranged");
                Check(u.GetPersistentCharacterState(true).RecipePractice[slot]==practice+10,"old task preserves practice claim");
                u.CompleteCraftingTask();Check(Count(u,1)==ammo+10 && !u.CraftingTaskLegacyRanged,"completion clears exception and duplicate is inert");
                Select(u,1,2);u.BeginSelectedCraftingTask();
                Check(!u.CraftingTaskActive && u.CraftingMissingStationType==CaelumConstants.CRAFTING_STATION_ALCHEMY,"grandfathering does not permit another ranged task");
            }
            Result();
        }
        if(e.Name=='ca471_current')
        {
            Verify(u);Check(u.CartridgeStationRevision==1 && !u.CraftingTaskLegacyRanged,"new saved task keeps alchemy requirement");
            RecoverStations(u);Open(u);int ammo=Count(u,1);u.CraftingTaskRemainingSeconds=0;u.CompleteCraftingTask();
            Check(Count(u,1)==ammo+10,"current saved task completes at alchemy");Result();
        }
        if(e.Name=='ca471_travel')
        {
            Check(level.MapName=="CAM471B","native map transition reached destination");
            Verify(u);Check(u.CraftingTaskLegacyRanged && u.GetPersistentCharacterState(true).CraftingTaskLegacyRanged,"travel retains grandfathered task");Result();
        }
        if(e.Name=='ca471_go')
        {u.CloseCraftingStationSession();u.PersistCharacterState();level.ChangeLevel("CAM471B",0,CHANGELEVEL_NOINTERMISSION);}
        if(e.Name=='ca471_live')
        {
            Setup(u);Stock(u,Kit(0),100);Select(u,0,2);u.BeginSelectedCraftingTask();LiveAmmo=Count(u,0);
            u.CraftingTaskRemainingSeconds=1;Check(u.CraftingTaskActive,"live task started");Result();
        }
        if(e.Name=='ca471_livecheck')
        {Check(!u.CraftingTaskActive && Count(u,0)==LiveAmmo+10 && u.CountRawCraftingMaterial(Kit(0),1)==90,"unpaused native tick completes alchemy cartridges");Result();}
        if(e.Name=='ca471_ui' || e.Name=='ca471_manual')
        {
            Setup(u);Stock(u,Kit(0),1000);Stock(u,Kit(1),1000);Select(u,0,2);u.CraftingMenuOpen=true;
            for(int n=0;n<2;n++){int slot=CaelumRecipeLearning.Slot(Recipe(n),1);u.GetPersistentCharacterState(true).RecipePractice[slot]=1000;u.GetPersistentCharacterState(true).RecipeRereadings[slot]=10;}
            u.RefreshCraftingPreview();
            Check(u.CraftingSelectedInfrastructureAvailable,"manual scene offers cartridges at alchemy");
            if(e.Name=='ca471_manual')Console.Printf("CA471: cartuchos en Alquimia; F2 alterna Alquimia/Taller a distancia. Kits, aprendizaje y practica preparados.");
            Result();
        }
        if(e.Name=='ca471_toggle_station')
        {
            int recipe=u.CraftingSelectionRecipe;bool alchemy=Ranged is 'CaelumAlchemyStation';
            Ranged.Destroy();Ranged=CaelumCraftingStation(Actor.Spawn(alchemy?'CaelumRangedWorkshopStation':'CaelumAlchemyStation',u.Pos+(0,48,0),NO_REPLACE));
            Open(u);u.CraftingSelectionRecipe=recipe;u.RefreshCraftingPreview();
            if(CaelumCraftingRules.GetRecipeCartridgeKit(recipe)>=0)
                Check(u.CraftingSelectedInfrastructureAvailable!=alchemy,"manual station switch updates cartridge availability");Result();
        }
