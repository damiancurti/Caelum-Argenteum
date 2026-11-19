// #829: visor aislado; los selectores no representan equipo de campaña.
class CA829WardrobePreview : CaelumDomingoPilotFrames
{
    int BodyKind,HeadKind,HandKind,FootKind,HiddenMask,FrozenFrame;
    bool Live;
    transient bool BindingsReady;
    void Bind(int slot,name file,String modelPath,String skinPath,name skin,bool visible)
    {
        A_ChangeModel('None',slot,modelPath,file,slot,skinPath,skin,visible?0:CMDL_HIDEMODEL);
        if(visible)HiddenMask&=~(1<<slot);else HiddenMask|=1<<slot;
    }
    void Apply()
    {
        String original="models/caelum/characters/domingo";
        String worn="models/caelum/characters/worn";
        int hidden=CA829ViewData.Hidden(BodyKind,HeadKind,HandKind,FootKind);
        Bind(0,'face.md3',original,original,'domingo_skin.png',true);
        Bind(1,'hair.md3',original,original,'domingo_skin.png',(hidden&(1<<1))==0);
        Bind(2,'hair_lower.md3',worn,original,'domingo_skin.png',(hidden&(1<<2))==0);
        Bind(3,'base_core.md3',worn,original,'domingo_skin.png',(hidden&(1<<3))==0);
        Bind(4,'base_arms.md3',worn,original,'domingo_skin.png',(hidden&(1<<4))==0);
        Bind(5,'base_neck.md3',worn,original,'domingo_skin.png',true);
        Bind(6,'base_feet.md3',worn,original,'domingo_skin.png',(hidden&(1<<6))==0);
        Bind(7,'left_hand.md3',original,original,'domingo_skin.png',(hidden&(1<<7))==0);
        Bind(8,'right_hand.md3',original,original,'domingo_skin.png',(hidden&(1<<8))==0);
        static const name bodies[]={'F.md3','FW.md3','CS.md3','CE.md3','CW.md3','RS.md3','RE.md3','RW.md3','PS.md3','PE.md3','PW.md3'};
        static const name bodySkins[]={'f.png','fw.png','cs.png','ce.png','cw.png','rs.png','re.png','rw.png','ps.png','pe.png','pw.png'};
        static const name hats[]={'HF.md3','HC.md3','HR.md3','HW.md3','HP.md3'};
        static const name hatSkins[]={'hf.png','hc.png','hr.png','hw.png','hp.png'};
        static const name gloves[]={'GF.md3','GC.md3','GW.md3','GP.md3'};
        static const name gloveSkins[]={'gf.png','gc.png','gw.png','gp.png'};
        static const name shoes[]={'BF.md3','BC.md3','BR.md3','BS.md3','BP.md3'};
        static const name shoeSkins[]={'bf.png','bc.png','br.png','bs.png','bp.png'};
        Bind(9,bodies[Max(0,BodyKind)],worn,"models/caelum/inventory/clothing",bodySkins[Max(0,BodyKind)],(hidden&(1<<9))==0);
        Bind(10,hats[Max(0,HeadKind)],worn,"models/caelum/inventory/headwear",hatSkins[Max(0,HeadKind)],(hidden&(1<<10))==0);
        Bind(11,gloves[Max(0,HandKind)],worn,"models/caelum/inventory/gloves",gloveSkins[Max(0,HandKind)],(hidden&(1<<11))==0);
        Bind(12,shoes[Max(0,FootKind)],worn,"models/caelum/inventory/footwear",shoeSkins[Max(0,FootKind)],(hidden&(1<<12))==0);
        Bind(13,'base_forearms.md3',worn,original,'domingo_skin.png',(hidden&(1<<13))==0);
        Bind(14,CA829ViewData.PantsFile(BodyKind,FootKind),worn,"models/caelum/inventory/clothing",bodySkins[Max(0,BodyKind)],(hidden&(1<<14))==0);
        BindingsReady=true;
    }
    void Freeze(int index)
    {Live=false;FrozenFrame=index;SetModelFlag(MDL_NOINTERPOLATION);SetState(FindStateByString(String.Format("F%d",index)));tics=-1;}
    void Animate()
    {Live=true;ClearModelFlag(MDL_NOINTERPOLATION);SetState(FindStateByString(String.Format("F%d",Start(WALK))));}
    override void Tick()
    {
        Super.Tick();if(!BindingsReady)Apply();
        if(!Live){let desired=FindStateByString(String.Format("F%d",FrozenFrame));if(CurState!=desired)SetState(desired);tics=-1;}
    }
    Default {+NOINTERACTION +NOGRAVITY +NOBLOCKMAP RenderRadius 260;}
}
class CA829Camera : Actor
{Default {CameraHeight 0;Height 0;Radius 0;+NOINTERACTION +NOGRAVITY} States {Spawn:TNT1 A -1;Stop;}}
class CA829KeyLight : CA829Camera {}
class CA829FillLight : CA829Camera {}
class CA829PreviewEvents : EventHandler
{
    CA829WardrobePreview Subject;
    CA829Camera Camera;
    int Checks,Failures,ViewRotation,ViewPose,Combination,DetailRegion;
    State Previous;
    String CurrentLabel;
    void Check(bool okay,String label)
    {Checks++;if(!okay)Failures++;Console.Printf("CA829 %s %s",okay?"PASS":"FAIL",label);}
    void Label()
    {CurrentLabel=String.Format("#829 | B:%d H:%d G:%d F:%d | pose %d | view %d",Subject.BodyKind,Subject.HeadKind,Subject.HandKind,Subject.FootKind,ViewPose,ViewRotation);}
    void Combo(int n)
    {
        Combination=n;DetailRegion=0;
        static const int hats[]={0,0,1,1,3,2,2,3,4,4,4};
        static const int hands[]={0,2,1,1,2,1,1,2,-1,-1,3};
        static const int feet[]={0,0,3,1,1,3,2,2,4,4,4};
        Subject.BodyKind=n;Subject.HeadKind=n<0?-1:hats[n];Subject.HandKind=n<0?-1:hands[n];Subject.FootKind=n<0?-1:feet[n];Subject.Apply();Label();
    }
    void Rotate(int view)
    {
        ViewRotation=view%8;double angle=ViewRotation*45;
        Camera.SetOrigin(CameraPosition(),true);Camera.Angle=angle+180;Camera.Pitch=4;
        Camera.ClearInterpolation();Label();Console.Printf("CA829 VIEW outfit=%d pose=%d rotation=%d",Combination,ViewPose,ViewRotation);
    }
    Vector3 CameraPosition()
    {
        double viewAngle=ViewRotation*45,distance=DetailRegion>0?CA829ViewData.DetailDistance(DetailRegion):CA829ViewData.Distance(ViewPose);
        Vector3 focus=DetailRegion>0?CA829ViewData.DetailFocus(DetailRegion):CA829ViewData.Focus(ViewPose);
        // El piloto conserva su MODELDEF original sin CorrectPixelStretch.
        focus.Z/=Max(0.001,level.pixelstretch);
        return focus+(cos(viewAngle)*distance,sin(viewAngle)*distance,tan(4)*distance);
    }
    override void WorldTick()
    {
        if(Camera==null)return;
        double viewAngle=ViewRotation*45;
        Camera.SetOrigin(CameraPosition(),true);Camera.Angle=viewAngle+180;Camera.Pitch=4;
        Camera.ClearInterpolation();
    }
    override void RenderOverlay(RenderEvent e)
    {
        if(Camera==null || players[0].camera!=Camera)return;
        Screen.DrawText(Font.GetFont("CaelumMono"),Font.CR_WHITE,8,8,CurrentLabel,DTA_VIRTUALWIDTH,640,DTA_VIRTUALHEIGHT,360,DTA_KEEPRATIO,true);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name.Left(6)!="ca829_")return;
        if(e.Name=="ca829_prepare")
        {
            Subject=CA829WardrobePreview(Actor.Spawn('CA829WardrobePreview',(0,0,0),NO_REPLACE));
            Camera=CA829Camera(Actor.Spawn('CA829Camera',(205,0,100),NO_REPLACE));
            Actor.Spawn('CA829KeyLight',(130,-100,190),NO_REPLACE);Actor.Spawn('CA829FillLight',(-90,100,140),NO_REPLACE);
            let user=CaelumPlayer(players[0].mo);user.CharacterCreationComplete=true;user.CreationWizardOpen=false;user.bInvisible=true;
            Subject.Freeze(0);players[0].camera=Camera;Combo(2);Rotate(0);return;
        }
        if(Subject==null || Camera==null){Check(false,"prepare must precede inspection");return;}
        if(e.Name=="ca829_combo"){Combo(Clamp(e.Args[0],-1,10));return;}
        if(e.Name=="ca829_nextdetail"){DetailRegion=(DetailRegion+1)%4;return;}
        if(e.Name=="ca829_detail")
        {
            Combo(-1);DetailRegion=Clamp(e.Args[0],1,3);int item=e.Args[1];Subject.Freeze(0);ViewPose=0;
            if(DetailRegion==1)Subject.HeadKind=item;
            if(DetailRegion==2)Subject.HandKind=item;
            if(DetailRegion==3)Subject.FootKind=item;
            Subject.Apply();Label();Check(Subject.BodyKind==-1 && !Subject.Live,"unobstructed garment detail");return;
        }
        if(e.Name=="ca829_region" || e.Name=="ca829_nextregion")
        {
            int b=Subject.BodyKind,h=Subject.HeadKind,g=Subject.HandKind,f=Subject.FootKind,region=e.Args[0],value=e.Args[1];
            if(e.Name=="ca829_nextregion")
            {
                int current=region==0?b:region==1?h:region==2?g:f;
                int count=region==0?11:region==2?4:5;
                value=(current+2)%(count+1)-1;
            }
            if(region==0)Subject.BodyKind=Clamp(value,-1,10);
            if(region==1)Subject.HeadKind=Clamp(value,-1,4);
            if(region==2)Subject.HandKind=Clamp(value,-1,3);
            if(region==3)Subject.FootKind=Clamp(value,-1,4);
            Subject.Apply();Label();
            int selected=region==0?Subject.BodyKind:region==1?Subject.HeadKind:region==2?Subject.HandKind:Subject.FootKind;
            Check(selected==value && (region==0 || Subject.BodyKind==b) && (region==1 || Subject.HeadKind==h) && (region==2 || Subject.HandKind==g) && (region==3 || Subject.FootKind==f),"changing one garment selects the request and preserves other regions");return;
        }
        if(e.Name=="ca829_viewcheck")
        {
            double desired=ViewRotation*45;
            Check((Camera.Pos-CameraPosition()).Length()<0.01 && abs(sin(Camera.Angle-desired-180))<0.0001 && cos(Camera.Angle-desired-180)>0,"selected camera position and angle");
            Console.Printf("CA829 CAMERA x=%.2f y=%.2f z=%.2f angle=%.2f subject=%.2f stretch=%.3f",Camera.Pos.X,Camera.Pos.Y,Camera.Pos.Z,Camera.Angle,Subject.Angle,level.pixelstretch);return;
        }
        if(e.Name=="ca829_rotate"){Rotate(e.Args[0]);return;}
        if(e.Name=="ca829_nextview"){Rotate(ViewRotation+1);return;}
        if(e.Name=="ca829_nextcombo"){Combo((Combination+1)%11);return;}
        if(e.Name=="ca829_pose" || e.Name=="ca829_nextpose")
        {
            ViewPose=e.Name=="ca829_nextpose"?(ViewPose+1)%24:Clamp(e.Args[0],0,23);
            int index=CaelumDomingoPilotFrames.Start(ViewPose)+CaelumDomingoPilotFrames.Count(ViewPose)/2;
            Subject.Freeze(index);Label();Check(Subject.CurState==Subject.FindStateByString(String.Format("F%d",index)),"selected native pose");return;
        }
        if(e.Name=="ca829_animate"){Subject.Animate();Previous=Subject.CurState;return;}
        if(e.Name=="ca829_motion"){Check(Subject.CurState!=Previous,"native walking state advances");return;}
        if(e.Name=="ca829_freeze"){ViewPose=0;Subject.Freeze(0);Label();return;}
        if(e.Name=="ca829_saved"){Combo(7);ViewPose=0;Subject.Freeze(0);Label();return;}
        if(e.Name=="ca829_verify")
        {
            Check(Subject!=null && Camera!=null && players[0].camera==Camera,"saved subject/camera references");
            Check(Subject.BodyKind==7 && Subject.HeadKind==3 && Subject.HandKind==2 && Subject.FootKind==2,"saved four garment selectors");
            Check(Subject.HiddenMask==((1<<1)|(1<<3)|(1<<4)|(1<<6)|(1<<7)|(1<<8)|(1<<13)),"saved covered-body and hair visibility");
            Check(!Subject.Live && Subject.CurState==Subject.FindState('F0'),"saved frozen pose");
            Check(Subject.bNoInteraction && Subject.bNoBlockmap,"inspection has no gameplay collision");
            Console.Printf("CA829 COMPLETE failures=%d checks=%d",Failures,Checks);
        }
    }
}
