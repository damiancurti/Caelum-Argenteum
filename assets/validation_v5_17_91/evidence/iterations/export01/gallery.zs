// #825: sala aislada de arte; no añade encuentros ni reglas de campaña.
class CA825Camera : Actor
{
    Default { CameraHeight 0; Height 0; Radius 0; +NOINTERACTION +NOGRAVITY }
    States { Spawn: TNT1 A -1; Stop; }
}

class CA825GalleryEvents : EventHandler
{
    Array<Actor> Subjects;
    Array<State> MotionSnapshot;
    CA825Camera View;
    int Failures;
    String CurrentLabel;
    int ObserverNoiseSerial;
    vector3 WalkStart;

    void Check(bool okay, String label)
    {
        if (!okay) Failures++;
        Console.Printf("CA825 %s %s", okay ? "PASS" : "FAIL", label);
    }

    void ConfigureView(int index)
    {
        if (View == null) return;
        if (index == 1) players[0].camera = players[0].mo;
        else players[0].camera = View;
        players[0].mo.bInvisible = index != 1;
        let hud = CaelumHUDOverlay(EventHandler.Find('CaelumHUDOverlay'));
        if (hud != null)
        {
            if (index == 1) hud.HUDFont = Font.GetFont("CaelumMono");
            else hud.HUDFont = null;
        }
        if(index==0){CurrentLabel="overview | Regional inspection";View.SetOrigin((2560.0,0,3500),false);View.Angle=0.00000000;View.Pitch=90.00000000;}
if(index==2){CurrentLabel="region-1 | Buenos Aires | neutral floor";View.SetOrigin((256.0,-300,800),false);View.Angle=90.00000000;View.Pitch=52.22431569;}
if(index==3){CurrentLabel="region-2 | Pampa";View.SetOrigin((768.0,-300,800),false);View.Angle=90.00000000;View.Pitch=52.22431569;}
if(index==4){CurrentLabel="region-3 | Litoral";View.SetOrigin((1280.0,-300,800),false);View.Angle=90.00000000;View.Pitch=52.22431569;}
if(index==5){CurrentLabel="region-4 | Cuyo";View.SetOrigin((1792.0,-300,800),false);View.Angle=90.00000000;View.Pitch=52.22431569;}
if(index==6){CurrentLabel="region-5 | Northwest Argentina";View.SetOrigin((2304.0,-300,800),false);View.Angle=90.00000000;View.Pitch=52.22431569;}
if(index==7){CurrentLabel="region-6 | Chaco | neutral floor";View.SetOrigin((2816.0,-300,800),false);View.Angle=90.00000000;View.Pitch=52.22431569;}
if(index==8){CurrentLabel="region-7 | Selva";View.SetOrigin((3328.0,-300,800),false);View.Angle=90.00000000;View.Pitch=52.22431569;}
if(index==9){CurrentLabel="region-8 | Patagonia";View.SetOrigin((4096.0,-300,800),false);View.Angle=90.00000000;View.Pitch=52.22431569;}
if(index==10){CurrentLabel="region-9 | Supernatural domains | neutral floor";View.SetOrigin((4864.0,-300,800),false);View.Angle=90.00000000;View.Pitch=52.22431569;}
if(index==11){CurrentLabel="CA-FOLK-001 | Buenos Aires";View.SetOrigin((128,-175,44),false);View.Angle=90.00000000;View.Pitch=9.71325102;}
if(index==12){CurrentLabel="CA-FOLK-031 | Buenos Aires";View.SetOrigin((384,-175,44),false);View.Angle=90.00000000;View.Pitch=9.71325102;}
if(index==13){CurrentLabel="CA-FOLK-032 | Buenos Aires";View.SetOrigin((128,145,44),false);View.Angle=90.00000000;View.Pitch=9.71325102;}
if(index==14){CurrentLabel="CA-FOLK-001 | Pampa";View.SetOrigin((640,-175,44),false);View.Angle=90.00000000;View.Pitch=9.71325102;}
if(index==15){CurrentLabel="CA-FOLK-017 | Pampa";View.SetOrigin((896,-174,41),false);View.Angle=90.00000000;View.Pitch=9.29330860;}
if(index==16){CurrentLabel="CA-FOLK-027 | Pampa";View.SetOrigin((640,146,41),false);View.Angle=90.00000000;View.Pitch=9.29330860;}
if(index==17){CurrentLabel="CA-FOLK-031 | Pampa";View.SetOrigin((896,145,44),false);View.Angle=90.00000000;View.Pitch=9.71325102;}
if(index==18){CurrentLabel="CA-FOLK-037 | Pampa";View.SetOrigin((640,465,44),false);View.Angle=90.00000000;View.Pitch=9.71325102;}
if(index==19){CurrentLabel="CA-FOLK-001 | Litoral";View.SetOrigin((1152,-175,44),false);View.Angle=90.00000000;View.Pitch=9.71325102;}
if(index==20){CurrentLabel="CA-FOLK-031 | Litoral";View.SetOrigin((1408,-175,44),false);View.Angle=90.00000000;View.Pitch=9.71325102;}
if(index==21){CurrentLabel="CA-FOLK-032 | Litoral";View.SetOrigin((1152,145,44),false);View.Angle=90.00000000;View.Pitch=9.71325102;}
if(index==22){CurrentLabel="CA-FOLK-001 | Cuyo";View.SetOrigin((1664,-175,44),false);View.Angle=90.00000000;View.Pitch=9.71325102;}
if(index==23){CurrentLabel="CA-FOLK-015 | Cuyo";View.SetOrigin((1920,-175,44),false);View.Angle=90.00000000;View.Pitch=9.71325102;}
if(index==24){CurrentLabel="CA-FOLK-016 | Cuyo";View.SetOrigin((1664,143,45),false);View.Angle=90.00000000;View.Pitch=9.54452557;}
if(index==25){CurrentLabel="CA-FOLK-027 | Cuyo";View.SetOrigin((1920,146,41),false);View.Angle=90.00000000;View.Pitch=9.29330860;}
if(index==26){CurrentLabel="CA-FOLK-031 | Cuyo";View.SetOrigin((1664,465,44),false);View.Angle=90.00000000;View.Pitch=9.71325102;}
if(index==27){CurrentLabel="CA-FOLK-033 | Cuyo";View.SetOrigin((1920,447,51),false);View.Angle=90.00000000;View.Pitch=9.67826005;}
if(index==28){CurrentLabel="CA-FOLK-001 | Northwest Argentina";View.SetOrigin((2176,-175,44),false);View.Angle=90.00000000;View.Pitch=9.71325102;}
if(index==29){CurrentLabel="CA-FOLK-002 | Northwest Argentina";View.SetOrigin((2432,-175,44),false);View.Angle=90.00000000;View.Pitch=9.71325102;}
if(index==30){CurrentLabel="CA-FOLK-038 | Northwest Argentina";View.SetOrigin((2176,145,44),false);View.Angle=90.00000000;View.Pitch=9.71325102;}
if(index==31){CurrentLabel="CA-FOLK-039 | Northwest Argentina";View.SetOrigin((2432,145,44),false);View.Angle=90.00000000;View.Pitch=9.71325102;}
if(index==32){CurrentLabel="CA-FOLK-040 | Northwest Argentina";View.SetOrigin((2176,464,44),false);View.Angle=90.00000000;View.Pitch=9.62815613;}
if(index==33){CurrentLabel="CA-FOLK-056 | Northwest Argentina";View.SetOrigin((2432,411,53),false);View.Angle=90.00000000;View.Pitch=7.93555037;}
if(index==34){CurrentLabel="CA-FOLK-001 | Chaco";View.SetOrigin((2688,-175,44),false);View.Angle=90.00000000;View.Pitch=9.71325102;}
if(index==35){CurrentLabel="CA-FOLK-012 | Chaco";View.SetOrigin((2944,-175,44),false);View.Angle=90.00000000;View.Pitch=9.71325102;}
if(index==36){CurrentLabel="CA-FOLK-020 | Chaco";View.SetOrigin((2688,145,44),false);View.Angle=90.00000000;View.Pitch=9.71325102;}
if(index==37){CurrentLabel="CA-FOLK-041 | Chaco";View.SetOrigin((2944,145,44),false);View.Angle=90.00000000;View.Pitch=9.71325102;}
if(index==38){CurrentLabel="CA-FOLK-057 | Chaco";View.SetOrigin((2688,389,42),false);View.Angle=90.00000000;View.Pitch=5.49816272;}
if(index==39){CurrentLabel="CA-FOLK-001 | Selva";View.SetOrigin((3200,-175,44),false);View.Angle=90.00000000;View.Pitch=9.71325102;}
if(index==40){CurrentLabel="CA-FOLK-008 | Selva";View.SetOrigin((3456,-176,45),false);View.Angle=90.00000000;View.Pitch=10.12467166;}
if(index==41){CurrentLabel="CA-FOLK-013 | Selva";View.SetOrigin((3200,144,45),false);View.Angle=90.00000000;View.Pitch=10.12467166;}
if(index==42){CurrentLabel="CA-FOLK-014 | Selva";View.SetOrigin((3456,145,44),false);View.Angle=90.00000000;View.Pitch=9.71325102;}
if(index==43){CurrentLabel="CA-FOLK-001 | Patagonia";View.SetOrigin((3755,-175,44),false);View.Angle=90.00000000;View.Pitch=9.71325102;}
if(index==44){CurrentLabel="CA-FOLK-021 | Patagonia";View.SetOrigin((4096,-237,46),false);View.Angle=90.00000000;View.Pitch=6.59451503;}
if(index==45){CurrentLabel="CA-FOLK-022 | Patagonia";View.SetOrigin((4437,-178,43),false);View.Angle=90.00000000;View.Pitch=9.46232221;}
if(index==46){CurrentLabel="CA-FOLK-023 | Patagonia";View.SetOrigin((3755,137,43),false);View.Angle=90.00000000;View.Pitch=9.07149758;}
if(index==47){CurrentLabel="CA-FOLK-024 | Patagonia";View.SetOrigin((4096,145,41),false);View.Angle=90.00000000;View.Pitch=9.21102654;}
if(index==48){CurrentLabel="CA-FOLK-025 | Patagonia";View.SetOrigin((4437,146,44),false);View.Angle=90.00000000;View.Pitch=9.79984867;}
if(index==49){CurrentLabel="CA-FOLK-026 | Patagonia";View.SetOrigin((3755,466,44),false);View.Angle=90.00000000;View.Pitch=9.79984867;}
if(index==50){CurrentLabel="CA-FOLK-027 | Patagonia";View.SetOrigin((4096,466,41),false);View.Angle=90.00000000;View.Pitch=9.29330860;}
if(index==51){CurrentLabel="CA-FOLK-034 | Patagonia";View.SetOrigin((4437,466,41),false);View.Angle=90.00000000;View.Pitch=9.29330860;}
if(index==52){CurrentLabel="CA-FOLK-036 | Patagonia";View.SetOrigin((3755,786,44),false);View.Angle=90.00000000;View.Pitch=9.79984867;}
if(index==53){CurrentLabel="CA-FOLK-042 | Patagonia";View.SetOrigin((4096,777,49),false);View.Angle=90.00000000;View.Pitch=10.00797980;}
if(index==54){CurrentLabel="CA-FOLK-002 | Supernatural domains";View.SetOrigin((4736,-175,44),false);View.Angle=90.00000000;View.Pitch=9.71325102;}
        View.ClearInterpolation();
        Console.Printf("CA825 VIEW index=%d",index);
    }

    // #692: silenciar sólo los pasos del observador en esta sala aislada.
    // La búsqueda por sonido es independiente de Friendly y NOTARGET.
    override void WorldTick()
    {
        if(level.MapName!="CA825G" || Subjects.Size()==0)return;
        let user=CaelumPlayer(players[0].mo);
        if(user!=null)user.MovementNoiseTimer=-CaelumConstants.MOVEMENT_NOISE_INTERVAL_SECONDS;
    }


    // Rótulo exclusivo de inspección: identifica asociación y suelo neutro.
    override void RenderOverlay(RenderEvent e)
    {
        if(level.MapName!="CA825G" || View==null || players[0].camera!=View)return;
        Screen.DrawText(Font.GetFont("CaelumMono"),Font.CR_WHITE,8,8,CurrentLabel,
            DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360,DTA_KEEPRATIO,true);
    }

    bool IsIdleState(Actor body, State value)
    {
        return value==body.SpawnState || body.InStateSequence(value,body.FindState('IdleBreathing'));
    }

    void Verify()
    {
        Check(level.MapName == "CA825G", "isolated gallery map");
        Check(Subjects.Size() == 44, "saved subject registry size");
        Check(View != null, "saved camera reference");
        Check(CaelumPlayer(players[0].mo).MovementNoiseEventSerial==ObserverNoiseSerial,"inspection observer footsteps remain silent");
        Check(Subjects[0]!=null && Subjects[0].GetClass()=='CaelumBestiary001',"subject 0 native class");
if(Subjects[0]!=null){Console.Printf("CA825 POSITION 0 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[0].Pos.X,Subjects[0].Pos.Y,Subjects[0].Pos.Z,Subjects[0].Vel.X,Subjects[0].Vel.Y,Subjects[0].Vel.Z);Check((Subjects[0].Pos-(128,-64,0)).Length()<0.01,"subject 0 saved position");let body=CaelumBestiaryCombatActor(Subjects[0]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-001","subject 0 initialized inspection catalogue identity");}
Check(Subjects[1]!=null && Subjects[1].GetClass()=='CaelumBestiary031',"subject 1 native class");
if(Subjects[1]!=null){Console.Printf("CA825 POSITION 1 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[1].Pos.X,Subjects[1].Pos.Y,Subjects[1].Pos.Z,Subjects[1].Vel.X,Subjects[1].Vel.Y,Subjects[1].Vel.Z);Check((Subjects[1].Pos-(384,-64,0)).Length()<0.01,"subject 1 saved position");let body=CaelumBestiaryCombatActor(Subjects[1]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-031","subject 1 initialized inspection catalogue identity");}
Check(Subjects[2]!=null && Subjects[2].GetClass()=='CaelumBestiary032',"subject 2 native class");
if(Subjects[2]!=null){Console.Printf("CA825 POSITION 2 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[2].Pos.X,Subjects[2].Pos.Y,Subjects[2].Pos.Z,Subjects[2].Vel.X,Subjects[2].Vel.Y,Subjects[2].Vel.Z);Check((Subjects[2].Pos-(128,256,0)).Length()<0.01,"subject 2 saved position");let body=CaelumBestiaryCombatActor(Subjects[2]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-032","subject 2 initialized inspection catalogue identity");}
Check(Subjects[3]!=null && Subjects[3].GetClass()=='CaelumBestiary001',"subject 3 native class");
if(Subjects[3]!=null){Console.Printf("CA825 POSITION 3 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[3].Pos.X,Subjects[3].Pos.Y,Subjects[3].Pos.Z,Subjects[3].Vel.X,Subjects[3].Vel.Y,Subjects[3].Vel.Z);Check((Subjects[3].Pos-(640,-64,0)).Length()<0.01,"subject 3 saved position");let body=CaelumBestiaryCombatActor(Subjects[3]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-001","subject 3 initialized inspection catalogue identity");}
Check(Subjects[4]!=null && Subjects[4].GetClass()=='CaelumBestiary017',"subject 4 native class");
if(Subjects[4]!=null){Console.Printf("CA825 POSITION 4 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[4].Pos.X,Subjects[4].Pos.Y,Subjects[4].Pos.Z,Subjects[4].Vel.X,Subjects[4].Vel.Y,Subjects[4].Vel.Z);Check((Subjects[4].Pos-(896,-64,0)).Length()<0.01,"subject 4 saved position");let body=CaelumBestiaryCombatActor(Subjects[4]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-017","subject 4 initialized inspection catalogue identity");}
Check(Subjects[5]!=null && Subjects[5].GetClass()=='CaelumBestiary027',"subject 5 native class");
if(Subjects[5]!=null){Console.Printf("CA825 POSITION 5 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[5].Pos.X,Subjects[5].Pos.Y,Subjects[5].Pos.Z,Subjects[5].Vel.X,Subjects[5].Vel.Y,Subjects[5].Vel.Z);Check((Subjects[5].Pos-(640,256,0)).Length()<0.01,"subject 5 saved position");let body=CaelumBestiaryCombatActor(Subjects[5]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-027","subject 5 initialized inspection catalogue identity");}
Check(Subjects[6]!=null && Subjects[6].GetClass()=='CaelumBestiary031',"subject 6 native class");
if(Subjects[6]!=null){Console.Printf("CA825 POSITION 6 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[6].Pos.X,Subjects[6].Pos.Y,Subjects[6].Pos.Z,Subjects[6].Vel.X,Subjects[6].Vel.Y,Subjects[6].Vel.Z);Check((Subjects[6].Pos-(896,256,0)).Length()<0.01,"subject 6 saved position");let body=CaelumBestiaryCombatActor(Subjects[6]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-031","subject 6 initialized inspection catalogue identity");}
Check(Subjects[7]!=null && Subjects[7].GetClass()=='CaelumBestiary037',"subject 7 native class");
if(Subjects[7]!=null){Console.Printf("CA825 POSITION 7 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[7].Pos.X,Subjects[7].Pos.Y,Subjects[7].Pos.Z,Subjects[7].Vel.X,Subjects[7].Vel.Y,Subjects[7].Vel.Z);Check((Subjects[7].Pos-(640,576,0)).Length()<0.01,"subject 7 saved position");let body=CaelumBestiaryCombatActor(Subjects[7]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-037","subject 7 initialized inspection catalogue identity");}
Check(Subjects[8]!=null && Subjects[8].GetClass()=='CaelumBestiary001',"subject 8 native class");
if(Subjects[8]!=null){Console.Printf("CA825 POSITION 8 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[8].Pos.X,Subjects[8].Pos.Y,Subjects[8].Pos.Z,Subjects[8].Vel.X,Subjects[8].Vel.Y,Subjects[8].Vel.Z);Check((Subjects[8].Pos-(1152,-64,0)).Length()<0.01,"subject 8 saved position");let body=CaelumBestiaryCombatActor(Subjects[8]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-001","subject 8 initialized inspection catalogue identity");}
Check(Subjects[9]!=null && Subjects[9].GetClass()=='CaelumBestiary031',"subject 9 native class");
if(Subjects[9]!=null){Console.Printf("CA825 POSITION 9 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[9].Pos.X,Subjects[9].Pos.Y,Subjects[9].Pos.Z,Subjects[9].Vel.X,Subjects[9].Vel.Y,Subjects[9].Vel.Z);Check((Subjects[9].Pos-(1408,-64,0)).Length()<0.01,"subject 9 saved position");let body=CaelumBestiaryCombatActor(Subjects[9]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-031","subject 9 initialized inspection catalogue identity");}
Check(Subjects[10]!=null && Subjects[10].GetClass()=='CaelumBestiary032',"subject 10 native class");
if(Subjects[10]!=null){Console.Printf("CA825 POSITION 10 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[10].Pos.X,Subjects[10].Pos.Y,Subjects[10].Pos.Z,Subjects[10].Vel.X,Subjects[10].Vel.Y,Subjects[10].Vel.Z);Check((Subjects[10].Pos-(1152,256,0)).Length()<0.01,"subject 10 saved position");let body=CaelumBestiaryCombatActor(Subjects[10]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-032","subject 10 initialized inspection catalogue identity");}
Check(Subjects[11]!=null && Subjects[11].GetClass()=='CaelumBestiary001',"subject 11 native class");
if(Subjects[11]!=null){Console.Printf("CA825 POSITION 11 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[11].Pos.X,Subjects[11].Pos.Y,Subjects[11].Pos.Z,Subjects[11].Vel.X,Subjects[11].Vel.Y,Subjects[11].Vel.Z);Check((Subjects[11].Pos-(1664,-64,0)).Length()<0.01,"subject 11 saved position");let body=CaelumBestiaryCombatActor(Subjects[11]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-001","subject 11 initialized inspection catalogue identity");}
Check(Subjects[12]!=null && Subjects[12].GetClass()=='CaelumBestiary015',"subject 12 native class");
if(Subjects[12]!=null){Console.Printf("CA825 POSITION 12 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[12].Pos.X,Subjects[12].Pos.Y,Subjects[12].Pos.Z,Subjects[12].Vel.X,Subjects[12].Vel.Y,Subjects[12].Vel.Z);Check((Subjects[12].Pos-(1920,-64,0)).Length()<0.01,"subject 12 saved position");let body=CaelumBestiaryCombatActor(Subjects[12]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-015","subject 12 initialized inspection catalogue identity");}
Check(Subjects[13]!=null && Subjects[13].GetClass()=='CaelumBestiary016',"subject 13 native class");
if(Subjects[13]!=null){Console.Printf("CA825 POSITION 13 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[13].Pos.X,Subjects[13].Pos.Y,Subjects[13].Pos.Z,Subjects[13].Vel.X,Subjects[13].Vel.Y,Subjects[13].Vel.Z);Check((Subjects[13].Pos-(1664,256,0)).Length()<0.01,"subject 13 saved position");let body=CaelumBestiaryCombatActor(Subjects[13]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-016","subject 13 initialized inspection catalogue identity");}
Check(Subjects[14]!=null && Subjects[14].GetClass()=='CaelumBestiary027',"subject 14 native class");
if(Subjects[14]!=null){Console.Printf("CA825 POSITION 14 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[14].Pos.X,Subjects[14].Pos.Y,Subjects[14].Pos.Z,Subjects[14].Vel.X,Subjects[14].Vel.Y,Subjects[14].Vel.Z);Check((Subjects[14].Pos-(1920,256,0)).Length()<0.01,"subject 14 saved position");let body=CaelumBestiaryCombatActor(Subjects[14]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-027","subject 14 initialized inspection catalogue identity");}
Check(Subjects[15]!=null && Subjects[15].GetClass()=='CaelumBestiary031',"subject 15 native class");
if(Subjects[15]!=null){Console.Printf("CA825 POSITION 15 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[15].Pos.X,Subjects[15].Pos.Y,Subjects[15].Pos.Z,Subjects[15].Vel.X,Subjects[15].Vel.Y,Subjects[15].Vel.Z);Check((Subjects[15].Pos-(1664,576,0)).Length()<0.01,"subject 15 saved position");let body=CaelumBestiaryCombatActor(Subjects[15]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-031","subject 15 initialized inspection catalogue identity");}
Check(Subjects[16]!=null && Subjects[16].GetClass()=='CaelumBestiary033',"subject 16 native class");
if(Subjects[16]!=null){Console.Printf("CA825 POSITION 16 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[16].Pos.X,Subjects[16].Pos.Y,Subjects[16].Pos.Z,Subjects[16].Vel.X,Subjects[16].Vel.Y,Subjects[16].Vel.Z);Check((Subjects[16].Pos-(1920,576,0)).Length()<0.01,"subject 16 saved position");let body=CaelumBestiaryCombatActor(Subjects[16]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-033","subject 16 initialized inspection catalogue identity");}
Check(Subjects[17]!=null && Subjects[17].GetClass()=='CaelumBestiary001',"subject 17 native class");
if(Subjects[17]!=null){Console.Printf("CA825 POSITION 17 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[17].Pos.X,Subjects[17].Pos.Y,Subjects[17].Pos.Z,Subjects[17].Vel.X,Subjects[17].Vel.Y,Subjects[17].Vel.Z);Check((Subjects[17].Pos-(2176,-64,0)).Length()<0.01,"subject 17 saved position");let body=CaelumBestiaryCombatActor(Subjects[17]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-001","subject 17 initialized inspection catalogue identity");}
Check(Subjects[18]!=null && Subjects[18].GetClass()=='CaelumBestiary002',"subject 18 native class");
if(Subjects[18]!=null){Console.Printf("CA825 POSITION 18 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[18].Pos.X,Subjects[18].Pos.Y,Subjects[18].Pos.Z,Subjects[18].Vel.X,Subjects[18].Vel.Y,Subjects[18].Vel.Z);Check((Subjects[18].Pos-(2432,-64,0)).Length()<0.01,"subject 18 saved position");let body=CaelumBestiaryCombatActor(Subjects[18]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-002","subject 18 initialized inspection catalogue identity");}
Check(Subjects[19]!=null && Subjects[19].GetClass()=='CaelumBestiary038',"subject 19 native class");
if(Subjects[19]!=null){Console.Printf("CA825 POSITION 19 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[19].Pos.X,Subjects[19].Pos.Y,Subjects[19].Pos.Z,Subjects[19].Vel.X,Subjects[19].Vel.Y,Subjects[19].Vel.Z);Check((Subjects[19].Pos-(2176,256,0)).Length()<0.01,"subject 19 saved position");let body=CaelumBestiaryCombatActor(Subjects[19]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-038","subject 19 initialized inspection catalogue identity");}
Check(Subjects[20]!=null && Subjects[20].GetClass()=='CaelumBestiary039',"subject 20 native class");
if(Subjects[20]!=null){Console.Printf("CA825 POSITION 20 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[20].Pos.X,Subjects[20].Pos.Y,Subjects[20].Pos.Z,Subjects[20].Vel.X,Subjects[20].Vel.Y,Subjects[20].Vel.Z);Check((Subjects[20].Pos-(2432,256,0)).Length()<0.01,"subject 20 saved position");let body=CaelumBestiaryCombatActor(Subjects[20]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-039","subject 20 initialized inspection catalogue identity");}
Check(Subjects[21]!=null && Subjects[21].GetClass()=='CaelumBestiary040',"subject 21 native class");
if(Subjects[21]!=null){Console.Printf("CA825 POSITION 21 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[21].Pos.X,Subjects[21].Pos.Y,Subjects[21].Pos.Z,Subjects[21].Vel.X,Subjects[21].Vel.Y,Subjects[21].Vel.Z);Check((Subjects[21].Pos-(2176,576,0)).Length()<0.01,"subject 21 saved position");let body=CaelumBestiaryCombatActor(Subjects[21]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-040","subject 21 initialized inspection catalogue identity");}
Check(Subjects[22]!=null && Subjects[22].GetClass()=='CaelumBestiary056',"subject 22 native class");
if(Subjects[22]!=null){Console.Printf("CA825 POSITION 22 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[22].Pos.X,Subjects[22].Pos.Y,Subjects[22].Pos.Z,Subjects[22].Vel.X,Subjects[22].Vel.Y,Subjects[22].Vel.Z);Check((Subjects[22].Pos-(2432,576,0)).Length()<0.01,"subject 22 saved position");let body=CaelumBestiaryCombatActor(Subjects[22]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-056","subject 22 initialized inspection catalogue identity");}
Check(Subjects[23]!=null && Subjects[23].GetClass()=='CaelumBestiary001',"subject 23 native class");
if(Subjects[23]!=null){Console.Printf("CA825 POSITION 23 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[23].Pos.X,Subjects[23].Pos.Y,Subjects[23].Pos.Z,Subjects[23].Vel.X,Subjects[23].Vel.Y,Subjects[23].Vel.Z);Check((Subjects[23].Pos-(2688,-64,0)).Length()<0.01,"subject 23 saved position");let body=CaelumBestiaryCombatActor(Subjects[23]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-001","subject 23 initialized inspection catalogue identity");}
Check(Subjects[24]!=null && Subjects[24].GetClass()=='CaelumBestiary012',"subject 24 native class");
if(Subjects[24]!=null){Console.Printf("CA825 POSITION 24 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[24].Pos.X,Subjects[24].Pos.Y,Subjects[24].Pos.Z,Subjects[24].Vel.X,Subjects[24].Vel.Y,Subjects[24].Vel.Z);Check((Subjects[24].Pos-(2944,-64,0)).Length()<0.01,"subject 24 saved position");let body=CaelumBestiaryCombatActor(Subjects[24]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-012","subject 24 initialized inspection catalogue identity");}
Check(Subjects[25]!=null && Subjects[25].GetClass()=='CaelumBestiary020',"subject 25 native class");
if(Subjects[25]!=null){Console.Printf("CA825 POSITION 25 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[25].Pos.X,Subjects[25].Pos.Y,Subjects[25].Pos.Z,Subjects[25].Vel.X,Subjects[25].Vel.Y,Subjects[25].Vel.Z);Check((Subjects[25].Pos-(2688,256,0)).Length()<0.01,"subject 25 saved position");let body=CaelumBestiaryCombatActor(Subjects[25]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-020","subject 25 initialized inspection catalogue identity");}
Check(Subjects[26]!=null && Subjects[26].GetClass()=='CaelumBestiary041',"subject 26 native class");
if(Subjects[26]!=null){Console.Printf("CA825 POSITION 26 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[26].Pos.X,Subjects[26].Pos.Y,Subjects[26].Pos.Z,Subjects[26].Vel.X,Subjects[26].Vel.Y,Subjects[26].Vel.Z);Check((Subjects[26].Pos-(2944,256,0)).Length()<0.01,"subject 26 saved position");let body=CaelumBestiaryCombatActor(Subjects[26]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-041","subject 26 initialized inspection catalogue identity");}
Check(Subjects[27]!=null && Subjects[27].GetClass()=='CaelumBestiary057',"subject 27 native class");
if(Subjects[27]!=null){Console.Printf("CA825 POSITION 27 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[27].Pos.X,Subjects[27].Pos.Y,Subjects[27].Pos.Z,Subjects[27].Vel.X,Subjects[27].Vel.Y,Subjects[27].Vel.Z);Check((Subjects[27].Pos-(2688,576,0)).Length()<0.01,"subject 27 saved position");let body=CaelumBestiaryCombatActor(Subjects[27]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-057","subject 27 initialized inspection catalogue identity");}
Check(Subjects[28]!=null && Subjects[28].GetClass()=='CaelumBestiary001',"subject 28 native class");
if(Subjects[28]!=null){Console.Printf("CA825 POSITION 28 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[28].Pos.X,Subjects[28].Pos.Y,Subjects[28].Pos.Z,Subjects[28].Vel.X,Subjects[28].Vel.Y,Subjects[28].Vel.Z);Check((Subjects[28].Pos-(3200,-64,0)).Length()<0.01,"subject 28 saved position");let body=CaelumBestiaryCombatActor(Subjects[28]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-001","subject 28 initialized inspection catalogue identity");}
Check(Subjects[29]!=null && Subjects[29].GetClass()=='CaelumBestiary008',"subject 29 native class");
if(Subjects[29]!=null){Console.Printf("CA825 POSITION 29 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[29].Pos.X,Subjects[29].Pos.Y,Subjects[29].Pos.Z,Subjects[29].Vel.X,Subjects[29].Vel.Y,Subjects[29].Vel.Z);Check((Subjects[29].Pos-(3456,-64,0)).Length()<0.01,"subject 29 saved position");let body=CaelumBestiaryCombatActor(Subjects[29]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-008","subject 29 initialized inspection catalogue identity");}
Check(Subjects[30]!=null && Subjects[30].GetClass()=='CaelumBestiary013',"subject 30 native class");
if(Subjects[30]!=null){Console.Printf("CA825 POSITION 30 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[30].Pos.X,Subjects[30].Pos.Y,Subjects[30].Pos.Z,Subjects[30].Vel.X,Subjects[30].Vel.Y,Subjects[30].Vel.Z);Check((Subjects[30].Pos-(3200,256,0)).Length()<0.01,"subject 30 saved position");let body=CaelumBestiaryCombatActor(Subjects[30]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-013","subject 30 initialized inspection catalogue identity");}
Check(Subjects[31]!=null && Subjects[31].GetClass()=='CaelumBestiary014',"subject 31 native class");
if(Subjects[31]!=null){Console.Printf("CA825 POSITION 31 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[31].Pos.X,Subjects[31].Pos.Y,Subjects[31].Pos.Z,Subjects[31].Vel.X,Subjects[31].Vel.Y,Subjects[31].Vel.Z);Check((Subjects[31].Pos-(3456,256,0)).Length()<0.01,"subject 31 saved position");let body=CaelumBestiaryCombatActor(Subjects[31]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-014","subject 31 initialized inspection catalogue identity");}
Check(Subjects[32]!=null && Subjects[32].GetClass()=='CaelumBestiary001',"subject 32 native class");
if(Subjects[32]!=null){Console.Printf("CA825 POSITION 32 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[32].Pos.X,Subjects[32].Pos.Y,Subjects[32].Pos.Z,Subjects[32].Vel.X,Subjects[32].Vel.Y,Subjects[32].Vel.Z);Check((Subjects[32].Pos-(3755,-64,0)).Length()<0.01,"subject 32 saved position");let body=CaelumBestiaryCombatActor(Subjects[32]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-001","subject 32 initialized inspection catalogue identity");}
Check(Subjects[33]!=null && Subjects[33].GetClass()=='CaelumBestiary021',"subject 33 native class");
if(Subjects[33]!=null){Console.Printf("CA825 POSITION 33 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[33].Pos.X,Subjects[33].Pos.Y,Subjects[33].Pos.Z,Subjects[33].Vel.X,Subjects[33].Vel.Y,Subjects[33].Vel.Z);Check((Subjects[33].Pos-(4096,-64,0)).Length()<0.01,"subject 33 saved position");let body=CaelumBestiaryCombatActor(Subjects[33]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-021","subject 33 initialized inspection catalogue identity");}
Check(Subjects[34]!=null && Subjects[34].GetClass()=='CaelumBestiary022',"subject 34 native class");
if(Subjects[34]!=null){Console.Printf("CA825 POSITION 34 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[34].Pos.X,Subjects[34].Pos.Y,Subjects[34].Pos.Z,Subjects[34].Vel.X,Subjects[34].Vel.Y,Subjects[34].Vel.Z);Check((Subjects[34].Pos-(4437,-64,0)).Length()<0.01,"subject 34 saved position");let body=CaelumBestiaryCombatActor(Subjects[34]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-022","subject 34 initialized inspection catalogue identity");}
Check(Subjects[35]!=null && Subjects[35].GetClass()=='CaelumBestiary023',"subject 35 native class");
if(Subjects[35]!=null){Console.Printf("CA825 POSITION 35 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[35].Pos.X,Subjects[35].Pos.Y,Subjects[35].Pos.Z,Subjects[35].Vel.X,Subjects[35].Vel.Y,Subjects[35].Vel.Z);Check((Subjects[35].Pos-(3755,256,0)).Length()<0.01,"subject 35 saved position");let body=CaelumBestiaryCombatActor(Subjects[35]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-023","subject 35 initialized inspection catalogue identity");}
Check(Subjects[36]!=null && Subjects[36].GetClass()=='CaelumBestiary024',"subject 36 native class");
if(Subjects[36]!=null){Console.Printf("CA825 POSITION 36 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[36].Pos.X,Subjects[36].Pos.Y,Subjects[36].Pos.Z,Subjects[36].Vel.X,Subjects[36].Vel.Y,Subjects[36].Vel.Z);Check((Subjects[36].Pos-(4096,256,0)).Length()<0.01,"subject 36 saved position");let body=CaelumBestiaryCombatActor(Subjects[36]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-024","subject 36 initialized inspection catalogue identity");}
Check(Subjects[37]!=null && Subjects[37].GetClass()=='CaelumBestiary025',"subject 37 native class");
if(Subjects[37]!=null){Console.Printf("CA825 POSITION 37 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[37].Pos.X,Subjects[37].Pos.Y,Subjects[37].Pos.Z,Subjects[37].Vel.X,Subjects[37].Vel.Y,Subjects[37].Vel.Z);Check((Subjects[37].Pos-(4437,256,0)).Length()<0.01,"subject 37 saved position");let body=CaelumBestiaryCombatActor(Subjects[37]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-025","subject 37 initialized inspection catalogue identity");}
Check(Subjects[38]!=null && Subjects[38].GetClass()=='CaelumBestiary026',"subject 38 native class");
if(Subjects[38]!=null){Console.Printf("CA825 POSITION 38 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[38].Pos.X,Subjects[38].Pos.Y,Subjects[38].Pos.Z,Subjects[38].Vel.X,Subjects[38].Vel.Y,Subjects[38].Vel.Z);Check((Subjects[38].Pos-(3755,576,0)).Length()<0.01,"subject 38 saved position");let body=CaelumBestiaryCombatActor(Subjects[38]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-026","subject 38 initialized inspection catalogue identity");}
Check(Subjects[39]!=null && Subjects[39].GetClass()=='CaelumBestiary027',"subject 39 native class");
if(Subjects[39]!=null){Console.Printf("CA825 POSITION 39 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[39].Pos.X,Subjects[39].Pos.Y,Subjects[39].Pos.Z,Subjects[39].Vel.X,Subjects[39].Vel.Y,Subjects[39].Vel.Z);Check((Subjects[39].Pos-(4096,576,0)).Length()<0.01,"subject 39 saved position");let body=CaelumBestiaryCombatActor(Subjects[39]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-027","subject 39 initialized inspection catalogue identity");}
Check(Subjects[40]!=null && Subjects[40].GetClass()=='CaelumBestiary034',"subject 40 native class");
if(Subjects[40]!=null){Console.Printf("CA825 POSITION 40 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[40].Pos.X,Subjects[40].Pos.Y,Subjects[40].Pos.Z,Subjects[40].Vel.X,Subjects[40].Vel.Y,Subjects[40].Vel.Z);Check((Subjects[40].Pos-(4437,576,0)).Length()<0.01,"subject 40 saved position");let body=CaelumBestiaryCombatActor(Subjects[40]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-034","subject 40 initialized inspection catalogue identity");}
Check(Subjects[41]!=null && Subjects[41].GetClass()=='CaelumBestiary036',"subject 41 native class");
if(Subjects[41]!=null){Console.Printf("CA825 POSITION 41 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[41].Pos.X,Subjects[41].Pos.Y,Subjects[41].Pos.Z,Subjects[41].Vel.X,Subjects[41].Vel.Y,Subjects[41].Vel.Z);Check((Subjects[41].Pos-(3755,896,0)).Length()<0.01,"subject 41 saved position");let body=CaelumBestiaryCombatActor(Subjects[41]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-036","subject 41 initialized inspection catalogue identity");}
Check(Subjects[42]!=null && Subjects[42].GetClass()=='CaelumBestiary042',"subject 42 native class");
if(Subjects[42]!=null){Console.Printf("CA825 POSITION 42 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[42].Pos.X,Subjects[42].Pos.Y,Subjects[42].Pos.Z,Subjects[42].Vel.X,Subjects[42].Vel.Y,Subjects[42].Vel.Z);Check((Subjects[42].Pos-(4096,896,0)).Length()<0.01,"subject 42 saved position");let body=CaelumBestiaryCombatActor(Subjects[42]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-042","subject 42 initialized inspection catalogue identity");}
Check(Subjects[43]!=null && Subjects[43].GetClass()=='CaelumBestiary002',"subject 43 native class");
if(Subjects[43]!=null){Console.Printf("CA825 POSITION 43 xyz=(%.5f,%.5f,%.5f) velocity=(%.5f,%.5f,%.5f)",Subjects[43].Pos.X,Subjects[43].Pos.Y,Subjects[43].Pos.Z,Subjects[43].Vel.X,Subjects[43].Vel.Y,Subjects[43].Vel.Z);Check((Subjects[43].Pos-(4736,-64,0)).Length()<0.01,"subject 43 saved position");let body=CaelumBestiaryCombatActor(Subjects[43]);Check(body!=null && body.CaelumDiagnosticPassiveAI && body.bFriendly && !CaelumVisualPerception.Opponent(body,players[0].mo) && body.MandingaBirthInitialized && body.BestiaryReference()=="CA-FOLK-002","subject 43 initialized inspection catalogue identity");}
        Console.Printf("CA825 COMPLETE failures=%d", Failures);
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        if (level.MapName != "CA825G") return;
        if (e.Name == "ca825_prepare")
        {
            if (Subjects.Size() != 0) return;
            CaelumPlayer(players[0].mo).CharacterCreationComplete = true;
            CaelumPlayer(players[0].mo).CreationWizardOpen = false;
            players[0].mo.bNOTARGET=true;players[0].mo.bInvulnerable=true;
            ObserverNoiseSerial=CaelumPlayer(players[0].mo).MovementNoiseEventSerial;
            {let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary001',(128,-64,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary031',(384,-64,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary032',(128,256,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary001',(640,-64,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary017',(896,-64,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary027',(640,256,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary031',(896,256,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary037',(640,576,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary001',(1152,-64,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary031',(1408,-64,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary032',(1152,256,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary001',(1664,-64,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary015',(1920,-64,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary016',(1664,256,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary027',(1920,256,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary031',(1664,576,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary033',(1920,576,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary001',(2176,-64,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary002',(2432,-64,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary038',(2176,256,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary039',(2432,256,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary040',(2176,576,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary056',(2432,576,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary001',(2688,-64,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary012',(2944,-64,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary020',(2688,256,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary041',(2944,256,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary057',(2688,576,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary001',(3200,-64,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary008',(3456,-64,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary013',(3200,256,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary014',(3456,256,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary001',(3755,-64,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary021',(4096,-64,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary022',(4437,-64,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary023',(3755,256,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary024',(4096,256,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary025',(4437,256,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary026',(3755,576,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary027',(4096,576,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary034',(4437,576,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary036',(3755,896,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary042',(4096,896,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
{let item=CaelumBestiaryCombatActor(Actor.Spawn('CaelumBestiary002',(4736,-64,0),NO_REPLACE));if(item!=null){item.CaelumDiagnosticPassiveAI=true;item.bFriendly=true;item.Angle=270;}Subjects.Push(item);}
            View = CA825Camera(Actor.Spawn('CA825Camera', (0,0,0), NO_REPLACE));
            ConfigureView(0);
        }
        if (e.Name == "ca825_view") ConfigureView(e.Args[0]);
        if (e.Name == "ca825_verify") Verify();
        if (e.Name == "ca825_motion_start")
        {
            MotionSnapshot.Clear();
            for (int index=0; index<Subjects.Size(); index++) MotionSnapshot.Push(Subjects[index].CurState);
        }
        if (e.Name == "ca825_motion_verify")
        {
            Check(MotionSnapshot.Size() == Subjects.Size(), "animation snapshot registry");
            for (int index=0; index<Subjects.Size(); index++)
                Check(Subjects[index].CurState != MotionSnapshot[index] && IsIdleState(Subjects[index],MotionSnapshot[index]) && IsIdleState(Subjects[index],Subjects[index].CurState), String.Format("subject %d native idle advancement", index));
            Console.Printf("CA825 COMPLETE failures=%d", Failures);
        }
        if (e.Name == "ca825_walk_start")
        {
            ConfigureView(1);
            WalkStart = players[0].mo.Pos;
        }
        if (e.Name == "ca825_walk_verify")
        {
            let user=players[0].mo;
            Console.Printf("CA825 WALK start=(%.3f,%.3f,%.3f) end=(%.3f,%.3f,%.3f) angle=%.3f",WalkStart.X,WalkStart.Y,WalkStart.Z,user.Pos.X,user.Pos.Y,user.Pos.Z,user.Angle);
            Check((user.Pos-WalkStart).Length() > user.Radius, "native player movement in gallery");
            Check(abs(user.Pos.Z-user.floorz)<0.01, "player remains on the walkable floor");
            Console.Printf("CA825 COMPLETE failures=%d", Failures);
        }
        if (e.Name == "ca825_cross_start")
        {
            // Recorrido diagnóstico de las 8 uniones entre parcelas.
            players[0].mo.SetOrigin((128,-384,0), false);
            players[0].mo.Angle = 90;
            players[0].mo.Vel = (0,0,0);
            Console.Printf("CA825 CROSS START pos=(%.3f,%.3f,%.3f) angle=%.3f",players[0].mo.Pos.X,players[0].mo.Pos.Y,players[0].mo.Pos.Z,players[0].mo.Angle);
        }
        if (e.Name == "ca825_cross_verify")
        {
            let user=players[0].mo;
            Console.Printf("CA825 CROSS END pos=(%.3f,%.3f,%.3f) angle=%.3f",user.Pos.X,user.Pos.Y,user.Pos.Z,user.Angle);
            Check(user.Pos.X > 4608, "native movement crosses all 8 regional boundaries");
            Check(abs(user.Pos.Z-user.floorz)<0.01, "regional crossing stays on the floor");
            Console.Printf("CA825 COMPLETE failures=%d", Failures);
        }
    }
}
