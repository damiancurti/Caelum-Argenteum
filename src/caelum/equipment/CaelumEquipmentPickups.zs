// Objetos de mundo configurables desde UDMF o desde los controles de prueba.
// Armadura: args 0=ranura, 1=tipo, 2=tier, 3=talle (1..5), 4=durabilidad+1.
// Escudo: args 0=tipo, 1=tier, 2=talle (1..5), 3=durabilidad+1.
// Talle cero conserva M y durabilidad cero crea el objeto al máximo.
class CaelumArmorPickup : Inventory
{
    Default
    {
        Radius 12;
        Height 8;
        Inventory.Amount 1;
        Inventory.MaxAmount 1;
        Inventory.PickupSound "misc/i_pkup";
        +INVENTORY.ALWAYSPICKUP
    }

    States
    {
    Spawn:
        ARM1 A -1;
        Stop;
    }

    override bool TryPickup(in out Actor toucher)
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(toucher);
        if (caelumPlayer == null) { return false; }
        int equipmentSize = args[3] <= 0
            ? CaelumConstants.EQUIPMENT_SIZE_M : args[3] - 1;
        if (!caelumPlayer.AcquireArmorPickup(
            args[0], args[1], args[2], equipmentSize, args[4]
        ))
        {
            return false;
        }
        toucher.A_StartSound(PickupSound, CHAN_ITEM);
        GoAwayAndDie();
        return true;
    }
}

class CaelumShieldPickup : Inventory
{
    Default
    {
        Radius 12;
        Height 8;
        Inventory.Amount 1;
        Inventory.MaxAmount 1;
        Inventory.PickupSound "misc/i_pkup";
        +INVENTORY.ALWAYSPICKUP
    }

    States
    {
    Spawn:
        BON2 A -1;
        Stop;
    }

    override bool TryPickup(in out Actor toucher)
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(toucher);
        if (caelumPlayer == null) { return false; }
        int equipmentSize = args[2] <= 0
            ? CaelumConstants.EQUIPMENT_SIZE_M : args[2] - 1;
        if (!caelumPlayer.AcquireShieldPickup(
            args[0], args[1], equipmentSize, args[3]
        ))
        {
            return false;
        }
        toucher.A_StartSound(PickupSound, CHAN_ITEM);
        GoAwayAndDie();
        return true;
    }
}

// Arma: args 0=tipo, 1=tier, 2=talle (1..5), 3=durabilidad+1.
class CaelumWeaponPickup : Inventory
{
    Default
    {
        Radius 12;
        Height 8;
        Inventory.Amount 1;
        Inventory.MaxAmount 1;
        Inventory.PickupSound "misc/w_pkup";
        +INVENTORY.ALWAYSPICKUP
    }

    States
    {
    Spawn:
        WPN2 A -1;
        Stop;
    }

    override bool TryPickup(in out Actor toucher)
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(toucher);
        if (caelumPlayer == null) { return false; }
        int equipmentSize = args[2] <= 0
            ? CaelumConstants.EQUIPMENT_SIZE_M : args[2] - 1;
        if (!caelumPlayer.AcquireWeaponPickup(
            args[0], args[1], equipmentSize, args[3]
        ))
        {
            return false;
        }
        toucher.A_StartSound(PickupSound, CHAN_ITEM);
        GoAwayAndDie();
        return true;
    }
}
