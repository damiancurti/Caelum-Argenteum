// Vistas FP v1: presentación nativa; no modifica daño, recursos ni cadencia.
// Los 93 estados pertenecen a una clase nueva, sin desplazar estados guardados.
class CaelumFirstPersonFrames : Actor
{
    States (Weapon, Overlay)
    {
// Fragmento para agregar DENTRO de States de la clase que controla la vista.
// No es un ZSCRIPT completo ni contiene callbacks de daño.
// Los cuadros -1 permanecen visibles hasta que el controlador los sustituye.

CA_FP1_dagger_T1_A:
    C011 A -1;
    Stop;

CA_FP1_dagger_T2_A:
    C012 A -1;
    Stop;

CA_FP1_dagger_T3_A:
    C013 A -1;
    Stop;

CA_FP1_hatchet_T1_A:
    C021 A -1;
    Stop;

CA_FP1_hatchet_T2_A:
    C022 A -1;
    Stop;

CA_FP1_hatchet_T3_A:
    C023 A -1;
    Stop;

CA_FP1_machete_T1_A:
    C031 A -1;
    Stop;

CA_FP1_machete_T2_A:
    C032 A -1;
    Stop;

CA_FP1_machete_T3_A:
    C033 A -1;
    Stop;

CA_FP1_javelin_T1_A:
    C041 A -1;
    Stop;

CA_FP1_javelin_T2_A:
    C042 A -1;
    Stop;

CA_FP1_javelin_T3_A:
    C043 A -1;
    Stop;

CA_FP1_sword_T1_A:
    C051 A -1;
    Stop;

CA_FP1_sword_T2_A:
    C052 A -1;
    Stop;

CA_FP1_sword_T3_A:
    C053 A -1;
    Stop;

CA_FP1_axe_T1_A:
    C061 A -1;
    Stop;

CA_FP1_axe_T2_A:
    C062 A -1;
    Stop;

CA_FP1_axe_T3_A:
    C063 A -1;
    Stop;

CA_FP1_flail_T1_A:
    C071 A -1;
    Stop;

CA_FP1_flail_T2_A:
    C072 A -1;
    Stop;

CA_FP1_flail_T3_A:
    C073 A -1;
    Stop;

CA_FP1_spear_T1_A:
    C081 A -1;
    Stop;

CA_FP1_spear_T2_A:
    C082 A -1;
    Stop;

CA_FP1_spear_T3_A:
    C083 A -1;
    Stop;

CA_FP1_greatsword_T1_A:
    C091 A -1;
    Stop;

CA_FP1_greatsword_T2_A:
    C092 A -1;
    Stop;

CA_FP1_greatsword_T3_A:
    C093 A -1;
    Stop;

CA_FP1_war_axe_T1_A:
    C101 A -1;
    Stop;

CA_FP1_war_axe_T2_A:
    C102 A -1;
    Stop;

CA_FP1_war_axe_T3_A:
    C103 A -1;
    Stop;

CA_FP1_halberd_T1_A:
    C111 A -1;
    Stop;

CA_FP1_halberd_T2_A:
    C112 A -1;
    Stop;

CA_FP1_halberd_T3_A:
    C113 A -1;
    Stop;

CA_FP1_staff_T1_A:
    C121 A -1;
    Stop;

CA_FP1_staff_T2_A:
    C122 A -1;
    Stop;

CA_FP1_staff_T3_A:
    C123 A -1;
    Stop;

CA_FP1_statuette_T1_A:
    C131 A -1;
    Stop;

CA_FP1_statuette_T2_A:
    C132 A -1;
    Stop;

CA_FP1_statuette_T3_A:
    C133 A -1;
    Stop;

CA_FP1_bell_T1_A:
    C141 A -1;
    Stop;

CA_FP1_bell_T2_A:
    C142 A -1;
    Stop;

CA_FP1_bell_T3_A:
    C143 A -1;
    Stop;

CA_FP1_book_T1_A:
    C151 A -1;
    Stop;

CA_FP1_book_T2_A:
    C152 A -1;
    Stop;

CA_FP1_book_T3_A:
    C153 A -1;
    Stop;

CA_FP1_book_T1_B:
    C151 B -1;
    Stop;

CA_FP1_book_T2_B:
    C152 B -1;
    Stop;

CA_FP1_book_T3_B:
    C153 B -1;
    Stop;

CA_FP1_standard_bow_T1_A:
    C161 A -1;
    Stop;

CA_FP1_standard_bow_T2_A:
    C162 A -1;
    Stop;

CA_FP1_standard_bow_T3_A:
    C163 A -1;
    Stop;

CA_FP1_standard_bow_T1_B:
    C161 B -1;
    Stop;

CA_FP1_standard_bow_T2_B:
    C162 B -1;
    Stop;

CA_FP1_standard_bow_T3_B:
    C163 B -1;
    Stop;

CA_FP1_standard_bow_T1_C:
    C161 C -1;
    Stop;

CA_FP1_standard_bow_T2_C:
    C162 C -1;
    Stop;

CA_FP1_standard_bow_T3_C:
    C163 C -1;
    Stop;

CA_FP1_longbow_T1_A:
    C171 A -1;
    Stop;

CA_FP1_longbow_T2_A:
    C172 A -1;
    Stop;

CA_FP1_longbow_T3_A:
    C173 A -1;
    Stop;

CA_FP1_longbow_T1_B:
    C171 B -1;
    Stop;

CA_FP1_longbow_T2_B:
    C172 B -1;
    Stop;

CA_FP1_longbow_T3_B:
    C173 B -1;
    Stop;

CA_FP1_longbow_T1_C:
    C171 C -1;
    Stop;

CA_FP1_longbow_T2_C:
    C172 C -1;
    Stop;

CA_FP1_longbow_T3_C:
    C173 C -1;
    Stop;

CA_FP1_crossbow_T1_A:
    C181 A -1;
    Stop;

CA_FP1_crossbow_T2_A:
    C182 A -1;
    Stop;

CA_FP1_crossbow_T3_A:
    C183 A -1;
    Stop;

CA_FP1_crossbow_T1_B:
    C181 B -1;
    Stop;

CA_FP1_crossbow_T2_B:
    C182 B -1;
    Stop;

CA_FP1_crossbow_T3_B:
    C183 B -1;
    Stop;

CA_FP1_crossbow_T1_C:
    C181 C -1;
    Stop;

CA_FP1_crossbow_T2_C:
    C182 C -1;
    Stop;

CA_FP1_crossbow_T3_C:
    C183 C -1;
    Stop;

CA_FP1_carbine_T1_A:
    C191 A -1;
    Stop;

CA_FP1_carbine_T2_A:
    C192 A -1;
    Stop;

CA_FP1_carbine_T3_A:
    C193 A -1;
    Stop;

CA_FP1_carbine_T1_B:
    C191 B -1;
    Stop;

CA_FP1_carbine_T2_B:
    C192 B -1;
    Stop;

CA_FP1_carbine_T3_B:
    C193 B -1;
    Stop;

CA_FP1_carbine_T1_C:
    C191 C -1;
    Stop;

CA_FP1_carbine_T2_C:
    C192 C -1;
    Stop;

CA_FP1_carbine_T3_C:
    C193 C -1;
    Stop;

CA_FP1_giant_gauntlets_T1_A:
    C201 A -1;
    Stop;

CA_FP1_giant_gauntlets_T2_A:
    C202 A -1;
    Stop;

CA_FP1_giant_gauntlets_T3_A:
    C203 A -1;
    Stop;

CA_FP1_giant_gauntlets_T1_B:
    C201 B -1;
    Stop;

CA_FP1_giant_gauntlets_T2_B:
    C202 B -1;
    Stop;

CA_FP1_giant_gauntlets_T3_B:
    C203 B -1;
    Stop;

CA_FP1_giant_gauntlets_T1_C:
    C201 C -1;
    Stop;

CA_FP1_giant_gauntlets_T2_C:
    C202 C -1;
    Stop;

CA_FP1_giant_gauntlets_T3_C:
    C203 C -1;
    Stop;
    }
}

class CaelumFirstPersonView : Object play
{
    const LAYER = 50;
    bool Initialized;
    int ItemId, WeaponType, Tier, AttackFrame, AttackLength, AttackSide;
    double PreviousCooldown;
    bool PreviousCastCompleted;
    String ViewMap;

    static clearscope bool OwnsView(Weapon selector)
    {
        return selector is 'CaelumPhysicalSelectorWeapon'
            || selector is 'CaelumMagicSelectorWeapon';
    }

    static clearscope String Family(int weaponType)
    {
        switch (weaponType)
        {
            case 0: return "sword";
            case 1: return "staff";
            case 2: return "carbine";
            case 3: return "dagger";
            case 4: return "hatchet";
            case 5: return "machete";
            case 6: return "javelin";
            case 7: return "axe";
            case 8: return "flail";
            case 9: return "spear";
            case 10: return "greatsword";
            case 11: return "war_axe";
            case 12: return "halberd";
            case 13: return "giant_gauntlets";
            case 14: return "standard_bow";
            case 15: return "longbow";
            case 16: return "crossbow";
            case 17: return "bell";
            case 18: return "book";
            case 19: return "statuette";
            default: return "";
        }
    }

    static State Pose(int weaponType, int tier, int phase)
    {
        String frame = phase == 1 ? "B" : phase == 2 ? "C" : "A";
        return GetDefaultByType("CaelumFirstPersonFrames").FindStateByString(
            String.Format("CA_FP1_%s_T%d_%s", Family(weaponType), Clamp(tier,1,3), frame));
    }

    static Vector2 Pivot(int weaponType, int tier, int phase)
    {
        // Porcentaje distinto por caja visible; todos vienen del manifiesto.
        int index = Clamp(weaponType,0,19)*9 + (Clamp(tier,1,3)-1)*3 + Clamp(phase,0,2);
        static const double px[] = {
            0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860,
            0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860,
            0.603773585, 0.603773585, 0.603773585, 0.603773585, 0.603773585, 0.603773585, 0.603773585, 0.603773585, 0.603773585,
            0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860,
            0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860,
            0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860,
            0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860,
            0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860,
            0.529850746, 0.529850746, 0.529850746, 0.522727273, 0.522727273, 0.522727273, 0.519083969, 0.519083969, 0.519083969,
            0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860,
            0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860,
            0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860,
            0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860,
            0.500000000, 0.493617021, 0.510638298, 0.500000000, 0.478448276, 0.504201681, 0.502092050, 0.480686695, 0.506276151,
            0.500000000, 0.500000000, 0.491304348, 0.500000000, 0.500000000, 0.489082969, 0.504464286, 0.502183406, 0.491304348,
            0.500000000, 0.500000000, 0.500000000, 0.498069498, 0.500000000, 0.498069498, 0.501945525, 0.502040816, 0.503906250,
            0.527173913, 0.527173913, 0.530054645, 0.527173913, 0.527173913, 0.530054645, 0.527173913, 0.527173913, 0.530054645,
            0.261061947, 0.261061947, 0.261061947, 0.254464286, 0.254464286, 0.254464286, 0.254464286, 0.254464286, 0.254464286,
            0.422222222, 0.376000000, 0.422222222, 0.417910448, 0.376000000, 0.417910448, 0.417910448, 0.380952381, 0.417910448,
            0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860, 0.267441860
        };
        static const double py[] = {
            0.727564103, 0.727564103, 0.727564103, 0.727564103, 0.727564103, 0.727564103, 0.727564103, 0.727564103, 0.727564103,
            0.755747126, 0.755747126, 0.755747126, 0.754335260, 0.754335260, 0.754335260, 0.755747126, 0.755747126, 0.755747126,
            0.835443038, 0.850574713, 0.842424242, 0.835443038, 0.850574713, 0.842424242, 0.835443038, 0.849710983, 0.842424242,
            0.665354331, 0.665354331, 0.665354331, 0.667968750, 0.667968750, 0.667968750, 0.667968750, 0.667968750, 0.667968750,
            0.698581560, 0.698581560, 0.698581560, 0.698581560, 0.698581560, 0.698581560, 0.698581560, 0.698581560, 0.698581560,
            0.732704403, 0.732704403, 0.732704403, 0.732704403, 0.732704403, 0.732704403, 0.732704403, 0.732704403, 0.732704403,
            0.750000000, 0.750000000, 0.750000000, 0.751461988, 0.751461988, 0.751461988, 0.750000000, 0.750000000, 0.750000000,
            0.698581560, 0.698581560, 0.698581560, 0.698581560, 0.698581560, 0.698581560, 0.698581560, 0.698581560, 0.698581560,
            0.708904110, 0.708904110, 0.708904110, 0.708904110, 0.708904110, 0.708904110, 0.708904110, 0.708904110, 0.708904110,
            0.755747126, 0.755747126, 0.755747126, 0.755747126, 0.755747126, 0.755747126, 0.755747126, 0.755747126, 0.755747126,
            0.758522727, 0.758522727, 0.758522727, 0.758522727, 0.758522727, 0.758522727, 0.758522727, 0.758522727, 0.758522727,
            0.736024845, 0.736024845, 0.736024845, 0.736024845, 0.736024845, 0.736024845, 0.736024845, 0.736024845, 0.736024845,
            0.757142857, 0.757142857, 0.757142857, 0.759887006, 0.759887006, 0.759887006, 0.759887006, 0.759887006, 0.759887006,
            0.727272727, 0.787234043, 0.791666667, 0.729729730, 0.790209790, 0.793103448, 0.727272727, 0.790209790, 0.793103448,
            0.621118012, 0.657303371, 0.504065041, 0.621118012, 0.653409091, 0.504065041, 0.621118012, 0.657303371, 0.504065041,
            0.688775510, 0.675531915, 0.561151079, 0.687179487, 0.678947368, 0.557971014, 0.690355330, 0.682291667, 0.564285714,
            0.800675676, 0.790780142, 0.790780142, 0.800675676, 0.790780142, 0.792253521, 0.800675676, 0.790780142, 0.792253521,
            0.257425743, 0.257425743, 0.257425743, 0.257425743, 0.257425743, 0.257425743, 0.257425743, 0.257425743, 0.257425743,
            0.660869565, 0.690476190, 0.660869565, 0.660869565, 0.688000000, 0.660869565, 0.660869565, 0.695312500, 0.660869565,
            0.662698413, 0.662698413, 0.662698413, 0.662698413, 0.662698413, 0.662698413, 0.662698413, 0.662698413, 0.662698413
        };
        return (px[index], py[index]);
    }

    void Hide(CaelumPlayer user)
    {
        if (user != null) CaelumFirstPersonLayers.Clear(user);
        Initialized = false; AttackLength = 0;
    }

    void Update(Weapon selector, CaelumPlayer user, PSprite baseView)
    {
        if (user == null || user.player == null) return;
        bool outgoing=Initialized && user.player.PendingWeapon!=null
            && user.player.PendingWeapon!=WP_NOCHANGE && user.player.PendingWeapon!=selector;
        if (selector != user.player.ReadyWeapon || user.health <= 0
            || user.player.playerstate != PST_LIVE || !user.CharacterCreationComplete
            || user.CreationWizardOpen || user.EquipmentMenuOpen || user.CraftingMenuOpen
            || (!user.HUDHasActiveWeapon && !outgoing) || CaelumRestState.IsActive(user)
            || user.ForcedSleepTics > 0)
        { Hide(user); return; }
        int kind = outgoing ? WeaponType : user.HUDActiveWeaponType;
        if (kind < 0 || kind >= CaelumConstants.WEAPON_TYPE_COUNT)
        { Hide(user); return; }
        if (!Initialized || (!outgoing && (ItemId != user.HUDActiveWeaponItemId
            || WeaponType != kind || Tier != user.HUDActiveWeaponTier)) || ViewMap != level.MapName)
        {
            CaelumFirstPersonLayers.Clear(user);
            ItemId=user.HUDActiveWeaponItemId; WeaponType=kind; Tier=user.HUDActiveWeaponTier;
            PreviousCooldown=user.EquippedWeaponCooldownRemaining;
            PreviousCastCompleted=user.LastStaffCastCompleted;
            AttackFrame=0; AttackLength=0; ViewMap=level.MapName; Initialized=true;
        }
        bool ranged = user.IsRangedWeaponType(kind);
        bool magic = user.WeaponModel.IsMagicalType(kind);
        // La recuperación sólo crece cuando el callback real acepta el golpe
        // o crea el proyectil. Una pulsación rechazada no genera esta señal.
        if (user.EquippedWeaponCooldownRemaining > PreviousCooldown + 0.0001)
        {
            AttackFrame=0;
            AttackLength=Min(8,Max(1,int(Ceil(user.EquippedWeaponCooldownRemaining*TICRATE))));
            AttackSide=(user.player.cmd.buttons & BT_ALTATTACK) != 0 ? 2 : 1;
        }
        if (magic && user.LastStaffCastCompleted && !PreviousCastCompleted)
        { AttackFrame=0; AttackLength=8; AttackSide=1; }
        PreviousCooldown=user.EquippedWeaponCooldownRemaining;
        PreviousCastCompleted=user.LastStaffCastCompleted;
        bool attack = !outgoing && AttackLength > 0 && AttackFrame < AttackLength;
        bool blocking = !outgoing && user.CombatBlockModeActive && user.HasActiveBlockSource();
        bool reloading = ranged && user.RangedReloadActive && user.RangedReloadWeaponType == kind;
        int magazine = ranged ? user.GetRangedMagazineCount(kind) : 0;
        int phase = 0;
        bool bow = kind == CaelumConstants.WEAPON_TYPE_STANDARD_BOW || kind == CaelumConstants.WEAPON_TYPE_LONGBOW;
        if (bow)
            phase = magazine <= 0 || attack ? 2 : user.RangedAimModeActive ? 1 : 0;
        else if (kind == CaelumConstants.WEAPON_TYPE_CROSSBOW)
            phase = reloading ? 2 : magazine <= 0 || attack ? 1 : 0;
        else if (kind == CaelumConstants.WEAPON_TYPE_CARBINE)
            phase = reloading ? 2 : attack ? 1 : 0;
        else if (kind == CaelumConstants.WEAPON_TYPE_BOOK)
            phase = blocking || baseView.y > WEAPONTOP + 1 ? 1 : 0;
        else if (kind == CaelumConstants.WEAPON_TYPE_GIANT_GAUNTLETS)
            phase = attack && !blocking ? AttackSide : 0;
        State pose = Pose(kind, Tier, phase);
        if (pose == null) { Hide(user); return; }
        let view = user.player.GetPSprite(LAYER);
        if (view == null) return;
        if (view.CurState != pose) view.SetState(pose);
        view.scale=(1,1);
        view.bAddWeapon = false;
        view.bAddBob = true;
        view.bPivotPercent = true;
        view.bPowDouble = false;
        view.bCVarFast = false;
        view.bInterpolate = true;
        view.pivot = Pivot(kind, Tier, phase);
        // Lienzo 320×200 y offset (160,32); el desplazamiento de Select/Deselect
        // acompaña al arma nativa y no introduce otra espera de jugabilidad.
        double dx=0, dy=0, rotation=0;
        if (attack && !blocking)
        {
            int step = Clamp(AttackFrame*8/Max(1,AttackLength),0,7);
            if (!ranged && !magic && kind != CaelumConstants.WEAPON_TYPE_GIANT_GAUNTLETS)
            {
                static const double xs[] = {18,36,5,-46,-81,-54,-27,-7};
                static const double ys[] = {-17,-36,-33,-21,-11,-7,-4,-1};
                static const double angles[] = {3,6,13,20,25,21,13,6};
                dx=xs[step]; dy=ys[step]; rotation=angles[step];
            }
            else
            {
                double pulse = Sin((step+1)*180.0/9);
                dy = (ranged ? 6.0 : -8.0)*pulse;
                rotation = (ranged ? -2.0 : 4.0)*pulse;
            }
        }
        if (magic && user.StaffCastPending) { dy-=8; rotation-=4; }
        if (user.WeaponChargeActive || user.WeaponChargedStateActive) { dy-=5; rotation-=3; }
        if (blocking)
        {
            dy += kind == CaelumConstants.WEAPON_TYPE_GIANT_GAUNTLETS ? -12 : 18;
            AttackLength=0;
        }
        double lower=Max(0.0,baseView.y-WEAPONTOP);
        // Guardado hacia abajo y a la izquierda para todas las familias.
        dx-=lower*0.85;
        if(CaelumFirstPersonLayers.Handles(kind))
        {
            CaelumFirstPersonLayers.Draw(user,kind,Tier,phase,baseView.x+dx,lower+dy,rotation);
            if(attack)AttackFrame++;
            return;
        }
        user.A_ClearOverlays(46,49); user.A_ClearOverlays(51,52);
        view.x=160 + baseView.x + dx;
        view.y=32 + Max(0.0,baseView.y-WEAPONTOP) + dy;
        view.rotation=rotation;
        if (attack) AttackFrame++;
    }
}
