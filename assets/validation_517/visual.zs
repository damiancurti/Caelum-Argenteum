class CA136Visual : CA136Checks
{
    CaelumPortDefender Body;int LastMode,Seen[6],LastView;bool Shot,Reload;
    override void WorldTick()
    {
        if(level.MapName!="CA136")return;
        let user=CaelumPlayer(players[0].mo);
        if(level.time==1){user.InitializeDirectMapCharacter();user.PersistCharacterState();user.bNOTARGET=true;LastMode=-1;LastView=-1;}
        if(level.time==60)
        {
            Gun=Equip(user,14);Shells=CaelumShotgunAmmo(Actor.Spawn("CaelumShotgunAmmo",user.Pos));Shells.Amount=20;Shells.AttachToOwner(user);
            user.SetRangedMagazineCount(14,2);user.OnNativeInventoryChanged();
            user.bINVULNERABLE=true;user.Angle=90;user.Pitch=0;user.SetOrigin((2300,4310,0),false);
            Body=CaelumPortDefender(Actor.Spawn("CA136Soldier",(2300,4490,0)));Body.tics=-1;
        }
        if(level.time<65)return;
        Shot=Shot || Shells.Amount<20;Reload=Reload || user.RangedReloadActive;
        int mode=CVar.GetCVar("ca136_mode").GetInt();
        if(mode!=LastMode)
        {
            LastMode=mode;
            if(mode==2 || mode==3){Gun.Tier=mode;user.WeaponModel.Tier=mode;user.PersistCharacterState();user.ApplyCharacterProfile();}
            if(mode==5 || mode==6)
            {
                Shells.Amount=mode==5 ? 1 : 10;user.SetRangedMagazineCount(14,mode==5 ? 0 : 1);
                user.RequestRangedReload(14);
            }
            if(mode==4)
            {
                Check(Shot && Reload,"actual player input fires and reloads shotgun");
                Check(Seen[0]==255 && Seen[1]==255 && Seen[2]==255 && Seen[3]==255 && Seen[4]==255 && Seen[5]==255,"all 48 directional world frames rendered");
                Console.Printf("CA136 COMPLETE checks=%d failures=%d",Checks,Failures);
            }
        }
        if(mode==1)
        {
            int view=CVar.GetCVar("ca136_view").GetInt(),pose=view/8,direction=view%8;
            Body.Angle=direction*45;Body.ClearInterpolation();Body.sprite=Body.GetSpriteIndex("SHGW");Body.frame=pose;
            Seen[pose]|=1<<direction;
            if(view!=LastView){LastView=view;Console.Printf("CA136 VIEW %d angle=%d pose=%d",view,direction*45,pose);}
        }
    }
}
