// Pulsos instantáneos: blockmap y rejilla física existente, nunca un censo global.
class CaelumTarotContamination : Object play
{
    CaelumPlayer Caster;
    Actor Probe;
    vector3 Center;
    double Radius,Concentration;
    bool PurifyWater;
    CaelumContaminationMap Sheet;
    Array<Actor> Visited;
    Array<Sector> Sectors;
    int BodyCount,SurfaceCount;

    bool Trace(vector3 point,out FLineTraceData hit)
    {
        vector3 ray=point-Center;
        if(ray.Length()<0.001)return false;
        return Caster.LineTrace(VectorAngle(ray.X,ray.Y),ray.Length()+0.02,
            -VectorAngle(ray.XY.Length(),ray.Z),TRF_ABSPOSITION|TRF_THRUACTORS,
            Center.Z,Center.X,Center.Y,hit);
    }
    bool VisiblePoint(vector3 point)
    {
        if((point-Center).Length()>Radius)return false;
        FLineTraceData hit;
        return !Trace(point,hit) || (hit.HitLocation-Center).Length()+0.03>=(point-Center).Length();
    }
    void Item(Inventory item)
    {
        if(item==null || item.bDestroyed || item.Amount<=0 || CaelumContaminationStorage.IsShielded(item))return;
        if(PurifyWater)CaelumTarotWater.Container(CaelumWaterContainer(item),self);
        if(item is 'CaelumEquipmentItem' || item is 'CaelumStorageFurnitureItem'
            || CaelumContaminationStack.Eligible(item))CaelumContaminationStorage.Set(item,Concentration);
        let set=CaelumDiningSetItem(item);
        if(set!=null && set.Table!=null && set.Table.Packed())
            for(int i=0;i<set.Table.Capacity();i++)Item(set.Table.Items[i]);
    }
    virtual void Body(Actor candidate)
    {
        if(!CaelumContaminationContacts.Eligible(candidate))return;
        Actor body=CaelumDiningContamination.Owner(candidate);
        if(body==null || !VisiblePoint(body.Pos+(0,0,body.Height/2)))return;
        for(int i=0;i<Visited.Size();i++)if(Visited[i]==body)return;
        Visited.Push(body);BodyCount++;
        CaelumContaminationStorage.Set(body,Concentration);
        if(PurifyWater)
        {
            CaelumTarotWater.Container(CaelumWaterContainer(body),self);
            let fixture=CaelumWaterFurniture(body);if(fixture!=null)fixture.SyncWater(Caster);
        }
        // La Caja y los cofres cerrados conservan su contenido; la cara exterior sí recibe el pulso.
        let chest=CaelumStashChest(body);
        if(chest!=null && !chest.ChestOpen)return;
        for(Inventory item=body.Inv;item!=null;item=item.Inv)Item(item);
        let table=CaelumDiningTable(body);
        if(table!=null)for(int i=0;i<table.Capacity();i++)Item(table.Items[i]);
        let npc=CaelumCombatActor(body);
        if(npc!=null && npc.CombatProfileInitialized)
        {
            let thermal=CaelumThermalBody.Get(npc,true);
            // Los combatientes sin fisiología planificada aún pueden poseer equipo.
            if(thermal==null){thermal=new('CaelumThermalState');thermal.Initialize();}
            CaelumThermalBody.Refresh(npc,thermal);
            let equipment=new('CaelumContaminationNPC');equipment.Capture(npc,thermal);
            for(int i=0;i<equipment.Frame.Items.Size();i++)
                equipment.Frame.Items[i].Endpoint.Set(Concentration);
        }
    }
    void Bodies()
    {
        let things=BlockThingsIterator.Create(Probe,Radius);
        while(things.Next())Body(things.thing);
        let world=CaelumContaminationWorld.Get();
        let grid=world!=null?world.ContactGrid():null;
        if(grid!=null && grid.Heads.Size()>0)
        {
            int left=int(Floor((Center.X-Radius)/grid.CELL)),right=int(Floor((Center.X+Radius)/grid.CELL));
            int low=int(Floor((Center.Y-Radius)/grid.CELL)),high=int(Floor((Center.Y+Radius)/grid.CELL));
            for(int x=left;x<=right;x++)for(int y=low;y<=high;y++)
                for(let row=grid.Heads[grid.Hash(x,y)];row!=null;row=row.GridNext)
                    if(row.GridX==x && row.GridY==y)Body(row.GridBody);
        }
        // También cubre el tic de admisión, antes del primer contacto del jugador.
        for(int i=0;i<MAXPLAYERS;i++)if(playeringame[i])Body(players[i].mo);
    }
    void AddSector(Sector sector)
    {
        if(sector==null)return;
        for(int i=0;i<Sectors.Size();i++)if(Sectors[i]==sector)return;
        Sectors.Push(sector);
    }
    virtual void Paint(CaelumContaminationTile tile,vector3 point)
    {
        if(tile==null)return;
        Probe.SetOrigin(point+(0,0,0.01),false);
        if(tile.Profile==0)CaelumContaminationSurfaceContact.ConfigureObject(Probe,tile);
        Sheet.Sync(tile,CaelumContaminationSurfaces.Now(Caster));
        CaelumContaminationSurfaceContact.ConfigureObject(Probe,tile);
        tile.Concentration=Concentration;SurfaceCount++;
    }
    void FloorPlane(Sector host,F3DFloor support)
    {
        let model=support!=null?support.model:host;
        double h=CaelumThermalMotion.SupportHeight(model,support,(0,0));
        vector2 slope=(CaelumThermalMotion.SupportHeight(model,support,(1,0))-h,
            CaelumThermalMotion.SupportHeight(model,support,(0,1))-h);
        double grade=slope.Length();vector2 uphill=grade>0?slope/grade:(1,0);
        double stretch=Sqrt(1+grade*grade);
        vector2 origin=CaelumContaminationSurfaceContact.PlaneCoordinates(Center.XY,slope);
        double cell=CaelumPhysicsUnits.MAP_UNITS_PER_METER*CaelumContaminationData.SURFACE_ZONE_METERS;
        int left=int(Floor((origin.X-Radius)/cell)),right=int(Floor((origin.X+Radius)/cell));
        int low=int(Floor((origin.Y-Radius)/cell)),high=int(Floor((origin.Y+Radius)/cell));
        for(int x=left;x<=right;x++)for(int y=low;y<=high;y++)
        {
            vector2 flat=((x+0.5)*cell,(y+0.5)*cell);
            vector2 xy=grade==0?flat:(uphill.X*flat.X/stretch-uphill.Y*flat.Y,
                uphill.Y*flat.X/stretch+uphill.X*flat.Y);
            if(level.PointInSector(xy)!=host)continue;
            vector3 point=(xy.X,xy.Y,CaelumThermalMotion.SupportHeight(model,support,xy));
            if((point-Center).Length()>Radius)continue;
            FLineTraceData hit;
            if(!Trace(point,hit) || hit.HitType!=FLineTraceData.TRACE_HitFloor
                || (hit.HitLocation-point).Length()>0.03)continue;
            Paint(Sheet.Find(support==null?0:1,model.Index(),0,x,y,true),point);
        }
    }
    void Wall(Line line)
    {
        double length=line.delta.Length();if(length<=0)return;
        vector2 along=line.delta/length,offset=Center.XY-line.v1.p;
        double projection=offset.X*along.X+offset.Y*along.Y;
        double cell=CaelumPhysicsUnits.MAP_UNITS_PER_METER*CaelumContaminationData.SURFACE_ZONE_METERS;
        int first=Max(0,int(Floor((projection-Radius)/cell)));
        int last=Min(int(Ceil(length/cell))-1,int(Floor((projection+Radius)/cell)));
        int low=int(Floor((Center.Z-Radius)/cell)),high=int(Floor((Center.Z+Radius)/cell));
        for(int x=first;x<=last;x++)for(int y=low;y<=high;y++)
        {
            vector2 xy=line.v1.p+along*Min((x+0.5)*cell,(x*cell+length)/2);
            vector3 point=(xy.X,xy.Y,(y+0.5)*cell);
            if((point-Center).Length()>Radius)continue;
            FLineTraceData hit;
            if(!Trace(point,hit) || hit.HitLine!=line || (hit.HitLocation-point).Length()>0.03)continue;
            Paint(Sheet.Find(2,line.Index(),level.PointOnLineSide(Center.XY,line),x,y,true),point);
        }
    }
    void Surfaces()
    {
        Sheet=CaelumContaminationSurfaces.CurrentMap(Caster);if(Sheet==null)return;
        AddSector(level.PointInSector(Center.XY));
        Probe.SetOrigin(Center,false);
        let lines=BlockLinesIterator.Create(Probe,Radius);
        while(lines.Next())
        {
            let line=lines.CurLine;
            AddSector(line.frontsector);AddSector(line.backsector);Wall(line);
        }
        for(int i=0;i<Sectors.Size();i++)
        {
            let sector=Sectors[i];FloorPlane(sector,null);
            for(int j=0;j<sector.Get3DFloorCount();j++)
            {
                let floor=sector.Get3DFloor(j);
                if((floor.flags&(F3DFloor.FF_EXISTS|F3DFloor.FF_SOLID))==(F3DFloor.FF_EXISTS|F3DFloor.FF_SOLID))FloorPlane(sector,floor);
            }
        }
    }
    static CaelumTarotContamination Pulse(CaelumPlayer user,vector3 point,double concentration,double multiplier,bool purifyWater=false)
    {
        if(user==null || user.bDestroyed || multiplier<=0)return null;
        let pulse=new('CaelumTarotContamination');pulse.Caster=user;pulse.Center=point;
        pulse.Radius=CaelumMajorArcanaData.AREA_METERS*CaelumPhysicsUnits.MAP_UNITS_PER_METER*multiplier;
        pulse.Concentration=Clamp(concentration,0,CaelumFoodData.MAX_CONTAMINATION);
        pulse.PurifyWater=purifyWater;
        pulse.Probe=Actor.Spawn('CaelumTarotContaminationProbe',point,NO_REPLACE);
        if(pulse.Probe==null)return null;
        pulse.Bodies();pulse.Surfaces();
        if(purifyWater){let water=CaelumTarotWaterMap.Ensure();if(water!=null)water.Pulse(pulse);}
        pulse.Probe.Destroy();pulse.Probe=null;
        return pulse;
    }
    static bool Hierophant(CaelumPlayer user,CaelumTarotGroundAim snapshot)
    {
        if(user==null || user.DerivedStats==null)return false;
        double range=snapshot!=null?snapshot.RangeMultiplier:user.DerivedStats.AbilityRangePercent/100.0;
        return Pulse(user,user.Pos+(0,0,user.Height/2),0,range,true)!=null;
    }
    static bool Death(CaelumPlayer user,Actor aimed,CaelumTarotGroundAim snapshot)
    {
        if(!CaelumMajorTargets.Visible(user,aimed))return false;
        double range=snapshot!=null?snapshot.RangeMultiplier:user.DerivedStats.AbilityRangePercent/100.0;
        return Pulse(user,aimed.Pos+(0,0,aimed.Height/2),CaelumFoodData.MAX_CONTAMINATION,range)!=null;
    }
}

class CaelumTarotContaminationProbe : Actor
{
    Default {Radius 0.01;Height 0.01;+NOGRAVITY +NOBLOCKMAP +NOINTERACTION RenderStyle "None";}
    States {Spawn:TNT1 A -1;Stop;}
}
