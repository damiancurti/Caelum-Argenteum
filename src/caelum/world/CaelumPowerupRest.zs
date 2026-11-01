// Descanso personal aislado: copia la aritmética compartida, no el reloj mundial.
class CaelumPowerupRestModel : CaelumTimeSkipModel
{
    override void ServeSupplies()
    {
        // Porciones frescas abstractas del efecto; jamás toma comida del jugador.
        for(int i=0;i<Supplies.Size();i++)Supplies[i].Count=1;
        RefreshTriggers();Super.ServeSupplies();
    }
    void Prepare(CaelumPlayer user,bool sleeping)
    {
        Capture(user,true,false);
        FoodInventory=null;Contamination=null;
        Scale=CaelumWorldClock.MapTimeScale(level.MapName);
        HungerLoss*=Scale;ThirstLoss*=Scale;SleepLoss*=Scale;AltitudeSecondsPerTic*=Scale;
        Sleeping=sleeping;HasChair=!sleeping;
        ChairFactor=CaelumRestRules.CHAIR_RESOURCE_FACTOR;
        let bed=CaelumRestFurniture(GetDefaultByType('CaelumRestBed'));
        BedFactor=bed.ComfortFactor();
        for(int kind=1;kind<=2;kind++)
        {let supply=new('CaelumSkipSupply');supply.Kind=kind;supply.Count=1;Supplies.Push(supply);}
        RefreshTriggers();
        let food=CaelumRegenerationPower(user.FindInventory('CaelumHungerRegeneration'));
        let water=CaelumRegenerationPower(user.FindInventory('CaelumThirstRegeneration'));
        if(food!=null)
        {FoodEffectTics=food.EffectTics;FoodPulseTics=food.PulseTics;FoodSeatedSubTics=food.SeatedMealSubTics;FoodPulse=food.FoodRecoveryPerPulse;}
        if(water!=null)
        {WaterEffectTics=water.EffectTics;WaterPulseTics=water.PulseTics;WaterSeatedSubTics=water.SeatedMealSubTics;WaterPulse=water.WaterRecoveryPerPulse;}
    }
    static void Apply(CaelumPlayer user,bool sleeping)
    {
        let model=new('CaelumPowerupRestModel');model.Prepare(user,sleeping);
        int tics=(sleeping?CaelumPowerupData.SLEEP_SECONDS:CaelumPowerupData.REST_SECONDS)*TICRATE;
        // Trabajo acotado: máximo 12.600 pasos numéricos, sin consultas de mundo.
        for(int i=0;i<tics && model.Health>0;i++)model.Step(sleeping);
        if(model.Health>0 && model.FoodIllness!=null)
        {model.FoodIllness.ToiletDepurate();if(sleeping)model.FoodIllness.Contamination=0;}
        // La aplicación común conserva fracciones, digestión y recargas. No
        // consume provisiones propias ni desplaza a otros participantes.
        model.FoodSpent=0;model.WaterSpent=0;model.ContainerSpent=0;
        let food=user.FindInventory('CaelumHungerRegeneration');if(food!=null)food.Destroy();
        let water=user.FindInventory('CaelumThirstRegeneration');if(water!=null)water.Destroy();
        let plan=CaelumJourneyPlan(Actor.Spawn('CaelumJourneyPlan',user.Pos,NO_REPLACE));
        plan.Available=model;plan.Apply(user,false);plan.Destroy();
        food=user.FindInventory('CaelumHungerRegeneration');water=user.FindInventory('CaelumThirstRegeneration');
        if(food!=null)CaelumRegenerationPower(food).SeatedMealSubTics=model.FoodSeatedSubTics;
        if(water!=null)CaelumRegenerationPower(water).SeatedMealSubTics=model.WaterSeatedSubTics;
        if(user.health<=0)user.Die(null,null,0,'CaelumDiseaseDOT');
    }
}
