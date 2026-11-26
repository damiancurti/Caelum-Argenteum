// #458: inspección aislada de módulos; no reemplaza cuerpos de campaña.
class CA458PreviewBody : CaelumDomingoPilotFrames
{
    int FrozenFrame;
    bool Live;
    void Freeze(int frame)
    {Live=false;FrozenFrame=frame;SetModelFlag(MDL_NOINTERPOLATION);SetState(FindStateByString(String.Format("F%d",frame)));tics=-1;}
    void Animate(int pose)
    {Live=true;ClearModelFlag(MDL_NOINTERPOLATION);SetState(FindStateByString(String.Format("F%d",Start(pose))));}
    override void Tick()
    {
        Super.Tick();
        if(!Live){let desired=FindStateByString(String.Format("F%d",FrozenFrame));if(CurState!=desired)SetState(desired);tics=-1;}
    }
    Default {+NOINTERACTION +NOGRAVITY +NOBLOCKMAP RenderRadius 240;}
}
class CA458LegacyPreview : CA458PreviewBody {}
class CA458ModularPreview : CA458PreviewBody
{
    int HiddenMask;
    void ShowModule(int slot,bool visible)
    {
        static const name files[]={'clothing.md3','armor.md3','cape.md3','face.md3','hair.md3','weapon.md3','shield.md3'};
        if(slot<0 || slot>=7)return;
        A_ChangeModel('None',slot,"models/caelum/characters/domingo",files[slot],slot,
            "models/caelum/characters/domingo",'domingo_skin.png',visible?0:CMDL_HIDEMODEL);
        if(visible)HiddenMask&=~(1<<slot);else HiddenMask|=1<<slot;
    }
}
class CA458Camera : Actor
{Default {CameraHeight 0;Height 0;Radius 0;+NOINTERACTION +NOGRAVITY} States {Spawn:TNT1 A -1;Stop;}}
class CA458PreviewEvents : EventHandler
{
    CA458LegacyPreview Legacy;
    CA458ModularPreview Modular;
    CA458Camera Camera;
    State Previous;
    int Failures;
    void Check(bool okay,String label)
    {if(!okay)Failures++;Console.Printf("CA458 %s %s",okay?"PASS":"FAIL",label);}
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name.Left(6)!="ca458_")return;
        if(e.Name=="ca458_prepare")
        {
            if(Legacy==null)Legacy=CA458LegacyPreview(Actor.Spawn('CA458LegacyPreview',(0,0,0),NO_REPLACE));
            if(Modular==null)Modular=CA458ModularPreview(Actor.Spawn('CA458ModularPreview',(0,0,0),NO_REPLACE));
            if(Camera==null)Camera=CA458Camera(Actor.Spawn('CA458Camera',(260,-260,130),NO_REPLACE));
            Camera.Angle=135;Camera.Pitch=7;Camera.ClearInterpolation();
            Legacy.Freeze(0);Modular.Freeze(0);Modular.bInvisible=true;Legacy.bInvisible=false;
            players[0].camera=Camera;players[0].mo.bInvisible=true;return;
        }
        if(e.Name=="ca458_select"){Legacy.bInvisible=e.Args[0]!=0;Modular.bInvisible=e.Args[0]==0;return;}
        if(e.Name=="ca458_module"){Modular.ShowModule(e.Args[0],e.Args[1]!=0);return;}
        if(e.Name=="ca458_restore")
        {for(int slot=0;slot<7;slot++)Modular.ShowModule(slot,true);Check(Modular.HiddenMask==0,"all module selections restored");return;}
        if(e.Name=="ca458_animate"){Modular.Animate(CaelumDomingoPilotFrames.WALK);Previous=Modular.CurState;return;}
        if(e.Name=="ca458_motion"){Check(Modular.CurState!=Previous,"native walking state advances");return;}
        if(e.Name=="ca458_freeze"){Modular.Freeze(0);return;}
        if(e.Name=="ca458_verify")
        {
            int count=0;let iterator=ThinkerIterator.Create('CA458PreviewBody');while(iterator.Next()!=null)count++;
            Check(count==2 && Legacy!=null && Modular!=null && players[0].camera==Camera,"exactly two saved preview bodies and camera");
            Check(Modular.HiddenMask==((1<<4)|(1<<6)),"hair/shield module selection retained");
            Check(!Modular.Live && Modular.CurState==Modular.FindState('F0'),"saved frozen frame retained");
            Console.Printf("CA458 COMPLETE failures=%d",Failures);
        }
    }
}
