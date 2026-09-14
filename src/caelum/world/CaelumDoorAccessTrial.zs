// Presentación opcional de accesos. Llave y puertas de prueba no intervienen
// en el inventario narrativo de Argento, reputación ni registro de misiones.
class CaelumDoorAccessTrial : Inventory
{
    CaelumSlidingDoorLeaf LeftDoor;
    CaelumSlidingDoorLeaf RightDoor;
    String PresentationMap;

    static CaelumDoorAccessTrial Get(CaelumPlayer user)
    {
        return user == null ? null : CaelumDoorAccessTrial(user.FindInventory("CaelumDoorAccessTrial"));
    }

    static void Feedback(CaelumPlayer user, String key)
    {
        if (user != null) user.A_Print(StringTable.Localize(key, false));
    }

    static bool Enable(CaelumPlayer user)
    {
        if (user == null || user.player == null || user.health <= 0
            || !user.CharacterCreationComplete || user.CreationWizardOpen
            || user.HasActiveConversation() || user.PalomoMerchantMenuOpen
            || user.CraftingMenuOpen || user.CraftingTaskActive || user.CombatChannelModeActive
            || (user.player.cheats & CF_PREDICTING)) return false;
        let trial = Get(user);
        if (trial != null && trial.PresentationMap == level.MapName
            && trial.LeftDoor != null && trial.RightDoor != null)
        {
            Feedback(user, "CA_DOOR_TRIAL_EXISTS");
            return true;
        }
        bool slideY = Abs(Cos(user.Angle)) > Abs(Sin(user.Angle));
        vector3 axis = slideY ? (0,1,0) : (1,0,0);
        vector3 center = user.Pos + (Cos(user.Angle)*128, Sin(user.Angle)*128, 0);
        // Comprobar las dos posiciones cerradas y abiertas antes de crear nada.
        // Las sondas reutilizan la misma colisión nativa de la prueba social.
        let probe = Actor.Spawn("CaelumReputationPlacementProbe", center, NO_REPLACE);
        if (probe == null) return false;
        bool fits = true;
        for (int step = 0; step < 4; step++)
        {
            probe.SetOrigin(center + axis*(-96 + step*64), false);
            fits = fits && probe.TestMobjLocation();
        }
        probe.Destroy();
        if (!fits) { Feedback(user, "CA_REP_TRIAL_SPACE"); return false; }
        int group = 50000;
        let iterator = ThinkerIterator.Create("CaelumSlidingDoorLeaf");
        CaelumSlidingDoorLeaf existing;
        while ((existing = CaelumSlidingDoorLeaf(iterator.Next())) != null)
            group = Max(group, existing.args[0]);
        if (group == 2147483647) return false;

        let left = CaelumSlidingDoorLeaf(Actor.Spawn("CaelumSlidingDoorLeaf", center-axis*32, NO_REPLACE));
        let right = CaelumSlidingDoorLeaf(Actor.Spawn("CaelumSlidingDoorLeaf", center+axis*32, NO_REPLACE));
        if (left == null || right == null)
        {
            if (left != null) left.Destroy();
            if (right != null) right.Destroy();
            return false;
        }
        if (trial == null) trial = CaelumDoorAccessTrial(user.GiveInventoryType("CaelumDoorAccessTrial"));
        if (trial == null) { left.Destroy(); right.Destroy(); return false; }
        if (trial.LeftDoor != null) trial.LeftDoor.Destroy();
        if (trial.RightDoor != null) trial.RightDoor.Destroy();
        trial.LeftDoor = left; trial.RightDoor = right; trial.PresentationMap = level.MapName;
        left.args[0] = group+1; right.args[0] = group+1;
        left.args[1] = -1; right.args[1] = 1;
        left.args[2] = slideY ? 1 : 0; right.args[2] = left.args[2];
        left.Angle = slideY ? 0 : 90; right.Angle = left.Angle;
        // Sólo la segunda hoja declara la cerradura: usar la primera prueba
        // que el requisito se valida para el grupo entero.
        right.args[3] = 202;
        Feedback(user, "CA_DOOR_TRIAL_ENABLED");
        return true;
    }

    static bool GiveKey(CaelumPlayer user)
    {
        if (user == null || user.player == null || user.health <= 0
            || (user.player.cheats & CF_PREDICTING)) return false;
        if (Get(user) == null) { Feedback(user, "CA_DOOR_TRIAL_NOT_ENABLED"); return false; }
        if (user.FindInventory("CaelumDoorTrialKey") == null
            && user.GiveInventoryType("CaelumDoorTrialKey") == null) return false;
        Feedback(user, "CA_DOOR_TRIAL_KEY_GIVEN");
        return true;
    }

    static bool Disable(CaelumPlayer user)
    {
        let trial = Get(user);
        if (trial == null) return false;
        trial.Destroy();
        Feedback(user, "CA_DOOR_TRIAL_DISABLED");
        return true;
    }

    static void Report(CaelumPlayer user)
    {
        if (user == null) return;
        let trial = Get(user);
        Console.Printf("[Caelum 4.34.0c] Accesos: prueba=%d llave de prueba=%d llave de plata=%d", trial != null,
            user.FindInventory("CaelumDoorTrialKey") != null, user.FindInventory("CaelumSilverKey") != null);
        if (trial == null) return;
        Console.Printf("Presentación=%s mapa actual=%s", trial.PresentationMap, level.MapName);
        for (int id = 0; id < 2; id++)
        {
            let leaf = id == 0 ? trial.LeftDoor : trial.RightDoor;
            if (leaf == null) { Console.Printf("Hoja %d: sin presentación en este mapa", id); continue; }
            Console.Printf("Hoja %d: grupo=%d cerradura=%d progreso=%d/64 solicitada=%d espera=%d paso ocupado=%d",
                id, leaf.args[0], leaf.args[3], leaf.SlideProgress, leaf.DoorRequested,
                leaf.HoldTimer, leaf.PlayerOccupiesDoorway());
        }
    }

    override void OnDestroy()
    {
        if (LeftDoor != null) LeftDoor.Destroy();
        if (RightDoor != null) RightDoor.Destroy();
        if (Owner != null)
        {
            let key = Owner.FindInventory("CaelumDoorTrialKey");
            if (key != null) key.Destroy();
        }
        Super.OnDestroy();
    }

    Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE -INVENTORY.INVBAR }
    States { Spawn: TNT1 A -1; Stop; }
}

// Key nativo sin peso ni fila de equipo. No es la llave de plata y sólo abre
// LOCKDEFS 202; no se coloca como objeto de campaña ni concede otro inventario.
class CaelumDoorTrialKey : Key
{
    Default
    {
        Tag "$CA_DOOR_TRIAL_KEY";
        Inventory.Icon "graphics/caelum/icons/ca_key.png";
        Inventory.MaxAmount 1;
        +INVENTORY.UNDROPPABLE
        -INVENTORY.INVBAR
    }
    States { Spawn: TNT1 A -1; Stop; }
}

class CaelumDebugDoorTrial : CaelumSocialDebugAction
{
    override bool Use(bool pickup) { return CaelumDoorAccessTrial.Enable(CaelumPlayer(Owner)); }
}
class CaelumDebugDoorKey : CaelumSocialDebugAction
{
    override bool Use(bool pickup) { return CaelumDoorAccessTrial.GiveKey(CaelumPlayer(Owner)); }
}
class CaelumDebugDoorTrialOff : CaelumSocialDebugAction
{
    override bool Use(bool pickup) { return CaelumDoorAccessTrial.Disable(CaelumPlayer(Owner)); }
}
