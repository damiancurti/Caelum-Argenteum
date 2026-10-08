class CA135Preset : CaelumMandinga
{
    Default { DropItem "CaelumWaterRation",255,1; }
}

class CA135Checks : EventHandler
{
    int Checks,Failures;
    int ExpectedFloor;
    bool ReloadChecked;
    CaelumCombatActor Subjects[9];
    CaelumCombatActor Small,Large;
    CaelumCombatActor Empty,Preset;
    double StartValue[9];
    void Check(bool ok,String label)
    {Checks++;if(!ok)Failures++;Console.Printf("CA135 %s %s",ok ? "PASS" : "FAIL",label);}
    bool Near(double a,double b){return Abs(a-b)<0.0000001;}

    int FloorUnits()
    {
        int units=0;let search=ThinkerIterator.Create("CaelumConsumableItem");Thinker entry;
        while((entry=search.Next())!=null)
        {
            let item=CaelumConsumableItem(entry);
            if(item.Owner==null)units+=item.Amount;
        }
        return units;
    }

    void LootAndPickup()
    {
        int before=FloorUnits();
        Large.DamageMobj(null,null,1000000,'None',DMG_NO_ARMOR,0);
        Check(Large.health<=0 && FloorUnits()==before+1,"native demon death releases exactly one potion unit");
        let search=ThinkerIterator.Create("CaelumConsumableItem");Thinker entry;
        bool actualLarge=false;
        while((entry=search.Next())!=null)
        {
            let item=CaelumConsumableItem(entry);
            if(item.Owner==null && item.Amount==1 && CaelumPotionRules.Size(item.GetConsumableType())==CaelumPotionRules.LARGE)actualLarge=true;
        }
        Check(actualLarge,"death loot preserves the large dose class");
        CaelumDemonService.ReleaseLoot(Large,false);
        Check(FloorUnits()==before+1,"repeated death callback cannot release another unit");
        for(int family=0;family<3;family++)CaelumDemonService.Potion(Empty,family).Destroy();
        Empty.DamageMobj(null,null,1000000,'None',DMG_NO_ARMOR,0);
        Check(FloorUnits()==before+1,"exhausted inventory produces no potion");
        Preset.DamageMobj(null,null,1000000,'None',DMG_NO_ARMOR,0);
        ExpectedFloor=before+2;
        Check(FloorUnits()==before+1 && CaelumDemonService.Potion(Preset,0).Amount==6,
            "predefined drop reserves priority before its native death animation");
        int units=FloorUnits();CaelumDemonService.ReleaseLoot(Small,false);
        Check(FloorUnits()==units,"a living demon cannot release death loot");

        let user=CaelumPlayer(players[0].mo);
        bool separate=true;
        for(int size=0;size<3;size++)
        {
            int kind=CaelumPotionRules.Kind(0,size);
            let item=CaelumConsumableItem(Actor.Spawn(CaelumPotionRules.ItemClass(kind),user.Pos,NO_REPLACE));
            Actor toucher=user;
            separate=separate && item.CallTryPickup(toucher);
            let held=user.FindNativeConsumableItem(kind);
            separate=separate && held!=null && held.GetConsumableType()==kind && held.Amount>=1;
        }
        Check(separate,"native player pickup retains three independent size stacks");
        let vendor=CaelumCityMerchant(Actor.Spawn("CaelumCityMerchant",(6500,6500,0),NO_REPLACE));
        vendor.Category=0;
        bool trade=true;
        for(int size=0;size<3;size++)trade=trade && vendor.Accepts(user.FindNativeConsumableItem(CaelumPotionRules.Kind(0,size)));
        Check(trade,"recovery merchant accepts each retained potion size");
    }

    CaelumCombatActor Body(Name type,Vector3 position)
    {
        let npc=CaelumCombatActor(Actor.Spawn(type,position,NO_REPLACE));
        npc.CaelumDiagnosticPassiveAI=true;npc.tics=-1;npc.Target=null;
        return npc;
    }

    void VerifyLoadedState()
    {
        ReloadChecked=true;
        bool ongoing=true;
        for(int i=0;i<9;i++)
        {
            Name power=i%3==0 ? 'CaelumLifeRegeneration' : i%3==1 ? 'CaelumAnimaRegeneration' : 'CaelumEnergyRegeneration';
            let effect=CaelumRegenerationPower(Subjects[i].FindInventory(power));
            ongoing=ongoing && effect!=null && effect.PotionTotalRatio==CaelumPotionRules.TotalRatio(i/3)
                && effect.PotionPulsesGiven>0 && effect.PotionPulsesGiven<10;
        }
        Check(ongoing && Small.DemonSupplyRevision==1 && CaelumDemonService.Potion(Small,0).Amount==2,
            "native save/load preserves spent supplies and partial potion doses");
    }

    void Start()
    {
        let small=Small;let large=Large;
        bool stocks=true;
        for(int family=0;family<3;family++)
        {
            let a=CaelumDemonService.Potion(small,family),b=CaelumDemonService.Potion(large,family);
            stocks=stocks && a!=null && b!=null && a.Amount==6 && b.Amount==6;
        }
        Check(stocks,"both demon profiles start with six units per family");
        if(!stocks)return;
        Check(CaelumDemonService.Potion(small,0).GetConsumableType()==0
            && CaelumDemonService.Potion(large,0).GetConsumableType()==CaelumConstants.CONSUMABLE_LIFE_LARGE,
            "Mandinga small and Zupay large native item identity");
        CaelumDemonService.Potion(small,0).Amount=2;
        CaelumDemonService.Initialize(small);CaelumDemonService.Initialize(small);
        Check(CaelumDemonService.Potion(small,0).Amount==2,"versioned initialization never refills a used stack");
        bool weights=true;
        for(int sample=0;sample<3;sample++)
        {
            int a=sample==1 ? 0 : 6,b=sample==2 ? 3 : 6,c=b;
            int hits[3];for(int i=0;i<3;i++)hits[i]=0;
            for(int roll=0;roll<a+b+c;roll++)hits[CaelumDemonService.WeightedFamily(a,b,c,roll)]++;
            weights=weights && hits[0]==a && hits[1]==b && hits[2]==c;
        }
        Check(weights && CaelumDemonService.WeightedFamily(0,0,0,0)==-1,"weighted examples cover exactly all remaining units");
        bool catalogue=true;
        for(int size=0;size<3;size++)for(int family=0;family<3;family++)
        {
            int kind=CaelumPotionRules.Kind(family,size);
            let item=CaelumConsumableItem(Actor.Spawn(CaelumPotionRules.ItemClass(kind),(0,0,0),NO_REPLACE));
            catalogue=catalogue && item!=null && item.GetConsumableType()==kind
                && CaelumPotionRules.Family(kind)==family && CaelumPotionRules.Size(kind)==size;
            item.Destroy();
        }
        Check(catalogue,"all nine size/family combinations retain distinct item identities");
        bool prices=true;
        double base=CaelumEconomyRules.GetConsumableUnitBaseValue(0);
        for(int size=0;size<3;size++)for(int family=0;family<3;family++)
        {
            int kind=CaelumPotionRules.Kind(family,size);
            prices=prices && Near(CaelumConsumableItem.UnitWeightForType(kind),0.25)
                && Near(CaelumEconomyRules.GetConsumableUnitBaseValue(kind)/base,
                    CaelumPotionRules.TotalRatio(size)/0.1);
        }
        Check(prices,"all potion sizes keep quarter-kilogram weight and proportional prices");
        let user=CaelumPlayer(players[0].mo);
        user.CreationWizardOpen=true;user.CurrentAir=0;user.CurrentSleep=20;
        let energy=CaelumConsumableItem(Actor.Spawn("CaelumEnergyDrinkLarge",user.Pos,NO_REPLACE));
        energy.AttachToOwner(user);
        Check(user.UseInventory(energy),"player can consume the same large energetic loot class");
        Check(Near(CaelumPotionRules.TotalRatio(0),0.1) && Near(CaelumPotionRules.TotalRatio(1),0.225)
            && Near(CaelumPotionRules.TotalRatio(2),0.5),"approved total restoration table");
        for(int index=0;index<9;index++)
        {
            int family=index%3,size=index/3;
            let npc=Subjects[index];
            npc.health=100;npc.CurrentCombatAnima=0;npc.CurrentCombatAir=0;
            let item=CaelumConsumableItem(Actor.Spawn(CaelumPotionRules.ItemClass(CaelumPotionRules.Kind(family,size)),npc.Pos,NO_REPLACE));
            item.Amount=2;item.AttachToOwner(npc);
            Check(npc.UseInventory(item) && item.Amount==1,"actual native use consumes exactly one unit");
            StartValue[index]=family==0 ? npc.health : family==1 ? npc.CurrentCombatAnima : npc.CurrentCombatAir;
        }
    }

    override void WorldTick()
    {
        let user=CaelumPlayer(players[0].mo);
        if(!ReloadChecked && CVar.GetCVar("ca135_verify_load").GetBool())VerifyLoadedState();
        if(level.time==1 && user!=null){user.InitializeDirectMapCharacter();user.PersistCharacterState();}
        if(level.time==60)
        {
            Small=Body('CaelumMandinga',(-800,800,0));
            Large=Body('CaelumZupayColossus',(800,800,0));
            Empty=Body('CaelumMandinga',(1000,800,0));
            Preset=Body('CA135Preset',(1000,500,0));
            for(int i=0;i<9;i++)Subjects[i]=Body('CaelumMandinga',(-800+i*180,300,0));
        }
        if(level.time==70)Start();
        if(level.time==80)
        {
            bool delayed=true;
            for(int i=0;i<9;i++)delayed=delayed && Near(i%3==0 ? Subjects[i].health : i%3==1 ? Subjects[i].CurrentCombatAnima : Subjects[i].CurrentCombatAir,StartValue[i]);
            Check(delayed,"restoration is not granted instantly");
        }
        if(level.time==430)
        {
            Console.Printf("CA135 PLAYER_ENERGY air=%.9f max=%.9f sleep=%.9f",user.CurrentAir,user.DerivedStats.MaximumAir,user.CurrentSleep);
            Check(Near(user.CurrentAir,user.DerivedStats.MaximumAir*0.5) && Near(user.CurrentSleep,70),
                "player energy restores both half of Air and fifty Sleep over ten seconds");
            user.CreationWizardOpen=false;
            for(int i=0;i<9;i++)
            {
                let npc=Subjects[i];int family=i%3,size=i/3;
                double actual=(family==0 ? npc.health : family==1 ? npc.CurrentCombatAnima : npc.CurrentCombatAir)-StartValue[i];
                double expected=(family==0 ? npc.CombatMaximumHealth : family==1 ? npc.MaximumCombatAnima : npc.MaximumCombatAir)*CaelumPotionRules.TotalRatio(size);
                Console.Printf("CA135 DOSE kind=%d size=%d actual=%.9f expected=%.9f",family,size,actual,expected);
                Check(Abs(actual-expected)<1,"ten real seconds restore the total dose with bounded integer HP rounding");
            }
            LootAndPickup();
        }
        if(level.time==465)
        {
            Check(FloorUnits()==ExpectedFloor,"native death animation releases only its predefined item");
            Console.Printf("CA135 COMPLETE checks=%d failures=%d",Checks,Failures);
        }
    }
}
