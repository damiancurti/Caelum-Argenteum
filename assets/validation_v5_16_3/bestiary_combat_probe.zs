// Perfil nativo comparado con un Mandinga real; no simula encuentros de campana.
class CA455CombatVictim : Actor
{
    Default { Monster; +FRIENDLY +NOGRAVITY }
    States { Spawn: MNDG A -1; Stop; }
}
class CA455CombatProbe : EventHandler
{
    Array<CaelumBestiaryCombatActor> Bodies;
    CaelumMandinga Baseline;
    int Failures;
    bool Prepared,Depleted;
    CaelumMandinga Fighter;
    Actor Victim;
    int ActionAge,ActionMode,ActionCount,ActionIndex,Projectiles,VictimHealth,TemplateHealth;
    double StartingAir,StartingAnima;
    bool SpentAir,SpentAnima,SawBreath;
    Array<CaelumConsumableItem> Drops;
    Array<int> Remaining;
    bool CollectingDrops,LootPrepared;
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
    void BeginAction(int index,int mode)
    {
        Check(Fighter==null,"previous action completed",index);if(Fighter!=null)return;
        // Cada acción usa un cuerpo nuevo y un único blanco, sin espectadores.
        for(int i=0;i<Bodies.Size();i++)if(Bodies[i]!=null)Bodies[i].Destroy();
        Bodies.Clear();if(Baseline!=null){TemplateHealth=Baseline.CombatMaximumHealth;Baseline.Destroy();}Baseline=null;
        class<Actor> kind='CaelumMandinga';
        if(index>=0)kind=CaelumBestiaryData.ActorClass(index);
        Fighter=CaelumMandinga(Actor.Spawn(kind,(-512,-768,0),NO_REPLACE));
        Check(Fighter!=null,"representative class found",index);if(Fighter==null)return;
        ActionIndex=index;ActionMode=mode;ActionAge=Projectiles=0;SpentAir=SpentAnima=SawBreath=false;
        Fighter.CaelumDiagnosticPassiveAI=true;Fighter.SetStateLabel("SiegeWithdrawal");Fighter.Angle=0;
        Victim=Actor.Spawn("CA455CombatVictim",Fighter.Pos+(Fighter.MeleeRange*(mode==1?4:0.5),0,0),NO_REPLACE);
        Victim.A_SetSize(Fighter.Radius,Fighter.Height);VictimHealth=TemplateHealth;Victim.health=VictimHealth;
        Fighter.target=Victim;
    }
    override void WorldThingSpawned(WorldEvent e)
    {
        if(CollectingDrops && e.Thing is "CaelumConsumableItem")Drops.Push(CaelumConsumableItem(e.Thing));
    }
    void PrepareLoot()
    {
        if(LootPrepared)return;LootPrepared=true;CollectingDrops=true;
        for(int i=0;i<Bodies.Size();i++)
        {
            let body=Bodies[i];
            for(int family=0;family<3;family++)
            {
                let item=CaelumDemonService.Potion(body,family);
                if(family!=1 && item!=null)body.TakeInventory(item.GetClassName(),item.Amount);
            }
            let supply=CaelumDemonService.Potion(body,1);Remaining.Push(supply.Amount-1);
            body.health=0;body.Die(null,null,0,'None');
        }
    }
    void AuditLoot()
    {
        Check(LootPrepared && Drops.Size()==56,"one available-family drop per death");
        for(int i=0;i<Bodies.Size();i++)
        {
            let body=Bodies[i];let supply=CaelumDemonService.Potion(body,1);
            Check(body.health<=0 && body.DemonDeathLootReleased,"native death and loot guard",body.BestiaryIndex());
            Check(supply!=null && supply.Amount==Remaining[i],"drop debited from finite stock",body.BestiaryIndex());
            if(i<Drops.Size())Check(Drops[i]!=null && Drops[i].Owner==null && Drops[i].Amount==1
                && Drops[i].GetClass()==supply.GetClass(),"native world drop identity",body.BestiaryIndex());
            body.Die(null,null,0,'None');CaelumDemonService.ReleaseLoot(body,false);
            Check(supply.Amount==Remaining[i],"repeated death/service cannot duplicate loot",body.BestiaryIndex());
        }
        Check(Drops.Size()==56,"no duplicate drops");
        Console.Printf("CA455 LOOT %s bodies=%d drops=%d failures=%d",Failures==0?"PASS":"FAIL",Bodies.Size(),Drops.Size(),Failures);
    }
    override void WorldTick()
    {
        if(Fighter==null)return;
        ActionAge++;
        if(ActionAge<=71){CaelumVisualPerception.Identify(Fighter,Victim);return;}
        if(ActionAge==72)
        {
            Fighter.CurrentCombatAir=Fighter.MaximumCombatAir;Fighter.CurrentCombatAnima=Fighter.MaximumCombatAnima;
            StartingAir=Fighter.CurrentCombatAir;StartingAnima=Fighter.CurrentCombatAnima;
            Console.Printf("CA455 SIGHT index=%d mode=%d live=%d/%d health=%d/%d visible=%d sight=%d order=%d dormant=%d sleep=%d stun=%.2f distance=%.2f angle=%.2f",
                ActionIndex,ActionMode,CaelumVisualPerception.Living(Fighter),CaelumVisualPerception.Living(Victim),Fighter.health,Victim.health,
                CaelumVisualPerception.CanSee(Fighter,Victim),Fighter.CheckSight(Victim),CaelumCommunication.MayEngage(Fighter,Victim),
                Fighter.bDormant,Fighter.ForcedSleepTics,Fighter.CombatLucidityPhysicalStunRemaining,Fighter.Distance3D(Victim),Fighter.Angle);
            Check(CaelumVisualPerception.Identify(Fighter,Victim),"native identification before attack",ActionIndex);
            Fighter.CaelumDiagnosticPassiveAI=false;
            if(ActionMode==0)Fighter.SetState(Fighter.MeleeState);
            else if(ActionMode==1)Fighter.SetState(Fighter.MissileState);
            // El servicio inicia el aliento; Look descartaría el blanco inerte de la prueba.
        }
        SpentAir|=Fighter.CurrentCombatAir<StartingAir;
        SpentAnima|=Fighter.CurrentCombatAnima<StartingAnima;
        SawBreath|=Fighter.DemonBreath!=null;
        Projectiles=Fighter.ImpactDiagnosticProjectilesSpawned;
        if(ActionAge<142)return;
        bool damaged=Victim==null || Victim.health<VictimHealth;
        bool okay=ActionMode==0?damaged && SpentAir:ActionMode==1?Projectiles>0 && SpentAnima:SawBreath && SpentAnima;
        Check(okay,"native action execution",ActionIndex);ActionCount++;
        Console.Printf("CA455 ACTION %s index=%d mode=%d damage=%d air=%d anima=%d projectiles=%d breath=%d",
            okay?"PASS":"FAIL",ActionIndex,ActionMode,damaged,SpentAir,SpentAnima,Projectiles,SawBreath);
        Fighter.target=null;Fighter.lastenemy=null;CaelumDemonService.StopBreath(Fighter);
        Fighter.Destroy();
        if(Victim!=null)Victim.Destroy();Victim=null;Fighter=null;
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="ca455_prepare")Prepare();
        else if(e.Name=="ca455_audit")Audit();
        else if(e.Name=="ca455_action")BeginAction(e.Args[0],e.Args[1]);
        else if(e.Name=="ca455_loot")PrepareLoot();
        else if(e.Name=="ca455_audit_loot")AuditLoot();
        else if(e.Name=="ca455_action_result")
            Console.Printf("CA455 ACTIONS %s completed=%d failures=%d",ActionCount==18 && Fighter==null && Failures==0?"PASS":"FAIL",ActionCount,Failures);
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
