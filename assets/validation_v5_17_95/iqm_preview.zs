// #834: comparación aislada; conserva los dueños de equipo y colisión.
class CA834Body : CaelumDomingoPilotFrames
{
    int FrozenFrame;
    bool Live;
    void Freeze(int index)
    {Live=false;FrozenFrame=index;SetModelFlag(MDL_NOINTERPOLATION);SetState(FindStateByString(String.Format("F%d",index)));tics=-1;}
    void Animate()
    {Live=true;ClearModelFlag(MDL_NOINTERPOLATION);SetState(FindStateByString(String.Format("F%d",Start(WALK))));}
    override void Tick()
    {Super.Tick();if(!Live){let desired=FindStateByString(String.Format("F%d",FrozenFrame));if(CurState!=desired)SetState(desired);tics=-1;}}
    Default {+NOINTERACTION +NOGRAVITY +NOBLOCKMAP RenderRadius 260;}
}
class CA834MD3Preview : CA834Body {}
class CA834IQMPreview : CA834Body
{
    int HiddenMask;
    transient bool BindingsReady;
    virtual bool RetainedCape(){return false;}
    void ShowModule(int slot,bool visible)
    {
        if(slot<0 || slot>=7)return;
        CA834Data.Show(self,slot,visible,RetainedCape());
        if(visible)HiddenMask&=~(1<<slot);else HiddenMask|=1<<slot;
    }
    override void Tick()
    {
        Super.Tick();
        // Los selectores guardados reconstruyen los overrides al cargar.
        if(!BindingsReady){for(int slot=0;slot<7;slot++)ShowModule(slot,(HiddenMask&(1<<slot))==0);BindingsReady=true;}
    }
}
class CA834HybridPreview : CA834IQMPreview
{override bool RetainedCape(){return true;}}
class CA834Camera : Actor
{Default {CameraHeight 0;Height 0;Radius 0;+NOINTERACTION +NOGRAVITY} States {Spawn:TNT1 A -1;Stop;}}
class CA834PreviewEvents : EventHandler
{
    CA834MD3Preview Reference;
    CA834IQMPreview Candidate,Hybrid;
    CA834Camera Camera;
    State Previous;
    int Pose,Rotation,Selected,Failures;
    override bool InputProcess(InputEvent e){return true;}
    void Check(bool okay,String label)
    {if(!okay)Failures++;Console.Printf("CA834 %s %s",okay?"PASS":"FAIL",label);}
    CA834IQMPreview Active(){if(Selected==2)return Hybrid;return Candidate;}
    void View()
    {
        vector3 focus=CA834Data.Focus(Pose);double distance=CA834Data.Distance(Pose),direction=270+Rotation*45;
        Camera.SetOrigin((focus.X+distance*Cos(direction),focus.Y+distance*Sin(direction),focus.Z/level.pixelstretch),false);
        Camera.Angle=direction+180;Camera.Pitch=0;Camera.ClearInterpolation();
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name.Left(6)!="ca834_")return;
        if(e.Name=="ca834_prepare")
        {
            if(Reference==null)Reference=CA834MD3Preview(Actor.Spawn('CA834MD3Preview',(0,0,0),NO_REPLACE));
            if(Candidate==null)Candidate=CA834IQMPreview(Actor.Spawn('CA834IQMPreview',(0,0,0),NO_REPLACE));
            if(Hybrid==null)Hybrid=CA834IQMPreview(Actor.Spawn('CA834HybridPreview',(0,0,0),NO_REPLACE));
            if(Camera==null)Camera=CA834Camera(Actor.Spawn('CA834Camera',(0,0,0),NO_REPLACE));
            let user=CaelumPlayer(players[0].mo);user.CharacterCreationComplete=true;user.CreationWizardOpen=false;user.bInvisible=true;
            Reference.Freeze(0);Candidate.Freeze(0);Hybrid.Freeze(0);Reference.bInvisible=false;Candidate.bInvisible=true;Hybrid.bInvisible=true;Selected=0;Pose=0;Rotation=0;
            players[0].camera=Camera;View();Check(Reference!=null && Candidate!=null && Hybrid!=null && Camera!=null,"comparison references created");return;
        }
        if(e.Name=="ca834_select")
        {Selected=Clamp(e.Args[0],0,2);Reference.bInvisible=Selected!=0;Candidate.bInvisible=Selected!=1;Hybrid.bInvisible=Selected!=2;Check(Reference.bInvisible==(Selected!=0) && Candidate.bInvisible==(Selected!=1) && Hybrid.bInvisible==(Selected!=2),"one selected format visible");return;}
        if(e.Name=="ca834_pose")
        {
            Pose=Clamp(e.Args[0],0,23);int frame=CA834Body.Start(Pose)+CA834Body.Count(Pose)/2;
            Reference.Freeze(frame);Candidate.Freeze(frame);Hybrid.Freeze(frame);View();
            Check(Reference.CurState==Reference.FindStateByString(String.Format("F%d",frame)) && Candidate.CurState==Candidate.FindStateByString(String.Format("F%d",frame)) && Hybrid.CurState==Hybrid.FindStateByString(String.Format("F%d",frame)),"all formats use the same registered sample");return;
        }
        if(e.Name=="ca834_rotate"){Rotation=Clamp(e.Args[0],0,7);View();return;}
        if(e.Name=="ca834_module")
        {let body=Active();body.ShowModule(e.Args[0],e.Args[1]!=0);Check(((body.HiddenMask&(1<<e.Args[0]))==0)==(e.Args[1]!=0),"independent module visibility selected");return;}
        if(e.Name=="ca834_restore")
        {let body=Active();for(int i=0;i<7;i++)body.ShowModule(i,true);Check(body.HiddenMask==0,"all candidate modules restored");return;}
        if(e.Name=="ca834_animate"){let body=Active();body.Animate();Previous=body.CurState;return;}
        if(e.Name=="ca834_motion"){Check(Active().CurState!=Previous,"skeletal walking frame advances");return;}
        if(e.Name=="ca834_saved")
        {
            Reference.Freeze(0);Candidate.Freeze(0);Hybrid.Freeze(0);Pose=0;Rotation=0;View();
            Candidate.ShowModule(4,false);Candidate.ShowModule(6,false);Hybrid.ShowModule(4,false);Hybrid.ShowModule(6,false);return;
        }
        if(e.Name=="ca834_verify")
        {
            Check(Reference!=null && Candidate!=null && Hybrid!=null && Candidate!=Hybrid && Actor(Reference)!=Actor(Candidate) && players[0].camera==Camera,"saved references and camera retained");
            Check(Candidate.HiddenMask==((1<<4)|(1<<6)),"saved hair and shield selections retained");
            Check(Hybrid.HiddenMask==((1<<4)|(1<<6)),"saved hybrid hair and shield selections retained");
            Check(!Candidate.Live && !Hybrid.Live && Candidate.CurState==Candidate.FindState('F0') && Hybrid.CurState==Hybrid.FindState('F0'),"saved frozen frames retained");
            Check(Selected==e.Args[0] && Reference.bInvisible && Candidate.bInvisible==(Selected!=1) && Hybrid.bInvisible==(Selected!=2),"saved format selection retained");
            Check(Candidate.bNOINTERACTION && Candidate.bNOBLOCKMAP && Hybrid.bNOINTERACTION && Hybrid.bNOBLOCKMAP,"diagnostic bodies remain noninteractive");
            Console.Printf("CA834 COMPLETE failures=%d",Failures);
        }
    }
}
