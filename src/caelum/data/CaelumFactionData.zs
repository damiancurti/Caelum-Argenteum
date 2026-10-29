// #420: calibración aprobada; ninguna identidad se deduce de raza o vestuario.
class CaelumFactionData : Object
{
    const RANK_COUNT = 7;
    const HOSTILITY_MAXIMUM = -250;
    const DISCLOSURE_PENALTY = 100;

    static clearscope int ConfirmedPrisonerFaction(int prisoner)
    {
        switch (prisoner)
        {
            case CaelumConstants.PRISONER_UNITARIO: return CaelumConstants.FACTION_UNITARIOS;
            case CaelumConstants.PRISONER_FEDERAL: return CaelumConstants.FACTION_FEDERALS;
            case CaelumConstants.PRISONER_BESTIA: return CaelumConstants.FACTION_PUEBLOS_LIBRES;
        }
        // Leandro conserva su recompensa anterior, pero no confirma pertenencia.
        return -1;
    }

    static clearscope int Rank(int reputation)
    {
        if (reputation < -499) return 0;
        if (reputation < -249) return 1;
        if (reputation < -49) return 2;
        if (reputation < 50) return 3;
        if (reputation < 250) return 4;
        if (reputation < 500) return 5;
        return 6;
    }

    static clearscope String RankKey(int reputation)
    { return String.Format("CA_FACTION_RANK_%d", Rank(reputation)); }

    static clearscope double PurchaseFactor(int reputation)
    {
        switch (Rank(reputation))
        {
            case 2: return 1.50;
            case 3: return 1;
            case 4: return 0.85;
            case 5: return 0.75;
            case 6: return 0.66;
        }
        return 0; // Sin acceso comercial; no representa un regalo.
    }

    static clearscope double SaleFactor(int reputation)
    {
        switch (Rank(reputation))
        {
            case 2: return 0.80;
            case 3: return 1;
            case 4: return 1.05;
            case 5: return 1.10;
            case 6: return 1.15;
        }
        return 0;
    }

    static clearscope bool EnemyPair(int first, int second)
    {
        return (first == CaelumConstants.FACTION_UNITARIOS && second == CaelumConstants.FACTION_FEDERALS)
            || (second == CaelumConstants.FACTION_UNITARIOS && first == CaelumConstants.FACTION_FEDERALS)
            || (first == CaelumConstants.FACTION_CULT_TAROT && second == CaelumConstants.FACTION_SUN_WARRIORS)
            || (second == CaelumConstants.FACTION_CULT_TAROT && first == CaelumConstants.FACTION_SUN_WARRIORS);
    }
}
