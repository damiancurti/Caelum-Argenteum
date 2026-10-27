// #502: propiedad persistente separada de la exposición y de su calendario.
class CaelumContaminationState : Object play
{
    int Revision;
    double Concentration;
    CaelumContaminationObject Exposure;

    void Ensure()
    {
        if(Revision>=CaelumContaminationData.STATE_REVISION)return;
        Concentration=0;Revision=CaelumContaminationData.STATE_REVISION;
    }
    CaelumContaminationState Copy()
    {
        let copy=new('CaelumContaminationState');copy.Ensure();
        if(Revision>=CaelumContaminationData.STATE_REVISION)
            copy.Concentration=Clamp(Concentration,0.0,CaelumFoodData.MAX_CONTAMINATION);
        return copy;
    }
}

// Los actores sin inventario de equipo conservan un registro nativo oculto.
// No ejecuta Tick ni recorre actores: quien produce el contacto lo consulta.
class CaelumContaminationCarrier : Inventory
{
    CaelumContaminationState State;
    int AttachmentRevision;
    void EnsureAttachment()
    {
        if(AttachmentRevision>=1 || Owner==null)return;
        // Los registros anteriores usaban AddInventory sin BecomeItem. Reparar
        // sus enlaces nativos una vez, conservando dueño y concentración.
        BecomeItem();AttachmentRevision=1;
    }
    override Inventory CreateTossable(int amount){return null;}
    Default
    {
        Inventory.MaxAmount 1;
        +INVENTORY.UNDROPPABLE
    }
}

class CaelumContaminationStorage : Object play
{
    static CaelumContaminationState Get(Actor body,bool create=false)
    {
        if(body==null || body is 'CaelumPlayer')return null;
        let furniture=CaelumStorageFurnitureItem(body);
        if(furniture!=null)
        {
            if(furniture.ContaminationState==null && create)furniture.ContaminationState=new('CaelumContaminationState');
            if(furniture.ContaminationState!=null && create)furniture.ContaminationState.Ensure();
            return furniture.ContaminationState;
        }
        let seat=CaelumSofaSeat(body);
        if(seat!=null)return seat.Sofa==null || seat.Sofa.bDestroyed?null:Get(seat.Sofa,create);
        let equipment=CaelumEquipmentItem(body);
        if(equipment!=null)
        {
            if(equipment.ContaminationState==null && create)
                equipment.ContaminationState=new('CaelumContaminationState');
            if(equipment.ContaminationState!=null && create)equipment.ContaminationState.Ensure();
            return equipment.ContaminationState;
        }
        let carrier=CaelumContaminationCarrier(body.FindInventory('CaelumContaminationCarrier'));
        if(carrier==null && create)
        {
            carrier=CaelumContaminationCarrier(Actor.Spawn('CaelumContaminationCarrier',body.Pos,NO_REPLACE));
            if(carrier!=null){carrier.AttachToOwner(body);carrier.AttachmentRevision=1;}
        }
        if(carrier==null)return null;
        carrier.EnsureAttachment();
        if(carrier.State==null && create)carrier.State=new('CaelumContaminationState');
        if(carrier.State!=null && create)carrier.State.Ensure();
        return carrier.State;
    }
    static double Value(Actor body)
    {
        let user=CaelumPlayer(body);
        if(user!=null)return CaelumFoodIllness.Value(user);
        let entry=Get(body);
        // Contacto/recogida pueden ocurrir antes del primer tic tras cargar.
        // Cerrar primero el intervalo guardado o cargado, sin buscar otros actores.
        if(entry!=null && entry.Exposure!=null)entry.Exposure.SettleNow();
        return entry!=null && entry.Revision>=CaelumContaminationData.STATE_REVISION
            ? entry.Concentration : 0;
    }
    static void Set(Actor body,double value)
    {
        value=Clamp(value,0.0,CaelumFoodData.MAX_CONTAMINATION);
        let user=CaelumPlayer(body);
        if(user!=null)
        {
            let illness=CaelumFoodIllness.Get(user);
            if(illness!=null)illness.Contamination=value;
            return;
        }
        let entry=Get(body,true);
        if(entry!=null && entry.Exposure!=null)entry.Exposure.SettleNow();
        if(entry!=null)entry.Concentration=value;
    }
    // Botiquines y mate cuentan su curación potencial, incluso con Vida llena.
    // La fracción del máximo evita depender del redondeo de puntos de Vida.
    static void Treatment(Actor body,double lifeRatio)
    {
        if(body==null || body.health<=0 || lifeRatio<=0)return;
        let user=CaelumPlayer(body);
        if(user!=null && !CaelumPlayerAuthority.CanMutate(user))return;
        double current=Value(body);
        if(current>0)Set(body,current-lifeRatio*CaelumContaminationData.TREATMENT_DEGREES_PER_LIFE_RATIO);
    }
    static bool IsShielded(Actor body)
    {
        let item=Inventory(body);
        if(item==null)return false;
        if(CaelumContainerRules.Boxed(item))return true;
        let chest=CaelumStashChest(item.Owner);
        return chest!=null && !chest.ChestOpen;
    }
    static double Dose(Actor body)
    {
        let user=CaelumPlayer(body);
        if(user!=null)return user.DerivedStats!=null
            ? CaelumContaminationRules.BodyDoseFactor(user.DerivedStats.BaseMass) : 0;
        if(body is 'CaelumCombatActor')return CaelumContaminationRules.BodyDoseFactor(body.Mass);
        return 1;
    }
    static void Touch(Actor first,Actor second,double areaM2,double worldSeconds)
    {
        if(first==null || second==null || first==second || IsShielded(first) || IsShielded(second))return;
        double a=Value(first),b=Value(second);
        if(a>b)Set(second,CaelumContaminationRules.AfterContact(b,a,areaM2,worldSeconds,Dose(second)));
        else if(b>a)Set(first,CaelumContaminationRules.AfterContact(a,b,areaM2,worldSeconds,Dose(first)));
    }
}
