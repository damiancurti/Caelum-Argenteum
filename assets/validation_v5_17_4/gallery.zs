// #463: sala aislada de arte; no añade encuentros ni reglas de campaña.
class CA463Camera : Actor
{
    Default { CameraHeight 0; Height 0; Radius 0; +NOINTERACTION +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
}

class CA463GalleryEvents : EventHandler
{
    Array<Actor> Subjects;
    Array<State> MotionSnapshot;
    CA463Camera View;
    int Failures;
    vector3 WalkStart;

    void Check(bool okay, String label)
    {
        if (!okay) Failures++;
        Console.Printf("CA463 %s %s", okay ? "PASS" : "FAIL", label);
    }

    void ConfigureView(int index)
    {
        if (View == null) return;
        if (index == PLAYER_VIEW) players[0].camera = players[0].mo;
        else players[0].camera = View;
        players[0].mo.bInvisible = index != PLAYER_VIEW;
        let hud = CaelumHUDOverlay(EventHandler.Find('CaelumHUDOverlay'));
        if (hud != null)
        {
            if (index == PLAYER_VIEW) hud.HUDFont = Font.GetFont("CaelumMono");
            else hud.HUDFont = null;
        }
        VIEW_CASES
        View.ClearInterpolation();
    }

    void Verify()
    {
        Check(level.MapName == "CA463G", "isolated gallery map");
        Check(Subjects.Size() == SUBJECT_COUNT, "saved subject registry size");
        Check(View != null, "saved camera reference");
        VERIFY_CASES
        Console.Printf("CA463 COMPLETE failures=%d", Failures);
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        if (level.MapName != "CA463G") return;
        if (e.Name == "ca463_prepare")
        {
            if (Subjects.Size() != 0) return;
            CaelumPlayer(players[0].mo).CharacterCreationComplete = true;
            CaelumPlayer(players[0].mo).CreationWizardOpen = false;
            SPAWN_CASES
            View = CA463Camera(Actor.Spawn('CA463Camera', (0,0,0), NO_REPLACE));
            ConfigureView(0);
        }
        if (e.Name == "ca463_view") ConfigureView(e.Args[0]);
        if (e.Name == "ca463_verify") Verify();
        if (e.Name == "ca463_motion_start")
        {
            MotionSnapshot.Clear();
            for (int index=0; index<Subjects.Size(); index++) MotionSnapshot.Push(Subjects[index].CurState);
        }
        if (e.Name == "ca463_motion_verify")
        {
            Check(MotionSnapshot.Size() == Subjects.Size(), "animation snapshot registry");
            for (int index=0; index<Subjects.Size(); index++)
                Check(Subjects[index].CurState != MotionSnapshot[index], String.Format("subject %d native idle advancement", index));
            Console.Printf("CA463 COMPLETE failures=%d", Failures);
        }
        if (e.Name == "ca463_walk_start")
        {
            ConfigureView(PLAYER_VIEW);
            WalkStart = players[0].mo.Pos;
        }
        if (e.Name == "ca463_walk_verify")
        {
            let user=players[0].mo;
            Console.Printf("CA463 WALK start=(%.3f,%.3f,%.3f) end=(%.3f,%.3f,%.3f) angle=%.3f",WalkStart.X,WalkStart.Y,WalkStart.Z,user.Pos.X,user.Pos.Y,user.Pos.Z,user.Angle);
            Check((user.Pos-WalkStart).Length() > user.Radius, "native player movement in gallery");
            Check(abs(user.Pos.Z-user.floorz)<0.01, "player remains on the walkable floor");
            Console.Printf("CA463 COMPLETE failures=%d", Failures);
        }
        if (e.Name == "ca463_cross_start")
        {
            // Recorrido diagnóstico de las dos uniones entre parcelas.
            players[0].mo.SetOrigin(CROSS_START, false);
            players[0].mo.Angle = CROSS_ANGLE;
            players[0].mo.Vel = (0,0,0);
            Console.Printf("CA463 CROSS START pos=(%.3f,%.3f,%.3f) angle=%.3f",players[0].mo.Pos.X,players[0].mo.Pos.Y,players[0].mo.Pos.Z,players[0].mo.Angle);
        }
        if (e.Name == "ca463_cross_verify")
        {
            let user=players[0].mo;
            Console.Printf("CA463 CROSS END pos=(%.3f,%.3f,%.3f) angle=%.3f",user.Pos.X,user.Pos.Y,user.Pos.Z,user.Angle);
            Check(user.Pos.X > CROSS_BOUNDARY, "native movement crosses both regional boundaries");
            Check(abs(user.Pos.Z-user.floorz)<0.01, "regional crossing stays on the floor");
            Console.Printf("CA463 COMPLETE failures=%d", Failures);
        }
    }
}
