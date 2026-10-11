// Native digestion plus an actual XL shotgun task and its shared time forecast.
class CA178Guards : EventHandler
{
    int Age, Servings;
    CaelumDiningTable Table;
    CaelumTimeSkipModel Forecast;
    bool Reported, Completed;
    static void Check(bool ok,String label){Console.Printf("CA178 %s %s",ok?"PASS":"FAIL",label);}
    static int Stock(CaelumDiningTable table,bool water)
    {
        int count=0;for(int i=0;i<table.Capacity();i++)
        {let item=table.Items[i];int kind=CaelumTimeSkipRules.Kind(item);if(item!=null && (water?(kind==2 || kind==3):kind==1))count+=item.Amount;}
        return count;
    }
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);if(u==null || !u.CharacterCreationComplete)return;
        let r=u.GetPersistentCharacterState(true);Age++;
        if(Age==1){r.DemoNarrativeDelivered=2047;r.DemoNarrativePending=0;r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD);}
        if(Age==100)
        {
            r.DemoNarrativeDelivered=2047;r.DemoNarrativePending=0;
            u.CharacterProfile.Race=CaelumConstants.RACE_BEAST_MAN;
            u.CharacterProfile.FirstClass=CaelumConstants.CLASS_WARRIOR;
            u.CharacterProfile.SecondClass=CaelumConstants.CLASS_WARRIOR;
            u.CharacterProfile.Sex=CaelumConstants.SEX_MALE;
            u.CharacterProfile.HeightChoice=CaelumConstants.HEIGHT_TALL;u.ApplyCharacterProfile();
            Check(u.CharacterProfile.GetMassTier()==CaelumConstants.MAX_MASS_TIER,"fixture is the heaviest playable character");
            let it=ThinkerIterator.Create("CaelumDiningTable");CaelumDiningTable t;
            while((t=CaelumDiningTable(it.Next()))!=null)if(Table==null || t.Pos.Z>Table.Pos.Z)Table=t;
            Console.Printf("CA178 MASS %.3f waterDose=%.6f tableZ=%.3f waterStock=%d",u.DerivedStats.BaseMass,CaelumTimeSkipRules.Dose(2,u.DerivedStats.BaseMass),Table.Pos.Z,Stock(Table,true));
            // Consume more than the original daily target without advancing midnight.
            for(int n=0;n<Table.ForecastDailyTarget()+5;n++)
            {
                let effect=u.FindInventory("CaelumThirstRegeneration");if(effect!=null)effect.Destroy();
                u.CurrentThirst=40;
                for(int i=0;i<Table.Capacity();i++)
                    if(CaelumTimeSkipRules.Kind(Table.Items[i])>=2 && CaelumTimeSkipRules.Consume(u,Table.Items[i],Table)){Servings++;break;}
            }
            Check(Servings==Table.ForecastDailyTarget()+5 && Stock(Table,true)==Table.ForecastDailyTarget(),"upper table supplies water beyond its old daily quota and immediately restores stock");
            int day=Table.LastMansionRestockDay;Table.SyncLocalDay(day);Table.SyncLocalDay(day);
            Check(Stock(Table,true)==Table.ForecastDailyTarget() && Stock(Table,false)==Table.ForecastDailyTarget(),"restock is bounded to existing slots and same-day migration is idempotent");
            r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_PALOMO_MET);
            r.SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_RONNIE_STARTED);
            r.QuestStage[0]=CaelumConstants.MAIN_M00_STATE_RONNIE_ACTIVE;
            CA178Route.Palomo(u);Check(CaelumMainM00Loadout.Choose(u,0,12),"heaviest character confirms shotgun");
            CA178Route.Station(u);
            let needs=new("CaelumMainM00StarterMaterials");needs.Build(12,r.MainM00StarterSize,2);
            for(int m=0;m<CaelumConstants.MATERIAL_TYPE_COUNT;m++)if(needs.Units[m]>0)
            {let stack=u.CreateDetachedMaterialStack(m,1,needs.Units[m]);stack.InMagicBox=false;stack.AttachToOwner(u);}
            u.OnNativeInventoryChanged();u.CraftingSelectionRecipe=12;u.CraftingSelectionTier=1;
            u.CraftingSelectionSize=r.MainM00StarterSize;u.CraftingEfficiencyIndex=2;u.ResetCraftingLayerChoices();u.RefreshCraftingPreview();
            u.BeginSelectedCraftingTask();Check(u.CraftingTaskActive,"native XL shotgun task begins with its real duration");
            u.CurrentHunger=100;u.CurrentThirst=100;u.CurrentSleep=100;
            let effect=u.FindInventory("CaelumThirstRegeneration");if(effect!=null)effect.Destroy();
            Console.Printf("CA178 MARK FORECAST_START");Forecast=new("CaelumTimeSkipModel");Forecast.CaptureSkip(u,false);
            Console.Printf("CA178 CRAFT seconds=%.6f required=%d",u.CraftingTaskRemainingSeconds,Forecast.RequiredTics);
        }
        if(Age==101)
        {
            Forecast=null;
            Check(CaelumTimeSkipState.OpenMenu(u),"guard fixture opens native task skip");
            let skip=CaelumTimeSkipState.Get(u);skip.UseTaskDefault=false;skip.Shift(u,60);
            Check(CaelumTimeSkipState.Start(u),"explicit skip starts without committing a forecast");
            int scan=u.CraftingNetworkScanToken;
            CaelumTimeSkipState.Pump(u);
            int elapsed=skip.ElapsedTics;double remaining=u.CraftingTaskRemainingSeconds;
            Console.Printf("CA178 BATCH scans=%d elapsed=%d work=%d",u.CraftingNetworkScanToken-scan,elapsed,skip.WorkTics);
            Check(elapsed==CaelumTimeSkipRules.BATCH_TICS && u.CraftingNetworkScanToken-scan==1,"one native network scan validates the entire production batch");
            CaelumTimeSkipState.FinishSkip(u,"CA_SKIP_CANCELLED",true);
            Check(!skip.Active && skip.ElapsedTics==elapsed && u.CraftingTaskRemainingSeconds==remaining,"cancel preserves exactly the work already performed");
            Check(CaelumTimeSkipState.OpenMenu(u),"cancelled task can reopen");
            skip.UseTaskDefault=false;skip.Shift(u,60);CaelumTimeSkipState.Start(u);
            u.CraftingTaskNetworkCapabilities|=1073741824;
            skip.LastPumpTic=-1;CaelumTimeSkipState.Pump(u);
            Check(!skip.Active && skip.ElapsedTics==0 && u.CraftingTaskRemainingSeconds==remaining,"changed network capabilities stop before another personal tic");
            Console.Printf("CA178 DONE");
        }
    }
}
