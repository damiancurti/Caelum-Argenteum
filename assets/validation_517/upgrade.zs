class CA136Upgrade : StaticEventHandler
{
    int Delay,Checks,Failures;bool Reopened,Saved;
    void Check(bool ok,String label)
    {Checks++;if(!ok)Failures++;Console.Printf("CA136 %s %s",ok ? "PASS" : "FAIL",label);}
    override void WorldLoaded(WorldEvent e)
    {if(level.MapName=="CA136"){Delay=10;Reopened=e.IsReopen;Saved=e.IsSaveGame;Checks=0;Failures=0;}}
    override void WorldTick()
    {
        if(level.MapName!="CA136" || Delay<=0 || --Delay>0)return;
        let marker=CA136Saved(ThinkerIterator.Create("CA136Saved").Next());
        if(marker==null){Console.Printf("CA136 FAIL migration marker missing");return;}
        let user=CaelumPlayer(players[0].mo);let record=user.GetPersistentCharacterState(true);
        if(marker.GunId==0 && marker.Gun!=null)
        {marker.GunId=marker.Gun.ItemId;marker.BoxedId=marker.Boxed.ItemId;marker.LongbowId=marker.Longbow.ItemId;}
        marker.Gun=user.FindNativeEquipmentItemById(marker.GunId);
        marker.Boxed=user.FindNativeEquipmentItemById(marker.BoxedId);
        marker.Longbow=user.FindNativeEquipmentItemById(marker.LongbowId);
        Check(marker.Gun!=null && marker.Boxed!=null && marker.Longbow!=null,"stable item identities resolve on current owner after load or hub");
        if(marker.Gun==null || marker.Boxed==null || marker.Longbow==null)return;
        int expected=int(marker.OldDurability*1.2+0.5);
        Console.Printf("CA136 VALUES item=%d model=%d old=%d boxed=%d oldboxed=%d inBox=%d longbow=%d oldlong=%d type=%d",marker.Gun.Durability,user.WeaponModel.Durability,marker.OldDurability,marker.Boxed.Durability,marker.OldBoxedDurability,marker.Boxed.InMagicBox,marker.Longbow.Durability,marker.OldLongbowDurability,marker.Longbow.ItemType);
        Check(marker.Gun.Durability==expected && user.WeaponModel.Durability==expected,"actual old save preserves active condition proportion in item and model");
        Check(marker.Boxed.Durability==int(marker.OldBoxedDurability*1.2+0.5) && marker.Boxed.InMagicBox,"actual old boxed shortbow migrates once and remains boxed");
        Check(marker.Longbow.Durability==marker.OldLongbowDurability && marker.Longbow.ItemType==15,"longbow item is untouched");
        Check(user.FindNativeAmmunition(1).Amount==marker.ArrowAmount && user.LongbowMagazine==11 && user.CrossbowMagazine==7 && user.CarbineMagazine==8,"shared arrows and other magazines survive actual save and hub");
        Check(user.ShotgunRevision==1 && marker.Gun.ShotgunRevision==1 && record.ShotgunRevision==1,"all authoritative migration revisions are committed");
        Check(record.KnowsCraftingRecipe(12) && record.KnowsCraftingRecipe(129),"known replacement recipe and old arrow recipe survive actual load");
        if(CVar.GetCVar("ca136_saved_shells").GetBool())
        {
            Check(user.ShotgunLoadedMask==1 && user.FindNativeAmmunition(6).Amount==9,"loaded left chamber and nine cartridges survive save/hub");
        }
        else
        {
            Check(user.ShotgunLoadedMask==0 && user.FindNativeAmmunition(6)==null,"migration does not turn loaded arrows into shotgun cartridges");
            let shells=CaelumShotgunAmmo(Actor.Spawn("CaelumShotgunAmmo",user.Pos));shells.Amount=9;shells.AttachToOwner(user);
            user.SetRangedMagazineCount(14,1);CVar.GetCVar("ca136_saved_shells").SetBool(true);user.OnNativeInventoryChanged();
        }
        Console.Printf("CA136 UPGRADE saved=%d reopened=%d type=%d tier=%d durability=%d expected=%d",Saved,Reopened,user.WeaponModel.WeaponType,user.WeaponModel.Tier,marker.Gun.Durability,expected);
        Console.Printf("CA136 COMPLETE checks=%d failures=%d",Checks,Failures);
    }
}
