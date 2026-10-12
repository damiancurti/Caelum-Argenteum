// Isolated #209 observations; not packaged with the game.
class CA209Camera : Actor
{
    Default {+NOBLOCKMAP +NOINTERACTION +NOGRAVITY}
    States {Spawn:TNT1 A -1;Stop;}
}
class CA209Player : CaelumPlayer
{
    override void Tick()
    {
        Super.Tick();
        let fixture=CA209Fixture(StaticEventHandler.Find("CA209Fixture"));
        if(fixture!=null && fixture.Showcase)fixture.Show();
        if(fixture!=null && fixture.Trace && !fixture.SeenPoses[AppearancePose])
        {fixture.SeenPoses[AppearancePose]=true;Console.Printf("CA209 NATIVE pose=%d health=%d",AppearancePose,health);}
    }
}
class CA209Fixture : StaticEventHandler
{
    CaelumPlayer User;
    Actor Camera;
    CaelumRestFurniture Furniture;
    CaelumPlayer Visual;
    CaelumDiningTable Table;
    CaelumCanteenLarge Canteen;
    int Failures,Passes;
    bool Showcase;
    int Pose,View;
    CaelumEquipmentItem TestGloves;
    bool Trace;
    bool SeenPoses[33];
    void Check(bool ok,String label)
    {if(ok)Passes++;else Failures++;Console.Printf("CA209 %s %s",ok?"PASS":"FAIL",label);}
    CaelumEquipmentItem Item(int kind,int type)
    {
        let item=CaelumEquipmentItem(Actor.Spawn("CaelumEquipmentItem"));
        item.EquipmentKind=kind;item.ItemType=type;item.Tier=1;
        item.EquipmentSize=CaelumEquipmentRules.GetDefaultSizeForCharacterTier(User.CharacterProfile.GetSizeTier());
        item.Durability=100000;item.ItemId=User.GetPersistentCharacterState(false).NextEquipmentItemId++;
        item.AcquisitionResolved=true;item.PickupDataInitialized=true;User.AddInventory(item);
        User.ApplyFormalInventorySelection(item);User.EquipSelectedNativeEquipment();
        Check(item.Equipped,"native owned test equipment successfully equipped");return item;
    }
    override void UiTick(){if(Menu.GetCurrentMenu()!=null && Showcase)Menu.GetCurrentMenu().Close();}
    void Prepare()
    {
        User=CaelumPlayer(players[0].mo);
        User.CreationWizardOpen=false;User.CharacterCreationComplete=true;
        let p=CaelumCharacterIdentity.Profile(User);
        p.Race=CaelumConstants.RACE_HUMAN;p.Sex=0;p.SkinTone=1;p.Face=0;p.HairStyle=0;p.HairColor=0;
        User.ApplyCharacterProfile();User.GetPersistentCharacterState(true).ProfileCommitted=true;
        User.CurrentHunger=90;User.CurrentThirst=90;User.CurrentSleep=50;User.CombatTimeRemaining=0;
        User.bInvulnerable=true;User.Vel=(0,0,0);User.Angle=0;User.SetOrigin((0,0,0),false);
        Camera=Actor.Spawn("CA209Camera",(150,0,50));User.player.camera=Camera;
        Camera.Angle=180;Camera.Pitch=0;
        Showcase=true;Pose=0;View=0;
        Visual=User;
        Console.Printf("CA209 READY class=%s height=%.4f scale=%.4f map=%s",User.GetClassName(),User.Height,User.Scale.Y,level.MapName);
    }
    void Show()
    {
        if(User==null || Camera==null)return;
        let body=Furniture==null?Visual:User;
        let p=User.CharacterProfile;
        body.Angle=0;body.AppearancePose=Pose;
        Camera.SetOrigin((Cos(View*45)*110,Sin(View*45)*110,32),true);
        Camera.Angle=View*45+180;
        body.AppearanceHasGloves=false;
        body.sprite=CaelumAppearance.SpriteFor(p.Race,p.Sex,p.BeastForm,p.SkinTone,Pose,false);
        body.frame=Pose%26;
        body.AppearanceHead.UpdateVisual();
    }
    override void WorldTick(){if(Showcase)Show();}
    override void ConsoleProcess(ConsoleEvent e)
    {
        if(e.Name=="c209_key")
        {
            let menu=CaelumLiveMenu(Menu.GetCurrentMenu());
            if(menu==null){Console.Printf("CA209 FAIL native rest menu missing");return;}
            int character=e.Args[0];
            String key=String.Format("%c",character);
            int scan=CaelumMenuPointer.KeyScan(character);
            Console.Printf("CA209 KEY %s binding=%s",key,Bindings.GetBinding(scan));
            menu.Key(InputEvent.Type_KeyDown,scan,character,key,true);
            menu.Key(InputEvent.Type_KeyUp,scan,character,key,true);
        }
        if(e.Name=="c209_prepare" || e.Name=="c209_pose" || e.Name=="c209_rest" || e.Name=="c209_offsets"
            || e.Name=="c209_done" || e.Name=="c209_race")
            EventHandler.SendNetworkEvent(e.Name,e.Args[0],e.Args[1],e.Args[2]);
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name=="c209_prepare")Prepare();
        if(e.Name=="c209_table")
        {
            Showcase=false;User.player.camera=User;
            Table=CaelumDiningTable(Actor.Spawn("CaelumDiningTable",(150,0,0)));
            Canteen=CaelumCanteenLarge(Actor.Spawn("CaelumCanteenLarge",Table.Pos));
            Canteen.WaterLiters=3;Canteen.AttachToOwner(Table);Table.Items[0]=Canteen;
            let food=CaelumConsumableItem(Actor.Spawn("CaelumFoodRation",Table.Pos));
            food.Amount=4;food.AttachToOwner(Table);Table.Items[1]=food;Table.RefreshDisplays();
            Furniture=CaelumRestFurniture(Actor.Spawn("CaelumRestChair",(0,0,0)));
            Furniture.Angle=180;Furniture.DiningTable=Table;
            User.WorldOffset=(2,3,4);User.SetOrigin((0,64,0),false);
            Check(CaelumRestState.Begin(User,Furniture.RestMode(),60,Furniture),"table seated rest begins");
            Check(Table.CanDine(User),"real table reachable while seated");
        }
        if(e.Name=="c209_dining_check")
        {
            let rest=CaelumRestState.Get(User);
            Check(rest!=null && rest.Status==CaelumRestRules.STATUS_ACTIVE,"context key preserves seated rest");
            if(rest!=null && e.Args[0]==0)Check(rest.AutoEating,"F enables automatic eating");
            if(rest!=null && e.Args[0]==1)Check(rest.AutoDrinking,"G enables automatic drinking");
            Check(Table.Items[0]==Canteen && Canteen.Owner==Table && Table.Displays[0].Item==Canteen,"3D canteen retains inventory identity");
        }
        if(e.Name=="c209_cancel_check")
        {
            Check(!CaelumRestState.IsActive(User),"Q cancels seated rest");
            Check(User.WorldOffset==(2,3,4),"stand up restores original WorldOffset");
        }
        if(e.Name=="c209_restore")
        {
            User=CaelumPlayer(players[0].mo);Visual=User;Showcase=false;
            let rest=CaelumRestState.Get(User);
            Check(rest!=null && rest.Status==CaelumRestRules.STATUS_ACTIVE,"saved rest remains active");
            if(rest==null)return;
            Furniture=rest.Furniture;Table=Furniture.DiningTable;Canteen=CaelumCanteenLarge(Table.Items[0]);
            Check(rest.OriginalWorldOffset==(2,3,4),"saved original WorldOffset preserved");
            Check(User.WorldOffset==rest.AppliedWorldOffset,"saved rest owns current offset");
            Check(User.AppearanceHead.WorldOffset==User.WorldOffset,"loaded head follows furniture offset");
            double expected=rest.OriginalWorldOffset.Z+20*Furniture.Scale.Y/level.pixelstretch-47*User.Scale.Y;
            Check(Abs(expected-User.WorldOffset.Z)<.001,"old saved seat aligns without cumulative offset");
            Check(Canteen.Owner==Table && Canteen.WaterLiters==3,"loaded 3D canteen retains owner and liters");
            Console.Printf("CA209 SAVED elapsed=%d offsetZ=%.5f expected=%.5f",rest.ElapsedTics,User.WorldOffset.Z,expected);
        }
        if(e.Name=="c209_camera")
        {
            if(Camera==null)Camera=Actor.Spawn("CA209Camera",User.Pos);
            double angle=e.Args[0]*45;
            vector3 center=User.Pos;
            if(e.Args[1]==1)center=Table.Displays[0].Pos;
            Camera.SetOrigin(center+(Cos(angle)*110,Sin(angle)*110,40),false);
            Camera.Angle=angle+180;Camera.Pitch=12;User.player.camera=Camera;
            Console.Printf("CA209 CAMERA view=%d bodyangle=%.3f",e.Args[0],User.Angle);
        }
        if(e.Name=="c209_support")
        {
            let rest=CaelumRestState.Get(User);
            Check(CaelumRestState.IsActive(User),"scaled furniture rest stays active");
            double support=rest.Mode==CaelumRestRules.MODE_WAIT?47*User.Scale.Y:0;
            double surface=rest.Mode==CaelumRestRules.MODE_WAIT?20:rest.Furniture is "CaelumRestBag"?4:12;
            Check(Abs(User.WorldOffset.Z+support-surface*Furniture.Scale.Y/level.pixelstretch)<.001,"drawn support aligns with furniture surface");
            if(User.CharacterProfile.Race!=CaelumConstants.RACE_BEAST_MAN)
                Check(User.AppearanceHead.WorldOffset==User.WorldOffset,"humanoid head shares scaled furniture offset");
            Console.Printf("CA209 SUPPORT race=%d sex=%d height=%d scale=%.4f z=%.4f",User.CharacterProfile.Race,User.CharacterProfile.Sex,User.CharacterProfile.HeightChoice,User.Scale.Y,User.WorldOffset.Z);
        }
        if(e.Name=="c209_live")
        {Showcase=false;User.player.camera=User;User.bInvisible=false;}
        if(e.Name=="c209_weapon")
        {let item=Item(CaelumConstants.EQUIPMENT_KIND_WEAPON,e.Args[0]);User.ActivateExactEquippedWeapon(item);}
        if(e.Name=="c209_shield")Item(CaelumConstants.EQUIPMENT_KIND_SHIELD,CaelumConstants.SHIELD_TYPE_KITE);
        if(e.Name=="c209_trace")
        {Trace=true;for(int i=0;i<33;i++)SeenPoses[i]=false;Showcase=false;}
        if(e.Name=="c209_attack")User.PlayAttacking();
        if(e.Name=="c209_death")
        {CaelumRestState.Cancel(User);User.bInvulnerable=false;User.DamageMobj(null,null,1000000,'None',DMG_FORCED);}
        if(e.Name=="c209_height")
        {User.CharacterProfile.HeightChoice=e.Args[0];User.ApplyCharacterProfile();}
        if(e.Name=="c209_hand")
        {
            Showcase=false;User.player.camera=User;User.A_ClearOverlays(1,1000);
            String label=String.Format("V%d_Hand_%d",e.Args[0],e.Args[1]);
            let pose=GetDefaultByType("CaelumAppearanceHandFrames").FindStateByString(label,true);
            let overlay=User.player.GetPSprite(999);overlay.SetState(pose);
            overlay.bAddWeapon=false;overlay.bAddBob=false;overlay.x=0;overlay.y=32;
        }
        if(e.Name=="c209_gloves")
        {
            if(TestGloves==null)
            {
                TestGloves=CaelumEquipmentItem(Actor.Spawn("CaelumEquipmentItem"));
                TestGloves.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_ARMOR;
                TestGloves.ItemType=CaelumConstants.ARMOR_TYPE_LIGHT;
                TestGloves.ArmorSlot=CaelumConstants.ARMOR_SLOT_HANDS;
                TestGloves.ItemId=990209;TestGloves.AcquisitionResolved=true;
                User.AddInventory(TestGloves);
            }
            TestGloves.Equipped=e.Args[0]!=0;User.EquippedArmorItemId[2]=TestGloves.Equipped?990209:0;
        }
        if(e.Name=="c209_hand_check")
        {
            int variant=CaelumAppearanceHands.Variant(User);
            Check(variant==e.Args[0],"actual character selects expected first-person variant");
            let left=User.player.FindPSprite(51);let right=User.player.FindPSprite(52);
            Check(left!=null && left.CurState==CaelumAppearanceHands.Hand(User,9),"actual unarmed left hand follows appearance");
            Check(right!=null && right.CurState==CaelumAppearanceHands.Hand(User,10),"actual unarmed right hand follows appearance");
            Console.Printf("CA209 HAND sex=%d race=%d form=%d gloves=%d variant=%d",User.CharacterProfile.Sex,User.CharacterProfile.Race,User.CharacterProfile.BeastForm,CaelumAppearanceHands.HasGloves(User),variant);
        }
        if(e.Name=="c209_contract")
        {
            Check(User is "CA209Player","isolated native test player selected");
            let p=User.CharacterProfile;
            for(int sex=0;sex<2;sex++)for(int race=0;race<4;race++)for(int form=0;form<4;form++)for(int tone=0;tone<3;tone++)
            {
                p.Sex=sex;p.Race=race;p.BeastForm=form;p.SkinTone=tone;
                for(int pose=0;pose<CaelumAppearance.POSE_COUNT;pose++)
                    if(CaelumAppearance.SpriteFor(race,sex,form,tone,pose)<0)Check(false,"all appearance banks resolve");
                int variant=CaelumAppearanceHands.Variant(User);
                let registry=GetDefaultByType("CaelumAppearanceHandFrames");
                Check(registry.FindStateByString(String.Format("V%d_Hand_0",variant),true)!=null,"sex race tone hand variant resolves");
            }
            Check(CaelumAppearance.POSE_COUNT==33,"33 semantic poses including four run phases");
            for(int step=0;step<4;step++)
                Check(CaelumAppearance.PoseFor(CaelumAppearance.RegisteredSprite("SourceDORN"),step)==(step<2?4+step:27+step),"native running frame mapping");
            p.Sex=0;p.Race=CaelumConstants.RACE_HUMAN;p.BeastForm=0;p.SkinTone=1;
        }
        if(e.Name=="c209_pose")
        {
            Pose=e.Args[0];View=e.Args[1];Show();
            Console.Printf("CA209 VISUAL pose=%d sprite=%d frame=%d pos=(%.2f,%.2f,%.2f) scale=%.2f invisible=%d",Pose,Visual.sprite,Visual.frame,Visual.Pos.X,Visual.Pos.Y,Visual.Pos.Z,Visual.Scale.Y,Visual.bInvisible);
        }
        if(e.Name=="c209_race")
        {let p=User.CharacterProfile;p.Race=e.Args[0];p.Sex=e.Args[1];p.SkinTone=e.Args[2];User.ApplyCharacterProfile();Show();}
        if(e.Name=="c209_rest")
        {
            CaelumRestState.Cancel(User);if(Furniture!=null)Furniture.Destroy();
            User.WorldOffset=(0,0,0);User.SetOrigin((64,0,0),false);User.Vel=(0,0,0);
            class<CaelumRestFurniture> kind=e.Args[0]==0?"CaelumRestChair":e.Args[0]==1?"CaelumRestBed":"CaelumRestBag";
            Furniture=CaelumRestFurniture(Actor.Spawn(kind,(0,0,0)));Furniture.Angle=180;
            if(e.Args[0]==2)
            {let bag=CaelumSleepingBag(Actor.Spawn("CaelumSleepingBag"));User.AddInventory(bag);CaelumRestBag(Furniture).Bag=bag;}
            bool began=CaelumRestState.Begin(User,Furniture.RestMode(),60,Furniture);
            Check(began,"native furniture rest begins");
            if(!began)Console.Printf("CA209 REST blocked: %s",CaelumRestState.BlockReason(User));
            Pose=e.Args[0]==0?16:17;
            User.player.camera=Camera;Show();
        }
        if(e.Name=="c209_offsets")
        {Show();Check(User.AppearanceHead.WorldOffset==User.WorldOffset,"head follows furniture WorldOffset");
         Console.Printf("CA209 OFFSET body=(%.3f,%.3f,%.3f) head=(%.3f,%.3f,%.3f)",User.WorldOffset.X,User.WorldOffset.Y,User.WorldOffset.Z,User.AppearanceHead.WorldOffset.X,User.AppearanceHead.WorldOffset.Y,User.AppearanceHead.WorldOffset.Z);}
        if(e.Name=="c209_done")Console.Printf("CA209 DONE failures=%d passes=%d",Failures,Passes);
    }
}
