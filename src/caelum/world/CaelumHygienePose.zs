// #502: sólo postura; no abre descanso ni concede sus bonificaciones.
class CaelumHygienePose : Inventory
{
    int Revision;
    String OriginMap;
    CaelumDomesticFixture Fixture;
    vector3 EntryPosition,OriginalOffset,AppliedOffset;
    double EntryAngle,EntryPitch,Facing,CameraYaw,CameraPitch;
    bool Lying,InputArmed,Engaged;
    CaelumHygieneCamera View;
    static clearscope CaelumHygienePose Find(CaelumPlayer user)
    {return user==null?null:CaelumHygienePose(user.FindInventory('CaelumHygienePose'));}
    static clearscope bool Active(CaelumPlayer user)
    {let pose=Find(user);return pose!=null && pose.Fixture!=null && pose.OriginMap==level.MapName;}
    static bool Begin(CaelumPlayer user,CaelumDomesticFixture fixture,bool lying)
    {
        if(!CaelumPlayerAuthority.CanMutate(user) || fixture==null || !fixture.CanReach(user))return false;
        if(Active(user)){End(user);return false;}
        vector3 entry=user.Pos;
        if(!fixture.Seat(user))return false;
        let pose=Find(user);if(pose==null)pose=CaelumHygienePose(user.GiveInventoryType('CaelumHygienePose'));
        if(pose==null){fixture.Release(user,entry);return false;}
        pose.Revision=CaelumHygienePoseData.REVISION;pose.OriginMap=level.MapName;pose.Fixture=fixture;
        pose.Engaged=true;
        pose.EntryPosition=entry;pose.EntryAngle=user.Angle;pose.EntryPitch=user.Pitch;
        pose.OriginalOffset=user.WorldOffset;pose.Lying=lying;pose.InputArmed=false;
        pose.Facing=fixture.Angle+(lying?90:0);user.Angle=pose.Facing;
        pose.AppliedOffset=pose.OriginalOffset+pose.Offset(user);user.WorldOffset=pose.AppliedOffset;
        pose.CameraYaw=pose.Facing+(lying?CaelumHygienePoseData.LYING_CAMERA_YAW:CaelumHygienePoseData.SEATED_CAMERA_YAW);
        pose.CameraPitch=lying?CaelumHygienePoseData.LYING_CAMERA_PITCH:CaelumHygienePoseData.SEATED_CAMERA_PITCH;
        if(user.player!=null && (user.player.camera==null || user.player.camera==user))
        {
            pose.View=CaelumHygieneCamera(Actor.Spawn('CaelumHygieneCamera',user.Pos,NO_REPLACE));
            if(pose.View!=null){pose.View.Subject=user;user.Pitch=0;pose.View.UpdateView(pose);user.player.camera=pose.View;}
        }
        user.Vel=(0,0,0);pose.ApplyState(user);return true;
    }
    vector3 Offset(CaelumPlayer user)
    {
        if(Lying)return (0,0,CaelumHygienePoseData.TUB_SUPPORT);
        return (Cos(Facing)*CaelumHygienePoseData.SEATED_OFFSET,Sin(Facing)*CaelumHygienePoseData.SEATED_OFFSET,
            CaelumHygienePoseData.TOILET_SUPPORT-CaelumAppearanceRegistry.SeatSupportPixels()*user.Scale.Y);
    }
    void ApplyState(CaelumPlayer user)
    {
        if(user.health<=0)return;
        State wanted=user.FindState("RestSeated");if(Lying)wanted=user.FindState("RestLying");
        if(user.CurState!=wanted)user.SetState(wanted);
    }
    static void End(CaelumPlayer user)
    {
        let pose=Find(user);if(pose==null || (!pose.Engaged && pose.Fixture==null))return;
        let fixture=pose.Fixture;pose.Fixture=null;pose.Engaged=false;
        if(pose.View!=null)
        {
            if(user.player!=null && user.player.camera==pose.View)
            {user.player.camera=user;if(user.health>0 && pose.OriginMap==level.MapName){user.Angle=pose.EntryAngle;user.Pitch=pose.EntryPitch;}}
            pose.View.Destroy();pose.View=null;
        }
        if(user.WorldOffset==pose.AppliedOffset)user.WorldOffset=pose.OriginalOffset;
        if(fixture!=null)
        {if(pose.OriginMap==level.MapName)fixture.Release(user,pose.EntryPosition);
            else if(fixture.Occupant==user)fixture.Occupant=null;}
        if(user.health>0 && (user.CurState==user.FindState("RestSeated") || user.CurState==user.FindState("RestLying")))user.SetState(user.SpawnState);
    }
    static void Cancel(CaelumPlayer user)
    {if(CaelumHygieneTask.Active(user))CaelumHygieneTask.Cancel(user);if(CaelumBathTask.Active(user))CaelumBathTask.Cancel(user);End(user);}
    static void HandleInput(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user))return;
        let pose=Find(user);if(pose==null || (!pose.Engaged && pose.Fixture==null))return;
        if(!pose.Valid(user)){Cancel(user);return;}
        int buttons=BT_USE|BT_ATTACK|BT_ALTATTACK|BT_JUMP|BT_CROUCH;
        bool pressed=user.player.cmd.forwardmove!=0 || user.player.cmd.sidemove!=0 || user.player.cmd.upmove!=0 || (user.player.cmd.buttons&buttons)!=0;
        if(!pose.InputArmed){pose.InputArmed=!pressed;return;}
        if(pressed){Cancel(user);user.player.cmd.buttons&=~BT_USE;}
    }
    bool Valid(CaelumPlayer user)
    {
        return user!=null && user.health>0 && user.player!=null && user.player.playerstate==PST_LIVE
            && OriginMap==level.MapName && Fixture!=null && Fixture.Occupant==user && Fixture.CanReach(user)
            && user.Distance3D(Fixture)<=4 && user.CombatTimeRemaining<=0 && !user.HasActiveConversation()
            && !CaelumSleepRules.IsSleeping(user);
    }
    static void UpdateViewInput(CaelumPlayer user)
    {
        if(!CaelumPlayerAuthority.CanMutate(user))return;
        let pose=Find(user);if(pose==null || pose.View==null || user.player.camera!=pose.View)return;
        pose.CameraYaw+=deltaangle(pose.Facing,user.Angle);pose.CameraPitch=Clamp(pose.CameraPitch+user.Pitch,-5,60);
        user.Angle=pose.Facing;user.Pitch=0;pose.View.UpdateView(pose);
    }
    override void Tick()
    {
        Super.Tick();let user=CaelumPlayer(Owner);if(user==null || (!Engaged && Fixture==null))return;
        if(Fixture!=null)Engaged=true;
        if(!Valid(user)){Cancel(user);return;}
        if(user.WorldOffset==AppliedOffset){AppliedOffset=OriginalOffset+Offset(user);user.WorldOffset=AppliedOffset;}
        ApplyState(user);
    }
    override void PreTravelled(){let user=CaelumPlayer(Owner);if(user!=null)Cancel(user);Super.PreTravelled();}
    Default {Inventory.MaxAmount 1;Inventory.InterHubAmount 1;+INVENTORY.UNDROPPABLE +INVENTORY.UNCLEARABLE +INVENTORY.KEEPDEPLETED -INVENTORY.INVBAR}
    States {Spawn:TNT1 A -1;Stop;}
}
class CaelumHygieneCamera : SpectatorCamera
{
    CaelumPlayer Subject;
    void UpdateView(CaelumHygienePose pose)
    {tracer=Subject;SetOrigin(Subject.Pos,true);CameraFOV=Subject.player.FOV;
        Init(Max(CaelumHygienePoseData.CAMERA_MIN_DISTANCE,Subject.Height*CaelumHygienePoseData.CAMERA_HEIGHT_FACTOR),pose.CameraYaw,pose.CameraPitch,VPSF_ABSOLUTEOFFSET);}
    override void Tick()
    {
        let pose=CaelumHygienePose.Find(Subject);
        if(Subject==null || Subject.player==null || pose==null || !CaelumHygienePose.Active(Subject) || pose.View!=self || Subject.player.camera!=self)
        {if(Subject!=null && Subject.player!=null && Subject.player.camera==self)Subject.player.camera=Subject;Destroy();return;}
        UpdateView(pose);
    }
}
