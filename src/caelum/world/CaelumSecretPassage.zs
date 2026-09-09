// Cara posterior puramente visual de una pared falsa. No crea bloqueadores:
// ambos lados se ven como la mansión, pero el jugador puede atravesarlos.
class CaelumWalkThroughWallBackPanel : Actor
{
    override void Tick()
    {
        Super.Tick();
        if (master == null)
        {
            Destroy();
            return;
        }
        Vector3 backPos = master.Pos;
        Vector2 backOffset = AngleToVector(master.Angle + 90.0, 0.25);
        backPos.X += backOffset.X;
        backPos.Y += backOffset.Y;
        SetOrigin(backPos, true);
        Angle = master.Angle + 180.0;
        Scale.X = master.Scale.X;
        Scale.Y = master.Scale.Y;
    }

    Default
    {
        Radius 1;
        Height 120;
        +NOBLOCKMAP
        +NOGRAVITY
        +CANNOTPUSH
        +DONTTHRUST
        +WALLSPRITE
        RenderStyle "Normal";
    }

    States
    {
    Spawn:
        CWAL A -1;
        Stop;
    }
}

class CaelumWalkThroughWallPanel : Actor
{
    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        int panelWidth = args[0] > 0 ? args[0] : 64;
        int panelHeight = args[1] > 0 ? args[1] : 120;
        Scale.X = panelWidth / 128.0;
        Scale.Y = panelHeight / 128.0;

        Vector3 backPos = Pos;
        Vector2 backOffset = AngleToVector(Angle + 90.0, 0.25);
        backPos.X += backOffset.X;
        backPos.Y += backOffset.Y;
        Actor backPanel = Spawn("CaelumWalkThroughWallBackPanel", backPos);
        if (backPanel != null)
        {
            backPanel.master = self;
            backPanel.Angle = Angle + 180.0;
            backPanel.Scale.X = Scale.X;
            backPanel.Scale.Y = Scale.Y;
        }
    }

    Default
    {
        Radius 1;
        Height 120;
        +NOBLOCKMAP
        +NOGRAVITY
        +CANNOTPUSH
        +DONTTHRUST
        +WALLSPRITE
        RenderStyle "Normal";
    }

    States
    {
    Spawn:
        CWAL A -1;
        Stop;
    }
}

// Plataforma automática del pasadizo. La planta de MAP01 usa pisos apilados;
// por eso el transporte vertical se resuelve de forma autoritativa entre la
// cabina superior y la cueva inferior, sin reiniciar al personaje ni el mapa.
class CaelumSecretElevator : Actor
{
    bool PlayerWasInside[MAXPLAYERS];

    bool IsPlayerInside(Actor traveler)
    {
        if (traveler == null || traveler.health <= 0) { return false; }
        double halfWidth = Max(8.0, double(args[1])) * 0.5;
        double halfDepth = Max(8.0, double(args[2])) * 0.5;
        return Abs(traveler.Pos.X - Pos.X) <= halfWidth
            && Abs(traveler.Pos.Y - Pos.Y) <= halfDepth
            && Abs(traveler.Pos.Z - Pos.Z) <= 24.0;
    }

    void TransportPlayer(Actor traveler)
    {
        Vector3 destination;
        if (args[0] == 0)
        {
            // Sale de la cabina inferior mirando hacia el interior de la cueva.
            destination = (
                CaelumConstants.M01_SECRET_CAVE_X - 300.0,
                CaelumConstants.M01_SECRET_CAVE_Y,
                CaelumConstants.M01_SECRET_CAVE_FLOOR_Z
            );
            traveler.Angle = 0.0;
        }
        else
        {
            // Regresa fuera del volumen superior para impedir un rebote.
            destination = (1860.0, 316.0, 0.0);
            traveler.Angle = 270.0;
        }

        A_StartSound("caelum/world/door_large_open", CHAN_BODY);
        traveler.SetOrigin(destination, false);
        traveler.Vel.X = 0.0;
        traveler.Vel.Y = 0.0;
        traveler.Vel.Z = 0.0;
    }

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        int platformWidth = args[1] > 0
            ? args[1] : CaelumConstants.M01_SECRET_ELEVATOR_WIDTH;
        int platformDepth = args[2] > 0
            ? args[2] : CaelumConstants.M01_SECRET_ELEVATOR_DEPTH;
        Scale.X = platformWidth / 128.0;
        Scale.Y = platformDepth / 128.0;
    }

    override void Tick()
    {
        Super.Tick();
        for (int playerIndex = 0; playerIndex < MAXPLAYERS; playerIndex++)
        {
            if (!playeringame[playerIndex])
            {
                PlayerWasInside[playerIndex] = false;
                continue;
            }
            Actor traveler = players[playerIndex].mo;
            bool inside = IsPlayerInside(traveler);
            if (inside && !PlayerWasInside[playerIndex])
            {
                PlayerWasInside[playerIndex] = true;
                TransportPlayer(traveler);
            }
            else
            {
                PlayerWasInside[playerIndex] = inside;
            }
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
        +FLATSPRITE
        RenderStyle "Normal";
    }

    States
    {
    Spawn:
        CSUF A -1;
        Stop;
    }
}

// La hachuela ya tala con Fire y golpea de forma roma con AltFire. Estas
// cuatro vetas tutoriales aceptan ese segundo uso sin cambiar la regla global:
// las vetas del resto del mundo continúan exigiendo daño perforante.
class CaelumM01VeinIron : CaelumVeinIron2
{
    override int GetRequiredHarvestDamageType()
    {
        return CaelumConstants.CATALOGUE_DAMAGE_BLUNT;
    }
}

class CaelumM01VeinCoal : CaelumVeinCoal2
{
    override int GetRequiredHarvestDamageType()
    {
        return CaelumConstants.CATALOGUE_DAMAGE_BLUNT;
    }
}

class CaelumM01VeinCopper : CaelumVeinCopper2
{
    override int GetRequiredHarvestDamageType()
    {
        return CaelumConstants.CATALOGUE_DAMAGE_BLUNT;
    }
}

class CaelumM01VeinTin : CaelumVeinTin2
{
    override int GetRequiredHarvestDamageType()
    {
        return CaelumConstants.CATALOGUE_DAMAGE_BLUNT;
    }
}

// Es una sola hachuela física, pero adopta al recogerla el talle por defecto
// del personaje. Así la herramienta tutorial no bloquea a tamaños XS o XL.
class CaelumM01HatchetPickup : CaelumWeaponPickup
{
    override bool TryPickup(in out Actor toucher)
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(toucher);
        if (caelumPlayer != null && caelumPlayer.CharacterProfile != null)
        {
            args[0] = CaelumConstants.WEAPON_TYPE_HATCHET;
            args[1] = 1;
            args[2] = CaelumEquipmentRules.GetDefaultSizeForCharacterTier(
                caelumPlayer.CharacterProfile.GetSizeTier()
            ) + 1;
            args[3] = 0;
            args[4] = 0;
        }
        return Super.TryPickup(toucher);
    }
}
