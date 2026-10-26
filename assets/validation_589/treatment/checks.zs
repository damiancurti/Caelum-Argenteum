class CA502TreatmentProof : Inventory
{
    double Expected;
    Default { +INVENTORY.UNDROPPABLE Inventory.MaxAmount 1; }
    States { Spawn: TNT1 A -1; Stop; }
}
class CA502TreatmentChecks : EventHandler
{
    int Passed,Failed;
    double Expected;
    void Check(bool ok,String label){if(ok)Passed++;else Failed++;Console.Printf("CA502 %s treatment %s",ok?"PASS":"FAIL",label);}
    bool Near(double a,double b){return Abs(a-b)<0.000001;}
    void Result(){Console.Printf("CA502 RESULT treatment passes=%d failures=%d",Passed,Failed);}
    void Setup(CaelumPlayer u)
    {
        u.CharacterCreationComplete=true;u.CreationWizardOpen=false;u.bInvulnerable=true;
        u.SetOrigin((128,320,192),false);u.Vel=(0,0,0);u.GetPersistentCharacterState(true);
        CaelumWorldClock.Get(u,true);u.CurrentHunger=0;u.CurrentThirst=0;
        u.health=u.CaelumMaximumHealth;u.player.health=u.health;
        CaelumContaminationStorage.Set(u,40);
    }
    void Rules(CaelumPlayer u)
    {
        Setup(u);
        let power=CaelumRegenerationPower(u.GiveInventoryType('CaelumLifeRegeneration'));
        for(int size=0;size<3;size++)
        {
            CaelumContaminationStorage.Set(u,40);power.PotionHealingFraction=0;
            double ratio=CaelumPotionRules.TotalRatio(size);
            for(int pulse=0;pulse<10;pulse++)power.ApplyPotionPulse(0,ratio/10);
            Check(Near(CaelumFoodIllness.Value(u),40-ratio*10),"all medikit sizes count potential Life at full health");
            Check(u.health==u.CaelumMaximumHealth,"medikit keeps maximum Life cap");
        }
        u.health=u.CaelumMaximumHealth/2;u.player.health=u.health;
        CaelumContaminationStorage.Set(u,40);power.ApplyPotionPulse(0,0.025);
        Check(Near(CaelumFoodIllness.Value(u),39.75),"wounded pulse removes proportional quarter degree");
        CaelumContaminationStorage.Set(u,40);power.ApplyPotionPulse(0,0.00001);
        Check(Near(CaelumFoodIllness.Value(u),39.9999),"fractional treatment survives sub-Life-point rounding");
        CaelumContaminationStorage.Set(u,40);power.ApplyPotionPulse(1,0.1);power.ApplyPotionPulse(2,0.1);
        Check(Near(CaelumFoodIllness.Value(u),40),"Anima and energy do not cleanse");
        CaelumContaminationStorage.Set(u,0.02);power.ApplyPotionPulse(0,0.025);
        Check(Near(CaelumFoodIllness.Value(u),0),"treatment clamps at clean without negative credit");
        CaelumContaminationStorage.Set(u,40);CaelumFoodIllness.Recover(u,u.CaelumMaximumHealth);
        Check(Near(CaelumFoodIllness.Value(u),39),"natural regeneration retains one degree per full Life");
        CaelumContaminationStorage.Set(u,40);u.ApplyConsumableRegenerationPulse(0);
        int legacy=Max(1,int(u.CaelumMaximumHealth*CaelumConstants.CONSUMABLE_REGENERATION_PERCENT_PER_SECOND+0.5));
        Check(Near(CaelumFoodIllness.Value(u),40-10.0*legacy/u.CaelumMaximumHealth),"legacy saved medikit pulse uses its historical healing");
        power.Destroy();
        let mate=CaelumMateRecovery(u.GiveInventoryType('CaelumMateRecovery'));
        CaelumContaminationStorage.Set(u,40);mate.AddDose(10,0.025);mate.AddDose(10,0.025);
        for(int tic=0;tic<350;tic++)mate.DoEffect();
        Check(Near(CaelumFoodIllness.Value(u),39.5),"overlapping mate doses retain their independent contribution");
        CaelumContaminationStorage.Set(u,40);mate.AddDose(10,0);
        for(int tic=0;tic<350;tic++)mate.DoEffect();
        Check(Near(CaelumFoodIllness.Value(u),40),"washed or cold mate hydration does not cleanse");mate.Destroy();
        let npc=CaelumCombatActor(Actor.Spawn('CaelumGiantRat',(384,320,192),NO_REPLACE));
        Check(npc!=null,"native combat actor available");
        if(npc!=null)
        {
            npc.CaelumDiagnosticPassiveAI=true;npc.CombatMaximumHealth=100;npc.health=100;CaelumContaminationStorage.Set(npc,40);
            let aid=CaelumRegenerationPower(npc.GiveInventoryType('CaelumLifeRegeneration'));
            aid.ApplyPotionPulse(0,0.1);
            Check(Near(CaelumContaminationStorage.Value(npc),39),"NPC treatment uses its own contamination record");npc.Destroy();
        }
        Result();
    }
    void Start(CaelumPlayer u,bool actualMate=false)
    {
        Setup(u);let item=CaelumConsumableItem(u.GiveInventoryType('CaelumLifePotionLarge'));
        Expected=34.75;
        Check(item!=null && u.UseInventory(item),"native large medikit use at full Life");
        if(actualMate)
        {
            let mate=CaelumMateItem(u.GiveInventoryType('CaelumMateGourd'));
            mate.YerbaLoaded=true;mate.TemperatureReady=true;mate.UsesRemaining=20;mate.WaterLiters=0.1;mate.TemperatureC=60;
            mate.TemperatureStamp=CaelumThermalRuntime.Stamp(CaelumWorldClock.Get(u));
            Expected=35-0.1*CaelumConstants.WATER_RECOVERY_PER_LITER_PER_PULSE/Max(1,u.DerivedStats.BaseMass)
                *CaelumConstants.CONSUMABLE_REGENERATION_SECONDS/CaelumConstants.SURVIVAL_MAXIMUM*CaelumMateData.RESOURCE_RATIO*10;
            Check(mate.Drink(u),"native hot mate drinking");
        }
        else
        {
            let mate=CaelumMateRecovery(u.GiveInventoryType('CaelumMateRecovery'));mate.AddDose(10,0.025);
        }
        let proof=CA502TreatmentProof(u.GiveInventoryType('CA502TreatmentProof'));proof.Expected=Expected;
        Result();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Player<0 || !playeringame[e.Player])return;
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="ca502_treatment_rules")Rules(u);
        else if(e.Name=="ca502_treatment_start")Start(u);
        else if(e.Name=="ca502_treatment_done")
        {
            let proof=CA502TreatmentProof(u.FindInventory('CA502TreatmentProof'));
            Console.Printf("CA502 treatment actual=%.8f expected=%.8f",CaelumFoodIllness.Value(u),proof!=null?proof.Expected:-1);
            Check(proof!=null && Near(CaelumFoodIllness.Value(u),proof.Expected),"native ten-second medikit and mate complete exactly once");
            Check(u.FindInventory('CaelumLifeRegeneration')==null && u.FindInventory('CaelumMateRecovery')==null,"expired powers leave no future treatment");Result();
        }
        else if(e.Name=="ca502_treatment_manual")Start(u,true);
        else if(e.Name=="ca502_treatment_full")
        {Setup(u);let item=u.GiveInventoryType('CaelumLifePotionMedium');u.UseInventory(item);Console.Printf("CA502 RESULT full Life / medium medikit: contamination 40 -> 37.75 over ten seconds");}
    }
}
