class CA868Reference : Object play
{
    static CaelumContaminationContactPoint ActorPoint(Actor body,CaelumContaminationContactPoint reuse=null)
    {
        if(body==null || CaelumContaminationStorage.IsShielded(body))return null;
        let point=reuse!=null?reuse:new('CaelumContaminationContactPoint');point.Body=body;point.Record=null;
        point.Dose=CaelumContaminationStorage.Dose(body);return point;
    }
    static CaelumContaminationContactPoint ModelPoint(CaelumContaminationState entry,CaelumContaminationContactPoint reuse=null)
    {
        if(entry==null)return null;
        entry.Ensure();let point=reuse!=null?reuse:new('CaelumContaminationContactPoint');point.Body=null;point.Record=entry;point.Dose=1;return point;
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
    static CaelumContaminationContactPoint Exterior(Actor body,int slot,CaelumContaminationContactPoint reuse=null)
    {
        let user=CaelumPlayer(body);
        if(user!=null)return ActorPoint(CaelumContaminationSurfaceContact.Outer(user,slot),reuse);
        let npc=CaelumCombatActor(body);
        if(npc!=null && npc.CombatArmor!=null && !CaelumThermalBody.FurryAnimal(body))
        {
            if(npc.CombatArmor.ContaminationState[slot]==null)
                npc.CombatArmor.ContaminationState[slot]=new('CaelumContaminationState');
            return ModelPoint(npc.CombatArmor.ContaminationState[slot],reuse);
        }
        return ActorPoint(body,reuse);
    }
}
