// #244: contribución temporal; nunca multiplica los atributos guardados.
class CaelumSurvivalInstinctEffect : Inventory
{
    int Revision, RemainingTics;
    double Multiplier;
    override void Tick()
    {
        Super.Tick();
        if(Owner==null || Owner.health<=0 || RemainingTics<=0){Destroy();return;}
        if(--RemainingTics<=0)Destroy();
    }
    Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE +INVENTORY.UNTOSSABLE }
    States { Spawn: TNT1 A -1; Stop; }
}

class CaelumSurvivalInstinct : Object
{
    const REVISION=1;
    const BASE_MULTIPLIER=3.0;

    static clearscope CaelumSurvivalInstinctEffect Status(CaelumPlayer user)
    {return user==null?null:CaelumSurvivalInstinctEffect(user.FindInventory("CaelumSurvivalInstinctEffect"));}

    static clearscope bool Active(CaelumPlayer user)
    {
        let effect=Status(user);
        return user!=null && user.health>0 && effect!=null
            && effect.Revision==REVISION && effect.RemainingTics>0;
    }

    static clearscope double Multiplier(CaelumPlayer user)
    {return Active(user)?Status(user).Multiplier:1.0;}

    static play bool Release(CaelumPlayer user)
    {
        if(user==null || user.health<=0 || user.DerivedStats==null)return false;
        let effect=Status(user);
        if(effect==null)effect=CaelumSurvivalInstinctEffect(user.GiveInventoryType("CaelumSurvivalInstinctEffect"));
        if(effect==null)return false;
        double power=CaelumClassAbilityRules.BeneficialPower(user);
        effect.Revision=REVISION;
        effect.Multiplier=BASE_MULTIPLIER*power;
        effect.RemainingTics=Max(effect.RemainingTics,
            int(CaelumClassAbilityRules.EFFECT_SECONDS*power*TICRATE+0.5));
        CaelumNotifications.Notify(user,StringTable.Localize("CA_SURVIVAL_INSTINCT_CAST",false));
        return true;
    }
}
