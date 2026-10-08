class CA143VisualSoldier : CaelumPortDefender { override void Tick() {} }
class CA143Visual : EventHandler
{
    CaelumPortDefender Body;int Stage,Checks,Failures;int SeenViews[4];bool PlayerWasCrouched,SawPlayerShot;
    double LastPlayerMuzzle;
    void Check(bool ok,String label)
    {Checks++;if(!ok)Failures++;Console.Printf("CA143 %s %s",ok ? "PASS" : "FAIL",label);}
    override void WorldTick()
    {
        let user=CaelumPlayer(players[0].mo);
        if(level.time==1){user.InitializeDirectMapCharacter();user.PersistCharacterState();user.bNOTARGET=true;Stage=-1;}
        if(level.time==60)
        {
            Body=CaelumPortDefender(Actor.Spawn("CA143VisualSoldier",(2300,4490,0)));
            user.bINVULNERABLE=true;user.bNOGRAVITY=true;user.SetOrigin((2300,4310,0),false);user.Angle=90;user.Pitch=0;
            let merchant=CaelumCityMerchant(Actor.Spawn("CaelumCityMerchant",(1000,1000,0)));
            int size=CaelumEquipmentRules.ResolveAcquisitionSize(user,CaelumEquipmentRules.CHARACTER_DEFAULT,CaelumConstants.EQUIPMENT_SIZE_M);
            merchant.SeedEquipment(user,CaelumConstants.EQUIPMENT_KIND_WEAPON,CaelumConstants.WEAPON_TYPE_CARBINE,0,size,0);
            let item=CaelumEquipmentItem(merchant.Inv);merchant.RemoveInventory(item);item.AttachToOwner(user);item.AcquisitionResolved=true;
            user.EnsureEquipmentItemId(item);user.EquipmentSelectionItemId=item.ItemId;user.EquipmentSelectionKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;
            user.EquipmentSelectionWeaponType=CaelumConstants.WEAPON_TYPE_CARBINE;user.EquipmentSelectionTier=1;user.EquipmentSelectionSize=size;
            user.RefreshEquipmentSelectionPreview();user.EquipSelectedNativeEquipment();
            let ammo=CaelumCarbineAmmo(Actor.Spawn("CaelumCarbineAmmo",user.Pos));ammo.Amount=10;ammo.AttachToOwner(user);user.CarbineMagazine=10;user.OnNativeInventoryChanged();
        }
        if(level.time==70){Body.Carbine=new("CaelumCityCarbine");Body.Carbine.Initialize(Body);Body.Carbine.SetCrouched(Body,true);Body.tics=-1;}
        if(Body!=null && Body.Carbine!=null)
        {
            int currentView=CVar.GetCVar("ca143_view").GetInt();int direction=currentView%8;int pose=currentView/8;
            Body.Angle=direction*45;Body.ClearInterpolation();Body.sprite=Body.GetSpriteIndex("CAGC");Body.frame=pose%4;
            SeenViews[pose%4]|=1<<direction;
            if(Stage!=currentView){Stage=currentView;Console.Printf("CA143 VIEW stage=%d angle=%.0f frame=%d",Stage,Body.Angle,Body.frame);}
        }
        if(user.player.crouchfactor<0.51 && user.WeaponModel!=null)
        {
            PlayerWasCrouched=true;
            if(user.WorldCarbineShotUntil>level.time){SawPlayerShot=true;LastPlayerMuzzle=CaelumRangedRules.LaunchHeight(user,CaelumConstants.WEAPON_TYPE_CARBINE);}
        }
        if(level.time==740 && !CVar.GetCVar("ca143_manual").GetBool())
        {
            Check(SeenViews[0]==255 && SeenViews[1]==255 && SeenViews[2]==255 && SeenViews[3]==255,"all eight directions of every crouched pose reach the native scene");
            Check(PlayerWasCrouched && Abs(user.player.crouchfactor-0.5)<0.0001,"native player input reaches the shared half-height crouch floor");
            Check(SawPlayerShot && user.CarbineMagazine<10,"native player input fires finite ammunition while crouched");
            Check(user.sprite==user.GetSpriteIndex("CAGC") && user.crouchsprite==user.GetSpriteIndex("CAGC"),"stationary player uses original crouched art without double compression");
            Check(user.RangedAimModeActive && user.LastCarbineAccuracyPercent>0,"existing player aimed fire remains active");
            Console.Printf("CA143 PLAYER muzzle=%.6f height=%.6f accuracy=%.6f magazine=%d",LastPlayerMuzzle,user.Height,user.LastCarbineAccuracyPercent,user.CarbineMagazine);
        }
        if(level.time==820 && !CVar.GetCVar("ca143_manual").GetBool())
        {
            Check(user.player.crouchfactor>0.99 && user.sprite==user.GetSpriteIndex("CAGN"),"native release returns player to standing carbine art");
            Console.Printf("CA143 COMPLETE checks=%d failures=%d",Checks,Failures);
        }
    }
}
