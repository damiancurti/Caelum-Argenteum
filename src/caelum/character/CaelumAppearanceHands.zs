// La identidad guardada y la pieza realmente equipada eligen sólo la imagen.
// No modifica inventario, defensa, animación de combate ni puntos de agarre.
class CaelumAppearanceHands : Object play
{
    static bool HasGloves(CaelumPlayer user)
    {
        if(user==null)return false;
        let item=user.FindNativeEquipmentItemById(user.EquippedArmorItemId[CaelumConstants.ARMOR_SLOT_HANDS]);
        return item!=null && item.Owner==user && item.Equipped && !item.InMagicBox
            && item.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_ARMOR
            && item.ArmorSlot==CaelumConstants.ARMOR_SLOT_HANDS
            && item.ItemType!=CaelumConstants.ARMOR_TYPE_BASE_CLOTHING;
    }

    static int Variant(CaelumPlayer user)
    {
        if(user==null || user.CharacterProfile==null)return -1;
        let profile=user.CharacterProfile;
        bool female=profile.Sex==1;
        if(HasGloves(user))return female?36:-1;
        int family=profile.Race==CaelumConstants.RACE_CAELITH?1
            :profile.Race==CaelumConstants.RACE_BEAST_MAN?2+Clamp(profile.BeastForm,0,3):0;
        return (female?18:0)+family*3+Clamp(profile.SkinTone,0,2);
    }

    static State Resolve(CaelumPlayer user,String label,State original)
    {
        int variant=Variant(user);
        if(variant<0)return original;
        State result=GetDefaultByType("CaelumAppearanceHandFrames").FindStateByString(
            String.Format("V%d_%s",variant,label),true);
        return result==null?original:result;
    }

    static State Hand(CaelumPlayer user,int hand)
    {
        String label=String.Format("Hand_%d",hand);
        return Resolve(user,label,GetDefaultByType("CaelumFirstPersonLayerFrames").FindStateByString(label));
    }

    static State Composed(CaelumPlayer user,int kind,int tier,int phase,State original)
    {
        if(kind!=1 && kind!=6 && kind!=9 && kind!=17 && kind!=18 && kind!=19)return original;
        return Resolve(user,String.Format("%s_T%d_%s",CaelumFirstPersonView.Family(kind),
            Clamp(tier,1,3),phase==1?"B":phase==2?"C":"A"),original);
    }

    static clearscope Vector2 ComposedPivot(int kind,int phase)
    {
        // Coordenadas absolutas del manifiesto FP v1; no dependen del recorte alfa.
        if(kind==17)return (236.5,125);
        if(kind==18)return (227,161);
        return (235,157.5);
    }
}
