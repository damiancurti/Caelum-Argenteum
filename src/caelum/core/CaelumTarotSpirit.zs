// Marcador explícito: Justicia/Juicio no convierten NPC ordinarios en espíritus.
class CaelumTarotSpirit : CaelumInteractiveFolkloreActor abstract
{
    static bool CanHarm(Actor source)
    {
        let user=CaelumPlayer(source);
        return user!=null && CaelumTarotLoadout.Passive(user.GetPersistentCharacterState(false),8);
    }
    static bool CanHear(CaelumPlayer user)
    {
        return user!=null && CaelumSpirit.CanConverse(user)
            && CaelumTarotLoadout.Passive(user.GetPersistentCharacterState(false),20);
    }
    override int DamageMobj(Actor inflictor,Actor source,int damage,Name mod,int flags,double angle)
    {
        if(!CanHarm(source))return 0;
        return Super.DamageMobj(inflictor,source,damage,mod,flags,angle);
    }
}

class CaelumTarotExampleSpirit : CaelumTarotSpirit
{
    int Revision;
    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        if(Revision>=1)return;
        Revision=1;Mass=CaelumPortData.DEFENDER_MASS_KG;
        A_SetSize(GetDefaultByType("CaelumPlayer").Radius,CaelumPortData.DEFENDER_HEIGHT);
        InitializeUniformFolkloreProfile(CaelumPortData.DEFENDER_ATTRIBUTE);
        double ratio=Height/CaelumAppearanceRegistry.StandingHeight(0,true);
        Scale=(ratio,ratio);
    }
    override bool InteractWithCaelumPlayer(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || health<=0 || user.player==null
            || Distance3D(user)>user.UseRange+Radius || !user.CheckSight(self))return false;
        if(!CanHear(user))
        {CaelumTarotService.Feedback(user,"CA_TAROT_SPIRIT_REQUIRES");return true;}
        Level.ExecuteSpecial(CaelumConstants.GZDOOM_THING_SET_CONVERSATION_SPECIAL,
            self,null,false,0,CaelumMajorArcanaData.SPIRIT_CONVERSATION);
        return HasConversation() && StartConversation(user,true,true);
    }
    override void Tick()
    {
        Super.Tick();
        // Retirar el nodo cerrado obliga a comprobar de nuevo la carta de quien usa.
        if(!bInConversation && HasConversation())
            Level.ExecuteSpecial(CaelumConstants.GZDOOM_THING_SET_CONVERSATION_SPECIAL,self,null,false,0,0);
    }
    Default {Tag "$CA_TAROT_EXAMPLE_SPIRIT";Health 1;Radius 16;Height 56;Mass 80;PainChance 0;+ISMONSTER +FRIENDLY +SOLID +SHOOTABLE -COUNTKILL}
    States
    {
        Spawn:See:V9G0 A -1;Stop;
        Pain:V9G0 F 4;Goto See;
        Death:V9G0 G 5;V9G0 H 5 A_NoBlocking;V9G0 I -1;Stop;
    }
}
