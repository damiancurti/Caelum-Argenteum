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
