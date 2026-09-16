// La bolsa sigue siendo el mismo Inventory mientras su modelo se despliega.
// Recogerla al levantarse retira sólo ese modelo: nunca entrega otra copia.
class CaelumSleepingBag : CaelumSpecialInventoryItem
{
    override int GetSpecialCategory() { return CaelumConstants.EQUIPMENT_KIND_KEY_ITEM; }
    override int GetSpecialType() { return CaelumConstants.KEY_ITEM_SLEEPING_BAG; }
    // Peso de dos kilogramos confirmado por el autor.
    override double GetUnitWeight() { return 2.0; }

    bool AvailableTo(CaelumPlayer user)
    { return user != null && Owner == user && Amount == 1 && !InMagicBox; }

    bool Open(CaelumPlayer user)
    {
        if (!AvailableTo(user)) return false;
        return CaelumRestTrial.Open(user, null, self);
    }

    bool BeginRest(CaelumPlayer user, int minutes)
    {
        if (!AvailableTo(user) || CaelumRestState.IsActive(user)) return false;
        String reason = CaelumRestState.BlockReason(user);
        if (reason.Length() != 0)
        { user.A_Print(StringTable.Localize(reason, false)); return false; }
        if (!CaelumRestBag.HasRoom(user))
        { user.A_Print(StringTable.Localize("CA_SLEEPING_BAG_SPACE", false)); return false; }
        let mat = CaelumRestBag(Actor.Spawn("CaelumRestBag", user.Pos, NO_REPLACE));
        if (mat == null) return false;
        mat.Bag = self;
        mat.Angle = user.Angle;
        if (CaelumRestState.Begin(user, CaelumRestRules.MODE_SLEEP, minutes, mat)) return true;
        mat.Destroy();
        return false;
    }

    override Inventory CreateTossable(int tossAmount)
    {
        let user = CaelumPlayer(Owner);
        let rest = CaelumRestState.Get(user);
        if (rest != null && CaelumRestBag(rest.Furniture) != null
            && CaelumRestBag(rest.Furniture).Bag == self) CaelumRestState.Cancel(user);
        return Super.CreateTossable(tossAmount);
    }

    static void PrepareTrial(CaelumPlayer user)
    {
        if (!CaelumSewerTrialSupport.IsTrialMap() || user == null
            || CaelumRestState.IsActive(user)) return;
        String reason = CaelumRestState.BlockReason(user);
        if (reason.Length() != 0 && reason != "CA_REST_NEEDS") return;
        if (user.FindInventory("CaelumSleepingBag") != null)
        { user.A_Print(StringTable.Localize("CA_SLEEPING_BAG_OWNED", false)); return; }
        let bag = CaelumSleepingBag(Actor.Spawn("CaelumSleepingBag", user.Pos, NO_REPLACE));
        if (bag == null) return;
        Actor receiver = user;
        if (!bag.TryPickup(receiver))
        {
            bag.Destroy();
            user.A_Print(StringTable.Localize("CA_SLEEPING_BAG_CARRY", false));
        }
        user.PersistCharacterState();
    }

    Default
    {
        Tag "$CA_SLEEPING_BAG_NAME";
        Inventory.Icon "graphics/caelum/icons/materials/ca_material_fabric.png";
        Inventory.PickupMessage "$CA_SLEEPING_BAG_PICKUP";
        Scale 1;
        Radius 12; Height 16;
    }
    States { Spawn: CAHC A -1; Stop; }
}

class CaelumSleepingBagProbe : Actor
{
    Default
    {
        Radius 46; Height 56;
        +SOLID +NOBLOCKMAP +NOGRAVITY +THRUACTORS +CANPASS
        RenderStyle "None";
    }
    States { Spawn: TNT1 A -1; Stop; }
}

class CaelumRestBag : CaelumRestFurniture
{
    CaelumSleepingBag Bag;
    override int RestMode() { return CaelumRestRules.MODE_SLEEP; }
    override int ComfortFactor() { return 3; }
    override vector3 PoseOffset() { return (0, 0, 2); }
    override bool SupportsRest(CaelumPlayer user)
    { return Occupant == user && Bag != null && Bag.AvailableTo(user); }
    override bool Used(Actor activator) { return false; }

    static bool HasRoom(CaelumPlayer user)
    {
        // El volumen de prueba ignora al ocupante; los demás sólidos se
        // verifican abajo. No modifica radio, altura ni flags del jugador.
        let probe = Actor.Spawn("CaelumSleepingBagProbe", user.Pos, NO_REPLACE);
        if (probe == null) return false;
        probe.A_SetSize(46, Max(8.0, user.Height), false);
        bool fits = probe.TestMobjLocation() && Abs(probe.FloorZ-user.Pos.Z) <= 1;
        probe.Destroy();
        if (!fits) return false;
        // Las muestras del perímetro evitan desplegarla sobre bordes/peldaños.
        for (int i = 0; i < 8; i++)
        {
            double a = i*45;
            vector3 point = user.Pos + (Cos(a)*44, Sin(a)*44, 0);
            probe = Actor.Spawn("CaelumSleepingBagProbe", point, NO_REPLACE);
            if (probe == null) return false;
            probe.A_SetSize(1, 8, false);
            fits = probe.TestMobjLocation() && Abs(probe.FloorZ-user.Pos.Z) <= 1;
            probe.Destroy();
            if (!fits) return false;
        }
        let it = ThinkerIterator.Create("Actor");
        Actor other;
        while ((other = Actor(it.Next())) != null)
        {
            if (other == user || !other.bSolid || other.bNoBlockmap) continue;
            if (other.Pos.Z < user.Pos.Z+Max(8.0,user.Height)
                && other.Pos.Z+other.Height > user.Pos.Z
                && user.Distance2D(other) < 46+other.Radius) return false;
        }
        return true;
    }

    override void Release(CaelumPlayer user, vector3 entry)
    {
        if (Occupant != user) return;
        Occupant = null;
        Destroy();
    }

    override void Tick()
    {
        Super.Tick();
        // Incluye restos de un hub previo: la referencia de sesión manda.
        if (Occupant == null) Destroy();
    }

    Default { Radius 46; Height 8; -SOLID +NOBLOCKMAP Tag "$CA_SLEEPING_BAG_NAME"; }
    States { Spawn: CAHC A -1; Stop; }
}
