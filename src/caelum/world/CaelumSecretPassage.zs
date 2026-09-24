// El transporte pertenece al piso móvil nativo de MAP01. Este actor sólo
// inicia el descenso cuando el personaje está completamente sobre la cabina.
// Plat_DownWaitUpStayLip mueve el suelo, transporta cuerpos, espera y regresa;
// nunca se modifica la posición del personaje ni se cambia de mapa.
class CaelumSecretElevator : Actor
{
    bool PlayerWasInside[MAXPLAYERS];

    override void Tick()
    {
        Super.Tick();
        if (CurSector == null) { return; }
        double platformZ = CurSector.floorplane.ZatPoint(Pos.XY);
        for (int i = 0; i < MAXPLAYERS; i++)
        {
            Actor traveler = playeringame[i] ? players[i].mo : null;
            bool inside = traveler != null && traveler.health > 0
                && Abs(traveler.Pos.X - Pos.X) + traveler.Radius
                    <= CaelumConstants.M01_SECRET_ELEVATOR_WIDTH * 0.5
                && Abs(traveler.Pos.Y - Pos.Y) + traveler.Radius
                    <= CaelumConstants.M01_SECRET_ELEVATOR_DEPTH * 0.5;
            if (inside && !PlayerWasInside[i]
                && Abs(platformZ) < 0.1
                && Abs(traveler.Pos.Z - platformZ) < 1.0)
            {
                Plat_DownWaitUpStayLip(
                    CaelumConstants.M01_SECRET_ELEVATOR_TAG,
                    CaelumConstants.M01_SECRET_ELEVATOR_SPEED,
                    CaelumConstants.M01_SECRET_ELEVATOR_WAIT, 0
                );
            }
            PlayerWasInside[i] = inside;
        }
    }

    Default
    {
        Radius 1;
        Height 1;
        +NOBLOCKMAP
        +NOGRAVITY
        +CANNOTPUSH
        +DONTTHRUST
        RenderStyle "None";
    }
    States
    {
    Spawn:
        TNT1 A -1;
        Stop;
    }
}

// Una espada T1 normal, con cortante en Fire y punzante en AltFire. Sólo
// resuelve el talle al recogerla para que el tutorial admita personajes XS–XL.
class CaelumM01SwordPickup : CaelumWeaponPickup
{
    override bool TryPickup(in out Actor toucher)
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(toucher);
        if (caelumPlayer != null && !HasAcquiredIdentity())
        {
            args[0] = CaelumConstants.WEAPON_TYPE_SWORD;
            args[1] = 1;
            SizePolicy = CaelumEquipmentRules.CHARACTER_DEFAULT;
            args[3] = 0;
            args[4] = 0;
        }
        return Super.TryPickup(toucher);
    }
}
