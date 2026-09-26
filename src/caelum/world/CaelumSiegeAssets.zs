// Issue #18: reusable cannon, battering ram and destructible gate assets.
// Visual preview only. The meshes and their state frames come from the
// deterministic generator assets/generators/generate_siege_models.py; this
// file does not invent mass, damage, reload time or gate hardness.

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
        Radius 96;
        Height 224;
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

// Test gallery for MAP03. It retires the trial chairs, dining tables and cots
// that previously occupied the tank, then shows every siege state in the open
// reservoir so the author can check appearance and clearances in one pass.
class CaelumSiegePreviewWorld : Object play
{
    static void RemoveTrialFurniture()
    {
        let tables = ThinkerIterator.Create("CaelumDiningTable");
        CaelumDiningTable table;
        while ((table = CaelumDiningTable(tables.Next())) != null)
            table.Destroy();

        let chairs = ThinkerIterator.Create("CaelumRestChair");
        CaelumRestChair chair;
        while ((chair = CaelumRestChair(chairs.Next())) != null)
            chair.Destroy();

        let beds = ThinkerIterator.Create("CaelumRestBed");
        CaelumRestBed bed;
        while ((bed = CaelumRestBed(beds.Next())) != null)
            bed.Destroy();
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

        SpawnState("CaelumSiegeGate", (-900, 3000, 0), "Intact");
        SpawnState("CaelumSiegeGate", (0, 3000, 0), "Damaged");
        SpawnState("CaelumSiegeGate", (900, 3000, 0), "Broken");
        return true;
    }
}
