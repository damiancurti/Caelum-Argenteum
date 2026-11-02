// #441: el poder procede de las 78 capturas; no existe un segundo inventario
// de esencias ni se consumen cartas. Comparte recarga, no efectos, con la secuencia.
class CaelumUnifiedTarot : Object play
{
    const REVISION=1;
    const WORLD_CARD=21;

    static void Ensure(CaelumPersistentCharacterState record)
    {
        if(record==null || record.UnifiedTarotRevision>=REVISION)return;
        if(!CaelumPlayerAuthority.OwnsRecord(CaelumPlayer(record.Owner),record))return;
        record.UnifiedTarotTics=0;
        record.UnifiedTarotRevision=REVISION;
    }

    static clearscope bool Owned(CaelumPersistentCharacterState record)
    {return record!=null && CaelumTarotService.CountTarotCards(record)==CaelumConstants.TAROT_CARD_COUNT;}

    static clearscope bool Active(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanRead(user) || user.ProfileDeparted
            || user.SessionIdentityPending || user.health<=0)return false;
        let record=CaelumPersistentCharacterState(user.FindInventory('CaelumPersistentCharacterState'));
        return record!=null && record.UnifiedTarotRevision>=REVISION && record.UnifiedTarotTics>0;
    }

    static bool Activate(CaelumPlayer user)
    {
        if(!CaelumTarotService.ValidUser(user) || CaelumBolas.Restrained(user))return false;
        let record=user.GetPersistentCharacterState(false);Ensure(record);
        if(!Owned(record))
        {CaelumTarotService.Feedback(user,"CA_TAROT_UNIFIED_REQUIRES");return false;}
        if(user.HasActiveConversation() || user.CraftingMenuOpen || user.PalomoMerchantMenuOpen
            || user.CraftingTaskActive || user.CombatChannelModeActive || user.StaffCastPending
            || user.ForcedSleepTics>0 || CaelumRestState.IsActive(user) || CaelumTimeSkipState.IsOpen(user)
            || (user.player.cheats & CF_TOTALLYFROZEN))
        {CaelumTarotService.Feedback(user,"CA_TAROT_POWER_CONTEXT");return false;}
        if(record.TarotCooldownTics>0 || record.TarotEffectTics>0 || record.UnifiedTarotTics>0)
        {CaelumTarotService.Feedback(user,"CA_TAROT_POWER_COOLDOWN");return false;}
        if(user.CurrentAnima<CaelumConstants.TAROT_ACTIVATION_ANIMA)
        {CaelumTarotService.Feedback(user,"CA_TAROT_POWER_ANIMA");return false;}
        user.CurrentAnima-=CaelumConstants.TAROT_ACTIVATION_ANIMA;
        record.UnifiedTarotTics=CaelumConstants.TAROT_EFFECT_SECONDS*TICRATE;
        record.TarotCooldownTics=CaelumConstants.TAROT_COOLDOWN_SECONDS*TICRATE;
        user.PersistCharacterState();
        CaelumTarotService.Feedback(user,"CA_TAROT_UNIFIED_ACTIVE");
        return true;
    }

    static void Advance(CaelumPlayer user,CaelumPersistentCharacterState record,int tics)
    {
        Ensure(record);
        if(record==null || record.UnifiedTarotTics<=0)return;
        record.UnifiedTarotTics=user.health>0?Max(0,record.UnifiedTarotTics-tics):0;
        if(record.UnifiedTarotTics==0)CaelumTarotService.Feedback(user,"CA_TAROT_POWER_EXPIRED");
    }
}
