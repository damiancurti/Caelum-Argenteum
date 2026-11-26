// #857: candidato optativo; el inventario nativo conserva toda la autoridad.
class CaelumWardrobeVisual : Object play
{
    static bool Enabled()
    {
        let setting=CVar.GetCVar("ca_wardrobe_candidate");
        return setting!=null && setting.GetBool();
    }

    static bool Supported(CaelumDomingoPilotPlayer user,bool originalSupport)
    {
        let body=CaelumWardrobePilotBody(user.PilotBody);
        if(user.health<=0)
            return originalSupport && body!=null && body.LastSupported && body.SnapshotReady;
        bool supported=originalSupport && user.ArmorModel!=null
            && user.CharacterProfile.SkinTone==0 && user.CharacterProfile.Face==0
            && user.CharacterProfile.HairStyle==0 && user.CharacterProfile.HairColor==0;
        if(user.ArmorModel!=null)
            for(int slot=0;slot<CaelumConstants.ARMOR_SLOT_COUNT;slot++)
                if(user.ArmorModel.ArmorType[slot]!=CaelumConstants.ARMOR_TYPE_BASE_CLOTHING)supported=false;
        if(body!=null)body.LastSupported=supported && !user.PilotOriginalSprites;
        return supported;
    }

    static void Invalidate(CaelumPlayer user)
    {
        let pilot=CaelumDomingoPilotPlayer(user);
        if(pilot==null)return;
        let body=CaelumWardrobePilotBody(pilot.PilotBody);
        if(body!=null)body.CacheReady=false;
    }
}

class CaelumWardrobePilotBody : CaelumDomingoPilotBody
{
    const WARDROBE_REVISION=1;
    int WardrobeRevision;
    int BodyKind,HeadKind,HandKind,FootKind,HiddenMask;
    bool SnapshotReady,LastSupported,FrozenDeath;
    transient bool CacheReady,BindingsReady;
    transient int CachedIds[4];
    transient CaelumEquipmentItem CachedPieces[4];

    void EnsureWardrobe()
    {
        if(WardrobeRevision>=WARDROBE_REVISION)return;
        BodyKind=HeadKind=HandKind=FootKind=-1;
        SnapshotReady=false;LastSupported=false;FrozenDeath=false;
        CacheReady=false;BindingsReady=false;WardrobeRevision=WARDROBE_REVISION;
    }

    void ApplyBindings()
    {
        HiddenMask=CaelumWornClothingModelData.Hidden(BodyKind,HeadKind,HandKind,FootKind);
        if(MealVisualPhase!=0)HiddenMask|=1<<15;
        for(int slot=0;slot<CaelumWornClothingModelData.MODEL_SLOTS;slot++)
        {
            bool visible=(HiddenMask&(1<<slot))==0;
            A_ChangeModel('None',slot,CaelumRestMotionData.ModelPath(CaelumWornClothingModelData.ModelPath(slot),MealVisualPhase),
                CaelumWornClothingModelData.File(slot,BodyKind,HeadKind,HandKind,FootKind),
                slot,CaelumWornClothingModelData.SkinPath(slot),
                CaelumWornClothingModelData.Skin(slot,BodyKind,HeadKind,HandKind,FootKind),
                visible?0:CMDL_HIDEMODEL);
        }
        BindingsReady=true;
    }

    override void SyncMealBindings(int phase)
    {
        if(MealBindingsReady && MealVisualPhase==phase)return;
        MealVisualPhase=phase;MealBindingsReady=true;ApplyBindings();
    }

    void Sync(CaelumDomingoPilotPlayer user)
    {
        EnsureWardrobe();
        if(user.health<=0)
        {
            // El equipo puede abandonar al dueño después de morir. Conservar
            // sólo la última presentación legítima, sin recrear objetos reales.
            if(!SnapshotReady || !LastSupported)return;
            FrozenDeath=true;
            if(MealVisualPhase!=0){MealVisualPhase=0;BindingsReady=false;}
            if(!BindingsReady)ApplyBindings();
            return;
        }
        LastSupported=true;FrozenDeath=false;
        let record=user.GetPersistentCharacterState(false);
        int kinds[4];
        for(int region=0;region<CaelumConstants.ARMOR_SLOT_COUNT;region++)
        {
            int wanted=record!=null?record.EquippedClothingItemId[region]:0;
            if(!CacheReady || CachedIds[region]!=wanted)
            {
                CachedIds[region]=wanted;
                CachedPieces[region]=wanted>0?user.FindNativeEquipmentItemById(wanted):null;
            }
            let item=CachedPieces[region];
            kinds[region]=item!=null && !item.bDestroyed && item.Owner==user
                && item.ItemId==wanted && item.EquipmentKind==CaelumConstants.EQUIPMENT_KIND_CLOTHING
                && item.ArmorSlot==region && item.Equipped && !item.InMagicBox
                ?CaelumWornClothingModelData.Kind(item.ItemType,region):-1;
        }
        CacheReady=true;
        bool changed=!BindingsReady || BodyKind!=kinds[CaelumConstants.ARMOR_SLOT_BODY]
            || HeadKind!=kinds[CaelumConstants.ARMOR_SLOT_HEAD]
            || HandKind!=kinds[CaelumConstants.ARMOR_SLOT_HANDS]
            || FootKind!=kinds[CaelumConstants.ARMOR_SLOT_FEET];
        BodyKind=kinds[CaelumConstants.ARMOR_SLOT_BODY];HeadKind=kinds[CaelumConstants.ARMOR_SLOT_HEAD];
        HandKind=kinds[CaelumConstants.ARMOR_SLOT_HANDS];FootKind=kinds[CaelumConstants.ARMOR_SLOT_FEET];
        SnapshotReady=true;
        if(changed)ApplyBindings();
    }

    override void Tick()
    {
        // Desactivar retira el único tipo nuevo que podría quedar en un guardado.
        // El jugador original reconstruye su cuerpo habitual cuando corresponde.
        if(!CaelumWardrobeVisual.Enabled())
        {
            let user=CaelumDomingoPilotPlayer(Master);
            if(user!=null && user.PilotBody==self)user.PilotBody=null;
            Destroy();return;
        }
        Super.Tick();
    }
}
