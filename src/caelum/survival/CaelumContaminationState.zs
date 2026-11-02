// #502: propiedad persistente separada de la exposición y de su calendario.
class CaelumContaminationState : Object play
{
    int Revision;
    double Concentration;
    CaelumContaminationObject Exposure;
    int PhysiologyRevision;
    double DiseaseFraction;
    int DomesticTargetKey;
    int StackRevision;
    Inventory StackOwner;
    CaelumFoodLots StackLots;
    CaelumContaminationContacts Contacts;

    void EnsurePhysiology()
    {
        if(PhysiologyRevision>=CaelumContaminationData.NPC_PHYSIOLOGY_REVISION)return;
        DiseaseFraction=0;PhysiologyRevision=CaelumContaminationData.NPC_PHYSIOLOGY_REVISION;
    }

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
    static CaelumContaminationState Get(Actor body,bool create=false,bool raw=false)
    {
        if(body==null || body is 'CaelumPlayer')return null;
        if(CaelumContaminationStack.Eligible(Inventory(body)))return CaelumContaminationStack.Record(Inventory(body),create);
        let proxy=CaelumDiningBlock(body);
        let dining=proxy!=null?proxy.Table:CaelumDiningTable(body);
        if(!raw && dining!=null && !dining.ContaminationMigrating)
        {
            CaelumDiningContamination.Ensure(dining);
            if(proxy!=null)return Get(dining,create,true);
        }
        let furniture=CaelumStorageFurnitureItem(body);
        if(furniture!=null)
        {
            if(furniture.ContaminationState==null && create)furniture.ContaminationState=new('CaelumContaminationState');
            if(furniture.ContaminationState!=null && create)furniture.ContaminationState.Ensure();
            return furniture.ContaminationState;
        }
        let decor=CaelumDecorBody(body);
        if(decor!=null && decor.PackedItem!=null)return Get(decor.PackedItem,create);
        let rest=CaelumRestFurniture(body);
        let table=CaelumPortableDiningTable(body);
        if(table!=null && table.PackedItem!=null)return Get(table.PackedItem,create);
        if(rest!=null && rest.PackedItem!=null)return Get(rest.PackedItem,create);
        let desk=CaelumPortableReadingDesk(body);
        if(desk!=null && desk.PackedItem!=null)return Get(desk.PackedItem,create);
        let sofa=CaelumSofa(body);
        if(sofa!=null && sofa.PackedItem!=null)return Get(sofa.PackedItem,create);
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
        let npc=CaelumCombatActor(body);
        if(npc!=null && npc.ContaminationBodyReady && (npc.ContaminationBody!=null || !create))
        {
            if(create)npc.ContaminationBody.Ensure();
            return npc.ContaminationBody;
        }
        let carrier=CaelumContaminationCarrier(body.FindInventory('CaelumContaminationCarrier'));
        if(carrier==null && create)
        {
            carrier=CaelumContaminationCarrier(Actor.Spawn('CaelumContaminationCarrier',body.Pos,NO_REPLACE));
            if(carrier!=null){carrier.AttachToOwner(body);carrier.AttachmentRevision=1;}
        }
        if(carrier==null)
        {
            if(npc!=null)npc.ContaminationBodyReady=true;
            return null;
        }
        carrier.EnsureAttachment();
        if(carrier.State==null && create)carrier.State=new('CaelumContaminationState');
        if(carrier.State!=null && create)carrier.State.Ensure();
        if(npc!=null){npc.ContaminationBody=carrier.State;npc.ContaminationBodyReady=true;}
        return carrier.State;
    }
    static double Value(Actor body)
    {
        if(CaelumContaminationStack.Eligible(Inventory(body)))return CaelumContaminationStack.Value(Inventory(body));
        let remote=CaelumHouseStorageEntry.Remote(body);if(remote!=null)remote.SyncDirt();
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
        if(CaelumContaminationStack.Eligible(Inventory(body))){CaelumContaminationStack.Set(Inventory(body),value);return;}
        let remote=CaelumHouseStorageEntry.Remote(body);if(remote!=null)remote.SyncDirt();
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
        let rock=CaelumTarotRock(body);if(rock!=null && rock.Contained)return true;
        let item=Inventory(body);
        if(item==null)return false;
        if(CaelumContainerRules.Boxed(item))return true;
        if(item is 'CaelumCampTent' && item.Owner is 'CaelumDeployedTent')return true;
        if(item is 'CaelumSleepingBag')
        {let mat=CaelumRestBag.ReservedBag(CaelumPlayer(item.Owner));if(mat!=null && mat.Bag==item)return true;}
        let table=CaelumPortableDiningTable(item.Owner);
        if(table!=null && table.Packed())return IsShielded(table.PackedItem);
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
        if(CaelumContaminationStack.Touch(first,second,areaM2,worldSeconds))return;
        double a=Value(first),b=Value(second);
        if(a>b)Set(second,CaelumContaminationRules.AfterContact(b,a,areaM2,worldSeconds,Dose(second)));
        else if(b>a)Set(first,CaelumContaminationRules.AfterContact(a,b,areaM2,worldSeconds,Dose(first)));
    }
}

// La mesa es un objeto; sus bloques sólo representan su colisión. La migración
// conserva el foco anterior más sucio, sin sumar concentraciones ni lavar nada.
class CaelumDiningContamination : Object play
{
    static Actor Owner(Actor body)
    {
        let proxy=CaelumDiningBlock(body);
        if(proxy!=null && proxy.Table!=null)return proxy.Table;
        return body;
    }
    static void Ensure(CaelumDiningTable table)
    {
        if(table==null || table.ContaminationMigrating
            || table.ContaminationProxyRevision>=CaelumContaminationData.DINING_PROXY_REVISION)return;
        table.ContaminationMigrating=true;
        let main=CaelumContaminationStorage.Get(table,true,true);
        if(main!=null && main.Exposure!=null)main.Exposure.SettleNow();
        for(int i=0;i<32;i++)
        {
            let block=table.Blocks[i];if(block==null)continue;
            let old=CaelumContaminationStorage.Get(block,false,true);if(old==null)continue;
            if(old.Exposure!=null){old.Exposure.SettleNow();old.Exposure.Release();}
            if(main!=null && old.Revision>=CaelumContaminationData.STATE_REVISION)
                main.Concentration=Max(main.Concentration,old.Concentration);
        }
        table.ContaminationProxyRevision=CaelumContaminationData.DINING_PROXY_REVISION;
        table.ContaminationMigrating=false;
    }
}
