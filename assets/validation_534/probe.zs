// Lecturas nativas aisladas: no revelan líneas ni sustituyen entrada del autor.
class CA231Probe : StaticEventHandler
{
    ui int Failures,KnownBefore,HiddenBefore;
    ui Vector3 PlayerBefore;
    ui Vector2 CenterBefore;
    double FloorDesired;
    ui void Check(bool ok,String label)
    {if(!ok)Failures++;Console.Printf("CA231 %s %s",ok?"PASS":"FAIL",label);}
    ui int Known()
    {int count=0;for(int i=0;i<level.lines.Size();i++)if(level.lines[i].flags&Line.ML_MAPPED)count++;return count;}
    ui int Hidden()
    {int count=0;for(int i=0;i<level.lines.Size();i++)if(level.lines[i].flags&Line.ML_DONTDRAW)count++;return count;}
    override void ConsoleProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[consoleplayer].mo);if(u==null)return;
        if(e.Name=="c231_before")
        {
            KnownBefore=Known();HiddenBefore=Hidden();PlayerBefore=u.Pos;
            Check(KnownBefore>0 && KnownBefore<int(level.lines.Size()),"fresh-map-retains-unknown-lines");
            Console.Printf("CA231 GEOMETRY known=%d hidden=%d total=%d",KnownBefore,HiddenBefore,level.lines.Size());
        }
        if(e.Name=="c231_full")
        {
            Check(automapactive && !viewactive && CaelumCartography.Visible(u),"native-full-map-with-project-header");
            Check(!CaelumPresentation.CrosshairVisible(),"native-full-map-crosshair-guard-preserved");
            Check(Known()==KnownBefore && Hidden()==HiddenBefore,"opening-does-not-add-geometry-or-change-hidden-flags");
            Check(CaelumCartography.KnownObjective(u)=="","no-unapproved-objective-inferred-from-journal-selection");
            let clock=CaelumWorldClock(u.FindInventory("CaelumWorldClock"));
            let calendar=CaelumCalendarState(u.FindInventory("CaelumCalendarState"));
            String expected=CaelumWorldCatalogue.IsLimboMap(level.MapName)?CaelumWorldClock.FormatStamp(clock.LocalDays(),clock.LocalTics()):calendar.FormatDate(clock);
            Check(CaelumCartography.ClockText(u)==expected,"header-uses-authoritative-local-clock");
            Check(CVar.GetCVar("am_cheat").GetInt()==0 && CVar.GetCVar("am_showalllines").GetInt()==-1,"no-reveal-cheat-enabled");
        }
        if(e.Name=="c231_pan_seed")CenterBefore=level.GetAutomapPosition();
        if(e.Name=="c231_pan_check")
        {
            Vector2 now=level.GetAutomapPosition();
            Check((now-CenterBefore).Length()>0.01,"native-pan-changes-map-center");
            Check(u.Pos==PlayerBefore,"native-map-pan-does-not-move-player");
            Check(Known()==KnownBefore && Hidden()==HiddenBefore,"pan-and-zoom-do-not-reveal-geometry");
        }
        if(e.Name=="c231_overlay")
        {
            Check(automapactive && viewactive,"native-overlay-keeps-three-dimensional-view");
            Check(Known()==KnownBefore && Hidden()==HiddenBefore,"overlay-keeps-native-discovery-boundary");
        }
        if(e.Name=="c231_keys")
        {
            Check(CaelumCartography.Keys("am_togglefollow").IndexOf("F6")>=0,"hint-reads-remapped-native-map-binding");
            Check(CaelumCartography.Keys("togglemap").IndexOf("M")>=0,"hint-preserves-accepted-normal-map-toggle");
            Check(CaelumCartography.Keys("c231_unbound") == StringTable.Localize("CA_INTRO_UNBOUND",false),"empty-binding-label-has-no-invented-key");
            // Scan físico DIK_M usado por la tabla nativa, no una tecla asignada en producción.
            Check(Bindings.GetBinding(50)~=="togglemap" && AutomapBindings.GetBinding(50)=="","no-map-mark-reset-conflict");
        }
        if(e.Name=="c231_preferences")
        {
            Check(CVar.GetCVar("am_customcolors").GetBool()==false && CVar.GetCVar("am_rotate").GetInt()==1
                && CVar.GetCVar("am_textured").GetBool()==true,"project-draw-preserves-custom-native-preferences");
            Check(Known()==KnownBefore && Hidden()==HiddenBefore,"rotation-and-texturing-preserve-known-flags");
        }
        if(e.Name=="c231_floor_check")
            Check(u.health>0 && u.player.onground && Abs(u.Pos.Z-FloorDesired)<=1,"authored-floor-position-stays-supported");
        if(e.Name=="c231_clock_check")
        {
            String expected=CaelumWorldCatalogue.IsLimboMap(level.MapName)?"3 d 14:25":"03/11/1889 09:00";
            Check(CaelumCartography.ClockText(u)==expected,"distinct-limbo-and-campaign-clock-oracle");
        }
        if(e.Name=="c231_done")Console.Printf("CA231 DONE failures=%d",Failures);
        if(e.Name=="c231_snapshot")
            Console.Printf("CA231 SNAPSHOT map=%s known=%d hidden=%d x=%.6f y=%.6f z=%.6f clock=%s",level.MapName,Known(),Hidden(),u.Pos.X,u.Pos.Y,u.Pos.Z,CaelumCartography.ClockText(u));
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=="c231_clock_seed")
        {
            let clock=CaelumWorldClock.Get(u,true);clock.EnsureLocalClock();
            clock.LimboDays=3;clock.LimboDayTics=14*6300+25*105;
            let calendar=CaelumCalendarState.Get(u,true);calendar.EnsureCampaign(clock);
            calendar.SetAnchor(clock,CaelumCalendarRules.ToSerial(1889,11,3),9*6300,false);
        }
        if(e.Name!="c231_floor" || level.MapName!="MAP01")return;
        // Anclas reales de CaelumMansionFurniture; sólo el escenario busca un
        // lugar libre junto al mueble. El juego no recibe teletransportes nuevos.
        let table=CaelumDiningWorld.Find(e.Args[0]==0?105:e.Args[0]==1?101:106);
        if(table==null){Console.Printf("CA231 FAIL missing-authored-floor-anchor");return;}
        bool clear=false;
        FloorDesired=table.Pos.Z;
        for(int ring=0;ring<4 && !clear;ring++)for(int turn=0;turn<8 && !clear;turn++)
        {
            double distance=64+ring*32;
            u.SetOrigin(table.Pos+(Cos(turn*45)*distance,Sin(turn*45)*distance,0),false);
            clear=u.TestMobjLocation() && Abs(u.FloorZ-table.Pos.Z)<=1;
        }
        u.Angle=0;u.Pitch=0;u.Vel=(0,0,0);
        Console.Printf("CA231 FLOOR requested=%d collision-clear=%d x=%.6f y=%.6f z=%.6f",e.Args[0],clear,u.Pos.X,u.Pos.Y,u.Pos.Z);
    }
}
