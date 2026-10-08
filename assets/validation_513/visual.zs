// Isolated camera/pose inspection controls; no gameplay code depends on these CVars.
class CA133Visual : EventHandler
{
    int Scene;
    CaelumPortDefender Model;
    override void OnRegister(){Scene=-1;}
    override void WorldTick()
    {
        if(level.time<75)return;
        let user=CaelumPlayer(players[0].mo);let port=CaelumPortSiege.Get();if(user==null || port==null)return;
        int requested=CVar.GetCVar("ca133_view").GetInt();
        if(requested!=Scene)
        {
            user.CreationWizardOpen=false;user.ClosePalomoMerchant();user.GrantMagicBoxFromPalomo(false);
            if(requested==0)
            {
                let vendor=CaelumCityMerchant.Find(5);user.SetOrigin(vendor.Pos+(48,0,0),false);user.Angle=180;user.Pitch=0;
                user.FolkloreInteractionUseLatched=false;
            }
            else if(requested==1)
            {user.SetOrigin(CaelumCityData.HouseOrigin(0)+(800,512,0),false);user.Angle=135;user.Pitch=0;}
            else if(requested==2)
            {
                if(Model==null)
                {
                    Model=CaelumPortDefender(Actor.Spawn("CA133VisualModel",CaelumCityData.HouseRoad(0)));
                    Model.tics=-1;
                }
                user.SetOrigin(Model.Pos+(160,0,0),false);user.Angle=180;user.Pitch=0;
            }
            else if(requested==3 || requested==4)
            {
                int type=requested==3 ? CaelumConstants.WEAPON_TYPE_CARBINE : CaelumConstants.WEAPON_TYPE_SWORD;
                let stock=CaelumCityMerchant.Find(2);int size=CaelumEquipmentRules.ResolveAcquisitionSize(user,CaelumEquipmentRules.CHARACTER_DEFAULT,CaelumConstants.EQUIPMENT_SIZE_M);
                stock.SeedEquipment(user,CaelumConstants.EQUIPMENT_KIND_WEAPON,type,0,size,0);
                let item=CaelumEquipmentItem(stock.Inv);stock.RemoveInventory(item);item.AttachToOwner(user);item.AcquisitionResolved=true;
                user.EnsureEquipmentItemId(item);user.EquipmentSelectionItemId=item.ItemId;user.EquipmentSelectionKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;
                user.EquipmentSelectionWeaponType=type;user.EquipmentSelectionTier=1;user.EquipmentSelectionSize=size;
                user.RefreshEquipmentSelectionPreview();user.EquipSelectedNativeEquipment();
                if(requested==3){let ammo=CaelumCarbineAmmo(Actor.Spawn("CaelumCarbineAmmo",user.Pos));ammo.Amount=100;ammo.AttachToOwner(user);user.CarbineMagazine=10;}
                user.SetOrigin(CaelumCityData.HouseRoad(0)+(0,512,0),false);user.Angle=90;user.Pitch=0;
            }
            Scene=requested;Console.Printf("CA133 VISUAL scene=%d ready",Scene);
        }
        if(Scene==2 && Model!=null)
        {
            Model.Angle=45*(CVar.GetCVar("ca133_angle").GetInt()%8);
        }
        if(Scene==3 && level.time%10==0)Console.Printf("CA133 PLAYER_VISUAL tic=%d sprite=%d frame=%d magazine=%d reload=%d remaining=%.3f shotUntil=%d",level.time,user.sprite,user.frame,user.CarbineMagazine,user.RangedReloadActive,user.RangedReloadRemainingSeconds,user.WorldCarbineShotUntil);
    }
}

class CA133VisualModel : CaelumPortDefender
{
    override void Tick()
    {
        Super.Tick();
        Angle=45*(CVar.GetCVar("ca133_angle").GetInt()%8);
        sprite=GetSpriteIndex("CAGN");frame=Clamp(CVar.GetCVar("ca133_pose").GetInt(),0,5);
    }
}
