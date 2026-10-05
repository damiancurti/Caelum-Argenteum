// Vista compartida del escudo real. No escribe inventario, defensa ni relojes.
// Los nuevos estados no desplazan los índices guardados del rig histórico.
class CaelumFirstPersonShieldFrames : Actor
{
    States (Weapon, Overlay)
    {
    BucklerIdle: DSHD AB 8; Loop;
    BucklerRaise: DSHD CD 3; Goto BucklerIdle;
    BucklerLower: DSHD D 3; DSHD C -1; Stop;
    BucklerAttack: DSHD A 8; Goto BucklerIdle;
    BucklerBlock: DSHD H 3;
    BucklerHold: DSHD I -1; Stop;
    KiteIdle: KSHD AB 8; Loop;
    KiteRaise: KSHD CD 3; Goto KiteIdle;
    KiteLower: KSHD D 3; KSHD C -1; Stop;
    KiteAttack: KSHD A 8; Goto KiteIdle;
    KiteBlock: KSHD H 3;
    KiteHold: KSHD I -1; Stop;
    TowerIdle: TSHD AB 8; Loop;
    TowerRaise: TSHD CD 3; Goto TowerIdle;
    TowerLower: TSHD D 3; TSHD C -1; Stop;
    TowerAttack: TSHD A 8; Goto TowerIdle;
    TowerBlock: TSHD H 3;
    TowerHold: TSHD I -1; Stop;
    MagicIdle: MSHD AB 8; Loop;
    MagicRaise: MSHD CD 3; Goto MagicIdle;
    MagicLower: MSHD D 3; MSHD C -1; Stop;
    MagicAttack: MSHD A 8; Goto MagicIdle;
    MagicBlock: MSHD H 3;
    MagicHold: MSHD I -1; Stop;
    HandIdle: LHND AB 8; Loop;
    HandRaise: LHND CD 3; Goto HandIdle;
    HandLower: LHND D 3; LHND C -1; Stop;
    HandAttack: LHND A 8; Goto HandIdle;
    HandBlock: LHND H 3;
    HandHold: LHND I -1; Stop;
    }
}

// Estados propios para no mover los índices históricos de reposo y golpe.
class CaelumGauntletGuardFrames : Actor
{
    States (Weapon, Overlay)
    {
    Tier1: GGB1 A -1; Stop;
    Tier2: GGB2 A -1; Stop;
    Tier3: GGB3 A -1; Stop;
    }
}

class CaelumFirstPersonShield : Object play
{
    const BODY_LAYER = 44;
    const HAND_LAYER = 45;
    bool Initialized;
    int LastType;
    String LastRole;

    static void Clear(CaelumPlayer user)
    { user.A_ClearOverlays(BODY_LAYER, HAND_LAYER); }

    static String Family(int kind)
    {
        switch (kind)
        {
            case CaelumConstants.SHIELD_TYPE_KITE: return "Kite";
            case CaelumConstants.SHIELD_TYPE_TOWER: return "Tower";
            case CaelumConstants.SHIELD_TYPE_MAGIC: return "Magic";
            default: return "Buckler";
        }
    }

    static State Pose(String family, String role)
    { return GetDefaultByType("CaelumFirstPersonShieldFrames").FindStateByString(family .. role); }

    static void Place(CaelumPlayer user, int layer, State pose, vector2 position, bool restart)
    {
        bool fresh = user.player.FindPSprite(layer) == null;
        let view = user.player.GetPSprite(layer);
        if (view == null) return;
        if (fresh || restart) view.SetState(pose);
        view.bAddWeapon = false; view.bAddBob = true;
        view.bPowDouble = false; view.bCVarFast = false;
        view.bInterpolate = true; view.bPivotPercent = false;
        view.scale = (1,1); view.rotation = 0;
        view.x = position.X; view.y = position.Y;
        if (fresh || restart) { view.oldx = view.x; view.oldy = view.y; }
    }

    bool Update(CaelumPlayer user, PSprite baseView, bool outgoing, bool attack)
    {
        // Guanteletes bloquean por sí mismos y nunca simulan un escudo.
        let item = user.FindActiveNativeShield();
        if (item == null || item.Durability <= 0 || user.IsGiantGauntletsBlockSource()
            || !user.HasActiveBlockSource())
        { Clear(user); Initialized = false; return false; }
        bool blocking = !outgoing && user.CombatBlockModeActive;
        double lower = Max(0.0, baseView.y - WEAPONTOP);
        String role = blocking ? "Block" : outgoing ? "Lower"
            : lower > 1 ? "Raise" : attack ? "Attack" : "Idle";
        bool missing = user.player.FindPSprite(BODY_LAYER) == null
            || user.player.FindPSprite(HAND_LAYER) == null;
        bool restart = !Initialized || missing || LastType != item.ItemType || LastRole != role;
        // Al cargar un bloqueo sostenido, reconstruye I directamente: no repite H.
        String poseRole = blocking && (!Initialized || missing) ? "Hold" : role;
        vector2 position = blocking ? (160,100) : (82 + baseView.x,45 + lower);
        Place(user, BODY_LAYER, Pose(Family(item.ItemType), poseRole), position, restart);
        Place(user, HAND_LAYER, Pose("Hand", poseRole), position, restart);
        LastType = item.ItemType; LastRole = role; Initialized = true;
        return blocking;
    }
}
