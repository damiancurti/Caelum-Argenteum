// Comprueba la selección real, disparo, recarga y guardado con el nombre nuevo.
class CA192Selector : EventHandler
{
    int Passes,Failures;
    CaelumEquipmentItem Gun;
    CaelumShotgunAmmo Shells;
    bool Shot,Reload;
    void Check(bool ok,String label)
    {if(ok)Passes++;else Failures++;Console.Printf("CA192 %s %s",ok?"PASS":"FAIL",label);}
    override void UiTick(){if(Menu.GetCurrentMenu()!=null)Menu.GetCurrentMenu().Close();}
    override void WorldTick()
    {
        let user=CaelumPlayer(players[0].mo);
        if(level.time==1){user.InitializeDirectMapCharacter();user.PersistCharacterState();user.bNOTARGET=true;}
        if(level.time==40)
        {
            user.CharacterCreationComplete=true;user.CreationWizardOpen=false;user.bINVULNERABLE=true;
            let vendor=CaelumCityMerchant(Actor.Spawn("CaelumCityMerchant",user.Pos+(256,0,0)));
            vendor.SeedEquipment(user,CaelumConstants.EQUIPMENT_KIND_WEAPON,CaelumConstants.WEAPON_TYPE_SHOTGUN,0,CaelumConstants.EQUIPMENT_SIZE_M,0);
            Gun=CaelumEquipmentItem(vendor.Inv);vendor.RemoveInventory(Gun);Gun.AttachToOwner(user);
            Gun.AcquisitionResolved=true;Gun.Tier=1;user.EnsureEquipmentItemId(Gun);
            user.EquipmentSelectionItemId=Gun.ItemId;user.EquipmentSelectionKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;
            user.EquipmentSelectionWeaponType=CaelumConstants.WEAPON_TYPE_SHOTGUN;user.EquipmentSelectionTier=1;
            user.EquipmentSelectionSize=CaelumConstants.EQUIPMENT_SIZE_M;
            user.RefreshEquipmentSelectionPreview();user.EquipSelectedNativeEquipment();vendor.Destroy();
            Shells=CaelumShotgunAmmo(Actor.Spawn("CaelumShotgunAmmo",user.Pos));Shells.Amount=20;Shells.AttachToOwner(user);
            user.SetRangedMagazineCount(CaelumConstants.WEAPON_TYPE_SHOTGUN,2);user.OnNativeInventoryChanged();
            Check(user.GetNativeWeaponSelectorClass(CaelumConstants.WEAPON_TYPE_SHOTGUN,0,1)== 'CaelumShotgunSelectorWeapon',"shotgun selector lookup renamed");
            Check(CaelumFirstPersonView.Family(CaelumConstants.WEAPON_TYPE_SHOTGUN)=="shotgun","shotgun frame family renamed");
            for(int tier=1;tier<=3;tier++)for(int phase=0;phase<3;phase++)
                Check(CaelumFirstPersonView.Pose(CaelumConstants.WEAPON_TYPE_SHOTGUN,tier,phase)!=null,"renamed frame label resolves");
        }
        if(level.time>40 && Shells!=null)
        {Shot=Shot || Shells.Amount<20;Reload=Reload || user.RangedReloadActive;}
    }
    override void NetworkProcess(ConsoleEvent e)
    {
        if(e.Name!="ca192_selector")return;
        let user=CaelumPlayer(players[e.Player].mo);
        Check(user.player.ReadyWeapon is 'CaelumShotgunSelectorWeapon',"native ready weapon has shotgun class");
        Check(Gun!=null && Gun.Equipped && Gun.ItemType==CaelumConstants.WEAPON_TYPE_SHOTGUN,"equipped physical item remains shotgun");
        Check(Shot,"real attack input spends shotgun cartridge");
        Check(Reload,"real reload input starts shotgun reload");
        Check(user.GetRangedMagazineCount(CaelumConstants.WEAPON_TYPE_SHOTGUN)==2,"both barrels loaded after reload");
        Console.Printf("CA192 DONE failures=%d passes=%d",Failures,Passes);
    }
}
