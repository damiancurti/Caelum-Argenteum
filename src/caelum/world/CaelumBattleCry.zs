// #243: prohibición temporal de atacar; no inmoviliza ni altera atributos.
class CaelumBattleCryEffect : Inventory
{
    int Revision, RemainingTics;
    override void Tick()
    {
        Super.Tick();
        if(Owner==null || Owner.health<=0 || RemainingTics<=0){Destroy();return;}
        CaelumBattleCry.Interrupt(Owner);
        if(--RemainingTics<=0)Destroy();
    }
    Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE }
    States { Spawn: TNT1 A -1; Stop; }
}

class CaelumBattleCry : Object play
{
    const REVISION=1;

    static CaelumBattleCryEffect Status(Actor body)
    {return body==null?null:CaelumBattleCryEffect(body.FindInventory("CaelumBattleCryEffect"));}

    static bool Active(Actor body)
    {let effect=Status(body);return body!=null && body.health>0 && effect!=null && effect.RemainingTics>0;}

    static void Interrupt(Actor body)
    {
        if(!Active(body))return;
        CaelumUtilityStaff.EndEmission(body);
        let user=CaelumPlayer(body);
        if(user!=null)
        {
            user.PhysicalAttackPending=false;
            let fists=CaelumUnarmedWeapon(user.FindInventory("CaelumUnarmedWeapon"));
            if(fists!=null)fists.Punching=false;
            user.CancelWeaponCharge();
            if(user.StaffCastPending)user.CancelPendingStaffCast(true);
            if(user.ClassCastActive && CaelumClassAbilityRules.Offensive(user.ClassCastProfession))CaelumClassAbilityRules.Cancel(user);
            user.StopSealChannel(true,false);
            if(user.RacialAbility is "CaelumTelekinesisEffect")CaelumRacialAbilityRules.Deactivate(user);
            user.BolasPreparedTics=0;user.BolasPreparedItem=0;
            return;
        }
        let npc=CaelumCombatActor(body);if(npc==null)return;
        CaelumDemonService.StopBreath(npc,false);
        let bull=CaelumBull(npc);if(bull!=null && bull.BullChargeActive)bull.StopBullCharge();
        let resident=CaelumAnchoredResident(npc);
        if(resident!=null && resident.ResidentTools!=null && resident.ResidentTools.Phase!=CaelumResidentTools.IDLE)
            resident.ResidentTools.Finish();
        if(npc.AttackResourceWaiting
            || (npc.MeleeState!=null && npc.InStateSequence(npc.CurState,npc.MeleeState))
            || (npc.MissileState!=null && npc.InStateSequence(npc.CurState,npc.MissileState)))
        {
            npc.AttackResourceWaiting=false;
            npc.SetState(npc.target!=null && npc.target.health>0 ? npc.SeeState : npc.SpawnState);
        }
    }

    static bool Apply(Actor body,int duration)
    {
        if(body==null || body.health<=0 || duration<=0
            || (CaelumPlayer(body)==null && CaelumCombatActor(body)==null))return false;
        let effect=Status(body);
        if(effect==null)effect=CaelumBattleCryEffect(body.GiveInventoryType("CaelumBattleCryEffect"));
        if(effect==null)return false;
        effect.Revision=REVISION;
        effect.RemainingTics=Max(effect.RemainingTics,duration);
        Interrupt(body);
        let user=CaelumPlayer(body);
        if(user!=null)CaelumNotifications.Notify(user,StringTable.Localize("CA_BATTLE_CRY_BLOCKED",false));
        return true;
    }

    static bool Release(CaelumPlayer user)
    {
        double radius=CaelumClassAbilityRules.Radius(user);
        int duration=int(CaelumClassAbilityRules.EFFECT_SECONDS*CaelumClassAbilityRules.HarmfulPower(user)*TICRATE+0.5);
        let it=ThinkerIterator.Create("Actor");Actor victim;int count=0;
        while((victim=Actor(it.Next()))!=null)
        {
            if(victim==user || victim.health<=0 || !CaelumSleepRules.Enemy(user,victim)
                || (victim.Pos-user.Pos).Length()>radius
                || !user.CheckSight(victim,SF_IGNOREVISIBILITY))continue;
            if(Apply(victim,duration))count++;
        }
        CaelumNotifications.Notify(user,String.Format(StringTable.Localize("CA_BATTLE_CRY_CAST",false),count));
        return true;
    }
}
