// Las existencias viven en Actor.Inv, nunca en un contador duplicado de la IA.
class CaelumDemonService : Object play
{
    const SUPPLY_REVISION=1;

    static void StopBreath(CaelumCombatActor npc,bool settle=true,bool resume=true)
    {
        let flame=npc.DemonBreath;
        npc.DemonBreath=null;
        if(flame!=null){if(settle)flame.FlushHeat();flame.Destroy();}
        if(resume && npc.health>0 && npc.FindState("RacialBreath")!=null
            && npc.InStateSequence(npc.CurState,npc.FindState("RacialBreath")))
        {if(npc.target!=null)npc.SetStateLabel("See");else npc.SetStateLabel("Spawn");}
    }

    static void UpdateBreath(CaelumCombatActor npc)
    {
        if(!Supports(npc))return;
        let boss=CaelumZupayColossus(npc);
        bool blocked=npc.health<=0 || npc.ForcedSleepTics>0 || npc.CombatLucidityPhysicalStunRemaining>0
            || npc.RecoveryPhase==1
            || npc.CaelumDiagnosticPassiveAI || npc.CaelumMassAIScheduleActive
            || (boss!=null && boss.SewerFleeing)
            || (npc.SiegeCombatant!=null && npc.SiegeCombatant.Withdrawing)
            || (npc.FindState("Pain")!=null && npc.InStateSequence(npc.CurState,npc.FindState("Pain")));
        bool cold=npc.ThermalState!=null && npc.ThermalState.Exposure<0 && npc.ThermalState.Severity>0;
        bool combat=!blocked && npc.RecoveryPhase==0 && npc.target!=null && npc.target.health>0
            && npc.target.bSHOOTABLE && CaelumDemonBreath.CanReach(npc,npc.target);
        if(blocked || (!cold && !combat)){StopBreath(npc);return;}
        // No se cancela a mitad una acción que ya pagó sus recursos.
        if(npc.DemonBreath==null && ((npc.MeleeState!=null && npc.InStateSequence(npc.CurState,npc.MeleeState))
            || (npc.MissileState!=null && npc.InStateSequence(npc.CurState,npc.MissileState))))return;
        double cost=npc.GetMagicAnimaCost(CaelumDemonBreathRules.ANIMA_PER_SECOND)/TICRATE;
        if(npc.CurrentCombatAnima<cost){StopBreath(npc);return;}
        if(combat)npc.A_FaceTarget();
        if(npc.DemonBreath==null)
        {
            npc.DemonBreath=CaelumDemonBreath(Actor.Spawn("CaelumDemonBreath",npc.Pos,NO_REPLACE));
            if(npc.DemonBreath==null)return;
            npc.DemonBreath.Emitter=npc;
            npc.SetStateLabel("RacialBreath");
        }
        // La regeneración natural sigue en el Tick normal, sin bloqueo mágico.
        npc.CurrentCombatAnima=Max(0.0,npc.CurrentCombatAnima-cost);
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
        if(supply.Amount<=0)supply.Destroy();
    }
}
