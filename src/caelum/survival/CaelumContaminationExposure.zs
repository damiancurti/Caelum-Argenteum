// #502: copia independiente para pronósticos y caché de equipo propio.
class CaelumContaminationEquipment : Object play
{
    CaelumEquipmentItem Item;
    CaelumContaminationContactPoint Endpoint;
    double Concentration,Area;
    int Slot,Kind;
    bool Worn;
}

class CaelumContaminationExposure : Object play
{
    Array<CaelumContaminationEquipment> Items;
    Array<CaelumStackExposureRow> Stacks;
    double BodyArea[4];
    double ContactSource[4];
    double WetArea[4],DirtyArea[4],CleanArea[4],ExcludedBodyArea[4],WaterBodyArea[4];
    double WetFraction,DirtyFraction;
    bool DynamicWater;
    double BodyKg;
    int Armor[4],Clothes[4];

    void CaptureStack(Actor owner,Inventory item)
    {
        if(item==null || !CaelumContaminationStack.Eligible(item) || item.Amount<=0
            || CaelumContaminationStack.Carrier(item)!=owner || CaelumContaminationStorage.IsShielded(item))return;
        CaelumContaminationStack.Reconcile(item);let row=new('CaelumStackExposureRow');
        row.Item=item;row.Area=CaelumStackSurfaceData.UnitArea(item);
        row.Lots=CaelumContaminationStack.Prepare(item).Copy();Stacks.Push(row);
    }
    void CaptureStacks(Actor owner)
    {
        Stacks.Clear();
        for(Inventory item=owner.Inv;item!=null;item=item.Inv)
        {
            CaptureStack(owner,item);
            let set=CaelumDiningSetItem(item);
            if(set!=null && set.Table!=null && set.Table.Packed())
                for(int i=0;i<set.Table.Capacity();i++)CaptureStack(owner,set.Table.Items[i]);
        }
    }
    void CommitStacks(Actor owner)
    {
        for(int i=0;i<Stacks.Size();i++)
        {
            let row=Stacks[i];let item=row.Item;
            if(item==null || item.bDestroyed || CaelumContaminationStack.Carrier(item)!=owner || CaelumContaminationStorage.IsShielded(item))continue;
            CaelumContaminationStack.Record(item).StackLots=row.Lots.Copy();
        }
    }

    void Capture(CaelumPlayer user,CaelumThermalState thermal)
    {
        CaptureStacks(user);
        Items.Clear();BodyKg=thermal.BodyMassKg;
        for(int slot=0;slot<4;slot++)
        {Armor[slot]=-1;Clothes[slot]=-1;BodyArea[slot]=thermal.SurfaceArea*thermal.Coverage[slot];}
        Immersion(thermal);
        // Sólo inventario del personaje, una vez por cambio/captura; nunca actores del mapa.
        for(Inventory cursor=user.Inv;cursor!=null;cursor=cursor.Inv)
        {
            let item=CaelumEquipmentItem(cursor);
            if(item==null || item.InMagicBox || item.Amount<=0)continue;
            int kind=item.EquipmentKind;
            if(kind!=CaelumConstants.EQUIPMENT_KIND_ARMOR && kind!=CaelumConstants.EQUIPMENT_KIND_CLOTHING
                && kind!=CaelumConstants.EQUIPMENT_KIND_WEAPON && kind!=CaelumConstants.EQUIPMENT_KIND_SHIELD)continue;
            let row=new('CaelumContaminationEquipment');row.Item=item;
            row.Kind=kind;row.Slot=Clamp(item.ArmorSlot,0,3);row.Worn=false;
            row.Concentration=CaelumContaminationStorage.Value(item);
            if(kind==CaelumConstants.EQUIPMENT_KIND_WEAPON)
                row.Area=CaelumContaminationRules.WeaponArea(item.ItemType,item.EquipmentSize);
            else if(kind==CaelumConstants.EQUIPMENT_KIND_SHIELD)
                row.Area=CaelumContaminationRules.ShieldArea(item.ItemType,item.EquipmentSize);
            else
            {
                row.Area=CaelumContaminationRules.GarmentArea(row.Slot,item.EquipmentSize);
                if(kind==CaelumConstants.EQUIPMENT_KIND_ARMOR && item==CaelumThermalBody.EquippedPiece(user,row.Slot))
                {row.Worn=true;Armor[row.Slot]=Items.Size();}
                else if(kind==CaelumConstants.EQUIPMENT_KIND_CLOTHING && item==CaelumClothing.Equipped(user,row.Slot))
                {row.Worn=true;Clothes[row.Slot]=Items.Size();}
            }
            Items.Push(row);
        }
    }

    void Immersion(CaelumThermalState thermal)
    {
        double total=0,wet=0,dirty=0;
        for(int slot=0;slot<4;slot++)
        {
            WetArea[slot]=Clamp(thermal.SurfaceArea*thermal.SubmergedCoverage[slot],0,BodyArea[slot]);
            DirtyArea[slot]=Clamp(thermal.SurfaceArea*thermal.DirtyWaterCoverage[slot],0,WetArea[slot]);
            CleanArea[slot]=Clamp(thermal.SurfaceArea*thermal.CleanWaterCoverage[slot],0,WetArea[slot]);
            total+=BodyArea[slot];wet+=WetArea[slot];dirty+=DirtyArea[slot];
        }
        WetFraction=total>0 ? wet/total : 0;DirtyFraction=total>0 ? dirty/total : 0;
        DynamicWater=thermal.DynamicContactWater;
    }
    void ClearImmersion()
    {
        for(int slot=0;slot<4;slot++){WetArea[slot]=0;DirtyArea[slot]=0;CleanArea[slot]=0;ExcludedBodyArea[slot]=0;WaterBodyArea[slot]=0;}
        WetFraction=0;DirtyFraction=0;DynamicWater=false;
    }
    void Exterior(int index,double ambient,double area,double wet,double dirty,double seconds)
    {
        if(index<0)return;
        Items[index].Concentration=CaelumContaminationRules.TwoSources(Items[index].Concentration,
            ambient,Max(0,area-wet),CaelumFoodData.MAX_CONTAMINATION,dirty,seconds);
    }

    void ReadLive()
    {
        for(int i=0;i<Stacks.Size();i++)
        {
            let item=Stacks[i].Item;if(item==null || item.bDestroyed)continue;
            CaelumContaminationStack.Reconcile(item);Stacks[i].Lots=CaelumContaminationStack.Prepare(item).Copy();
        }
        for(int i=0;i<Items.Size();i++)Items[i].Concentration=Items[i].Endpoint!=null
            ? Items[i].Endpoint.Value() : CaelumContaminationStorage.Value(Items[i].Item);
    }
    bool Valid(CaelumPlayer user,CaelumThermalState thermal)
    {
        for(int i=0;i<Stacks.Size();i++)
            if(Stacks[i].Item==null || Stacks[i].Item.bDestroyed || CaelumContaminationStack.Carrier(Stacks[i].Item)!=user
                || CaelumContaminationStorage.IsShielded(Stacks[i].Item))return false;
        if(BodyKg!=thermal.BodyMassKg)return false;
        for(int slot=0;slot<4;slot++)if(BodyArea[slot]!=thermal.SurfaceArea*thermal.Coverage[slot])return false;
        for(int i=0;i<Items.Size();i++)
        {
            let row=Items[i];
            if(row.Item==null || row.Item.Owner!=user || row.Item.InMagicBox || row.Item.Amount<=0)return false;
            if((row.Kind==CaelumConstants.EQUIPMENT_KIND_ARMOR || row.Kind==CaelumConstants.EQUIPMENT_KIND_CLOTHING)
                && row.Worn!=row.Item.Equipped)return false;
        }
        return true;
    }
    void Commit(CaelumPlayer user)
    {
        CommitStacks(user);
        for(int i=0;i<Items.Size();i++)
        {
            let row=Items[i];
            if(row.Item!=null && row.Item.Owner==user && !row.Item.InMagicBox
                && row.Concentration!=CaelumContaminationStorage.Value(row.Item))
                CaelumContaminationStorage.Set(row.Item,row.Concentration);
        }
    }
    void Expose(int index,double source,double area,double seconds)
    {
        if(index<0)return;
        let row=Items[index];
        row.Concentration=CaelumContaminationRules.AfterContact(row.Concentration,source,area,seconds);
    }
    void Pair(int a,int b,double area,double seconds)
    {
        if(a<0 || b<0)return;
        double first=Items[a].Concentration,second=Items[b].Concentration;
        if(first>second)Expose(b,first,area,seconds);else Expose(a,second,area,seconds);
    }
    void Advance(CaelumFoodIllness illness,double ambient,double seconds)
    {
        if(illness==null || seconds<=0)return;
        for(int i=0;i<Stacks.Size();i++)
        {let row=Stacks[i];CaelumContaminationStack.Expose(row.Lots,ambient,row.Area,row.Area*WetFraction,row.Area*DirtyFraction,seconds);}
        double body=illness.Contamination;
        for(int i=0;i<Items.Size();i++)if(!Items[i].Worn)
            Exterior(i,ambient,Items[i].Area,Items[i].Area*WetFraction,Items[i].Area*DirtyFraction,seconds);
        for(int slot=0;slot<4;slot++)
        {
            int armor=Armor[slot],cloth=Clothes[slot];
            int outer=armor>=0 ? armor : cloth;
            double area=BodyArea[slot],source=ambient;
            ExcludedBodyArea[slot]=outer>=0 ? 0 : WetArea[slot];
            WaterBodyArea[slot]=outer>=0 ? 0 : DirtyArea[slot];
            if(outer>=0)
            {
                Exterior(outer,ambient,area,WetArea[slot],DirtyArea[slot],seconds);
                Pair(armor,cloth,area,seconds);
                int inner=cloth>=0 ? cloth : armor;
                source=Items[inner].Concentration;
                if(body>source)Expose(inner,body,area,seconds);
            }
            ContactSource[slot]=source;
        }
        double clean=0;for(int slot=0;slot<4;slot++)clean+=CleanArea[slot];
        // El lavado corporal no sustituye la limpieza del equipo: éste conserva
        // su concentración y puede volver a transmitirla por contacto.
        illness.Contamination=CaelumContaminationRules.ImmersionWash(BodyContact(body,seconds),clean,seconds,BodyKg);
    }
    double BodyContact(double value,double seconds)
    {
        // Integra juntas las zonas que todavía tienen mayor concentración.
        // Cada fuente deja de aportar al alcanzarla; como máximo hay cuatro cortes.
        for(int pass=0;pass<5 && seconds>0;pass++)
        {
            double weighted=0,boundary=CaelumFoodData.MAX_CONTAMINATION;
            for(int slot=0;slot<4;slot++)
            {
                double area=Max(0,BodyArea[slot]-ExcludedBodyArea[slot]);
                if(ContactSource[slot]>value && area>0)
                {weighted+=area*ContactSource[slot];boundary=Min(boundary,ContactSource[slot]);}
                if(value<CaelumFoodData.MAX_CONTAMINATION)weighted+=WaterBodyArea[slot]*CaelumFoodData.MAX_CONTAMINATION;
            }
            double rate=CaelumContaminationData.CONTACT_DEGREES_M2_SECOND*weighted
                *CaelumContaminationRules.BodyDoseFactor(BodyKg);
            if(rate<=0)break;
            double timeToBoundary=(CaelumContaminationRules.ContactPrimitive(boundary)-CaelumContaminationRules.ContactPrimitive(value))/rate;
            if(seconds>=timeToBoundary){value=boundary;seconds-=timeToBoundary;}
            else
            {
                value=CaelumContaminationRules.AfterContact(value,boundary,weighted/boundary,seconds,
                    CaelumContaminationRules.BodyDoseFactor(BodyKg));break;
            }
        }
        return value;
    }
}

class CaelumContaminationRuntime : Object play
{
    static void PlayerStep(CaelumPlayer user,CaelumThermalState thermal,double seconds)
    {
        if(user==null || thermal==null || !thermal.Available || user.health<=0 || seconds<=0)return;
        double reference=CaelumContaminationEnvironment.ReferenceAt(user);
        if(user.ContaminationExposure==null || !user.ContaminationExposure.Valid(user,thermal))
        {
            user.ContaminationExposure=new('CaelumContaminationExposure');
            user.ContaminationExposure.Capture(user,thermal);
        }
        let exposure=user.ContaminationExposure;
        exposure.Immersion(thermal);
        exposure.ReadLive();
        exposure.Advance(CaelumFoodIllness.Get(user),reference>=0 ? CaelumContaminationRules.Ambient(
            reference,thermal.AirC,thermal.Humidity,thermal.RainMmHour,!thermal.Roof) : -1,seconds);
        exposure.Commit(user);
        CaelumContaminationSurfaceContact.Step(user,thermal,seconds);
    }
}
