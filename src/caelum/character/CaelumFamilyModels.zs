// Presentación modular. Los índices proceden del perfil ya validado por el juego.
class CaelumFamilyModels : Object play
{
    static void BindSlot(Actor body,int slot,String mesh,String skin,bool visible=true)
    {
        body.A_ChangeModel('None',slot,"models/caelum/players",Name(mesh),slot,
            "models/caelum/players",Name(skin),visible?0:CMDL_HIDEMODEL);
    }

    static bool WearsArmor(CaelumPlayer body,int slot)
    {
        int key=body.WornVisualKeys[2+slot];
        if(body.health<=0 && key!=0)return key>0;
        return body.ArmorModel!=null && body.ArmorModel.ArmorType[slot]!=CaelumConstants.ARMOR_TYPE_BASE_CLOTHING;
    }

    static void Bind(CaelumPlayer body,CaelumCharacterProfile profile,bool gloves)
    {
        int id=CaelumAppearance.Identity(profile.Race,profile.Sex,profile.BeastForm);
        int tone=Clamp(profile.SkinTone,0,2);
        int face=id<6?Clamp(profile.Face,0,3):0;
        int hair=id<6?Clamp(profile.HairStyle,0,3):0;
        int color=id<6?Clamp(profile.HairColor,0,5):0;
        int key=(((((id*3+tone)*4+face)*4+hair)*6+color)*2+int(gloves))+1;
        bool boots=WearsArmor(body,CaelumConstants.ARMOR_SLOT_FEET);
        bool helmet=WearsArmor(body,CaelumConstants.ARMOR_SLOT_HEAD);
        key=key*4+int(boots)*2+int(helmet);
        if(body.FamilyVisualKey==key)return;
        body.FamilyVisualKey=key;
        // El mismo casco necesita otro ajuste cuando se vuelve a enlazar el cuerpo vivo.
        if(body.health>0)body.WornVisualKeys[2+CaelumConstants.ARMOR_SLOT_HEAD]=0;
        String base=String.Format("b%d",id);
        String cloth=base..".png";
        BindSlot(body,0,base.."_shirt.md3",cloth);
        BindSlot(body,1,base.."_trousers.md3",cloth);
        BindSlot(body,2,base.."_belt.md3",cloth);
        BindSlot(body,3,base.."_boots.md3",cloth,!boots);
        int skin=id>=6?6+((id-6)/2)*3+tone:id>=2 && id<=3?3+tone:tone;
        BindSlot(body,4,base..(gloves?"_gloves.md3":"_hands.md3"),
            gloves?cloth:String.Format("hskin%d.png",skin));
        String head=String.Format("head%d_%d",id,face);
        String cut=helmet?"tuck/":"";
        BindSlot(body,5,cut..head..".md3",String.Format("%s_%d.png",head,tone));
        String style=String.Format("hair%d_%d",id<6?id:0,hair);
        BindSlot(body,6,cut..style..".md3",String.Format("%s_%d.png",style,color),id<6);
    }
}
