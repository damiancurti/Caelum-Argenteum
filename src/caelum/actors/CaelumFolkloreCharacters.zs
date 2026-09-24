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
    virtual bool InteractWithCaelumPlayer(CaelumPlayer user)
    {
        return false;
    }

    override bool Used(Actor user)
    {
        CaelumPlayer caelumPlayer = CaelumPlayer(user);
        if (caelumPlayer == null || caelumPlayer.player == null)
        {
            return false;
        }

        // La interacción sólo nace de una pulsación física de Use. El latch
        // vive en el jugador porque PlayerThink limpia BT_USE mientras la
        // tienda está abierta; así Q no puede cerrar y reabrirla en el mismo
        // pulso cuando Palomo continúa bajo la mira.
        if ((caelumPlayer.player.cmd.buttons & BT_USE) == 0
            || caelumPlayer.FolkloreInteractionUseLatched)
        {
            return true;
        }
        caelumPlayer.FolkloreInteractionUseLatched = true;
        caelumPlayer.FolkloreInteractionReleaseGuardTics = 0;
        return InteractWithCaelumPlayer(caelumPlayer);
    }
}

class CaelumPalomo : CaelumInteractiveFolkloreActor
{
    Vector3 WanderHome;
    double WanderDirection;
    int WanderDirectionTics;
    bool WanderEnabled;
    bool MerchantAnchored;
    bool MerchantReturningHome;
    double MerchantHomeAngle;
    bool NarrativeRevealInitialized;
    bool NarrativeRevealRequired;
    bool NarrativeRevealed;
    bool NarrativeDismissed;
    bool DepartureStarted;
    bool DepartureDone;
    int DepartureWaypoint;

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
        MerchantReturningHome = false;
        MerchantHomeAngle = Angle;
        InitializeNarrativeReveal();
    }

    bool IsNarrativeRevealReady()
    {
        for (int playerIndex = 0; playerIndex < MAXPLAYERS; playerIndex++)
        {
            if (!playeringame[playerIndex]) { continue; }
            CaelumPlayer caelumPlayer = CaelumPlayer(players[playerIndex].mo);
            if (caelumPlayer != null && caelumPlayer.HasMainM00Flag(
                    CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD
                ))
            {
                return true;
            }
        }
        return false;
    }

    bool IsNarrativeFoyerComplete()
    {
        for (int playerIndex = 0; playerIndex < MAXPLAYERS; playerIndex++)
        {
            if (!playeringame[playerIndex]) { continue; }
            CaelumPlayer caelumPlayer = CaelumPlayer(players[playerIndex].mo);
            if (caelumPlayer != null && caelumPlayer.HasMainM00Flag(
                    CaelumConstants.MAIN_M00_FLAG_PALOMO_MET
                ))
            {
                return true;
            }
        }
        return false;
    }

    bool IsVisibleToAnyActivePlayer()
    {
        for (int playerIndex = 0; playerIndex < MAXPLAYERS; playerIndex++)
        {
            if (!playeringame[playerIndex]) { continue; }
            CaelumPlayer caelumPlayer = CaelumPlayer(players[playerIndex].mo);
            if (caelumPlayer == null || caelumPlayer.health <= 0
                || !caelumPlayer.CheckSight(self))
            {
                continue;
            }
            double viewOffset = Abs(DeltaAngle(
                caelumPlayer.Angle, caelumPlayer.AngleTo(self)
            ));
            if (viewOffset <= 70.0) { return true; }
        }
        return false;
    }

    void InitializeNarrativeReveal()
    {
        NarrativeRevealInitialized = true;
        NarrativeRevealRequired = MerchantAnchored
            && level.MapName == "MAP01";
        NarrativeDismissed = false;
        NarrativeRevealed = !NarrativeRevealRequired || IsNarrativeRevealReady();
        Alpha = 1.0;
        bInvisible = !NarrativeRevealed;
        bSolid = NarrativeRevealed;
        bShootable = NarrativeRevealed;
        if (NarrativeRevealRequired) bInvulnerable = true;
    }

    Vector3 GetDepartureWaypoint(int index)
    {
        switch (index)
        {
            case 0: return (-650,0,0);
            case 1: return (1360,0,0);
            case 2: return (1360,260,136);
            case 3: return (1456,260,136);
            case 4: return (1600,260,136);
            case 5: return (1600,0,136);
            case 6: return (1848,0,136);
            case 7: return (1848,344,136);
            case 8: return (1750,344,136);
            case 9: return (1750,0,264);
            case 10: return (1600,0,264);
            case 11: return (1200,0,264);
            case 12: return (1000,0,264);
            case 13: return (500,0,264);
            default: return (500,120,264);
        }
    }

    void UpdateDeparture()
    {
        if (bInConversation) { Vel.X = 0; Vel.Y = 0; return; }
        // Alpha no oculta actores de RenderStyle Normal. La visibilidad se
        // controla con INVISIBLE; durante la retirada nunca se oculta.
        bInvisible = false; Alpha = 1; bSolid = true; bShootable = true;
        bInvulnerable = true; bCanPass = true;
        if (!DepartureStarted)
        {
            DepartureStarted = true; NarrativeDismissed = false;
            NarrativeRevealed = true; DepartureWaypoint = 0;
            SetStateLabel("DepartureRun");
        }
        if (DepartureDone) { Vel.X = 0; Vel.Y = 0; return; }
        Vector3 goal = GetDepartureWaypoint(DepartureWaypoint);
        Vector2 offset = goal.XY - Pos.XY;
        if (offset.Length() < 8 && Abs(Pos.Z-goal.Z) < 20)
        {
            DepartureWaypoint++;
            if (DepartureWaypoint > 14)
            {
                DepartureDone = true; NarrativeDismissed = true;
                WanderHome = Pos; Vel.X = 0; Vel.Y = 0;
                SetStateLabel("DepartureWait"); return;
            }
            goal = GetDepartureWaypoint(DepartureWaypoint);
            offset = goal.XY - Pos.XY;
        }
        // Abrir únicamente puertas sin llave cercanas y en su propio nivel.
        let doors = ThinkerIterator.Create("CaelumSlidingDoorLeaf"); CaelumSlidingDoorLeaf door;
        while ((door = CaelumSlidingDoorLeaf(doors.Next())) != null)
            if (door.args[3] == 0 && Abs(door.Pos.Z-Pos.Z) < 32 && Distance2D(door) < 100)
                door.RequestDoorGroup(self);
        Angle = VectorAngle(offset.X,offset.Y);
        double pace = Min(8.0,offset.Length());
        Vel.X = Cos(Angle)*pace; Vel.Y = Sin(Angle)*pace;
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

    // El movimiento sigue en Tick; esta selección sólo cambia su dibujo.
    void UpdateLocomotionVisual()
    {
        if (health <= 0 || bInConversation || CombatLucidityPhysicalStunRemaining > 0) return;
        if (CurState == FindState("DepartureWait") && tics < 0) tics = 10;
        State walkVisual = FindState("Walk");
        State runVisual = FindState("Run");
        State idleVisual = FindState("IdleBreathing");
        if (!InStateSequence(CurState, SpawnState)
            && !InStateSequence(CurState, walkVisual)
            && !InStateSequence(CurState, runVisual)
            && !InStateSequence(CurState, idleVisual)) return;
        if (DepartureStarted) return;
        bool moving = Vel.X * Vel.X + Vel.Y * Vel.Y > 0.01;
        State wanted = !moving ? idleVisual : MerchantReturningHome ? runVisual : walkVisual;
        if (!InStateSequence(CurState, wanted)) SetState(wanted);
    }

    override void Tick()
    {
        Super.Tick();
        UpdateLocomotionVisual();
        if (!NarrativeRevealInitialized) { InitializeNarrativeReveal(); }
        // CAPALOMO no queda unido permanentemente a la clase. Tras cerrar la
        // conversación, retirar el nodo devuelve la siguiente pulsación a
        // Actor.Used, donde se resincronizan estado y requisitos por jugador.
        if (!bInConversation && HasConversation())
        {
            Level.ExecuteSpecial(
                CaelumConstants.GZDOOM_THING_SET_CONVERSATION_SPECIAL,
                self, null, false, 0, 0
            );
        }
        if (NarrativeRevealRequired)
        {
            if (IsNarrativeFoyerComplete()) { UpdateDeparture(); return; }
            if (!NarrativeRevealed)
            {
                if (!IsNarrativeRevealReady())
                { bInvisible = true; bSolid = false; bShootable = false; Vel.X = 0; Vel.Y = 0; return; }
                NarrativeRevealed = true;
            }
            bInvisible = false; Alpha = 1; bSolid = true; bShootable = true;
        }
        if (health <= 0 || CombatLucidityPhysicalStunRemaining > 0.0)
        {
            return;
        }

        Vector2 homeOffset = WanderHome.XY - Pos.XY;
        double homeDistance = homeOffset.Length();
        if (MerchantAnchored)
        {
            if (!MerchantReturningHome
                && homeDistance
                    >= CaelumConstants.PALOMO_MERCHANT_RETURN_DISTANCE)
            {
                MerchantReturningHome = true;
            }

            if (!MerchantReturningHome) { return; }
            if (homeDistance <= 1.0)
            {
                Vel.X = 0.0;
                Vel.Y = 0.0;
                Angle = MerchantHomeAngle;
                MerchantReturningHome = false;
                return;
            }

            double returnDirection = VectorAngle(homeOffset.X, homeOffset.Y);
            double returnSpeed = CombatBaseSpeed
                * CaelumConstants.GZDOOM_BASE_MAX_RUN_SPEED
                / CaelumConstants.GZDOOM_BASE_MAX_WALK_SPEED;
            double resolvedSpeed = Min(Max(0.0, returnSpeed), homeDistance);
            Angle = returnDirection;
            Vel.X = Cos(returnDirection) * resolvedSpeed;
            Vel.Y = Sin(returnDirection) * resolvedSpeed;
            return;
        }

        if (!WanderEnabled) { return; }
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
        if (NarrativeRevealRequired && IsNarrativeFoyerComplete() && !DepartureDone) return false;
        return caelumPlayer.OpenPalomoDialogue(self);
    }

    States
    {
    Spawn:
        PAID A 1 A_EnablePalomoWander;
        Goto Walk;
    Walk:
        PAWK A 0 A_EnablePalomoWander;
        PAWK AB 4;
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
    DepartureRun:
        PARN AB 4;
        Goto DepartureRunContinue;
    DepartureWait:
        PAID A 10;
        Goto IdleBreathing;

    // Los estados anteriores mantienen su índice para guardar/cargar.
    IdleBreathing:
        PAID A 10;
        Loop;
    Run:
        PARN ABCD 3;
        Loop;
    DepartureRunContinue:
        PARN CD 4;
        Goto DepartureRun;
    RestSeated:
        RSPA A -1 A_StopPalomoWander;
        Stop;
    RestLying:
        RSPA B -1 A_StopPalomoWander;
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
        MIID A 10 A_CaelumBudgetedLook;
        Goto IdleBreathing;
    See:
        TNT1 A 0 A_JumpIf(
            CombatLucidityPhysicalStunRemaining > 0.0,
            "LucidityStun"
        );
        MIRN AB 4 A_CaelumBudgetedChase;
        Goto RunSecondHalf;
    Walk:
        Goto WalkCycle;
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

    // Estados nuevos al final: conservan los índices de partidas anteriores.
    IdleBreathing:
        MIID AAA 10 A_CaelumBudgetedLook;
        MIID BBBB 10 A_CaelumBudgetedLook;
        Goto Spawn;
    RunSecondHalf:
        TNT1 A 0 A_JumpIf(CombatLucidityPhysicalStunRemaining > 0.0, "LucidityStun");
        MIRN CD 4 A_CaelumBudgetedChase;
        Goto See;
    Run:
        Goto See;
    WalkCycle:
        TNT1 A 0 A_JumpIf(CombatLucidityPhysicalStunRemaining > 0.0, "LucidityStun");
        MIWK AB 4 A_CaelumBudgetedChase;
        Loop;
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
        ZUID A 10 A_CaelumBudgetedLook;
        Goto IdleBreathing;
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
        ZURN AB 4 A_CaelumBudgetedChase;
        Goto RunSecondHalf;
    Walk:
        Goto WalkCycle;
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

    // Estados nuevos al final: conservan los índices de partidas anteriores.
    IdleBreathing:
        ZUID AAA 10 A_CaelumBudgetedLook;
        ZUID BBBB 10 A_CaelumBudgetedLook;
        Goto Spawn;
    RunSecondHalf:
        TNT1 A 0 A_JumpIf(CombatLucidityPhysicalStunRemaining > 0.0, "LucidityStun");
        ZURN CD 4 A_CaelumBudgetedChase;
        Goto See;
    Run:
        Goto See;
    WalkCycle:
        TNT1 A 0 A_JumpIf(CombatLucidityPhysicalStunRemaining > 0.0, "LucidityStun");
        ZUWK A 0 A_StartSoundIfNotSame("caelum/enemies/zupay_walk", "caelum/enemies/zupay_walk", CHAN_7);
        ZUWK AB 4 A_CaelumBudgetedChase;
        Loop;
    }
}
