// #323: aislar el movimiento nativo de techos sin cambiar el comportamiento de trampas.
class CA323Probe : CA282Probe
{
    CaelumCrusherTrap Trap;
    Array<double> Original;
    Array<bool> Changed;
    bool Observing;
    bool Baseline(){return CVar.GetCVar("ca323_baseline").GetBool();}
    CaelumCrusherTrap FindTrap(int tid)
    {return CaelumCrusherTrap(ActorIterator.Create(tid,"CaelumCrusherTrap").Next());}
    override void WorldLoaded(WorldEvent e)
    {
        // Sólo el fixture: impedir ataques/pisadas de otros actores mientras se mide la geometría.
        let it=ThinkerIterator.Create("CaelumCombatActor");CaelumCombatActor body;
        while((body=CaelumCombatActor(it.Next()))!=null)
        {body.CaelumDiagnosticPassiveAI=true;body.bSolid=false;body.bNoGravity=true;body.Vel=(0,0,0);}
        Observing=false;
    }
    void PrepareUser()
    {
        User=CaelumPlayer(players[consoleplayer].mo);User.bInvulnerable=true;User.bNoTarget=true;
        User.CurrentHunger=User.CurrentThirst=User.CurrentSleep=User.CurrentLucidity=100;
        User.SetOrigin((0,0,0),false);User.Vel=(0,0,0);
    }
    void Snapshot()
    {
        Original.Clear();Changed.Clear();
        for(int n=0;n<level.sectors.Size();n++)
        {Original.Push(level.sectors[n].ceilingplane.ZatPoint((0,0)));Changed.Push(false);}
        Observing=true;
    }
    override void WorldTick()
    {
        if(!Observing || level.MapName!="MAP02")return;
        for(int n=0;n<level.sectors.Size();n++)
            if(Abs(level.sectors[n].ceilingplane.ZatPoint((0,0))-Original[n])>0.00001)Changed[n]=true;
    }
    void Geometry()
    {
        int malformed=0;
        for(int n=0;n<CA323Data.COUNT;n++)
        {
            let trap=FindTrap(CA323Data.Tid(n));Check(trap!=null,"mapped crusher exists");if(trap==null)continue;
            double area=CaelumCrushingDamage.SectorArea(trap.CurSector);
            bool broken=Abs(area-CA323Data.AREA)>0.00001;if(broken)malformed++;
            Check(broken==(Baseline() && trap.tid==CA323Data.WEST_TID),"authored panel area");
            Console.Printf("CA323 GEOMETRY tid%d x%.0f y%.0f sector%d areaM2%.3f ceiling%.3f",trap.tid,trap.Pos.X,trap.Pos.Y,trap.CurSector.Index(),area,trap.CurSector.ceilingplane.ZatPoint(trap.Pos.XY));
        }
        Check(malformed==(Baseline()?1:0),"only expected baseline panel is malformed");
    }
    void Place()
    {
        Trap=FindTrap(CA323Data.WEST_TID);
        User.SetOrigin(Trap.Pos+(-176,0,-0.5),false);User.Vel=(0,0,0);User.Angle=0;User.Pitch=0;
        Snapshot();
    }
    void Moving()
    {
        Check(Trap!=null && Trap.Spent && Trap.ActivationCount==1 && Trap.IsMoving(),"single native activation moves ceiling");
        if(Trap==null)return;
        Check(Trap.Panels.Size()==1 && Trap.Panels[0]==Trap.CurSector,"one owned native panel");
    }
    void Neighbors()
    {
        int changes=0;bool unrelated=false;
        for(int n=0;n<Changed.Size();n++)if(Changed[n])
        {changes++;if(level.sectors[n]!=Trap.CurSector)unrelated=true;}
        Check(changes==1 && !unrelated,"no unrelated sector moves");
        double area=CaelumCrushingDamage.SectorArea(Trap.CurSector);
        Check(Baseline() && Trap.tid==CA323Data.WEST_TID ? area>CA323Data.AREA : Abs(area-CA323Data.AREA)<0.00001,"moved footprint matches expected revision");
        Console.Printf("CA323 MOVED tid%d sector%d areaM2%.3f changedSectors%d playerX%.3f playerY%.3f",Trap.tid,Trap.CurSector.Index(),area,changes,User.Pos.X,User.Pos.Y);
    }
    void Finished()
    {
        Check(Trap.Spent && Trap.MovementFinished && !Trap.IsMoving(),"native cycle finishes");
        Check(Abs(Trap.CurSector.ceilingplane.ZatPoint(Trap.Pos.XY)-CA323Data.CEILING)<0.00001,"ceiling returns to initial height");
        Check(!Trap.Release() && Trap.ActivationCount==1,"spent plate cannot retrigger");
        if(Observing)Neighbors();Observing=false;
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        Super.NetworkProcess(e);
        if(e.Name=="c323_setup")PrepareUser();
        if(e.Name=="c323_geometry")Geometry();
        if(e.Name=="c323_place")Place();
        if(e.Name=="c323_unspent")
        {Trap=FindTrap(CA323Data.WEST_TID);Check(!Trap.Spent && Trap.ActivationCount==0,"pre-trigger save retains unspent plate");}
        if(e.Name=="c323_release")
        {
            Trap=FindTrap(CA323Data.Tid(e.Args[0]));Snapshot();
            Check(Trap.Release(),"release authored native crusher");
        }
        if(e.Name=="c323_moving")Moving();
        if(e.Name=="c323_finished")Finished();
        if(e.Name=="c323_walk_check")
        {Check(Trap.Spent && Trap.ActivationCount==1,"ordinary forward input pressed plate");Neighbors();}
        if(e.Name=="c323_resume")
        {User=CaelumPlayer(players[consoleplayer].mo);Trap=FindTrap(CA323Data.WEST_TID);Observing=false;Check(Trap!=null && Trap.Spent && Trap.ActivationCount==1,"loaded active native crusher");}
        if(e.Name=="c323_manual")
        {Manual=true;Place();User.Pitch=-12;}
    }
}
