// #502: adapta el inventario/modelos del NPC al mismo balance del jugador.
// La planificación térmica existente posee el reloj; no añade Tick ni censos.
class CaelumContaminationNPC : Object play
{
    CaelumContaminationExposure Frame;
    CaelumFoodIllness Body;
    int Count;

    // El daño usa segundos activos, como el jugador; la exposición conserva
    // su reloj mundial separado. El registro del cuerpo es la única autoridad.
    static void IllnessStep(CaelumCombatActor npc)
    {
        if(npc==null || npc.health<=0 || !npc.CombatProfileInitialized)return;
        let entry=CaelumContaminationStorage.Get(npc);if(entry==null)return;
        entry.EnsurePhysiology();
        if(entry.Revision<CaelumContaminationData.STATE_REVISION
            || entry.Concentration<=CaelumFoodData.ILLNESS_THRESHOLD)return;
        entry.DiseaseFraction+=CaelumFoodRules.DamagePerSecond(entry.Concentration,
            npc.CombatMaximumHealth,CaelumToughnessRules.Effective(npc))/TICRATE;
        int damage=int(entry.DiseaseFraction+0.0000001);
        if(damage<=0)return;
        entry.DiseaseFraction=Max(0.0,entry.DiseaseFraction-damage);
        npc.DamageMobj(null,null,damage,'CaelumDiseaseDOT',DMG_NO_ARMOR,0.0);
    }
    static bool NeedsRecovery(CaelumCombatActor npc)
    {
        let entry=CaelumContaminationStorage.Get(npc);
        return entry!=null && entry.Revision>=CaelumContaminationData.STATE_REVISION
            && entry.Concentration>0;
    }
    static void Recover(CaelumCombatActor npc,double effort)
    {
        if(npc==null || npc.health<=0 || npc.CombatMaximumHealth<=0 || effort<=0)return;
        let entry=CaelumContaminationStorage.Get(npc);
        if(entry!=null && entry.Revision>=CaelumContaminationData.STATE_REVISION)
            entry.Concentration=Max(0.0,entry.Concentration-effort/npc.CombatMaximumHealth);
    }

    CaelumContaminationEquipment Row()
    {
        if(Count==Frame.Items.Size())
        {
            let row=new('CaelumContaminationEquipment');
            row.Endpoint=new('CaelumContaminationContactPoint');Frame.Items.Push(row);
        }
        let row=Frame.Items[Count++];
        row.Item=null;row.Endpoint.Body=null;row.Endpoint.Record=null;row.Endpoint.Dose=1;
        row.Worn=false;row.Slot=0;row.Kind=0;return row;
    }
    void Model(CaelumContaminationState entry,double area,int slot=-1)
    {
        entry.Ensure();let row=Row();row.Endpoint.Record=entry;row.Area=area;
        if(slot>=0){row.Worn=true;row.Slot=slot;Frame.Armor[slot]=Count-1;}
    }
    void Capture(CaelumCombatActor npc,CaelumThermalState thermal)
    {
        if(Frame==null)Frame=new('CaelumContaminationExposure');
        if(Body==null)Body=new('CaelumFoodIllness');
        Count=0;Frame.BodyKg=thermal.BodyMassKg;
        for(int slot=0;slot<4;slot++)
        {
            Frame.Armor[slot]=-1;Frame.Clothes[slot]=-1;
            Frame.BodyArea[slot]=thermal.SurfaceArea*thermal.Coverage[slot];
            if(npc.CombatArmor!=null && !CaelumThermalBody.FurryAnimal(npc))
            {
                if(npc.CombatArmor.ContaminationState[slot]==null)
                    npc.CombatArmor.ContaminationState[slot]=new('CaelumContaminationState');
                Model(npc.CombatArmor.ContaminationState[slot],Frame.BodyArea[slot],slot);
            }
        }
        let weapon=npc.GetPossessedSidearm();
        let resident=CaelumAnchoredResident(npc);
        bool nativeSidearm=resident!=null && resident.ResidentTools!=null
            && resident.ResidentTools.Available(resident.ResidentTools.Melee);
        if(weapon!=null && !nativeSidearm)
        {
            if(weapon.ContaminationState==null)weapon.ContaminationState=new('CaelumContaminationState');
            Model(weapon.ContaminationState,CaelumContaminationRules.WeaponArea(weapon.WeaponType,weapon.Size));
        }
        let defender=CaelumPortDefender(npc);
        if(defender!=null && defender.Shield!=null)
        {
            let shield=defender.Shield;
            if(shield.ContaminationState==null)shield.ContaminationState=new('CaelumContaminationState');
            Model(shield.ContaminationState,CaelumContaminationRules.ShieldArea(shield.ShieldType,shield.Size));
        }
        // Sólo el inventario de este dueño, en su intervalo térmico compartido.
        // Los objetos nativos guardan identidad; no se copian a los modelos.
        for(Inventory cursor=npc.Inv;cursor!=null;cursor=cursor.Inv)
        {
            let item=CaelumEquipmentItem(cursor);
            if(item==null || item.Owner!=npc || item.Amount<=0 || CaelumContaminationStorage.IsShielded(item))continue;
            int kind=item.EquipmentKind;double area;
            if(kind==CaelumConstants.EQUIPMENT_KIND_WEAPON)
                area=CaelumContaminationRules.WeaponArea(item.ItemType,item.EquipmentSize);
            else if(kind==CaelumConstants.EQUIPMENT_KIND_SHIELD)
                area=CaelumContaminationRules.ShieldArea(item.ItemType,item.EquipmentSize);
            else if(kind==CaelumConstants.EQUIPMENT_KIND_ARMOR || kind==CaelumConstants.EQUIPMENT_KIND_CLOTHING)
                area=CaelumContaminationRules.GarmentArea(item.ArmorSlot,item.EquipmentSize);
            else continue;
            let row=Row();row.Item=item;row.Endpoint.Body=item;row.Area=area;row.Kind=kind;
        }
        Frame.Items.Resize(Count);Frame.Immersion(thermal);Frame.ReadLive();
        Body.Contamination=CaelumContaminationStorage.Value(npc);
    }
    void Advance(CaelumCombatActor npc,CaelumThermalState thermal,double seconds,double ambient)
    {
        Capture(npc,thermal);Frame.Advance(Body,ambient,seconds);
        if(Body.Contamination!=CaelumContaminationStorage.Value(npc))
            CaelumContaminationStorage.Set(npc,Body.Contamination);
        for(int i=0;i<Frame.Items.Size();i++)
        {
            let row=Frame.Items[i];
            if(row.Concentration!=row.Endpoint.Value())row.Endpoint.Set(row.Concentration);
        }
    }
    static void Step(CaelumCombatActor npc,CaelumThermalState thermal,double seconds)
    {
        if(npc==null || thermal==null || !thermal.Available || npc.health<=0 || seconds<=0)return;
        if(npc.ContaminationExposure==null)npc.ContaminationExposure=new('CaelumContaminationNPC');
        double reference=CaelumContaminationEnvironment.ReferenceAt(npc);
        double ambient=reference>=0?CaelumContaminationRules.Ambient(reference,thermal.AirC,
            thermal.Humidity,thermal.RainMmHour,!thermal.Roof):-1;
        npc.ContaminationExposure.Advance(npc,thermal,seconds,ambient);
    }
}
