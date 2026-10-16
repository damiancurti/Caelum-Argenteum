// #248: el área sigue al lanzador; cada receptor conserva su propia barra.
class CaelumRallyEffect : Inventory
{
    int Revision, RemainingTics, PulseTics;
    double Power, Range;
    override void Tick()
    {
        Super.Tick();
        let user=CaelumPlayer(Owner);
        if(user==null || user.health<=0 || RemainingTics<=0){Destroy();return;}
        if(--PulseTics<=0)
        {
            PulseTics=TICRATE;
            CaelumRally.Pulse(self);
        }
        if(--RemainingTics<=0)Destroy();
    }
    Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE }
    States { Spawn: TNT1 A -1; Stop; }
}

class CaelumRally : Object play
{
    const REVISION=1;
    const BASE_RECOVERY_RATIO=0.10;

    static clearscope CaelumRallyEffect Status(CaelumPlayer user)
    {return user==null?null:CaelumRallyEffect(user.FindInventory("CaelumRallyEffect"));}

    static clearscope bool Active(CaelumPlayer user)
    {let effect=Status(user);return user!=null && user.health>0 && effect!=null
        && effect.Revision==REVISION && effect.RemainingTics>0;}

    static bool Eligible(CaelumRallyEffect effect,Actor body)
    {
        if(CaelumRedemption.Pending(body))return false;
        let summoned=CaelumSummonedZupay(body);
        if(summoned!=null && summoned.AwaitingPlacement)return false;
        let caster=CaelumPlayer(effect.Owner);
        if(caster==null || caster.health<=0 || effect.Revision!=REVISION || effect.RemainingTics<=0
            || body==null || body.health<=0
            || (CaelumPlayer(body)==null && CaelumCombatActor(body)==null))return false;
        if(body!=caster)
        {
            bool allied=CaelumRedemption.Allied(caster,body);
            if(!allied || (body.Pos-caster.Pos).Length()>effect.Range
                || !caster.CheckSight(body,SF_IGNOREVISIBILITY))return false;
        }
        return true;
    }

    static CaelumRallyEffect Strongest(Actor body)
    {
        if(body==null || body.health<=0)return null;
        let it=ThinkerIterator.Create("CaelumRallyEffect");CaelumRallyEffect effect,best;
        while((effect=CaelumRallyEffect(it.Next()))!=null)
        {
            if(!Eligible(effect,body))continue;
            if(best==null || effect.Power>best.Power || (effect.Power==best.Power
                && effect.Owner.PlayerNumber()<best.Owner.PlayerNumber()))best=effect;
        }
        return best;
    }

    static bool Affected(Actor body) {return Strongest(body)!=null;}

    static double Factor(Actor body)
    {
        let effect=Strongest(body);if(effect==null)return 1;
        let user=CaelumPlayer(body);let npc=CaelumCombatActor(body);
        double ratio=user!=null ? (user.DerivedStats!=null && user.DerivedStats.MaximumAdrenaline>0
            ? user.CurrentAdrenaline/user.DerivedStats.MaximumAdrenaline : 0)
            : npc.GetCombatAdrenalineRatio();
        return (1+Clamp(ratio,0.0,1.0))*effect.Power;
    }

    static double DamageFactor(Actor victim,Actor source)
    {
        // Las caídas y las explosiones propias sólo reciben protección.
        return (source!=victim ? Factor(source) : 1)/Factor(victim);
    }

    static double PendingFactor(Actor victim)
    {
        let user=CaelumPlayer(victim);let npc=CaelumCombatActor(victim);
        double factor=user!=null ? user.RallyDamageFactor : npc!=null ? npc.RallyDamageFactor : 0;
        return factor>0 ? factor : 1;
    }

    static int ScaleDamage(Actor victim,int damage)
    {
        if(damage<=0)return damage;
        int result=Max(0,int(damage*PendingFactor(victim)+0.5));
        let user=CaelumPlayer(victim);
        if(user!=null){user.RallyPayloadBaseDamage=damage;user.RallyResolvedDamage=result;}
        return result;
    }

    static int PayloadLoss(CaelumPlayer user,int actualLoss)
    {
        // La dosis no guarda Arenga: el estado resolverá su factor vivo en cada pulso.
        // Conservar también la retención nativa y el piso de seguridad del tutorial.
        if(PendingFactor(user)==1 || user.RallyResolvedDamage<=0
            || (user.health==1 && CaelumTutorialSafety.Protects(user)))return actualLoss;
        return Max(0,int(actualLoss*double(user.RallyPayloadBaseDamage)/user.RallyResolvedDamage+0.5));
    }

    static void Pulse(CaelumRallyEffect effect)
    {
        let it=ThinkerIterator.Create("Actor");Actor body;
        while((body=Actor(it.Next()))!=null)
        {
            if(!Eligible(effect,body) || Strongest(body)!=effect)continue;
            double ratio=BASE_RECOVERY_RATIO*effect.Power;
            let user=CaelumPlayer(body);
            if(user!=null && user.DerivedStats!=null)
                user.AddAdrenaline(user.DerivedStats.MaximumAdrenaline*ratio);
            else
            {
                let npc=CaelumCombatActor(body);
                if(npc!=null)npc.CurrentCombatAdrenaline=Clamp(npc.CurrentCombatAdrenaline
                    +npc.MaximumCombatAdrenaline*ratio,0.0,npc.MaximumCombatAdrenaline);
            }
        }
    }

    static bool Release(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || user.health<=0 || user.DerivedStats==null)return false;
        let effect=Status(user);bool renewed=effect!=null && effect.RemainingTics>0;
        if(effect==null)effect=CaelumRallyEffect(user.GiveInventoryType("CaelumRallyEffect"));
        if(effect==null)return false;
        effect.Revision=REVISION;
        effect.Power=CaelumClassAbilityRules.BeneficialPower(user);
        effect.Range=CaelumClassAbilityRules.Radius(user);
        effect.RemainingTics=Max(effect.RemainingTics,
            int(CaelumClassAbilityRules.EFFECT_SECONDS*effect.Power*TICRATE+0.5));
        if(!renewed)effect.PulseTics=TICRATE;
        CaelumNotifications.Notify(user,StringTable.Localize("CA_RALLY_CAST",false));
        return true;
    }
}
