// #502: extremos del contacto físico; el objeto nativo conserva la autoridad.
// Los NPC que aún usan modelos guardan el mismo estado en su pieza/modelo.
class CaelumContaminationContactPoint : Object play
{
    Actor Body;
    CaelumContaminationState Record;
    double Dose;
    double Value(){return Body!=null ? CaelumContaminationStorage.Value(Body) : Record.Concentration;}
    void Set(double value)
    {
        if(Body!=null)CaelumContaminationStorage.Set(Body,value);
        else Record.Concentration=Clamp(value,0.0,CaelumFoodData.MAX_CONTAMINATION);
    }
}

class CaelumContaminationCombat : Object play
{
    static CaelumContaminationContactPoint ActorPoint(Actor body)
    {
        if(body==null || CaelumContaminationStorage.IsShielded(body))return null;
        let point=new('CaelumContaminationContactPoint');point.Body=body;
        point.Dose=CaelumContaminationStorage.Dose(body);return point;
    }
    static CaelumContaminationContactPoint ModelPoint(CaelumContaminationState entry)
    {
        if(entry==null)return null;
        entry.Ensure();let point=new('CaelumContaminationContactPoint');point.Record=entry;point.Dose=1;return point;
    }
    static CaelumContaminationContactPoint WeaponPoint(CaelumWeaponModel model)
    {
        if(model==null)return null;
        if(model.ContaminationState==null)model.ContaminationState=new('CaelumContaminationState');
        return ModelPoint(model.ContaminationState);
    }
    static CaelumContaminationContactPoint ShieldPoint(CaelumShieldModel model)
    {
        if(model==null)return null;
        if(model.ContaminationState==null)model.ContaminationState=new('CaelumContaminationState');
        return ModelPoint(model.ContaminationState);
    }
    static CaelumContaminationContactPoint Exterior(Actor body,int slot)
    {
        let user=CaelumPlayer(body);
        if(user!=null)return ActorPoint(CaelumContaminationSurfaceContact.Outer(user,slot));
        let npc=CaelumCombatActor(body);
        if(npc!=null && npc.CombatArmor!=null && !CaelumThermalBody.FurryAnimal(body))
        {
            if(npc.CombatArmor.ContaminationState[slot]==null)
                npc.CombatArmor.ContaminationState[slot]=new('CaelumContaminationState');
            return ModelPoint(npc.CombatArmor.ContaminationState[slot]);
        }
        return ActorPoint(body);
    }
    static bool Physical(Actor victim,Actor inflictor,Actor source,Name mod,int flags)
    {
        let npc=CaelumCombatActor(source);
        return victim!=null && source!=null && victim!=source && victim.health>0
            && !(flags & DMG_EXPLOSION) && (inflictor==null || !inflictor.bMissile)
            && (mod=='Melee' || mod=='CaelumMeleeTest'
                || (mod=='None' && inflictor==source && npc!=null && npc.ContaminationMeleeActive));
    }
    static CaelumContaminationContactPoint Attacker(Actor source,Name mod)
    {
        let user=CaelumPlayer(source);
        if(user!=null)
        {
            if(mod=='Melee')return Exterior(user,CaelumConstants.ARMOR_SLOT_HANDS);
            return ActorPoint(user.FindNativeEquipmentItemById(user.ActiveWeaponItemId));
        }
        let npc=CaelumCombatActor(source);
        if(npc!=null)
        {
            if(npc.CombatActiveTool!=null && npc.CombatActiveTool.Owner==npc)
                return ActorPoint(npc.CombatActiveTool);
            let resident=CaelumAnchoredResident(npc);
            if(resident!=null && resident.ResidentTools!=null
                && resident.ResidentTools.Available(resident.ResidentTools.Melee))
                return ActorPoint(resident.ResidentTools.Melee);
            let weapon=npc.GetPossessedSidearm();
            if(weapon!=null)return WeaponPoint(weapon);
        }
        return ActorPoint(source);
    }
    static void Exchange(CaelumContaminationContactPoint first,CaelumContaminationContactPoint second)
    {
        if(first==null || second==null)return;
        double a=first.Value(),b=second.Value();
        double area=CaelumContaminationData.IMPACT_CONTACT_M2,seconds=CaelumContaminationData.IMPACT_CONTACT_SECONDS;
        if(a>b)second.Set(CaelumContaminationRules.AfterContact(b,a,area,seconds,second.Dose));
        else if(b>a)first.Set(CaelumContaminationRules.AfterContact(a,b,area,seconds,first.Dose));
    }
    // Se llama después de la esquiva y de decidir el bloqueo, antes del desgaste.
    static void Hit(Actor victim,Actor inflictor,Actor source,Name mod,int flags,int slot,
        CaelumContaminationContactPoint blocker=null)
    {
        if(!Physical(victim,inflictor,source,mod,flags))return;
        Exchange(Attacker(source,mod),blocker!=null?blocker:Exterior(victim,slot));
    }
    static void PlayerHit(CaelumPlayer user,Actor inflictor,Actor source,Name mod,int flags)
    {
        if(!Physical(user,inflictor,source,mod,flags))return;
        CaelumContaminationContactPoint blocker;
        if(user.LastShieldBlockedAttack)
            blocker=ActorPoint(user.FindNativeEquipmentItemById(user.IsGiantGauntletsBlockSource()
                ? user.ActiveWeaponItemId : user.EquippedShieldItemId));
        Hit(user,inflictor,source,mod,flags,user.LastIncomingArmorSlot,blocker);
    }
}
