// Las existencias viven en Actor.Inv, nunca en un contador duplicado de la IA.
class CaelumDemonService : Object play
{
    const SUPPLY_REVISION=1;

    static void StopBreath(CaelumCombatActor npc,bool settle=true,bool resume=true)
    {
        let probe=CA853BreathProbe.Sample();double stamp=0;if(probe!=null)stamp=MSTimeF();
        CA853Body_StopBreath(npc,settle,resume);
        if(probe!=null)probe.End(11,stamp);
    }

    static void CA853Body_StopBreath(CaelumCombatActor npc,bool settle=true,bool resume=true)
    {
        let flame=npc.DemonBreath;
        npc.DemonBreath=null;
        if(flame!=null){if(settle)flame.FlushHeat();flame.Destroy();}
        if(resume && npc.health>0 && CA853BreathProbe.Find(npc,"RacialBreath",1)!=null
            && CA853BreathProbe.Sequence(npc,npc.CurState,CA853BreathProbe.Find(npc,"RacialBreath",1),3))
        {if(npc.target!=null)npc.SetStateLabel("See");else npc.SetStateLabel("Spawn");}
    }

    static void UpdateBreath(CaelumCombatActor npc)
    {
        let probe=CA853BreathProbe.Sample();double stamp=0;if(probe!=null)stamp=MSTimeF();
        CA853Body_UpdateBreath(npc);
        if(probe!=null)probe.End(12,stamp);
    }

    static void CA853Body_UpdateBreath(CaelumCombatActor npc)
    {
        if(!Supports(npc))return;
        let boss=CaelumZupayColossus(npc);
        bool blocked=CA853BreathProbe.BattleCry(npc) || CA853BreathProbe.Held(npc) || npc.health<=0 || npc.ForcedSleepTics>0 || npc.CombatLucidityPhysicalStunRemaining>0
            || npc.RecoveryPhase==1
            || npc.CaelumDiagnosticPassiveAI || npc.CaelumMassAIScheduleActive
            || (boss!=null && boss.SewerFleeing)
            || (!CaelumRedemption.PreviouslyRaised(npc) && npc.SiegeCombatant!=null && npc.SiegeCombatant.Withdrawing)
            || (CA853BreathProbe.Find(npc,"Pain",0)!=null && CA853BreathProbe.Sequence(npc,npc.CurState,CA853BreathProbe.Find(npc,"Pain",0),2));
        bool ropes=CA853BreathProbe.Restrained(npc);
        if(ropes && CA853BreathProbe.Interrupted(npc))blocked=true;
        bool cold=npc.ThermalState!=null && npc.ThermalState.Exposure<0 && npc.ThermalState.Severity>0;
        bool combat=!blocked && npc.RecoveryPhase==0 && npc.target!=null && npc.target.health>0
            && npc.target.bSHOOTABLE && CA853BreathProbe.Identify(npc,npc.target) && CA853BreathProbe.CanReach(npc,npc.target);
        if(blocked || (!ropes && !cold && !combat)){StopBreath(npc,!CA853BreathProbe.BattleCry(npc));return;}
        // No se cancela a mitad una acción que ya pagó sus recursos.
        if(!ropes && npc.DemonBreath==null && ((npc.MeleeState!=null && CA853BreathProbe.Sequence(npc,npc.CurState,npc.MeleeState,4))
            || (npc.MissileState!=null && CA853BreathProbe.Sequence(npc,npc.CurState,npc.MissileState,4))))return;
        double cost=npc.GetMagicAnimaCost(CaelumDemonBreathRules.ANIMA_PER_SECOND)/TICRATE;
        if(npc.CurrentCombatAnima<cost){StopBreath(npc,!CA853BreathProbe.BattleCry(npc));return;}
        if(combat)npc.A_CaelumFacePerceivedTarget();
        if(npc.DemonBreath==null)
        {
            npc.DemonBreath=CaelumDemonBreath(Actor.Spawn("CaelumDemonBreath",npc.Pos,NO_REPLACE));
            if(npc.DemonBreath==null)return;
            npc.DemonBreath.Emitter=npc;
            CaelumNoise.Emit(npc,CaelumNoiseData.MAGIC);
            npc.SetStateLabel("RacialBreath");
        }
        // La regeneración natural sigue en el Tick normal, sin bloqueo mágico.
        npc.CurrentCombatAnima=Max(0.0,npc.CurrentCombatAnima-cost);
        if(ropes)CaelumBolas.FireContact(npc); // Contacto propio pagado, boca libre.
        npc.DemonBreath.PaidTick();
    }

    static clearscope bool Supports(CaelumCombatActor npc)
    {return npc!=null && (npc is "CaelumMandinga" || npc is "CaelumZupayColossus");}

    static clearscope int PotionSize(CaelumCombatActor npc)
    {return npc is "CaelumZupayColossus" ? CaelumPotionRules.LARGE : CaelumPotionRules.SMALL;}

    static CaelumConsumableItem Potion(CaelumCombatActor npc,int family)
    {
        if(!Supports(npc))return null;
        return CaelumConsumableItem(npc.FindInventory(
            CaelumPotionRules.ItemClass(CaelumPotionRules.Kind(family,PotionSize(npc))),false));
    }

    static void Initialize(CaelumCombatActor npc)
    {
        if(!Supports(npc) || npc.DemonSupplyRevision>=SUPPLY_REVISION || npc.health<=0)return;
        npc.DemonSupplyRevision=SUPPLY_REVISION;
        for(int family=0;family<3;family++)
        {
            // Una migración parcial conserva cualquier pila ya presente.
            if(Potion(npc,family)!=null)continue;
            let item=CaelumConsumableItem(Actor.Spawn(
                CaelumPotionRules.ItemClass(CaelumPotionRules.Kind(family,PotionSize(npc))),npc.Pos,NO_REPLACE));
            if(item==null)continue;
            item.Amount=CaelumPotionRules.INITIAL_DEMON_UNITS;
            item.AttachToOwner(npc);
        }
    }

    static clearscope int WeightedFamily(int life,int anima,int energy,int roll)
    {
        if(roll<0 || roll>=life+anima+energy)return -1;
        if(roll<life)return CaelumConstants.CONSUMABLE_LIFE_POTION;
        if(roll<life+anima)return CaelumConstants.CONSUMABLE_ANIMA_POTION;
        return CaelumConstants.CONSUMABLE_ENERGY_DRINK;
    }

    static void UpdatePotions(CaelumCombatActor npc)
    {
        if(!Supports(npc) || npc.health<=0 || npc.CaelumDiagnosticPassiveAI || npc.CaelumMassAIScheduleActive)return;
        Initialize(npc);
        for(int family=0;family<3;family++)
        {
            double value=family==0 ? npc.health : family==1 ? npc.CurrentCombatAnima : npc.CurrentCombatAir;
            double maximum=family==0 ? npc.CombatMaximumHealth : family==1 ? npc.MaximumCombatAnima : npc.MaximumCombatAir;
            if(maximum<=0 || value>=maximum*CaelumPotionRules.AUTO_USE_THRESHOLD)continue;
            let item=Potion(npc,family);
            if(item==null || item.Amount<=0)continue;
            let active=CaelumRegenerationPower(npc.FindInventory(item.GetPowerClassName()));
            // El refresco manual conserva su contrato; la IA espera por familia
            // y permite tres recursos simultáneos sin encadenar seis consumos.
            if(active!=null && active.EffectTics>0)continue;
            npc.UseInventory(item);
        }
    }

    static void ReleaseLoot(CaelumCombatActor npc,bool predefined)
    {
        if(!Supports(npc) || npc.health>0 || npc.DemonDeathLootReleased)return;
        npc.DemonDeathLootReleased=true;
        // Un drop definido conserva prioridad aun si su aparición falla.
        if(predefined || npc.GetDropItems()!=null)return;
        int counts[3];int total=0;
        for(int family=0;family<3;family++)
        {
            let item=Potion(npc,family);
            counts[family]=item!=null ? Max(0,item.Amount) : 0;
            total+=counts[family];
        }
        if(total<=0)return;
        int chosen=WeightedFamily(counts[0],counts[1],counts[2],Random[CaelumDemonLoot](0,total-1));
        let supply=Potion(npc,chosen);
        if(supply==null || supply.Amount<=0)return;
        let drop=Inventory(Actor.Spawn(supply.GetClassName(),npc.Pos,NO_REPLACE));
        if(drop==null)return;
        drop.Amount=1;
        supply.Amount--;
        CaelumActorMaintenance.InventoryChanged(npc);
        if(supply.Amount<=0)supply.Destroy();
    }
}

class CA853BreathProbe : StaticEventHandler
{
    Array<double> Total,Maximum;Array<int> Calls;
    bool Ready,Printed;
    override void WorldLoaded(WorldEvent e){Total.Resize(9100);Maximum.Resize(9100);Calls.Resize(9100);Ready=true;}
    static CA853BreathProbe Sample()
    {
        if(level.time<3599 || level.time>=4299 || (level.time-3599)%17!=0)return null;
        return CA853BreathProbe(StaticEventHandler.Find('CA853BreathProbe'));
    }
    void End(int metric,double start)
    {
        double elapsed=MSTimeF()-start;int cell=metric*700+level.time-3599;
        Total[cell]+=elapsed;Maximum[cell]=Max(Maximum[cell],elapsed);Calls[cell]++;
    }
    static State Find(CaelumCombatActor body,StateLabel label,int metric)
    {
        let probe=Sample();double stamp=0;if(probe!=null)stamp=MSTimeF();
        State result=body.FindState(label);
        if(probe!=null)probe.End(metric,stamp);return result;
    }
    static bool Sequence(CaelumCombatActor body,State current,State start,int metric)
    {
        let probe=Sample();double stamp=0;if(probe!=null)stamp=MSTimeF();
        bool result=body.InStateSequence(current,start);
        if(probe!=null)probe.End(metric,stamp);return result;
    }
    static bool BattleCry(CaelumCombatActor body)
    {
        let probe=Sample();double stamp=0;if(probe!=null)stamp=MSTimeF();
        bool result=CaelumBattleCry.Active(body);
        if(probe!=null)probe.End(5,stamp);return result;
    }
    static bool Held(CaelumCombatActor body)
    {
        let probe=Sample();double stamp=0;if(probe!=null)stamp=MSTimeF();
        bool result=CaelumTelekinesisRules.Held(body);
        if(probe!=null)probe.End(6,stamp);return result;
    }
    static bool Restrained(CaelumCombatActor body)
    {
        let probe=Sample();double stamp=0;if(probe!=null)stamp=MSTimeF();
        bool result=CaelumBolas.Restrained(body);
        if(probe!=null)probe.End(7,stamp);return result;
    }
    static bool Interrupted(CaelumCombatActor body)
    {
        let probe=Sample();double stamp=0;if(probe!=null)stamp=MSTimeF();
        bool result=CaelumBolas.Interrupted(body);
        if(probe!=null)probe.End(8,stamp);return result;
    }
    static bool Identify(CaelumCombatActor body,Actor target)
    {
        let probe=Sample();double stamp=0;if(probe!=null)stamp=MSTimeF();
        bool result=CaelumVisualPerception.Identify(body,target);
        if(probe!=null)probe.End(9,stamp);return result;
    }
    static bool CanReach(CaelumCombatActor body,Actor target)
    {
        let probe=Sample();double stamp=0;if(probe!=null)stamp=MSTimeF();
        bool result=CaelumDemonBreath.CanReach(body,target);
        if(probe!=null)probe.End(10,stamp);return result;
    }
    override void WorldTick()
    {
        if(!Ready || Printed || level.time!=4350)return;Printed=true;
        for(int tic=0;tic<700;tic++)for(int metric=0;metric<13;metric++)
        {int cell=metric*700+tic;if(Calls[cell]>0)Console.Printf("CA853 SERVICE tic=%d metric=%d total=%.6f maximum=%.6f calls=%d",tic+3599,metric,Total[cell],Maximum[cell],Calls[cell]);}
        Console.Printf("CA853 SERVICES_COMPLETE");
    }
}
