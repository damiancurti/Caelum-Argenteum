// Galería privada: reutiliza selección, equipamiento y manos de producción.
class CA479Gallery : EventHandler
{
    int Selection;
    CaelumEquipmentItem Held,WorldItem;
    void Show(CaelumPlayer user)
    {
        if(Held!=null){Held.Destroy();Held=null;}
        if(WorldItem!=null){WorldItem.Destroy();WorldItem=null;}
        user.CreationWizardOpen=false;user.CharacterCreationComplete=true;
        user.CurrentHunger=100;user.CurrentThirst=100;user.CurrentSleep=100;
        user.SetOrigin((-96,0,0),false);user.Angle=0;user.Pitch=12;
        int index=Selection/3,tier=Selection%3+1;
        int kind=index==0?18:index==1?19:23+index-2;
        Held=CaelumEquipmentItem(Actor.Spawn("CaelumWeaponPickup",user.Pos,NO_REPLACE));
        Held.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;Held.ItemType=kind;
        Held.EssenceType=kind<23?0:4;Held.Tier=tier;Held.EquipmentSize=CaelumConstants.EQUIPMENT_SIZE_M;
        Held.PickupDataInitialized=true;Held.SizePolicy=CaelumEquipmentRules.FIXED_SIZE;
        Held.UnitWeight=user.WeaponModel.GetWeightFor(kind,tier,Held.EquipmentSize);
        Held.Durability=Held.PreviewMaximumDurability(user);Held.Equipped=true;Held.AttachToOwner(user);
        user.EnsureEquipmentItemId(Held);user.EnsureWeaponFamilySelectors();
        bool activated=CaelumInventoryService.ActivateExactEquippedWeapon(user,Held);
        user.RefreshCarriedInventorySummary();user.RefreshFormalInventorySnapshot();
        WorldItem=CaelumEquipmentItem(Actor.Spawn("CaelumWeaponPickup",(16,0,0),NO_REPLACE));
        WorldItem.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_WEAPON;WorldItem.ItemType=kind;
        WorldItem.Tier=tier;WorldItem.EssenceType=Held.EssenceType;WorldItem.PickupDataInitialized=true;
        WorldItem.UpdateWorldSprite();
        Console.Printf("CA479 %s gallery selected kind=%d tier=%d",activated?"PASS":"FAIL",kind,tier);
    }
    override void NetworkProcess(ConsoleEvent event)
    {
        if(level.MapName!="CSUP479")return;
        let user=CaelumPlayer(players[event.Player].mo);if(user==null)return;
        if(event.Name=="ca479_gallery"){Selection=0;Show(user);}
        if(event.Name=="ca479_next"){Selection=(Selection+1)%18;Show(user);}
        if(event.Name=="ca479_artcheck")
        {
            int invalid=0;
            for(int index=0;index<6;index++)
            {
                int kind=index==0?18:index==1?19:23+index-2;
                if(!TexMan.CheckForTexture(CaelumSupportArt.Icon(kind),TexMan.Type_MiscPatch).IsValid())invalid++;
                for(int tier=1;tier<=3;tier++)
                {
                    if(CaelumSupportArt.Pose(kind,tier)==null)invalid++;
                    if(!TexMan.CheckForTexture(CaelumIconResolver.ResolveTierPath(CaelumIconResolver.GetWeaponBasePath(kind),tier),TexMan.Type_MiscPatch).IsValid())invalid++;
                }
            }
            Console.Printf("CA479 %s all implement icons and native poses resolve",invalid==0?"PASS":"FAIL");
            Console.Printf("CA479 RESULT gallery assets invalid=%d",invalid);
        }
    }
}
