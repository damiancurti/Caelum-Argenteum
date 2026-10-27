class CA410BasicCamera : Actor
{Default {+NOBLOCKMAP +NOINTERACTION +NOGRAVITY} States {Spawn:TNT1 A -1;Stop;}}
// Diagnostic fixture also compiles against the untouched 5.8.32 runtime.
class CA410BasicRestChecks : EventHandler
{
    int Passed,Failed;
    CaelumRestChair Chair;
    CaelumRestBed Bed;
    CaelumSleepingBag BagItem;
    CaelumLuxuryChair LuxuryChair;
    CaelumLuxuryBed LuxuryBed;
    CaelumSofa Sofa;
    CaelumDiningTable Table;
    Inventory Witness;
    void Check(bool ok,String label){if(ok)Passed++;else Failed++;Console.Printf("CA410BR %s %s",ok?"PASS":"FAIL",label);}
    void Result(){Console.Printf("CA410BR RESULT passed=%d failed=%d",Passed,Failed);}
    bool Near(double a,double b){return Abs(a-b)<.00001;}
    void Profile(CaelumPlayer u)
    {
        if(u.player.ConversationNPC!=null)u.player.ConversationNPC.bInConversation=false;
        u.player.ConversationNPC=null;u.player.ConversationPC=null;
        u.CharacterCreationComplete=true;u.CreationWizardOpen=false;u.bInvulnerable=true;u.CombatTimeRemaining=0;
        u.GetPersistentCharacterState(true).ProfileCommitted=true;
        u.GetPersistentCharacterState(true).SetMainM00Flag(CaelumConstants.MAIN_M00_FLAG_UNKNOWN_VOICE_HEARD);
        u.CurrentHunger=100;u.CurrentThirst=100;u.CurrentSleep=50;u.Vel=(0,0,0);
    }
    void Setup(CaelumPlayer u)
    {
        Profile(u);
        if(Chair==null)Chair=CaelumRestChair(Actor.Spawn('CaelumRestChair',(-180,0,0)));
        if(Bed==null)Bed=CaelumRestBed(Actor.Spawn('CaelumRestBed',(60,0,0)));
        if(BagItem==null){BagItem=CaelumSleepingBag(Actor.Spawn('CaelumSleepingBag'));BagItem.AttachToOwner(u);}
        if(LuxuryChair==null)LuxuryChair=CaelumLuxuryChair(Actor.Spawn('CaelumLuxuryChair',(-180,260,0)));
        if(LuxuryBed==null)LuxuryBed=CaelumLuxuryBed(Actor.Spawn('CaelumLuxuryBed',(60,260,0)));
        if(Sofa==null)Sofa=CaelumSofa(Actor.Spawn('CaelumTwoSeatSofa',(300,260,0)));
        if(Table==null){Table=CaelumDiningTable(Actor.Spawn('CaelumDiningTable',(0,600,0)));CaelumDiningWorld.EnsureSeats(Table);}
        let zone=Actor.Spawn('CaelumTimeAdvanceZone',(0,0,0));zone.A_SetSize(900,256,false);
        Check(Chair!=null && Bed!=null && BagItem!=null,"owned chair, cot and unchanged floor bag spawn");
    }
    void FinishRest(CaelumPlayer u){let r=CaelumRestState.Get(u);if(r!=null)r.Finish(u,CaelumRestRules.STATUS_CANCELLED,"");}
    void Approach(CaelumPlayer u,CaelumRestFurniture f)
    {u.SetOrigin(f.Pos+(-72,0,0),false);u.FindFloorCeiling();u.Angle=0;u.Pitch=15;u.Vel=(0,0,0);u.CombatTimeRemaining=0;}
    void Dimensions()
    {
        Check(Near(Chair.Radius,Sqrt(.43*.43+.44*.44)*16) && Near(Chair.Height,.88*32),"chair uses documented human footprint and height");
        Check(Near(Bed.Radius,Sqrt(1.0414*1.0414+1.9685*1.9685)*16) && Near(Bed.Height,.68*32),"cot uses historical footprint and raised frame envelope");
        Check(Chair.Mass==8 && Bed.Mass==29,"rounded actor mass matches transparent construction bill");
    }
    void Core(CaelumPlayer u)
    {
        Profile(u);Dimensions();double radius=u.Radius,height=u.Height;
        Check(Chair.ComfortFactor()==CaelumRestRules.CHAIR_RESOURCE_FACTOR && Bed.ComfortFactor()==4,"resizing adds no rest bonus");
        Check(Chair.TestMobjLocation() && Bed.TestMobjLocation(),"new complete native footprints fit");
        for(int k=0;k<2;k++)
        {
            CaelumRestFurniture f=Chair;if(k==1)f=Bed;Approach(u,f);
            Check(CaelumRestState.Begin(u,f.RestMode(),480,f),"native rest begins on corrected furniture");
            Check(f.Occupant==u && !f.bSolid,"real occupant borrows only furniture collision");
            Check(Near(u.Radius,radius) && Near(u.Height,height) && u.TestMobjLocation(),"player capsule stays full size");
            vector3 pose=f.PoseOffsetFor(u);
            double support=k==0?CaelumAppearanceRegistry.SeatSupportPixels()*u.Scale.Y:0;
            Check(Near(pose.Z+support,.46*32/level.pixelstretch),"seat and sleeping support are at the same raised height");
            Check(Near(u.WorldOffset.Z,pose.Z),"actual resting pose follows corrected support");
            if(k==0)Check(Near(pose.X,0) && Near(pose.Y,0),"ordinary sitter is centered on smaller seat");
            else Check(Near(u.Angle,Bed.Angle),"ordinary sleeper faces the corrected headboard orientation");
            FinishRest(u);Check(f.Occupant==null && f.bSolid,"cancel releases occupant and restores solid furniture");
            Approach(u,f);let blocker=Actor.Spawn('CaelumRestChair',f.Pos);blocker.A_SetSize(16,56,false);
            Check(!f.Seat(u),"another full body prevents sitting or lying through it");blocker.Destroy();
        }
        u.SetOrigin((300,0,0),false);u.Vel=(0,0,0);Check(BagItem.BeginRest(u,480),"native sleeping bag still opens on clear floor");
        let bagRest=CaelumRestState.Get(u);vector3 bagPose=bagRest.Furniture.PoseOffsetFor(u);
        Check(Near(bagPose.Z,CaelumAppearanceRegistry.BagSurface()/level.pixelstretch),"sleeping bag retains ground-level support");FinishRest(u);
        Check(LuxuryChair.Mass==30 && LuxuryBed.Mass==136,"luxury dimensions and construction mass remain intact");
        Check(Near(LuxuryChair.Radius,Sqrt(2)*22.368/2) && Near(LuxuryBed.Height,68.288),"ordinary migration does not resize luxury subclasses");
        Check(Sofa.Seats[0]!=null && Near(Sofa.Seats[0].Radius,16),"sofa anchor collision is unchanged");
        Check(Table.HasSeatLayout(6) && Table.LayoutFits(),"existing dining table keeps six functional chairs");
        for(int k=0;k<6;k++)Check(Table.Chairs[k]!=null && Near(Table.Chairs[k].Radius,Chair.Radius),"existing dining chair receives ordinary dimension migration");
        if(Table.Chairs[0]!=null){Approach(u,Table.Chairs[0]);Check(CaelumRestState.Begin(u,Table.Chairs[0].RestMode(),480,Table.Chairs[0]),"dining chair remains usable after resizing");FinishRest(u);}
    }
    void Seed(CaelumPlayer u)
    {
        Witness=Inventory(Actor.Spawn('CaelumFoodRation'));Witness.AttachToOwner(Bed);
        CaelumContaminationStorage.Set(Bed,43);
        Check(Witness.Owner==Bed,"real cot inventory attached for persistence check");
    }
    void Resume(CaelumPlayer u)
    {
        Profile(u);Check(Chair!=null && Bed!=null && Witness!=null && Witness.Owner==Bed,"same bodies and real inventory persist");Dimensions();
        Check(Near(CaelumContaminationStorage.Value(Bed),43),"migration preserves original contamination");
        Approach(u,Bed);Check(CaelumRestState.Begin(u,Bed.RestMode(),480,Bed),"retained cot can still be used");FinishRest(u);
    }
    void LegacySeed(CaelumPlayer u)
    {
        Seed(u);Approach(u,Bed);Check(CaelumRestState.Begin(u,Bed.RestMode(),480,Bed),"old runtime saves occupied cot");
        Check(Near(Chair.Radius,24) && Near(Bed.Radius,56),"legacy fixture really uses old furniture collision");
    }
    void LegacyResume(CaelumPlayer u,bool rollback)
    {
        Check(Bed!=null && Witness!=null && Witness.Owner==Bed,"legacy occupied actor and inventory preserved");
        let r=CaelumRestState.Get(u);
        Check(r!=null && r.Status==CaelumRestRules.STATUS_ACTIVE && r.Furniture==Bed && Bed.Occupant==u,"old active rest session survives load");
        if(rollback)Check(Near(Bed.Radius,56),"untouched save still loads in original runtime");
        else {Dimensions();Check(Near(u.WorldOffset.Z,.46*32/level.pixelstretch),"saved occupant automatically aligns to raised cot");Check(Near(u.Angle,Bed.Angle),"old occupied cot also migrates facing toward headboard");}
        Check(Near(CaelumContaminationStorage.Value(Bed),43),"old cot contamination retained");
        FinishRest(u);Check(Bed.Occupant==null && Bed.bSolid,"migrated or rollback rest exits normally");
    }
    void Migration(CaelumPlayer u)
    {
        let s=CaelumRecipeSession.Get(u);
        Check(s!=null && s.Active && s.Book!=null && Near(s.RemainingSeconds,321.75),"original campaign stored-book progress unchanged");
        let b=CaelumRestFurnitureTrial.Find(101);
        Check(b!=null && Near(b.Height,.68*32),"existing campaign bed migrates in place without map replacement");
        let t=CaelumDiningWorld.Find(105);Check(t!=null && t.HasSeatLayout(6),"campaign table preserves real six-seat layout");
    }
    void View(CaelumPlayer u,int k)
    {
        Profile(u);FinishRest(u);
        if(k==2 || k==5){u.SetOrigin((300,0,0),false);u.Vel=(0,0,0);Check(BagItem.BeginRest(u,480),"floor bag uses native rest");}
        else {
            CaelumRestFurniture f=Chair;if(k==1 || k==4)f=Bed;
            if(k<3){u.SetOrigin(f.Pos+(-100,-100,0),false);u.Angle=45;u.Pitch=12;}
            else {Approach(u,f);Check(CaelumRestState.Begin(u,f.RestMode(),480,f),"visual inspection begins actual furniture rest");}
        }
        Check(u.TestMobjLocation(),"inspection position keeps physical clearance");
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Player<0)return;let u=CaelumPlayer(players[e.Player].mo);if(u==null)return;
        if(e.Name=='ca410br_setup')Setup(u);
        else if(e.Name=='ca410br_input')
        {
            CaelumRestFurniture f=Chair;if(e.Args[0]==1)f=Bed;
            if(e.Args[1]==0){Profile(u);double distance=f.Radius+u.Radius+5;u.SetOrigin(f.Pos+(-distance,0,0),false);u.Angle=0;u.Pitch=atan2(u.player.viewz-f.Pos.Z-f.Height*.5,distance);Check(f.CanReach(u),"native use ray starts within legal reach");}
            else {let guide=CaelumRestGuide(u.player.ConversationNPC);Check(guide!=null && guide.Furniture==f,"real Use opens the correct furniture interaction");}
        }
        else if(e.Name=='ca410br_core')Core(u);
        else if(e.Name=='ca410br_seed')Seed(u);
        else if(e.Name=='ca410br_resume')Resume(u);
        else if(e.Name=='ca410br_view')View(u,e.Args[0]);
        else if(e.Name=='ca410br_migration')Migration(u);
        else if(e.Name=='ca410br_camera')
        {
            let camera=Actor.Spawn('CA410BasicCamera',u.Pos+(-75,-75,45));
            camera.Angle=45;camera.Pitch=0;u.player.camera=camera;
            Check(CaelumRestState.IsActive(u),"side inspection preserves actual active rest");
        }
        else if(e.Name=='ca410br_legacyseed')LegacySeed(u);
        else if(e.Name=='ca410br_legacyresume')LegacyResume(u,false);
        else if(e.Name=='ca410br_legacyrollback')LegacyResume(u,true);
        else return;Result();
    }
}
