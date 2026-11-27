// Cada pieza toma su tipo del equipo real. Las ranuras sólo afectan al modelo.
class CaelumWornEquipment : Object play
{
    static void UpdateSlot(CaelumPlayer body, int part, int key, String mesh)
    {
        if(body.WornVisualKeys[part] == key) return;
        body.WornVisualKeys[part] = key;
        int slot = 7 + part;
        body.A_ChangeModel('None', slot, "models/caelum/players/gear", Name(mesh..".md3"),
            slot, "models/caelum/players/gear", Name(mesh..".png"), key < 0 ? CMDL_HIDEMODEL : 0);
    }

    static void Sync(CaelumPlayer body)
    {
        if(body.health<=0 && body.WornVisualKeys[0]!=0) return;
        let weapon = body.WeaponModel;
        let shield = body.ShieldModel;
        let armor = body.ArmorModel;
        int kind = weapon!=null ? weapon.WeaponType : 0;
        bool tiered = kind == CaelumConstants.WEAPON_TYPE_SCEPTER || kind == CaelumConstants.WEAPON_TYPE_ORB
            || kind >= CaelumConstants.WEAPON_TYPE_SUPPORT_BOOK;
        int tier = tiered && weapon!=null ? Clamp(weapon.Tier,1,3) : 1;
        let rest = CaelumRestState.Get(body);
        bool meal = rest!=null && CaelumRestState.MotionLocked(body)
            && (rest.MotionPhase==CaelumRestMotionData.EAT || rest.MotionPhase==CaelumRestMotionData.DRINK);
        int key = weapon!=null && weapon.Equipped && !meal ? 1+kind*3+tier-1 : -1;
        if(body.WornVisualKeys[0]!=key)
            UpdateSlot(body,0,key,key<0 ? "w0_1" : String.Format("w%d_%d",kind,tier));
        key = shield!=null && shield.Equipped ? 1+shield.ShieldType : -1;
        if(body.WornVisualKeys[1]!=key)
            UpdateSlot(body,1,key,key<0 ? "s0" : String.Format("s%d",key-1));
        for(int i=0;i<CaelumConstants.ARMOR_SLOT_COUNT;i++)
        {
            kind = armor!=null ? armor.ArmorType[i] : CaelumConstants.ARMOR_TYPE_BASE_CLOTHING;
            key = kind == CaelumConstants.ARMOR_TYPE_BASE_CLOTHING ? -1 : kind+1;
            if(body.WornVisualKeys[i+2]!=key)
                UpdateSlot(body,i+2,key,String.Format("a%d_%d",i,Max(0,key-1)));
        }
    }
}

