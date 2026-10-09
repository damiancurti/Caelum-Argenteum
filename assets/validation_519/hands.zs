// Isolated visual follow-up; pose changes do not enter the production package.
class CA152Hands : StaticEventHandler
{
    int Elapsed,LastStage;
    override void WorldLoaded(WorldEvent e){Elapsed=0;LastStage=-1;}
    override void WorldTick()
    {
        let u=CaelumPlayer(players[0].mo);if(u==null)return;Elapsed++;
        if(Elapsed==10){u.InitializeDirectMapCharacter();u.PersistCharacterState();u.bNOTARGET=true;u.bINVULNERABLE=true;}
        if(Elapsed==60)
        {
            let helper=new("CA136Checks");helper.Equip(u,14);
            u.GiveInventory("CaelumShotgunAmmo",20);u.SetRangedMagazineCount(14,2);
            u.Angle=90;u.Pitch=0;u.SetOrigin((2300,4310,0),false);
        }
        if(Elapsed<80)return;
        int stage=CVar.GetCVar("ca152_stage").GetInt();
        if(stage!=LastStage)
        {
            LastStage=stage;
            if(stage==3 || stage==4)
            {
                u.FindNativeAmmunition(6).Amount=stage==3 ? 1 : 10;
                u.SetRangedMagazineCount(14,stage==3 ? 0 : 1);
                u.RequestRangedReload(14);
            }
            if(stage>=5 && stage<=9)
            {
                let helper=new("CA136Checks");
                helper.Equip(u,stage==7 ? 2 : stage==9 ? CaelumConstants.WEAPON_TYPE_DAGGER : 14,
                    stage==5 ? 2 : stage==6 ? 3 : 1);
            }
            if(stage==10)Console.Printf("CA152 HANDS COMPLETE");
        }
        if(Elapsed%7==0)
        {
            let a=u.player.FindPSprite(48);let b=u.player.FindPSprite(49);let c=u.player.FindPSprite(51);
            Console.Printf("CA152 HANDS stage=%d tier=%d kind=%d aim=%d reload=%d remaining=%.3f layers=%d,%d,%d",stage,u.WeaponModel.Tier,u.WeaponModel.WeaponType,u.RangedAimModeActive,u.RangedReloadActive,u.RangedReloadRemainingSeconds,a!=null,b!=null,c!=null);
        }
    }
}
