version "4.14.2"
// Perfil nativo comparado con un Mandinga real; no simula encuentros de campana.
class CA455CombatProbe : EventHandler
{
    Array<CaelumBestiaryCombatActor> Bodies;
    CaelumMandinga Baseline;
    int Failures;
    bool Prepared,Depleted;
    void Check(bool okay,String label,int index=-1)
    {
        if(!okay){Failures++;Console.Printf("CA455 COMBAT FAIL index=%d %s",index,label);}
    }
    void Prepare()
    {
        if(Prepared)return;Prepared=true;
        let user=CaelumPlayer(players[0].mo);user.bNOTARGET=true;user.bInvulnerable=true;
        Baseline=CaelumMandinga(Actor.Spawn("CaelumMandinga",(768,768,0),NO_REPLACE));
        Baseline.CaelumDiagnosticPassiveAI=true;
        for(int i=0;i<CaelumBestiaryData.COUNT;i++)
        {
            let kind=CaelumBestiaryData.ActorClass(i);
            if(kind==null)continue;
            let body=CaelumBestiaryCombatActor(Actor.Spawn(kind,(-768+(i%8)*160,-256+(i/8)*128,0),NO_REPLACE));
            Check(body!=null,"native class spawn",i);if(body==null)continue;
            body.CaelumDiagnosticPassiveAI=true;Bodies.Push(body);
        }
    }
    bool SameAttributes(CaelumCombatActor body)
    {
        return body.CombatStrength==Baseline.CombatStrength && body.CombatConstitution==Baseline.CombatConstitution
            && body.CombatToughness==Baseline.CombatToughness && body.CombatResilience==Baseline.CombatResilience
            && body.CombatAgility==Baseline.CombatAgility && body.CombatPatience==Baseline.CombatPatience
            && body.CombatDexterity==Baseline.CombatDexterity && body.CombatInsight==Baseline.CombatInsight
            && body.CombatIntelligence==Baseline.CombatIntelligence && body.CombatCharisma==Baseline.CombatCharisma
            && body.CombatEmpathy==Baseline.CombatEmpathy && body.CombatEloquence==Baseline.CombatEloquence;
    }
    void Audit()
    {
        Check(Prepared && Baseline!=null,"fixture exists");if(Baseline==null)return;
        Check(Bodies.Size()==56,"56 new classes");
        Check(CaelumBestiaryData.ActorClass(17)==null && CaelumBestiaryData.ActorClass(18)==null,"protected Mandinga/Zupay excluded");
        let user=CaelumPlayer(players[0].mo);
        for(int n=0;n<Bodies.Size();n++)
        {
            let body=Bodies[n];int i=body.BestiaryIndex();
            Check(SameAttributes(body),"twelve current attributes",i);
            Check(body.CombatMaximumHealth==Baseline.CombatMaximumHealth && body.MaximumCombatAnima==Baseline.MaximumCombatAnima
                && body.MaximumCombatAir==Baseline.MaximumCombatAir && body.CombatBaseSpeed==Baseline.CombatBaseSpeed,"derived maxima/speed",i);
            Check(body.Radius==Baseline.Radius && body.Height==Baseline.Height && body.Mass==Baseline.Mass,"temporary body inherited",i);
            Check(body.GetInnateArmorDefense(false)==Baseline.GetInnateArmorDefense(false)
                && body.GetInnateArmorDefense(true)==Baseline.GetInnateArmorDefense(true),"provisional defense adapter",i);
            Check(body.BestiaryReference()==CaelumBestiaryData.Reference(i) && body.BestiaryTaxonomy()==CaelumBestiaryData.Taxonomy(i)
                && body.BestiaryPopulation()==CaelumBestiaryData.Population(i),"catalogue identity/taxonomy/population",i);
            Check(body.GetClass()==CaelumBestiaryData.ActorClass(i) && body.MandingaBirthInitialized,"stable class/initialization",i);
            Check(body.FindState("Melee")==Baseline.FindState("Melee") && body.FindState("Missile")==Baseline.FindState("Missile")
                && body.FindState("RacialBreath")==Baseline.FindState("RacialBreath") && body.FindState("Death")==Baseline.FindState("Death"),"shared action states",i);
            Check(body.IsHostile(user)==Baseline.IsHostile(user) && body.IsAlliedMandinga(Baseline),"shared hostility/alliance",i);
            Check(CaelumDemonService.Supports(body) && body.DemonSupplyRevision==Baseline.DemonSupplyRevision,"native resource service",i);
            for(int family=0;family<3;family++)
            {
                let potion=CaelumDemonService.Potion(body,family);let base=CaelumDemonService.Potion(Baseline,family);
                Check(potion!=null && base!=null && potion.GetClass()==base.GetClass()
                    && potion.Amount==base.Amount-(Depleted && family==0?1:0),"finite inventory persists",i);
            }
            Console.Printf("CA455 PROFILE index=%d reference=%s taxonomy=%s maximum_health=%d radius=%.6f height=%.6f",
                i,body.BestiaryReference(),body.BestiaryTaxonomy(),body.CombatMaximumHealth,body.Radius,body.Height);
        }
        // El tipo concreto no se sustituye por el NPC protegido de la misma especie.
        Check(Bodies[4].BestiaryReference()=="CA-FOLK-005" && !(Bodies[4] is "CaelumRulo"),"repeatable Ucumar is not Rulo");
        Console.Printf("CA455 COMBAT %s bodies=%d depleted=%d failures=%d",Failures==0?"PASS":"FAIL",Bodies.Size(),Depleted,Failures);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca455_prepare")Prepare();
        else if(e.Name=="ca455_audit")Audit();
        else if(e.Name=="ca455_deplete")
        {
            if(Depleted)return;
            for(int i=0;i<Bodies.Size();i++)
            {
                let potion=CaelumDemonService.Potion(Bodies[i],0);
                if(potion!=null)Bodies[i].TakeInventory(potion.GetClassName(),1);
            }
            Depleted=true;
        }
    }
}
