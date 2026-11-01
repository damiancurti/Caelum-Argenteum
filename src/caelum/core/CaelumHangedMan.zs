// La elección es personal; el efecto prestado usa el mismo ciclo racial nativo.
class CaelumHangedMan : Object play
{
    const REVISION=1;
    const CARD=12;

    static void Ensure(CaelumPersistentCharacterState record)
    {
        if(record==null || record.TarotRaceRevision>=REVISION)return;
        record.TarotRaceRevision=REVISION;
        record.TarotHangedRace=record.TarotHangedActiveRace=-1;
        record.TarotRaceMenuOpen=false;
    }

    static clearscope bool ValidRace(CaelumPlayer user,int race)
    {
        return user!=null && user.CharacterProfile!=null
            && race>=CaelumConstants.RACE_BEAST_MAN && race<=CaelumConstants.RACE_GOBLIN
            && race!=user.CharacterProfile.Race;
    }
    static clearscope bool Chosen(CaelumPlayer user,CaelumPersistentCharacterState record)
    {return record!=null && record.TarotRaceRevision>=REVISION && ValidRace(user,record.TarotHangedRace);}

    static clearscope String RaceKey(int race)
    {
        if(race==CaelumConstants.RACE_BEAST_MAN)return "CA_RACE_BEAST_MAN";
        if(race==CaelumConstants.RACE_CAELITH)return "CA_RACE_CAELITH";
        if(race==CaelumConstants.RACE_HUMAN)return "CA_RACE_HUMAN";
        return "CA_RACE_GOBLIN";
    }

    static bool Choose(CaelumPlayer user,int race)
    {
        if(!CaelumPlayerAuthority.CanMutate(user))return false;
        let record=CaelumPersistentCharacterState(user.FindInventory('CaelumPersistentCharacterState'));
        if(record==null || !record.TarotRaceMenuOpen)return false;
        if(race<0){record.TarotRaceMenuOpen=false;return true;}
        record.TarotRaceMenuOpen=false;
        if((!CaelumTarotService.ValidUser(user) && !CaelumFoolTravel.CanEditDeadLoadout(user))
            || record.TarotSelected[CARD] || !ValidRace(user,race))return false;
        return CaelumTarotService.Select(user,CARD,race);
    }

    static clearscope bool Allows(CaelumPlayer user,int race)
    {
        let record=user!=null?CaelumPersistentCharacterState(user.FindInventory('CaelumPersistentCharacterState')):null;
        return record!=null && record.TarotRaceRevision>=REVISION
            && CaelumTarotService.IsActive(record,CARD)
            && record.TarotHangedActiveRace==race && ValidRace(user,race);
    }

    static bool Prepare(CaelumPlayer user,CaelumPersistentCharacterState record)
    {
        Ensure(record);
        if(!Chosen(user,record))return false;
        // Repetir la secuencia no cambia a mitad del ciclo una habilidad pagada.
        if(user.RacialAbility!=null && user.RacialAbility.TarotBorrowed
            && user.RacialAbility.Race!=record.TarotHangedRace)
            CaelumRacialAbilityRules.Deactivate(user);
        record.TarotHangedActiveRace=record.TarotHangedRace;
        return true;
    }

    static bool Input(CaelumPlayer user)
    {
        let record=user!=null?CaelumPersistentCharacterState(user.FindInventory('CaelumPersistentCharacterState')):null;
        if(record==null || !CaelumTarotService.IsActive(record,CARD))return false;
        if(!CaelumTarotService.ValidUser(user) || CaelumRacialAbilityRules.Interrupted(user)
            || CaelumRacialAbilityRules.MenuBlocked(user) || user.CraftingTaskActive || user.StaffCastPending)
        {CaelumTarotService.Feedback(user,"CA_TAROT_POWER_CONTEXT");return true;}
        if(user.RacialAbility!=null && user.RacialAbility.TarotBorrowed)
        {CaelumRacialAbilityRules.Deactivate(user);return true;}
        if(!Allows(user,record.TarotHangedActiveRace))return true;
        // Sólo una habilidad racial a la vez: la propia conserva su tecla.
        if(user.RacialAbility!=null)CaelumRacialAbilityRules.Deactivate(user);
        CaelumRacialAbilityRules.Begin(user,record.TarotHangedActiveRace,true);
        return true;
    }
}

// Las acciones dirigidas se resuelven antes de la alternancia racial.
class CaelumTarotFollowup : Object play
{
    static bool Input(CaelumPlayer user)
    {return CaelumTarotMoon.Input(user) || CaelumHangedMan.Input(user);}
}
