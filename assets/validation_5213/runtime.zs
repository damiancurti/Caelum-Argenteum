// Isolated native contract checks. No fixture is packaged with the game.
class CA148Runtime : StaticEventHandler
{
    int Failures;
    bool Done;
    ui bool CoverageDone;
    void Check(bool ok,String label)
    { if(!ok)Failures++;Console.Printf("CA148 %s %s",ok?"PASS":"FAIL",label); }

    override void UiTick()
    {
        if(CoverageDone)return;CoverageDone=true;
        int missing=0,total=0;
        let state=GetDefaultByType("CaelumPlayer").SpawnState;
        for(int race=0;race<4;race++)for(int sex=0;sex<2;sex++)
        for(int form=0;form<(race==0?4:1);form++)for(int tone=0;tone<3;tone++)
        for(int gloves=0;gloves<2;gloves++)for(int pose=0;pose<CaelumAppearance.POSE_COUNT;pose++)
        for(int angle=0;angle<8;angle++)
        {
            TextureID tex;bool flip;Vector2 scale;
            int sprite=CaelumAppearance.SpriteFor(race,sex,form,tone,pose,gloves!=0);
            [tex,flip,scale]=state.GetSpriteTexture(angle*2,0,(1,1),sprite,pose%26);
            if(sprite<0 || !tex.IsValid())missing++;
            total++;
        }
        Console.Printf("CA148 %s all %d world textures (42 looks, 29 poses, 8 views, gloves/bare), missing=%d",missing==0?"PASS":"FAIL",total,missing);
    }

    override void WorldTick()
    {
        if(Done || level.time<35)return;Done=true;
        let user=CaelumPlayer(players[0].mo);
        let profile=CaelumCharacterIdentity.Profile(user);
        int race=profile.Race,sex=profile.Sex,tone=profile.SkinTone,form=profile.BeastForm;
        int health=user.health,profession=profile.GetProfession(),size=profile.GetSizeTier();
        double air=user.CurrentAir,anima=user.CurrentAnima;
        bool valid=CaelumAppearance.Valid(0,0) && CaelumAppearance.Valid(2,3)
            && !CaelumAppearance.Valid(-1,0) && !CaelumAppearance.Valid(3,0)
            && !CaelumAppearance.Valid(0,-1) && !CaelumAppearance.Valid(0,4);
        Check(valid,"finite tone/form bounds");
        int missing=0,looks=0;
        for(int r=0;r<4;r++)for(int s=0;s<2;s++)
        for(int f=0;f<(r==0?4:1);f++)for(int t=0;t<3;t++)
        {
            profile.Race=r;profile.Sex=s;profile.BeastForm=f;profile.SkinTone=t;
            int expected=(r==0?2+f:r==1?1:0)*3+t;
            if(CaelumAppearanceHands.Variant(user)!=expected)missing++;
            for(int h=0;h<13;h++)
                if(h==0 || (h>=3 && h<=7) || h==9 || h==10 || h==12)
                    if(CaelumAppearanceHands.Hand(user,h)==null)missing++;
            if(CaelumAppearanceHands.Resolve(user,"Bolas",null)==null)missing++;
            for(int p=0;p<7;p++)if(CaelumAppearanceHands.Resolve(user,String.Format("Shotgun_%d",p),null)==null)missing++;
            for(int k=0;k<20;k++)if(k==1 || k==6 || k==9 || k>=17)
                for(int tier=1;tier<=3;tier++)
                    if(CaelumAppearanceHands.Composed(user,k,tier,0,null)==null)missing++;
            if(CaelumCharacterIdentity.VoiceSex(user)!=s)missing++;
            looks++;
        }
        Check(missing==0 && looks==42,"all 42 looks resolve modular/composed/bolas/shotgun hands and saved-sex voices");
        profile.Race=race;profile.Sex=sex;profile.SkinTone=tone;profile.BeastForm=form;
        Check(user.health==health && user.CurrentAir==air && user.CurrentAnima==anima
            && profile.GetProfession()==profession && profile.GetSizeTier()==size,"cosmetic lookups preserve resources and structural values");
        let gloves=CaelumEquipmentItem(Actor.Spawn("CaelumEquipmentItem"));
        gloves.EquipmentKind=CaelumConstants.EQUIPMENT_KIND_ARMOR;
        gloves.ItemType=CaelumConstants.ARMOR_TYPE_LIGHT;
        gloves.ArmorSlot=CaelumConstants.ARMOR_SLOT_HANDS;
        gloves.ItemId=990148;gloves.AcquisitionResolved=true;gloves.Equipped=true;
        user.AddInventory(gloves);user.EquippedArmorItemId[2]=gloves.ItemId;
        Check(CaelumAppearanceHands.HasGloves(user) && CaelumAppearanceHands.Variant(user)==-1,"owned equipped gloves select original artwork");
        gloves.Durability=0;
        Check(CaelumAppearanceHands.HasGloves(user),"broken gloves remain visibly equipped");
        gloves.Equipped=false;
        Check(!CaelumAppearanceHands.HasGloves(user) && CaelumAppearanceHands.Variant(user)>=0,"unequip restores saved bare hands");
        gloves.Equipped=true;gloves.InMagicBox=true;
        Check(!CaelumAppearanceHands.HasGloves(user),"boxed item cannot supply glove appearance");
        user.EquippedArmorItemId[2]=0;gloves.Destroy();
        Check(CaelumAppearanceHands.ComposedPivot(17,0)==(236.5,125)
            && CaelumAppearanceHands.ComposedPivot(18,1)==(227,161)
            && CaelumAppearanceHands.ComposedPivot(6,0)==(235,157.5),"fallback grip pivots match original source manifest");
        user.UpdateWorldCarbineVisual();
        Check(user.sprite==CaelumAppearance.SpriteFor(profile.Race,profile.Sex,profile.BeastForm,profile.SkinTone,
            CaelumAppearance.PoseFor(user.CurState.sprite,user.CurState.Frame)),"world appearance comes from bound saved profile");
        Console.Printf("CA148 DONE failures=%d",Failures);
    }
}
