// La resistencia se decide al aplicar el estado, sin buscar actores por tic.
class CaelumTemperance : Object play
{
    static double Duration(Actor receiver,double seconds)
    {
        let user=CaelumPlayer(receiver);
        let record=user!=null ? user.GetPersistentCharacterState(false) : null;
        if(CaelumTarotService.IsActive(record,14))return 0;
        return Max(0.0,seconds)*(CaelumTarotLoadout.Passive(record,14)
            ? CaelumMajorArcanaData.TEMPERANCE_DURATION : 1.0);
    }

    static void Cleanse(CaelumPlayer user)
    {
        if(user==null)return;
        if(user.ElementalStatus!=null)user.ElementalStatus.ClearTemporaryStates(user);
        if(user.ForcedSleepTics>0)CaelumSleepRules.Wake(user);
        if(user.TarotEmperor!=null)user.TarotEmperor.Cleanse();
    }

    static bool SelectedForSequence(CaelumPersistentCharacterState record)
    {
        return CaelumTarotLoadout.Passive(record,14)
            || (CaelumTarotLoadout.Passive(record,21) && record.HasTarotCard(14));
    }
}
