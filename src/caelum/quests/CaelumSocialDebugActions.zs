// Acciones aisladas para validar la persistencia social sin adjudicar
// consecuencias narrativas a ningún diálogo o actor del mundo. No poseen
// DoomEdNum, no aparecen en mapas y MaxAmount 0 impide que queden guardadas.
class CaelumSocialDebugAction : Inventory abstract
{
    Default
    {
        Inventory.MaxAmount 0;
        +INVENTORY.AUTOACTIVATE
        -INVENTORY.INVBAR
    }

    States
    {
    Spawn:
        TNT1 A -1;
        Stop;
    }
}

class CaelumDebugJoinGendarmeria : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(Owner);
        if (caelumPlayer == null) { return false; }
        caelumPlayer.SetPlayerFactionMembership(
            CaelumConstants.FACTION_GENDARMERIA, true
        );
        return true;
    }
}

class CaelumDebugLeaveGendarmeria : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(Owner);
        if (caelumPlayer == null) { return false; }
        caelumPlayer.SetPlayerFactionMembership(
            CaelumConstants.FACTION_GENDARMERIA, false
        );
        return true;
    }
}

class CaelumDebugGendarmeriaReputationPlus25 : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(Owner);
        if (caelumPlayer == null) { return false; }
        caelumPlayer.ChangePlayerFactionReputation(
            CaelumConstants.FACTION_GENDARMERIA, 25
        );
        return true;
    }
}

class CaelumDebugGendarmeriaReputationMinus50 : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(Owner);
        if (caelumPlayer == null) { return false; }
        caelumPlayer.ChangePlayerFactionReputation(
            CaelumConstants.FACTION_GENDARMERIA, -50
        );
        return true;
    }
}

class CaelumDebugResetFactions : CaelumSocialDebugAction
{
    override bool Use(bool pickup)
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(Owner);
        if (caelumPlayer == null) { return false; }
        caelumPlayer.ResetPlayerFactionStateForDebug();
        return true;
    }
}
