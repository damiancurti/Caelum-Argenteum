// La identidad guardada y la pieza realmente equipada eligen sólo la imagen.
// No modifica inventario, defensa, animación de combate ni puntos de agarre.
class CaelumAppearanceHands : Object play
{
    static void Invalidate(CaelumPlayer user)
    {
        if(user==null)return;
        user.AppearanceHandStateReady=false;
        user.AppearanceHandLayerReady[0]=false;
        user.AppearanceHandLayerReady[1]=false;
    }

    static CaelumEquipmentItem HandLayer(CaelumPlayer user,bool clothing)
    {
        if(!CaelumPlayerAuthority.CanRead(user))return null;
        int layer=clothing?1:0;
        int wanted=user.EquippedArmorItemId[CaelumConstants.ARMOR_SLOT_HANDS];
        if(clothing)
        {
            if(!user.AppearanceHandStateReady)
            {
                // Sólo lectura: el acceso general también ejecuta migraciones ajenas al dibujo.
                user.CA861StateReads++;
                user.AppearanceHandState=CaelumPersistentCharacterState(user.FindInventory("CaelumPersistentCharacterState"));
                user.AppearanceHandStateReady=true;
            }
            let record=user.AppearanceHandState;
            wanted=record!=null && !record.bDestroyed && record.Owner==user
                ?record.EquippedClothingItemId[CaelumConstants.ARMOR_SLOT_HANDS]:0;
        }
        // La identidad cambia por equipamiento; el evento invalida reemplazos del mismo ID.
        if(!user.AppearanceHandLayerReady[layer] || user.AppearanceHandLayerIds[layer]!=wanted)
        {
            user.AppearanceHandLayerIds[layer]=wanted;
            if(wanted>0)user.CA861ItemReads++;
            user.AppearanceHandLayers[layer]=wanted>0?user.FindNativeEquipmentItemById(wanted):null;
            user.AppearanceHandLayerReady[layer]=true;
        }
        let item=user.AppearanceHandLayers[layer];
        if(item==null || item.bDestroyed || item.Owner!=user || item.ItemId!=wanted
            || !item.Equipped || item.InMagicBox || item.ArmorSlot!=CaelumConstants.ARMOR_SLOT_HANDS)return null;
        if(clothing)
            return item.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_CLOTHING
                && item.ItemType>=0 && item.ItemType<CaelumClothingData.COUNT
                && CaelumClothingData.Region(item.ItemType)==CaelumConstants.ARMOR_SLOT_HANDS?item:null;
        return item.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_ARMOR
            && item.ItemType!=CaelumConstants.ARMOR_TYPE_BASE_CLOTHING?item:null;
    }

    static bool HasGloves(CaelumPlayer user)
    {
        // La capa exterior conserva prioridad; la ropa usa los mismos guantes ya aceptados.
        return HandLayer(user,false)!=null || HandLayer(user,true)!=null;
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
        if(CaelumSupportArt.NewSprite(kind))return original;
        if(CaelumSupportArt.Legacy(kind)>=0)kind=CaelumSupportArt.Legacy(kind);
        if(kind!=1 && kind!=6 && kind!=9 && kind!=17 && kind!=18 && kind!=19)return original;
        return Resolve(user,String.Format("%s_T%d_%s",CaelumFirstPersonView.Family(kind),
            Clamp(tier,1,3),phase==1?"B":phase==2?"C":"A"),original);
    }

    static clearscope Vector2 ComposedPivot(int kind,int phase)
    {
        if(CaelumSupportArt.Legacy(kind)>=0)kind=CaelumSupportArt.Legacy(kind);
        // Coordenadas absolutas del manifiesto FP v1; no dependen del recorte alfa.
        if(kind==17)return (236.5,125);
        if(kind==18)return (227,161);
        return (235,157.5);
    }
}
