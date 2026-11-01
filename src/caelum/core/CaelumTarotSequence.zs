// Una secuencia pagada conserva su orden incluso si El Diablo mata al dueño.
// Las consultas de objetivos y poderes se incorporan aquí sin volver a cobrar.
class CaelumTarotSequence : Object play
{
    static clearscope bool Temporal(int card)
    {
        return card>=CaelumConstants.TAROT_MAJOR_COUNT || card==1 || card==2 || card==3
            || card==4 || card==6 || card==8 || card==11 || card==12
            || card==14 || card==17 || card==18 || card==19;
    }

    static void ApplyCard(CaelumPlayer user,CaelumPersistentCharacterState record,int card,int duration,Actor aimed=null,bool report=true,CaelumTarotGroundAim ground=null)
    {
        if(!CaelumTarotService.Implemented(card))return;
        if(card==2 && !CaelumTarotMine.Place(user,ground,duration))
        {if(report)CaelumTarotService.Feedback(user,"CA_TAROT_MINE_GROUND");return;}
        if(card==3 && !CaelumTarotRoots.Place(user,aimed,duration,ground))
        {if(report)CaelumTarotService.Feedback(user,"CA_TAROT_ROOTS_TARGET");return;}
        if(card==8 && !CaelumTarotJustice.Start(user,aimed,duration))
        {if(report)CaelumTarotService.Feedback(user,"CA_JUSTICE_UNAVAILABLE");return;}
        if(card==CaelumHangedMan.CARD && !CaelumHangedMan.Prepare(user,record))return;
        if(card==14)CaelumTemperance.Cleanse(user);
        if(card==4)CaelumTarotEmperor.Pulse(user,duration,aimed);
        if(card==5)CaelumTarotContamination.Hierophant(user,ground);
        if(card==13 && !CaelumTarotContamination.Death(user,aimed,ground))
        {if(report)CaelumTarotService.Feedback(user,"CA_TAROT_CONTAMINATION_TARGET");return;}
        if(card==7)CaelumTarotChariot.Launch(user);
        if(card==10)CaelumTarotExamples.Wheel(user,report);
        if(card==16)
        {
            bool destroyed=CaelumMajorTargets.Tower(aimed);
            if(report)CaelumTarotService.Feedback(user,destroyed?"CA_TAROT_TOWER_DONE":"CA_TAROT_TOWER_TARGET");
        }
        // Los activos instantáneos no se repiten por recibir una duración mayor.
        if(Temporal(card))
        {
            record.TarotRemaining[card]=duration;
            record.TarotActive[card]=true;
            record.TarotEffectTics=Max(record.TarotEffectTics,duration);
        }
    }

    static void Apply(CaelumPlayer user,CaelumPersistentCharacterState record,Actor aimed=null,CaelumTarotGroundAim ground=null)
    {
        CaelumTarotLoadout.Ensure(record);
        bool selected[CaelumConstants.TAROT_CARD_COUNT];
        bool visited[CaelumConstants.TAROT_CARD_COUNT];
        int order[CaelumConstants.TAROT_CARD_COUNT];
        int count=record.TarotOrderCount;
        for(int i=0;i<count;i++)order[i]=record.TarotOrder[i];
        for(int i=0;i<CaelumConstants.TAROT_CARD_COUNT;i++)selected[i]=record.TarotSelected[i];
        bool hermit=selected[9] || (selected[21] && record.HasTarotCard(9));
        for(int index=0;index<count;index++)
        {
            int card=order[index];
            if(card<0 || card>=CaelumConstants.TAROT_CARD_COUNT || visited[card])continue;
            visited[card]=true;
            int duration=CaelumConstants.TAROT_EFFECT_SECONDS*TICRATE;
            if(index==0 && hermit)duration*=CaelumMajorArcanaData.HERMIT_DURATION;
            if(card==21)
            {
                for(int nested=0;nested<CaelumConstants.TAROT_CARD_COUNT;nested++)
                {
                    if(nested==21 || selected[nested] || visited[nested] || !record.HasTarotCard(nested))continue;
                    visited[nested]=true;
                    ApplyCard(user,record,nested,CaelumConstants.TAROT_EFFECT_SECONDS*TICRATE,aimed,false,ground);
                }
            }
            else ApplyCard(user,record,card,duration,aimed,true,ground);
        }
    }

    static void Pay(CaelumPlayer user,CaelumPersistentCharacterState record,bool devil)
    {
        if(devil)
        {
            user.health-=CaelumConstants.TAROT_ACTIVATION_ANIMA*CaelumMajorArcanaData.DEVIL_COST;
            user.player.health=user.health;
            if(user.health<=0)user.Die(user,user,0,'CaelumTarotSacrifice');
            else user.UpdateHealthStateEffects();
        }
        else user.CurrentAnima-=CaelumConstants.TAROT_ACTIVATION_ANIMA;
        record.TarotCooldownTics=CaelumConstants.TAROT_COOLDOWN_SECONDS*TICRATE;
    }

    static bool Advance(CaelumPlayer user,CaelumPersistentCharacterState record,int elapsed)
    {
        bool changed=false;record.TarotEffectTics=0;
        for(int card=0;card<CaelumConstants.TAROT_CARD_COUNT;card++)
        {
            if(record.TarotRemaining[card]<=0)continue;
            record.TarotRemaining[card]=Max(0,record.TarotRemaining[card]-elapsed);
            if(record.TarotRemaining[card]==0){record.TarotActive[card]=false;changed=true;}
            record.TarotEffectTics=Max(record.TarotEffectTics,record.TarotRemaining[card]);
        }
        if(changed && user.RacialAbility!=null && user.RacialAbility.TarotBorrowed)
            CaelumRacialAbilityRules.Guard(user);
        return changed;
    }
}
