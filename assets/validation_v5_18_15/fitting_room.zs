version "4.14.2"
class FittingEye : Actor
{
    Default { +NOGRAVITY +NOINTERACTION }
    States { Spawn: TNT1 A -1; Stop; }
}
class FittingRoom : StaticEventHandler
{
    Actor eye;
    CaelumArmorPickup groundHelmet;
    bool onFloor;
    CaelumShieldPickup testShield;
    int form, item, rotation, face, hair, helmetTier;
    bool still;
    bool combination, report, seated, detail;
    int reference, previousReference;
    override void NetworkProcess(ConsoleEvent e)
    {
        if(level.MapName!="VESTIDOR")return;
        if(e.Name=='outfit_select')
        {
            form=Clamp(e.Args[0],0,13);item=Clamp(e.Args[1],0,ITEM_COUNT);combination=false;reference=0;
            if(e.Args[2]>0)helmetTier=Clamp(e.Args[2],1,3);
        }
        else if(e.Name=='outfit_reference')reference=e.Args[0];
        else if(e.Name=='outfit_item')item=(ITEM_COUNT+1+item+e.Args[0])%(ITEM_COUNT+1);
        else if(e.Name=='outfit_form')form=(14+form+e.Args[0])%14;
        else if(e.Name=='outfit_turn')rotation+=e.Args[0];
        else if(e.Name=='outfit_seat')seated=!seated;
        else if(e.Name=='outfit_empty'){item=0;combination=false;}
        else if(e.Name=='outfit_next_tier')helmetTier=1+helmetTier%3;
        else if(e.Name=='outfit_tier')helmetTier=Clamp(e.Args[0],1,3);
        else if(e.Name=='outfit_ground')
        {
            static const int slots[]={SLOTS};
            if(slots[item]==2)onFloor=!onFloor;
            else {cycleSlot(2);onFloor=true;}
        }
        else if(e.Name=='outfit_floor')onFloor=e.Args[0]!=0;
        else if(e.Name=='outfit_helm')cycleSlot(2);
        else if(e.Name=='outfit_face')face=(face+1)%4;
        else if(e.Name=='outfit_hair')hair=(hair+1)%4;
        else if(e.Name=='outfit_still')still=true;
        else if(e.Name=='outfit_shield')cycleSlot(1);
        else if(e.Name=='outfit_detail')detail=e.Args[0]!=0;
        else if(e.Name=='outfit_zoom')detail=!detail;
        else if(e.Name=='outfit_angle')rotation=e.Args[0];
        else if(e.Name=='outfit_boots')cycleSlot(5);
        else if(e.Name=='outfit_set')combination=!combination;
        else return;
        report=true;
    }
    void cycleSlot(int wanted)
    {
        static const int slots[]={SLOTS};
        do {item=(item+1)%(ITEM_COUNT+1);} while(slots[item]!=wanted);
        combination=false;
    }
    override void WorldTick()
    {
        if(level.MapName!="VESTIDOR")return;
        let p=CaelumPlayer(players[0].mo);
        if(p==null || !p.CharacterProfile || !p.WeaponModel || !p.ShieldModel || !p.ArmorModel)return;
        if(!eye)
        {
            eye=Actor.Spawn('FittingEye',(0,0,0),NO_REPLACE);
            if(!eye)return;
            testShield=CaelumShieldPickup(Actor.Spawn('CaelumShieldPickup',p.Pos,NO_REPLACE));
            testShield.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_SHIELD;
            testShield.EquipmentSize=p.ShieldModel.Size;testShield.Tier=1;testShield.ArmorSlot=-1;
            testShield.PickupDataInitialized=true;testShield.AcquisitionResolved=true;testShield.ItemId=904001;
            testShield.AttachToOwner(p);testShield.InMagicBox=false;
            item=0;cycleSlot(2);helmetTier=1;detail=true;report=true;
            p.SetOrigin((0,0,0),false);
            players[0].Camera=eye;
        }
        let look=p.CharacterProfile;
        look.Race=form<2?CaelumConstants.RACE_HUMAN:form<4?CaelumConstants.RACE_CAELITH:form<6?CaelumConstants.RACE_GOBLIN:CaelumConstants.RACE_BEAST_MAN;
        look.Sex=form%2;look.BeastForm=form<6?0:(form-6)/2;
        look.SkinTone=0;look.Face=face;look.HairStyle=hair;look.HairColor=1;
        static const int slots[]={SLOTS};
        static const int kinds[]={KINDS};
        static const int tiers[]={TIERS};
        int chosen=slots[item];
        int material=(form+1)%4;
        p.WeaponModel.WeaponType=chosen==0?kinds[item]:CaelumConstants.WEAPON_TYPE_SWORD;
        p.WeaponModel.Tier=chosen==0?tiers[item]:1;
        p.WeaponModel.Equipped=chosen==0 || combination;
        p.ShieldModel.ShieldType=chosen==1?kinds[item]:CaelumConstants.SHIELD_TYPE_BUCKLER;
        testShield.ItemType=p.ShieldModel.ShieldType;
        testShield.Durability=p.ShieldModel.GetMaximumDurabilityFor(testShield.ItemType,1,testShield.EquipmentSize);
        testShield.Equipped=chosen==1 || (combination && p.CanUseShieldWithEquippedWeapon());
        p.EquippedShieldItemId=testShield.Equipped?testShield.ItemId:0;
        p.ShieldModel.SourceItem=testShield.Equipped?testShield:null;p.ShieldModel.Durability=testShield.Durability;
        p.ShieldModel.Equipped=testShield.Equipped;
        for(int i=0;i<CaelumConstants.ARMOR_SLOT_COUNT;i++)
            p.ArmorModel.ArmorType[i]=chosen==i+2?kinds[item]:combination?material:CaelumConstants.ARMOR_TYPE_BASE_CLOTHING;
        p.ArmorModel.Tier[CaelumConstants.ARMOR_SLOT_HEAD]=helmetTier;
        p.Angle=270;p.Vel=(0,0,0);
        if(seated)p.SetState(p.FindState('RestSeated'));
        else if(still || p.CurState==p.FindState('RestSeated'))p.SetState(p.SpawnState);
        // Quitar una referencia forzada devuelve el control a los enlaces del jugador.
        if(previousReference!=0 && previousReference!=reference)
        {
            p.FamilyVisualKey=0;p.WornVisualKeys[2]=0;
        }
        previousReference=reference;
        p.UpdateWorldCarbineVisual();
        if((reference==3 || reference==4) && chosen==2)
        {
            String base=String.Format("a0_%d",kinds[item]);
            p.A_ChangeModel('None',9,"models/caelum/players/gear",Name(base..".md3"),9,
                "models/caelum/players/gear",Name(base..".png"),CMDL_HIDEMODEL);
            if(reference==4)
            {
                String head=String.Format("head%d_%d",form,form<6?face:0);
                CaelumFamilyModels.BindSlot(p,5,(kinds[item]==3?"tuck/":"open/")..head..".md3",head.."_0.png");
                if(form<6)
                {
                    String style=String.Format("hair%d_%d",form,hair);
                    CaelumFamilyModels.BindSlot(p,6,"tuck/"..style..".md3",style.."_1.png");
                }
            }
        }
        else if(reference && chosen==2)
        {
            // Referencia independiente para comparar el modelo elegido por el juego.
            int family=reference==2?0:form/2;
            int quality=reference==6?1:helmetTier;
            String base=String.Format("a0_%d",kinds[item]);
            String model=family?String.Format("%s_f%d.md3",base,family):base..".md3";
            p.A_ChangeModel('None',9,"models/caelum/players/gear",Name(model),9,
                "models/caelum/players/gear",Name(base..(quality>1?String.Format("_t%d",quality):"")..".png"),0);
        }
        double height=CaelumAppearanceRegistry.StandingHeight(form,false)*p.Scale.Y;
        double direction=292+rotation*30;
        double dist=height*(detail?(chosen==2?.55:.79):1.35);
        double eyeHeight=height*(detail && chosen==2?.62:detail && chosen==5?.10:.40);
        Vector3 eyePos=(cos(direction)*dist,sin(direction)*dist,eyeHeight);
        double pitch=0;
        if(groundHelmet)groundHelmet.bInvisible=!(onFloor && chosen==2);
        if(onFloor && chosen==2)
        {
            if(!groundHelmet)
                groundHelmet=CaelumArmorPickup(Actor.Spawn('CaelumArmorPickup',(100,0,p.FloorZ),NO_REPLACE));
            if(groundHelmet)
            {
                groundHelmet.args[0]=CaelumConstants.ARMOR_SLOT_HEAD;
                groundHelmet.args[1]=kinds[item];groundHelmet.args[2]=helmetTier;
                groundHelmet.Angle=p.Angle;
                groundHelmet.UpdateWorldSprite();
                double radius=detail?18:33;
                eyePos=groundHelmet.Pos+(cos(direction)*radius,sin(direction)*radius,radius*.28+1);
                // El penacho del pesado debe quedar por debajo de los controles.
                pitch=kinds[item]==CaelumConstants.ARMOR_TYPE_HEAVY?24:32;
                if(report)Console.Printf("FLOOR kind=%d tier=%d frame=%d",groundHelmet.PreviewItemType(),
                    groundHelmet.PreviewTier(),groundHelmet.frame);
            }
        }
        eye.SetOrigin(eyePos,false);
        eye.Angle=direction+180;eye.Pitch=pitch;
        if(report)
        {
            Console.Printf("FITTING form=%d resolved=%d item=%d slots=%d,%d,%d,%d,%d,%d",form,CaelumAppearance.Identity(look.Race,look.Sex,look.BeastForm),item,p.WornVisualKeys[0],p.WornVisualKeys[1],p.WornVisualKeys[2],p.WornVisualKeys[3],p.WornVisualKeys[4],p.WornVisualKeys[5]);
            if(chosen==2)Console.Printf("HELMET kind=%d tier=%d key=%d",kinds[item],p.ArmorModel.Tier[0],p.WornVisualKeys[2]);
            Console.Printf("FITPOSE pose=%d seated=%d",p.AppearancePose,seated);
            if(reference)Console.Printf("REFERENCE form=%d item=%d mode=%d",form,item,reference);
            report=false;
        }
    }
    override void RenderOverlay(RenderEvent e)
    {
        if(level.MapName!="VESTIDOR")return;
        static const String bodies[]={BODIES};
        static const String pieces[]={PIECES};
        String title=String.Format("%s   |   %s",bodies[form],pieces[item]);
        static const int slots[]={SLOTS};
        if(slots[item]==2 || combination)title=title..String.Format("   |   Tier %d",helmetTier);
        Screen.DrawText(SmallFont,Font.CR_WHITE,320-SmallFont.StringWidth(title)/2,7,title,DTA_VirtualWidth,640,DTA_VirtualHeight,360,DTA_KeepRatio,true);
        String mode=combination?"Conjunto equipado":"Pieza sola";
        if(onFloor && slots[item]==2)mode="En el suelo";
        else if(seated)mode=mode.."  |  Sentado";
        Screen.DrawText(SmallFont,Font.CR_GRAY,320-SmallFont.StringWidth(mode)/2,19,mode,DTA_VirtualWidth,640,DTA_VirtualHeight,360,DTA_KeepRatio,true);
        String keys="B Botas   S Postura   E Escudos   H Cascos   T Tier   G Suelo   0 Quitar   Z Zoom";
        Screen.DrawText(SmallFont,Font.CR_GRAY,320-SmallFont.StringWidth(keys)/2,31,keys,DTA_VirtualWidth,640,DTA_VirtualHeight,360,DTA_KeepRatio,true);
    }
}
