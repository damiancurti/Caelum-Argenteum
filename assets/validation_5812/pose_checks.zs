    CaelumDomesticBathtub Tub(CaelumPlayer u)
    {
        Toilet(u);let it=ThinkerIterator.Create('CaelumBathroomInstallation');let room=CaelumBathroomInstallation(it.Next());
        return room==null?null:CaelumDomesticBathtub(room.Fixtures[1]);
    }
    void PoseCore(CaelumPlayer u)
    {
        Reset(u);let toilet=Toilet(u);vector3 entry=u.Pos;vector3 offset=u.WorldOffset;double angle=u.Angle,pitch=u.Pitch;
        double radius=u.Radius,height=u.Height;
        Check(toilet.Used(u),"posture toilet begins");let pose=CaelumHygienePose.Find(u);
        Check(pose!=null && pose.Fixture==toilet && toilet.Occupant==u && !toilet.bSolid,"toilet lends collision to its occupant");
        Check(u.Pos==toilet.Pos && u.TestMobjLocation() && u.Radius==radius && u.Height==height,"safe entry retains actual player volume");
        Check(u.CurState==u.FindState("RestSeated") && !pose.Lying && pose.View!=null && u.player.camera==pose.View,"toilet seated artwork and dedicated camera");
        Check(!CaelumRestState.IsActive(u) && !CaelumSleepRules.IsSleeping(u) && CaelumRestState.ResourceFactor(u)==1,"hygiene grants no rest or sleep benefits");
        double facing=u.Angle;u.Angle+=20;CaelumHygienePose.UpdateViewInput(u);
        Check(Near(u.Angle,facing) && Near(pose.CameraYaw,facing+CaelumHygienePoseData.SEATED_CAMERA_YAW+20),"mouse orbit keeps seated body facing fixed");
        Check(toilet.Used(u) && !CaelumHygienePose.Active(u) && !CaelumHygieneTask.Active(u),"second Use releases toilet pose and task");
        Check(u.Pos==entry && u.WorldOffset==offset && Near(u.Angle,angle) && Near(u.Pitch,pitch) && u.player.camera==u && toilet.bSolid && toilet.Occupant==null,"exit restores entry view offset and collision");
        let tub=Tub(u);Aim(u,tub);entry=u.Pos;let water=CaelumDomesticWater.Get(tub.House);double before=water.Liters,c=CaelumFoodIllness.Value(u);
        Check(tub.Used(u),"bathtub Use reclines");pose=CaelumHygienePose.Find(u);
        Check(pose.Lying && u.CurState==u.FindState("RestLying") && u.player.camera==pose.View && tub.Occupant==u,"bathtub uses lying artwork and camera");
        Check(!CaelumSleepRules.IsSleeping(u) && !CaelumHygieneTask.Active(u) && Near(water.Liters,before) && Near(CaelumFoodIllness.Value(u),c),"reclining alone neither sleeps nor charges or washes");
        Check(tub.Used(u) && u.Pos==entry && tub.Occupant==null && tub.bSolid,"bathtub toggle restores standing and free collision");
        Aim(u,tub);tub.Used(u);pose=CaelumHygienePose.Find(u);pose.InputArmed=true;u.player.cmd.buttons=BT_USE;
        CaelumHygienePose.HandleInput(u);u.player.cmd.buttons=0;
        Check(!CaelumHygienePose.Active(u) && u.player.camera==u,"real Use input exits even without aiming from inside tub");
        Aim(u,tub);tub.Used(u);int hp=u.health;u.DamageMobj(null,null,1,'CaelumDiseaseDOT',DMG_NO_ARMOR,0);
        Check(CaelumHygienePose.Active(u) && u.health<hp,"disease continues without interrupting reclining");
        u.DamageMobj(null,null,1,'Drowning',DMG_NO_ARMOR,0);
        Check(!CaelumHygienePose.Active(u) && tub.Occupant==null,"external damage releases tub");
        Reset(u);Aim(u,tub);tub.Used(u);vector3 moved=tub.Pos+(-120,0,0);u.SetOrigin(moved,false);CaelumHygienePose.Find(u).Tick();
        Check(!CaelumHygienePose.Active(u) && u.Pos==moved,"external displacement is preserved on release");
        Reset(u);Aim(u,toilet);let blocker=Actor.Spawn('CaelumRestChair',toilet.Pos,NO_REPLACE);
        bool blockedUse=toilet.Used(u);
        Console.Printf("CA502H blocker=%d solid=%d usernoclip=%d usersolid=%d used=%d task=%d occupant=%d camera=%d location=%d",blocker!=null,blocker.bSolid,u.bNOCLIP,u.bSolid,blockedUse,CaelumHygieneTask.Active(u),toilet.Occupant!=null,u.player.camera==u,u.TestMobjLocation());
        Check(!blockedUse && !CaelumHygieneTask.Active(u) && toilet.Occupant==null && u.player.camera==u,"occupied physical space rejects entry atomically");blocker.Destroy();
        Reset(u);Aim(u,tub);tub.Used(u);pose=CaelumHygienePose.Find(u);let otherCamera=Actor.Spawn('CaelumRestPlacementProbe',u.Pos,NO_REPLACE);u.player.camera=otherCamera;
        CaelumHygienePose.End(u);Check(u.player.camera==otherCamera,"release respects a camera taken by another system");u.player.camera=u;otherCamera.Destroy();
        Reset(u);toilet.Used(u);u.CraftingTaskRemainingSeconds=0;u.CompleteCraftingTask();
        Check(!CaelumHygienePose.Active(u) && u.player.camera==u && toilet.Occupant==null,"successful toilet completion stands up");
        Reset(u);let other=CaelumPlayer(Actor.Spawn('CaelumPlayer',u.Pos+(-160,0,0),NO_REPLACE));toilet.Occupant=other;
        Check(!toilet.Used(u) && !CaelumHygienePose.Active(u),"another occupant blocks toilet use");toilet.Occupant=null;other.Destroy();
        Reset(u);toilet.Used(u);entry=CaelumHygienePose.Find(u).EntryPosition;
        Array<Actor> exits;
        for(int i=-1;i<8;i++)
        {
            double direction=toilet.Angle+i*45;double distance=toilet.Radius+u.Radius+12;
            vector3 pos=i<0?entry:toilet.Pos+(Cos(direction)*distance,Sin(direction)*distance,0);
            let obstruction=Actor.Spawn('CaelumRestChair',pos,NO_REPLACE);obstruction.A_SetSize(8,64,false);exits.Push(obstruction);
        }
        CaelumHygienePose.Cancel(u);
        Check(!CaelumHygienePose.Active(u) && u.Pos==toilet.Pos && !toilet.bSolid && toilet.Occupant==null,"blocked exits release in place without trapping or telefragging");
        for(int i=0;i<exits.Size();i++)exits[i].Destroy();u.SetOrigin(entry,false);toilet.Tick();
        Check(toilet.bSolid,"fixture collision returns after standing occupant walks clear");
        Reset(u);Aim(u,tub);tub.Used(u);entry=u.Pos;u.health=0;CaelumHygienePose.Find(u).Tick();
        Check(!CaelumHygienePose.Active(u) && u.Pos==entry && u.player.camera==u,"zero-Life cleanup restores camera without moving body");
        u.health=u.CaelumMaximumHealth;u.player.health=u.health;u.SetState(u.SpawnState);
        Reset(u);Aim(u,tub);offset=u.WorldOffset;entry=u.Pos;tub.Used(u);pose=CaelumHygienePose.Find(u);pose.Fixture=null;pose.Tick();
        Check(!pose.Engaged && u.WorldOffset==offset && u.player.camera==u,"lost fixture reference still restores pose offset and camera");
        u.SetOrigin(entry,false);tub.Tick();Check(tub.Occupant==null && tub.bSolid,"orphaned fixture releases occupant and collision");
        Reset(u);toilet.Used(u);water=CaelumDomesticWater.Get(toilet.House);before=water.Liters;
        u.SetOrigin(toilet.Pos+(10,0,0),false);u.CraftingTaskRemainingSeconds=0;u.CompleteCraftingTask();
        Check(!CaelumHygieneTask.Active(u) && Near(water.Liters,before) && Near(CaelumFoodIllness.Value(u),40),"late displacement within Use range cannot complete an abandoned seat");
    }
    void PoseSeed(CaelumPlayer u)
    {Reset(u);let tub=Tub(u);Aim(u,tub);Check(tub.Used(u) && CaelumHygienePose.Active(u),"save a reclining tub occupant");}
    void PoseLoad(CaelumPlayer u)
    {let pose=CaelumHygienePose.Find(u);Check(pose!=null && pose.Lying && pose.Fixture==Tub(u) && pose.Fixture.Occupant==u && u.player.camera==pose.View,"saved tub posture occupancy and camera retain identity");
        CaelumHygienePose.End(u);Check(!CaelumHygienePose.Active(u) && u.player.camera==u && Tub(u).bSolid,"saved tub exits safely");}
    void PoseLegacy(CaelumPlayer u)
    {let task=CaelumHygieneTask.Find(u);double remaining=u.CraftingTaskRemainingSeconds;
        Check(task!=null && CaelumHygieneTask.Active(u) && remaining>0,"pre-pose toilet session remains active");
        u.RefreshActiveCraftingStationSession();Check(CaelumHygienePose.Active(u) && Toilet(u).Occupant==u && Near(u.CraftingTaskRemainingSeconds,remaining),"old pending toilet adopts pose without restarting its timer");}
    void PoseHub(CaelumPlayer u)
    {Check(!CaelumHygienePose.Active(u) && u.player.camera==u,"hub travel clears old posture and camera");
        Check(Tub(u).Occupant==null && Toilet(u).Occupant==null,"hub fixtures have no stranded occupant");}
    void PoseManual(CaelumPlayer u,bool tubMode)
    {CaelumHygienePose.Cancel(u);Reset(u);let fixture=CaelumDomesticFixture(Toilet(u));if(tubMode)fixture=Tub(u);Aim(u,fixture);
        Console.Printf("CA502H manual posture: F1 toilet / F2 bathtub / Use begins and exits; movement or external damage exits.");}
