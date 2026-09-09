// Contrato común para los cuatro residentes narrativos de MAP01. Las
// invocaciones de depuración sin args[0] conservan su IA de combate anterior.
class CaelumAnchoredResident : CaelumCombatActor abstract
{
    Vector3 StoryHome;
    double StoryHomeAngle;
    bool StoryAnchored;
    bool StoryReturningHome;

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        StoryHome = Pos;
        StoryHomeAngle = Angle;
        StoryAnchored = args[0] == CaelumConstants.STORY_NPC_ANCHORED;
        StoryReturningHome = false;

        if (StoryAnchored)
        {
            // Son residentes físicos de la mansión, no encuentros de combate.
            bSolid = true;
            bShootable = true;
            bInvulnerable = true;
            bFriendly = true;
            target = null;
        }
    }

    action void A_CaelumResidentLook()
    {
        CaelumAnchoredResident resident = CaelumAnchoredResident(self);
        if (resident != null && resident.StoryAnchored)
        {
            resident.target = null;
            return;
        }
        A_CaelumBudgetedLook();
    }

    action void A_CaelumResidentChase()
    {
        CaelumAnchoredResident resident = CaelumAnchoredResident(self);
        if (resident != null && resident.StoryAnchored)
        {
            resident.target = null;
            return;
        }
        A_CaelumBudgetedChase();
    }

    override void Tick()
    {
        Super.Tick();
        if (!StoryAnchored || health <= 0) { return; }

        target = null;
        bSolid = true;
        bShootable = true;
        bInvulnerable = true;
        bFriendly = true;

        Vector2 homeOffset = StoryHome.XY - Pos.XY;
        double homeDistance = homeOffset.Length();
        if (!StoryReturningHome
            && homeDistance >= CaelumConstants.STORY_NPC_RETURN_DISTANCE)
        {
            StoryReturningHome = true;
            SetState(FindState("See"));
        }

        if (!StoryReturningHome)
        {
            return;
        }

        if (homeDistance <= CaelumConstants.STORY_NPC_HOME_TOLERANCE)
        {
            SetOrigin((StoryHome.X, StoryHome.Y, Pos.Z), true);
            Vel.X = 0.0;
            Vel.Y = 0.0;
            Angle = StoryHomeAngle;
            StoryReturningHome = false;
            SetState(FindState("Spawn"));
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
    }
}
