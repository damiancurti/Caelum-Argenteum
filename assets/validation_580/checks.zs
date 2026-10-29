// #414: laboratorio privado; estas magnitudes no calibran el juego.
class CA414Checks : EventHandler
{
    Sector Models[3];
    Line Gate;
    int Revision;
    bool Open;
    int Passed, Failed;
    double StoppedA, StoppedB;

    void Check(bool ok, String label)
    { if(ok)Passed++;else Failed++;Console.Printf("CA414 %s %s",ok?"PASS":"FAIL",label); }
    void Result()
    { Console.Printf("CA414 RESULT passed=%d failed=%d map=%s",Passed,Failed,level.MapName); }
    double Height(int index)
    { return Models[index]!=null ? Models[index].CenterCeiling() : -1; }
    void Report()
    { Console.Printf("CA414 LEVEL left=%.3f right=%.3f isolated=%.3f total=%.3f gate=%d revision=%d",
        Height(0),Height(1),Height(2),(Height(0)+Height(1))*CA414Data.AREA,Open,Revision); }

    override void WorldLoaded(WorldEvent e)
    {
        // Un solo recorrido de los ocho sectores de la sala al inicializar.
        if(Revision!=0)return;
        for(int i=0;i<level.Sectors.Size();i++)
        {
            let sector=level.Sectors[i];int id=sector.GetUDMFInt('user_ca414_id');
            if(id>=101 && id<=103)Models[id-101]=sector;
        }
        let it=level.CreateLineIdIterator(CA414Data.GATE);int index=it.Next();
        if(index>=0)Gate=level.Lines[index];
        if(Models[0]!=null && Models[1]!=null && Models[2]!=null && Gate!=null)Revision=1;
    }
    void SetGate(bool value)
    {
        if(Revision!=1)return;
        Open=value;
        if(value)Gate.flags &= ~(Line.ML_BLOCKING|Line.ML_BLOCKSIGHT);
        else Gate.flags |= Line.ML_BLOCKING|Line.ML_BLOCKSIGHT;
        for(int i=0;i<2;i++)if(Gate.sidedef[i]!=null)
            Gate.sidedef[i].SetTexture(Side.mid,TexMan.CheckForTexture(value?"-":"CMST01",TexMan.Type_Wall));
        StoppedA=Height(0);StoppedB=Height(1);
        Report();
    }
    override void WorldTick()
    {
        if(Revision!=1 || !Open)return;
        double a=Height(0),b=Height(1);
        double step=Min(CA414Data.STEP,Abs(a-b)*0.5);
        if(step<=0)return;
        int direction=a>b?-1:1;
        // MoveCeiling actualiza el volumen 3D y sus sectores adjuntos nativamente.
        Models[0].MoveCeiling(step,Models[0].ceilingplane.PointToDist((0,0),a+step*direction),-1,direction,false);
        Models[1].MoveCeiling(step,Models[1].ceilingplane.PointToDist((0,0),b-step*direction),-1,-direction,false);
    }
    void Prepare(CaelumPlayer u)
    {
        u.bInvulnerable=true;u.CreationWizardOpen=false;
        u.DebugAttributesAt100=true;u.ApplyCharacterProfile();
        Console.Printf("CA414 SETTINGS pause=%d render=%d volume=%.3f",
            CVar.GetCVar('i_pauseinbackground').GetBool(),CVar.GetCVar('vid_activeinbackground').GetBool(),
            CVar.GetCVar('snd_mastervolume').GetFloat());
    }
    void Conserved()
    {
        Check(Abs(Height(0)+Height(1)-224)<0.00001,"connected pair conserves volume");
        Check(Height(2)==64,"isolated water is unchanged");
    }
    void Boundary(CaelumPlayer u,bool shouldCross)
    {
        vector3 before=u.Pos;
        u.SetOrigin((224,128,0),false);u.Vel=(0,0,0);
        Check(u.TryMove((256,128),0)==shouldCross,shouldCross?"native body crosses open boundary":"native body cannot cross closed boundary");
        u.SetOrigin(before,false);u.Vel=(0,0,0);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Player<0 || e.Player>=MAXPLAYERS)return;
        let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca414_initial')
        {
            Prepare(u);Check(Revision==1,"native control sectors located by stable IDs");
            Check(Height(0)==192 && Height(1)==32 && Height(2)==64,"authored initial levels");
            Check(!Open && (Gate.flags&Line.ML_BLOCKING)!=0,"closed gate blocks boundary");
            Check(u.WaterLevel==0,"observation walkway stays dry");Boundary(u,false);Conserved();Report();Result();
        }
        else if(e.Name=='ca414_open')SetGate(true);
        else if(e.Name=='ca414_close')SetGate(false);
        else if(e.Name=='ca414_partial')
        {Check(Height(0)<192 && Height(0)>112 && Height(1)>32 && Height(1)<112,"intermediate levels persist");Conserved();Report();Result();}
        else if(e.Name=='ca414_stopped')
        {Check(!Open && Height(0)==StoppedA && Height(1)==StoppedB,"closed gate stops transfer including save reload");Conserved();Result();}
        else if(e.Name=='ca414_final')
        {Check(Height(0)==112 && Height(1)==112,"native water surfaces reach equal level");Check(Open && (Gate.flags&Line.ML_BLOCKING)==0,"open gate permits boundary");Boundary(u,true);Conserved();Report();Result();}
        else if(e.Name=='ca414_left' || e.Name=='ca414_right')
        {u.bNoGravity=false;u.SetOrigin((e.Name=='ca414_left'?128:384,128,0),false);u.Vel=(0,0,0);u.CurrentAir=u.DerivedStats.MaximumAir;}
        else if(e.Name=='ca414_dry') {u.bNoGravity=false;u.SetOrigin((128,320,192),false);u.Vel=(0,0,0);}
        else if(e.Name=='ca414_wet')
        {
            Check(u.WaterLevel==3,"moved volume drives native full immersion");
            let thermal=CaelumThermalBody.Get(u,true);
            Check(CaelumThermalEnvironment.SampleWater(u,thermal,20)==1,"thermal sampling follows native moved surface");
            Check(CaelumRestSafety.BlockReason(u)=="CA_REST_GROUND","submerged character cannot start ordinary rest");
            Console.Printf("CA414 QUALITY current_source=%d expected_control=%d",CaelumWaterQuality.Source(u),Models[0].GetUDMFInt('user_ca_water_quality'));
            Result();
        }
        else if(e.Name=='ca414_drycheck')
        {
            Check(u.WaterLevel==0,"leaving water clears native immersion");
            let thermal=CaelumThermalBody.Get(u,true);
            Check(CaelumThermalEnvironment.SampleWater(u,thermal,20)==0,"leaving water clears thermal wet rows");Result();
        }
        else if(e.Name=='ca414_report'){Report();Result();}
        else if(e.Name=='ca414_view'){u.bNoGravity=true;u.SetOrigin((256,300,256),false);u.Angle=270;u.Pitch=55;u.Vel=(0,0,0);}
        else if(e.Name=='ca414_help')Console.Printf("#414 PRUEBA TECNICA: F1 abrir, F2 cerrar, F3 deposito izquierdo, F4 derecho, F5 pasarela seca, F6 niveles, F7 vista general. Guardado/carga por Escape. No cambia mapas de campana.");
    }
}
