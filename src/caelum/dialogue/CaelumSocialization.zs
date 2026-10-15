// #240: el efecto temporal no modifica los atributos ni los resultados guardados.
class CaelumSocializationEffect : CaelumRacialAbilityEffect
{
    override double BaseAnimaPerSecond(CaelumPlayer user)
    {return CaelumSocialization.ANIMA_PER_SECOND;}
}

class CaelumSocialPage : Object
{
    int Node,Offset;
    double Multiplier;
}

class CaelumSocialSession : Object
{
    int Revision,Current;
    Actor Speaker;
    Array<CaelumSocialPage> Pages;
}

class CaelumSocialization : Object play
{
    const REVISION=1;
    const ANIMA_PER_SECOND=10.0;
    const MULTIPLIER=2.0;

    static clearscope bool Active(CaelumPlayer user)
    {return user!=null && user.RacialAbilityActive && user.RacialAbility is "CaelumSocializationEffect";}

    static clearscope bool InConversation(CaelumPlayer user)
    {
        return user!=null && user.player!=null && user.player.ConversationPC==user
            && user.player.ConversationNPC!=null && user.player.ConversationNPC.bInConversation;
    }

    static clearscope bool ValidSession(CaelumPlayer user)
    {
        let session=user==null?null:user.SocialSession;
        return InConversation(user) && session!=null && session.Revision==REVISION
            && session.Speaker==user.player.ConversationNPC;
    }

    static clearscope bool Ready(CaelumPlayer user,int node,int offset)
    {
        if(!ValidSession(user))return false;
        let session=user.SocialSession;
        return session.Current>=0 && session.Current<int(session.Pages.Size())
            && session.Pages[session.Current].Node==node && session.Pages[session.Current].Offset==offset;
    }

    static clearscope double CurrentMultiplier(CaelumPlayer user)
    {
        if(ValidSession(user))
        {
            let session=user.SocialSession;
            if(session.Current>=0 && session.Current<int(session.Pages.Size()))
                return session.Pages[session.Current].Multiplier;
        }
        return Active(user)?MULTIPLIER:1.0;
    }

    static clearscope double Dialogue(CaelumPlayer user)
    {
        double value=user==null?0:user.DerivedStats!=null?user.DerivedStats.DialogueSkillPercent
            :user.Attributes!=null?CaelumGrowthRules.Bonus(user.Attributes.Eloquence):0;
        return value*CurrentMultiplier(user);
    }

    static clearscope double Persuasion(CaelumPlayer user,double currentValue)
    {return currentValue*CurrentMultiplier(user);}

    static void Clear(CaelumPlayer user){user.SocialSession=null;}

    static void Update(CaelumPlayer user)
    {if(!InConversation(user))Clear(user);}

    static void Capture(CaelumPlayer user,int node,int offset)
    {
        if(!InConversation(user) || node<0 || offset<0)return;
        if(!ValidSession(user))
        {
            user.SocialSession=new("CaelumSocialSession");
            user.SocialSession.Revision=REVISION;
            user.SocialSession.Speaker=user.player.ConversationNPC;
        }
        let session=user.SocialSession;
        for(int i=0;i<int(session.Pages.Size());i++)
        {
            if(session.Pages[i].Node==node && session.Pages[i].Offset==offset)
            {session.Current=i;Refresh(user);return;}
        }
        let page=new("CaelumSocialPage");page.Node=node;page.Offset=offset;
        // Se obtiene en play antes de mostrar/responder, nunca de un valor del cliente.
        page.Multiplier=Active(user)?MULTIPLIER:1.0;
        session.Current=session.Pages.Size();session.Pages.Push(page);Refresh(user);
    }

    static void Refresh(CaelumPlayer user)
    {CaelumMainM00SocialDialogue.Sync(user);user.RefreshPalomoDiscountOdds();}

    static void StopInConversation(CaelumPlayer user)
    {
        if(!InConversation(user) || !Active(user))return;
        CaelumRacialAbilityRules.Deactivate(user);
        user.RacialAbilityInputLatched=true;
    }
}
