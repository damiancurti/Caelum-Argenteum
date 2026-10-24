// #410: dosis, enfermedad y coste real de regeneración; sólo diagnóstico.
class CA410Checks : EventHandler
{
    int Passed,Failed;
    int ImmuneLife;
    void Check(bool ok,String label)
    {if(ok)Passed++;else Failed++;Console.Printf("CA410 %s %s",ok?"PASS":"FAIL",label);}
    void Reset(CaelumPlayer u,int life,double contamination)
    {
        u.CreationWizardOpen=false;u.bInvulnerable=false;
        u.CaelumMaximumHealth=1000;u.health=life;u.player.health=life;
        u.CurrentHunger=100;u.CurrentThirst=100;u.CurrentSleep=100;u.UpdateSurvivalStates();
        u.NaturalHealthRegenerationAccumulator=0;
        u.DerivedStats.HealthRegenerationPerSecond=TICRATE;
        u.Attributes.Toughness=0;
        let illness=CaelumFoodIllness.Get(u);illness.Contamination=contamination;illness.DamageFraction=0;
    }
    void Core(CaelumPlayer u)
    {
        Check(CaelumFoodRules.Intake(60,50,80)==30,"reference 80 kg dose");
        Check(CaelumFoodRules.Intake(60,50,40)==60 && CaelumFoodRules.Intake(60,50,160)==15,"natural body mass changes intake inversely");
        Check(CaelumFoodRules.Aged(0,CaelumFoodData.RAW_FISH,21600,20,50)==100,"raw fish reference lifetime");
        Check(CaelumFoodRules.Aged(0,CaelumFoodData.ROAST_FISH,21600,20,50)==50,"cooked fish keeps twice as long");
        Check(CaelumFoodRules.Aged(0,CaelumFoodData.RATION,302400,20,50)==50,"existing ration reaches midpoint after 84 hours");
        Check(CaelumFoodRules.EnvironmentRate(30,100)==3 && CaelumFoodRules.EnvironmentRate(10,0)==0.25,"heat and humidity compound independently");
        Check(CaelumFoodRules.Aged(60,0,999999,-18,100)==60 && CaelumFoodRules.Aged(60,0,999999,60,100)==60,"freezing and hot holding stop growth without purifying");
        Check(CaelumFoodRules.DamagePerSecond(50,1000,0)==0,"threshold has no illness damage");
        Check(CaelumFoodRules.DamagePerSecond(60,1000,0)==10,"ten excess degrees cost one percent maximum Life per second");
        Check(CaelumFoodRules.DamagePerSecond(100,1000,100)==0 && CaelumFoodRules.DamagePerSecond(100,1000,150)==0,"Toughness immunity never becomes healing");
        Reset(u,1000,60);
        for(int i=0;i<TICRATE*2;i++)CaelumFoodIllness.Advance(u);
        Console.Printf("CA410 DAMAGE life=%d maximum=%d fraction=%.12f toughness=%.3f",u.health,u.CaelumMaximumHealth,CaelumFoodIllness.Get(u).DamageFraction,u.Attributes.Toughness);
        Check(u.health==980,"actual native illness deals twenty Life over two seconds");
        Reset(u,1000,100);u.Attributes.Toughness=150;
        for(int i=0;i<TICRATE;i++)CaelumFoodIllness.Advance(u);
        Check(u.health==1000,"above immunity causes neither damage nor healing");
        Reset(u,900,0);
        for(int i=0;i<100;i++)CaelumPlayerResources.ApplyNaturalHealthRegeneration(u);
        double hungerCost=100-u.CurrentHunger,thirstCost=100-u.CurrentThirst;
        Check(u.health==1000 && hungerCost>0 && thirstCost>0,"baseline natural healing pays its existing costs");
        Reset(u,1000,1);
        for(int i=0;i<100;i++)CaelumPlayerResources.ApplyNaturalHealthRegeneration(u);
        Check(u.health==1000 && Abs(CaelumFoodIllness.Value(u)-0.9)<0.000001,"full Life potential regeneration removes equivalent contamination");
        Check(Abs(100-u.CurrentHunger-hungerCost)<0.000001 && Abs(100-u.CurrentThirst-thirstCost)<0.000001,"full Life depuration pays exactly the baseline costs");
        Reset(u,900,2);
        for(int i=0;i<100;i++)CaelumPlayerResources.ApplyNaturalHealthRegeneration(u);
        Check(u.health==1000 && Abs(CaelumFoodIllness.Value(u)-1.9)<0.000001,"actual healing simultaneously decontaminates");
        Check(Abs(100-u.CurrentHunger-hungerCost)<0.000001 && Abs(100-u.CurrentThirst-thirstCost)<0.000001,"combined healing and depuration do not double charge");
        u.CurrentHunger=0;u.UpdateSurvivalStates();double previous=CaelumFoodIllness.Value(u);
        for(int i=0;i<TICRATE;i++)CaelumPlayerResources.ApplyNaturalHealthRegeneration(u);
        Check(CaelumFoodIllness.Value(u)==previous,"critical Hunger blocks potential depuration");
        Reset(u,1000,0.0005);CaelumPlayerResources.ApplyNaturalHealthRegeneration(u);
        Check(CaelumFoodIllness.Value(u)==0,"fractional final degree clears without a permanent residue");
        Reset(u,1100,1);CaelumPlayerResources.ApplyNaturalHealthRegeneration(u);
        Check(u.health==1100 && CaelumFoodIllness.Value(u)<1,"depuration never reduces pre-existing over-maximum Life");
        Reset(u,1000,99);
        CaelumFoodIllness.Ingest(u,100,1000);Check(CaelumFoodIllness.Value(u)==100,"multiple ingestion doses cap at one hundred");
        let same=CaelumFoodIllness.Get(u);same.Ensure();
        Check(CaelumFoodIllness.Value(u)==100,"idempotent migration does not reset existing contamination");
        Reset(u,1000,0);u.PersistCharacterState();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Player<0 || e.Player>=MAXPLAYERS)return;
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca410_core')Core(u);
        else if(e.Name=='ca410_preview')
        {
            Reset(u,1000,60);u.bInvulnerable=true;
            Check(TexMan.CheckForTexture("graphics/caelum/ui/hud/icons/ca_hud_icon_contamination.png",TexMan.Type_Any).IsValid(),"contamination HUD icon is available");
        }
        else if(e.Name=='ca410_harm')
        {Reset(u,1000,60);u.DerivedStats.HealthRegenerationPerSecond=0;u.CurrentHunger=100;u.CurrentThirst=100;}
        else if(e.Name=='ca410_immune')
        {u.Attributes.Toughness=100;u.DerivedStats.HealthRegenerationPerSecond=0;ImmuneLife=u.health;}
        else if(e.Name=='ca410_potential')
        {Reset(u,1000,0.5);u.Attributes.Toughness=100;u.DerivedStats.HealthRegenerationPerSecond=500;}
        else if(e.Name=='ca410_report')
        {Console.Printf("CA410 STATE life=%d/%d contamination=%.6f toughness=%.2f hunger=%.6f thirst=%.6f",u.health,u.CaelumMaximumHealth,CaelumFoodIllness.Value(u),u.Attributes.Toughness,u.CurrentHunger,u.CurrentThirst);}
        else if(e.Name=='ca410_harmcheck')Check(u.health>=978 && u.health<=981,"live simulation applies progressive illness damage");
        else if(e.Name=='ca410_immunecheck')Check(u.health==ImmuneLife,"live Toughness immunity stops illness");
        else if(e.Name=='ca410_potentialcheck')Check(u.health==1000 && CaelumFoodIllness.Value(u)==0
            && u.CurrentHunger<99 && u.CurrentThirst<99,"live full-Life depuration consumes reserves without over-healing");
        else if(e.Name=='ca410_seed')
        {
            Reset(u,1000,37.25);u.CurrentHunger=0;u.UpdateSurvivalStates();
            CaelumFoodIllness.Get(u).DamageFraction=0.375;u.PersistCharacterState();
            Check(CaelumFoodIllness.Value(u)==37.25,"saved illness seeded");
        }
        else if(e.Name=='ca410_loaded')
        {
            let illness=CaelumFoodIllness.Get(u);
            Check(illness!=null && illness.Revision==1,"saved illness schema restored");
            Check(illness.Contamination==37.25 && illness.DamageFraction==0.375,"contamination and accrued fractional damage survive reload");
        }
        Console.Printf("CA410 RESULT passed=%d failed=%d",Passed,Failed);
    }
}
