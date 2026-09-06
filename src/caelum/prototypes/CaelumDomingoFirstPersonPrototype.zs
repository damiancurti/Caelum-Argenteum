// Caelum Argenteum — prototipo modular de primera persona de Domingo.
// Es una herramienta visual aislada: no sustituye todavía los selectores ni
// las reglas de daño, bloqueo, aire o durabilidad del equipamiento real.
class CA_DomingoFPSwordShield : Weapon
{
    Default
    {
        Tag "$CA_DOMINGO_FP_PROTOTYPE_NAME";
        Weapon.SelectionOrder 2500;
        Weapon.Kickback 60;
        +WEAPON.MELEEWEAPON
        +WEAPON.NOALERT
        +INVENTORY.UNDROPPABLE
    }

    States
    {
    Spawn:
        TNT1 A -1;
        Stop;

    Select:
        TNT1 A 0
        {
            // Orden: brazo izquierdo < escudo < espada < mano derecha.
            A_Overlay(10, "CA_LeftSelect", true);
            A_Overlay(20, "CA_ShieldSelect", true);
            A_Overlay(30, "CA_SwordSelect", true);
            A_Overlay(40, "CA_RightSelect", true);
        }
        TNT1 A 1 A_Raise;
        Loop;

    Deselect:
        TNT1 A 0 A_ClearOverlays(10, 40);
        TNT1 A 1 A_Lower;
        Loop;

    Ready:
        TNT1 A 0
        {
            A_Overlay(10, "CA_LeftIdle", true);
            A_Overlay(20, "CA_ShieldIdle", true);
            A_Overlay(30, "CA_SwordIdle", true);
            A_Overlay(40, "CA_RightIdle", true);
        }
        TNT1 A 1 A_WeaponReady;
        Loop;

    Fire:
        TNT1 A 0
        {
            A_Overlay(10, "CA_LeftAttack");
            A_Overlay(20, "CA_ShieldAttack");
            A_Overlay(30, "CA_SwordAttack");
            A_Overlay(40, "CA_RightAttack");
        }
        TNT1 A 2;
        // Sólo permite sentir la animación dentro de esta arma de consola.
        // El combate autoritativo de Caelum no se modifica con el prototipo.
        TNT1 A 0 A_CustomPunch(30, true);
        TNT1 A 6;
        Goto Ready;

    AltFire:
        TNT1 A 0
        {
            A_Overlay(10, "CA_LeftBlock");
            A_Overlay(20, "CA_ShieldBlock");
            A_Overlay(30, "CA_SwordBlock");
            A_Overlay(40, "CA_RightBlock");
        }
        // Prueba visual: aún no reduce daño ni consume Aire.
        TNT1 A 10;
        Goto Ready;

    CA_LeftSelect:
        LHND C 2;
        LHND D 2;
        Goto CA_LeftIdle;
    CA_ShieldSelect:
        DSHD C 2;
        DSHD D 2;
        Goto CA_ShieldIdle;
    CA_SwordSelect:
        DSWD C 2;
        DSWD D 2;
        Goto CA_SwordIdle;
    CA_RightSelect:
        RHND C 2;
        RHND D 2;
        Goto CA_RightIdle;

    CA_LeftIdle:
        LHND AB 8;
        Loop;
    CA_ShieldIdle:
        DSHD AB 8;
        Loop;
    CA_SwordIdle:
        DSWD AB 8;
        Loop;
    CA_RightIdle:
        RHND AB 8;
        Loop;

    CA_LeftAttack:
        LHND E 2;
        LHND F 3;
        LHND G 3;
        Goto CA_LeftIdle;
    CA_ShieldAttack:
        DSHD E 2;
        DSHD F 3;
        DSHD G 3;
        Goto CA_ShieldIdle;
    CA_SwordAttack:
        DSWD E 2;
        DSWD F 3;
        DSWD G 3;
        Goto CA_SwordIdle;
    CA_RightAttack:
        RHND E 2;
        RHND F 3;
        RHND G 3;
        Goto CA_RightIdle;

    CA_LeftBlock:
        LHND H 3;
        LHND I 7;
        Goto CA_LeftIdle;
    CA_ShieldBlock:
        DSHD H 3;
        DSHD I 7;
        Goto CA_ShieldIdle;
    CA_SwordBlock:
        DSWD H 3;
        DSWD I 7;
        Goto CA_SwordIdle;
    CA_RightBlock:
        RHND H 3;
        RHND I 7;
        Goto CA_RightIdle;
    }
}
