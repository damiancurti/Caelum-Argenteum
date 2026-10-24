// #502: extiende las comparaciones nativas ya verificadas del pronóstico.
class CA502Checks : CA410JChecks
{
    void Rules(CaelumPlayer u)
    {
        Check(Near(CaelumFoodRules.DamagePerSecond(50,1000,0),0),"C50 no disease damage");
        Check(Near(CaelumFoodRules.DamagePerSecond(89,1000,0),39),"C89 retains 3.9 percent Life per second");
        Check(Near(CaelumFoodRules.DamagePerSecond(90,1000,0),80),"C90 doubles to eight percent Life per second");
        Check(Near(CaelumFoodRules.DamagePerSecond(100,1000,0),100),"C100 ten percent Life per second");
        Check(Near(CaelumFoodRules.DamagePerSecond(90,1000,100),0),"severe Toughness100 immunity");
        Check(Near(CaelumFoodRules.DamagePerSecond(100,1000,150),0),"severe Toughness150 never heals");
        Reset(u,1000,89);Check(CaelumSurvivalView.ContaminationStateKey(u)=="CA_FOOD_CONTAMINATED","C89 contaminated label");
        Reset(u,1000,90);Check(CaelumSurvivalView.ContaminationStateKey(u)=="CA_CONTAMINATION_SICK","C90 sick label");
        u.Attributes.Toughness=100;
        Check(CaelumSurvivalView.ContaminationStateKey(u)=="CA_CONTAMINATION_SICK_IMMUNE","severe label preserves explicit damage immunity");
        Check(Near(CaelumContaminationRules.AfterContact(20,80,1,1),20.3960780543711),"80 to20 contact one-second integral");
        double together=CaelumContaminationRules.AfterContact(20,80,1,10),split=20;
        for(int i=0;i<TICRATE*10;i++)split=CaelumContaminationRules.AfterContact(split,80,1,1.0/TICRATE);
        Check(Near(together,23.6643191323985),"ten seconds update evolving concentration ratio");
        Check(Near(together,split),"ten seconds equals350 contact steps");
        Check(Near(CaelumContaminationRules.AfterContact(0,80,1,0.025),0.2),"clean recipient finite initial dose");
        Check(Near(CaelumContaminationRules.AfterContact(0,80,1,10),12.6095202129185),"clean recipient crosses denominator floor continuously");
        Check(Near(CaelumContaminationRules.AfterContact(0,0.5,1,100),0.5),"fractional source does not overshoot");
        Check(Near(CaelumContaminationRules.AfterContact(80,20,1,10),80),"cleaner source never cleans recipient");
        Check(Near(CaelumContaminationRules.AfterContact(20,20,1,10),20),"equal concentrations no exchange");
        Check(Near(CaelumContaminationRules.AfterContact(20,80,0,10),20),"zero area no exchange");
        Check(Near(CaelumContaminationRules.AfterContact(20,80,1,0),20),"zero time no exchange");
        Check(Near(CaelumContaminationRules.AfterContact(20,80,-1,10),20),"invalid area no exchange");
        Check(Near(CaelumContaminationRules.AfterContact(20,80,1,1e8),80),"long contact stops at source");
        Check(Near(CaelumContaminationRules.AfterContact(20,80,CaelumContaminationData.IMPACT_CONTACT_M2,
            CaelumContaminationData.IMPACT_CONTACT_SECONDS),20.0399600798006),"impact ten-second calibrated patch");
        Check(Near(CaelumContaminationRules.BodyDoseFactor(40),2)
            && Near(CaelumContaminationRules.BodyDoseFactor(160),0.5),"body exposure inverse mass reference");
        Check(Near(CaelumContaminationRules.Environment(5,20,50),5),"natural reference climate");
        Check(Near(CaelumContaminationRules.Environment(15,30,50),30),"urban hotter climate doubles");
        Check(Near(CaelumContaminationRules.Environment(40,20,100),60),"industrial humid climate");
        Check(Near(CaelumContaminationRules.Environment(60,30,100),100),"sewer index capped100");
        Check(Near(CaelumContaminationRules.Environment(5,20,-10),2.5),"humidity lower bound");
        Check(Near(CaelumContaminationRules.EquipmentWaterLiters(1),1)
            && Near(CaelumContaminationRules.SoapGrams(1),5),"one square meter water and soap cost");
        Check(Near(CaelumContaminationRules.EquipmentWaterLiters(0),0),"zero equipment area quote");
        Check(Near(CaelumContaminationRules.BathWaterLiters(90,80),45)
            && Near(CaelumContaminationRules.SoapGrams(45),225),"90 degree80kg bath quote");
        Check(Near(CaelumContaminationRules.BathWaterLiters(90,40),22.5)
            && Near(CaelumContaminationRules.BathWaterLiters(90,160),90),"bath scales with body mass");
        Check(Near(CaelumContaminationRules.BathWaterLiters(-1,80),0),"negative bath removal cannot credit resources");
        Check(CaelumTimeSkipModel.PROVISION_REVISION==7,"wait cache schema7 invalidates old damage predictions");
        Reset(u,1000,0);
    }
    void Runtime(CaelumPlayer u)
    {
        Parity(u,1000,89,0,35);Parity(u,1000,90,0,35);
        Parity(u,1000,100,0,35);Parity(u,1000,90,100,35);
        Reset(u,1000,90);u.DerivedStats.HealthRegenerationPerSecond=0;
        for(int i=0;i<TICRATE;i++)CaelumFoodIllness.Advance(u);
        Check(u.health==920,"actual damage engine applies80 Life loss atC90");
        Reset(u,1000,90);CaelumFoodIllness.Get(u).Depurate(1000,1000);
        Check(Near(CaelumFoodIllness.Value(u),89)
            && Near(CaelumFoodRules.DamagePerSecond(CaelumFoodIllness.Value(u),1000,0),39),
            "natural depuration below90 immediately removes double damage");
        Check(CaelumSurvivalView.ContaminationStateKey(u)=="CA_FOOD_CONTAMINATED","depuration clears sick label");
        Reset(u,1000,0);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Player<0 || e.Player>=MAXPLAYERS)return;
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca502_rules')Rules(u);
        else if(e.Name=='ca502_runtime')Runtime(u);
        else if(e.Name=='ca502_seed')Seed(u);
        else if(e.Name=='ca502_loaded')Loaded(u);
        else if(e.Name=='ca502_manual89'){Reset(u,1000,89);u.DerivedStats.HealthRegenerationPerSecond=0;}
        else if(e.Name=='ca502_manual90'){Reset(u,1000,90);u.DerivedStats.HealthRegenerationPerSecond=0;}
        else if(e.Name=='ca502_manual100'){Reset(u,1000,100);u.DerivedStats.HealthRegenerationPerSecond=0;}
        else if(e.Name=='ca502_immune'){Reset(u,1000,90,100);u.DerivedStats.HealthRegenerationPerSecond=0;}
        else if(e.Name=='ca502_clean')Reset(u,1000,0);
        else return;
        Console.Printf("CA502 RESULT passes=%d failures=%d",Passed,Failed);
    }
}
