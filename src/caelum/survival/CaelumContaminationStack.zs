// #502: libro de unidades, separado de Amount y de la contaminación de comida.
// Reutiliza la transferencia FIFO probada; este libro nunca envejece alimentos.
class CaelumContaminationStack : Object play
{
    static Actor Carrier(Inventory item)
    {
        if(item==null)return null;
        Actor owner=item.Owner;let table=CaelumPortableDiningTable(owner);
        if(table!=null && table.Packed())owner=table.PackedItem.Owner;
        return owner is 'CaelumPlayer' || owner is 'CaelumCombatActor'?owner:null;
    }
    static bool Eligible(Inventory item)
    {
        if(CaelumVesselSurfaceData.Eligible(item))return true;
        let material=CaelumMaterialPickup(item);
        if(material!=null)return CaelumStackSurfaceData.AbstractMaterial(material.GetSpecialType());
        let prepared=CaelumConsumableItem(item);
        return prepared!=null && CaelumPotionRules.IsPotion(prepared.GetConsumableType());
    }
    static CaelumContaminationState Record(Inventory item,bool create=true)
    {
        if(!Eligible(item))return null;
        let material=CaelumMaterialPickup(item);let prepared=CaelumConsumableItem(item);
        let result=material!=null?material.ContaminationState:prepared.ContaminationState;
        if(result==null && create)
        {
            let old=CaelumContaminationCarrier(item.FindInventory('CaelumContaminationCarrier'));
            result=old!=null && old.State!=null?old.State:new('CaelumContaminationState');result.Ensure();
            if(material!=null)material.ContaminationState=result;else prepared.ContaminationState=result;
        }
        return result;
    }
    static CaelumFoodLots Prepare(Inventory item)
    {
        let record=Record(item);if(record==null)return null;
        if(record.StackLots==null)
        {
            record.StackLots=new('CaelumFoodLots');
            record.StackLots.Ensure(CaelumFoodData.RATION,0,0);
            if(item.Amount>0)record.StackLots.Add(item.Amount,record.Concentration,CaelumFoodInventory.Stamp(item));
        }
        record.StackRevision=CaelumStackSurfaceData.REVISION;
        return record.StackLots;
    }
    static CaelumStackExposure Clock(Inventory item)
    {
        let record=Record(item);if(record==null)return null;
        let node=CaelumStackExposure(record.Exposure);
        if(node==null)
        {
            node=new('CaelumStackExposure');node.Body=item;node.Revision=4;record.Exposure=node;
        }
        return node;
    }
    static void Reconcile(Inventory item)
    {
        let lots=Prepare(item);if(lots==null)return;
        Clock(item).Sync();
        int difference=Max(0,item.Amount)-lots.Units();
        if(difference>0)lots.Add(difference,0,CaelumFoodInventory.Stamp(item));
        else if(difference<0){double ignored;lots.Consume(-difference,ignored);}
    }
    static bool Transfer(Inventory source,Inventory target,int count,bool emptyTarget)
    {
        if(!Eligible(source))return true;
        if(source==target)return true;
        if(!Eligible(target) || source.GetClass()!=target.GetClass())return false;
        let sm=CaelumMaterialPickup(source);let tm=CaelumMaterialPickup(target);
        if(sm!=null && (sm.GetSpecialType()!=tm.GetSpecialType() || sm.GetSpecialTier()!=tm.GetSpecialTier()))return false;
        let from=Prepare(source);let to=Prepare(target);
        if(count<=0 || count>from.Units())return false;
        if(emptyTarget)
        {to=new('CaelumFoodLots');to.Ensure(CaelumFoodData.RATION,0,0);Record(target).StackLots=to;}
        bool moved=from.TransferTo(to,count);
        if(moved){Clock(target).ResetBoundary();Clock(source).ResetBoundary();}
        return moved;
    }
    static void KeepOldest(Inventory item)
    {
        let lots=Prepare(item);
        if(lots!=null && item.Amount>0 && item.Amount<lots.Units())Record(item).StackLots=lots.CopyOldest(item.Amount);
    }
    static void Remove(Inventory item,int count)
    {
        let lots=Prepare(item);if(lots==null)return;
        double ignored;lots.Consume(count,ignored);
    }
    static void Relocate(Inventory item)
    {if(Eligible(item) && !item.bDestroyed)Clock(item).Sync();}
    static void Rebase(Inventory item,double shift)
    {
        let record=Record(item,false);if(record==null)return;
        let node=CaelumStackExposure(record.Exposure);if(node==null)return;
        node.HistoryStamp+=shift;node.Stamp+=shift;node.HistoryCivilOffset-=shift;
    }
    static double Mean(CaelumFoodLots lots)
    {
        if(lots==null || lots.Units()<=0)return 0;
        double total=0;int count=lots.Units();
        for(int i=0;i<lots.Lots.Size();i++)total+=lots.Contamination(i)*(double(lots.Lots[i].Units)/count);
        return total;
    }
    static double Value(Inventory item)
    {Reconcile(item);return Mean(Prepare(item));}
    static void Set(Inventory item,double value)
    {
        Reconcile(item);let lots=Prepare(item);if(lots==null)return;
        for(int i=0;i<lots.Lots.Size();i++)
        {lots.Lots[i].BaseContamination=Clamp(value,0.0,100.0);lots.Lots[i].ExposureAtEntry=lots.Exposure;}
    }
    static void Expose(CaelumFoodLots lots,double ambient,double area,double wet,double dirty,double seconds)
    {
        if(lots==null)return;
        for(int i=0;i<lots.Lots.Size();i++)
        {
            lots.Lots[i].BaseContamination=CaelumContaminationRules.TwoSources(lots.Contamination(i),
                ambient,Max(0,area-wet),CaelumFoodData.MAX_CONTAMINATION,dirty,seconds);
            lots.Lots[i].ExposureAtEntry=lots.Exposure;
        }
    }
    static CaelumFoodLots ContactSnapshot(Actor body)
    {
        let item=Inventory(body);
        if(Eligible(item)){Reconcile(item);return Prepare(item).Copy();}
        let lots=new('CaelumFoodLots');lots.Ensure(CaelumFoodData.RATION,0,0);
        lots.Add(1,CaelumContaminationStorage.Value(body),0);return lots;
    }
    // Todas las fuentes se evalúan desde la misma foto. El área se distribuye
    // por unidades, sin iterar gramos ni promediar sus concentraciones.
    static CaelumFoodLots ContactResult(CaelumFoodLots destination,CaelumFoodLots source,double area,double seconds,double dose)
    {
        let result=destination.Copy();
        if(source.Units()<=0 || destination.Units()<=0)return result;
        area/=destination.Units();
        for(int i=0;i<result.Lots.Size();i++)
        {
            double value=destination.Contamination(i),remaining=seconds;
            for(int pass=0;pass<=source.Lots.Size() && remaining>0;pass++)
            {
                double weighted=0,boundary=CaelumFoodData.MAX_CONTAMINATION;
                for(int j=0;j<source.Lots.Size();j++)
                {
                    double c=source.Contamination(j);if(c<=value)continue;
                    weighted+=area*c*(double(source.Lots[j].Units)/source.Units());boundary=Min(boundary,c);
                }
                double rate=CaelumContaminationData.CONTACT_DEGREES_M2_SECOND*weighted*dose;
                if(rate<=0)break;
                double duration=(CaelumContaminationRules.ContactPrimitive(boundary)-CaelumContaminationRules.ContactPrimitive(value))/rate;
                if(remaining>=duration){value=boundary;remaining-=duration;}
                else {value=CaelumContaminationRules.AfterContact(value,boundary,weighted/boundary,remaining,dose);break;}
            }
            result.Lots[i].BaseContamination=value;result.Lots[i].ExposureAtEntry=result.Exposure;
        }
        return result;
    }
    static bool Touch(Actor first,Actor second,double area,double seconds)
    {
        bool a=Eligible(Inventory(first)),b=Eligible(Inventory(second));if(!a && !b)return false;
        return TouchPoints(CaelumContaminationCombat.ActorPoint(first),CaelumContaminationCombat.ActorPoint(second),area,seconds);
    }
    static CaelumFoodLots PointSnapshot(CaelumContaminationContactPoint point)
    {
        if(point.Body!=null)return ContactSnapshot(point.Body);
        let lots=new('CaelumFoodLots');lots.Ensure(CaelumFoodData.RATION,0,0);
        lots.Add(1,point.Value(),0);return lots;
    }
    static bool TouchPoints(CaelumContaminationContactPoint first,CaelumContaminationContactPoint second,double area,double seconds)
    {
        if(first==null || second==null)return false;
        bool a=Eligible(Inventory(first.Body)),b=Eligible(Inventory(second.Body));if(!a && !b)return false;
        if(CaelumContaminationStorage.IsShielded(first.Body) || CaelumContaminationStorage.IsShielded(second.Body))return true;
        let originalA=PointSnapshot(first);let originalB=PointSnapshot(second);
        if(a)area=Min(area,CaelumStackSurfaceData.UnitArea(Inventory(first.Body))*originalA.Units());
        if(b)area=Min(area,CaelumStackSurfaceData.UnitArea(Inventory(second.Body))*originalB.Units());
        let resultA=ContactResult(originalA,originalB,area,seconds,first.Dose);
        let resultB=ContactResult(originalB,originalA,area,seconds,second.Dose);
        if(a)Record(Inventory(first.Body)).StackLots=resultA;else first.Set(Mean(resultA));
        if(b)Record(Inventory(second.Body)).StackLots=resultB;else second.Set(Mean(resultB));
        return true;
    }
}

// Un nodo escalonado por pila, no por gramo. El clima histórico se comparte con
// los objetos del mundo; el equipo llevado usa el pronóstico térmico del dueño.
class CaelumStackExposure : CaelumContaminationObject
{
    transient bool Syncing;
    static bool Carried(Inventory item)
    {return CaelumContaminationStack.Carrier(item)!=null;}
    Actor Location()
    {
        let item=Inventory(Body);if(item==null)return null;
        Actor location=item.Owner!=null?item.Owner:Body;
        let table=CaelumDiningTable(location);if(table!=null)location=table.ContentLocation();
        let chest=CaelumStashChest(location);
        if(chest!=null && chest.Cargo!=null && chest.Cargo.Owner!=null)location=chest.Cargo.Owner;
        return location;
    }
    void ResetBoundary(){HistoryReady=false;Ready=false;}
    override void SettleNow(){Sync();}
    override void Depart()
    {
        Sync();if(!HistoryTemporaryClimate)return;
        HistoryTemporaryClimate=false;HistoryVariable=HistoryNaturalVariable;
        HistoryAmbient=HistoryNaturalAmbient;Ambient=HistoryAmbient;SampleTemporaryClimate=false;
    }
    void Sync()
    {
        let item=Inventory(Body);
        if(Syncing || item==null || item.bDestroyed || !CaelumContaminationStack.Eligible(item))return;
        Syncing=true;
        let lots=CaelumContaminationStack.Prepare(item);
        let world=CaelumThermalWorld.Get();let location=Location();
        let user=CaelumPlayer(location);
        let clock=user!=null?CaelumWorldClock.Get(user):world!=null?world.ReferenceClock:null;
        if(clock==null){Syncing=false;return;}
        double now=CaelumThermalRuntime.Stamp(clock),sampleStamp=now;
        let vendor=CaelumCityMerchant(item.Owner);
        bool parked=vendor!=null && vendor.DomesticMarketParked;
        // Provisiones viaja oculta con el registro, pero su clima y calendario
        // siguen siendo los de MAP03. El Limbo no envejece esa exposición.
        if(vendor!=null && HistoryReady && HistoryProfile!=CaelumWeatherRules.PROFILE_LIMBO)
        {
            double civil=CaelumHouseAwayWork.Civil(CaelumPlayer(clock.Owner));
            if(civil>=0)now=civil-HistoryCivilOffset;
        }
        let remote=CaelumHouseStorageEntry.Remote(location);
        if(remote!=null)
        {let store=CaelumHouseStorage.Get();if(store!=null)now=remote.SourceNow(CaelumPlayer(store.Owner));}
        if(HistoryReady && now<HistoryStamp){Syncing=false;return;}
        if(HistoryReady && now>HistoryStamp)
            for(int i=0;i<lots.Lots.Size();i++)
            {
                lots.Lots[i].BaseContamination=Replay(lots.Contamination(i),now);
                lots.Lots[i].ExposureAtEntry=lots.Exposure;
            }
        HistoryStamp=Stamp=now;
        if(Carried(item))
        {HistoryReady=false;Ready=true;NextUpdate=level.maptime+TICRATE;Syncing=false;return;}
        if(remote==null && !parked && world!=null && location!=null)
        {
            Actor original=Body;Body=location;Sample(world);Body=original;
            RecordSample(sampleStamp);Stamp=sampleStamp;HistoryArea=CaelumStackSurfaceData.UnitArea(item);
            if(Carried(item) || CaelumContaminationStorage.IsShielded(item))HistoryArea=0;
        }
        Ready=true;NextUpdate=level.maptime+TICRATE;Syncing=false;
    }
    override void Tick()
    {
        if(Body==null || Body.bDestroyed){Destroy();return;}
        if(!CaelumContaminationStack.Eligible(Inventory(Body)))return;
        if(NextUpdate==0)
        {let world=CaelumThermalWorld.Get();NextUpdate=level.maptime+1+(world!=null?world.NextPhase++%TICRATE:0);}
        if(level.maptime>=NextUpdate)CaelumContaminationStack.Reconcile(Inventory(Body));
    }
}

class CaelumStackExposureRow : Object play
{
    Inventory Item;
    CaelumFoodLots Lots;
    double Area;
}
