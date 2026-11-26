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
        if (index == 4) players[0].camera = players[0].mo;
        else players[0].camera = View;
        players[0].mo.bInvisible = index != 4;
        let hud = CaelumHUDOverlay(EventHandler.Find('CaelumHUDOverlay'));
        if (hud != null)
        {
            if (index == 4) hud.HUDFont = Font.GetFont("CaelumMono");
            else hud.HUDFont = null;
        }
        if(index==0){View.SetOrigin((0,-160,1400),false);View.Angle=90.00000000;View.Pitch=83.48019825;}
if(index==1){View.SetOrigin((-768,-110,60),false);View.Angle=90.00000000;View.Pitch=21.80140949;}
if(index==2){View.SetOrigin((-256,-110,60),false);View.Angle=90.00000000;View.Pitch=21.80140949;}
if(index==3){View.SetOrigin((512,-480,240),false);View.Angle=75.06858282;View.Pitch=17.85262395;}
if(index==5){View.SetOrigin((256,-155,85),false);View.Angle=90.00000000;View.Pitch=25.21892289;}
if(index==6){View.SetOrigin((960,-300,260),false);View.Angle=130.47523153;View.Pitch=19.54420599;}
if(index==7){View.SetOrigin((-768,-280,200),false);View.Angle=0.00000000;View.Pitch=90.00000000;}
if(index==8){View.SetOrigin((-256,-280,70),false);View.Angle=0.00000000;View.Pitch=90.00000000;}
if(index==9){View.SetOrigin((384,-280,120),false);View.Angle=0.00000000;View.Pitch=90.00000000;}
        View.ClearInterpolation();
    }

    void Verify()
    {
        Check(level.MapName == "CA463G", "isolated gallery map");
        Check(Subjects.Size() == 4, "saved subject registry size");
        Check(View != null, "saved camera reference");
        Check(Subjects[0] != null && Subjects[0].GetClass()=='CA455PomberoPreview', "subject 0 original class");
if(Subjects[0] != null) Check((Subjects[0].Pos-(-768,0,0)).Length()<0.01, "subject 0 saved position");
Check(Subjects[1] != null && Subjects[1].GetClass()=='CA455PomberoPreview', "subject 1 original class");
if(Subjects[1] != null) Check((Subjects[1].Pos-(-256,0,0)).Length()<0.01, "subject 1 saved position");
Check(Subjects[2] != null && Subjects[2].GetClass()=='CA455CueroPreview', "subject 2 original class");
if(Subjects[2] != null) Check((Subjects[2].Pos-(256,0,0)).Length()<0.01, "subject 2 saved position");
Check(Subjects[3] != null && Subjects[3].GetClass()=='CA455NahuelitoPreview', "subject 3 original class");
if(Subjects[3] != null) Check((Subjects[3].Pos-(704,0,0)).Length()<0.01, "subject 3 saved position");
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
            {let item=Actor.Spawn('CA455PomberoPreview',(-768,0,0),NO_REPLACE);item.Angle=270;Subjects.Push(item);}
{let item=Actor.Spawn('CA455PomberoPreview',(-256,0,0),NO_REPLACE);item.Angle=270;Subjects.Push(item);}
{let item=Actor.Spawn('CA455CueroPreview',(256,0,0),NO_REPLACE);item.Angle=270;Subjects.Push(item);}
{let item=Actor.Spawn('CA455NahuelitoPreview',(704,0,0),NO_REPLACE);item.Angle=180;Subjects.Push(item);}
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
            ConfigureView(4);
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
            players[0].mo.SetOrigin((-768,-256,0), false);
            players[0].mo.Angle = 90;
            players[0].mo.Vel = (0,0,0);
            Console.Printf("CA463 CROSS START pos=(%.3f,%.3f,%.3f) angle=%.3f",players[0].mo.Pos.X,players[0].mo.Pos.Y,players[0].mo.Pos.Z,players[0].mo.Angle);
        }
        if (e.Name == "ca463_cross_verify")
        {
            let user=players[0].mo;
            Console.Printf("CA463 CROSS END pos=(%.3f,%.3f,%.3f) angle=%.3f",user.Pos.X,user.Pos.Y,user.Pos.Z,user.Angle);
            Check(user.Pos.X > 0, "native movement crosses both regional boundaries");
            Check(abs(user.Pos.Z-user.floorz)<0.01, "regional crossing stays on the floor");
            Console.Printf("CA463 COMPLETE failures=%d", Failures);
        }
    }
}
