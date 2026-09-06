// Base funcional para los tres personajes folclóricos incorporados en
// 4.29.0aq. Conserva la escala visual del paquete y usa el perfil completo de
// combate de los NPC, sin recursos de supervivencia exclusivos del jugador.
class CaelumFolkloreCombatActor : CaelumCombatActor abstract
{
    Default
    {
        // Cubre el semiancho visible de los lienzos humanos a Scale 0.3125.
        RenderRadius 40;
        Speed 1;
        +FLOORCLIP
        RenderStyle "Normal";
    }

    void InitializeUniformFolkloreProfile(int attributeLevel)
    {
        ClearCombatArmorToBaseClothing();
        InitializeCombatProfile(
            attributeLevel, attributeLevel, attributeLevel,
            attributeLevel, attributeLevel, attributeLevel,
            attributeLevel, attributeLevel, attributeLevel,
            attributeLevel, attributeLevel, attributeLevel
        );

        // El movimiento reutiliza la marcha máxima normal del jugador y su
        // Agilidad Tipo 4. La masa corporal no penaliza una carga vacía.
        CombatBaseSpeed = CaelumConstants.GZDOOM_BASE_MAX_WALK_SPEED
            * CalculateActorType4Percent(CombatAgility) / 100.0;
        Speed = CombatBaseSpeed;
    }
}

// Contrato compartido de interacción para NPC. Centraliza el flanco de Use y
// deja que cada personaje implemente una única operación autoritativa.
class CaelumInteractiveFolkloreActor : CaelumFolkloreCombatActor abstract
{
    bool InteractionUseLatched;
    Actor LastInteractionPlayer;

    virtual bool InteractWithCaelumPlayer(CaelumPlayer user)
    {
        return false;
    }

    override void Tick()
    {
        Super.Tick();
        if (!InteractionUseLatched) { return; }
        PlayerPawn userPawn = PlayerPawn(LastInteractionPlayer);
        if (userPawn == null
            || userPawn.player == null
            || (userPawn.player.cmd.buttons & BT_USE) == 0)
        {
            InteractionUseLatched = false;
            LastInteractionPlayer = null;
        }
    }

    override bool Used(Actor user)
    {
        if (InteractionUseLatched && LastInteractionPlayer == user)
        {
            return true;
        }
        InteractionUseLatched = true;
        LastInteractionPlayer = user;
        CaelumPlayer caelumPlayer = CaelumPlayer(user);
        return caelumPlayer != null
            && InteractWithCaelumPlayer(caelumPlayer);
    }
}

class CaelumPalomo : CaelumInteractiveFolkloreActor
{
    Vector3 WanderHome;
    double WanderDirection;
    int WanderDirectionTics;
    bool WanderEnabled;
    bool MerchantAnchored;

    Default
    {
        Tag "$CA_PALOMO_NAME";
        Health 360500;
        Radius 16;
        Height 56;
        Mass 700;
        Scale 0.3125;
        +SOLID
        +SHOOTABLE
    }

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        InitializeUniformFolkloreProfile(100);
        WanderHome = Pos;
        WanderDirection = Angle;
        WanderDirectionTics = 0;
        MerchantAnchored = args[0]
            == CaelumConstants.PALOMO_MERCHANT_ANCHORED;
        WanderEnabled = !MerchantAnchored;
    }

    action void A_EnablePalomoWander()
    {
        CaelumPalomo palomo = CaelumPalomo(self);
        if (palomo != null && !palomo.MerchantAnchored)
        {
            palomo.WanderEnabled = true;
        }
    }

    action void A_StopPalomoWander()
    {
        CaelumPalomo palomo = CaelumPalomo(self);
        if (palomo == null) { return; }
        palomo.WanderEnabled = false;
        palomo.Vel.X = 0.0;
        palomo.Vel.Y = 0.0;
    }

    override void Tick()
    {
        Super.Tick();
        if (!WanderEnabled || health <= 0
            || CombatLucidityPhysicalStunRemaining > 0.0)
        {
            return;
        }

        Vector2 homeOffset = WanderHome.XY - Pos.XY;
        double homeDistance = homeOffset.Length();
        if (homeDistance > CaelumConstants.PALOMO_TEST_WANDER_RADIUS)
        {
            WanderDirection = VectorAngle(homeOffset.X, homeOffset.Y);
            WanderDirectionTics = 8;
        }
        else
        {
            if (BlockingMobj != null
                || MovementBlockingLine != null
                || BlockingLine != null)
            {
                WanderDirectionTics = 0;
            }
            if (WanderDirectionTics <= 0)
            {
                WanderDirection = Random[CaelumPalomoWander](0, 359);
                WanderDirectionTics = Random[CaelumPalomoWander](35, 105);
            }
            else
            {
                WanderDirectionTics--;
            }
        }

        Angle = WanderDirection;
        Vel.X = Cos(WanderDirection) * Speed;
        Vel.Y = Sin(WanderDirection) * Speed;
    }

    override bool InteractWithCaelumPlayer(CaelumPlayer caelumPlayer)
    {
        if (caelumPlayer.GrantMagicBoxFromPalomo())
        {
            return true;
        }
        caelumPlayer.OpenPalomoMerchant(self);
        return true;
    }

    States
    {
    Spawn:
        PALM A 1 A_EnablePalomoWander;
        Goto Walk;
    Walk:
        PALM B 0 A_EnablePalomoWander;
        PALM BC 4;
        Loop;
    Talk:
        PALM D 0 A_StopPalomoWander;
        PALM D -1;
        Stop;
    Laugh:
        PLLF A 0 A_StopPalomoWander;
        PLLF ABCBD 5;
        Loop;
    Anger:
        PLAG A 0 A_StopPalomoWander;
        PLAG ABC 6;
        PLAG D -1;
        Stop;
    Joy:
        PLJY A 0 A_StopPalomoWander;
        PLJY ABCD 6;
        Loop;
    Surprise:
        PLSP A 0 A_StopPalomoWander;
        PLSP ABC 4;
        PLSP C 4;
        PLSP D -1;
        Stop;
    Sadness:
        PLSD A 0 A_StopPalomoWander;
        PLSD ABC 9;
        PLSD D -1;
        Stop;
    Thought:
        PLTH A 0 A_StopPalomoWander;
        PLTH ABCD 7;
        Loop;
    Pain:
        PALM A 0 A_StopPalomoWander;
        PALM A 5 A_Pain;
        Goto Walk;
    Death:
        PALM A 0 A_StopPalomoWander;
        PALM A 5 A_Scream;
        PALM A 0 A_NoBlocking;
        PALM A -1;
        Stop;
    }
}

class CaelumMandinga : CaelumFolkloreCombatActor
{
    Default
    {
        Tag "$CA_MANDINGA_NAME";
        Health 798;
        Radius 14.755556;
        Height 51.644444;
        Mass 66;
        MeleeRange 52;
        Scale 0.3125;
        Monster;
        +LOOKALLAROUND
    }

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        InitializeUniformFolkloreProfile(6);
        ConfigureCombatMagicalRange();
    }

    override String GetCaelumRecognitionSound()
    {
        return "caelum/enemies/mandinga_alert";
    }

    States
    {
    Spawn:
        MNDG A 10 A_CaelumBudgetedLook;
        Loop;
    See:
        TNT1 A 0 A_JumpIf(
            CombatLucidityPhysicalStunRemaining > 0.0,
            "LucidityStun"
        );
        MNDG BC 4 A_CaelumBudgetedChase;
        Loop;
    Walk:
        Goto See;
    LucidityStun:
        MNDG A 1;
        Goto See;
    Melee:
        MNDG D 6 A_FaceTarget;
        MNDG E 0 A_CaelumProfiledMeleeAttack(
            CaelumConstants.MANDINGA_MACHETE_BASE_DAMAGE
        );
        MNDG E 4;
        Goto See;
    Missile:
        // 18 tics: ficha T1 de bastón redondeada con Elocuencia 6.
        MNDG D 14 A_FaceTarget;
        MNDG E 0 A_CaelumSpawnTierOneMagicProjectile(
            "CaelumActorSimpleElementalProjectile",
            0.65,
            CaelumConstants.WEAPON_TYPE_STAFF,
            CaelumConstants.ESSENCE_FIRE,
            false
        );
        MNDG E 4;
        Goto See;
    Attack:
        Goto Melee;
    Pain:
        MNDG F 5 A_Pain;
        Goto See;
    Death:
        MNDG G 5 A_Scream;
        MNDG HI 5;
        MNDG J 5 A_NoBlocking;
        MNDG K 5;
        MNDG L -1;
        Stop;
    }
}

class CaelumZupayColossus : CaelumFolkloreCombatActor
{
    Default
    {
        Tag "$CA_ZUPAY_COLOSSUS_NAME";
        Health 44022;
        Radius 26.666667;
        Height 93.333333;
        Mass 666;
        MeleeRange 192;
        // 208 px desde el pivote al borde × 0,3125.
        RenderRadius 65;
        // 384 px visibles × 0,3125 = 120 MU; la caja física mide 93,33 MU.
        Scale 0.3125;
        Monster;
        +LOOKALLAROUND
    }

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        InitializeUniformFolkloreProfile(33);
        ConfigureCombatMagicalRange();
    }

    override String GetCaelumRecognitionSound()
    {
        return "caelum/enemies/zupay_alert";
    }

    States
    {
    Spawn:
        TNT1 A 0 NoDelay A_StopSound(CHAN_7);
        ZUPY A 10 A_CaelumBudgetedLook;
        Loop;
    See:
        TNT1 A 0 A_JumpIf(
            CombatLucidityPhysicalStunRemaining > 0.0,
            "LucidityStun"
        );
        ZUPY B 0 A_StartSoundIfNotSame(
            "caelum/enemies/zupay_walk",
            "caelum/enemies/zupay_walk",
            CHAN_7
        );
        ZUPY BC 4 A_CaelumBudgetedChase;
        Loop;
    Walk:
        Goto See;
    LucidityStun:
        TNT1 A 0 A_StopSound(CHAN_7);
        ZUPY A 1;
        Goto See;
    Melee:
        TNT1 A 0 A_StopSound(CHAN_7);
        // El golpe conserva el mismo punto proporcional de impacto, pero su
        // ciclo completo pasa de 10 a 20 tics.
        ZUPY D 12 A_FaceTarget;
        ZUPY E 0 A_CaelumGroundSlam(
            CaelumConstants.ZUPAY_SLAM_BASE_DAMAGE,
            CaelumConstants.ZUPAY_SLAM_RADIUS_MAP_UNITS,
            CaelumConstants.ZUPAY_SLAM_VERTICAL_SPEED
        );
        ZUPY E 8;
        Goto See;
    Missile:
        TNT1 A 0 A_StopSound(CHAN_7);
        // 20 tics: ficha T1 de estatuilla redondeada con Elocuencia 33.
        ZUPY M 3 A_FaceTarget;
        ZUPY NOPQ 3;
        // El proyectil nace al pasar de throw_release a throw_recover.
        ZUPY R 0 A_CaelumSpawnTierOneMagicProjectile(
            "CaelumActorExplosiveElementalProjectile",
            0.65,
            CaelumConstants.WEAPON_TYPE_STATUETTE,
            CaelumConstants.ESSENCE_EARTH,
            true
        );
        ZUPY R 5;
        Goto See;
    Attack:
        Goto Melee;
    Pain:
        TNT1 A 0 A_StopSound(CHAN_7);
        ZUPY F 5 A_Pain;
        Goto See;
    Death:
        TNT1 A 0 A_StopSound(CHAN_7);
        ZUPY G 5 A_Scream;
        ZUPY HI 5;
        ZUPY J 5 A_NoBlocking;
        ZUPY K 5;
        ZUPY L -1;
        Stop;
    Lift:
        TNT1 A 0 A_StopSound(CHAN_7);
        ZUPY MN 6;
        ZUPY O -1;
        Stop;
    Throw:
        Goto Missile;
    }
}
