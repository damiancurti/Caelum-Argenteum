// Issue #18: recursos visuales de asedio. La galería no implementa combate.
// Las mallas y los cuadros se generan con generate_siege_models.py.

class CaelumSiegeCannon : Actor
{
    Default
    {
        Radius 48;
        Height 56;
        +NOGRAVITY
        +NOBLOCKMAP
        +DONTSPLASH
        +NOBLOOD
        +INVULNERABLE
    }

    States
    {
    Spawn:
    Ready:
        CSGN A -1;
        Loop;
    Loading:
        CSGN B -1;
        Loop;
    Firing:
        CSGN C -1;
        Loop;
    Recovery:
        CSGN D -1;
        Loop;
    }
}

class CaelumSiegeRam : Actor
{
    Default
    {
        Radius 48;
        Height 48;
        +NOGRAVITY
        +NOBLOCKMAP
        +DONTSPLASH
        +NOBLOOD
        +INVULNERABLE
    }

    States
    {
    Spawn:
    Ready:
        CRAM A -1;
        Loop;
    Strike:
        CRAM B -1;
        Loop;
    Recovery:
        CRAM C -1;
        Loop;
    }
}

class CaelumSiegeGate : Actor
{
    Default
    {
        Radius 56;
        Height 104;
        +NOGRAVITY
        +NOBLOCKMAP
        +DONTSPLASH
        +NOBLOOD
        +INVULNERABLE
    }

    States
    {
    Spawn:
    Intact:
        CAGT A -1;
        Loop;
    Damaged:
        CAGT B -1;
        Loop;
    Broken:
        CAGT C -1;
        Loop;
    }
}

class CaelumSiegeGateReinforced : CaelumSiegeGate
{
    States
    {
    Spawn:
    Intact:
        CAGR A -1;
        Loop;
    Damaged:
        CAGR B -1;
        Loop;
    Broken:
        CAGR C -1;
        Loop;
    }
}

class CaelumSiegeGateArmored : CaelumSiegeGate
{
    States
    {
    Spawn:
    Intact:
        CAGA A -1;
        Loop;
    Damaged:
        CAGA B -1;
        Loop;
    Broken:
        CAGA C -1;
        Loop;
    }
}

// Galería de MAP03: retira los muebles de prueba y muestra todos los estados.
// Los tres materiales ocupan columnas; intacto, dañado y abierto, filas.
class CaelumSiegePreviewWorld : Object play
{
    static void RemoveTrialFurniture()
    {
        let furniture = ThinkerIterator.Create("Actor");
        Actor actor;
        while ((actor = Actor(furniture.Next())) != null)
        {
            let table = CaelumDiningTable(actor);
            if (table != null)
            {
                table.Destroy();
                continue;
            }
            let chair = CaelumRestChair(actor);
            if (chair != null)
            {
                chair.Destroy();
                continue;
            }
            let bed = CaelumRestBed(actor);
            if (bed != null)
                bed.Destroy();
        }
    }

    static Actor SpawnState(class<Actor> kind, vector3 position, StateLabel label)
    {
        let actor = Actor.Spawn(kind, position, NO_REPLACE);
        if (actor == null) return null;
        actor.Angle = 0;
        actor.SetStateLabel(label);
        return actor;
    }

    static bool Prepare()
    {
        if (level.MapName != "MAP03") return true;
        RemoveTrialFurniture();

        SpawnState("CaelumSiegeCannon", (-1500, 1500, 0), "Ready");
        SpawnState("CaelumSiegeCannon", (-900, 1500, 0), "Loading");
        SpawnState("CaelumSiegeCannon", (-300, 1500, 0), "Firing");
        SpawnState("CaelumSiegeCannon", (300, 1500, 0), "Recovery");

        SpawnState("CaelumSiegeRam", (-900, 2200, 0), "Ready");
        SpawnState("CaelumSiegeRam", (0, 2200, 0), "Strike");
        SpawnState("CaelumSiegeRam", (900, 2200, 0), "Recovery");

        // BEGIN GENERATED SIEGE GATE GALLERY
        SpawnState("CaelumSiegeGate", (-1200, 2600, 0), "Intact");
        SpawnState("CaelumSiegeGate", (-1200, 2900, 0), "Damaged");
        SpawnState("CaelumSiegeGate", (-1200, 3200, 0), "Broken");
        SpawnState("CaelumSiegeGateReinforced", (0, 2600, 0), "Intact");
        SpawnState("CaelumSiegeGateReinforced", (0, 2900, 0), "Damaged");
        SpawnState("CaelumSiegeGateReinforced", (0, 3200, 0), "Broken");
        SpawnState("CaelumSiegeGateArmored", (1200, 2600, 0), "Intact");
        SpawnState("CaelumSiegeGateArmored", (1200, 2900, 0), "Damaged");
        SpawnState("CaelumSiegeGateArmored", (1200, 3200, 0), "Broken");
        // END GENERATED SIEGE GATE GALLERY
        return true;
    }
}
