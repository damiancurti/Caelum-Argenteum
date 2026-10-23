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
        if(event.Name=="ca479_orb"){Selection=3;Show(user);}
        if(event.Name=="ca479_orbfemale"){user.CharacterProfile.Sex=1;}
        if(event.Name=="ca479_orbcheck")
        {
            bool palms=true;
            for(int variant=-1;variant<37;variant++)
                palms=palms && GetDefaultByType("CaelumOrbHandFrames").FindStateByString(variant<0?"Fallback":String.Format("Hand%d",variant))!=null;
            int active=CaelumAppearanceHands.Variant(user);
            State expected=GetDefaultByType("CaelumOrbHandFrames").FindStateByString(active<0?"Fallback":String.Format("Hand%d",active));
            let hand=user.player.FindPSprite(52);
            Console.Printf("CA479 %s all original Book palm variants resolve",palms?"PASS":"FAIL");
            Console.Printf("CA479 %s Orb uses active appearance palm variant=%d",hand!=null && hand.CurState==expected?"PASS":"FAIL",active);
            Console.Printf("CA479 %s Orb shares original Book palm pivot",CaelumFirstPersonLayers.Grip(19)==CaelumAppearanceHands.ComposedPivot(23,0)?"PASS":"FAIL");
            Console.Printf("CA479 RESULT floating Orb presentation checked");
        }
        if(event.Name=="ca479_next"){Selection=(Selection+1)%18;Show(user);}
        if(event.Name=="ca479_inventory" && Held!=null)
        {
            user.FormalInventoryFilter=1;user.RefreshFormalInventorySnapshot();
            bool selected=false;
            for(int i=0;i<user.FormalInventoryEntryCount;i++)
                if(user.GetFormalInventoryEntryAt(i)==Held){user.FormalInventorySelectionIndex=i;selected=true;break;}
            user.RefreshFormalInventorySnapshot();
            String path=CaelumIconResolver.ResolveEquipmentPath(Held.EquipmentKind,Held.ItemType,0,Held.Tier);
            Console.Printf("CA479 %s inventory selection and icon kind=%d tier=%d",selected && TexMan.CheckForTexture(path,TexMan.Type_MiscPatch).IsValid()?"PASS":"FAIL",Held.ItemType,Held.Tier);
        }
        if(event.Name=="ca479_legacyart")
        {
            bool poses=true,icons=true,hands=true;
            for(int which=0;which<2;which++)for(int tier=1;tier<=3;tier++)
            {
                int kind=which==0?23:25;String key=which==0?"book":"statuette";
                String expected="graphics/caelum/icons/ca_"..key..(tier==1?"":String.Format("_t%d",tier))..".png";
                icons=icons && CaelumIconResolver.ResolveEquipmentPath(CaelumConstants.EQUIPMENT_KIND_WEAPON,kind,0,tier)==expected;
                for(int phase=0;phase<(which==0?2:1);phase++)
                {
                    String label=String.Format("%s_T%d_%s",key,tier,phase==1?"B":"A");
                    State original=GetDefaultByType("CaelumFirstPersonFrames").FindStateByString("CA_FP1_"..label);
                    poses=poses && original!=null && CaelumFirstPersonView.Pose(kind,tier,phase)==original;
                    hands=hands && CaelumAppearanceHands.Composed(user,kind,tier,phase,original)==CaelumAppearanceHands.Resolve(user,label,original);
                }
            }
            Console.Printf("CA479 %s accepted Book and Statuette pose identities restored",poses?"PASS":"FAIL");
            Console.Printf("CA479 %s accepted Book and Statuette inventory icons restored",icons?"PASS":"FAIL");
            Console.Printf("CA479 %s accepted character hand compositions restored",hands?"PASS":"FAIL");
        }
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
