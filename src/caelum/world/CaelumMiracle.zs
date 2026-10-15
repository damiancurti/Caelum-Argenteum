// #245: aura móvil; los beneficiarios se deciden de nuevo en cada pulso.
class CaelumMiracleEffect : Inventory
{
    int Revision, RemainingTics, PulseTics;
    double RecoveryRatio, Range;
    override void Tick()
    {
        Super.Tick();
        let user=CaelumPlayer(Owner);
        if(user==null || user.health<=0 || RemainingTics<=0){Destroy();return;}
        if(--PulseTics<=0)
        {
            PulseTics=TICRATE;
            CaelumMiracle.Pulse(self);
        }
        if(--RemainingTics<=0)Destroy();
    }
    Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE }
    States { Spawn: TNT1 A -1; Stop; }
}

class CaelumMiracle : Object
{
    const REVISION=1;
    const BASE_RECOVERY_RATIO=0.03;

    static clearscope CaelumMiracleEffect Status(CaelumPlayer user)
    {return user==null?null:CaelumMiracleEffect(user.FindInventory("CaelumMiracleEffect"));}

    static clearscope bool Active(CaelumPlayer user)
    {let effect=Status(user);return user!=null && user.health>0 && effect!=null
        && effect.Revision==REVISION && effect.RemainingTics>0;}

    static play bool Eligible(CaelumMiracleEffect effect,Actor body)
    {
        let summoned=CaelumSummonedZupay(body);
        if(summoned!=null && summoned.AwaitingPlacement)return false;
        let caster=CaelumPlayer(effect.Owner);
        if(caster==null || caster.health<=0 || effect.Revision!=REVISION || effect.RemainingTics<=0
            || body==null || body.health<=0
            || (CaelumPlayer(body)==null && CaelumCombatActor(body)==null))return false;
        if(body!=caster)
        {
            bool allied=body.player!=null ? (!deathmatch || body.IsTeammate(caster))
                : body.bIsMonster && body.bFriendly && body.IsFriend(caster);
            if(!allied || (body.Pos-caster.Pos).Length()>effect.Range
                || !caster.CheckSight(body,SF_IGNOREVISIBILITY))return false;
        }
        return true;
    }

    static play bool Strongest(CaelumMiracleEffect effect,Actor body)
    {
        // Cada lanzador conserva su reloj; un área más débil nunca suma otro pulso.
        // En empates, la identidad nativa del jugador da un orden estable.
        let it=ThinkerIterator.Create("CaelumMiracleEffect");CaelumMiracleEffect other;
        while((other=CaelumMiracleEffect(it.Next()))!=null)
        {
            if(other==effect || !Eligible(other,body))continue;
            if(other.RecoveryRatio>effect.RecoveryRatio
                || (other.RecoveryRatio==effect.RecoveryRatio
                    && other.Owner.PlayerNumber()<effect.Owner.PlayerNumber()))return false;
        }
        return true;
    }

    static play bool Affected(Actor body)
    {
        let it=ThinkerIterator.Create("CaelumMiracleEffect");CaelumMiracleEffect effect;
        while((effect=CaelumMiracleEffect(it.Next()))!=null)
            if(Eligible(effect,body))return true;
        return false;
    }

    static play void Pulse(CaelumMiracleEffect effect)
    {
        let it=ThinkerIterator.Create("Actor");Actor body;
        while((body=Actor(it.Next()))!=null)
        {
            if(!Eligible(effect,body) || !Strongest(effect,body))continue;
            let user=CaelumPlayer(body);
            if(user!=null)CaelumPlayerResources.ApplyMiraclePulse(user,effect.RecoveryRatio);
            else CaelumCombatActor(body).ApplyMiraclePulse(effect.RecoveryRatio);
        }
    }

    static play bool Release(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || user.health<=0 || user.DerivedStats==null)return false;
        let effect=Status(user);bool renewed=effect!=null && effect.RemainingTics>0;
        if(effect==null)effect=CaelumMiracleEffect(user.GiveInventoryType("CaelumMiracleEffect"));
        if(effect==null)return false;
        double power=CaelumClassAbilityRules.BeneficialPower(user);
        effect.Revision=REVISION;
        effect.RecoveryRatio=BASE_RECOVERY_RATIO*power;
        effect.Range=CaelumClassAbilityRules.Radius(user);
        effect.RemainingTics=Max(effect.RemainingTics,
            int(CaelumClassAbilityRules.EFFECT_SECONDS*power*TICRATE+0.5));
        if(!renewed)effect.PulseTics=TICRATE;
        CaelumNotifications.Notify(user,StringTable.Localize("CA_MIRACLE_CAST",false));
        return true;
    }
}
