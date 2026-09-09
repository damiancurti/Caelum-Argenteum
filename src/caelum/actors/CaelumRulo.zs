// Rulo conserva su perfil de combate para pruebas aisladas. En MAP01 se coloca
// con args[0]=1 y adopta el contrato tangible/anclado del residente.
class CaelumRulo : CaelumAnchoredResident
{
    Default
    {
        Tag "$CA_RULO_NAME";
        Health 6200;
        Radius 21.3;
        Height 74.7;
        Mass 200;
        Speed 8;
        MeleeRange 72;
        MinMissileChance 128;
        MaxTargetRange 768;
        Scale 0.454545;
        Monster;
        +FLOORCLIP
    }

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        InitializeCombatProfile(20, 20, 20, 18, 18, 18, 9, 9, 9, 3, 3, 3);
        InitializeCombatArmor(CaelumConstants.ARMOR_TYPE_HEAVY, 1);
        for (int slot = 0; CombatArmor != null
            && slot < CaelumConstants.ARMOR_SLOT_COUNT; slot++)
        {
            CombatArmor.Size[slot] = CaelumConstants.EQUIPMENT_SIZE_XL;
            CombatArmor.Durability[slot] = CombatArmor.GetMaximumDurability(slot);
        }
        ConfigureCombatMagicalRange();
    }

    override String GetCaelumRecognitionSound()
    {
        return "caelum/npcs/rulo_alert";
    }

    States
    {
    Spawn:
        RULO A 10 A_CaelumResidentLook;
        Loop;
    See:
        TNT1 A 0 A_JumpIf(CombatLucidityPhysicalStunRemaining > 0.0, "LucidityStun");
        RULO BCDC 4 A_CaelumResidentChase;
        Loop;
    LucidityStun:
        RULO A 1;
        Goto See;
    Melee:
        RULO E 9 A_FaceTarget;
        RULO E 0 A_CaelumMeleeAttack(372);
        RULO A 13;
        Goto See;
    Missile:
        RULO E 9 A_FaceTarget;
        RULO E 0 A_CaelumSpawnSimpleElementalProjectile(
            "CaelumActorSimpleElementalProjectile", 46,
            372, CaelumConstants.ESSENCE_EARTH
        );
        RULO A 16;
        Goto See;
    Pain:
        RULO F 8 A_Pain;
        Goto See;
    Death:
        RULO G 5 A_Scream;
        RULO H 5;
        RULO I 5 A_NoBlocking;
        RULO JK 5;
        RULO L -1;
        Stop;
    }
}
