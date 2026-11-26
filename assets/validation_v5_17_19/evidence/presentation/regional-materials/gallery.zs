// #682: sala aislada de arte; no añade encuentros ni reglas de campaña.
class CA682Camera : Actor
{
    Default { CameraHeight 0; Height 0; Radius 0; +NOINTERACTION +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
}

class CA682GalleryEvents : EventHandler
{
    Array<Actor> Subjects;
    Array<State> MotionSnapshot;
    CA682Camera View;
    int Failures;
    vector3 WalkStart;

    void Check(bool okay, String label)
    {
        if (!okay) Failures++;
        Console.Printf("CA682 %s %s", okay ? "PASS" : "FAIL", label);
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
        if(index==0){View.SetOrigin((0,-800,1200),false);View.Angle=90.00000000;View.Pitch=56.30993247;}
if(index==1){View.SetOrigin((-768,-110,60),false);View.Angle=90.00000000;View.Pitch=17.17590362;}
if(index==2){View.SetOrigin((-256,-110,60),false);View.Angle=90.00000000;View.Pitch=17.17590362;}
if(index==3){View.SetOrigin((256,-250,120),false);View.Angle=90.00000000;View.Pitch=20.60626061;}
if(index==5){View.SetOrigin((768,-110,60),false);View.Angle=90.00000000;View.Pitch=17.17590362;}
if(index==6){View.SetOrigin((-768,-280,150),false);View.Angle=0.00000000;View.Pitch=90.00000000;}
if(index==7){View.SetOrigin((-256,-280,150),false);View.Angle=0.00000000;View.Pitch=90.00000000;}
if(index==8){View.SetOrigin((256,-280,150),false);View.Angle=0.00000000;View.Pitch=90.00000000;}
if(index==9){View.SetOrigin((768,-280,80),false);View.Angle=0.00000000;View.Pitch=90.00000000;}
        View.ClearInterpolation();
    }

    bool IsIdleState(Actor body, State value)
    {
        return value==body.SpawnState || body.InStateSequence(value,body.FindState('IdleBreathing'));
    }

    void Verify()
    {
        Check(level.MapName == "CA682G", "isolated gallery map");
        Check(Subjects.Size() == 5, "saved subject registry size");
        Check(View != null, "saved camera reference");
        Check(Subjects[0]!=null && Subjects[0].GetClass()=='CaelumBestiary003',"subject 0 native class");
if(Subjects[0]!=null){Console.Printf("CA682 POSITION 0 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[0].Pos.X,Subjects[0].Pos.Y,Subjects[0].Pos.Z,Subjects[0].Vel.X,Subjects[0].Vel.Y,Subjects[0].Vel.Z);Check((Subjects[0].Pos-(-768,0,0)).Length()<0.01,"subject 0 saved position");let body=CaelumBestiaryCombatActor(Subjects[0]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-003","subject 0 initialized inspection catalogue identity");}
Check(Subjects[1]!=null && Subjects[1].GetClass()=='CaelumBestiary005',"subject 1 native class");
if(Subjects[1]!=null){Console.Printf("CA682 POSITION 1 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[1].Pos.X,Subjects[1].Pos.Y,Subjects[1].Pos.Z,Subjects[1].Vel.X,Subjects[1].Vel.Y,Subjects[1].Vel.Z);Check((Subjects[1].Pos-(-256,0,0)).Length()<0.01,"subject 1 saved position");let body=CaelumBestiaryCombatActor(Subjects[1]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-005","subject 1 initialized inspection catalogue identity");}
Check(Subjects[2]!=null && Subjects[2].GetClass()=='CaelumBestiary003',"subject 2 native class");
if(Subjects[2]!=null){Console.Printf("CA682 POSITION 2 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[2].Pos.X,Subjects[2].Pos.Y,Subjects[2].Pos.Z,Subjects[2].Vel.X,Subjects[2].Vel.Y,Subjects[2].Vel.Z);Check((Subjects[2].Pos-(128,0,0)).Length()<0.01,"subject 2 saved position");let body=CaelumBestiaryCombatActor(Subjects[2]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-003","subject 2 initialized inspection catalogue identity");}
Check(Subjects[3]!=null && Subjects[3].GetClass()=='CaelumBestiary004',"subject 3 native class");
if(Subjects[3]!=null){Console.Printf("CA682 POSITION 3 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[3].Pos.X,Subjects[3].Pos.Y,Subjects[3].Pos.Z,Subjects[3].Vel.X,Subjects[3].Vel.Y,Subjects[3].Vel.Z);Check((Subjects[3].Pos-(384,0,0)).Length()<0.01,"subject 3 saved position");let body=CaelumBestiaryCombatActor(Subjects[3]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-004","subject 3 initialized inspection catalogue identity");}
Check(Subjects[4]!=null && Subjects[4].GetClass()=='CaelumBestiary004',"subject 4 native class");
if(Subjects[4]!=null){Console.Printf("CA682 POSITION 4 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[4].Pos.X,Subjects[4].Pos.Y,Subjects[4].Pos.Z,Subjects[4].Vel.X,Subjects[4].Vel.Y,Subjects[4].Vel.Z);Check((Subjects[4].Pos-(768,0,0)).Length()<0.01,"subject 4 saved position");let body=CaelumBestiaryCombatActor(Subjects[4]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-004","subject 4 initialized inspection catalogue identity");}
        Console.Printf("CA682 COMPLETE failures=%d", Failures);
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        if (level.MapName != "CA682G") return;
        if (e.Name == "ca682_prepare")
        {
            if (Subjects.Size() != 0) return;
            CaelumPlayer(players[0].mo).CharacterCreationComplete = true;
            CaelumPlayer(players[0].mo).CreationWizardOpen = false;
            players[0].mo.bNOTARGET=true;players[0].mo.bInvulnerable=true;
            {let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary003',(-768,0,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary005',(-256,0,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary003',(128,0,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary004',(384,0,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary004',(768,0,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
            View = CA682Camera(Actor.Spawn('CA682Camera', (0,0,0), NO_REPLACE));
            ConfigureView(0);
        }
        if (e.Name == "ca682_view") ConfigureView(e.Args[0]);
        if (e.Name == "ca682_verify") Verify();
        if (e.Name == "ca682_motion_start")
        {
            MotionSnapshot.Clear();
            for (int index=0; index<Subjects.Size(); index++) MotionSnapshot.Push(Subjects[index].CurState);
        }
        if (e.Name == "ca682_motion_verify")
        {
            Check(MotionSnapshot.Size() == Subjects.Size(), "animation snapshot registry");
            for (int index=0; index<Subjects.Size(); index++)
                Check(Subjects[index].CurState != MotionSnapshot[index] && IsIdleState(Subjects[index],MotionSnapshot[index]) && IsIdleState(Subjects[index],Subjects[index].CurState), String.Format("subject %d native idle advancement", index));
            Console.Printf("CA682 COMPLETE failures=%d", Failures);
        }
        if (e.Name == "ca682_walk_start")
        {
            ConfigureView(4);
            WalkStart = players[0].mo.Pos;
        }
        if (e.Name == "ca682_walk_verify")
        {
            let user=players[0].mo;
            Console.Printf("CA682 WALK start=(%.3f,%.3f,%.3f) end=(%.3f,%.3f,%.3f) angle=%.3f",WalkStart.X,WalkStart.Y,WalkStart.Z,user.Pos.X,user.Pos.Y,user.Pos.Z,user.Angle);
            Check((user.Pos-WalkStart).Length() > user.Radius, "native player movement in gallery");
            Check(abs(user.Pos.Z-user.floorz)<0.01, "player remains on the walkable floor");
            Console.Printf("CA682 COMPLETE failures=%d", Failures);
        }
        if (e.Name == "ca682_cross_start")
        {
            // Recorrido diagnóstico de las tres uniones entre parcelas.
            players[0].mo.SetOrigin((-768,-256,0), false);
            players[0].mo.Angle = 90;
            players[0].mo.Vel = (0,0,0);
            Console.Printf("CA682 CROSS START pos=(%.3f,%.3f,%.3f) angle=%.3f",players[0].mo.Pos.X,players[0].mo.Pos.Y,players[0].mo.Pos.Z,players[0].mo.Angle);
        }
        if (e.Name == "ca682_cross_verify")
        {
            let user=players[0].mo;
            Console.Printf("CA682 CROSS END pos=(%.3f,%.3f,%.3f) angle=%.3f",user.Pos.X,user.Pos.Y,user.Pos.Z,user.Angle);
            Check(user.Pos.X > 512, "native movement crosses all three regional boundaries");
            Check(abs(user.Pos.Z-user.floorz)<0.01, "regional crossing stays on the floor");
            Console.Printf("CA682 COMPLETE failures=%d", Failures);
        }
    }
}
